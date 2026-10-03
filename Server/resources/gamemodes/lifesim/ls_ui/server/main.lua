--[[
    LIFESIM RP - Native UI Server Manager & Persistence
    Path: ls_ui/server/main.lua
    Gerencia a persistência de configurações de interface do usuário (ex: posicionamento do Biomonitor HUD),
    integração com ls_data (cache write-behind / MariaDB) e sincronização com novos jogadores.
]]

local Module = {
    name = "ls_ui",
    version = "0.1.0",
    ready = false
}

local UISettings = {
    players = {},   -- [playerId] = { license = string, settings = table }
    byLicense = {}  -- [license] = playerId
}

-- =============================================================================
-- INICIALIZAÇÃO & MIGRAÇÕES DE DADOS
-- =============================================================================

CreateThread(function()
    -- 1. Aguardar prontidão da camada de dados
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registrar migração declarativa para tabela ls_ui_settings
    local migrations = {
        {
            version = 1,
            name = "create_ls_ui_settings",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_ui_settings (
                    license      CHAR(32)  NOT NULL,
                    data         JSON      NOT NULL,
                    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (license),
                    CONSTRAINT fk_ls_ui_settings_license FOREIGN KEY (license) REFERENCES ls_players(license) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }
    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_ui", migrations)
    if migCall then migCall:await() end

    -- 3. Registrar namespace no CacheService de alta performance
    local cacheCall = Open77.exports.call("ls_data", "registerCacheNamespace", "ui_settings", "ls_ui_settings", "license", "data")
    if cacheCall then cacheCall:await() end

    -- 4. Registrar módulo no ls_core
    local regCall = Open77.exports.call("ls_core", "registerModule", {
        version = Module.version,
        requires = { "ls_data", "ls_core" },
        provides = { "getSettings", "saveSettings" },
        emits = { "ls:ui:syncSettings" },
        listens = { "ls:core:playerLoaded", "ls:core:playerUnloading" },
        stateKeys = {},
        tables = { "ls_ui_settings" }
    })
    if regCall then regCall:await() end

    Module.ready = true
    Open77.log.info(("[ls_ui] Servidor de UI e persistência de layout inicializados (v%s)."):format(Module.version))
end)

-- =============================================================================
-- RESOLUÇÃO DE IDENTIDADE & CICLO DE VIDA DO JOGADOR
-- =============================================================================

---Resolve a licença única do jogador no Core
---@param playerId integer
---@return string|nil
local function resolveLicense(playerId)
    if not LS.isPlayerId(playerId) then return nil end
    local p = UISettings.players[playerId]
    if p and p.license then return p.license end

    local license
    local licCall = Open77.exports.call("ls_core", "getPlayerLicense", playerId)
    if licCall then
        license = licCall:await()
    end

    if not license or license == "" then
        local ids = Open77.players and Open77.players.identifiers and Open77.players.identifiers(playerId) or {}
        local rawLicense = ids.license or ids.userId or ids.open77 or ids.fingerprint or ("player_" .. tostring(playerId))
        license = tostring(rawLicense):gsub("[^%w]", ""):lower()
        if #license < 32 then
            license = (license .. string.rep("0", 32)):sub(1, 32)
        else
            license = license:sub(1, 32)
        end
    end

    return license
end

---Carrega as configurações salvas do jogador do banco ou cache
---@param playerId integer
---@param license string
local function loadPlayerSettings(playerId, license)
    if not LS.isPlayerId(playerId) or not license then return end

    CreateThread(function()
        local loadCall = Open77.exports.call("ls_data", "cacheLoad", "ui_settings", license)
        local rawSettings = loadCall and loadCall:await()
        local settings = {}

        if type(rawSettings) == "table" then
            settings = rawSettings
        end

        UISettings.players[playerId] = {
            license = license,
            settings = settings
        }
        UISettings.byLicense[license] = playerId

        Open77.log.info(("[ls_ui] Configurações de layout carregadas para jogador [%d] (%s)"):format(playerId, license))

        -- Envia para o cliente as configurações restauradas
        TriggerClientEvent("ls:ui:syncSettings", playerId, settings)
    end)
end

---Descarrega o jogador e assegura persistência de suas configurações
---@param playerId integer
local function unloadPlayerSettings(playerId)
    local p = UISettings.players[playerId]
    if not p then return end

    if p.license and p.settings then
        Open77.exports.call("ls_data", "cacheSet", "ui_settings", p.license, p.settings)
        Open77.exports.call("ls_data", "flushLicense", p.license)
    end

    if p.license then
        UISettings.byLicense[p.license] = nil
    end
    UISettings.players[playerId] = nil
    Open77.log.info(("[ls_ui] Configurações de UI descarregadas para jogador [%d]"):format(playerId))
end

AddEventHandler("ls:core:playerLoaded", function(playerId, license)
    loadPlayerSettings(playerId, license)
end)

AddEventHandler("ls:core:playerUnloading", function(playerId, license)
    unloadPlayerSettings(playerId)
end)

AddEventHandler("playerDropped", function(reason)
    unloadPlayerSettings(source)
end)

-- =============================================================================
-- REDE & SINCRONIZAÇÃO DE CONFIGURAÇÕES DE INTERFACE
-- =============================================================================

-- Cliente solicitando suas configurações salvas (ex: ao terminar de carregar o CEF)
RegisterNetEvent("ls:ui:requestSettings", function()
    local src = source
    if not LS.isPlayerId(src) then return end

    local p = UISettings.players[src]
    if p and p.settings then
        TriggerClientEvent("ls:ui:syncSettings", src, p.settings)
    else
        local license = resolveLicense(src)
        if license then
            loadPlayerSettings(src, license)
        end
    end
end)

-- Cliente enviando nova posição salva do Biomonitor
RegisterNetEvent("ls:ui:saveBiomonitorPos", function(pos)
    local src = source
    if not LS.isPlayerId(src) or type(pos) ~= "table" then return end

    local left = tonumber(pos.left)
    local top = tonumber(pos.top)
    if not left or not top then return end

    -- Limites de segurança na tela (suporte a resoluções até 4K)
    left = math.max(0, math.min(3840, math.floor(left)))
    top = math.max(0, math.min(2160, math.floor(top)))

    local license = resolveLicense(src)
    if not license then return end

    local p = UISettings.players[src]
    if not p then
        p = { license = license, settings = {} }
        UISettings.players[src] = p
        UISettings.byLicense[license] = src
    end

    p.settings.biomonitor = { left = left, top = top }

    -- Persistência via ls_data CacheService (Write-Behind no MariaDB)
    Open77.exports.call("ls_data", "cacheSet", "ui_settings", license, p.settings)
    Open77.log.info(("[ls_ui] Posição do Biomonitor salva no banco para [%d] (%s): Left=%d, Top=%d"):format(
        src, license, left, top
    ))
end)

-- Cliente solicitando reset da posição do Biomonitor para o padrão de fábrica
RegisterNetEvent("ls:ui:resetBiomonitorPos", function()
    local src = source
    if not LS.isPlayerId(src) then return end

    local license = resolveLicense(src)
    if not license then return end

    local p = UISettings.players[src]
    if p and p.settings then
        p.settings.biomonitor = nil
        Open77.exports.call("ls_data", "cacheSet", "ui_settings", license, p.settings)
        Open77.log.info(("[ls_ui] Posição do Biomonitor resetada no banco para [%d] (%s)"):format(src, license))
    end
end)

-- =============================================================================
-- EXPORTS SERVIDOR
-- =============================================================================

exports("getSettings", function(playerId)
    local p = UISettings.players[playerId]
    return p and p.settings or nil
end)

exports("saveSettings", function(playerId, settings)
    if not LS.isPlayerId(playerId) or type(settings) ~= "table" then return false end
    local license = resolveLicense(playerId)
    if not license then return false end

    local p = UISettings.players[playerId]
    if not p then
        p = { license = license, settings = settings }
        UISettings.players[playerId] = p
        UISettings.byLicense[license] = playerId
    else
        p.settings = settings
    end

    Open77.exports.call("ls_data", "cacheSet", "ui_settings", license, p.settings)
    TriggerClientEvent("ls:ui:syncSettings", playerId, p.settings)
    return true
end)
