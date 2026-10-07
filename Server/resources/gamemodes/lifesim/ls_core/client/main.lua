--[[
    LIFESIM RP - Core Client Entrypoint
    Path: ls_core/client/main.lua
    Informa ao servidor a prontidão física do avatar no cliente e escuta mudanças de estado do core.
]]

local clientSpawnNotified = false

local function notifyServerReady()
    if clientSpawnNotified then return end
    clientSpawnNotified = true
    Open77.log.info("[ls_core:Client] Cliente físico pronto no mundo (bootstrap completo). Notificando servidor...")
    TriggerServerEvent("ls:core:clientReady")
    -- Notifica a plataforma OPEN//77 que o cliente está em gameplay ativa (abre o readiness gate da plataforma)
    TriggerServerEvent("open77:session:gameplayReady")
end

-- 1. O evento canônico que o host nativo emite quando o bootstrap do jogador termina e a loading screen sai
AddEventHandler("open77:playerReset:complete", function()
    notifyServerReady()
end)

-- 2. Fallback caso o recurso seja reiniciado com o jogador já no mundo
AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    Open77.log.info("[ls_core:Client] Subindo runtime do cliente Life-Sim.")

    CreateThread(function()
        for _ = 1, 25 do
            Wait(1000)
            if clientSpawnNotified then break end
            pcall(function()
                if Open77.players and Open77.players.localId then
                    local myId = Open77.players.localId()
                    if myId and myId > 0 then
                        if Open77.players.isDead and not Open77.players.isDead(myId) then
                            notifyServerReady()
                        end
                    end
                end
            end)
        end
    end)
end)

-- 3. World Ready (RuntimeScene attach) com fallback temporizado seguro
AddEventHandler("open77:worldReady", function()
    SetTimeout(6000, function()
        if not clientSpawnNotified then
            notifyServerReady()
        end
    end)
end)

-- Observador de State Bag do Core
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.core.loaded", function(bagName, key, val)
        if val == true then
            Open77.log.info("[ls_core:Client] Perfil do jogador sincronizado e validado pelo servidor.")
        end
    end)
end
