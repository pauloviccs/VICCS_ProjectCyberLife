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

local function getPlayerCoords()
    if Open77.character and Open77.character.position then
        local r1, r2, r3 = Open77.character.position()
        if type(r1) == "table" then
            return tonumber(r1.x), tonumber(r1.y), tonumber(r1.z)
        elseif type(r1) == "number" and r2 and r3 then
            return r1, tonumber(r2), tonumber(r3)
        end
    end
    local state = (Open77.character and Open77.character.state) and Open77.character.state() or nil
    if state and state.position then
        return tonumber(state.position.x), tonumber(state.position.y), tonumber(state.position.z)
    end
    if GetEntityCoords and PlayerPedId then
        local p = GetEntityCoords(PlayerPedId())
        if p then return p.x, p.y, p.z end
    end
    return nil, nil, nil
end

local function isInteractActionPressed()
    if not Open77.input or not Open77.input.isCaptured or not Open77.input.isCaptured() then
        if Open77.input and Open77.input.isDown then
            if Open77.input.isDown("e") == true or Open77.input.isDown("E") == true then
                return true
            end
        end
        if Open77.input and Open77.input.isActionJustPressed then
            if Open77.input.isActionJustPressed("ChoiceApply") or
               Open77.input.isActionJustPressed("Choice1") or
               Open77.input.isActionJustPressed("Use") or
               Open77.input.isActionJustPressed("UI_Apply") then
                return true
            end
        end
    end
    if IsControlJustPressed and (IsControlJustPressed(0, 38) or IsControlJustPressed(0, 51)) then
        return true
    end
    return false
end

-- Procura mobília interativa mais próxima
CreateThread(function()
    while true do
        Wait(350)
        local px, py, pz = getPlayerCoords()

        if px and exports["ls_housing"]:isInsideApartment() then
            nearbyInteractiveItem = nil
            for _, item in ipairs(activeFurniture) do
                local template = item.data
                if template and template.interaction then
                    local dx = px - item.x
                    local dy = py - item.y
                    local dz = pz - item.z
                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                    if dist <= 2.2 then
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
        if nearbyInteractiveItem then
            Wait(100)
            if isInteractActionPressed() then
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
            Wait(500)
        end
    end
end)
