--[[
    LIFESIM RP - Crafting Recipes
    Path: ls_inventory/shared/crafting_recipes.lua
    Tabela oficial de blueprints e fórmulas de manufatura com ingredientes e tempo.
]]

CraftingRecipes = {
    -- =========================================================================
    -- CATEGORIA: ARMAMENTO
    -- =========================================================================
    {
        id = "craft_unity",
        label = "Constitutional Arms Unity (9mm)",
        category = "weapons",
        output = { item = "weapon_unity", count = 1 },
        timeSec = 6,
        description = "Montagem de pistola tática semiautomática utilizando polímero reforçado e câmara de 9mm.",
        inputs = {
            { item = "component_common", count = 15 },
            { item = "component_uncommon", count = 8 },
            { item = "metal_scrap", count = 10 }
        }
    },
    {
        id = "craft_lexington",
        label = "Militech M-10AF Lexington",
        category = "weapons",
        output = { item = "weapon_lexington", count = 1 },
        timeSec = 8,
        description = "Usinagem de pistola automática de alta dispersão com controle eletrônico de cadência.",
        inputs = {
            { item = "component_uncommon", count = 20 },
            { item = "metal_scrap", count = 15 },
            { item = "microchip", count = 1 }
        }
    },
    {
        id = "craft_nue",
        label = "Tsunami Nue (Armação de Precisão)",
        category = "weapons",
        output = { item = "weapon_nue", count = 1 },
        timeSec = 10,
        description = "Pistola japonesa forjada sob tolerâncias microscópicas. Alto recuo, impacto letal.",
        inputs = {
            { item = "component_rare", count = 15 },
            { item = "component_uncommon", count = 12 },
            { item = "upgrade_part", count = 2 }
        }
    },
    {
        id = "craft_copperhead",
        label = "Nokota Copperhead (Assault Rifle)",
        category = "weapons",
        output = { item = "weapon_copperhead", count = 1 },
        timeSec = 12,
        description = "Fuzil de assalto de combate urbano com receptor de aço estampado e coronha dobrável.",
        inputs = {
            { item = "component_uncommon", count = 25 },
            { item = "component_rare", count = 15 },
            { item = "upgrade_part", count = 3 },
            { item = "metal_scrap", count = 20 }
        }
    },
    {
        id = "craft_crusher",
        label = "Rostović Crusher (Auto-Shotgun)",
        category = "weapons",
        output = { item = "weapon_crusher", count = 1 },
        timeSec = 12,
        description = "Escopeta de tambor automática de cal. 12 para varredura de corredores em Megabuildings.",
        inputs = {
            { item = "component_rare", count = 20 },
            { item = "metal_scrap", count = 25 },
            { item = "upgrade_part", count = 3 }
        }
    },
    {
        id = "craft_katana",
        label = "Katana Tática Arasaka",
        category = "weapons",
        output = { item = "weapon_katana", count = 1 },
        timeSec = 8,
        description = "Forja de lâmina monomolecular com balanceamento ergonômico anti-inércia.",
        inputs = {
            { item = "component_rare", count = 15 },
            { item = "metal_scrap", count = 20 },
            { item = "component_epic", count = 1 }
        }
    },

    -- =========================================================================
    -- CATEGORIA: MUNIÇÕES
    -- =========================================================================
    {
        id = "craft_ammo_handgun",
        label = "Lote de Munição 9mm (x50)",
        category = "ammo",
        output = { item = "ammo_handgun", count = 50 },
        timeSec = 3,
        description = "Prensagem de 50 cápsulas de latão com ogiva ogival e propelente padrão.",
        inputs = {
            { item = "component_common", count = 6 },
            { item = "gunpowder", count = 10 },
            { item = "metal_scrap", count = 6 }
        }
    },
    {
        id = "craft_ammo_rifle",
        label = "Lote de Munição 5.56mm (x50)",
        category = "ammo",
        output = { item = "ammo_rifle", count = 50 },
        timeSec = 4,
        description = "50 cartuchos de fuzil com ponta de aço endurecido para penetração de coletes leves.",
        inputs = {
            { item = "component_uncommon", count = 8 },
            { item = "gunpowder", count = 15 },
            { item = "metal_scrap", count = 8 }
        }
    },
    {
        id = "craft_ammo_shotgun",
        label = "Lote de Cartuchos Cal. 12 (x30)",
        category = "ammo",
        output = { item = "ammo_shotgun", count = 30 },
        timeSec = 4,
        description = "30 cartuchos de plástico reforçado com bagos múltiplos de chumbo e alta expansão.",
        inputs = {
            { item = "component_uncommon", count = 8 },
            { item = "gunpowder", count = 12 },
            { item = "metal_scrap", count = 10 }
        }
    },
    {
        id = "craft_ammo_sniper",
        label = "Lote de Munição .50 BMG (x20)",
        category = "ammo",
        output = { item = "ammo_sniper", count = 20 },
        timeSec = 5,
        description = "20 projéteis antimaterial com núcleo de tungstênio e carga propulsora maciça.",
        inputs = {
            { item = "component_rare", count = 10 },
            { item = "gunpowder", count = 20 },
            { item = "metal_scrap", count = 12 }
        }
    },

    -- =========================================================================
    -- CATEGORIA: FARMÁCIA & BIOMETRIA
    -- =========================================================================
    {
        id = "craft_maxdoc",
        label = "Inalador MaxDoc Mk.1",
        category = "medical",
        output = { item = "maxdoc_mk1", count = 1 },
        timeSec = 4,
        description = "Síntese em nebulizador portátil com biogel de coagulação imediata.",
        inputs = {
            { item = "component_common", count = 6 },
            { item = "biogel", count = 2 }
        }
    },
    {
        id = "craft_bounce_back",
        label = "Estimulante Bounce Back",
        category = "medical",
        output = { item = "bounce_back", count = 1 },
        timeSec = 5,
        description = "Ampola estéril de nano-reparadores teciduais para suporte metabólico prolongado.",
        inputs = {
            { item = "component_uncommon", count = 8 },
            { item = "biogel", count = 3 }
        }
    },
    {
        id = "craft_neuroblocker",
        label = "Neurobloqueador Imunológico",
        category = "medical",
        output = { item = "neuroblocker", count = 1 },
        timeSec = 7,
        description = "Fórmula imunossupressora neural para resfriar sobrecargas sinápticas de ciberware.",
        inputs = {
            { item = "component_rare", count = 10 },
            { item = "biogel", count = 4 },
            { item = "microchip", count = 1 }
        }
    },

    -- =========================================================================
    -- CATEGORIA: COMPONENTES & UPGRADES
    -- =========================================================================
    {
        id = "craft_comp_uncommon",
        label = "Componente Incomum (Tier 2)",
        category = "components",
        output = { item = "component_uncommon", count = 1 },
        timeSec = 2,
        description = "Refinamento e fusão de 3 componentes comuns em uma liga mais pura.",
        inputs = {
            { item = "component_common", count = 3 }
        }
    },
    {
        id = "craft_comp_rare",
        label = "Componente Raro (Tier 3)",
        category = "components",
        output = { item = "component_rare", count = 1 },
        timeSec = 3,
        description = "Tratamento térmico de 3 componentes incomuns com revestimento semicondutor.",
        inputs = {
            { item = "component_uncommon", count = 3 }
        }
    },
    {
        id = "craft_comp_epic",
        label = "Componente Épico (Tier 4)",
        category = "components",
        output = { item = "component_epic", count = 1 },
        timeSec = 4,
        description = "Nano-cristalização de componentes raros sob vácuo industrial.",
        inputs = {
            { item = "component_rare", count = 3 }
        }
    },
    {
        id = "craft_upgrade_part",
        label = "Módulo de Aprimoramento",
        category = "components",
        output = { item = "upgrade_part", count = 1 },
        timeSec = 5,
        description = "Montagem de servomecanismo de calibração a partir de sucatas e ligas estruturais.",
        inputs = {
            { item = "metal_scrap", count = 8 },
            { item = "component_uncommon", count = 4 }
        }
    },
    {
        id = "craft_microchip",
        label = "Microprocessador IC-77",
        category = "components",
        output = { item = "microchip", count = 1 },
        timeSec = 6,
        description = "Gravação a laser de circuito integrado militar em pastilha de silício sintetizado.",
        inputs = {
            { item = "component_rare", count = 5 },
            { item = "component_uncommon", count = 3 }
        }
    }
}
