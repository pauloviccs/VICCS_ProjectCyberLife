--[[
    LIFESIM RP - Vitals Client Observer & Motion Telemetry
    Path: ls_vitals/client/main.lua
    Observa o State Bag de necessidades biológicas, rastreia esforço físico do jogador e notifica a HUD Kiroshi.
]]

local currentVitals = {
    hunger = 100.0,
    thirst = 100.0,
    energy = 100.0,
    hygiene = 100.0,
    stress = 0.0,
    activity = "idle",
    activityMult = 1.0
}

local lastReportedActivity = "idle"
local lastHeartbeatMs = 0

local function forwardToUI(v)
    -- Tenta despachar para o ls_ui de forma não-bloqueante
    pcall(function()
        Open77.exports.call("ls_ui", "push", "vitals", v)
    end)
end

---Aplica os dados de vitais recebidos de forma segura e atualiza UI
---@param v table
local function applyVitals(v)
    if type(v) ~= "table" then return end
    currentVitals.hunger       = tonumber(v.hunger) or currentVitals.hunger
    currentVitals.thirst       = tonumber(v.thirst) or currentVitals.thirst
    currentVitals.energy       = tonumber(v.energy) or currentVitals.energy
    currentVitals.hygiene      = tonumber(v.hygiene) or currentVitals.hygiene
    currentVitals.stress       = tonumber(v.stress) or currentVitals.stress
    currentVitals.activity     = tostring(v.activity or currentVitals.activity)
    currentVitals.activityMult = tonumber(v.activityMult) or currentVitals.activityMult
    currentVitals.rateMult     = tonumber(v.rateMult) or currentVitals.rateMult

    forwardToUI(currentVitals)
    TriggerEvent("ls:vitals:clientUpdated", currentVitals)
end

-- =============================================================================
-- RECEPÇÃO DE SINCRONIZAÇÃO (DUAL: NET EVENT + STATE BAG)
-- =============================================================================

-- 1. NetEvent direto garantido do servidor
RegisterNetEvent("ls:vitals:sync", function(v)
    applyVitals(v)
end)

-- 2. Observador de State Bag (Open77.state.onChange)
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.vitals.v", function(selector, key, v)
        applyVitals(v)
    end)
end

-- Re-sincronizar quando a UI do lifesim avisar que está pronta
AddEventHandler("ls:ui:ready", function()
    forwardToUI(currentVitals)
    TriggerServerEvent("ls:vitals:requestSync")
end)

-- Solicitar sincronização fresca logo no boot
CreateThread(function()
    Wait(500)
    TriggerServerEvent("ls:vitals:requestSync")
end)

-- =============================================================================
-- MONITOR DE ATIVIDADE & ESFORÇO MOTOR DO JOGADOR
-- =============================================================================

CreateThread(function()
    while true do
        Wait(400) -- Varredura a cada 400ms para resposta motora ágil

        local localId = Open77.players and Open77.players.localId and Open77.players.localId()
        if localId then
            local act = "idle"
            local mult = VitalsConfig.Multipliers.Idle or 1.0

            -- Detecção multicamadas de veículo nativo REDengine e Open77
            local inVehicle = false
            if type(IsPlayerInVehicle) == "function" and IsPlayerInVehicle() then
                inVehicle = true
            elseif type(IsPlayerDriver) == "function" and IsPlayerDriver() then
                inVehicle = true
            elseif type(IsPlayerPassenger) == "function" and IsPlayerPassenger() then
                inVehicle = true
            elseif Open77.vehicles and Open77.vehicles.getPlayerSeat and Open77.vehicles.getPlayerSeat() ~= nil then
                inVehicle = true
            elseif Open77.players and Open77.players.getVehicleSeat and Open77.players.getVehicleSeat() ~= nil then
                inVehicle = true
            elseif Open77.players and Open77.players.isInVehicle and Open77.players.isInVehicle(localId) then
                inVehicle = true
            end

            if inVehicle then
                act = "driving"
                mult = VitalsConfig.Multipliers.Driving or 0.85
            elseif Open77.players.isShooting and Open77.players.isShooting(localId) then
                act = "combat"
                mult = VitalsConfig.Multipliers.Combat or 3.0
            elseif Open77.players.isSprinting and Open77.players.isSprinting(localId) then
                act = "sprinting"
                mult = VitalsConfig.Multipliers.Sprinting or 3.2
            elseif Open77.players.isJumping and Open77.players.isJumping(localId) then
                act = "jumping"
                mult = VitalsConfig.Multipliers.Jumping or 2.5
            elseif Open77.players.isSliding and Open77.players.isSliding(localId) then
                act = "sliding"
                mult = VitalsConfig.Multipliers.Sliding or 2.2
            elseif Open77.players.isCrouching and Open77.players.isCrouching(localId) then
                act = "crouching"
                mult = 1.1
            end

            local tNow = GetGameTimer()
            -- Reporta quando o estado mudar ou a cada 8 segundos de pulso contínuo
            if act ~= lastReportedActivity or (tNow - lastHeartbeatMs) >= 8000 then
                lastReportedActivity = act
                lastHeartbeatMs = tNow
                TriggerServerEvent("ls:vitals:setActivity", act, mult)
            end
        end
    end
end)

-- Listener de alerta biológico (desidratação severa ou inanição)
RegisterNetEvent("ls:vitals:damageAlert", function(alertData)
    TriggerEvent("ls:ui:vitalDamage", alertData)
end)

-- =============================================================================
-- COMANDO CLIENTE DE TELEMETRIA (/vitals)
-- =============================================================================

local function executeVitalsClientCommand(source, args)
    local sub = args[1] and tostring(args[1]):lower()

    if not sub or sub == "" or sub == "status" or sub == "info" then
        -- Solicita sincronização fresca autoritativa do servidor
        TriggerServerEvent("ls:vitals:requestSync")

        -- Exibição imediata com os dados locais atuais
        local msg = ("[BIOMONITOR] Fome: %.1f%% | Sede: %.1f%% | Stamina: %.1f%% | Higiene: %.1f%% | Stress: %.1f%% | Atividade: %s (x%.2f)"):format(
            currentVitals.hunger,
            currentVitals.thirst,
            currentVitals.energy,
            currentVitals.hygiene,
            currentVitals.stress,
            (currentVitals.activity or "idle"):upper(),
            currentVitals.activityMult or 1.0
        )
        Open77.log.info(msg)
        TriggerEvent("chat:addMessage", {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "KIROSHI", msg }
        })
        return
    end

    if sub == "consume" and args[2] then
        local itemKey = tostring(args[2]):lower()
        TriggerServerEvent("ls:vitals:consume", itemKey)
        Open77.log.info(("[ls_vitals] Solicitado consumo do item: %s"):format(itemKey))
        return
    end

    -- Qualquer outro subcomando (fill, drain, heal, set, rate, log, items, help...) é encaminhado ao servidor com todos os argumentos
    TriggerServerEvent("ls:vitals:adminCommand", args)
end

RegisterCommand("vitals", executeVitalsClientCommand, false)
RegisterCommand("ls_vitals", executeVitalsClientCommand, false)

-- =============================================================================
-- EXPORTS CLIENTE
-- =============================================================================

exports("getVitals", function()
    return {
        hunger = currentVitals.hunger,
        thirst = currentVitals.thirst,
        energy = currentVitals.energy,
        hygiene = currentVitals.hygiene,
        stress = currentVitals.stress,
        activity = currentVitals.activity,
        activityMult = currentVitals.activityMult
    }
end)

exports("consume", function(itemKey)
    if type(itemKey) == "string" and itemKey ~= "" then
        TriggerServerEvent("ls:vitals:consume", itemKey)
        return true
    end
    return false
end)
