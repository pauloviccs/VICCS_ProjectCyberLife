--[[
    LIFESIM RP - Core Client Entrypoint
    Path: ls_core/client/main.lua
    Informa ao servidor a prontidão física do avatar no cliente e escuta mudanças de estado do core.
]]

local clientSpawnNotified = false

local function notifyServerReady()
    if clientSpawnNotified then return end
    clientSpawnNotified = true
    Open77.log.info("[ls_core:Client] Cliente físico pronto no mundo. Notificando servidor...")
    TriggerServerEvent("ls:core:clientReady")
    -- Notifica a plataforma OPEN//77 que o cliente está em gameplay ativa (abre o readiness gate da plataforma)
    TriggerServerEvent("open77:session:gameplayReady")
end

AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    Open77.log.info("[ls_core:Client] Subindo runtime do cliente Life-Sim.")

    -- Se o mundo já estiver pronto no momento do start/reload
    if Open77.ready and Open77.ready.isReady and Open77.ready.isReady() then
        notifyServerReady()
    end

    -- Watchdog para assegurar que se o avatar estiver vivo no mundo o sinal é disparado
    CreateThread(function()
        for _ = 1, 30 do
            Wait(1000)
            if clientSpawnNotified then break end
            local ped = PlayerPedId()
            if ped and DoesEntityExist(ped) and not IsEntityDead(ped) then
                notifyServerReady()
                break
            end
        end
    end)
end)

-- Evento nativo da plataforma quando o mundo do jogador é totalmente montado
AddEventHandler("open77:worldReady", function()
    notifyServerReady()
end)

-- Observador de State Bag do Core
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.core.loaded", function(bagName, key, val)
        if val == true then
            Open77.log.info("[ls_core:Client] Perfil do jogador sincronizado e validado pelo servidor.")
        end
    end)
end
