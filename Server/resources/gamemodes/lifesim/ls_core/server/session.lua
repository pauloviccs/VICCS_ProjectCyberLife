--[[
    LIFESIM RP - Player Session & Lifecycle Manager
    Path: ls_core/server/session.lua
    Controla o ciclo de vida de conexão, resolução de identidade permanente (license) e gate de prontidão.
]]

local function nowMs()
    return GetGameTimer()
end

---Garante a existência de uma estrutura de sessão em memória para o jogador
---@param playerId integer
---@return table|nil
function Core.ensureSession(playerId)
    if not LS.isPlayerId(playerId) then return nil end
    local s = Core.sessions[playerId]
    if not s then
        s = {
            playerId = playerId,
            state = "connected",
            sinceMs = nowMs(),
            clientReady = false,
            announced = false
        }
        Core.sessions[playerId] = s
    end
    return s
end

-- Grafo de transições de sessão válidas
local EDGES = {
    connected = { loading = true, dropped = true },
    loading   = { loaded = true, rejected = true, dropped = true },
    loaded    = { dropped = true },
    rejected  = { dropped = true },
    dropped   = {}
}
Core.transition = LS.makeTransition(EDGES)

---Inicia o carregamento seguro do perfil do jogador
---@param playerId integer
function Core.beginLoad(playerId)
    local s = Core.ensureSession(playerId)
    if not s or s.state ~= "connected" then return end

    Core.transition(s, "loading", "begin")

    CreateThread(function()
        -- 1. Capturar sessão do gate ANTES de qualquer chamada assíncrona
        local gate = Open77.ready.status(playerId)
        local gateSession = gate and gate.session

        -- 2. Resolver identificadores oficiais com fallback robusto (LAN/dev/offline compatível)
        local ids = Open77.players.identifiers(playerId) or {}
        local rawLicense = ids.license
        if type(rawLicense) ~= "string" or rawLicense == "" then
            if GetPlayerIdentifierByType then
                pcall(function() rawLicense = GetPlayerIdentifierByType(playerId, "license") end)
            end
        end

        if type(rawLicense) ~= "string" or rawLicense == "" then
            local fallbackId = ids.userId or ids.open77 or ids.fingerprint or ("player_" .. tostring(playerId))
            rawLicense = "dev_" .. tostring(fallbackId):gsub("[^%w]", "")
        end

        -- Sanitiza para formato limpo alfanumérico de até 32 caracteres (compatível com schema CHAR(32))
        local license = rawLicense:gsub("%-", ""):lower()
        if #license < 32 then
            license = (license .. string.rep("0", 32)):sub(1, 32)
        else
            license = license:sub(1, 32)
        end

        s.license = license
        s.userId = ids.userId or ids.open77 or tostring(playerId)
        s.name = ids.name or ids.displayName or ("Cidadão #%d"):format(playerId)

        -- 3. Carregar ou criar perfil no banco (ls_data)
        local call = Open77.exports.call("ls_data", "loadOrCreateProfile", license, s.userId, s.name)
        local profile, err
        if call then
            profile, err = call:await()
        else
            profile, err = exports["ls_data"]:loadOrCreateProfile(license, s.userId, s.name)
        end

        -- Se o jogador desconectou durante o await, abortar
        if Core.sessions[playerId] ~= s then return end

        if not profile then
            Core.transition(s, "rejected", err or "profile_load_failed")
            Open77.log.error(("[ls_core] Falha ao carregar perfil do jogador %d: %s"):format(playerId, tostring(err)))
            return
        end

        -- 4. Registrar mapeamento por licença e marcar como carregado
        Core.byLicense[license] = playerId
        Core.transition(s, "loaded", "profile_ready")
        s.loadedAtMs = nowMs()

        -- Replicar estado no state bag (leitura leve para clientes)
        Open77.state.player(playerId):set("ls.core.loaded", true)

        -- 5. Liberar hold no gate de prontidão se existente
        if gateSession then
            Open77.ready.release(playerId, gateSession, "ls_profile_loaded")
        end

        -- 6. Tentar anunciar entrada do jogador
        Core.maybeAnnounce(playerId)
    end)
end

---Dispara o evento ls:core:playerLoaded quando o perfil estiver carregado e o jogador estiver ativo
---@param playerId integer
function Core.maybeAnnounce(playerId)
    local s = Core.sessions[playerId]
    if not s or s.state ~= "loaded" or s.announced then return end

    local isClientReady = s.clientReady == true
    local isPlatformReady = (Open77.ready and Open77.ready.isReady and Open77.ready.isReady(playerId)) or false
    local timeSinceLoad = nowMs() - (s.loadedAtMs or nowMs())

    -- Não bloqueia indefinidamente por holds de outros mods: anuncia se o cliente confirmou ou após tolerância de 3s
    if not (isClientReady or isPlatformReady or timeSinceLoad >= 3000) then
        return
    end

    s.announced = true
    Open77.log.info(("[ls_core] Jogador %d (%s | %s) totalmente carregado e anunciado ao ecossistema."):format(
        playerId, s.name, s.license
    ))

    -- Dispara para todo o ecossistema com playerId numérico
    TriggerEvent("ls:core:playerLoaded", playerId, s.license)
    TriggerClientEvent("ls:core:playerLoaded", playerId, s.license)
end

-- Watchdog de sessões ativas (garante que nenhuma sessão fique travada sem carregar ou anunciar)
CreateThread(function()
    while true do
        Wait(1500)
        for playerId, s in pairs(Core.sessions) do
            if s.state == "loaded" and not s.announced then
                Core.maybeAnnounce(playerId)
            elseif s.state == "connected" and (nowMs() - (s.connectedAtMs or 0)) > 2000 then
                Core.beginLoad(playerId)
            end
        end
    end
end)

-- =============================================================================
-- EVENT HANDLERS DO HOST
-- =============================================================================

AddEventHandler("onPlayerConnected", function(playerIdStr)
    local playerId = LS.toPlayerId(playerIdStr)
    if not playerId then return end
    Core.ensureSession(playerId)
    Core.beginLoad(playerId)
end)

AddEventHandler("onPlayerReady", function(playerIdStr)
    local playerId = LS.toPlayerId(playerIdStr)
    if playerId then
        Core.maybeAnnounce(playerId)
    end
end)

RegisterNetEvent("ls:core:clientReady", function()
    local playerId = source
    local s = Core.ensureSession(playerId)
    if not s then return end
    s.clientReady = true
    Core.maybeAnnounce(playerId)
end)

AddEventHandler("onPlayerDisconnected", function(playerIdStr, reason)
    local playerId = LS.toPlayerId(playerIdStr)
    local s = playerId and Core.sessions[playerId]
    if not s then return end

    Core.sessions[playerId] = nil
    if s.license then
        Core.byLicense[s.license] = nil
    end

    Core.transition(s, "dropped", reason)

    -- Notifica módulos que o jogador está descarregando (cache ainda íntegro)
    TriggerEvent("ls:core:playerUnloading", playerId, s.license, reason)

    CreateThread(function()
        if s.license then
            -- Flush dos dados do jogador no banco
            local call = Open77.exports.call("ls_data", "flushLicense", s.license)
            if call then call:await() end
        end
        TriggerEvent("ls:core:playerDropped", playerId, s.license, reason)
    end)
end)

-- =============================================================================
-- EXPORTS PÚBLICOS DE SESSÃO
-- =============================================================================

exports("getPlayerLicense", function(playerId)
    local s = Core.sessions[playerId]
    return s and s.license or nil
end)

exports("isPlayerLoaded", function(playerId)
    local s = Core.sessions[playerId]
    return s and s.state == "loaded" or false
end)
