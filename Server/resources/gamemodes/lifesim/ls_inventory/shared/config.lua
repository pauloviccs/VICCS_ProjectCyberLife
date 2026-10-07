--[[
    LIFESIM RP - Inventory & Crafting Configuration
    Path: ls_inventory/shared/config.lua
]]

InventoryConfig = {
    -- Capacidade da mochila pessoal
    Bag = {
        slots = 40,
        maxWeight = 35000, -- 35 kg em gramas
    },

    -- Capacidade de baús fixos (apartamentos)
    Stash = {
        slots = 60,
        maxWeight = 100000, -- 100 kg em gramas
    },

    -- Capacidade de porta-malas veicular
    Trunk = {
        slots = 30,
        maxWeight = 80000, -- 80 kg em gramas
    },

    -- Alcance em metros para abrir baú/porta-malas ou usar bancadas
    ReachDistance = 3.0,

    -- Atalhos de teclado padrão (reconfiguráveis nas opções do jogo)
    Keys = {
        inventory = "I",
        radial = "CAPSLOCK"
    },

    -- Limite de taxa de requisições do inventário (segurança contra macro/spam)
    RateLimit = {
        windowMs = 1000,
        maxRequests = 15
    },

    -- Configuração do Quick Radial Menu (Equipamentos, Armas, Consumíveis)
    Radial = {
        maxSectors = 8,
        deadzoneRadius = 45, -- px no centro da roda
        wheelRadius = 180,   -- px de raio externo
    }
}
