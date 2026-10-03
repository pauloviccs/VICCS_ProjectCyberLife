--[[
    LIFESIM RP - Target & Diegetic World Interaction Manager
    Path: ls_economy/client/targets.lua
    Adaptação dos sistemas econômicos, bancários, médicos e comerciais para o sistema de mira/olho (ALT Target)
    utilizando open77_contextmenu e open77_interactions sobre props físicos de Night City.
]]

local resource = GetCurrentResourceName()

-- =============================================================================
-- UTILITÁRIOS DE DISTÂNCIA & VALIDAÇÃO ESPACIAL
-- =============================================================================

local function distance3D(a, b)
    if not a or not b then return math.huge end
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    local dz = (a.z or 0) - (b.z or 0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function isNearLocations(point, locations, maxDist)
    if not point or not locations then return false end
    for _, loc in ipairs(locations) do
        local checkDist = maxDist or (loc.radius and loc.radius * 1.5) or 3.5
        local d = distance3D(point, loc)
        if d <= checkDist then
            return true, loc
        end
    end
    return false, nil
end

local function recordOrNameMatches(target, patterns)
    if not target or not patterns then return false end
    local text = ""
    if type(target.record) == "string" then
        text = text .. " " .. target.record:lower()
    end
    if type(target.class) == "string" then
        text = text .. " " .. target.class:lower()
    end
    if type(target.name) == "string" then
        text = text .. " " .. target.name:lower()
    end
    if type(target.model) == "string" then
        text = text .. " " .. target.model:lower()
    end

    for _, pat in ipairs(patterns) do
        local cleanPat = pat:lower():gsub("%*", "")
        if #cleanPat > 0 and text:find(cleanPat, 1, true) then
            return true
        end
    end
    return false
end

-- =============================================================================
-- PREDICADOS DE INTERAÇÃO (open77_contextmenu / ALT de Interação)
-- =============================================================================

exports("targetCanInteractAtm", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    if not context then return false end
    local pos = context.position
    local target = context.target

    -- 1. Verificação por proximidade física com caixas eletrônicos registrados
    if isNearLocations(pos, EconomyConfig.AtmLocations, 3.8) then
        return true
    end

    -- 2. Verificação por prop/classe/modelo do Cyberpunk
    if target and recordOrNameMatches(target, EconomyConfig.TargetProps.atm) then
        return true
    end

    return false
end)

exports("targetSelectAtm", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    local ok = pcall(function()
        if exports["ls_ui"] and exports["ls_ui"].openAtm then
            exports["ls_ui"]:openAtm()
        else
            TriggerEvent("ls:ui:openAtm")
        end
    end)
    if ok then
        TriggerEvent("open77:chat:addMessage", {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "NIGHT CITY BANK", "Acesso biométrico autorizado via Kiroshi Optics." }
        })
    end
    return ok
end)

exports("targetCanInteractVending", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    if not context then return false end
    local pos = context.position
    local target = context.target

    if isNearLocations(pos, EconomyConfig.VendingLocations, 3.5) then
        return true
    end

    if target and recordOrNameMatches(target, EconomyConfig.TargetProps.vending) then
        return true
    end

    return false
end)

exports("targetSelectVending", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    local ok = pcall(function()
        if exports["ls_ui"] and exports["ls_ui"].openVending then
            exports["ls_ui"]:openVending()
        else
            TriggerEvent("ls:ui:openVending")
        end
    end)
    return ok
end)

exports("targetCanInteractRipperdoc", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    if not context then return false end
    local pos = context.position
    local target = context.target

    if isNearLocations(pos, EconomyConfig.RipperdocLocations, 4.5) then
        return true
    end

    if target and recordOrNameMatches(target, EconomyConfig.TargetProps.ripperdoc) then
        return true
    end

    return false
end)

exports("targetSelectRipperdoc", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    local ok = pcall(function()
        if exports["ls_ui"] and exports["ls_ui"].openRipperdoc then
            exports["ls_ui"]:openRipperdoc()
        else
            TriggerEvent("ls:ui:openRipperdoc")
        end
    end)
    return ok
end)

exports("targetCanInteractMarket", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    if not context then return false end
    local pos = context.position
    local target = context.target

    if isNearLocations(pos, EconomyConfig.MarketLocations, 4.0) then
        return true
    end

    if target and recordOrNameMatches(target, EconomyConfig.TargetProps.market) then
        return true
    end

    return false
end)

exports("targetSelectMarket", function(context)
    if GetInvokingResource() ~= "open77_contextmenu" then return false end
    local ok = pcall(function()
        if exports["ls_ui"] and exports["ls_ui"].openVending then
            exports["ls_ui"]:openVending()
        else
            TriggerEvent("ls:ui:openVending")
        end
    end)
    return ok
end)

-- =============================================================================
-- REGISTRO NO SISTEMA ALT TARGET (open77_contextmenu)
-- =============================================================================

local function registerContextMenuActions()
    local definitions = {
        {
            id = "ls_target_atm",
            label = "Terminal Bancário (NC Bank)",
            description = "Acessar transferências, depósitos e saques.",
            group = "Economia",
            icon = "interact",
            types = { "prop", "device", "object", "world" },
            distance = 4.0,
            order = 1,
            canInteract = "targetCanInteractAtm",
            onSelect = "targetSelectAtm",
        },
        {
            id = "ls_target_vending",
            label = "Dispensador All-Foods",
            description = "Comprar alimentos, bebidas e estimulantes.",
            group = "Alimentos",
            icon = "interact",
            types = { "prop", "device", "object", "world" },
            distance = 4.0,
            order = 2,
            canInteract = "targetCanInteractVending",
            onSelect = "targetSelectVending",
        },
        {
            id = "ls_target_ripperdoc",
            label = "Clínica Cirúrgica & Ripperdoc",
            description = "Consultar instalação de implantes e neurobloqueadores.",
            group = "Medicina",
            icon = "tool",
            types = { "prop", "device", "object", "world", "npc" },
            distance = 5.0,
            order = 3,
            canInteract = "targetCanInteractRipperdoc",
            onSelect = "targetSelectRipperdoc",
        },
        {
            id = "ls_target_market",
            label = "Mercado 24/7 & Suprimentos",
            description = "Comprar suprimentos e itens essenciais.",
            group = "Comércio",
            icon = "interact",
            types = { "prop", "device", "object", "world", "npc" },
            distance = 5.0,
            order = 4,
            canInteract = "targetCanInteractMarket",
            onSelect = "targetSelectMarket",
        }
    }

    local pending, reason = Open77.exports.call("open77_contextmenu", "registerMany", definitions)
    if pending then
        local tokens, err = pending:await()
        if tokens then
            print(string.format("[ls_economy] %d ações de ALT Target registradas com sucesso no open77_contextmenu.", #tokens))
            return
        end
        print("[ls_economy] Falha ao registrar ações no open77_contextmenu: " .. tostring(err))
    else
        print("[ls_economy] ContextMenu indisponível: " .. tostring(reason))
    end
end

-- =============================================================================
-- REGISTRO DE CARDS 3D EM MUNDO (open77_interactions)
-- =============================================================================

local function registerWorldInteractions()
    if not exports["open77_interactions"] then return end

    -- 1. Alvos Globais por Modelo/Classe de Props
    pcall(function()
        exports["open77_interactions"]:addModel(EconomyConfig.TargetProps.atm, {
            id = "atm_prop_target",
            marker = "ring",
            color = "#22D8E2",
            distance = 2.5,
            markerDistance = 12.0,
            choices = {
                {
                    id = "open_atm_card",
                    label = "Acessar Terminal ATM",
                    key = "E",
                    event = "ls:economy:openAtmTarget",
                    color = "#22D8E2"
                }
            }
        })
    end)

    pcall(function()
        exports["open77_interactions"]:addModel(EconomyConfig.TargetProps.vending, {
            id = "vending_prop_target",
            marker = "diamond",
            color = "#FCEE0A",
            distance = 2.5,
            markerDistance = 12.0,
            choices = {
                {
                    id = "open_vending_card",
                    label = "Dispensador de Alimentos",
                    key = "E",
                    event = "ls:economy:openVendingTarget",
                    color = "#FCEE0A"
                }
            }
        })
    end)

    -- 2. Zonas Fixas para ATMs
    for _, atm in ipairs(EconomyConfig.AtmLocations or {}) do
        pcall(function()
            exports["open77_interactions"]:addSphereZone({
                id = "zone_" .. atm.id,
                position = { x = atm.x, y = atm.y, z = atm.z },
                radius = atm.radius or 2.5,
                marker = "ring",
                color = "#22D8E2",
                markerDistance = 10.0,
                choices = {
                    {
                        id = "access_atm_" .. atm.id,
                        label = atm.name or "Terminal Bancário",
                        key = "E",
                        event = "ls:economy:openAtmTarget",
                        color = "#22D8E2"
                    }
                }
            })
        end)
    end

    -- 3. Zonas Fixas para Vending Machines
    for _, v in ipairs(EconomyConfig.VendingLocations or {}) do
        pcall(function()
            exports["open77_interactions"]:addSphereZone({
                id = "zone_" .. v.id,
                position = { x = v.x, y = v.y, z = v.z },
                radius = v.radius or 2.5,
                marker = "diamond",
                color = "#FCEE0A",
                markerDistance = 8.0,
                choices = {
                    {
                        id = "access_vending_" .. v.id,
                        label = v.name or "Dispensador All-Foods",
                        key = "E",
                        event = "ls:economy:openVendingTarget",
                        color = "#FCEE0A"
                    }
                }
            })
        end)
    end

    -- 4. Zonas Fixas para Clínicas Ripperdoc
    for _, rip in ipairs(EconomyConfig.RipperdocLocations or {}) do
        pcall(function()
            exports["open77_interactions"]:addSphereZone({
                id = "zone_" .. rip.id,
                position = { x = rip.x, y = rip.y, z = rip.z },
                radius = rip.radius or 3.5,
                marker = "ring",
                color = "#FF003C",
                markerDistance = 12.0,
                choices = {
                    {
                        id = "access_ripper_" .. rip.id,
                        label = rip.name or "Clínica Cirúrgica Ripperdoc",
                        key = "E",
                        event = "ls:economy:openRipperdocTarget",
                        color = "#FF003C"
                    }
                }
            })
        end)
    end

    -- 5. Zonas Fixas para Mercados
    for _, m in ipairs(EconomyConfig.MarketLocations or {}) do
        pcall(function()
            exports["open77_interactions"]:addSphereZone({
                id = "zone_" .. m.id,
                position = { x = m.x, y = m.y, z = m.z },
                radius = m.radius or 3.0,
                marker = "shop",
                color = "#00FF66",
                markerDistance = 10.0,
                choices = {
                    {
                        id = "access_market_" .. m.id,
                        label = m.name or "Mercado de Conveniência 24/7",
                        key = "E",
                        event = "ls:economy:openMarketTarget",
                        color = "#00FF66"
                    }
                }
            })
        end)
    end
end

-- =============================================================================
-- CONTROLE DE VISIBILIDADE / SUPRESSÃO EM MODAIS (ANTI-OVERLAP)
-- =============================================================================

local interactionsEnabled = true

local function setInteractionsVisible(enabled)
    enabled = enabled == true
    if interactionsEnabled == enabled then return end
    interactionsEnabled = enabled
    pcall(function()
        if exports["open77_interactions"] and exports["open77_interactions"].setEnabled then
            exports["open77_interactions"]:setEnabled(enabled)
        end
    end)
end

AddEventHandler("ls:ui:modalStateChanged", function(active)
    setInteractionsVisible(not active)
end)

exports("setInteractionsVisible", setInteractionsVisible)

-- =============================================================================
-- ESCUTADORES DE EVENTOS DE ENTRADA
-- =============================================================================

RegisterNetEvent("ls:economy:openAtmTarget", function()
    setInteractionsVisible(false)
    if exports["ls_ui"] and exports["ls_ui"].openAtm then
        exports["ls_ui"]:openAtm()
    else
        TriggerEvent("ls:ui:openAtm")
    end
end)

RegisterNetEvent("ls:economy:openVendingTarget", function()
    setInteractionsVisible(false)
    if exports["ls_ui"] and exports["ls_ui"].openVending then
        exports["ls_ui"]:openVending()
    else
        TriggerEvent("ls:ui:openVending")
    end
end)

RegisterNetEvent("ls:economy:openRipperdocTarget", function()
    setInteractionsVisible(false)
    if exports["ls_ui"] and exports["ls_ui"].openRipperdoc then
        exports["ls_ui"]:openRipperdoc()
    else
        TriggerEvent("ls:ui:openRipperdoc")
    end
end)

RegisterNetEvent("ls:economy:openMarketTarget", function()
    setInteractionsVisible(false)
    if exports["ls_ui"] and exports["ls_ui"].openVending then
        exports["ls_ui"]:openVending()
    else
        TriggerEvent("ls:ui:openVending")
    end
end)

-- Inicialização e reconciliação em recarregamento
AddEventHandler("onClientResourceStart", function(name)
    if name == resource or name == "open77_contextmenu" then
        registerContextMenuActions()
    end
    if name == resource or name == "open77_interactions" then
        registerWorldInteractions()
    end
end)

AddEventHandler("onClientResourceStop", function(name)
    if name == resource then
        setInteractionsVisible(true)
    end
end)

AddEventHandler("open77:worldReady", function()
    registerContextMenuActions()
    registerWorldInteractions()
end)

