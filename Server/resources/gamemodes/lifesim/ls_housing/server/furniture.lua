--[[
    LIFESIM RP - Housing Furniture & PolyZone Placement Server Logic
    Path: ls_housing/server/furniture.lua
    
    Gerencia:
    1. Validação autoritativa de colocação de mobílias dentro do PolyZone do interior.
    2. Cobrança e estorno de mobílias integrados ao ls_economy.
    3. Persistência em ls_apartment_furniture e broadcast no routing bucket.
    4. Interações diegéticas funcionais (Cama -> Vitais, Chuveiro -> Higiene).
]]

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

local function findFurnitureCatalogItem(templateId)
    for _, item in ipairs(Config.FurnitureCatalog) do
        if item.id == templateId then
            return item
        end
    end
    return nil
end

local function findApartmentConfig(aptId)
    for _, apt in ipairs(Config.Apartments) do
        if apt.id == aptId then
            return apt
        end
    end
    return nil
end

---Valida se as 4 quinas do móvel orientado estão dentro do PolyZone do apartamento
local function isInsideApartmentBounds(apt, x, y, z, heading, width, length, height)
    if not apt or not apt.polyzone then return false, "no_zone" end

    -- 1. Checa limites verticais (Piso e Teto)
    if z < apt.polyzone.minZ or (z + height) > apt.polyzone.maxZ then
        return false, "vertical_bound_exceeded"
    end

    -- 2. Calcula os 4 vértices do Oriented Bounding Box (OBB)
    local w2 = (width or 1.0) / 2.0
    local l2 = (length or 1.0) / 2.0
    local rad = math.rad(heading or 0.0)
    local cosR, sinR = math.cos(rad), math.sin(rad)

    local corners = {
        { x = x + w2 * cosR - l2 * sinR, y = y + w2 * sinR + l2 * cosR },
        { x = x - w2 * cosR - l2 * sinR, y = y - w2 * sinR + l2 * cosR },
        { x = x - w2 * cosR + l2 * sinR, y = y - w2 * sinR - l2 * cosR },
        { x = x + w2 * cosR + l2 * sinR, y = y + w2 * sinR - l2 * cosR }
    }

    local pts = apt.polyzone.points
    for i = 1, 4 do
        if not isPointInPolygon(corners[i].x, corners[i].y, pts) then
            return false, "corner_outside_walls"
        end
    end

    return true, nil
end

-- =============================================================================
-- COLOCAÇÃO DE MOBÍLIA (BUILD MODE)
-- =============================================================================

RegisterNetEvent("ls:housing:placeFurniture", function(aptId, templateId, coords, heading)
    local playerId = source
    CreateThread(function()
        local license = exports["ls_core"]:getPlayerLicense(playerId)
        if not license then return end

        local loc = Housing.playerLocations[playerId]
        if not loc or loc.aptId ~= aptId or loc.ownerLicense ~= license then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Permissão negada: você só pode mobiliar seus próprios imóveis."
            })
            return
        end

        local apt = findApartmentConfig(aptId)
        local template = findFurnitureCatalogItem(templateId)
        if not apt or not template then return end

        -- 1. Verifica limite de peças
        local countRows = Database.query(
            "SELECT COUNT(*) as total FROM ls_apartment_furniture WHERE apartment_id = ? AND owner_license = ?",
            { aptId, license }
        )
        local currentCount = (countRows and countRows[1] and countRows[1].total) or 0
        if currentCount >= apt.maxFurniture then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = ("Capacidade máxima de mobília atingida (%d/%d peças)."):format(currentCount, apt.maxFurniture)
            })
            return
        end

        -- 2. Validação matemática via PolyZone OBB
        local dim = template.dimensions
        local valid, reason = isInsideApartmentBounds(
            apt, coords.x, coords.y, coords.z, heading, dim.width, dim.length, dim.height
        )
        if not valid then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Posição inválida: o móvel colide com as paredes do apartamento."
            })
            return
        end

        -- 3. Débito da mobília (Banco com fallback para Carteira)
        local ok, err = exports["ls_economy"]:removeBank(playerId, template.price, "Mobília: " .. template.name)
        if not ok then
            ok, err = exports["ls_economy"]:removeCash(playerId, template.price, "Mobília (Dinheiro Vivo): " .. template.name)
        end
        if not ok then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Saldo insuficiente para mobília (E$ " .. template.price .. ")."
            })
            return
        end

        -- 4. Insere no MariaDB
        local _, insertErr = Database.update([[
            INSERT INTO ls_apartment_furniture (apartment_id, owner_license, template_id, x, y, z, heading, data)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ]], { aptId, license, templateId, coords.x, coords.y, coords.z, heading, json.encode(template) })

        if insertErr then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Erro de gravação no banco de dados."
            })
            return
        end

        -- Busca o ID gerado
        local lastIdRow = Database.query("SELECT LAST_INSERT_ID() as id")
        local newId = lastIdRow and lastIdRow[1] and lastIdRow[1].id

        local furnitureItem = {
            id = newId,
            template_id = templateId,
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading,
            data = template
        }

        -- Notifica todos os ocupantes do mesmo routing bucket
        local instKey = loc.ownerLicense .. "_" .. loc.aptId
        local inst = Housing.activeInstances[instKey]
        if inst and inst.occupants then
            for occupantId in pairs(inst.occupants) do
                TriggerClientEvent("ls:housing:furnitureAdded", occupantId, furnitureItem)
            end
        end

        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = true,
            message = template.name .. " instalado com sucesso!"
        })

        Open77.log.info(("[ls_housing] Jogador %d posicionou mobília '%s' (ID %d) no apto %s."):format(playerId, template.name, newId or 0, aptId))
    end)
end)

-- =============================================================================
-- REMOÇÃO DE MOBÍLIA (COM REEMBOLSO PARCIAL)
-- =============================================================================

RegisterNetEvent("ls:housing:removeFurniture", function(aptId, furnitureId)
    local playerId = source
    CreateThread(function()
        local license = exports["ls_core"]:getPlayerLicense(playerId)
        if not license then return end

        local loc = Housing.playerLocations[playerId]
        if not loc or loc.aptId ~= aptId or loc.ownerLicense ~= license then return end

        -- Busca o item para calcular reembolso de 50%
        local rows = Database.query(
            "SELECT id, template_id FROM ls_apartment_furniture WHERE id = ? AND owner_license = ? AND apartment_id = ? LIMIT 1",
            { furnitureId, license, aptId }
        )
        if not rows or #rows == 0 then return end

        local template = findFurnitureCatalogItem(rows[1].template_id)
        local refundAmount = template and math.floor(template.price * 0.5) or 0

        Database.update("DELETE FROM ls_apartment_furniture WHERE id = ?", { furnitureId })

        if refundAmount > 0 then
            exports["ls_economy"]:addBank(playerId, refundAmount, "Reciclagem de Mobília")
        end

        local instKey = loc.ownerLicense .. "_" .. loc.aptId
        local inst = Housing.activeInstances[instKey]
        if inst and inst.occupants then
            for occupantId in pairs(inst.occupants) do
                TriggerClientEvent("ls:housing:furnitureRemoved", occupantId, furnitureId)
            end
        end

        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = true,
            message = "Mobília reciclada. Reembolso de E$ " .. refundAmount .. " creditado na conta."
        })
    end)
end)

-- =============================================================================
-- INTERAÇÕES FUNCIONAIS (VITALS RECOVERY)
-- =============================================================================

RegisterNetEvent("ls:housing:useBed", function(templateId)
    local playerId = source
    local template = findFurnitureCatalogItem(templateId)
    if not template or not template.interaction or template.interaction.type ~= "bed" then return end

    -- Restaura energia e alivia estresse no ls_vitals
    pcall(function()
        local v = exports["ls_vitals"]:getVitals() -- se chamado via export no player
        -- Invoca evento de consumo/regeneração biológica
        TriggerEvent("ls:vitals:boostEnergy", playerId, template.interaction.energyRegenPerSec or 3.0)
    end)
end)

RegisterNetEvent("ls:housing:useShower", function()
    local playerId = source
    pcall(function()
        -- Restaura higiene a 100%
        TriggerEvent("ls:vitals:setHygiene", playerId, 100.0)
    end)
    TriggerClientEvent("ls:housing:feedback", playerId, {
        success = true,
        message = "Banho sônico concluído. Higiene e assepsia 100% restauradas."
    })
end)
