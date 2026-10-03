--[[
    LIFESIM RP - Cyberware, Neural Stability & Psychosis Client Controller
    Path: ls_cyberware/client/main.lua
    Observador de telemetria cibernética, efeitos sensoriais de ciberpsicose,
    alertas térmicos oculares Kiroshi e atalhos farmacêuticos.
]]

local ClientCyberware = {
    stability = 100.0,
    heat = 36.5,
    isPsychotic = false,
    blockerActive = true,
    blockerRemaining = 0,
    implantsCount = 0,
    lastHeatWarnTime = 0,
    psychosisThreadActive = false
}

-- =============================================================================
-- OBSERVADOR REATIVO & DUAL SYNC DO SERVIDOR
-- =============================================================================

local function applyCyberwareData(value)
    if not value or type(value) ~= "table" then return end
    ClientCyberware.stability = tonumber(value.stability) or ClientCyberware.stability
    ClientCyberware.heat = tonumber(value.heat) or ClientCyberware.heat
    ClientCyberware.isPsychotic = (value.psychosis == true)
    ClientCyberware.blockerActive = (value.blockerActive == true)
    ClientCyberware.blockerRemaining = tonumber(value.blockerRemaining) or 0
    ClientCyberware.implantsCount = tonumber(value.implantsCount) or ClientCyberware.implantsCount

    -- Encaminha dados de telemetria para o HUD diegético Kiroshi
    TriggerEvent("ls:ui:updateCyberware", {
        stability = ClientCyberware.stability,
        heat = ClientCyberware.heat,
        isPsychotic = ClientCyberware.isPsychotic,
        blockerActive = ClientCyberware.blockerActive,
        implantsCount = ClientCyberware.implantsCount
    })

    if ClientCyberware.isPsychotic then
        TriggerEvent("ls:cyberware:clientPsychosisStart")
    else
        TriggerEvent("ls:cyberware:clientPsychosisStop")
    end
end

-- 1. Sincronização direta via NetEvent (garantida mesmo sem StateBag montado)
RegisterNetEvent("ls:cyberware:sync", function(value)
    applyCyberwareData(value)
end)

-- 2. Observadores reativos de State Bag local Open77
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.cyberware.v", function(bagName, key, value)
        applyCyberwareData(value)
    end)

    Open77.state.onChange(nil, "ls.psychosis", function(bagName, key, isPsychotic)
        ClientCyberware.isPsychotic = (isPsychotic == true)
        if ClientCyberware.isPsychotic then
            TriggerEvent("ls:cyberware:clientPsychosisStart")
        else
            TriggerEvent("ls:cyberware:clientPsychosisStop")
        end
    end)
end

-- 3. Solicitação de sincronização no boot do cliente
AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    TriggerServerEvent("ls:cyberware:requestSync")
end)

-- =============================================================================
-- EFEITOS SENSORIAIS & LOOP DE CIBERPSICOSE
-- =============================================================================

local function startPsychosisFeedback()
    if ClientCyberware.psychosisThreadActive then return end
    ClientCyberware.psychosisThreadActive = true

    CreateThread(function()
        TriggerEvent("open77:chat:addMessage", {
            color = { 255, 40, 40 },
            multiline = true,
            args = {
                "// KIROSHI CRITICAL //",
                "FALHA DE ESTABILIDADE NEURAL (<25%). SINAPSES CEREBRAIS CORROMPIDAS. CIBERPSICOSE IMINENTE!"
            }
        })

        while ClientCyberware.isPsychotic do
            -- Emite aviso periódico de crise neural
            Wait(8000)

            if ClientCyberware.isPsychotic then
                TriggerEvent("open77:chat:addMessage", {
                    color = { 255, 60, 60 },
                    multiline = false,
                    args = {
                        "PSICOSE",
                        ("Estabilidade Neural Crítica (%.1f%%). Aplique Neurobloqueador com /neuroblocker!")
                            :format(ClientCyberware.stability)
                    }
                })
            end
        end

        ClientCyberware.psychosisThreadActive = false
    end)
end

RegisterNetEvent("ls:cyberware:onPsychosisStart", function(stability)
    ClientCyberware.isPsychotic = true
    startPsychosisFeedback()
end)

RegisterNetEvent("ls:cyberware:onPsychosisEnd", function()
    ClientCyberware.isPsychotic = false
    TriggerEvent("open77:chat:addMessage", {
        color = { 34, 216, 226 },
        multiline = false,
        args = {
            "KIROSHI",
            "Estabilidade neural recuperada. Supressores sinápticos operando normalmente."
        }
    })
end)

RegisterNetEvent("ls:cyberware:clientPsychosisStart", function()
    startPsychosisFeedback()
end)

RegisterNetEvent("ls:cyberware:clientPsychosisStop", function()
    ClientCyberware.isPsychotic = false
end)

-- =============================================================================
-- ALERTAS TÉRMICOS DE HARDWARE OCULAR
-- =============================================================================

RegisterNetEvent("ls:cyberware:onHeatWarning", function(heat)
    local now = GetGameTimer()
    if now - ClientCyberware.lastHeatWarnTime > 30000 then -- 30s de cooldown de aviso
        ClientCyberware.lastHeatWarnTime = now
        TriggerEvent("open77:chat:addMessage", {
            color = { 252, 238, 10 },
            multiline = false,
            args = {
                "KIROSHI OPTICS",
                ("AVISO TÉRMICO: Núcleo ocular a %.1f°C. Risco de sobreaquecimento de sensores!")
                    :format(heat)
            }
        })
    end
end)

RegisterNetEvent("ls:cyberware:onPharmaUsed", function(pharmaId, pharmaName)
    TriggerEvent("open77:chat:addMessage", {
        color = { 34, 216, 226 },
        multiline = false,
        args = {
            "BIO-INJETOR",
            ("Medicamento '%s' administrado com sucesso."):format(tostring(pharmaName))
        }
    })
end)

-- =============================================================================
-- EXPORTS CLIENTE & INTEGRAÇÃO DIEGÉTICA (SEM COMANDOS DE CHAT)
-- =============================================================================

exports("getCyberwareData", function()
    return ClientCyberware
end)

exports("usePharmaceutical", function(pharmaId)
    if not pharmaId then return false end
    TriggerServerEvent("ls:cyberware:usePharmaceutical", tostring(pharmaId))
    return true
end)

exports("useNeuroblocker", function()
    TriggerServerEvent("ls:cyberware:usePharmaceutical", "neuroblocker_booster")
    return true
end)

exports("useCryo", function()
    TriggerServerEvent("ls:cyberware:usePharmaceutical", "cryo_spray")
    return true
end)

-- Comando exclusivo de diagnóstico / depuração para operadores
RegisterCommand("cw_diag", function()
    local blockerText = ClientCyberware.blockerActive
        and ("Ativo (%ds restantes)"):format(ClientCyberware.blockerRemaining)
        or "EXPIRADO"

    print(("[ls_cyberware:diag] Estabilidade=%.1f%% | Calor=%.1f°C | Neurobloqueador=%s | Implantes=%d | Psicose=%s"):format(
        ClientCyberware.stability,
        ClientCyberware.heat,
        blockerText,
        ClientCyberware.implantsCount,
        tostring(ClientCyberware.isPsychotic)
    ))
end, false)
