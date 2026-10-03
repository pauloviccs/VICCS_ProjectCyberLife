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

-- =============================================================================
-- INICIALIZAÇÃO DA WEBUI
-- =============================================================================

local function createHousingPage()
    if page then return end

    local errorMessage
    page, errorMessage = WebUI.create({
        entry = "web/index.html",
        layer = "hud",
        width = 1920,
        height = 1080,
        fps = 60,
        zIndex = 800,
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
            TriggerServerEvent("ls:housing:rent", payload.aptId)
        end
    end)

    page:on("housing:buy", function(payload)
        if payload and payload.aptId then
            TriggerServerEvent("ls:housing:buy", payload.aptId)
        end
    end)

    page:on("housing:enter", function(payload)
        if payload and payload.aptId then
            if page then
                page:send("housing:close")
                page:setFocus(false, false)
            end
            TriggerServerEvent("ls:housing:enter", payload.aptId)
        end
    end)

    page:on("housing:close", function()
        if page then
            page:send("housing:close")
            page:setFocus(false, false)
        end
        TriggerEvent("ls:ui:modalStateChanged", false)
    end)

    page:on("housing:openBuildMode", function()
        if page then
            page:send("housing:close")
            page:setFocus(false, false)
        end
        TriggerEvent("ls:housing:startBuildMode")
    end)
end

local function registerDoorInteractions()
    if not exports["open77_interactions"] then return end
    for _, apt in ipairs(Config.Apartments or {}) do
        local d = apt.doorCoords
        if d and d.x and d.y and d.z then
            pcall(function()
                exports["open77_interactions"]:addSphereZone({
                    id = "housing_door_" .. apt.id,
                    position = { x = d.x, y = d.y, z = d.z },
                    radius = d.radius or 2.5,
                    marker = "ring",
                    color = "#00FF9D",
                    markerDistance = 10.0,
                    choices = {
                        {
                            id = "access_apt_" .. apt.id,
                            label = apt.name .. " (Terminal Residencial)",
                            key = "E",
                            event = "ls:housing:openDoorTarget",
                            args = { aptId = apt.id },
                            color = "#00FF9D"
                        }
                    }
                })
            end)
        end
    end
end

RegisterNetEvent("ls:housing:openDoorTarget", function(args)
    local aptId = (type(args) == "table" and args.aptId) or args
    if aptId then
        TriggerServerEvent("ls:housing:requestInfo", aptId)
    end
end)

AddEventHandler("onClientResourceStart", function(name)
    if name ~= GetCurrentResourceName() then return end
    createHousingPage()
    registerDoorInteractions()
end)

-- =============================================================================
-- PROXIMIDADE DE PORTAS E ENTRADA/SAÍDA
-- =============================================================================

CreateThread(function()
    while true do
        Wait(400)
        local ped = PlayerPedId and PlayerPedId() or -1
        local pPos = GetEntityCoords and GetEntityCoords(ped) or nil

        if pPos and not isInsideApartment then
            nearbyDoorApt = nil
            for _, apt in ipairs(Config.Apartments) do
                local d = apt.doorCoords
                local dist = #(vector3(pPos.x, pPos.y, pPos.z) - vector3(d.x, d.y, d.z))
                if dist <= (d.radius or 2.5) then
                    nearbyDoorApt = apt
                    break
                end
            end
        elseif pPos and isInsideApartment and currentApartment then
            local inCoords = currentApartment.interiorCoords
            local dist = #(vector3(pPos.x, pPos.y, pPos.z) - vector3(inCoords.x, inCoords.y, inCoords.z))
            nearInteriorExit = dist <= 2.2
        else
            nearbyDoorApt = nil
            nearInteriorExit = false
        end
    end
end)

-- Tecla [E] para interagir com a porta ou saída (fallback de proximidade direta)
CreateThread(function()
    while true do
        Wait(5)
        if nearbyDoorApt and not isInsideApartment then
            if IsControlJustPressed and (IsControlJustPressed(0, 38) or IsControlJustPressed(0, 51)) then
                TriggerServerEvent("ls:housing:requestInfo", nearbyDoorApt.id)
            end
        elseif nearInteriorExit and isInsideApartment and currentApartment then
            if IsControlJustPressed and (IsControlJustPressed(0, 38) or IsControlJustPressed(0, 51)) then
                TriggerServerEvent("ls:housing:exit", currentApartment.id)
            end
        else
            Wait(150)
        end
    end
end)

-- =============================================================================
-- EVENTOS DE REDE
-- =============================================================================

RegisterNetEvent("ls:housing:receiveInfo", function(data)
    if not page then createHousingPage() end
    if page then
        page:setFocus(true, true)
        page:send("housing:showInfo", data)
        TriggerEvent("ls:ui:modalStateChanged", true)
    end
end)

RegisterNetEvent("ls:housing:enteredApartment", function(data)
    currentApartment = data.apartment
    currentBucketId = data.bucketId
    isInsideApartment = true

    TriggerEvent("ls:housing:onEnter", data)
    Open77.log.info("[ls_housing] Entrou no interior instanciado de " .. data.apartment.name)
end)

RegisterNetEvent("ls:housing:exitedApartment", function(data)
    TriggerEvent("ls:housing:onExit", currentApartment)
    currentApartment = nil
    currentBucketId = 0
    isInsideApartment = false

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
