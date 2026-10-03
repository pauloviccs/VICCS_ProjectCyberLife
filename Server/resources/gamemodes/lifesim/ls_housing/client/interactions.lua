--[[
    LIFESIM RP - Housing Furniture Interactions Client Manager
    Path: ls_housing/client/interactions.lua
    
    Gerencia:
    1. Proximidade com mobílias interativas (Camas, Chuveiros, Cofres, Sintetizadores).
    2. Disparo de regeneração biológica no ls_vitals (Energia, Higiene, Estresse).
    3. Animações e transições diegéticas de conforto residencial.
]]

local activeFurniture = {}
local nearbyInteractiveItem = nil

AddEventHandler("ls:housing:onEnter", function(data)
    activeFurniture = data.furniture or {}
end)

AddEventHandler("ls:housing:onExit", function()
    activeFurniture = {}
    nearbyInteractiveItem = nil
end)

RegisterNetEvent("ls:housing:furnitureAdded", function(item)
    table.insert(activeFurniture, item)
end)

RegisterNetEvent("ls:housing:furnitureRemoved", function(furnitureId)
    for i, item in ipairs(activeFurniture) do
        if item.id == furnitureId then
            table.remove(activeFurniture, i)
            break
        end
    end
end)

-- Procura mobília interativa mais próxima
CreateThread(function()
    while true do
        Wait(350)
        local ped = PlayerPedId and PlayerPedId() or -1
        local pPos = GetEntityCoords and GetEntityCoords(ped) or nil

        if pPos and exports["ls_housing"]:isInsideApartment() then
            nearbyInteractiveItem = nil
            for _, item in ipairs(activeFurniture) do
                local template = item.data
                if template and template.interaction then
                    local dist = #(vector3(pPos.x, pPos.y, pPos.z) - vector3(item.x, item.y, item.z))
                    if dist <= 2.0 then
                        nearbyInteractiveItem = item
                        break
                    end
                end
            end
        else
            nearbyInteractiveItem = nil
        end
    end
end)

-- Loop de interação com tecla [E]
CreateThread(function()
    while true do
        Wait(5)
        if nearbyInteractiveItem then
            if IsControlJustPressed and (IsControlJustPressed(0, 38) or IsControlJustPressed(0, 51)) then
                local it = nearbyInteractiveItem
                local inter = it.data and it.data.interaction
                if inter then
                    if inter.type == "bed" then
                        TriggerServerEvent("ls:housing:useBed", it.template_id)
                        Open77.log.info("[ls_housing] Deitou na cama para descansar.")
                    elseif inter.type == "shower" then
                        TriggerServerEvent("ls:housing:useShower")
                        Open77.log.info("[ls_housing] Ativou banho sônico desinfetante.")
                    elseif inter.type == "stash" then
                        TriggerEvent("ls:housing:feedback", {
                            success = true,
                            message = "Acessando Baú Balístico Residencial..."
                        })
                    elseif inter.type == "kitchen" then
                        TriggerEvent("ls:housing:feedback", {
                            success = true,
                            message = "Sintetizador culinário pronto. Alimentos disponíveis no estoque."
                        })
                    end
                end
                Wait(500)
            end
        else
            Wait(200)
        end
    end
end)
