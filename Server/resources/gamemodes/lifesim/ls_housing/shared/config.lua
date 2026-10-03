--[[
    LIFESIM RP - Housing & Vertical Living Configuration
    Path: ls_housing/shared/config.lua
    
    ARQUIVO DE CONFIGURAÇÃO DE FÁCIL ACESSO:
    Permite cadastrar e alterar complexos residenciais (Megabuildings, Lofts, Studios),
    coordenadas de entrada/interior, polígonos PolyZone de paredes, preços de aluguel/venda
    e o catálogo completo de mobílias com dimensões físicas para cálculo de colisão OBB.
]]

Config = Config or {}

-- =============================================================================
-- 1. CATÁLOGO DE APARTAMENTOS E INTERIORES POLIGONAIS (POLYZONE)
-- =============================================================================
Config.Apartments = {
    {
        id = "h10_apt_v",
        name = "Megabuilding H10 - Apto 0705",
        district = "Watson",
        subdistrict = "Little China",
        building = "Megabuilding H10",
        tier = "Starter",
        badge = "RESIDENCIAL H10",
        rentPrice = 350,       -- E$ por ciclo de pagamento
        buyPrice = 18000,      -- E$ para compra definitiva
        rentPeriodHours = 72,  -- 3 dias reais por ciclo de aluguel
        maxFurniture = 60,     -- Limite de peças por interior
        
        -- Porta de Entrada Externa (Corredor Residencial do Megabuilding H10)
        doorCoords = {
            x = -1386.4,
            y = 1272.2,
            z = 111.4,
            heading = 180.0,
            radius = 2.0
        },

        -- Ponto de Surgimento no Interior Instanciado
        interiorCoords = {
            x = -1386.4,
            y = 1275.5,
            z = 111.4,
            heading = 0.0
        },

        -- Delimitação Tridimensional do Volume Habitável via PolyZone
        -- As 4 quinas dos móveis PRECISAM estar 100% contidas neste polígono!
        polyzone = {
            points = {
                { x = -1393.5, y = 1269.8 },
                { x = -1393.5, y = 1282.4 },
                { x = -1379.2, y = 1282.4 },
                { x = -1379.2, y = 1269.8 }
            },
            minZ = 110.2, -- Altura exata do piso acabado
            maxZ = 115.0  -- Altura do teto com luminárias
        }
    },
    {
        id = "japantown_loft",
        name = "Japantown Skyline Loft",
        district = "Westbrook",
        subdistrict = "Japantown",
        building = "Megabuilding H8 Terrace",
        tier = "Mid-High",
        badge = "LOFT EXECUTIVO",
        rentPrice = 1200,
        buyPrice = 65000,
        rentPeriodHours = 72,
        maxFurniture = 90,

        doorCoords = {
            x = -1125.0,
            y = 355.0,
            z = 32.5,
            heading = 90.0,
            radius = 2.0
        },
        interiorCoords = {
            x = -1122.0,
            y = 355.0,
            z = 32.5,
            heading = 270.0
        },
        polyzone = {
            points = {
                { x = -1132.0, y = 345.0 },
                { x = -1132.0, y = 368.0 },
                { x = -1112.0, y = 368.0 },
                { x = -1112.0, y = 345.0 }
            },
            minZ = 31.5,
            maxZ = 37.0
        }
    },
    {
        id = "glen_studio",
        name = "The Glen City Studio",
        district = "Heywood",
        subdistrict = "The Glen",
        building = "Condomínio Residencial Vista del Rey",
        tier = "Comfort",
        badge = "STUDIO MODERNO",
        rentPrice = 750,
        buyPrice = 38000,
        rentPeriodHours = 72,
        maxFurniture = 70,

        doorCoords = {
            x = -790.0,
            y = -840.0,
            z = 14.5,
            heading = 180.0,
            radius = 2.0
        },
        interiorCoords = {
            x = -790.0,
            y = -836.0,
            z = 14.5,
            heading = 0.0
        },
        polyzone = {
            points = {
                { x = -798.0, y = -846.0 },
                { x = -798.0, y = -828.0 },
                { x = -782.0, y = -828.0 },
                { x = -782.0, y = -846.0 }
            },
            minZ = 13.5,
            maxZ = 18.5
        }
    },
    {
        id = "corpo_plaza_suite",
        name = "Arasaka High-Rise Penthouse",
        district = "City Center",
        subdistrict = "Corpo Plaza",
        building = "Torre Arasaka Waterfront",
        tier = "Luxury",
        badge = "COBERTURA CORPORATIVA",
        rentPrice = 3500,
        buyPrice = 220000,
        rentPeriodHours = 72,
        maxFurniture = 120,

        doorCoords = {
            x = -205.0,
            y = -115.0,
            z = 15.5,
            heading = 220.0,
            radius = 2.0
        },
        interiorCoords = {
            x = -202.0,
            y = -112.0,
            z = 15.5,
            heading = 40.0
        },
        polyzone = {
            points = {
                { x = -215.0, y = -125.0 },
                { x = -215.0, y = -95.0 },
                { x = -185.0, y = -95.0 },
                { x = -185.0, y = -125.0 }
            },
            minZ = 14.5,
            maxZ = 21.0
        }
    }
}

-- =============================================================================
-- 2. CATÁLOGO DE MOBÍLIAS COM DIMENSÕES FÍSICAS (OBB) & INTERAÇÕES
-- =============================================================================
Config.FurnitureCatalog = {
    -- --- CAMAS & DESCANSO ----------------------------------------------------
    {
        id = "bed_futon_cyber",
        name = "Futon Night City Básico",
        category = "beds",
        price = 600,
        description = "Colchão ergonômico reforçado sobre base metálica modular. Conforto básico para edgerunners iniciantes.",
        dimensions = { width = 1.3, length = 2.0, height = 0.55 },
        isSurface = false,
        allowStack = false,
        interaction = {
            type = "bed",
            label = "Dormir (Restaurar Energia)",
            energyRegenPerSec = 2.5,
            stressReliefPerSec = 1.2
        }
    },
    {
        id = "bed_arasaka_ortho",
        name = "Cama Ortopédica Arasaka Medi-Rest",
        category = "beds",
        price = 3200,
        description = "Leito com sensores biomonitores e indução de sono REM por microcorrentes neurais. Recuperação biológica ultrarrápida.",
        dimensions = { width = 1.9, length = 2.2, height = 0.8 },
        isSurface = false,
        allowStack = false,
        interaction = {
            type = "bed",
            label = "Dormir em Terapia Sináptica",
            energyRegenPerSec = 5.0,
            stressReliefPerSec = 3.5
        }
    },

    -- --- ASSENTOS & SOFÁS ----------------------------------------------------
    {
        id = "sofa_leather_cyber",
        name = "Sofá de Couro Sintético Neon",
        category = "seating",
        price = 1100,
        description = "Sofá de 3 lugares com detalhes em costura luminescente e espuma com memória de forma.",
        dimensions = { width = 2.2, length = 0.95, height = 0.85 },
        isSurface = false,
        allowStack = false,
        interaction = {
            type = "chair",
            label = "Relaxar no Sofá",
            stressReliefPerSec = 1.0
        }
    },
    {
        id = "chair_netrunner_ergonomic",
        name = "Cadeira Ergonômica de Netrunner",
        category = "seating",
        price = 850,
        description = "Cadeira giratória com apoios cervicais e blindagem contra radiação de decks superaquecidos.",
        dimensions = { width = 0.75, length = 0.75, height = 1.25 },
        isSurface = false,
        allowStack = false,
        interaction = {
            type = "chair",
            label = "Sentar na Estação",
            stressReliefPerSec = 0.8
        }
    },

    -- --- MESAS & SUPERFÍCIES DE APOIO ----------------------------------------
    {
        id = "desk_workstation_cyber",
        name = "Bancada Netrunner Cyber-Desk",
        category = "tables",
        price = 1400,
        description = "Mesa reforçada com dutos embutidos para cabos e trilhos para montagem de telas e periféricos.",
        dimensions = { width = 1.7, length = 0.85, height = 0.78 },
        isSurface = true, -- Permite que objetos menores sejam apoiados sobre ela!
        allowStack = false,
        surfaceZ = 0.78
    },
    {
        id = "table_coffee_glass",
        name = "Mesa de Centro Holográfica",
        category = "tables",
        price = 650,
        description = "Tampo em acrílico balístico fumê com base em fibra de carbono fosca.",
        dimensions = { width = 1.1, length = 0.65, height = 0.45 },
        isSurface = true,
        allowStack = false,
        surfaceZ = 0.45
    },

    -- --- SANITÁRIO & HIGIENE -------------------------------------------------
    {
        id = "shower_sonic_booth",
        name = "Cabine de Banho Sônica Kiroshi",
        category = "sanitary",
        price = 2400,
        description = "Sistema de higienização por ondas ultrassônicas e vapor desinfetante antibacteriano. Restauração higiênica total.",
        dimensions = { width = 1.15, length = 1.15, height = 2.25 },
        isSurface = false,
        allowStack = false,
        interaction = {
            type = "shower",
            label = "Tomar Banho Sônico (Restaurar Higiene)",
            hygieneRegenTotal = 100.0,
            durationSec = 6
        }
    },
    {
        id = "kitchen_synth_cooker",
        name = "Sintetizador Culinário All-Foods Chef",
        category = "sanitary",
        price = 1900,
        description = "Estação de cozinha compacta capaz de reidratar e aquecer rações sintéticas e preparar cafés quentes.",
        dimensions = { width = 1.5, length = 0.75, height = 0.9 },
        isSurface = true,
        allowStack = false,
        surfaceZ = 0.9,
        interaction = {
            type = "kitchen",
            label = "Preparar Refeição Sintética"
        }
    },

    -- --- ARMAZENAMENTO & BAÚ (STASH) -----------------------------------------
    {
        id = "stash_heavy_safe",
        name = "Cofre Balístico Residencial (Stash)",
        category = "storage",
        price = 1750,
        description = "Baú blindado com fechadura biométrica para guardar armas, drogas, ciberimplantes e itens valiosos.",
        dimensions = { width = 1.0, length = 0.6, height = 0.7 },
        isSurface = true,
        allowStack = false,
        surfaceZ = 0.7,
        interaction = {
            type = "stash",
            label = "Abrir Baú do Apartamento (Stash)",
            maxSlots = 50,
            maxWeightKg = 250.0
        }
    },

    -- --- ILUMINAÇÃO & DECORAÇÃO ----------------------------------------------
    {
        id = "lamp_cyber_ambient",
        name = "Luminária de Mesa Neon Ciano",
        category = "decor",
        price = 250,
        description = "Globo translúcido emitindo luz suave na frequência característica dos biomonitores de Night City.",
        dimensions = { width = 0.35, length = 0.35, height = 0.45 },
        isSurface = false,
        allowStack = true, -- Pode ser colocado em cima de mesas e balcões!
        interaction = {
            type = "light",
            label = "Alternar Luz Neon"
        }
    },
    {
        id = "holo_projector_koi",
        name = "Projetor Holográfico Peixe Koi",
        category = "decor",
        price = 900,
        description = "Projeta carpas digitais nadando suavemente no ar do apartamento. Efeito calmante que reduz estresse contínuo.",
        dimensions = { width = 0.4, length = 0.4, height = 0.3 },
        isSurface = false,
        allowStack = true,
        interaction = {
            type = "decor",
            label = "Ligar/Desligar Holograma"
        }
    }
}

-- =============================================================================
-- 3. PARÂMETROS DO MODO DECORAÇÃO LIVRE (BUILD MODE)
-- =============================================================================
Config.BuildMode = {
    maxRaycastDistance = 16.0,  -- Alcance máximo em metros do cursor
    rotationStepDeg = 5.0,      -- Passo suave de rotação yaw contínua
    discreteSnapDeg = 15.0,     -- Ângulo de travamento rápido ao segurar [Ctrl]
    elevationStepZ = 0.05,      -- Passo de elevação vertical do eixo Z [Shift + Scroll]
    previewAlpha = 0.7,         -- Transparência do prop holográfico fantasma
    validColor = "#00ff9d",     -- Verde/Ciano Neon quando a posição é válida
    invalidColor = "#ff003c"    -- Vermelho Neon quando colide com parede ou móvel
}
