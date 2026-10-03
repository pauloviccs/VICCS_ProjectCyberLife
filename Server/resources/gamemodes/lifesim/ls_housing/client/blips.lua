--[[
    LIFESIM RP - Housing Map Blips Manager
    Path: ls_housing/client/blips.lua
    
    Gera e gerencia marcadores nativos no mapa mundial (Open77.blips) para todos os
    apartamentos e complexos residenciais cadastrados em Config.Apartments.
]]

local createdBlips = {}
local blipsInitialized = false
local lastSyncTimestamp = 0
local isSyncing = false

-- =============================================================================
-- CRIAÇÃO ROBUSTA DE BLIP COM FALLBACKS
-- =============================================================================

local function createNativeBlip(options, fallbackSprite)
    if type(Open77.blips) ~= "table" or type(Open77.blips.create) ~= "function" then
        return nil, "blips_backend_unavailable"
    end

    -- REGRA DA DOCUMENTAÇÃO OFICIAL OPEN//77:
    -- routable=false (Mappins.DefaultStaticMappin) para marcadores de POI/serviço no mapa.
    local payload = {
        position = options.position,
        sprite = options.sprite or "apartment",
        title = options.title,
        description = options.description,
        color = options.color or "#00FF9D",
        active = true,
        visibleThroughWalls = false,
        routable = false
    }

    -- 1. Tentativa com sprite primário
    local id, err = Open77.blips.create(payload)
    if id ~= nil then return id end

    -- 2. Tentativa com fallback especializado
    if fallbackSprite and fallbackSprite ~= payload.sprite then
        payload.sprite = fallbackSprite
        id, err = Open77.blips.create(payload)
        if id ~= nil then return id end
    end

    -- 3. Fallback universal garantido (tech)
    payload.sprite = "tech"
    id, err = Open77.blips.create(payload)
    return id, err
end

-- =============================================================================
-- GERENCIAMENTO DE BLIPS RESIDENCIAIS
-- =============================================================================

local function clearAllBlips()
    for _, id in ipairs(createdBlips) do
        pcall(function()
            if Open77.blips and Open77.blips.remove then
                Open77.blips.remove(id)
            end
        end)
    end
    createdBlips = {}
    blipsInitialized = false
end

local function spawnHousingBlips(force)
    if blipsInitialized and #createdBlips > 0 and not force then return end
    if not Config.Apartments or #Config.Apartments == 0 then return end

    clearAllBlips()
    local count = 0

    for _, apt in ipairs(Config.Apartments) do
        local d = apt.doorCoords
        if d and d.x and d.y and d.z then
            -- Paleta diegética por complexo/tier
            local blipColor = "#00FF9D" -- Padrão: Verde Kiroshi
            if apt.id == "japantown_loft" then
                blipColor = "#FCEE0A" -- Amarelo Néon Japantown
            elseif apt.id == "corpo_plaza_suite" then
                blipColor = "#FF003C" -- Vermelho Néon Arasaka
            elseif apt.id == "glen_studio" then
                blipColor = "#00D0FF" -- Ciano Heywood
            end

            local blipDesc = ("%s // %s\nAluguel: E$ %d | Aquisição: E$ %d"):format(
                apt.building or "Complexo Habitacional",
                apt.badge or "RESIDÊNCIA",
                apt.rentPrice or 0,
                apt.buyPrice or 0
            )

            local id = createNativeBlip({
                position = { x = d.x, y = d.y, z = d.z },
                sprite = "apartment",
                title = apt.name or "Residencial Night City",
                description = blipDesc,
                color = blipColor,
                routable = false
            }, "service_point")

            if id then
                createdBlips[#createdBlips + 1] = id
                count = count + 1
            end
        end
    end

    blipsInitialized = count > 0
    Open77.log.info(("[ls_housing] Sincronização de Blips concluída: %d/%d complexos mapeados no GPS."):format(
        count, #Config.Apartments
    ))
end

-- =============================================================================
-- WATCHDOG E CICLO DE VIDA
-- =============================================================================

CreateThread(function()
    Wait(2000)
    spawnHousingBlips(true)

    while true do
        Wait(10000)
        -- Se por algum motivo o subsistema de blips reiniciar ou a lista zerar, restaura os pins
        if not isSyncing and (#createdBlips == 0 or not blipsInitialized) then
            isSyncing = true
            spawnHousingBlips(true)
            isSyncing = false
        end
    end
end)

AddEventHandler("onClientResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    clearAllBlips()
end)

-- Export útil para forçar sincronização
exports("refreshBlips", function()
    spawnHousingBlips(true)
    return #createdBlips
end)
