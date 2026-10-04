--[[
    LIFESIM RP - Spawn Points Client Manager
    Path: ls_spawn/client/main.lua
    
    Controla o ciclo de vida do cliente:
    1. Criação da superfície WebUI do seletor holográfico de spawn points.
    2. Bloqueio de locomoção e foco de mouse/teclado durante a escolha.
    3. Envio da seleção ao servidor e restauração graciosa do HUD e mobilidade.
    4. Boas-vindas diegéticas no primeiro spawn (sem interface de escolha).
]]

local page = nil
local isSpawnActive = false
local pendingOpenData = nil
local webUiReady = false

-- =============================================================================
-- INICIALIZAÇÃO DA WEBUI
-- =============================================================================

local function createSpawnPage()
    if page then return end

    local errorMessage
    page, errorMessage = WebUI.create({
        entry = "web/index.html",
        layer = "hud",
        width = 1920,
        height = 1080,
        fps = 60,
        zIndex = 99990,
        transparent = true,
        visible = true
    })

    if not page then
        Open77.log.error("[ls_spawn] Falha ao instanciar WebUI de Spawn: " .. tostring(errorMessage))
        return
    end

    -- Listener de prontidão emitido pelo app.js (CEF)
    page:on("ls:spawn:ready", function()
        webUiReady = true
        Open77.log.info("[ls_spawn] WebUI de spawn points carregada e pronta.")
        if pendingOpenData then
            local data = pendingOpenData
            pendingOpenData = nil
            TriggerEvent("ls:spawn:internalOpen", data)
        end
    end)

    -- Ação de seleção disparada pelo usuário na interface
    page:on("spawn:select", function(payload)
        if type(payload) == "table" and payload.spawnId then
            Open77.log.info("[ls_spawn] Ponto de spawn selecionado pelo usuário: " .. tostring(payload.spawnId))
            TriggerServerEvent("ls:spawn:select", payload.spawnId)
        end
    end)
end

AddEventHandler("onClientResourceStart", function(name)
    if name ~= GetCurrentResourceName() then return end
    createSpawnPage()
end)

-- =============================================================================
-- CONTROLE DE LOCOMOÇÃO E FOCO
-- =============================================================================

local function setPlayerFrozen(frozen)
    frozen = frozen == true
    pcall(function()
        if Open77.players and Open77.players.freezePosition then
            Open77.players.freezePosition(frozen)
        elseif FreezePosition then
            FreezePosition(frozen)
        end

        if not frozen then
            if Open77.players and Open77.players.allowInteraction then
                Open77.players.allowInteraction(true)
                Open77.players.allowAim(true)
                Open77.players.allowRunning(true)
                Open77.players.allowJump(true)
                Open77.players.allowCrouch(true)
                Open77.players.allowWeapons(true)
            end
            if AllowMovement then AllowMovement(true) end
            if AllowInteraction then AllowInteraction(true) end
        else
            if AllowMovement then AllowMovement(false) end
            if AllowInteraction then AllowInteraction(false) end
        end
    end)
end

local function openSpawnSelector(data)
    isSpawnActive = true
    setPlayerFrozen(true)

    -- Notifica outros módulos que uma tela modal crítica está ativa (oculta o Biomonitor temporariamente)
    TriggerEvent("ls:ui:modalStateChanged", true)

    if not page then
        createSpawnPage()
    end

    if not webUiReady then
        pendingOpenData = data
        return
    end

    if page then
        page:setFocus(true, true)
        page:send("spawn:open", data)
    end
end

local function closeSpawnSelector()
    isSpawnActive = false
    setPlayerFrozen(false)

    if page then
        -- OPEN//77 CEF page:send SEMPRE requer tabela como payload
        page:send("spawn:close", {})
        page:setFocus(false, false)
    end

    -- Restaura a visibilidade do Biomonitor HUD
    TriggerEvent("ls:ui:modalStateChanged", false)
end

-- =============================================================================
-- EVENTOS DE REDE
-- =============================================================================

-- Recebe ordem do servidor para abrir o seletor de spawn (personagens existentes)
RegisterNetEvent("ls:spawn:open", function(data)
    openSpawnSelector(data)
end)

AddEventHandler("ls:spawn:internalOpen", function(data)
    openSpawnSelector(data)
end)

-- Recebe confirmação do servidor de que o teleporte foi concluído
RegisterNetEvent("ls:spawn:completed", function(data)
    Open77.log.info(("[ls_spawn] Spawn concluído com sucesso em %s (%s)."):format(
        tostring(data and data.name), tostring(data and data.district)
    ))

    -- Teleporte nativo autoritativo no cliente via Open77.travel
    if data and data.coords and data.coords.x then
        pcall(function()
            if Open77.travel and Open77.travel.teleport then
                Open77.travel.teleport(data.coords.x + 0.0, data.coords.y + 0.0, data.coords.z + 0.0, (data.coords.heading or 0.0) + 0.0)
            end
        end)
    end

    closeSpawnSelector()
end)

-- Primeiro spawn direto no Megabuilding H10 (sem abrir o seletor)
RegisterNetEvent("ls:spawn:firstSpawnWelcome", function(data)
    setPlayerFrozen(false)
    TriggerEvent("ls:ui:modalStateChanged", false)

    Open77.log.info(("[ls_spawn] Primeiro spawn inicializado: %s - %s"):format(
        tostring(data and data.locationName), tostring(data and data.message)
    ))
end)

-- =============================================================================
-- GERENCIAMENTO DE BLIPS E MARCADORES 3D NO MUNDO
-- =============================================================================

local createdSpawnBlips = {}
local createdSpawnMarkers = {}

local function clearSpawnWorldElements()
    for _, blipId in ipairs(createdSpawnBlips) do
        pcall(function()
            if Open77.blips and Open77.blips.remove then
                Open77.blips.remove(blipId)
            end
        end)
    end
    createdSpawnBlips = {}

    for _, markerId in ipairs(createdSpawnMarkers) do
        pcall(function()
            if Open77.markers and Open77.markers.remove then
                Open77.markers.remove(markerId)
            end
        end)
    end
    createdSpawnMarkers = {}
end

local function initSpawnWorldElements()
    clearSpawnWorldElements()

    local blipsGlobal = Config.WorldBlips and Config.WorldBlips.enabled
    local markersGlobal = Config.WorldMarkers and Config.WorldMarkers.enabled

    for _, sp in ipairs(Config.PublicSpawns or {}) do
        local c = sp.coords
        if c and c.x and c.y and c.z then
            -- 1. Criação de Blips no Mapa Vanilla
            local blipCfg = sp.blip
            local shouldCreateBlip = (blipsGlobal and (not blipCfg or blipCfg.enabled ~= false)) or (blipCfg and blipCfg.enabled == true)

            if shouldCreateBlip then
                pcall(function()
                    if Open77.blips and Open77.blips.create then
                        local blipId = Open77.blips.create({
                            position = { x = c.x + 0.0, y = c.y + 0.0, z = c.z + 0.0 },
                            label = (blipCfg and blipCfg.label) or sp.name,
                            color = (blipCfg and blipCfg.color) or (Config.WorldBlips and Config.WorldBlips.defaultColor) or "#22D8E2",
                            icon = (blipCfg and blipCfg.icon) or (Config.WorldBlips and Config.WorldBlips.defaultIcon) or "CustomPositionVariant"
                        })
                        if blipId then
                            table.insert(createdSpawnBlips, blipId)
                        end
                    end
                end)
            end

            -- 2. Criação de Marcadores 3D no chão
            local markerCfg = sp.marker
            local shouldCreateMarker = (markersGlobal and (not markerCfg or markerCfg.enabled ~= false)) or (markerCfg and markerCfg.enabled == true)

            if shouldCreateMarker then
                pcall(function()
                    if Open77.markers and Open77.markers.create then
                        local mId = Open77.markers.create({
                            position = { x = c.x + 0.0, y = c.y + 0.0, z = c.z + 0.05 },
                            shape = (markerCfg and markerCfg.shape) or (Config.WorldMarkers and Config.WorldMarkers.defaultShape) or "ring",
                            style = "spawn",
                            radius = (markerCfg and markerCfg.radius) or (Config.WorldMarkers and Config.WorldMarkers.defaultRadius) or 2.0,
                            color = (markerCfg and markerCfg.color) or (Config.WorldMarkers and Config.WorldMarkers.defaultColor) or { 34, 216, 226, 180 },
                            maxDistance = 50.0
                        })
                        if mId then
                            table.insert(createdSpawnMarkers, mId)
                        end
                    end
                end)
            end
        end
    end
end

AddEventHandler("onClientResourceStart", function(name)
    if name ~= GetCurrentResourceName() then return end
    initSpawnWorldElements()
end)

-- Limpeza ao parar o recurso
AddEventHandler("onClientResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    clearSpawnWorldElements()
    setPlayerFrozen(false)
    if page then
        page:setFocus(false, false)
        page:destroy()
        page = nil
    end
end)
