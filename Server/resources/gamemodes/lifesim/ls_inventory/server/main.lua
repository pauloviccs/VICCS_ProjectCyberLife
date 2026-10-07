--[[
    LIFESIM RP - Server Authoritative Inventory & Crafting Manager
    Path: ls_inventory/server/main.lua
    Gerencia persistência em MariaDB, validação server-side de pesos,
    movimentação de itens, consumo e manufatura atômica de receitas.
]]

local activeInventories = {} -- [src] = { invId = int, charId = int, maxWeight = int, maxSlots = int, items = { [slot] = item } }
local craftingStates = {}    -- [src] = { recipeId = str, finishesAt = int }
local isReady = false

-- =============================================================================
-- CAMADA DE BANCO DE DADOS RESILIENTE (Database Adapter)
-- =============================================================================

local Database = {}

Database.query = function(sql, params)
    params = params or {}
    local ok, rows = pcall(function()
        if MySQL and MySQL.query and MySQL.query.await then
            return MySQL.query.await(sql, params)
        elseif Open77 and Open77.database and Open77.database.query and Open77.database.query.await then
            return Open77.database.query.await(sql, params)
        elseif exports and exports["ls_data"] and exports["ls_data"].query then
            return exports["ls_data"]:query(sql, params)
        end
        return nil
    end)
    if ok and type(rows) == "table" then return rows end
    return {}
end

Database.single = function(sql, params)
    params = params or {}
    local rows = Database.query(sql, params)
    if rows and #rows > 0 then return rows[1] end
    return nil
end

Database.update = function(sql, params)
    params = params or {}
    local ok, res = pcall(function()
        if MySQL and MySQL.update and MySQL.update.await then
            return MySQL.update.await(sql, params)
        elseif Open77 and Open77.database and Open77.database.update and Open77.database.update.await then
            return Open77.database.update.await(sql, params)
        elseif exports and exports["ls_data"] and exports["ls_data"].update then
            return exports["ls_data"]:update(sql, params)
        end
        return nil
    end)
    if ok and res ~= nil then return res end
    return 0
end

Database.insert = function(sql, params)
    params = params or {}
    local ok, insertId = pcall(function()
        if MySQL and MySQL.insert and MySQL.insert.await then
            return MySQL.insert.await(sql, params)
        end
        Database.update(sql, params)
        local last = Database.query("SELECT LAST_INSERT_ID() AS id", {})
        if last and last[1] and last[1].id then
            return tonumber(last[1].id)
        end
        return 1
    end)
    if ok and insertId then return insertId end
    return 1
end

-- =============================================================================
-- INICIALIZAÇÃO & MIGRAÇÕES
-- =============================================================================

CreateThread(function()
    -- 1. Aguarda prontidão da camada de dados
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registra e aplica migrações de inventário
    local migrations = {
        {
            version = 1,
            checksum = "base_ls_inventory_schema_v1",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_inventories (
                    inventory_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                    owner_type VARCHAR(32) NOT NULL DEFAULT 'character',
                    owner_id VARCHAR(64) NOT NULL,
                    max_weight INT NOT NULL DEFAULT 35000,
                    max_slots INT NOT NULL DEFAULT 40,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    UNIQUE KEY uq_ls_inv_owner (owner_type, owner_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

                CREATE TABLE IF NOT EXISTS ls_inventory_items (
                    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                    inventory_id BIGINT UNSIGNED NOT NULL,
                    item_id VARCHAR(64) NOT NULL,
                    slot INT NOT NULL,
                    count INT NOT NULL DEFAULT 1,
                    metadata LONGTEXT NOT NULL DEFAULT '{}',
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_ls_inv_slot (inventory_id, slot),
                    CONSTRAINT fk_ls_inv_items_parent FOREIGN KEY (inventory_id) REFERENCES ls_inventories(inventory_id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            ]]
        }
    }

    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_inventory", migrations)
    if migCall then migCall:await() end

    -- Garantir idempotência das tabelas
    Database.update([[
        CREATE TABLE IF NOT EXISTS ls_inventories (
            inventory_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            owner_type VARCHAR(32) NOT NULL DEFAULT 'character',
            owner_id VARCHAR(64) NOT NULL,
            max_weight INT NOT NULL DEFAULT 35000,
            max_slots INT NOT NULL DEFAULT 40,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uq_ls_inv_owner (owner_type, owner_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    Database.update([[
        CREATE TABLE IF NOT EXISTS ls_inventory_items (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            inventory_id BIGINT UNSIGNED NOT NULL,
            item_id VARCHAR(64) NOT NULL,
            slot INT NOT NULL,
            count INT NOT NULL DEFAULT 1,
            metadata LONGTEXT NOT NULL DEFAULT '{}',
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_ls_inv_slot (inventory_id, slot),
            CONSTRAINT fk_ls_inv_items_parent FOREIGN KEY (inventory_id) REFERENCES ls_inventories(inventory_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- 3. Registrar módulo no ls_core
    local regCall = Open77.exports.call("ls_core", "registerModule", {
        version = "0.1.0",
        requires = { "ls_data", "ls_core" },
        provides = {
            "AddItem",
            "RemoveItem",
            "GetPlayerInventory"
        },
        emits = {
            "ls:inventory:syncBag",
            "ls:inventory:itemUsed",
            "ls:inventory:craftSuccess"
        },
        listens = { "ls:core:characterSelected", "playerDropped" },
        tables = { "ls_inventories", "ls_inventory_items" }
    })
    if regCall then regCall:await() end

    isReady = true
    Open77.log.info("[ls_inventory] Motor de Inventário e Crafting Inicializado com Sucesso.")
end)

-- =============================================================================
-- UTILITÁRIOS INTERNOS
-- =============================================================================

local function getUnixTime()
    if Open77 and Open77.time and Open77.time.unix then
        return Open77.time.unix()
    elseif GetUnixTime then
        return GetUnixTime()
    end
    return 0
end

local function calculateTotalWeight(items)
    local weight = 0
    for _, item in pairs(items) do
        local def = ItemsCatalog[item.itemId]
        local itemWeight = def and def.weight or 100
        weight = weight + (itemWeight * (item.count or 1))
    end
    return weight
end

local function findFreeSlot(items, maxSlots)
    maxSlots = tonumber(maxSlots) or 40
    for s = 1, maxSlots do
        if not items[s] and not items[tostring(s)] then
            return s
        end
    end
    return nil
end

-- =============================================================================
-- CARREGAMENTO E CRIAÇÃO DO INVENTÁRIO DO JOGADOR
-- =============================================================================

-- =============================================================================
-- RESOLUÇÃO DE IDENTIDADE CANÔNICA DO JOGADOR
-- =============================================================================

local function resolvePlayerLicense(src)
    if not src or src <= 0 then return nil end

    -- 1. Tentar obter da sessão oficial do ls_core
    local ok, session = pcall(function()
        return exports["ls_core"]:getSession(src)
    end)
    if ok and session and session.license and session.license ~= "" then
        return session.license
    end

    -- 2. Tentar obter dos identificadores oficiais da plataforma OPEN//77
    local ids = (Open77 and Open77.players and Open77.players.identifiers and Open77.players.identifiers(src)) or {}
    local rawLicense = ids.license
    if not rawLicense or rawLicense == "" then
        if GetPlayerIdentifierByType then
            pcall(function() rawLicense = GetPlayerIdentifierByType(src, "license") end)
        end
    end

    if type(rawLicense) == "string" and rawLicense ~= "" then
        local lic = rawLicense:gsub("%-", ""):lower()
        if #lic < 32 then
            lic = (lic .. string.rep("0", 32)):sub(1, 32)
        else
            lic = lic:sub(1, 32)
        end
        return lic
    end

    -- 3. Fallback determinístico seguro para desenvolvimento/LAN
    local fallback = "dev_" .. tostring(src)
    return (fallback .. string.rep("0", 32)):sub(1, 32)
end

-- =============================================================================
-- CARREGAMENTO E CRIAÇÃO DO INVENTÁRIO DO JOGADOR
-- =============================================================================

local function grantStarterKit(invId)
    local kit = {
        { item = "weapon_unity", slot = 1, count = 1 },
        { item = "ammo_handgun", slot = 2, count = 40 },
        { item = "burrito_xxl", slot = 3, count = 3 },
        { item = "clean_water", slot = 4, count = 3 },
        { item = "maxdoc_mk1", slot = 5, count = 2 },
        { item = "component_common", slot = 6, count = 25 },
        { item = "metal_scrap", slot = 7, count = 20 }
    }

    for _, entry in ipairs(kit) do
        Database.insert(
            "INSERT INTO ls_inventory_items (inventory_id, item_id, slot, count, metadata) VALUES (?, ?, ?, ?, '{}')",
            { invId, entry.item, entry.slot, entry.count }
        )
    end
end

local function loadPlayerInventory(src, license)
    if not src or src <= 0 then return end
    license = license or resolvePlayerLicense(src)
    if not license then return end

    CreateThread(function()
        -- 1. Buscar ou criar registro na tabela ls_inventories
        local invRow = Database.single(
            "SELECT inventory_id, max_weight, max_slots FROM ls_inventories WHERE owner_type = 'character' AND owner_id = ?",
            { tostring(license) }
        )

        local invId, maxWeight, maxSlots
        local isBrandNew = false

        if not invRow then
            local insertId = Database.insert(
                "INSERT INTO ls_inventories (owner_type, owner_id, max_weight, max_slots, created_at, updated_at) VALUES ('character', ?, ?, ?, NOW(), NOW())",
                { tostring(license), InventoryConfig.Bag.maxWeight, InventoryConfig.Bag.slots }
            )
            invId = insertId
            maxWeight = InventoryConfig.Bag.maxWeight
            maxSlots = InventoryConfig.Bag.slots
            isBrandNew = true

            grantStarterKit(invId)
        else
            invId = invRow.inventory_id
            maxWeight = invRow.max_weight
            maxSlots = invRow.max_slots
        end

        -- 2. Carregar itens do inventário
        local itemRows = Database.query(
            "SELECT id, item_id, slot, count, metadata FROM ls_inventory_items WHERE inventory_id = ?",
            { invId }
        ) or {}

        -- Se a conta já existia no banco mas estava sem itens, concede o kit de sobrevivência
        if not isBrandNew and #itemRows == 0 then
            grantStarterKit(invId)
            itemRows = Database.query(
                "SELECT id, item_id, slot, count, metadata FROM ls_inventory_items WHERE inventory_id = ?",
                { invId }
            ) or {}
        end

        local itemsMap = {}
        for _, row in ipairs(itemRows) do
            local meta = {}
            if row.metadata and type(row.metadata) == "string" and row.metadata ~= "" then
                pcall(function() meta = json.decode(row.metadata) end)
            end
            local slotNum = tonumber(row.slot) or row.slot
            itemsMap[slotNum] = {
                dbId = row.id,
                itemId = row.item_id,
                slot = slotNum,
                count = row.count or 1,
                metadata = meta
            }
        end

        activeInventories[src] = {
            invId = invId,
            license = license,
            maxWeight = maxWeight,
            maxSlots = maxSlots,
            items = itemsMap
        }

        Open77.log.info(("[ls_inventory] Inventário sincronizado para jogador [%d] (Licença: %s, Itens: %d, Peso: %dg)"):format(
            src, license, #itemRows, calculateTotalWeight(itemsMap)
        ))

        -- Sincronizar estado com o cliente
        TriggerClientEvent("ls:inventory:syncBag", src, {
            invId = invId,
            maxWeight = maxWeight,
            maxSlots = maxSlots,
            currentWeight = calculateTotalWeight(itemsMap),
            items = itemsMap
        })
    end)
end

-- =============================================================================
-- EVENTOS DE REDE & CICLO DE VIDA DO JOGADOR
-- =============================================================================

-- Evento canônico disparado por ls_core quando o perfil do jogador estiver totalmente carregado
AddEventHandler("ls:core:playerLoaded", function(playerId, license)
    loadPlayerInventory(playerId, license)
end)

-- Suporte a hot-reload: carregar inventários para todos os jogadores já conectados
AddEventHandler("onResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(1000)
        for _, playerId in ipairs(Open77.players.all()) do
            local license = resolvePlayerLicense(playerId)
            if license then
                loadPlayerInventory(playerId, license)
            end
        end
    end)
end)

RegisterNetEvent("ls:inventory:requestSync", function()
    local src = source
    local inv = activeInventories[src]
    if inv then
        TriggerClientEvent("ls:inventory:syncBag", src, {
            invId = inv.invId,
            maxWeight = inv.maxWeight,
            maxSlots = inv.maxSlots,
            currentWeight = calculateTotalWeight(inv.items),
            items = inv.items
        })
    else
        local license = resolvePlayerLicense(src)
        if license then
            loadPlayerInventory(src, license)
        end
    end
end)

RegisterNetEvent("ls:core:characterSelected", function(charId)
    local src = source
    local license = resolvePlayerLicense(src)
    loadPlayerInventory(src, license)
end)

AddEventHandler("playerDropped", function()
    local src = source
    activeInventories[src] = nil
    craftingStates[src] = nil
end)

-- Mover ou mesclar itens entre slots
RegisterNetEvent("ls:inventory:moveItem", function(fromSlot, toSlot)
    local src = source
    local inv = activeInventories[src]
    if not inv then return end

    fromSlot = tonumber(fromSlot)
    toSlot = tonumber(toSlot)
    if not fromSlot or not toSlot or fromSlot == toSlot then return end
    if fromSlot < 1 or fromSlot > inv.maxSlots or toSlot < 1 or toSlot > inv.maxSlots then return end

    local sourceItem = inv.items[fromSlot]
    if not sourceItem then return end

    local targetItem = inv.items[toSlot]

    CreateThread(function()
        if not targetItem then
            -- Mover para slot vazio
            sourceItem.slot = toSlot
            inv.items[toSlot] = sourceItem
            inv.items[fromSlot] = nil

            Database.update(
                "UPDATE ls_inventory_items SET slot = ? WHERE id = ?",
                { toSlot, sourceItem.dbId }
            )
        elseif targetItem.itemId == sourceItem.itemId then
            -- Mesclar itens iguais se couber no max_stack
            local def = ItemsCatalog[sourceItem.itemId]
            local maxStack = def and def.max_stack or 100
            local spaceLeft = maxStack - targetItem.count

            if spaceLeft > 0 then
                local transferCount = math.min(spaceLeft, sourceItem.count)
                targetItem.count = targetItem.count + transferCount
                sourceItem.count = sourceItem.count - transferCount

                if sourceItem.count <= 0 then
                    inv.items[fromSlot] = nil
                    Database.update("DELETE FROM ls_inventory_items WHERE id = ?", { sourceItem.dbId })
                else
                    Database.update("UPDATE ls_inventory_items SET count = ? WHERE id = ?", { sourceItem.count, sourceItem.dbId })
                end

                Database.update("UPDATE ls_inventory_items SET count = ? WHERE id = ?", { targetItem.count, targetItem.dbId })
            else
                -- Trocar slots
                sourceItem.slot = toSlot
                targetItem.slot = fromSlot
                inv.items[toSlot] = sourceItem
                inv.items[fromSlot] = targetItem

                Database.update("UPDATE ls_inventory_items SET slot = ? WHERE id = ?", { toSlot, sourceItem.dbId })
                Database.update("UPDATE ls_inventory_items SET slot = ? WHERE id = ?", { fromSlot, targetItem.dbId })
            end
        else
            -- Trocar itens diferentes de lugar
            sourceItem.slot = toSlot
            targetItem.slot = fromSlot
            inv.items[toSlot] = sourceItem
            inv.items[fromSlot] = targetItem

            Database.update("UPDATE ls_inventory_items SET slot = ? WHERE id = ?", { toSlot, sourceItem.dbId })
            Database.update("UPDATE ls_inventory_items SET slot = ? WHERE id = ?", { fromSlot, targetItem.dbId })
        end

        TriggerClientEvent("ls:inventory:syncBag", src, {
            invId = inv.invId,
            maxWeight = inv.maxWeight,
            maxSlots = inv.maxSlots,
            currentWeight = calculateTotalWeight(inv.items),
            items = inv.items
        })
    end)
end)

-- Consumo / Uso de item
RegisterNetEvent("ls:inventory:useItem", function(slot)
    local src = source
    local inv = activeInventories[src]
    if not inv then return end

    slot = tonumber(slot)
    if not slot or not inv.items[slot] then return end

    local item = inv.items[slot]
    local def = ItemsCatalog[item.itemId]
    if not def then return end

    CreateThread(function()
        if def.type == "consumable" or def.type == "medical" then
            -- 1. Aplicar efeitos corporais (vitals / cyberware)
            if def.effects then
                TriggerEvent("ls:vitals:applyEffects", src, def.effects)
                if def.effects.stability then
                    TriggerEvent("ls:cyberware:modifyStability", src, def.effects.stability)
                end
            end
            if def.type == "medical" then
                TriggerEvent("ls:cyberware:applyPharmaceutical", src, item.itemId)
            end

            -- 2. Consumir 1 unidade do item
            item.count = item.count - 1
            if item.count <= 0 then
                inv.items[slot] = nil
                Database.update("DELETE FROM ls_inventory_items WHERE id = ?", { item.dbId })
            else
                Database.update("UPDATE ls_inventory_items SET count = ? WHERE id = ?", { item.count, item.dbId })
            end

            TriggerClientEvent("ls:inventory:itemUsed", src, {
                itemId = item.itemId,
                name = def.name,
                effects = def.effects
            })

            TriggerClientEvent("ls:inventory:syncBag", src, {
                invId = inv.invId,
                maxWeight = inv.maxWeight,
                maxSlots = inv.maxSlots,
                currentWeight = calculateTotalWeight(inv.items),
                items = inv.items
            })
        elseif def.type == "weapon" then
            -- Armas: Equipa no personagem do cliente
            TriggerClientEvent("ls:inventory:equipWeapon", src, {
                itemId = item.itemId,
                name = def.name,
                ammoType = def.ammoType
            })
        elseif def.type == "clothing" then
            -- Vestuário: Notifica cliente e equipa peça
            TriggerClientEvent("ls:inventory:equipClothing", src, {
                itemId = item.itemId,
                name = def.name,
                slot = def.slot
            })
        end
    end)
end)

-- =============================================================================
-- SISTEMA DE CRAFTING SERVER-AUTHORITATIVE
-- =============================================================================

RegisterNetEvent("ls:inventory:startCrafting", function(recipeId)
    local src = source
    local inv = activeInventories[src]
    if not inv then return end

    local recipe = nil
    for _, r in ipairs(CraftingRecipes) do
        if r.id == recipeId then
            recipe = r
            break
        end
    end
    if not recipe then return end

    -- 1. Verificar se o jogador já não está craftando
    if craftingStates[src] then
        TriggerClientEvent("ls:inventory:craftFailed", src, "Você já está fabricando outro item.")
        return
    end

    -- 2. Contar materiais disponíveis na mochila
    local availableMaterials = {}
    for _, item in pairs(inv.items) do
        availableMaterials[item.itemId] = (availableMaterials[item.itemId] or 0) + item.count
    end

    -- 3. Validar se tem todos os insumos necessários
    for _, input in ipairs(recipe.inputs) do
        local has = availableMaterials[input.item] or 0
        if has < input.count then
            TriggerClientEvent("ls:inventory:craftFailed", src, "Materiais insuficientes para fabricação.")
            return
        end
    end

    -- 4. Validar se o produto final cabe no peso do inventário
    local outputDef = ItemsCatalog[recipe.output.item]
    local addedWeight = (outputDef and outputDef.weight or 100) * recipe.output.count
    local currentWeight = calculateTotalWeight(inv.items)
    if currentWeight + addedWeight > inv.maxWeight then
        TriggerClientEvent("ls:inventory:craftFailed", src, "Carga excessiva! A mochila não suporta este item.")
        return
    end

    -- 5. Bloquear e iniciar o estado de crafting
    craftingStates[src] = {
        recipeId = recipe.id,
        finishesAt = getUnixTime() + recipe.timeSec
    }

    TriggerClientEvent("ls:inventory:craftProgressStarted", src, {
        recipeId = recipe.id,
        label = recipe.label,
        timeSec = recipe.timeSec
    })

    -- 6. Executar débito de materiais e geração do produto após o timer
    SetTimeout(recipe.timeSec * 1000, function()
        if not activeInventories[src] or not craftingStates[src] then return end
        craftingStates[src] = nil

        CreateThread(function()
            -- Débito atômico de cada material requerido
            for _, input in ipairs(recipe.inputs) do
                local needed = input.count
                for slot, item in pairs(inv.items) do
                    if item.itemId == input.item and needed > 0 then
                        local take = math.min(needed, item.count)
                        item.count = item.count - take
                        needed = needed - take

                        if item.count <= 0 then
                            inv.items[slot] = nil
                            Database.update("DELETE FROM ls_inventory_items WHERE id = ?", { item.dbId })
                        else
                            Database.update("UPDATE ls_inventory_items SET count = ? WHERE id = ?", { item.count, item.dbId })
                        end
                    end
                end
            end

            -- Adicionar o produto fabricado
            local freeSlot = findFreeSlot(inv.items, inv.maxSlots)
            if freeSlot then
                local insertId = Database.insert(
                    "INSERT INTO ls_inventory_items (inventory_id, item_id, slot, count, metadata) VALUES (?, ?, ?, ?, '{}')",
                    { inv.invId, recipe.output.item, freeSlot, recipe.output.count }
                )
                inv.items[freeSlot] = {
                    dbId = insertId,
                    itemId = recipe.output.item,
                    slot = freeSlot,
                    count = recipe.output.count,
                    metadata = {}
                }
            end

            TriggerClientEvent("ls:inventory:craftSuccess", src, {
                recipeId = recipe.id,
                label = recipe.label,
                output = recipe.output
            })

            TriggerClientEvent("ls:inventory:syncBag", src, {
                invId = inv.invId,
                maxWeight = inv.maxWeight,
                maxSlots = inv.maxSlots,
                currentWeight = calculateTotalWeight(inv.items),
                items = inv.items
            })
        end)
    end)
end)

-- =============================================================================
-- EXPORTS E API DE MANIPULAÇÃO DE ITENS
-- =============================================================================

local function internalAddItem(...)
    local args = { ... }
    local src, itemId, count, metadata
    if type(args[1]) == "table" or type(args[1]) == "userdata" then
        src = tonumber(args[2])
        itemId = args[3]
        count = args[4]
        metadata = args[5]
    else
        src = tonumber(args[1])
        itemId = args[2]
        count = args[3]
        metadata = args[4]
    end

    if not src or src <= 0 then
        Open77.log.warn(("[ls_inventory] internalAddItem chamado com source inválido: %s"):format(tostring(args[1])))
        return false, "invalid_source"
    end
    if not itemId or type(itemId) ~= "string" then
        Open77.log.warn(("[ls_inventory] internalAddItem chamado com itemId inválido: %s"):format(tostring(itemId)))
        return false, "invalid_item_id"
    end
    itemId = itemId:lower()
    local def = ItemsCatalog[itemId]
    if not def then
        Open77.log.warn(("[ls_inventory] Tentativa de adicionar item desconhecido: %s"):format(tostring(itemId)))
        return false, "unknown_item"
    end
    count = math.max(1, tonumber(count) or 1)
    metadata = metadata or {}

    local inv = activeInventories[src]
    if not inv then
        local license = resolvePlayerLicense(src)
        if license then
            local invRow = Database.single(
                "SELECT inventory_id, max_weight, max_slots FROM ls_inventories WHERE owner_type = 'character' AND owner_id = ?",
                { tostring(license) }
            )
            if invRow then
                local itemRows = Database.query(
                    "SELECT id, item_id, slot, count, metadata FROM ls_inventory_items WHERE inventory_id = ?",
                    { invRow.inventory_id }
                ) or {}
                local itemsMap = {}
                for _, row in ipairs(itemRows) do
                    local meta = {}
                    if row.metadata and type(row.metadata) == "string" and row.metadata ~= "" then
                        pcall(function() meta = json.decode(row.metadata) end)
                    end
                    local slotNum = tonumber(row.slot) or row.slot
                    itemsMap[slotNum] = {
                        dbId = row.id,
                        itemId = row.item_id,
                        slot = slotNum,
                        count = row.count or 1,
                        metadata = meta
                    }
                end
                inv = {
                    invId = invRow.inventory_id,
                    license = license,
                    maxWeight = invRow.max_weight,
                    maxSlots = invRow.max_slots,
                    items = itemsMap
                }
                activeInventories[src] = inv
            end
        end
    end

    if not inv then return false, "inventory_not_loaded" end

    -- Checar limite de peso antes de processar
    local currentWeight = calculateTotalWeight(inv.items)
    local itemWeight = def.weight or 100
    if currentWeight + (itemWeight * count) > inv.maxWeight then
        Open77.log.warn(("[ls_inventory] Mochila de [%d] excederia peso (%dg + %dg > %dg)"):format(
            src, currentWeight, itemWeight * count, inv.maxWeight
        ))
        return false, "weight_limit_exceeded"
    end

    local maxStack = def.max_stack or 20
    local remaining = count

    -- 1. Tentar empilhar em slots existentes com o mesmo item
    if maxStack > 1 then
        for slot, slotItem in pairs(inv.items) do
            if slotItem.itemId == itemId and slotItem.count < maxStack then
                local space = maxStack - slotItem.count
                local toAdd = math.min(space, remaining)
                slotItem.count = slotItem.count + toAdd
                remaining = remaining - toAdd

                Database.update(
                    "UPDATE ls_inventory_items SET count = ? WHERE id = ?",
                    { slotItem.count, slotItem.dbId }
                )

                if remaining <= 0 then break end
            end
        end
    end

    -- 2. Alocar slots livres para o restante
    while remaining > 0 do
        local freeSlot = findFreeSlot(inv.items, inv.maxSlots)
        if not freeSlot then
            break
        end

        local toAdd = math.min(maxStack, remaining)
        remaining = remaining - toAdd

        local metaJson = "{}"
        if type(metadata) == "table" and next(metadata) ~= nil then
            pcall(function() metaJson = json.encode(metadata) end)
        end

        local insertId = Database.insert(
            "INSERT INTO ls_inventory_items (inventory_id, item_id, slot, count, metadata) VALUES (?, ?, ?, ?, ?)",
            { inv.invId, itemId, freeSlot, toAdd, metaJson }
        )

        inv.items[freeSlot] = {
            dbId = insertId,
            itemId = itemId,
            slot = freeSlot,
            count = toAdd,
            metadata = metadata
        }
    end

    local updatedWeight = calculateTotalWeight(inv.items)

    -- Sincronizar com cliente
    TriggerClientEvent("ls:inventory:syncBag", src, {
        invId = inv.invId,
        maxWeight = inv.maxWeight,
        maxSlots = inv.maxSlots,
        currentWeight = updatedWeight,
        items = inv.items
    })

    if remaining > 0 then
        Open77.log.warn(("[ls_inventory] Mochila de [%d] sem slots livres suficientes para '%s'"):format(src, itemId))
        return false, "partial_slots_full"
    end

    Open77.log.info(("[ls_inventory] Item '%s' (x%d) adicionado com sucesso ao inventário de [%d]"):format(
        itemId, count, src
    ))
    return true, "success"
end

exports("AddItem", function(...)
    return internalAddItem(...)
end)

exports("addItem", function(...)
    return internalAddItem(...)
end)

AddEventHandler("ls:inventory:addItem", function(src, itemId, count, metadata, cb)
    local ok, reason = internalAddItem(src, itemId, count, metadata)
    if cb and type(cb) == "function" then
        cb(ok, reason)
    end
end)

exports("GetPlayerInventory", function(src)
    return activeInventories[tonumber(src)]
end)

exports("getPlayerInventory", function(src)
    return activeInventories[tonumber(src)]
end)

-- Comando administrativo para spawn e teste de itens
RegisterCommand("giveitem", function(source, args)
    local src = source
    if src ~= 0 and not isAuthorizedAdmin(src) then return end

    local targetSrc = src
    local itemId = args[1]
    local count = tonumber(args[2]) or 1

    if args[3] then
        targetSrc = tonumber(args[1]) or src
        itemId = args[2]
        count = tonumber(args[3]) or 1
    end

    if not itemId then
        local msg = "Uso: /giveitem <itemId> [count] (ex: /giveitem weapon_nue 1)"
        TriggerClientEvent("open77:chat:addMessage", src, { color = { 252, 238, 10 }, args = { "INVENTÁRIO", msg } })
        return
    end

    local ok, res = internalAddItem(targetSrc, itemId, count)
    local feedback = ok and ("Item '%s' (x%d) entregue com sucesso."):format(itemId, count)
                       or ("Falha ao entregar item: %s"):format(tostring(res))
    TriggerClientEvent("open77:chat:addMessage", src, { color = ok and { 34, 216, 226 } or { 255, 60, 60 }, args = { "INVENTÁRIO", feedback } })
end, false)
