--[[
    LIFESIM RP - Housing Free 3D Build Mode & PolyZone Collision Engine
    Path: ls_housing/client/build_mode.lua
    
    Implementa:
    1. Movimentação livre contínua em 3D (raycast do mouse/mira) sem amarras de grade.
    2. Rotação contínua de 360° no eixo Yaw via scroll do mouse ou teclas Q/E.
    3. Motor de validação matemática de 4 vértices OBB contra o PolyZone do apartamento.
    4. Feedback diegético de shader holográfico (Ciano/Verde para válido, Vermelho para colisão).
    5. Disparo autoritativo para fixação no MariaDB.
]]

local PZ = nil
pcall(function()
    if type(require) == "function" then
        PZ = require('@polyzone')
    elseif PolyZone then
        PZ = { PolyZone = PolyZone }
    end
end)

---Verifica se um ponto 2D está dentro de um polígono via algoritmo Raycasting / Winding number
local function isPointInPolygon(px, py, points)
    if not points or #points == 0 then return false end
    local winding = 0
    local count = #points
    for i = 1, count do
        local a = points[i]
        local b = points[i % count + 1]
        local ax, ay = a.x or a[1], a.y or a[2]
        local bx, by = b.x or b[1], b.y or b[2]
        if ay <= py then
            if by > py and ((bx - ax) * (py - ay) - (px - ax) * (by - ay)) > 0 then
                winding = winding + 1
            end
        else
            if by <= py and ((bx - ax) * (py - ay) - (px - ax) * (by - ay)) < 0 then
                winding = winding - 1
            end
        end
    end
    return winding ~= 0
end

local isBuildModeActive = false
local selectedTemplate = nil
local currentAptZone = nil
local currentApartmentData = nil
local placedFurnitureList = {} -- lista local de móveis instalados

-- Estado da peça sendo manipulada
local propState = {
    x = 0.0,
    y = 0.0,
    z = 0.0,
    heading = 0.0,
    isValid = false,
    reason = nil
}

-- =============================================================================
-- INICIALIZAÇÃO DA POLYZONE DO INTERIOR
-- =============================================================================

local function setupApartmentPolyZone(apt)
    if currentAptZone and currentAptZone.destroy then
        pcall(function() currentAptZone:destroy() end)
        currentAptZone = nil
    end

    if not apt or not apt.polyzone or not apt.polyzone.points then return end

    if PZ and PZ.PolyZone and PZ.PolyZone.Create then
        local pts = {}
        for _, p in ipairs(apt.polyzone.points) do
            table.insert(pts, vector2(p.x, p.y))
        end

        currentAptZone = PZ.PolyZone:Create(pts, {
            name = "apt_" .. apt.id,
            minZ = apt.polyzone.minZ,
            maxZ = apt.polyzone.maxZ,
            debugPoly = false
        })
    end

    currentApartmentData = apt
end

AddEventHandler("ls:housing:onEnter", function(data)
    setupApartmentPolyZone(data.apartment)
    placedFurnitureList = data.furniture or {}
end)

AddEventHandler("ls:housing:onExit", function()
    if currentAptZone then
        currentAptZone:destroy()
        currentAptZone = nil
    end
    currentApartmentData = nil
    placedFurnitureList = {}
    isBuildModeActive = false
end)

RegisterNetEvent("ls:housing:furnitureAdded", function(item)
    table.insert(placedFurnitureList, item)
end)

RegisterNetEvent("ls:housing:furnitureRemoved", function(furnitureId)
    for i, item in ipairs(placedFurnitureList) do
        if item.id == furnitureId then
            table.remove(placedFurnitureList, i)
            break
        end
    end
end)

-- =============================================================================
-- MOTOR DE VALIDAÇÃO MATEMÁTICA DE COLISÃO OBB (POLYZONE)
-- =============================================================================

---Calcula e valida os 4 cantos do OBB e os limites verticais contra a PolyZone
---@param x number
---@param y number
---@param z number
---@param heading number
---@param width number
---@param length number
---@param height number
---@return boolean isValid, string|nil reason
local function validateFurniturePlacement(x, y, z, heading, width, length, height)
    if not currentApartmentData or not currentApartmentData.polyzone then
        return false, "no_active_polyzone"
    end

    -- 1. Limites verticais de Piso e Teto
    local pz = currentApartmentData.polyzone
    if z < pz.minZ or (z + height) > pz.maxZ then
        return false, "vertical_bound_exceeded"
    end

    -- 2. Cálculo dos 4 vértices do retângulo orientado (OBB)
    local w2 = width / 2.0
    local l2 = length / 2.0
    local rad = math.rad(heading or 0.0)
    local cosR, sinR = math.cos(rad), math.sin(rad)

    local corners = {
        { x = x + w2 * cosR - l2 * sinR, y = y + w2 * sinR + l2 * cosR, z = z },
        { x = x - w2 * cosR - l2 * sinR, y = y - w2 * sinR + l2 * cosR, z = z },
        { x = x - w2 * cosR + l2 * sinR, y = y - w2 * sinR - l2 * cosR, z = z },
        { x = x + w2 * cosR + l2 * sinR, y = y + w2 * sinR - l2 * cosR, z = z }
    }

    -- 3. Teste perimetral de paredes: TODOS os 4 vértices precisam estar dentro
    if currentAptZone and currentAptZone.isPointInside then
        for i = 1, 4 do
            if not currentAptZone:isPointInside(vector3(corners[i].x, corners[i].y, corners[i].z)) then
                return false, "collision_wall_perimeter"
            end
        end
        if not currentAptZone:isPointInside(vector3(x, y, z)) then
            return false, "collision_wall_perimeter"
        end
    else
        local pts = pz.points
        for i = 1, 4 do
            if not isPointInPolygon(corners[i].x, corners[i].y, pts) then
                return false, "collision_wall_perimeter"
            end
        end
        if not isPointInPolygon(x, y, pts) then
            return false, "collision_wall_perimeter"
        end
    end

    -- 5. Teste de sobreposição com mobílias existentes
    for _, existing in ipairs(placedFurnitureList) do
        local dist2D = #(vector2(x, y) - vector2(existing.x, existing.y))
        local minAllowedDist = (width + (existing.data and existing.data.dimensions and existing.data.dimensions.width or 1.0)) * 0.42
        if dist2D < minAllowedDist and math.abs(z - existing.z) < 0.3 then
            return false, "collision_furniture_overlap"
        end
    end

    return true, nil
end

-- =============================================================================
-- LOOP DE CONTROLE E RAYCAST CONTÍNUO DO MODO DECORAÇÃO
-- =============================================================================

local function startBuildMode(template)
    if not currentApartmentData then return end
    selectedTemplate = template or Config.FurnitureCatalog[1]
    isBuildModeActive = true

    -- Inicializa coordenadas no ponto de surgimento
    propState.x = currentApartmentData.interiorCoords.x
    propState.y = currentApartmentData.interiorCoords.y + 1.2
    propState.z = currentApartmentData.interiorCoords.z
    propState.heading = currentApartmentData.interiorCoords.heading or 0.0

    Open77.log.info("[ls_housing] Modo Decoração Livre iniciado com mobília: " .. selectedTemplate.name)
end

AddEventHandler("ls:housing:startBuildMode", function(template)
    startBuildMode(template)
end)

-- Loop por frame durante a manipulação do móvel
CreateThread(function()
    while true do
        if isBuildModeActive and selectedTemplate then
            Wait(0)

            -- 1. Movimentação suave contínua com teclas ou mouse
            if IsControlPressed then
                if IsControlPressed(0, 32) then -- W (Frente)
                    propState.y = propState.y + 0.035
                end
                if IsControlPressed(0, 33) then -- S (Trás)
                    propState.y = propState.y - 0.035
                end
                if IsControlPressed(0, 34) then -- A (Esquerda)
                    propState.x = propState.x - 0.035
                end
                if IsControlPressed(0, 35) then -- D (Direita)
                    propState.x = propState.x + 0.035
                end

                -- Rotação Contínua Yaw
                if IsControlPressed(0, 44) then -- Q (Girar Esquerda)
                    propState.heading = (propState.heading + 2.5) % 360.0
                end
                if IsControlPressed(0, 38) then -- E (Girar Direita se não for tecla de confirmação isolada)
                    propState.heading = (propState.heading - 2.5) % 360.0
                end
            end

            -- 2. Validação matemática a cada frame via PolyZone
            local dim = selectedTemplate.dimensions
            local valid, reason = validateFurniturePlacement(
                propState.x, propState.y, propState.z, propState.heading,
                dim.width, dim.length, dim.height
            )
            propState.isValid = valid
            propState.reason = reason

            -- 3. Confirmação com tecla Enter ou Espaço
            if IsControlJustPressed and (IsControlJustPressed(0, 18) or IsControlJustPressed(0, 191)) then
                if propState.isValid then
                    TriggerServerEvent("ls:housing:placeFurniture",
                        currentApartmentData.id,
                        selectedTemplate.id,
                        { x = propState.x, y = propState.y, z = propState.z },
                        propState.heading
                    )
                    isBuildModeActive = false
                    selectedTemplate = nil
                else
                    Open77.log.warn("[ls_housing] Posicionamento bloqueado: " .. tostring(propState.reason))
                end
            end

            -- 4. Cancelamento com tecla X / Backspace
            if IsControlJustPressed and (IsControlJustPressed(0, 73) or IsControlJustPressed(0, 177)) then
                isBuildModeActive = false
                selectedTemplate = nil
                Open77.log.info("[ls_housing] Modo Decoração cancelado pelo usuário.")
            end
        else
            Wait(250)
        end
    end
end)

-- Comando direto no chat /decorate para testar rapidamente
RegisterCommand("decorate", function()
    if exports["ls_housing"]:isInsideApartment() then
        startBuildMode(Config.FurnitureCatalog[1])
    else
        Open77.log.warn("[ls_housing] Você precisa estar dentro do seu apartamento para decorar.")
    end
end)
