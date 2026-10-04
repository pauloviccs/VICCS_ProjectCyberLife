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

    -- Padrão oficial Open77 para marcadores de habitação com suporte a rota GPS:
    local payload = {
        position = options.position,
        sprite = options.sprite or "fast_travel",
        title = options.title,
        description = options.description,
        color = options.color or "#00FF9D",
        active = true,
        visibleThroughWalls = false,
        routable = true
    }

    -- 1. Tentativa com sprite primário
    local id, err = Open77.blips.create(payload)
    if id ~= nil then return id end

    -- 2. Tentativa com fallback especializado (objective)
    payload.sprite = fallbackSprite or "objective"
    id, err = Open77.blips.create(payload)
    if id ~= nil then return id end

    -- 3. Fallback universal
    payload.sprite = "fast_travel"
    id, err = Open77.blips.create(payload)
    return id, err
end

-- =============================================================================
-- GERENCIAMENTO DE BLIPS RESIDENCIAIS
-- =============================================================================

--- Normaliza doorCoords (objeto único OU array de portas) em uma lista uniforme
local function getDoorList(apt)
    local d = apt and apt.doorCoords
    if not d then return {} end
    if d[1] and type(d[1]) == "table" and d[1].x then
        return d
    end
    if d.x then
        return { d }
    end
    return {}
end

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
        local doors = getDoorList(apt)
        for doorIdx, d in ipairs(doors) do
            if d and d.x and d.y and d.z then
                -- Paleta diegética por complexo/tier
                local blipColor = d.blipColor or "#00FF9D" -- Padrão: Verde Kiroshi
                if not d.blipColor then
                    if apt.id == "japantown_loft" then
                        blipColor = "#FCEE0A" -- Amarelo Néon Japantown
                    elseif apt.id == "corpo_plaza_suite" then
                        blipColor = "#FF003C" -- Vermelho Néon Arasaka
                    elseif apt.id == "glen_studio" then
                        blipColor = "#00D0FF" -- Ciano Heywood
                    end
                end

                local doorTitle = apt.name or "Residencial Night City"
                if #doors > 1 and d.label then
                    doorTitle = ("%s - %s"):format(apt.name or "Residencial", d.label)
                end

                local blipDesc = ("%s // %s\nAluguel: E$ %d | Aquisição: E$ %d"):format(
                    apt.building or "Complexo Habitacional",
                    apt.badge or "RESIDÊNCIA",
                    apt.rentPrice or 0,
                    apt.buyPrice or 0
                )

                local id = createNativeBlip({
                    position = { x = d.x, y = d.y, z = d.z },
                    sprite = "fast_travel",
                    title = doorTitle,
                    description = blipDesc,
                    color = blipColor,
                    routable = true
                }, "objective")

                if id then
                    createdBlips[#createdBlips + 1] = id
                    count = count + 1
                end
            end
        end
    end

    blipsInitialized = count > 0
    Open77.log.info(("[ls_housing] Sincronização de Blips concluída: %d pontos de entrada mapeados no GPS."):format(
        count
    ))
end

-- =============================================================================
-- WATCHDOG E CICLO DE VIDA
-- =============================================================================

AddEventHandler("open77:worldReady", function()
    spawnHousingBlips(true)
end)

CreateThread(function()
    Wait(3000)
    spawnHousingBlips(false)

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
