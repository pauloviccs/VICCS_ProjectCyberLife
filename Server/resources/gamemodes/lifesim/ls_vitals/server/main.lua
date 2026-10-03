--[[
    LIFESIM RP - Vitals Server Engine & Dynamic Telemetry
    Path: ls_vitals/server/main.lua
    Controla o ciclo biológico, decaimento monotônico dinâmico com esforço motor,
    logs em tempo real, histerese e persistência write-behind.
]]

local Vitals = {
    ready = false,
    players = {},
    byLicense = {}
}

local function nowMs()
    return GetGameTimer()
end

local function cloneTable(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

local function hasCrossedHysteresis(current, last)
    if not last then return true end
    local th = VitalsConfig.HysteresisThreshold or 0.10
    if math.abs((current.hunger or 0) - (last.hunger or 0)) >= th then return true end
    if math.abs((current.thirst or 0) - (last.thirst or 0)) >= th then return true end
    if math.abs((current.energy or 0) - (last.energy or 0)) >= th then return true end
    if math.abs((current.hygiene or 0) - (last.hygiene or 0)) >= th then return true end
    if math.abs((current.stress or 0) - (last.stress or 0)) >= th then return true end
    return false
end

-- =============================================================================
-- INICIALIZAÇÃO & REGISTRO DE CONTRATOS
-- =============================================================================

CreateThread(function()
    -- 1. Aguardar prontidão dos subsistemas de dados e core
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registrar migração do módulo ls_vitals
    local migrations = {
        {
            version = 1,
            checksum = "base_ls_vitals_schema_v1",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_vitals (
                    license      CHAR(32)  NOT NULL,
                    data         JSON      NOT NULL,
                    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (license),
                    CONSTRAINT fk_ls_vitals_license FOREIGN KEY (license) REFERENCES ls_players(license) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }
    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_vitals", migrations)
    if migCall then migCall:await() end

    -- 3. Registrar namespace declarativo no CacheService
    local cacheCall = Open77.exports.call("ls_data", "registerCacheNamespace", "vitals", "ls_vitals", "license", "data")
    if cacheCall then cacheCall:await() end

    -- 4. Registrar módulo no ls_core
    local regCall = Open77.exports.call("ls_core", "registerModule", {
        version = "0.1.0",
        requires = { "ls_data", "ls_core" },
        provides = { "getVitals", "setVitals", "modifyVitals", "consumeItem" },
        emits = { "ls:vitals:critical", "ls:vitals:updated" },
        listens = { "ls:core:playerLoaded", "ls:core:playerUnloading" },
        stateKeys = {
            ["ls.vitals.v"] = { maxBytes = 512 }
        },
        tables = { "ls_vitals" }
    })
    if regCall then regCall:await() end

    Vitals.ready = true
    Open77.log.info("[ls_vitals] Submódulo biológico e motor de necessidades inicializados.")
end)

-- =============================================================================
-- CICLO DE VIDA DO JOGADOR
-- =============================================================================

---Carrega e inicializa os vitais de um jogador recém-carregado no Core
---@param playerId integer
---@param license string
---Carrega e inicializa os vitais de um jogador recém-carregado no Core
---@param playerId integer
---@param license string
local function onPlayerLoaded(playerId, license)
    if not LS.isPlayerId(playerId) or not license then return end

    CreateThread(function()
        -- Carregar vitais do cache ou banco
        local loadCall = Open77.exports.call("ls_data", "cacheLoad", "vitals", license)
        local rawVitals = loadCall and loadCall:await()
        local nowUnix = Open77.time.unix()

        local vitals
        if type(rawVitals) == "table" and rawVitals.hunger ~= nil then
            vitals = cloneTable(rawVitals)
            -- Calcular decaimento offline
            local elapsedSec = math.max(0, nowUnix - (tonumber(vitals.lastUpdateUnix) or nowUnix))
            if elapsedSec > 60 then
                local decayHours = math.min(elapsedSec / 3600.0, VitalsConfig.Offline.MaxDecayHours)
                local decayMinutes = decayHours * 60.0
                local mult = VitalsConfig.Offline.DecayRateMultiplier

                vitals.hunger = math.max(VitalsConfig.Offline.MinHunger, vitals.hunger - (VitalsConfig.Decay.HungerPerMin * decayMinutes * mult))
                vitals.thirst = math.max(VitalsConfig.Offline.MinThirst, vitals.thirst - (VitalsConfig.Decay.ThirstPerMin * decayMinutes * mult))
                vitals.energy = math.max(VitalsConfig.Offline.MinEnergy, vitals.energy - (VitalsConfig.Decay.EnergyPerMin * decayMinutes * mult))
                vitals.hygiene = math.max(15.0, vitals.hygiene - (VitalsConfig.Decay.HygienePerMin * decayMinutes * mult))
                vitals.lastUpdateUnix = nowUnix

                Open77.log.info(("[ls_vitals] Decaimento offline aplicado a %s: %.1f horas ausente."):format(license, decayHours))
            end
        else
            -- Novo jogador: valores plenos de fábrica
            vitals = {
                hunger = 100.0,
                thirst = 100.0,
                energy = 100.0,
                hygiene = 100.0,
                stress = 0.0,
                lastUpdateUnix = nowUnix
            }
        end

        vitals.activity = "idle"
        vitals.activityMult = 1.0
        vitals.rateMult = VitalsConfig.GlobalRateMultiplier

        local tNow = nowMs()
        local record = {
            playerId = playerId,
            license = license,
            vitals = vitals,
            clientActivity = "idle",
            activityMult = 1.0,
            lastPos = nil,
            speed = 0.0,
            lastTickMs = tNow,
            lastReplicatedMs = tNow,
            lastReplicatedVitals = cloneTable(vitals)
        }

        Vitals.players[playerId] = record
        Vitals.byLicense[license] = playerId

        -- Atualizar cache síncrono
        Open77.exports.call("ls_data", "cacheSet", "vitals", license, vitals)

        -- Replicar no State Bag do jogador (rede)
        Open77.state.player(playerId):set("ls.vitals.v", vitals)

        -- DUAL-SYNC: Disparar NetEvent direto garantido para o cliente
        TriggerClientEvent("ls:vitals:sync", playerId, vitals)

        Open77.log.info(("[ls_vitals] Vitais do Jogador %d (%s) inicializados com sucesso."):format(playerId, license))
    end)
end

---Garante que os vitais de um jogador conectado estejam inicializados mesmo sem evento prévio
---@param playerId integer
---@return table|nil
local function ensurePlayerVitals(playerId)
    if not LS.isPlayerId(playerId) then return nil end
    local p = Vitals.players[playerId]
    if p then return p end

    -- Tentar obter licença oficial do ls_core
    local license
    local licCall = Open77.exports.call("ls_core", "getPlayerLicense", playerId)
    if licCall then
        license = licCall:await()
    end

    -- Fallback determinístico caso o ls_core ainda esteja processando
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

    onPlayerLoaded(playerId, license)
    return Vitals.players[playerId]
end

AddEventHandler("ls:core:playerLoaded", function(playerId, license)
    onPlayerLoaded(playerId, license)
end)

AddEventHandler("ls:core:playerUnloading", function(playerId, license, reason)
    local p = Vitals.players[playerId]
    if not p then return end

    p.vitals.lastUpdateUnix = Open77.time.unix()
    Open77.exports.call("ls_data", "cacheSet", "vitals", license, p.vitals)

    Vitals.players[playerId] = nil
    Vitals.byLicense[license] = nil
end)

-- Sincronização manual sob demanda (chamada pelo comando /vitals ou boot do cliente)
RegisterNetEvent("ls:vitals:requestSync", function()
    local src = source
    if not LS.isPlayerId(src) then return end

    local p = Vitals.players[src] or ensurePlayerVitals(src)
    if p and p.vitals then
        TriggerClientEvent("ls:vitals:sync", src, p.vitals)
        Open77.state.player(src):set("ls.vitals.v", p.vitals)
    end
end)

-- Rastreio de esforço motor enviado pelo cliente
RegisterNetEvent("ls:vitals:setActivity", function(act, mult)
    local src = source
    if not LS.isPlayerId(src) then return end

    local p = Vitals.players[src] or ensurePlayerVitals(src)
    if not p then return end

    p.clientActivity = tostring(act or "idle")
    p.activityMult = math.max(0.2, math.min(5.0, tonumber(mult) or 1.0))
end)

-- =============================================================================
-- MOTOR DE DECAIMENTO MONOTÔNICO DINÂMICO (TICK)
-- =============================================================================

CreateThread(function()
    while true do
        Wait(VitalsConfig.TickIntervalMs)

        if Vitals.ready then
            local tNow = nowMs()

            -- 0. Descoberta contínua e auto-cura de jogadores conectados
            if Open77.players and Open77.players.all then
                local all = Open77.players.all()
                if type(all) == "table" then
                    for _, pid in ipairs(all) do
                        local numId = tonumber(pid)
                        if numId and not Vitals.players[numId] then
                            ensurePlayerVitals(numId)
                        end
                    end
                end
            end

            for playerId, p in pairs(Vitals.players) do
                local dtSec = math.max(0.1, (tNow - p.lastTickMs) / 1000.0)
                p.lastTickMs = tNow

                -- 1. Determinação de velocidade física do mundo (Server Fallback)
                local currentPos = Open77.players.position and Open77.players.position(playerId)
                if currentPos and p.lastPos then
                    local dx = (currentPos.x or 0) - (p.lastPos.x or 0)
                    local dy = (currentPos.y or 0) - (p.lastPos.y or 0)
                    local dz = (currentPos.z or 0) - (p.lastPos.z or 0)
                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                    p.speed = dist / dtSec
                end
                p.lastPos = currentPos

                -- 2. Cálculo do Multiplicador Efetivo de Esforço
                local inVehicle = false
                if p.clientActivity == "driving" then
                    inVehicle = true
                elseif Open77.vehicles and Open77.vehicles.getPlayerSeat and Open77.vehicles.getPlayerSeat(playerId) ~= nil then
                    inVehicle = true
                end

                local effectiveAct = p.clientActivity or "idle"
                local baseMult = p.activityMult or 1.0

                -- Se estiver em veículo, fixa atividade 'driving' e bloqueia detecção de sprint por velocidade
                if inVehicle then
                    effectiveAct = "driving"
                    baseMult = VitalsConfig.Multipliers.Driving or 0.85
                elseif effectiveAct == "idle" and p.speed > 1.2 then
                    if p.speed > 7.0 then
                        effectiveAct = "sprinting"
                        baseMult = VitalsConfig.Multipliers.Sprinting or 3.2
                    elseif p.speed > 3.5 then
                        effectiveAct = "running"
                        baseMult = VitalsConfig.Multipliers.Running or 2.0
                    else
                        effectiveAct = "walking"
                        baseMult = VitalsConfig.Multipliers.Walking or 1.3
                    end
                end

                local globalMult = VitalsConfig.GlobalRateMultiplier or 1.0
                local totalMult = baseMult * globalMult

                local v = p.vitals
                local hungerDelta  = (VitalsConfig.Decay.HungerPerMin  / 60.0) * dtSec * totalMult
                local thirstDelta  = (VitalsConfig.Decay.ThirstPerMin  / 60.0) * dtSec * (totalMult * 1.15)
                local energyDelta  = (VitalsConfig.Decay.EnergyPerMin  / 60.0) * dtSec * totalMult
                local hygieneDelta = (VitalsConfig.Decay.HygienePerMin / 60.0) * dtSec * (totalMult >= 2.0 and 1.6 or 1.0)
                
                -- Stress sobe em combate/sprint contínuo ou diminui em repouso
                local stressDelta = 0.0
                if effectiveAct == "combat" or effectiveAct == "sprinting" then
                    stressDelta = 0.15 * dtSec * globalMult
                else
                    stressDelta = - (VitalsConfig.Decay.StressRecoveryPerMin / 60.0) * dtSec
                end

                -- Aplicação dos deltas
                v.hunger  = LS.clamp(v.hunger  - hungerDelta,  0.0, 100.0)
                v.thirst  = LS.clamp(v.thirst  - thirstDelta,  0.0, 100.0)
                v.energy  = LS.clamp(v.energy  - energyDelta,  0.0, 100.0)
                v.hygiene = LS.clamp(v.hygiene - hygieneDelta, 0.0, 100.0)
                v.stress  = LS.clamp(v.stress  + stressDelta,  0.0, 100.0)

                -- 3. Penalidades Biológicas Críticas (Desidratação Severa e Inanição a 0%)
                local damageToApply = 0.0
                local damageReasons = {}

                if v.thirst <= 0.0 then
                    local thirstCfg = (VitalsConfig.Starvation and VitalsConfig.Starvation.ThirstDamagePerTick) or 3.5
                    local thirstDmg = thirstCfg * (dtSec / 3.0)
                    damageToApply = damageToApply + thirstDmg
                    table.insert(damageReasons, "dehydration")
                end

                if v.hunger <= 0.0 then
                    local hungerCfg = (VitalsConfig.Starvation and VitalsConfig.Starvation.HungerDamagePerTick) or 1.5
                    local hungerDmg = hungerCfg * (dtSec / 3.0)
                    damageToApply = damageToApply + hungerDmg
                    table.insert(damageReasons, "starvation")
                end

                if damageToApply > 0.0 then
                    pcall(function()
                        local hObj = Open77.players and Open77.players.getHealth and Open77.players.getHealth(playerId)
                        local currentHp = hObj and tonumber(hObj.health) or 100.0
                        local newHp = math.max(0.0, currentHp - damageToApply)

                        if Open77.players and Open77.players.setHealth then
                            Open77.players.setHealth(playerId, newHp)
                        end

                        TriggerClientEvent("ls:vitals:damageAlert", playerId, {
                            reasons = damageReasons,
                            damage = damageToApply,
                            health = newHp
                        })

                        if VitalsConfig.DebugLogs then
                            Open77.log.warn(("[ls_vitals:Damage] Jogador #%d sofreu -%.1f HP (%s) | HP Restante: %.1f"):format(
                                playerId, damageToApply, table.concat(damageReasons, "+"), newHp
                            ))
                        end
                    end)
                end

                v.activity = effectiveAct
                v.activityMult = totalMult
                v.rateMult = globalMult

                -- 3. Verificação de histerese para replicação em rede
                local forceReplicate = (tNow - p.lastReplicatedMs) >= VitalsConfig.ForceReplicateIntervalMs
                if forceReplicate or hasCrossedHysteresis(v, p.lastReplicatedVitals) then
                    p.lastReplicatedMs = tNow
                    p.lastReplicatedVitals = cloneTable(v)
                    v.lastUpdateUnix = Open77.time.unix()

                    -- Grava no cache write-behind
                    Open77.exports.call("ls_data", "cacheSet", "vitals", p.license, v)

                    -- DUAL-SYNC: Notifica clientes via State Bag E NetEvent Direto
                    Open77.state.player(playerId):set("ls.vitals.v", v)
                    TriggerClientEvent("ls:vitals:sync", playerId, v)

                    -- LOG EM TEMPO REAL NO CONSOLE DO SERVIDOR
                    if VitalsConfig.DebugLogs then
                        Open77.log.info(("[ls_vitals:Tick] Jogador #%d | Fome: %.2f%% (-%.2f) | Sede: %.2f%% (-%.2f) | Stamina: %.2f%% (-%.2f) | Atividade: %s (x%.2f)"):format(
                            playerId,
                            v.hunger, hungerDelta,
                            v.thirst, thirstDelta,
                            v.energy, energyDelta,
                            effectiveAct:upper(), totalMult
                        ))
                    end

                    -- Checagem de limiares críticos
                    if v.hunger <= VitalsConfig.Thresholds.CriticalHunger then
                        TriggerEvent("ls:vitals:critical", playerId, "hunger", v.hunger)
                    end
                    if v.thirst <= VitalsConfig.Thresholds.CriticalThirst then
                        TriggerEvent("ls:vitals:critical", playerId, "thirst", v.thirst)
                    end
                    if v.energy <= VitalsConfig.Thresholds.CriticalEnergy then
                        TriggerEvent("ls:vitals:critical", playerId, "energy", v.energy)
                    end
                end
            end
        end
    end
end)

-- =============================================================================
-- CONSUMÍVEIS E MODIFICADORES
-- =============================================================================

---Modifica os vitais de um jogador aplicando deltas seguros
---@param playerId integer
---@param deltas table { hunger?, thirst?, energy?, hygiene?, stress? }
---@return boolean, table|string
local function modifyPlayerVitals(playerId, deltas)
    local p = Vitals.players[playerId]
    if not p then return false, "player_not_active" end
    if type(deltas) ~= "table" then return false, "invalid_deltas" end

    local v = p.vitals
    if deltas.hunger  then v.hunger  = LS.clamp(v.hunger  + tonumber(deltas.hunger),  0.0, 100.0) end
    if deltas.thirst  then v.thirst  = LS.clamp(v.thirst  + tonumber(deltas.thirst),  0.0, 100.0) end
    if deltas.energy  then v.energy  = LS.clamp(v.energy  + tonumber(deltas.energy),  0.0, 100.0) end
    if deltas.hygiene then v.hygiene = LS.clamp(v.hygiene + tonumber(deltas.hygiene), 0.0, 100.0) end
    if deltas.stress  then v.stress  = LS.clamp(v.stress  + tonumber(deltas.stress),  0.0, 100.0) end

    v.lastUpdateUnix = Open77.time.unix()
    p.lastReplicatedVitals = cloneTable(v)
    p.lastReplicatedMs = nowMs()

    Open77.exports.call("ls_data", "cacheSet", "vitals", p.license, v)
    Open77.state.player(playerId):set("ls.vitals.v", v)
    TriggerClientEvent("ls:vitals:sync", playerId, v)

    TriggerEvent("ls:vitals:updated", playerId, v)
    return true, v
end

---Aplica o consumo de um item catalogado aos vitais do jogador
---@param playerId integer
---@param itemKey string
---@return boolean, string|table
local function consumeItem(playerId, itemKey)
    local item = VitalsConfig.Consumables[itemKey]
    if not item then return false, "unknown_item" end

    local ok, res = modifyPlayerVitals(playerId, item)
    if ok then
        Open77.log.info(("[ls_vitals:Consume] Jogador %d consumiu '%s' (%s) -> Fome: %.1f%% | Sede: %.1f%% | Stamina: %.1f%%"):format(
            playerId, item.label, itemKey, res.hunger, res.thirst, res.energy
        ))
    end
    return ok, res
end

RegisterNetEvent("ls:vitals:consume", function(itemKey)
    local src = source
    if not LS.isPlayerId(src) or type(itemKey) ~= "string" then return end
    consumeItem(src, itemKey)
end)

---Compra um item consumível debitando de sua conta/carteira no ls_economy
---@param playerId integer
---@param itemKey string
---@param preferredPayment? string "cash"|"bank"
---@return boolean, string
local function buyItem(playerId, itemKey, preferredPayment)
    if not LS.isPlayerId(playerId) or type(itemKey) ~= "string" then
        return false, "invalid_player"
    end
    itemKey = itemKey:lower()
    local item = VitalsConfig.Consumables[itemKey]
    if not item then
        TriggerClientEvent("ls:ui:vendingFeedback", playerId, { success = false, message = "Item indisponível no dispensador." })
        return false, "item_not_found"
    end

    local price = math.max(0, math.floor(tonumber(item.price) or 15))
    local paid = false
    local paymentType = "dinheiro vivo"
    preferredPayment = preferredPayment and tostring(preferredPayment):lower() or "cash"

    if preferredPayment == "bank" then
        -- Preferência por débito bancário
        local okBankCall, debitBankRes = pcall(function()
            local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "bank", price, "Débito Automático: " .. item.label)
            if remCall and remCall.await then return remCall:await() end
            return remCall
        end)
        if okBankCall and debitBankRes == true then
            paid = true
            paymentType = "Night City Bank"
        end
    else
        -- Preferência por dinheiro em mãos
        local okCall, debitRes = pcall(function()
            local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "cash", price, "Compra: " .. item.label)
            if remCall and remCall.await then return remCall:await() end
            return remCall
        end)
        if okCall and debitRes == true then
            paid = true
            paymentType = "dinheiro vivo"
        else
            -- Contingência: tenta banco
            local okBankCall, debitBankRes = pcall(function()
                local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "bank", price, "Débito Automático: " .. item.label)
                if remCall and remCall.await then return remCall:await() end
                return remCall
            end)
            if okBankCall and debitBankRes == true then
                paid = true
                paymentType = "Night City Bank"
            end
        end
    end

    if not paid then
        local failMsg = ("Saldo insuficiente! '%s' custa E$ %d."):format(item.label, price)
        TriggerClientEvent("ls:ui:vendingFeedback", playerId, { success = false, message = failMsg })
        TriggerClientEvent("open77:chat:addMessage", playerId, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "MÁQUINA DE VENDAS", failMsg }
        })
        return false, "insufficient_funds"
    end

    -- Consome o item e aplica os vitais
    consumeItem(playerId, itemKey)

    local successMsg = ("'%s' dispensado por E$ %d via %s."):format(item.label, price, paymentType)
    TriggerClientEvent("ls:ui:vendingFeedback", playerId, { success = true, message = successMsg })
    TriggerClientEvent("open77:chat:addMessage", playerId, {
        color = { 34, 216, 226 },
        multiline = false,
        args = { "MÁQUINA DE VENDAS", successMsg }
    })

    return true, "success"
end

RegisterNetEvent("ls:vitals:buy", function(itemKey, paymentType)
    local src = source
    if not LS.isPlayerId(src) or type(itemKey) ~= "string" then return end
    buyItem(src, itemKey, paymentType)
end)


local function handleBuyCommand(source, args)
    local itemKey = args[1]
    if not itemKey then
        local helpMsg = "Uso correto: /comprar <itemKey> (ex: /comprar burrito_xxl, /comprar sprunki, /comprar synth_ramen)"
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "CONVENIÊNCIA 24/7", helpMsg }
        })
        TriggerClientEvent("chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "CONVENIÊNCIA 24/7", helpMsg }
        })
        return
    end

    buyItem(source, tostring(itemKey))
end

RegisterCommand("comprar", handleBuyCommand, false)
RegisterCommand("buy", handleBuyCommand, false)


-- =============================================================================
-- COMANDOS ADMINISTRATIVOS & DE TELEMETRIA (/vitals & /ls_vitals)
-- =============================================================================

local function connectedPlayers()
    if type(Open77) == "table" and type(Open77.players) == "table" and type(Open77.players.all) == "function" then
        local ok, ids = pcall(Open77.players.all)
        if ok and type(ids) == "table" then return ids end
    end
    if type(GetPlayers) == "function" then
        local ok, ids = pcall(GetPlayers)
        if ok and type(ids) == "table" then return ids end
    end
    return {}
end

local function getPlayerNameSafely(playerId)
    if type(Open77) == "table" and type(Open77.players) == "table" and type(Open77.players.name) == "function" then
        local ok, name = pcall(Open77.players.name, playerId)
        if ok and name and name ~= "" then return name end
    end
    if type(GetPlayerName) == "function" then
        local ok, name = pcall(GetPlayerName, playerId)
        if ok and name and name ~= "" then return name end
    end
    local p = Vitals and Vitals.players and Vitals.players[playerId]
    if p and p.license then return p.license end
    return ("Jogador %d"):format(playerId)
end

local function isAuthorizedAdmin(src)
    -- Console do servidor tem autoridade máxima
    if not LS.isPlayerId(src) or src == 0 then
        return true
    end

    -- Se o sistema Open77.acl estiver ativo
    if Open77 and Open77.acl and type(Open77.acl.isAllowed) == "function" then
        local ok, allowed = pcall(Open77.acl.isAllowed, src, "command.vitals")
        if ok and allowed == true then return true end

        ok, allowed = pcall(Open77.acl.isAllowed, src, "command.admin")
        if ok and allowed == true then return true end

        if type(Open77.acl.roles) == "function" then
            local okRoles, roles = pcall(Open77.acl.roles, src)
            if okRoles and type(roles) == "table" then
                for _, r in ipairs(roles) do
                    local roleName = tostring(r):lower()
                    if roleName == "operator" or roleName == "admin" or roleName == "moderator" or roleName == "owner" then
                        return true
                    end
                end
            end
        end

        return false
    end

    -- Modo de desenvolvimento / fallback seguro
    return true
end

local function sendAdminReply(caller, isSuccess, title, message)
    local tag = title or "KIROSHI ADMIN"
    local color = isSuccess and { 34, 216, 226 } or { 255, 60, 60 }
    Open77.log.info(("[%s] %s"):format(tag, message))
    if LS.isPlayerId(caller) and caller > 0 then
        TriggerClientEvent("chat:addMessage", caller, {
            color = color,
            multiline = false,
            args = { tag, message }
        })
    end
end

local function resolvePlayerTarget(caller, targetArg)
    -- Se argumento vazio ou 'me' / 'self', é o próprio caller
    if not targetArg or targetArg == "" or targetArg:lower() == "me" or targetArg:lower() == "self" then
        if LS.isPlayerId(caller) then
            return caller, getPlayerNameSafely(caller)
        end
        return nil, "Console do servidor deve especificar o ID, nome do jogador ou 'all'."
    end

    -- Se for 'all' / 'todos'
    local lowerArg = targetArg:lower()
    if lowerArg == "all" or lowerArg == "todos" then
        return "all", "TODOS"
    end

    -- Remove aspas se fornecidas, ex: "jogador" -> jogador
    local cleanArg = targetArg:gsub('^["\']', ''):gsub('["\']$', ''):match("^%s*(.-)%s*$")
    if not cleanArg or cleanArg == "" then
        if LS.isPlayerId(caller) then
            return caller, getPlayerNameSafely(caller)
        end
        return nil, "Console deve especificar o jogador."
    end

    local cleanLower = cleanArg:lower()

    -- Verifica se é ID numérico direto
    local numId = tonumber(cleanArg)
    if numId and numId > 0 and numId % 1 == 0 then
        local name = getPlayerNameSafely(numId)
        local isConnected = false
        for _, pid in ipairs(connectedPlayers()) do
            if tonumber(pid) == numId then
                isConnected = true
                break
            end
        end
        if isConnected or (Vitals.players and Vitals.players[numId]) then
            return numId, name
        else
            return nil, ("Jogador com ID %d não está online no servidor."):format(numId)
        end
    end

    -- Busca por correspondência de nome nos jogadores online
    local exactMatches = {}
    local partialMatches = {}

    local activeIds = connectedPlayers()
    local checkIds = {}
    local seen = {}
    for _, pid in ipairs(activeIds) do
        local n = tonumber(pid)
        if n and not seen[n] then
            table.insert(checkIds, n)
            seen[n] = true
        end
    end
    if Vitals and Vitals.players then
        for pid, _ in pairs(Vitals.players) do
            if not seen[pid] then
                table.insert(checkIds, pid)
                seen[pid] = true
            end
        end
    end

    for _, pid in ipairs(checkIds) do
        local pName = getPlayerNameSafely(pid)
        if pName then
            local pLower = pName:lower()
            if pLower == cleanLower then
                table.insert(exactMatches, { id = pid, name = pName })
            elseif pLower:find(cleanLower, 1, true) then
                table.insert(partialMatches, { id = pid, name = pName })
            end
        end
    end

    if #exactMatches == 1 then
        return exactMatches[1].id, exactMatches[1].name
    elseif #exactMatches > 1 then
        return nil, ("Múltiplos jogadores com o nome exato '%s'. Especifique o ID numérico."):format(cleanArg)
    end

    if #partialMatches == 1 then
        return partialMatches[1].id, partialMatches[1].name
    elseif #partialMatches > 1 then
        local namesList = {}
        for _, m in ipairs(partialMatches) do
            table.insert(namesList, ("%s (ID %d)"):format(m.name, m.id))
        end
        return nil, ("Múltiplos jogadores encontrados para '%s': %s. Especifique o ID."):format(cleanArg, table.concat(namesList, ", "))
    end

    return nil, ("Nenhum jogador online encontrado com o nome '%s'."):format(cleanArg)
end

local function restorePlayerFull(playerId)
    -- 1. Vitais no nível ótimo (100% vital, 0% stress neural)
    exports["ls_vitals"]:setVitals(playerId, {
        hunger = 100.0,
        thirst = 100.0,
        energy = 100.0,
        hygiene = 100.0,
        stress = 0.0
    })

    -- 2. Restauração integral de integridade física (Health / HP)
    if Open77 and Open77.players and type(Open77.players.setHealth) == "function" then
        local maxHp = 100.0
        if type(Open77.players.getHealth) == "function" then
            local ok, h = pcall(Open77.players.getHealth, playerId)
            if ok and h and tonumber(h.maxHealth) and h.maxHealth > 0 then
                maxHp = tonumber(h.maxHealth)
            end
        end
        pcall(Open77.players.setHealth, playerId, maxHp)
    end
end

local function drainPlayerVitals(playerId)
    -- Esvazia fome, sede e energia para testes imediatos de sobrevivência
    exports["ls_vitals"]:setVitals(playerId, {
        hunger = 0.0,
        thirst = 0.0,
        energy = 0.0,
        hygiene = 20.0,
        stress = 80.0
    })
end

local function handleVitalsCommand(src, args)
    local isIngame = LS.isPlayerId(src)
    if type(args) ~= "table" then args = { tostring(args or "") } end
    local sub = args[1] and tostring(args[1]):lower() or ""

    -- Visualização de Telemetria / Status se nenhum argumento for fornecido
    if sub == "" or sub == "status" or sub == "info" then
        local targetId = isIngame and src or 1
        local p = Vitals.players[targetId] or ensurePlayerVitals(targetId)
        if p then
            local v = p.vitals
            local chatMsg = ("[BIOMONITOR] Fome: %.1f%% | Sede: %.1f%% | Stamina: %.1f%% | Higiene: %.1f%% | Stress: %.1f%% | Atividade: %s (x%.2f)"):format(
                v.hunger, v.thirst, v.energy, v.hygiene, v.stress, (v.activity or "idle"):upper(), v.activityMult or 1.0
            )
            Open77.log.info(("[ls_vitals] === STATUS BIOMONITOR (JOGADOR %d | %s) ==="):format(targetId, p.license))
            Open77.log.info(("  * Fome:       %.2f%%"):format(v.hunger))
            Open77.log.info(("  * Sede:       %.2f%%"):format(v.thirst))
            Open77.log.info(("  * Stamina:    %.2f%%"):format(v.energy))
            Open77.log.info(("  * Sanitário:  %.2f%%"):format(v.hygiene))
            Open77.log.info(("  * Carga Neu:  %.2f%%"):format(v.stress))
            Open77.log.info(("  * Atividade:  %s (Multiplicador: x%.2f)"):format((v.activity or "idle"):upper(), v.activityMult or 1.0))
            Open77.log.info(("  * Taxa Glob:  %.2fx"):format(VitalsConfig.GlobalRateMultiplier))

            if isIngame then
                TriggerClientEvent("chat:addMessage", src, {
                    color = { 34, 216, 226 },
                    multiline = false,
                    args = { "KIROSHI", chatMsg }
                })
                TriggerClientEvent("ls:vitals:sync", src, v)
            end
        else
            Open77.log.warn(("[ls_vitals] Nenhum jogador com ID %d ativo na sessão."):format(targetId))
        end
        return
    end

    -- Ajuda / Guia de comandos
    if sub == "help" or sub == "?" then
        local helpLines = {
            "--- COMANDOS BIOMONITOR & ADMIN VITALS ---",
            "/vitals fill [id|nome|\"jogador\"|all] - Restaura vitais para 100% e regenera HP",
            "/vitals drain [id|nome|all] - Zera fome/sede/energia para testar penalidades",
            "/vitals set [id|nome] <fome> <sede> <stamina> <higiene> <stress> - Ajusta vitais",
            "/vitals rate <multiplicador> - Altera a taxa de decaimento global (ex: 2.0)",
            "/vitals log [on|off] - Ativa/desativa telemetria em tempo real no console",
            "/vitals items - Lista os consumíveis biológicos cadastrados",
            "/vitals consume <itemKey> - Consome um item específico do catálogo"
        }
        for _, line in ipairs(helpLines) do
            Open77.log.info(line)
            if isIngame then
                TriggerClientEvent("chat:addMessage", src, {
                    color = { 34, 216, 226 },
                    multiline = false,
                    args = { "KIROSHI", line }
                })
            end
        end
        return
    end

    -- 1. PREENCHIMENTO COMPLETO: /vitals fill [jogador]
    if sub == "fill" or sub == "heal" or sub == "max" then
        if not isAuthorizedAdmin(src) then
            return sendAdminReply(src, false, "SEGURANÇA", "Acesso negado: permissão administrativa insuficiente.")
        end

        local targetToken = ""
        if #args >= 2 then
            local parts = {}
            for i = 2, #args do
                table.insert(parts, tostring(args[i]))
            end
            targetToken = table.concat(parts, " ")
        end

        local target, targetName = resolvePlayerTarget(src, targetToken)
        if not target then
            return sendAdminReply(src, false, "KIROSHI ADMIN", targetName)
        end

        if target == "all" then
            local cList = connectedPlayers()
            local filledCount = 0
            local seenIds = {}
            for _, pid in ipairs(cList) do
                local n = tonumber(pid)
                if n and not seenIds[n] then
                    restorePlayerFull(n)
                    filledCount = filledCount + 1
                    seenIds[n] = true
                end
            end
            for pid, _ in pairs(Vitals.players) do
                if not seenIds[pid] then
                    restorePlayerFull(pid)
                    filledCount = filledCount + 1
                    seenIds[pid] = true
                end
            end
            sendAdminReply(src, true, "KIROSHI ADMIN", ("Vitais e saúde restaurados para 100%% em %d jogador(es) online."):format(filledCount))
            TriggerClientEvent("chat:addMessage", -1, {
                color = { 34, 216, 226 },
                multiline = false,
                args = { "BIOMONITOR", "Todos os índices biológicos da cidade foram calibrados em 100% pelo Administrador." }
            })
            return
        end

        restorePlayerFull(target)
        sendAdminReply(src, true, "KIROSHI ADMIN", ("Vitais e saúde do jogador '%s' (ID %d) foram preenchidos para 100%% com sucesso!"):format(targetName, target))

        if target ~= src and LS.isPlayerId(target) then
            TriggerClientEvent("chat:addMessage", target, {
                color = { 34, 216, 226 },
                multiline = false,
                args = { "BIOMONITOR", "Seus índices vitais e integridade biológica foram totalmente restaurados por um Administrador." }
            })
        end
        return
    end

    -- 2. DRAIN / ESVAZIAR: /vitals drain [jogador]
    if sub == "drain" or sub == "empty" then
        if not isAuthorizedAdmin(src) then
            return sendAdminReply(src, false, "SEGURANÇA", "Acesso negado: permissão administrativa insuficiente.")
        end

        local targetToken = ""
        if #args >= 2 then
            local parts = {}
            for i = 2, #args do
                table.insert(parts, tostring(args[i]))
            end
            targetToken = table.concat(parts, " ")
        end

        local target, targetName = resolvePlayerTarget(src, targetToken)
        if not target then
            return sendAdminReply(src, false, "KIROSHI ADMIN", targetName)
        end

        if target == "all" then
            local cList = connectedPlayers()
            local drainedCount = 0
            local seenIds = {}
            for _, pid in ipairs(cList) do
                local n = tonumber(pid)
                if n and not seenIds[n] then
                    drainPlayerVitals(n)
                    drainedCount = drainedCount + 1
                    seenIds[n] = true
                end
            end
            for pid, _ in pairs(Vitals.players) do
                if not seenIds[pid] then
                    drainPlayerVitals(pid)
                    drainedCount = drainedCount + 1
                    seenIds[pid] = true
                end
            end
            sendAdminReply(src, true, "KIROSHI ADMIN", ("Vitais esvaziados (drain) em %d jogador(es) online."):format(drainedCount))
            return
        end

        drainPlayerVitals(target)
        sendAdminReply(src, true, "KIROSHI ADMIN", ("Vitais do jogador '%s' (ID %d) foram esvaziados para 0%% (drain)."):format(targetName, target))
        return
    end

    -- 3. AJUSTE PERSONALIZADO: /vitals set [jogador] <fome> <sede> <stamina> <higiene> <stress>
    if sub == "set" then
        if not isAuthorizedAdmin(src) then
            return sendAdminReply(src, false, "SEGURANÇA", "Acesso negado: permissão administrativa insuficiente.")
        end

        local targetToken = ""
        local h, t, e, hy, s = 100.0, 100.0, 100.0, 100.0, 0.0

        if #args >= 7 then
            targetToken = tostring(args[2])
            h  = tonumber(args[3]) or 100.0
            t  = tonumber(args[4]) or 100.0
            e  = tonumber(args[5]) or 100.0
            hy = tonumber(args[6]) or 100.0
            s  = tonumber(args[7]) or 0.0
        elseif #args >= 2 then
            local firstNum = tonumber(args[2])
            if firstNum == nil then
                targetToken = tostring(args[2])
                h  = tonumber(args[3]) or 100.0
                t  = tonumber(args[4]) or 100.0
                e  = tonumber(args[5]) or 100.0
                hy = tonumber(args[6]) or 100.0
                s  = tonumber(args[7]) or 0.0
            else
                targetToken = ""
                h  = tonumber(args[2]) or 100.0
                t  = tonumber(args[3]) or 100.0
                e  = tonumber(args[4]) or 100.0
                hy = tonumber(args[5]) or 100.0
                s  = tonumber(args[6]) or 0.0
            end
        end

        local target, targetName = resolvePlayerTarget(src, targetToken)
        if not target or target == "all" then
            return sendAdminReply(src, false, "KIROSHI ADMIN", target == "all" and "O comando 'set' requer um jogador específico, não 'all'." or targetName)
        end

        local ok = exports["ls_vitals"]:setVitals(target, {
            hunger = h, thirst = t, energy = e, hygiene = hy, stress = s
        })
        sendAdminReply(src, ok, "KIROSHI ADMIN", ("Vitais de '%s' (ID %d) forçados para: Fome=%.0f, Sede=%.0f, Stamina=%.0f, Higiene=%.0f, Stress=%.0f"):format(
            targetName, target, h, t, e, hy, s
        ))
        return
    end

    -- 4. ALTERAR TAXA GLOBAL: /vitals rate <multiplicador>
    if sub == "rate" and args[2] then
        if not isAuthorizedAdmin(src) then
            return sendAdminReply(src, false, "SEGURANÇA", "Acesso negado: permissão administrativa insuficiente.")
        end
        local r = tonumber(args[2])
        if r and r > 0 then
            VitalsConfig.GlobalRateMultiplier = r
            sendAdminReply(src, true, "KIROSHI ADMIN", ("Multiplicador global de decaimento alterado para: %.2fx"):format(r))
        else
            sendAdminReply(src, false, "KIROSHI ADMIN", "Uso correto: /vitals rate <número> (ex: /vitals rate 1.5)")
        end
        return
    end

    -- 5. TOGGLE LOGS: /vitals log [on|off]
    if sub == "log" then
        if not isAuthorizedAdmin(src) then
            return sendAdminReply(src, false, "SEGURANÇA", "Acesso negado: permissão administrativa insuficiente.")
        end
        if args[2] == "off" then
            VitalsConfig.DebugLogs = false
        else
            VitalsConfig.DebugLogs = true
        end
        sendAdminReply(src, true, "KIROSHI ADMIN", ("Logs de telemetria em tempo real: %s"):format(VitalsConfig.DebugLogs and "ATIVADOS" or "DESATIVADOS"))
        return
    end

    -- 6. CONSUMIR ITEM: /vitals consume <itemKey>
    if sub == "consume" and args[2] then
        local targetId = isIngame and src or 1
        local itemKey = tostring(args[2]):lower()
        local ok, res = consumeItem(targetId, itemKey)
        local msg = ok and ("[ls_vitals] Item '%s' consumido com sucesso pelo jogador %d!"):format(itemKey, targetId)
                        or ("[ls_vitals] Falha ao consumir '%s': %s"):format(itemKey, tostring(res))
        sendAdminReply(src, ok, "KIROSHI", msg)
        return
    end

    -- 7. CATÁLOGO DE ITENS: /vitals items
    if sub == "items" then
        Open77.log.info("[ls_vitals] --- CATÁLOGO DE CONSUMÍVEIS ---")
        for k, it in pairs(VitalsConfig.Consumables) do
            local line = ("  * '%s': %s (Fome: %+d, Sede: %+d, Stamina: %+d)"):format(k, it.label, it.hunger or 0, it.thirst or 0, it.energy or 0)
            Open77.log.info(line)
            if isIngame then
                TriggerClientEvent("chat:addMessage", src, { color = { 34, 216, 226 }, multiline = false, args = { "KIROSHI", line } })
            end
        end
        return
    end

    -- Subcomando não reconhecido
    sendAdminReply(src, false, "KIROSHI", ("Subcomando '/vitals %s' não reconhecido. Use '/vitals help' para instruções."):format(sub))
end

RegisterCommand("ls_vitals", handleVitalsCommand, false)
RegisterCommand("vitals", handleVitalsCommand, false)

RegisterNetEvent("ls:vitals:adminCommand", function(...)
    local src = source
    if not LS.isPlayerId(src) then return end
    local raw = { ... }
    local args = {}
    if type(raw[1]) == "table" then
        args = raw[1]
    else
        for i = 1, select("#", ...) do
            local v = select(i, ...)
            if v ~= nil then table.insert(args, tostring(v)) end
        end
    end
    handleVitalsCommand(src, args)
end)

-- =============================================================================
-- EXPORTS PÚBLICOS
-- =============================================================================

exports("getVitals", function(playerId)
    local p = Vitals.players[playerId]
    return p and cloneTable(p.vitals) or nil
end)

exports("setVitals", function(playerId, newVitals)
    local p = Vitals.players[playerId] or ensurePlayerVitals(playerId)
    if not p or type(newVitals) ~= "table" then return false end
    p.vitals.hunger = LS.clamp(newVitals.hunger or 100.0, 0.0, 100.0)
    p.vitals.thirst = LS.clamp(newVitals.thirst or 100.0, 0.0, 100.0)
    p.vitals.energy = LS.clamp(newVitals.energy or 100.0, 0.0, 100.0)
    p.vitals.hygiene = LS.clamp(newVitals.hygiene or 100.0, 0.0, 100.0)
    p.vitals.stress = LS.clamp(newVitals.stress or 0.0, 0.0, 100.0)
    p.vitals.lastUpdateUnix = Open77.time.unix()

    p.lastReplicatedVitals = cloneTable(p.vitals)
    p.lastReplicatedMs = nowMs()

    Open77.exports.call("ls_data", "cacheSet", "vitals", p.license, p.vitals)
    Open77.state.player(playerId):set("ls.vitals.v", p.vitals)
    TriggerClientEvent("ls:vitals:sync", playerId, p.vitals)
    return true
end)

exports("modifyVitals", function(playerId, deltas)
    return modifyPlayerVitals(playerId, deltas)
end)

exports("consumeItem", function(playerId, itemKey)
    return consumeItem(playerId, itemKey)
end)

exports("buyItem", function(playerId, itemKey)
    return buyItem(playerId, itemKey)
end)

