--[[
    OPEN//77 - Spatial Positioning & Coordinate Inspector (Coords Tool)
    Path: open77_coords/client/main.lua
    Captura de telemetria REDengine 4 (posição, yaw, forward/head) e controle da WebUI.
]]

local page = nil
local pageReady = false
local isOpen = false
local lastSnapshot = nil

---Coleta os dados espaciais completos e de alta precisão do personagem local
---@return table|nil
local function captureSpatialSnapshot()
    local px, py, pz

    -- 1. Leitura nativa de posição (retorna 3 números float x, y, z ou tabela)
    if Open77.character and Open77.character.position then
        local r1, r2, r3 = Open77.character.position()
        if type(r1) == "table" then
            px, py, pz = tonumber(r1.x), tonumber(r1.y), tonumber(r1.z)
        elseif type(r1) == "number" then
            px, py, pz = r1, tonumber(r2), tonumber(r3)
        end
    end

    -- 2. Fallback via Open77.character.state()
    local state = (Open77.character and Open77.character.state) and Open77.character.state() or nil
    if (not px or not py or not pz) and state and state.position then
        px = tonumber(state.position.x)
        py = tonumber(state.position.y)
        pz = tonumber(state.position.z)
    end

    if not px or not py or not pz then return nil end

    -- 3. Leitura e normalização de Yaw e Heading
    local yaw = 0.0
    if Open77.character and Open77.character.yaw then
        local y = Open77.character.yaw()
        if type(y) == "number" then yaw = y end
    elseif state and state.yaw then
        yaw = tonumber(state.yaw) or 0.0
    end

    local heading = (tonumber(yaw) or 0.0) % 360
    if heading < 0 then heading = heading + 360 end

    -- 4. Vetor Frontal (Forward Vector) e Inclinação (Pitch)
    local forwardX, forwardY, forwardZ = 0.0, 1.0, 0.0
    if Open77.character and Open77.character.forward then
        local f1, f2, f3 = Open77.character.forward()
        if type(f1) == "table" then
            forwardX = tonumber(f1.x) or 0.0
            forwardY = tonumber(f1.y) or 0.0
            forwardZ = tonumber(f1.z) or 0.0
        elseif type(f1) == "number" then
            forwardX = f1
            forwardY = tonumber(f2) or 0.0
            forwardZ = tonumber(f3) or 0.0
        end
    elseif state and state.orientation then
        local q = state.orientation
        local qx, qy, qz, qw = tonumber(q.x) or 0, tonumber(q.y) or 0, tonumber(q.z) or 0, tonumber(q.w) or 1
        forwardX = 2.0 * (qx * qy - qw * qz)
        forwardY = 1.0 - 2.0 * (qx * qx + qz * qz)
        forwardZ = 2.0 * (qy * qz + qw * qx)
    else
        local rad = math.rad(yaw)
        forwardX = -math.sin(rad)
        forwardY = math.cos(rad)
        forwardZ = 0.0
    end

    local fz = tonumber(forwardZ) or 0.0
    local pitch = math.deg(math.asin(math.max(-1.0, math.min(1.0, fz))))

    -- 5. Leitura da Posição do Osso da Cabeça (Head Bone)
    local headPos = nil
    if Open77.character and Open77.character.bonePosition then
        local ok, hp1, hp2, hp3 = pcall(Open77.character.bonePosition, nil, "Head")
        if ok and hp1 then
            if type(hp1) == "table" then
                headPos = { x = tonumber(hp1.x) or px, y = tonumber(hp1.y) or py, z = tonumber(hp1.z) or (pz + 1.7) }
            elseif type(hp1) == "number" then
                headPos = { x = hp1, y = tonumber(hp2) or py, z = tonumber(hp3) or (pz + 1.7) }
            end
        end
    end

    return {
        position = {
            x = px,
            y = py,
            z = pz
        },
        head = {
            forwardX = forwardX,
            forwardY = forwardY,
            forwardZ = forwardZ,
            boneX = headPos and headPos.x or px,
            boneY = headPos and headPos.y or py,
            boneZ = headPos and headPos.z or (pz + 1.7),
            pitch = pitch
        },
        yaw = yaw,
        heading = heading
    }
end

---Inicializa e configura a camada CEF WebUI
local function initWebUI()
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
        visible = false
    })

    if not page then
        Open77.log.error("[open77_coords] Falha ao criar WebUI de Coordenadas: " .. tostring(errorMessage))
        return
    end

    -- Evento disparado quando o app.js carrega no navegador CEF
    page:on("coords:ready", function()
        pageReady = true
        Open77.log.info("[open77_coords] Interface Kiroshi Spatial Scanner montada e pronta.")
        if isOpen and lastSnapshot then
            page:send("coords:setData", lastSnapshot)
        end
    end)

    -- Fechamento de modal solicitado pela interface
    page:on("coords:close", function()
        if not isOpen then return end
        isOpen = false
        if page then
            page:setFocus(false, false)
            page:hide()
        end
    end)

    -- Solicitação de cópia de texto com driver nativo do Open77
    page:on("coords:copyNative", function(payload)
        if not payload or not payload.text then return end
        if Open77.clipboard and Open77.clipboard.setText then
            Open77.clipboard.setText(tostring(payload.text))
        end
    end)

    -- Recaptura de coordenadas sem fechar a interface
    page:on("coords:refresh", function()
        if not page then return end
        local snapshot = captureSpatialSnapshot()
        if snapshot then
            lastSnapshot = snapshot
            page:send("coords:setData", snapshot)
        end
    end)
end

---Abre o modal de coordenadas com captura fresca
local function openInspector()
    if not page then
        initWebUI()
    end

    local snapshot = captureSpatialSnapshot()
    if not snapshot then
        TriggerEvent("open77:chat:addMessage", {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "SCANNER KIROSHI", "Dados espaciais indisponíveis. Seu personagem já entrou no mundo?" }
        })
        return
    end

    lastSnapshot = snapshot
    isOpen = true

    if page then
        page:show()
        page:setFocus(true, true)
        page:send("coords:setData", snapshot)
    end
end

-- Handlers de Ciclo de Vida e Rede
AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    initWebUI()
end)

AddEventHandler("onClientResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    if page then
        page:setFocus(false, false)
        page:destroy()
        page = nil
    end
end)

RegisterNetEvent("open77_coords:openUI", function()
    openInspector()
end)
