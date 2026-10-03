--[[
    LIFESIM RP - World Map Blips Manager
    Path: ls_economy/client/blips.lua
    Gera marcadores nativos no mapa mundial (Open77.blips) para todos os caixas eletrônicos (ATMs),
    máquinas de conveniência (Vending Machines), clínicas de implantes (Ripperdocs) e mercados de Night City.
]]

local createdBlips = {}
local blipsInitialized = false

-- =============================================================================
-- CRIAÇÃO ROBUSTA DE BLIP COM FALLBACKS
-- =============================================================================

local function createNativeBlip(options, fallbackSprite)
    if type(Open77.blips) ~= "table" or type(Open77.blips.create) ~= "function" then
        return nil, "blips_backend_unavailable"
    end

    -- REGRA DA DOCUMENTAÇÃO OFICIAL (open2077.net/docs/blips):
    -- routable=true força Mappins.CustomPositionMappinDefinition (waypoint diamond) que sobrescreve
    -- o sprite e oculta todos os pins não rastreados.
    -- Marcadores de POI/serviço no mapa DEVEM usar routable=false (Mappins.DefaultStaticMappin).
    local payload = {
        position = options.position,
        sprite = options.sprite,
        title = options.title,
        description = options.description,
        color = options.color,
        active = true,
        visibleThroughWalls = false,
        routable = false
    }

    -- 1. Tentativa com sprite primário
    local id, err = Open77.blips.create(payload)
    if id ~= nil then return id end

    -- 2. Tentativa com fallback especializado
    if fallbackSprite and fallbackSprite ~= options.sprite then
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
-- GERADOR DE MARCADORES DO MUNDO
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

local lastSyncTimestamp = 0
local isSyncing = false

local function spawnWorldBlips(force)
    if blipsInitialized and #createdBlips > 0 and not force then return end
    if not EconomyConfig.BlipSettings or not EconomyConfig.BlipSettings.enabled then return end

    clearAllBlips()

    local countAtm = 0
    local countVending = 0
    local countRipper = 0
    local countMarket = 0

    local settings = EconomyConfig.BlipSettings

    -- 1. Gerar Blips de ATMs (Bancos)
    for _, atm in ipairs(EconomyConfig.AtmLocations or {}) do
        local id = createNativeBlip({
            position = { x = atm.x, y = atm.y, z = atm.z },
            sprite = settings.atm.sprite,
            title = atm.name or settings.atm.title,
            description = settings.atm.description,
            color = settings.atm.color,
            routable = false
        }, settings.atm.fallbackSprite)

        if id then
            createdBlips[#createdBlips + 1] = id
            countAtm = countAtm + 1
        end
    end

    -- 2. Gerar Blips de Dispensadores (Vending Machines)
    for _, v in ipairs(EconomyConfig.VendingLocations or {}) do
        local id = createNativeBlip({
            position = { x = v.x, y = v.y, z = v.z },
            sprite = settings.vending.sprite,
            title = v.name or settings.vending.title,
            description = settings.vending.description,
            color = settings.vending.color,
            routable = false
        }, settings.vending.fallbackSprite)

        if id then
            createdBlips[#createdBlips + 1] = id
            countVending = countVending + 1
        end
    end

    -- 3. Gerar Blips de Ripperdocs (Médicos / Ciberimplantes)
    for _, rip in ipairs(EconomyConfig.RipperdocLocations or {}) do
        local id = createNativeBlip({
            position = { x = rip.x, y = rip.y, z = rip.z },
            sprite = settings.ripperdoc.sprite,
            title = rip.name or settings.ripperdoc.title,
            description = settings.ripperdoc.description,
            color = settings.ripperdoc.color,
            routable = false
        }, settings.ripperdoc.fallbackSprite)

        if id then
            createdBlips[#createdBlips + 1] = id
            countRipper = countRipper + 1
        end
    end

    -- 4. Gerar Blips de Mercados e Conveniências (Lojas)
    for _, m in ipairs(EconomyConfig.MarketLocations or {}) do
        local id = createNativeBlip({
            position = { x = m.x, y = m.y, z = m.z },
            sprite = settings.market.sprite,
            title = m.name or settings.market.title,
            description = settings.market.description,
            color = settings.market.color,
            routable = false
        }, settings.market.fallbackSprite)

        if id then
            createdBlips[#createdBlips + 1] = id
            countMarket = countMarket + 1
        end
    end

    blipsInitialized = true
    print(string.format("[ls_economy] %d Marcadores de Mapa gerados com sucesso (ATMs: %d, Vending: %d, Ripperdocs: %d, Mercados: %d).",
        #createdBlips, countAtm, countVending, countRipper, countMarket))
end

local function syncBlips(force)
    local now = GetGameTimer and GetGameTimer() or (os.time() * 1000)
    if not force and (now - lastSyncTimestamp < 2000) then
        return
    end
    if isSyncing then return end
    isSyncing = true
    lastSyncTimestamp = now

    spawnWorldBlips(true)
    isSyncing = false
end

-- =============================================================================
-- CICLO DE VIDA DO RECURSO (MULTI-GATILHO DE SINCRONIZAÇÃO AUTOMÁTICA)
-- =============================================================================

local function startBlipLifecycle()
    CreateThread(function()
        -- 1. Aguarda o personagem local entrar e estar anexado ao mundo com coordenadas válidas
        while true do
            if Open77 and Open77.character and Open77.character.state then
                local state = Open77.character.state()
                if state and state.attached and state.alive then
                    local px, py
                    if type(Open77.character.position) == "function" then
                        local rawPos, rY = Open77.character.position()
                        if type(rawPos) == "table" then
                            px, py = rawPos.x, rawPos.y
                        elseif type(rawPos) == "number" then
                            px, py = rawPos, rY
                        end
                    end
                    if px and py and (math.abs(px) > 1.0 or math.abs(py) > 1.0) then
                        break
                    end
                end
            end
            Wait(500)
        end

        -- 2. Aguarda estabilização dos filtros de bootstrap do REDengine e MappinSystem
        Wait(2500)
        syncBlips(true)
    end)
end

-- Gatilho 1: Inicialização do recurso e worldReady
startBlipLifecycle()

AddEventHandler("open77:worldReady", function()
    CreateThread(function()
        Wait(1500)
        syncBlips(true)
    end)
end)

AddEventHandler("onClientResourceStart", function(name)
    if name == GetCurrentResourceName() then
        startBlipLifecycle()
    end
end)

AddEventHandler("onClientResourceStop", function(name)
    if name == GetCurrentResourceName() then
        clearAllBlips()
    end
end)

-- Gatilho 2: Sessão de jogador autenticada e carregada
RegisterNetEvent("ls:core:playerLoaded", function()
    CreateThread(function()
        Wait(1500)
        syncBlips(true)
    end)
end)

AddEventHandler("ls:core:playerLoaded", function()
    CreateThread(function()
        Wait(1500)
        syncBlips(true)
    end)
end)

RegisterNetEvent("ls:economy:sync", function()
    if not blipsInitialized or #createdBlips == 0 then
        CreateThread(function()
            Wait(1000)
            syncBlips(true)
        end)
    end
end)

-- Gatilho 3: Abertura do mapa mundi nativo (evento oficial)
AddEventHandler("open77:map:opened", function()
    syncBlips(true)
end)

-- Gatilho 4: Detector de borda de abertura do mapa mundi via Open77.map.isOpen()
CreateThread(function()
    local wasMapOpen = false
    while true do
        Wait(1000)
        if Open77 and Open77.map and Open77.map.isOpen then
            local isOpen = false
            local ok, val = pcall(function() return Open77.map.isOpen() end)
            if ok and val == true then
                isOpen = true
            end

            if isOpen and not wasMapOpen then
                -- Borda de subida: o jogador acabou de abrir o mapa mundi!
                syncBlips(true)
            end
            wasMapOpen = isOpen
        end
    end
end)

-- =============================================================================
-- SISTEMA DIEGÉTICO DE NAVEGAÇÃO GPS KIROSHI (/gps)
-- Conforme open2077.net/docs/blips:
-- setWaypoint({x, y, z}) registra um pino calculável e traça a rota na estrada.
-- =============================================================================

local function getPlayerPos()
    if Open77 and Open77.character and Open77.character.position then
        return Open77.character.position()
    end
    return nil
end

local function findNearest(locations)
    local pPos = getPlayerPos()
    if not pPos then return locations and locations[1] or nil end
    local nearest = nil
    local minDist = math.huge
    for _, loc in ipairs(locations or {}) do
        local dx = loc.x - pPos.x
        local dy = loc.y - pPos.y
        local dz = (loc.z or 0) - (pPos.z or 0)
        local dist = dx*dx + dy*dy + dz*dz
        if dist < minDist then
            minDist = dist
            nearest = loc
        end
    end
    return nearest
end

local function setGpsTo(loc, categoryName)
    if not loc then return end
    if Open77.blips and Open77.blips.setWaypoint then
        local ok, reason = Open77.blips.setWaypoint({ x = loc.x, y = loc.y, z = loc.z })
        if ok then
            TriggerEvent("open77:chat:addMessage", {
                color = { 34, 216, 226 },
                multiline = false,
                args = { "GPS KIROSHI", string.format("Rota traçada para: %s (%s). Siga a linha de navegação no mapa/minimapa.", loc.name or categoryName, categoryName) }
            })
        else
            TriggerEvent("open77:chat:addMessage", {
                color = { 255, 60, 60 },
                multiline = false,
                args = { "GPS KIROSHI", "Falha ao traçar rota: " .. tostring(reason) }
            })
        end
    end
end

RegisterCommand("gps", function(source, args)
    local target = args[1] and string.lower(args[1]) or ""
    if target == "atm" or target == "banco" or target == "bank" then
        local nearest = findNearest(EconomyConfig.AtmLocations)
        setGpsTo(nearest, "ATM / Banco")
    elseif target == "vending" or target == "comida" or target == "food" then
        local nearest = findNearest(EconomyConfig.VendingLocations)
        setGpsTo(nearest, "Dispensador de Alimentos")
    elseif target == "ripper" or target == "ripperdoc" or target == "clinica" or target == "med" then
        local nearest = findNearest(EconomyConfig.RipperdocLocations)
        setGpsTo(nearest, "Clínica Ripperdoc")
    elseif target == "mercado" or target == "market" or target == "loja" or target == "shop" then
        local nearest = findNearest(EconomyConfig.MarketLocations)
        setGpsTo(nearest, "Mercado 24/7")
    elseif target == "clear" or target == "limpar" or target == "off" then
        if Open77.blips and Open77.blips.clearWaypoint then
            Open77.blips.clearWaypoint()
            TriggerEvent("open77:chat:addMessage", {
                color = { 200, 200, 200 },
                multiline = false,
                args = { "GPS KIROSHI", "Destino e rota cancelados." }
            })
        end
    else
        TriggerEvent("open77:chat:addMessage", {
            color = { 255, 204, 0 },
            multiline = false,
            args = { "GPS KIROSHI", "Uso: /gps [atm | vending | ripper | mercado | clear]" }
        })
    end
end, false)

-- Comando diegético de recarregar marcadores
RegisterCommand("syncblips", function()
    syncBlips(true)
    TriggerEvent("open77:chat:addMessage", {
        color = { 0, 255, 128 },
        multiline = false,
        args = { "GPS KIROSHI", "Sinal dos satélites sincronizado: marcadores de Night City atualizados." }
    })
end, false)

-- Exportações para outros recursos do servidor
exports("syncBlips", function(force)
    syncBlips(force == true)
end)
exports("setGPS", function(targetType)
    ExecuteCommand("gps " .. tostring(targetType))
end)

exports("setWaypoint", function(coords)
    if Open77.blips and Open77.blips.setWaypoint then
        return Open77.blips.setWaypoint(coords)
    end
    return false, "blips_backend_unavailable"
end)

exports("clearWaypoint", function()
    if Open77.blips and Open77.blips.clearWaypoint then
        return Open77.blips.clearWaypoint()
    end
    return false, "blips_backend_unavailable"
end)
