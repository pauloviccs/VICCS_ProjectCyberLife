--[[
    LIFESIM RP - Cyberware, Neural Stability & Psychosis Server Engine
    Path: ls_cyberware/server/main.lua
    Controla o inventário de implantes corporais, estabilidade neural,
    calor ocular, gatilhos de ciberpsicose e integração com neurobloqueadores.
]]

local Cyberware = {
    ready = false,
    players = {},    -- [playerId] = { license, data, lastPayload, lastHeartbeat }
    byLicense = {}   -- [license] = playerId
}

local function nowSec()
    return math.floor(GetGameTimer() / 1000)
end

local function nowMs()
    return GetGameTimer()
end

local function cloneTable(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = cloneTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- =============================================================================
-- INICIALIZAÇÃO & REGISTRO DE CONTRATOS
-- =============================================================================

CreateThread(function()
    -- 1. Aguardar prontidão dos subsistemas de dados e core
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registrar migração do módulo ls_cyberware
    local migrations = {
        {
            version = 1,
            checksum = "base_ls_cyberware_schema_v1",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_cyberware (
                    license      CHAR(32)  NOT NULL,
                    data         JSON      NOT NULL,
                    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (license),
                    CONSTRAINT fk_ls_cyberware_license FOREIGN KEY (license) REFERENCES ls_players(license) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }
    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_cyberware", migrations)
    if migCall then migCall:await() end

    -- 3. Registrar namespace declarativo no CacheService
    local cacheCall = Open77.exports.call("ls_data", "registerCacheNamespace", "cyberware", "ls_cyberware", "license", "data")
    if cacheCall then cacheCall:await() end

    -- 4. Registrar módulo no ls_core
    local regCall = Open77.exports.call("ls_core", "registerModule", {
        version = "0.1.0",
        requires = { "ls_data", "ls_core", "ls_vitals" },
        provides = {
            "getCyberware",
            "installImplant",
            "removeImplant",
            "usePharmaceutical",
            "getNeuralStability",
            "getOcularTemp"
        },
        emits = {
            "ls:cyberware:updated",
            "ls:cyberware:psychosisTriggered",
            "ls:cyberware:psychosisEnded",
            "ls:cyberware:heatAlert"
        },
        listens = { "ls:core:playerLoaded", "ls:core:playerUnloading" },
        stateKeys = {
            ["ls.cyberware.v"] = { maxBytes = 512 },
            ["ls.psychosis"]   = { maxBytes = 64 }
        },
        tables = { "ls_cyberware" }
    })
    if regCall then regCall:await() end

    Cyberware.ready = true
    Open77.log.info("[ls_cyberware] Motor de Ciberimplantes, Estabilidade Neural e Ciberpsicose inicializado.")
end)

-- =============================================================================
-- GERENCIAMENTO DE PERFIL & DADOS DE CIBERIMPLANTES
-- =============================================================================

---Gera um conjunto seguro de ciberware padrão para novos cidadãos
---@return table
local function createDefaultCyberwareData()
    local initialImplants = {}
    for _, implantId in ipairs(CyberwareConfig.DefaultImplants or {}) do
        local def = CyberwareConfig.Implants[implantId]
        if def then
            table.insert(initialImplants, {
                id = implantId,
                slot = def.slot,
                name = def.name,
                quality = def.quality,
                neuralCost = def.neuralCost,
                heatBonus = def.heatBonus,
                installedAt = nowSec(),
                durability = 100.0
            })
        end
    end

    return {
        implants = initialImplants,
        neuroblocker_expires = nowSec() + 1800, -- 30 minutos de tolerância cirúrgica inicial
        ocular_temp = CyberwareConfig.BaseOcularTemp,
        neural_stability = 95.0,
        is_psychotic = false,
        cryo_cooling_active = 0
    }
end

---Carrega ou inicializa o cyberware de um jogador recém-carregado no Core
---@param playerId integer
---@param license string
local function onPlayerLoaded(playerId, license)
    if not LS.isPlayerId(playerId) or not license then return end

    CreateThread(function()
        local getCall = Open77.exports.call("ls_data", "cacheLoad", "cyberware", license)
        local rawData = getCall and getCall:await()
        local cwData = nil

        if type(rawData) == "string" then
            local ok, parsed = pcall(json.decode, rawData)
            if ok and type(parsed) == "table" then cwData = parsed end
        elseif type(rawData) == "table" then
            cwData = rawData
        end

        if not cwData or not cwData.implants then
            cwData = createDefaultCyberwareData()
            Open77.exports.call("ls_data", "cacheSet", "cyberware", license, cwData)
            Open77.log.info(("[ls_cyberware] Ciberimplantes padrão instalados para novo cidadão [%s]."):format(license))
        end

        Cyberware.players[playerId] = {
            license = license,
            data = cwData,
            lastPayload = nil,
            lastHeartbeat = nowMs()
        }
        Cyberware.byLicense[license] = playerId

        -- Atualiza State Bags imediatos
        local currentSec = nowSec()
        local hasBlocker = (cwData.neuroblocker_expires or 0) > currentSec
        local payload = {
            stability = math.floor((cwData.neural_stability or 95.0) * 10) / 10,
            heat = math.floor((cwData.ocular_temp or 36.5) * 10) / 10,
            psychosis = cwData.is_psychotic == true,
            blockerActive = hasBlocker,
            blockerRemaining = math.max(0, (cwData.neuroblocker_expires or 0) - currentSec),
            implantsCount = #(cwData.implants or {})
        }

        Open77.state.player(playerId):set("ls.cyberware.v", payload)
        Open77.state.player(playerId):set("ls.psychosis", cwData.is_psychotic == true)
        Cyberware.players[playerId].lastPayload = cloneTable(payload)
        TriggerClientEvent("ls:cyberware:sync", playerId, payload)

        Open77.log.info(("[ls_cyberware] Perfil neural de [%d] carregado: Estabilidade=%.1f%%, Calor=%.1f°C, Implantes=%d"):format(
            playerId, payload.stability, payload.heat, payload.implantsCount))
    end)
end

---Descarrega e persiste o estado de ciberware do jogador
---@param playerId integer
---@param license string
local function onPlayerUnloading(playerId, license)
    local pState = Cyberware.players[playerId]
    if not pState then return end

    if pState.data and license then
        Open77.exports.call("ls_data", "cacheSet", "cyberware", license, pState.data)
    end

    Cyberware.players[playerId] = nil
    if license then Cyberware.byLicense[license] = nil end
    Open77.log.info(("[ls_cyberware] Estado neural de [%d] salvo e descarregado."):format(playerId))
end

-- Handlers de ciclo de vida do Core
RegisterNetEvent("ls:core:playerLoaded", function(playerId, license)
    onPlayerLoaded(playerId, license)
end)

RegisterNetEvent("ls:core:playerUnloading", function(playerId, license)
    onPlayerUnloading(playerId, license)
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    local pState = Cyberware.players[src]
    if pState then
        onPlayerUnloading(src, pState.license)
    end
end)

RegisterNetEvent("ls:cyberware:requestSync", function()
    local src = source
    if not LS.isPlayerId(src) then return end
    local pState = Cyberware.players[src]
    if pState and pState.lastPayload then
        TriggerClientEvent("ls:cyberware:sync", src, pState.lastPayload)
    end
end)

-- =============================================================================
-- MOTOR DINÂMICO DE TELEMETRIA NEURAL & CALOR OCULAR
-- =============================================================================

CreateThread(function()
    while true do
        Wait(CyberwareConfig.TickIntervalMs or 5000)

        if Cyberware.ready then
            local currentMs = nowMs()
            local currentSec = nowSec()

            for playerId, pState in pairs(Cyberware.players) do
                local data = pState.data
                if data then
                    -- 1. Obter nível de estresse / carga neural dos vitais
                    local stress = 0.0
                    local vitalsCall = Open77.exports.call("ls_vitals", "getVitals", playerId)
                    local vitalsState = vitalsCall and vitalsCall:await()
                    if type(vitalsState) == "table" and vitalsState.stress then
                        stress = tonumber(vitalsState.stress) or 0.0
                    end

                    -- 2. Verificar vigência do neurobloqueador
                    local hasBlocker = (data.neuroblocker_expires or 0) > currentSec
                    local implants = data.implants or {}
                    local implantCount = #implants

                    -- 3. Calcular somatório de custo neural e bônus de calor dos implantes instalados
                    local totalNeuralCost = 0.0
                    local totalHeatBonus = 0.0
                    for _, imp in ipairs(implants) do
                        totalNeuralCost = totalNeuralCost + (tonumber(imp.neuralCost) or CyberwareConfig.ImplantStrainMultiplier)
                        totalHeatBonus = totalHeatBonus + (tonumber(imp.heatBonus) or CyberwareConfig.ImplantHeatMultiplier)
                    end

                    -- 4. Equação de Estabilidade Neural:
                    -- Estabilidade = 100 - (Custo Neural) - (Sem Bloqueador ? 25 : 0) - (Stress * 0.25)
                    local unmedicatedFactor = hasBlocker and 0.0 or CyberwareConfig.UnmedicatedPenalty
                    local stressFactor = stress * CyberwareConfig.StressStrainMultiplier
                    local rawStability = CyberwareConfig.BaseStability - totalNeuralCost - unmedicatedFactor - stressFactor
                    local stability = LS.clamp(rawStability, CyberwareConfig.MinStability, CyberwareConfig.BaseStability)

                    -- 5. Equação de Calor Ocular:
                    -- Calor = 36.5 + (Bônus de Calor dos Implantes) + (Stress * 0.04)
                    local stressHeat = stress * CyberwareConfig.StressHeatMultiplier
                    local rawHeat = CyberwareConfig.BaseOcularTemp + totalHeatBonus + stressHeat

                    -- Resfriamento por spray criogênico ativo
                    if (data.cryo_cooling_active or 0) > 0 then
                        rawHeat = rawHeat - data.cryo_cooling_active
                        data.cryo_cooling_active = math.max(0, data.cryo_cooling_active - 0.5) -- dissipa lentamente
                    end

                    local heat = LS.clamp(rawHeat, CyberwareConfig.BaseOcularTemp, CyberwareConfig.MaxOcularTemp)

                    -- Atualiza objeto em memória
                    data.neural_stability = stability
                    data.ocular_temp = heat

                    -- 6. Gatilho de Ciberpsicose (< 25.0%)
                    local isPsychotic = stability < CyberwareConfig.PsychosisThreshold
                    if isPsychotic and not data.is_psychotic then
                        data.is_psychotic = true
                        Open77.state.player(playerId):set("ls.psychosis", true)
                        TriggerEvent("ls:cyberware:psychosisTriggered", playerId, stability, implantCount)
                        TriggerClientEvent("ls:cyberware:onPsychosisStart", playerId, stability)
                        Open77.log.warn(("[ls_cyberware] ALERTA CRÍTICO: Cidadão [%d] entrou em CIBERPSICOSE! Estabilidade=%.1f%%, Implantes=%d")
                            :format(playerId, stability, implantCount))
                    elseif not isPsychotic and data.is_psychotic then
                        data.is_psychotic = false
                        Open77.state.player(playerId):set("ls.psychosis", false)
                        TriggerEvent("ls:cyberware:psychosisEnded", playerId)
                        TriggerClientEvent("ls:cyberware:onPsychosisEnd", playerId)
                        Open77.log.info(("[ls_cyberware] Ciberpsicose contida para o cidadão [%d]. Estabilidade neural=%.1f%%")
                            :format(playerId, stability))
                    end

                    -- Alerta de Superaquecimento Ocular
                    if heat >= CyberwareConfig.WarningOcularTemp then
                        TriggerClientEvent("ls:cyberware:onHeatWarning", playerId, heat)
                    end

                    -- 7. Filtragem por Histerese de Rede (variação >= 0.5% ou batimento a cada 30s)
                    local last = pState.lastPayload
                    local timeSinceHeartbeat = currentMs - (pState.lastHeartbeat or 0)
                    local crossedHysteresis = false

                    if not last then
                        crossedHysteresis = true
                    elseif math.abs(stability - (last.stability or 0)) >= CyberwareConfig.HysteresisThreshold then
                        crossedHysteresis = true
                    elseif math.abs(heat - (last.heat or 0)) >= 0.20 then
                        crossedHysteresis = true
                    elseif hasBlocker ~= (last.blockerActive == true) then
                        crossedHysteresis = true
                    elseif timeSinceHeartbeat >= CyberwareConfig.ForceHeartbeatIntervalMs then
                        crossedHysteresis = true
                    end

                    if crossedHysteresis then
                        local payload = {
                            stability = math.floor(stability * 10) / 10,
                            heat = math.floor(heat * 10) / 10,
                            psychosis = data.is_psychotic,
                            blockerActive = hasBlocker,
                            blockerRemaining = math.max(0, (data.neuroblocker_expires or 0) - currentSec),
                            implantsCount = implantCount
                        }
                        Open77.state.player(playerId):set("ls.cyberware.v", payload)
                        pState.lastPayload = cloneTable(payload)
                        pState.lastHeartbeat = currentMs
                        TriggerClientEvent("ls:cyberware:sync", playerId, payload)
                    end

                    -- Persiste estado no cache de write-behind
                    Open77.exports.call("ls_data", "cacheSet", "cyberware", pState.license, data)
                end
            end
        end
    end
end)

-- =============================================================================
-- API & CONSUMO DE PRODUTOS FARMACÊUTICOS
-- =============================================================================

---Aplica o efeito de um medicamento ou dreno farmacêutico
---@param playerId integer
---@param pharmaId string
---@return boolean, string
local function applyPharmaceutical(playerId, pharmaId)
    local pState = Cyberware.players[playerId]
    if not pState or not pState.data then
        return false, "player_not_loaded"
    end

    local item = CyberwareConfig.Pharmaceuticals[pharmaId]
    if not item and pharmaId == "neuroblocker" then
        item = CyberwareConfig.Pharmaceuticals["neuroblocker_booster"]
    end
    if not item then
        return false, "invalid_pharmaceutical"
    end

    local data = pState.data
    local currentSec = nowSec()

    if pharmaId == "neuroblocker_booster" or pharmaId == "neuroblocker" then
        -- Concede 30 minutos de supressão neural
        data.neuroblocker_expires = currentSec + item.durationSeconds
        data.neural_stability = math.min(CyberwareConfig.BaseStability, (data.neural_stability or 50.0) + item.stabilityBoost)
        Open77.log.info(("[ls_cyberware] Cidadão [%d] aplicou Neurobloqueador. Válido por %ds."):format(playerId, item.durationSeconds))
    elseif pharmaId == "cryo_spray" then
        -- Resfriamento térmico imediato dos sensores oculares
        data.cryo_cooling_active = (data.cryo_cooling_active or 0) + item.heatReduction
        data.ocular_temp = math.max(CyberwareConfig.BaseOcularTemp, (data.ocular_temp or 36.5) - item.heatReduction)
        Open77.log.info(("[ls_cyberware] Cidadão [%d] aplicou Spray Criogênico. Calor Ocular arrefecido em -%.1f°C."):format(playerId, item.heatReduction))
    elseif pharmaId == "immuno_shot" then
        data.neural_stability = math.min(CyberwareConfig.BaseStability, (data.neural_stability or 50.0) + item.stabilityBoost)
        Open77.log.info(("[ls_cyberware] Cidadão [%d] aplicou Ampola Imunossupressora."):format(playerId))
    end

    -- Força sincronização imediata
    local hasBlocker = (data.neuroblocker_expires or 0) > currentSec
    local payload = {
        stability = math.floor((data.neural_stability or 95.0) * 10) / 10,
        heat = math.floor((data.ocular_temp or 36.5) * 10) / 10,
        psychosis = data.is_psychotic == true,
        blockerActive = hasBlocker,
        blockerRemaining = math.max(0, (data.neuroblocker_expires or 0) - currentSec),
        implantsCount = #(data.implants or {})
    }
    Open77.state.player(playerId):set("ls.cyberware.v", payload)
    Open77.state.player(playerId):set("ls.psychosis", data.is_psychotic == true)
    pState.lastPayload = cloneTable(payload)
    TriggerClientEvent("ls:cyberware:sync", playerId, payload)

    Open77.exports.call("ls_data", "cacheSet", "cyberware", pState.license, data)
    TriggerClientEvent("ls:cyberware:onPharmaUsed", playerId, pharmaId, item.name)

    return true, "success"
end

AddEventHandler("ls:cyberware:applyPharmaceutical", function(playerId, pharmaId)
    if not LS.isPlayerId(playerId) or type(pharmaId) ~= "string" then return end
    applyPharmaceutical(playerId, pharmaId)
end)

AddEventHandler("ls:cyberware:modifyStability", function(playerId, amount)
    if not LS.isPlayerId(playerId) then return end
    local pState = Cyberware.players[playerId]
    if not pState or not pState.data then return end
    pState.data.neural_stability = math.min(CyberwareConfig.BaseStability, math.max(0.0, (pState.data.neural_stability or 50.0) + tonumber(amount)))
end)

RegisterNetEvent("ls:cyberware:usePharmaceutical", function(pharmaId)
    local src = source
    local ok, reason = applyPharmaceutical(src, pharmaId)
    if not ok then
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 255, 80, 80 },
            multiline = false,
            args = { "FARMÁCIA", "Falha ao aplicar medicamento: " .. tostring(reason) }
        })
    end
end)

---Compra e aplica um produto farmacêutico via débito financeiro
---@param playerId integer
---@param pharmaId string
---@return boolean, string
local function buyPharmaceutical(playerId, pharmaId)
    if not LS.isPlayerId(playerId) or type(pharmaId) ~= "string" then
        return false, "invalid_player"
    end
    pharmaId = pharmaId:lower()
    local item = CyberwareConfig.Pharmaceuticals[pharmaId]
    if not item then
        return false, "invalid_pharmaceutical"
    end

    local price = math.max(0, math.floor(tonumber(item.price) or 200))
    local paid = false
    local paymentType = "dinheiro vivo"

    -- Tenta dinheiro em mãos
    local okCall, debitRes = pcall(function()
        local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "cash", price, "Farmácia: " .. item.name)
        if remCall and remCall.await then return remCall:await() end
        return remCall
    end)

    if okCall and debitRes == true then
        paid = true
        paymentType = "dinheiro vivo"
    else
        -- Tenta cartão do banco
        local okBankCall, debitBankRes = pcall(function()
            local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "bank", price, "Farmácia Débito: " .. item.name)
            if remCall and remCall.await then return remCall:await() end
            return remCall
        end)
        if okBankCall and debitBankRes == true then
            paid = true
            paymentType = "Night City Bank"
        end
    end

    if not paid then
        local failMsg = ("Saldo insuficiente! '%s' custa E$ %d."):format(item.name, price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", playerId, { success = false, message = failMsg })
        TriggerClientEvent("open77:chat:addMessage", playerId, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "FARMA-CORP NC", failMsg }
        })
        return false, "insufficient_funds"
    end

    -- 1. Tentar adicionar à mochila do jogador
    local addedToBag = false
    local okAdd, addRes = pcall(function()
        if exports["ls_inventory"] then
            if exports["ls_inventory"].AddItem then
                return exports["ls_inventory"]:AddItem(playerId, pharmaId, 1)
            elseif exports["ls_inventory"].addItem then
                return exports["ls_inventory"]:addItem(playerId, pharmaId, 1)
            end
        end
        return false
    end)

    if okAdd and addRes == true then
        local successMsg = ("'%s' adquirido por E$ %d via %s e guardado na sua mochila."):format(item.name, price, paymentType)
        TriggerClientEvent("ls:ui:ripperdocFeedback", playerId, { success = true, message = successMsg })
        TriggerClientEvent("ls:ui:notify", playerId, {
            type = "success",
            title = "FARMÁCIA RIPPERDOC",
            message = item.name .. " adicionado à sua mochila."
        })
        TriggerClientEvent("open77:chat:addMessage", playerId, {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "FARMA-CORP NC", successMsg }
        })
        return true, "success"
    else
        -- Reembolso obrigatório! NUNCA aplicar ou consumir o item automaticamente na compra
        pcall(function()
            if paymentType == "Night City Bank" then
                Open77.exports.call("ls_economy", "addMoney", playerId, "bank", price, "Reembolso Farmácia: Falha de inventário")
            else
                Open77.exports.call("ls_economy", "addMoney", playerId, "cash", price, "Reembolso Farmácia: Falha de inventário")
            end
        end)
        local errRev = ("Mochila cheia ou indisponível para '%s'. E$ %d estornados."):format(item.name, price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", playerId, { success = false, message = errRev })
        TriggerClientEvent("open77:chat:addMessage", playerId, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "FARMA-CORP NC", errRev }
        })
        return false, "inventory_unavailable"
    end
end


RegisterNetEvent("ls:cyberware:buyPharmaceutical", function(pharmaId)
    local src = source
    if not LS.isPlayerId(src) or type(pharmaId) ~= "string" then return end
    buyPharmaceutical(src, pharmaId)
end)

RegisterCommand("farmacia", function(source, args)
    local pharmaId = args[1]
    if not pharmaId then
        local helpMsg = "Medicamentos disponíveis: /farmacia neuroblocker_booster (E$ 250), /farmacia cryo_spray (E$ 180), /farmacia immuno_shot (E$ 190)"
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "FARMA-CORP NC", helpMsg }
        })
        return
    end
    buyPharmaceutical(source, tostring(pharmaId))
end, false)



-- =============================================================================
-- GESTÃO CIRÚRGICA DE IMPLANTES (RIPPERDOC API)
-- =============================================================================

---Instala um implante no corpo do cidadão
---@param playerId integer
---@param implantId string
---@return boolean, string
local function installImplant(playerId, implantId)
    local pState = Cyberware.players[playerId]
    if not pState or not pState.data then return false, "player_not_loaded" end

    local def = CyberwareConfig.Implants[implantId]
    if not def then return false, "implant_not_found" end

    local slotDef = CyberwareConfig.Slots[def.slot]
    if not slotDef then return false, "invalid_slot" end

    local implants = pState.data.implants or {}

    -- Checar limite de slots anatômicos
    local countInSlot = 0
    for _, imp in ipairs(implants) do
        if imp.slot == def.slot then
            countInSlot = countInSlot + 1
            if imp.id == implantId then
                return false, "implant_already_installed"
            end
        end
    end

    if countInSlot >= (slotDef.maxImplants or 1) then
        return false, "slot_capacity_exceeded"
    end

    table.insert(implants, {
        id = implantId,
        slot = def.slot,
        name = def.name,
        quality = def.quality,
        neuralCost = def.neuralCost,
        heatBonus = def.heatBonus,
        installedAt = nowSec(),
        durability = 100.0
    })

    pState.data.implants = implants
    Open77.exports.call("ls_data", "cacheSet", "cyberware", pState.license, pState.data)
    Open77.log.info(("[ls_cyberware] Implante '%s' instalado no cidadão [%d]."):format(def.name, playerId))

    return true, "installed"
end

---Remove um implante de um slot específico
---@param playerId integer
---@param slot string
---@return boolean, string
local function removeImplant(playerId, slot)
    local pState = Cyberware.players[playerId]
    if not pState or not pState.data then return false, "player_not_loaded" end

    local implants = pState.data.implants or {}
    local removed = nil

    for i = #implants, 1, -1 do
        if implants[i].slot == slot then
            removed = table.remove(implants, i)
            break
        end
    end

    if not removed then return false, "no_implant_in_slot" end

    pState.data.implants = implants
    Open77.exports.call("ls_data", "cacheSet", "cyberware", pState.license, pState.data)
    Open77.log.info(("[ls_cyberware] Implante '%s' desinstalado do slot '%s' do cidadão [%d]."):format(removed.name, slot, playerId))

    return true, "removed"
end

---Compra cirúrgica de implante no Ripperdoc com débito no ls_economy e rollback garantido
---@param playerId integer
---@param implantId string
---@return boolean, string
local function buyAndInstallImplant(playerId, implantId)
    if not LS.isPlayerId(playerId) or type(implantId) ~= "string" then
        return false, "invalid_player"
    end
    implantId = implantId:lower()
    local def = CyberwareConfig.Implants[implantId]
    if not def then
        return false, "implant_not_found"
    end

    local price = math.max(0, math.floor(tonumber(def.price) or 1000))

    -- Checagem prévia de anatomia para evitar cobrança indevida
    local pState = Cyberware.players[playerId]
    if not pState or not pState.data then return false, "player_not_loaded" end
    local slotDef = CyberwareConfig.Slots[def.slot]
    if not slotDef then return false, "invalid_slot" end

    local countInSlot = 0
    for _, imp in ipairs(pState.data.implants or {}) do
        if imp.slot == def.slot then
            countInSlot = countInSlot + 1
            if imp.id == implantId then
                local dupMsg = ("Você já possui '%s' instalado neste slot cirúrgico!"):format(def.name)
                TriggerClientEvent("open77:chat:addMessage", playerId, { color = { 255, 60, 60 }, multiline = false, args = { "RIPPERDOC", dupMsg } })
                return false, "implant_already_installed"
            end
        end
    end
    if countInSlot >= (slotDef.maxImplants or 1) then
        local fullMsg = ("Capacidade esgotada no slot '%s' (%d/%d)! Desinstale um cromo antes."):format(slotDef.label, countInSlot, slotDef.maxImplants or 1)
        TriggerClientEvent("open77:chat:addMessage", playerId, { color = { 255, 60, 60 }, multiline = false, args = { "RIPPERDOC", fullMsg } })
        return false, "slot_capacity_exceeded"
    end

    -- Processa pagamento (Tenta Banco primeiro para cirurgias, depois Cash)
    local paid = false
    local paymentType = "Night City Bank"

    local okBankCall, debitBankRes = pcall(function()
        local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "bank", price, "Cirurgia Ripperdoc: " .. def.name)
        if remCall and remCall.await then return remCall:await() end
        return remCall
    end)

    if okBankCall and debitBankRes == true then
        paid = true
        paymentType = "Night City Bank"
    else
        local okCashCall, debitCashRes = pcall(function()
            local remCall = Open77.exports.call("ls_economy", "removeMoney", playerId, "cash", price, "Cirurgia Ripperdoc: " .. def.name)
            if remCall and remCall.await then return remCall:await() end
            return remCall
        end)
        if okCashCall and debitCashRes == true then
            paid = true
            paymentType = "dinheiro vivo"
        end
    end

    if not paid then
        local failMsg = ("Fundos insuficientes para procedimento cirúrgico! '%s' custa E$ %d."):format(def.name, price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", playerId, { success = false, message = failMsg })
        TriggerClientEvent("open77:chat:addMessage", playerId, { color = { 255, 60, 60 }, multiline = false, args = { "RIPPERDOC", failMsg } })
        return false, "insufficient_funds"
    end

    -- Instala cirurgicamente
    local ok, reason = installImplant(playerId, implantId)
    if ok then
        local successMsg = ("Cirurgia concluída com sucesso! '%s' implantado por E$ %d via %s."):format(def.name, price, paymentType)
        TriggerClientEvent("ls:ui:ripperdocFeedback", playerId, { success = true, message = successMsg })
        TriggerClientEvent("open77:chat:addMessage", playerId, { color = { 34, 216, 226 }, multiline = false, args = { "RIPPERDOC", successMsg } })
    else
        -- Rollback compensatório de fundos
        pcall(function()
            Open77.exports.call("ls_economy", "addMoney", playerId, "bank", price, "Reembolso Ripperdoc: Rejeição cirúrgica")
        end)
        local errMsg = ("Cirurgia abortada (%s). E$ %d estornados integralmente."):format(tostring(reason), price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", playerId, { success = false, message = errMsg })
        TriggerClientEvent("open77:chat:addMessage", playerId, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "RIPPERDOC", errMsg }
        })
    end

    return ok, reason
end

RegisterNetEvent("ls:cyberware:buyImplant", function(implantId)
    local src = source
    if not LS.isPlayerId(src) or type(implantId) ~= "string" then return end
    buyAndInstallImplant(src, implantId)
end)

RegisterCommand("ripperdoc", function(source, args)
    local sub = args[1] and args[1]:lower() or nil

    -- INTERFACE FIRST: Sem argumentos ou /ripperdoc ui abre a estação cirúrgica visual
    if not sub or sub == "ui" or sub == "open" then
        if source ~= 0 then
            TriggerClientEvent("ls:ui:openRipperdoc", source)
            return
        end
    end

    if sub == "buy" and args[2] then
        local implantId = tostring(args[2]):lower()
        buyAndInstallImplant(source, implantId)
        return
    end

    if sub == "list" then
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "RIPPERDOC CATÁLOGO", "Implantes Disponíveis para Procedimento Cirúrgico:" }
        })
        for id, def in pairs(CyberwareConfig.Implants) do
            local line = ("* '%s' (%s) - E$ %d | Custo Neural: %.1f%%"):format(id, def.name, def.price or 0, def.neuralCost or 0)
            TriggerClientEvent("open77:chat:addMessage", source, {
                color = { 34, 216, 226 },
                multiline = false,
                args = { "CROMO", line }
            })
        end
        return
    end

    local helpMsg = "Uso: /ripperdoc (abrir estação cirúrgica visual) ou /ripperdoc buy <implantId>"
    TriggerClientEvent("open77:chat:addMessage", source, {
        color = { 252, 238, 10 },
        multiline = false,
        args = { "RIPPERDOC", helpMsg }
    })
end, false)



-- =============================================================================
-- EXPORTS PARA OUTROS MÓDULOS (CORE, ECONOMIA, MEDICINA, UI)
-- =============================================================================

exports("getCyberware", function(playerId)
    local pState = Cyberware.players[playerId]
    return pState and cloneTable(pState.data) or nil
end)

exports("getNeuralStability", function(playerId)
    local pState = Cyberware.players[playerId]
    return pState and pState.data and pState.data.neural_stability or CyberwareConfig.BaseStability
end)

exports("getOcularTemp", function(playerId)
    local pState = Cyberware.players[playerId]
    return pState and pState.data and pState.data.ocular_temp or CyberwareConfig.BaseOcularTemp
end)

exports("installImplant", installImplant)
exports("removeImplant", removeImplant)
exports("usePharmaceutical", applyPharmaceutical)
exports("buyImplant", buyAndInstallImplant)
exports("buyPharmaceutical", buyPharmaceutical)


-- =============================================================================
-- COMANDOS ADMINISTRATIVOS & DE TESTE DE CIBERPSICOSE
-- =============================================================================

RegisterCommand("cw_status", function(source, args, raw)
    local target = tonumber(args[1]) or source
    local pState = Cyberware.players[target]
    if not pState or not pState.data then
        return print(("[ls_cyberware] Cidadão [%s] não encontrado ou não carregado."):format(tostring(target)))
    end

    local d = pState.data
    local currentSec = nowSec()
    local remBlocker = math.max(0, (d.neuroblocker_expires or 0) - currentSec)

    local msg = ([[
------------------------------------------------------
[KIROSHI TELEMETRIA] STATUS CIBERNÉTICO DO CIDADÃO [%d]
- Estabilidade Neural: %.1f%% (Limiar Psicose: %.1f%%)
- Calor Ocular: %.1f°C (Alerta: %.1f°C)
- Estado de Psicose: %s
- Neurobloqueador Ativo: %s (Tempo restante: %ds)
- Implantes Instalados: %d peças
------------------------------------------------------
]]):format(
        target,
        d.neural_stability or 0, CyberwareConfig.PsychosisThreshold,
        d.ocular_temp or 0, CyberwareConfig.WarningOcularTemp,
        d.is_psychotic and "SIM (CRÍTICO)" or "NÃO (ESTÁVEL)",
        remBlocker > 0 and "SIM" or "NÃO (EM FALTA)", remBlocker,
        #(d.implants or {})
    )

    if source == 0 then
        print(msg)
    else
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 34, 216, 226 },
            multiline = true,
            args = { "CIBERWARE", msg }
        })
    end
end, false)

RegisterCommand("cw_give", function(source, args, raw)
    local target = tonumber(args[1]) or source
    local implantId = args[2]
    if not implantId then
        return print("[ls_cyberware] Uso: /cw_give <playerId> <implantId>")
    end

    local ok, reason = installImplant(target, implantId)
    local outMsg = ok and ("Implante '%s' instalado com sucesso em [%d]!"):format(implantId, target)
        or ("Falha ao instalar '%s': %s"):format(implantId, tostring(reason))

    if source == 0 then print(outMsg) else
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = ok and { 34, 216, 226 } or { 255, 80, 80 },
            multiline = false,
            args = { "RIPPERDOC", outMsg }
        })
    end
end, false)

RegisterCommand("cw_blocker", function(source, args, raw)
    local target = tonumber(args[1]) or source
    local ok, reason = applyPharmaceutical(target, "neuroblocker_booster")
    local outMsg = ok and ("Neurobloqueador aplicado com sucesso no cidadão [%d]!"):format(target)
        or ("Falha ao aplicar neurobloqueador: %s"):format(tostring(reason))

    if source == 0 then print(outMsg) else
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "FARMÁCIA", outMsg }
        })
    end
end, false)

RegisterCommand("cw_cryo", function(source, args, raw)
    local target = tonumber(args[1]) or source
    local ok, reason = applyPharmaceutical(target, "cryo_spray")
    local outMsg = ok and ("Spray Criogênico aplicado nos sensores de [%d]!"):format(target)
        or ("Falha ao aplicar spray: %s"):format(tostring(reason))

    if source == 0 then print(outMsg) else
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "FARMÁCIA", outMsg }
        })
    end
end, false)

RegisterCommand("cw_psychosis", function(source, args, raw)
    local target = tonumber(args[1]) or source
    local pState = Cyberware.players[target]
    if not pState or not pState.data then return end

    -- Zera o neurobloqueador e força estabilidade baixa para teste de ciberpsicose
    pState.data.neuroblocker_expires = 0
    pState.data.neural_stability = 12.0
    pState.data.ocular_temp = 43.5
    pState.data.is_psychotic = true

    Open77.state.player(target):set("ls.psychosis", true)
    TriggerEvent("ls:cyberware:psychosisTriggered", target, 12.0, #(pState.data.implants or {}))
    TriggerClientEvent("ls:cyberware:onPsychosisStart", target, 12.0)

    local outMsg = ("Ciberpsicose forçada com sucesso no cidadão [%d] (Estabilidade: 12.0%%)!"):format(target)
    if source == 0 then print(outMsg) else
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 255, 50, 50 },
            multiline = false,
            args = { "MAXTAC ALERTA", outMsg }
        })
    end
end, false)

RegisterCommand("cw_cure", function(source, args, raw)
    local target = tonumber(args[1]) or source
    local pState = Cyberware.players[target]
    if not pState or not pState.data then return end

    pState.data.neuroblocker_expires = nowSec() + 3600
    pState.data.neural_stability = 100.0
    pState.data.ocular_temp = 36.5
    pState.data.is_psychotic = false

    Open77.state.player(target):set("ls.psychosis", false)
    TriggerEvent("ls:cyberware:psychosisEnded", target)
    TriggerClientEvent("ls:cyberware:onPsychosisEnd", target)

    local outMsg = ("Estabilidade neural restaurada para 100%% no cidadão [%d]!"):format(target)
    if source == 0 then print(outMsg) else
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "RIPPERDOC", outMsg }
        })
    end
end, false)

-- =============================================================================
-- SISTEMA DE COMPRAS DA CLÍNICA RIPPERDOC & FARMÁCIA NEURAL (ENTREGA NA MOCHILA)
-- =============================================================================

local RIPPER_PRICES = {
    -- Farmacêuticos
    ["neuroblocker_booster"] = { label = "Injetor de Neurobloqueador", price = 250 },
    ["cryo_spray"] = { label = "Spray Criogênico Craniano", price = 180 },
    ["immuno_shot"] = { label = "Ampola Imunossupressora", price = 190 },
    -- Implantes Corporais
    ["kiroshi_optics_mk1"] = { label = "Kiroshi Optics Mk.1", price = 1200 },
    ["kiroshi_optics_mk2"] = { label = "Kiroshi Optics Mk.2", price = 3500 },
    ["kiroshi_optics_stalker"] = { label = "Kiroshi 'Stalker' Mk.3", price = 12500 },
    ["bioconductor_mk1"] = { label = "Biocondutor Zetatech Mk.1", price = 4200 },
    ["memory_boost_mk2"] = { label = "Amplificador Dynalar", price = 8500 },
    ["second_heart_mk1"] = { label = "Segundo Coração Moore", price = 28000 },
    ["subdermal_armor_mk1"] = { label = "Armadura Militech", price = 2500 },
    ["optical_camo_mk1"] = { label = "Camuflagem Arasaka", price = 22000 },
    ["militech_sandevistan_mk4"] = { label = "Militech Sandevistan Mk.4", price = 35000 },
    ["arasaka_cyberdeck_mk3"] = { label = "Cyberdeck Arasaka Mk.3", price = 16000 },
    ["smart_link"] = { label = "Smart Link Arasaka", price = 4500 },
    ["mantis_blades"] = { label = "Lâminas Mantis Carbono", price = 15000 },
    ["gorilla_arms"] = { label = "Braços de Gorila", price = 15000 },
    ["reinforced_tendons"] = { label = "Tendões Reforçados", price = 9000 }
}

local function processStorePurchase(src, itemId, storeName)
    local item = RIPPER_PRICES[itemId]
    if not item then
        Open77.log.warn(("[ls_cyberware] Item não catalogado para compra na clínica: %s"):format(tostring(itemId)))
        TriggerClientEvent("ls:ui:ripperdocFeedback", src, { success = false, message = "Item indisponível no catálogo da clínica." })
        return
    end

    local price = item.price
    local paid = false
    local paymentSource = "cash"

    -- 1. Cobrança via ls_economy (Tenta dinheiro em mãos primeiro, depois banco)
    local okCash, canCash = pcall(function()
        local res = Open77.exports.call("ls_economy", "canAfford", src, "cash", price)
        return res and res:await()
    end)
    if okCash and canCash then
        local okSub = pcall(function()
            local res = Open77.exports.call("ls_economy", "removeMoney", src, "cash", price, ("Compra Clínica: %s"):format(item.label))
            return res and res:await()
        end)
        if okSub then
            paid = true
            paymentSource = "cash"
        end
    end

    if not paid then
        local okBank, canBank = pcall(function()
            local res = Open77.exports.call("ls_economy", "canAfford", src, "bank", price)
            return res and res:await()
        end)
        if okBank and canBank then
            local okSub = pcall(function()
                local res = Open77.exports.call("ls_economy", "removeMoney", src, "bank", price, ("Compra Clínica: %s"):format(item.label))
                return res and res:await()
            end)
            if okSub then
                paid = true
                paymentSource = "bank"
            end
        end
    end

    if not paid then
        local failMsg = ("Saldo insuficiente! '%s' custa E$ %d."):format(item.label, price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", src, { success = false, message = failMsg })
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { storeName, failMsg }
        })
        return
    end

    -- 2. Entregar o item adquirido na MOCHILA do jogador (ls_inventory)
    local addedToInventory = false
    local addFailureReason = nil

    if Open77 and Open77.exports and Open77.exports.call then
        local okCall, pending = pcall(Open77.exports.call, "ls_inventory", "AddItem", src, itemId, 1)
        if okCall and pending then
            if type(pending) == "table" and pending.await then
                local okAwait, res, reason = pcall(function() return pending:await() end)
                if okAwait and (res == true or (type(res) == "table" and res[1] == true)) then
                    addedToInventory = true
                else
                    addFailureReason = reason or res
                end
            elseif pending == true then
                addedToInventory = true
            end
        end
    end

    if not addedToInventory and Open77 and Open77.exports and Open77.exports.callSync then
        local okSync, syncRes = pcall(Open77.exports.callSync, "ls_inventory", "AddItem", src, itemId, 1)
        if okSync and (syncRes == true or (type(syncRes) == "table" and syncRes[1] == true)) then
            addedToInventory = true
        end
    end

    if not addedToInventory then
        TriggerEvent("ls:inventory:addItem", src, itemId, 1, {}, function(success, reason)
            if success == true then
                addedToInventory = true
            else
                addFailureReason = addFailureReason or reason
            end
        end)
    end

    if addedToInventory then
        local successMsg = ("'%s' adquirido por E$ %d e guardado na sua mochila."):format(item.label, price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", src, { success = true, message = successMsg })
        TriggerClientEvent("ls:ui:notify", src, {
            type = "success",
            title = "COMPRA REALIZADA",
            message = item.label .. " adicionado à sua mochila."
        })
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 34, 216, 226 },
            multiline = false,
            args = { storeName, successMsg }
        })
    else
        -- Reembolso automático imediato
        pcall(function()
            Open77.exports.call("ls_economy", "addMoney", src, paymentSource, price, "Reembolso: Falha no Inventário")
        end)
        local fullMsg = ("Mochila cheia ou indisponível! Não foi possível armazenar '%s'. E$ %d reembolsados."):format(item.label, price)
        TriggerClientEvent("ls:ui:ripperdocFeedback", src, { success = false, message = fullMsg })
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { storeName, fullMsg }
        })
    end
end

RegisterNetEvent("ls:cyberware:buyPharmaceutical", function(pharmaId)
    local src = source
    if not src or src <= 0 or type(pharmaId) ~= "string" then return end
    CreateThread(function()
        processStorePurchase(src, pharmaId, "FARMÁCIA NEURAL")
    end)
end)

RegisterNetEvent("ls:cyberware:buyImplant", function(implantId)
    local src = source
    if not src or src <= 0 or type(implantId) ~= "string" then return end
    CreateThread(function()
        processStorePurchase(src, implantId, "CLÍNICA RIPPERDOC")
    end)
end)
