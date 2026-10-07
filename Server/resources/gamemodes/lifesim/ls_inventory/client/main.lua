--[[
    LIFESIM RP - Client Authoritative Inventory & Radial Input Manager
    Path: ls_inventory/client/main.lua
    Controla atalhos de teclado, escuta do Radial Menu e sincronização com a WebUI.
]]

local currentBag = nil
local isInventoryOpen = false
local isRadialOpen = false

-- =============================================================================
-- INICIALIZAÇÃO
-- =============================================================================

AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    TriggerServerEvent("ls:inventory:requestSync")
end)

RegisterNetEvent("ls:core:playerLoaded", function()
    TriggerServerEvent("ls:inventory:requestSync")
end)

-- Sincronização do estado do inventário vindo do servidor
RegisterNetEvent("ls:inventory:syncBag", function(bagData)
    currentBag = bagData
    if bagData and bagData.items then
        for _, it in pairs(bagData.items) do
            if it and it.itemId then
                local def = ItemsCatalog and ItemsCatalog[it.itemId]
                if def then
                    it.name = def.name
                    it.description = def.description
                    it.type = def.type
                    it.rarity = def.rarity
                    it.weight = def.weight
                    it.image = def.image
                    it.ammoType = def.ammoType
                    it.slot = def.slot
                    it.effects = def.effects
                end
            end
        end
    end
    TriggerEvent("ls:ui:syncInventoryBag", bagData)
end)

RegisterNetEvent("ls:inventory:itemUsed", function(data)
    TriggerEvent("ls:ui:notify", {
        type = "success",
        title = "ITEM CONSUMIDO",
        message = data.name .. " utilizado com sucesso."
    })
end)

RegisterNetEvent("ls:inventory:craftProgressStarted", function(data)
    TriggerEvent("ls:ui:craftProgressStarted", data)
end)

RegisterNetEvent("ls:inventory:craftSuccess", function(data)
    TriggerEvent("ls:ui:craftSuccess", data)
    TriggerEvent("ls:ui:notify", {
        type = "success",
        title = "FABRICAÇÃO CONCLUÍDA",
        message = data.label .. " foi adicionado à sua mochila."
    })
end)

RegisterNetEvent("ls:inventory:craftFailed", function(reason)
    TriggerEvent("ls:ui:craftFailed", reason)
    TriggerEvent("ls:ui:notify", {
        type = "error",
        title = "FALHA NA FABRICAÇÃO",
        message = reason
    })
end)

-- Equipamento de arma
RegisterNetEvent("ls:inventory:equipWeapon", function(data)
    TriggerEvent("ls:ui:notify", {
        type = "info",
        title = "ARMA EQUIPADA",
        message = data.name .. " em punho."
    })
    -- Se houver suporte à API de armas do cliente:
    if Open77 and Open77.weapons and Open77.weapons.equip then
        Open77.weapons.equip(data.itemId)
    end
end)

-- Equipamento de vestuário
RegisterNetEvent("ls:inventory:equipClothing", function(data)
    TriggerEvent("ls:ui:notify", {
        type = "info",
        title = "VESTUÁRIO EQUIPADO",
        message = data.name .. " vestido no slot [" .. tostring(data.slot or "geral"):upper() .. "]."
    })
end)

-- =============================================================================
-- ENCAMINHAMENTO DE AÇÕES DA UI PARA O SERVIDOR
-- =============================================================================

RegisterNetEvent("ls:inventory:clientMoveItem", function(fromSlot, toSlot)
    TriggerServerEvent("ls:inventory:moveItem", fromSlot, toSlot)
end)

RegisterNetEvent("ls:inventory:clientUseItem", function(slot)
    TriggerServerEvent("ls:inventory:useItem", slot)
end)

RegisterNetEvent("ls:inventory:clientStartCraft", function(recipeId)
    TriggerServerEvent("ls:inventory:startCrafting", recipeId)
end)

-- =============================================================================
-- COMANDOS E ATALHOS DE TECLADO NATIVOS
-- =============================================================================

RegisterNetEvent("ls:inventory:closedFromUI", function()
    isInventoryOpen = false
end)

RegisterCommand("inventory", function()
    isInventoryOpen = not isInventoryOpen
    TriggerEvent("ls:ui:toggleInventoryModal", isInventoryOpen)
end, false)

RegisterCommand("inv", function()
    isInventoryOpen = not isInventoryOpen
    TriggerEvent("ls:ui:toggleInventoryModal", isInventoryOpen)
end, false)

RegisterCommand("mochila", function()
    isInventoryOpen = not isInventoryOpen
    TriggerEvent("ls:ui:toggleInventoryModal", isInventoryOpen)
end, false)

RegisterCommand("radial", function()
    if isInventoryOpen then return end
    isRadialOpen = not isRadialOpen
    TriggerEvent("ls:ui:setRadialState", isRadialOpen)
end, false)

RegisterCommand("+radialmenu", function()
    if isInventoryOpen then return end
    isRadialOpen = true
    TriggerEvent("ls:ui:setRadialState", true)
end, false)

RegisterCommand("-radialmenu", function()
    if not isRadialOpen then return end
    isRadialOpen = false
    TriggerEvent("ls:ui:setRadialState", false)
end, false)

-- Comando informativo para ensinar o jogador a reconfigurar atalhos no menu Pause do motor
RegisterCommand("keybinds", function()
    TriggerEvent("ls:ui:notify", {
        type = "info",
        title = "CONFIGURAÇÃO DE TECLAS",
        message = "Para redefinir as teclas da Mochila ou do Menu Radial: Pressione ESC > Configurações (Settings) > Atalhos de Teclado (KEY BINDINGS)."
    })
end, false)

RegisterCommand("atalhos", function()
    TriggerEvent("ls:ui:notify", {
        type = "info",
        title = "CONFIGURAÇÃO DE TECLAS",
        message = "Para redefinir as teclas da Mochila ou do Menu Radial: Pressione ESC > Configurações (Settings) > Atalhos de Teclado (KEY BINDINGS)."
    })
end, false)

-- Registro canônico no motor OPEN//77 (visível e reconfigurável na aba KEY BINDINGS do Pause Menu)
local function initKeyBindings()
    local invKey = (InventoryConfig and InventoryConfig.Keys and InventoryConfig.Keys.inventory) or "I"
    local radKey = (InventoryConfig and InventoryConfig.Keys and InventoryConfig.Keys.radial) or "CAPSLOCK"

    local invSpec = {
        id = "inventory_toggle",
        name = "Mochila Kiroshi (Inventário)",
        key = invKey,
        onPressed = function()
            isInventoryOpen = not isInventoryOpen
            TriggerEvent("ls:ui:toggleInventoryModal", isInventoryOpen)
        end
    }

    local radSpec = {
        id = "radial_menu_hold",
        name = "Menu Radial Rápido (Segurar)",
        key = radKey,
        hold = true,
        onPressed = function()
            if isInventoryOpen then return end
            isRadialOpen = true
            TriggerEvent("ls:ui:setRadialState", true)
        end,
        onReleased = function()
            if not isRadialOpen then return end
            isRadialOpen = false
            TriggerEvent("ls:ui:setRadialState", false)
        end
    }

    if Open77 and Open77.input and Open77.input.registerKeyMapping then
        local okInv, effInv = Open77.input.registerKeyMapping(invSpec)
        Open77.log.info(("[ls_inventory] Mapeamento 'inventory_toggle' [%s]: %s (ativo: %s)"):format(
            tostring(invKey), okInv and "registrado" or "recusado", tostring(effInv)
        ))
        local okRad, effRad = Open77.input.registerKeyMapping(radSpec)
        Open77.log.info(("[ls_inventory] Mapeamento 'radial_menu_hold' [%s]: %s (ativo: %s)"):format(
            tostring(radKey), okRad and "registrado" or "recusado", tostring(effRad)
        ))
    elseif type(RegisterKeyMapping) == "function" then
        RegisterKeyMapping(invSpec.id, invSpec.name, invSpec.key, invSpec.onPressed)
        RegisterKeyMapping(radSpec.id, radSpec.name, radSpec.key, radSpec.onPressed, radSpec.onReleased)
    end
end

initKeyBindings()

