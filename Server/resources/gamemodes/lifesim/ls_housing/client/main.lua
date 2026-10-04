--[[
    LIFESIM RP - Housing Client Lifecycle & Apartment Navigation
    Path: ls_housing/client/main.lua
    
    Gerencia:
    1. Superfície WebUI para o terminal residencial (informações, locação e compra).
    2. Detecção de proximidade de portas externas e portas internas.
    3. Notificações de feedback diegético Kiroshi.
]]

local page = nil
local webUiReady = false
local currentApartment = nil
local isInsideApartment = false
local currentBucketId = 0
local nearbyDoorApt = nil
local nearInteriorExit = false
local nearbyDoorIndex = nil  -- Qual porta da lista está próxima
local entryDoorIndex = nil   -- Qual porta o jogador usou para entrar

-- =============================================================================
-- HELPER: Normaliza doorCoords (objeto único OU array) em lista uniforme
-- =============================================================================
local function getDoorList(apt)
    local d = apt.doorCoords
    if not d then return {} end
    -- Se o primeiro elemento é uma tabela com .x, é um array de portas
    if d[1] and type(d[1]) == "table" and d[1].x then
        return d
    end
    -- Objeto único (formato legado): empacota em array
    if d.x then
        return { d }
    end
    return {}
end

-- =============================================================================
-- INICIALIZAÇÃO DA WEBUI
-- =============================================================================

local function createHousingPage()
    if page then return end

    local errorMessage
    page, errorMessage = WebUI.create({
        entry = "web/index.html",
        layer = "menu",
        width = 1920,
        height = 1080,
        fps = 60,
        zIndex = 9999,
        transparent = true,
        visible = true
    })

    if not page then
        Open77.log.error("[ls_housing] Falha ao criar WebUI de Housing: " .. tostring(errorMessage))
        return
    end

    page:on("ls:housing:ready", function()
        webUiReady = true
        Open77.log.info("[ls_housing] WebUI de habitação pronta e conectada.")
    end)

    page:on("housing:rent", function(payload)
        if payload and payload.aptId then
            TriggerServerEvent("ls:housing:rent", payload.aptId, nearbyDoorIndex or 1)
        end
    end)

    page:on("housing:buy", function(payload)
        if payload and payload.aptId then
            TriggerServerEvent("ls:housing:buy", payload.aptId, nearbyDoorIndex or 1)
        end
    end)

    page:on("housing:enter", function(payload)
        if payload and payload.aptId then
            if page then
                page:send("housing:close")
                page:setFocus(false, false)
                page:hide()
            end
            TriggerEvent("ls:ui:modalStateChanged", false)
            TriggerServerEvent("ls:housing:enter", payload.aptId, nearbyDoorIndex or 1)
        end
    end)

    page:on("housing:close", function()
        if page then
            page:send("housing:close")
            page:setFocus(false, false)
            page:hide()
        end
        TriggerEvent("ls:ui:modalStateChanged", false)
        if not isInsideApartment then
            registerDoorInteractions()
        end
    end)

    page:on("housing:openBuildMode", function()
        if page then
            page:send("housing:close")
            page:setFocus(false, false)
            page:hide()
        end
        TriggerEvent("ls:ui:modalStateChanged", false)
        TriggerEvent("ls:housing:startBuildMode")
    end)
end

local createdWorldMarkers = {}
local createdWorldPois = {}

local function clearDoorInteractions()
    for _, markerId in ipairs(createdWorldMarkers) do
        pcall(function()
            if Open77.markers and Open77.markers.remove then
                Open77.markers.remove(markerId)
            end
        end)
    end
    createdWorldMarkers = {}

    for _, poiHandle in ipairs(createdWorldPois) do
        pcall(function()
            Open77.exports.call("open77_worldui", "remove", poiHandle)
        end)
    end
    createdWorldPois = {}
end

local function registerDoorInteractions()
    clearDoorInteractions()

    for _, apt in ipairs(Config.Apartments or {}) do
        local doors = getDoorList(apt)
        for doorIdx, d in ipairs(doors) do
            if d and d.x and d.y and d.z then
                -- 1. Criação do anel holográfico de chão 3D via Open77.markers nativo
                pcall(function()
                    if Open77.markers and Open77.markers.create then
                        local markerId, err = Open77.markers.create({
                            position = { x = d.x, y = d.y, z = d.z + 0.05 },
                            shape = "ring",
                            style = "objective",
                            radius = 1.6,
                            maxDistance = 45.0,
                            color = { 0, 255, 157, 210 }
                        })
                        if markerId then
                            createdWorldMarkers[#createdWorldMarkers + 1] = markerId
                        end
                    end
                end)

                -- 2. Registro do card de interação diegético via open77_worldui
                local doorLabel = d.label or apt.name
                pcall(function()
                    local promise = Open77.exports.call("open77_worldui", "create", {
                        id = "housing_door_" .. apt.id .. "_" .. doorIdx,
                        position = { x = d.x, y = d.y, z = d.z },
                        radius = d.radius or 2.5,
                        style = "objective",
                        label = doorLabel,
                        description = "Terminal Residencial // " .. (apt.badge or "APARTAMENTO"),
                        key = "E",
                        color = "#00FF9D",
                        icon = "DIALOG",
                        event = "ls:housing:openDoorTarget",
                        args = { aptId = apt.id, doorIndex = doorIdx }
                    })
                    if promise and promise.await then
                        CreateThread(function()
                            local res = promise:await()
                            if res and res.ok and res.handle then
                                createdWorldPois[#createdWorldPois + 1] = res.handle
                            end
                        end)
                    end
                end)
            end
        end
    end
end

local function registerInteriorExitInteraction(apt)
    clearDoorInteractions()
    if not apt then return end
    local inExit = apt.interiorExitCoords or apt.interiorCoords
    if not inExit or not inExit.x then return end

    -- 1. Anel holográfico de chão 3D no interior (indicando o portal de saída)
    pcall(function()
        if Open77.markers and Open77.markers.create then
            local markerId, err = Open77.markers.create({
                position = { x = inExit.x, y = inExit.y, z = inExit.z + 0.05 },
                shape = "ring",
                style = "objective",
                radius = 1.6,
                maxDistance = 25.0,
                color = { 255, 71, 87, 210 }
            })
            if markerId then
                createdWorldMarkers[#createdWorldMarkers + 1] = markerId
            end
        end
    end)

    -- 2. Card de interação diegético via open77_worldui
    pcall(function()
        local promise = Open77.exports.call("open77_worldui", "create", {
            id = "housing_exit_" .. tostring(apt.id),
            position = { x = inExit.x, y = inExit.y, z = inExit.z },
            radius = 2.5,
            style = "objective",
            label = "Porta de Saída",
            description = "Retornar ao corredor // " .. tostring(apt.building or "Edifício"),
            key = "E",
            color = "#FF4757",
            icon = "LOGOUT",
            event = "ls:housing:clientTriggerExit",
            args = { aptId = apt.id }
        })
        if promise and promise.await then
            CreateThread(function()
                local res = promise:await()
                if res and res.ok and res.handle then
                    createdWorldPois[#createdWorldPois + 1] = res.handle
                end
            end)
        end
    end)
end

RegisterNetEvent("ls:housing:clientTriggerExit", function(args)
    if isInsideApartment and currentApartment then
        Open77.log.info("[ls_housing] Saída acionada via WorldUI de: " .. tostring(currentApartment.name))
        TriggerServerEvent("ls:housing:exit", currentApartment.id, entryDoorIndex or 1)
    end
end)

RegisterNetEvent("ls:housing:openDoorTarget", function(args)
    local aptId = nil
    if type(args) == "table" then
        aptId = args.aptId or args.id
        if not aptId and args.interactionId then
            aptId = tostring(args.interactionId):match("housing_door_([%w_]+)")
        end
    elseif type(args) == "string" then
        aptId = args:match("housing_door_([%w_]+)") or args
    end

    if not aptId and nearbyDoorApt then
        aptId = nearbyDoorApt.id
    end

    if aptId then
        Open77.log.info("[ls_housing] Interagindo com terminal residencial via WorldUI: " .. tostring(aptId))
        TriggerServerEvent("ls:housing:requestInfo", aptId)
    else
        Open77.log.warn("[ls_housing] Evento openDoorTarget recebido sem aptId resolúvel: " .. tostring(args))
    end
end)

AddEventHandler("onClientResourceStart", function(name)
    if name ~= GetCurrentResourceName() then return end
    createHousingPage()
    registerDoorInteractions()
end)

AddEventHandler("onClientResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    clearDoorInteractions()
end)

-- =============================================================================
-- PROXIMIDADE DE PORTAS E ENTRADA/SAÍDA
-- =============================================================================

local function getLocalCoords()
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

CreateThread(function()
    while true do
        Wait(250)
        local px, py, pz = getLocalCoords()

        if px and not isInsideApartment then
            nearbyDoorApt = nil
            nearbyDoorIndex = nil
            for _, apt in ipairs(Config.Apartments or {}) do
                local doors = getDoorList(apt)
                for doorIdx, d in ipairs(doors) do
                    local dx = px - d.x
                    local dy = py - d.y
                    local dz = pz - d.z
                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                    if dist <= (d.radius or 2.5) then
                        nearbyDoorApt = apt
                        nearbyDoorIndex = doorIdx
                        break
                    end
                end
                if nearbyDoorApt then break end
            end
        elseif px and isInsideApartment and currentApartment then
            local inExit = currentApartment.interiorExitCoords or currentApartment.interiorCoords
            local dx = px - inExit.x
            local dy = py - inExit.y
            local dz = pz - inExit.z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
            nearInteriorExit = dist <= 2.5
        else
            nearbyDoorApt = nil
            nearbyDoorIndex = nil
            nearInteriorExit = false
        end
    end
end)

-- Tecla [E] para interagir com a porta ou saída (fallback de proximidade direta com detecção de transição)
CreateThread(function()
    local wasPressed = false
    while true do
        Wait(15)
        local isPressed = isInteractActionPressed()

        if isPressed and not wasPressed then
            if nearbyDoorApt and not isInsideApartment then
                Open77.log.info("[ls_housing] Tecla [E] pressionada na porta de: " .. tostring(nearbyDoorApt.name) .. " (porta #" .. tostring(nearbyDoorIndex or 1) .. ")")
                TriggerServerEvent("ls:housing:requestInfo", nearbyDoorApt.id)
                Wait(400)
            elseif nearInteriorExit and isInsideApartment and currentApartment then
                Open77.log.info("[ls_housing] Tecla [E] pressionada para sair de: " .. tostring(currentApartment.name))
                TriggerServerEvent("ls:housing:exit", currentApartment.id, entryDoorIndex or 1)
                Wait(400)
            end
        end
        wasPressed = isPressed
    end
end)

-- =============================================================================
-- EVENTOS DE REDE
-- =============================================================================

RegisterNetEvent("ls:housing:receiveInfo", function(data)
    if not page then createHousingPage() end
    if page then
        -- Oculta os marcadores 3D e cards WorldUI enquanto o modal de habitação estiver aberto
        clearDoorInteractions()
        page:show()
        page:setFocus(true, true)
        page:send("housing:showInfo", data)
        TriggerEvent("ls:ui:modalStateChanged", true)
    end
end)

RegisterNetEvent("ls:housing:enteredApartment", function(data)
    currentApartment = data.apartment
    currentBucketId = data.bucketId
    isInsideApartment = true
    entryDoorIndex = data.entryDoorIndex or 1

    -- Fecha o modal e limpa os marcadores de porta externa
    if page then
        page:send("housing:close")
        page:setFocus(false, false)
        page:hide()
    end
    TriggerEvent("ls:ui:modalStateChanged", false)
    registerInteriorExitInteraction(data.apartment)

    -- Teleporte nativo autoritativo no cliente via Open77.travel
    if data and data.apartment and data.apartment.interiorCoords then
        local inC = data.apartment.interiorCoords
        pcall(function()
            if Open77.travel and Open77.travel.teleport then
                Open77.travel.teleport(inC.x + 0.0, inC.y + 0.0, inC.z + 0.0, (inC.heading or 0.0) + 0.0)
            end
        end)
    end

    TriggerEvent("ls:housing:onEnter", data)
    Open77.log.info("[ls_housing] Entrou no interior instanciado de " .. data.apartment.name)
end)

RegisterNetEvent("ls:housing:exitedApartment", function(data)
    TriggerEvent("ls:housing:onExit", currentApartment)
    currentApartment = nil
    currentBucketId = 0
    isInsideApartment = false
    entryDoorIndex = nil

    -- Teleporte nativo autoritativo no cliente via Open77.travel de volta para a porta externa
    if data and data.doorCoords then
        local d = data.doorCoords
        pcall(function()
            if Open77.travel and Open77.travel.teleport then
                Open77.travel.teleport(d.x + 0.0, d.y + 0.0, d.z + 0.0, (d.heading or 0.0) + 0.0)
            end
        end)
    end

    -- Restaura os marcadores e prompts de porta no mundo aberto
    registerDoorInteractions()

    Open77.log.info("[ls_housing] Retornou ao mundo aberto.")
end)

RegisterNetEvent("ls:housing:feedback", function(data)
    if page then
        page:send("housing:feedback", data)
    end
    Open77.log.info(("[ls_housing] Feedback: %s (Sucesso: %s)"):format(
        tostring(data and data.message), tostring(data and data.success)
    ))
end)

-- Comando de chat /housing para abrir menu do imóvel quando dentro dele
RegisterCommand("housing", function()
    if isInsideApartment and currentApartment then
        TriggerServerEvent("ls:housing:requestInfo", currentApartment.id)
    elseif nearbyDoorApt then
        TriggerServerEvent("ls:housing:requestInfo", nearbyDoorApt.id)
    end
end)

exports("isInsideApartment", function()
    return isInsideApartment
end)

exports("getCurrentApartment", function()
    return currentApartment
end)
