--[[
    LIFESIM RP - Native UI Client Manager
    Path: ls_ui/client/main.lua
    Gerencia a camada WebUI do Kiroshi Biomonitor HUD, ponte nativa de eventos,
    foco de tela e sincronização bidirecional de posicionamento espacial persistente.
]]

local page = nil
local ready = false
local currentVitals = nil
local currentMoney = nil
local savedBiomonitorPos = nil
local cachedInventoryBag = nil
local isModalActive = false

local function setModalActive(active)
    active = active == true
    if isModalActive == active then return end
    isModalActive = active
    TriggerEvent("ls:ui:modalStateChanged", active)
end

local function dispatchVitals(v)
    if not v or type(v) ~= "table" then return end
    currentVitals = v
    if page and ready then
        page:send("vitals:update", v)
    end
end

local function dispatchMoney(m)
    if not m or type(m) ~= "table" then return end
    currentMoney = m
    if page and ready then
        page:send("economy:update", m)
    end
end

-- =============================================================================
-- INICIALIZAÇÃO DA WEBUI
-- =============================================================================

AddEventHandler("onClientResourceStart", function(name)
    if name ~= GetCurrentResourceName() then return end

    local errorMessage
    page, errorMessage = WebUI.create({
        entry = "web/index.html",
        layer = "hud",
        width = 1920,
        height = 1080,
        fps = 30,
        zIndex = 500,
        transparent = true,
        visible = true
    })

    if not page then
        Open77.log.error("[ls_ui] Falha ao criar WebUI HUD: " .. tostring(errorMessage))
        return
    end

    -- Listener de prontidão da página WebUI (emitido pelo CEF app.js)
    page:on("ls:ui:ready", function()
        ready = true
        Open77.log.info("[ls_ui] Kiroshi Biomonitor HUD montado e conectado.")
        TriggerEvent("ls:ui:ready")

        -- 1. Solicita as configurações espaciais salvas no banco do servidor
        TriggerServerEvent("ls:ui:requestSettings")

        -- 2. Se já tivermos recebido a posição antes da página estar pronta, aplica agora
        if savedBiomonitorPos and type(savedBiomonitorPos) == "table" then
            page:send("biomonitor:setPosition", savedBiomonitorPos)
        end

        -- 3. Sincronizar com os vitais atuais em memória, se existirem
        if currentVitals then
            page:send("vitals:update", currentVitals)
        else
            pcall(function()
                local v = exports["ls_vitals"]:getVitals()
                if v then dispatchVitals(v) end
            end)
        end

        -- 4. Sincronizar com saldos financeiros atuais em memória
        if currentMoney then
            page:send("economy:update", currentMoney)
        else
            pcall(function()
                local acc = exports["ls_economy"]:getAccount()
                if acc then dispatchMoney(acc) end
            end)
        end

        -- 5. Sincronizar com inventário em cache, se existente
        if cachedInventoryBag and type(cachedInventoryBag) == "table" then
            page:send("inventory:updateBag", cachedInventoryBag)
        end
    end)

    -- Fechamento de modal de configurações e devolução de controle ao jogo
    page:on("biomonitor:closeSettings", function()
        setModalActive(false)
        if page then
            page:setFocus(false, false)
        end
    end)

    -- Salvamento de nova posição do HUD: devolve mouse e envia para persistência no servidor
    page:on("biomonitor:savePosition", function(pos)
        setModalActive(false)
        if page then
            page:setFocus(false, false)
        end
        if type(pos) == "table" and pos.left and pos.top then
            savedBiomonitorPos = {
                left = tonumber(pos.left) or 0,
                top = tonumber(pos.top) or 0
            }
            Open77.log.info(("[ls_ui] Posição do Biomonitor atualizada localmente: Left=%s, Top=%s"):format(
                tostring(savedBiomonitorPos.left), tostring(savedBiomonitorPos.top)
            ))
            -- Transmite ao servidor para gravar no MariaDB (ls_ui_settings)
            TriggerServerEvent("ls:ui:saveBiomonitorPos", savedBiomonitorPos)
        end
    end)

    -- Reset da posição do Biomonitor para o canto padrão
    page:on("biomonitor:resetPosition", function()
        savedBiomonitorPos = nil
        Open77.log.info("[ls_ui] Reset da posição do Biomonitor enviado ao servidor.")
        TriggerServerEvent("ls:ui:resetBiomonitorPos")
    end)

    -- Comunicação e ações do Terminal Kiosk ATM
    page:on("atm:action", function(data)
        if type(data) == "table" and data.action then
            TriggerServerEvent("ls:economy:atmAction", data)
        end
    end)

    page:on("atm:close", function()
        setModalActive(false)
        if page then
            page:setFocus(false, false)
        end
    end)

    -- Comunicação da Máquina de Vendas & Conveniência
    page:on("vending:buy", function(data)
        if type(data) == "table" and data.itemKey then
            TriggerServerEvent("ls:vitals:buy", data.itemKey, data.paymentType)
        end
    end)

    page:on("vending:close", function()
        setModalActive(false)
        if page then
            page:setFocus(false, false)
        end
    end)

    -- Comunicação da Clínica Ripperdoc & Farmácia
    page:on("ripperdoc:buyImplant", function(data)
        if type(data) == "table" and data.implantId then
            TriggerServerEvent("ls:cyberware:buyImplant", data.implantId)
        end
    end)

    page:on("ripperdoc:buyPharma", function(data)
        if type(data) == "table" and data.pharmaId then
            TriggerServerEvent("ls:cyberware:buyPharmaceutical", data.pharmaId)
        end
    end)

    page:on("ripperdoc:close", function()
        setModalActive(false)
        if page then
            page:setFocus(false, false)
        end
    end)

    -- Comunicação e ações do Inventário e Crafting
    page:on("inventory:moveItem", function(data)
        if type(data) == "table" and data.fromSlot and data.toSlot then
            TriggerServerEvent("ls:inventory:moveItem", data.fromSlot, data.toSlot)
        end
    end)

    page:on("inventory:useItem", function(data)
        if type(data) == "table" and data.slot then
            TriggerServerEvent("ls:inventory:useItem", data.slot)
        end
    end)

    page:on("inventory:startCraft", function(data)
        if type(data) == "table" and data.recipeId then
            TriggerServerEvent("ls:inventory:startCrafting", data.recipeId)
        end
    end)

    page:on("inventory:close", function()
        setModalActive(false)
        if page then
            page:setFocus(false, false)
        end
        TriggerEvent("ls:inventory:closedFromUI")
    end)

    -- Ação rápida disparada pelo Quick Radial Menu
    page:on("radial:triggerAction", function(data)
        if type(data) == "table" and data.slot then
            TriggerServerEvent("ls:inventory:useItem", data.slot)
        end
    end)
end)

-- =============================================================================
-- INTEGRAÇÃO NATIVA DE INVENTÁRIO, CRAFTING E RADIAL MENU
-- =============================================================================

RegisterNetEvent("ls:ui:syncInventoryBag", function(bagData)
    if type(bagData) == "table" then
        cachedInventoryBag = bagData
        if page and ready then
            page:send("inventory:updateBag", bagData)
        end
    end
end)

RegisterNetEvent("ls:ui:toggleInventoryModal", function(open)
    if not page or not ready then return end
    local shouldOpen = open == true
    setModalActive(shouldOpen)
    page:setFocus(shouldOpen, shouldOpen)
    if shouldOpen then
        if cachedInventoryBag and type(cachedInventoryBag) == "table" then
            page:send("inventory:updateBag", cachedInventoryBag)
        end
        TriggerServerEvent("ls:inventory:requestSync")
    end
    page:send("inventory:toggle", { open = shouldOpen })
end)

RegisterNetEvent("ls:ui:setRadialState", function(active)
    if not page or not ready then return end
    local shouldActive = active == true
    setModalActive(shouldActive)
    if shouldActive and cachedInventoryBag and type(cachedInventoryBag) == "table" then
        page:send("inventory:updateBag", cachedInventoryBag)
    end
    if page then
        page:setFocus(false, shouldActive) -- Libera ponteiro do mouse para navegação no SVG sem travar câmera do jogador
        page:send("radial:toggle", { active = shouldActive })
    end
end)

RegisterNetEvent("ls:ui:craftProgressStarted", function(data)
    if page and ready and type(data) == "table" then
        page:send("crafting:progress", data)
    end
end)

RegisterNetEvent("ls:ui:craftSuccess", function(data)
    if page and ready and type(data) == "table" then
        page:send("crafting:success", data)
    end
end)

RegisterNetEvent("ls:ui:craftFailed", function(reason)
    if page and ready then
        page:send("crafting:failed", { message = tostring(reason) })
    end
end)



-- =============================================================================
-- SINCRONIZAÇÃO DE CONFIGURAÇÕES VINDO DO SERVIDOR
-- =============================================================================

RegisterNetEvent("ls:ui:syncSettings", function(settings)
    if not settings or type(settings) ~= "table" then return end

    if settings.biomonitor and type(settings.biomonitor) == "table" then
        savedBiomonitorPos = settings.biomonitor
        if page and ready then
            page:send("biomonitor:setPosition", settings.biomonitor)
            Open77.log.info(("[ls_ui] Posição salva restaurada do banco: Left=%s, Top=%s"):format(
                tostring(settings.biomonitor.left), tostring(settings.biomonitor.top)
            ))
        end
    end
end)

-- Observador direto do State Bag local para atualizações reativas de alta performance
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.vitals.v", function(bagName, key, v)
        dispatchVitals(v)
    end)
end

-- Listener direto de rede (Dual Sync de Vitais)
RegisterNetEvent("ls:vitals:sync", function(v)
    dispatchVitals(v)
end)

-- Observador direto do State Bag financeiro
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.economy.v", function(bagName, key, m)
        dispatchMoney(m)
    end)
end

-- Listeners diretos de rede para saldos (Dual Sync de Economia)
RegisterNetEvent("ls:economy:sync", function(m)
    dispatchMoney(m)
end)

RegisterNetEvent("ls:ui:updateMoney", function(m)
    dispatchMoney(m)
end)

-- Limpeza absoluta no teardown para evitar HUD duplicada ou órfã
AddEventHandler("onClientResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    setModalActive(false)
    if page then
        pcall(function() page:destroy() end)
        page = nil
        ready = false
    end
end)

-- =============================================================================
-- EXPORTS CLIENTE
-- =============================================================================

---Empurra dados customizados para a interface sob um tópico específico
---@param topic string
---@param data table
exports("push", function(topic, data)
    if not page or not ready or type(topic) ~= "string" then return false end
    if topic == "vitals" then
        dispatchVitals(data)
    else
        page:send("hud:" .. topic, data)
    end
    return true
end)

---Alterna a visibilidade da HUD
---@param visible boolean
exports("setVisible", function(visible)
    if not page or not ready then return false end
    page:send("hud:visibility", { visible = visible == true })
    return true
end)

---Define foco de teclado e cursor do mouse para modais e aplicativos
---@param keyboard boolean
---@param cursor boolean
exports("setFocus", function(keyboard, cursor)
    if not page then return false end
    page:setFocus(keyboard == true, cursor == true)
    return true
end)

---Verifica se qualquer interface modal/fullscreen está aberta
exports("isModalOpen", function()
    return isModalActive
end)

---Abre diretamente o painel de configurações do Biomonitor
exports("openSettings", function()
    if not page or not ready then return false end
    setModalActive(true)
    page:setFocus(true, true)
    page:send("biomonitor:openSettings", {})
    return true
end)

---Abre o terminal interativo do ATM Kiosk
exports("openAtm", function()
    if not page or not ready then return false end
    setModalActive(true)
    page:setFocus(true, true)
    page:send("atm:open", currentMoney or { cash = 0, bank = 0 })
    return true
end)

---Fecha o terminal interativo do ATM Kiosk
exports("closeAtm", function()
    if not page or not ready then return false end
    setModalActive(false)
    page:setFocus(false, false)
    page:send("atm:close", {})
    return true
end)

RegisterNetEvent("ls:ui:openAtm", function()
    if page and ready then
        setModalActive(true)
        page:setFocus(true, true)
        page:send("atm:open", currentMoney or { cash = 0, bank = 0 })
    end
end)

RegisterNetEvent("ls:ui:atmFeedback", function(feedback)
    if page and ready and type(feedback) == "table" then
        page:send("atm:feedback", feedback)
    end
end)

---Abre a Máquina de Vendas & Conveniência
exports("openVending", function()
    if not page or not ready then return false end
    setModalActive(true)
    page:setFocus(true, true)
    page:send("vending:open", currentMoney or { cash = 0, bank = 0 })
    return true
end)

---Fecha a Máquina de Vendas
exports("closeVending", function()
    if not page or not ready then return false end
    setModalActive(false)
    page:setFocus(false, false)
    page:send("vending:close", {})
    return true
end)

---Abre a Clínica Ripperdoc & Farmácia Cirúrgica
exports("openRipperdoc", function()
    if not page or not ready then return false end
    local cwData = nil
    pcall(function()
        cwData = exports["ls_cyberware"]:getCyberware()
    end)

    local payload = {
        cash = currentMoney and currentMoney.cash or 0,
        bank = currentMoney and currentMoney.bank or 0,
        stability = cwData and cwData.neural_stability or 95.0,
        heat = cwData and cwData.ocular_temp or 36.5,
        blockerActive = cwData and (cwData.neuroblocker_expires or 0) > (GetGameTimer() / 1000),
        psychosis = cwData and cwData.is_psychotic or false,
        implants = cwData and cwData.implants or {}
    }

    setModalActive(true)
    page:setFocus(true, true)
    page:send("ripperdoc:open", payload)
    return true
end)

---Fecha a Clínica Ripperdoc
exports("closeRipperdoc", function()
    if not page or not ready then return false end
    setModalActive(false)
    page:setFocus(false, false)
    page:send("ripperdoc:close", {})
    return true
end)

RegisterNetEvent("ls:ui:openVending", function()
    exports["ls_ui"]:openVending()
end)

RegisterNetEvent("ls:ui:vendingFeedback", function(feedback)
    if page and ready and type(feedback) == "table" then
        page:send("vending:feedback", feedback)
    end
end)

RegisterNetEvent("ls:ui:openRipperdoc", function()
    exports["ls_ui"]:openRipperdoc()
end)

RegisterNetEvent("ls:ui:ripperdocFeedback", function(feedback)
    if page and ready and type(feedback) == "table" then
        page:send("ripperdoc:feedback", feedback)
    end
end)

RegisterCommand("vending", function()
    exports["ls_ui"]:openVending()
end, false)

RegisterCommand("loja", function()
    exports["ls_ui"]:openVending()
end, false)

RegisterCommand("conveniencia", function()
    exports["ls_ui"]:openVending()
end, false)

RegisterCommand("ripperdoc", function()
    exports["ls_ui"]:openRipperdoc()
end, false)

RegisterCommand("clinica", function()
    exports["ls_ui"]:openRipperdoc()
end, false)

RegisterCommand("viktor", function()
    exports["ls_ui"]:openRipperdoc()
end, false)

RegisterCommand("atm", function()
    exports["ls_ui"]:openAtm()
end, false)

RegisterCommand("banco", function()
    exports["ls_ui"]:openAtm()
end, false)



-- =============================================================================
-- INTEGRAÇÃO DE ALERTAS BIOLÓGICOS E COMANDO /biomonitor
-- =============================================================================

RegisterNetEvent("ls:ui:vitalDamage", function(alertData)
    if page and ready then
        page:send("vitals:damageAlert", alertData)
    end
end)

RegisterCommand("biomonitor", function()
    if not page or not ready then
        Open77.log.warn("[ls_ui] Biomonitor HUD não está montado.")
        return
    end

    page:setFocus(true, true)
    page:send("biomonitor:openSettings", {})
end, false)
