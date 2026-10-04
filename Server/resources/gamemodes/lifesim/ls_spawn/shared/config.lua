--[[
    =============================================================================
    LIFESIM RP - CENTRAL DE CONFIGURAÇÃO DE SPAWNS, BLIPS E COORDENADAS
    Arquivo: ls_spawn/shared/config.lua
    =============================================================================

    GUIA RÁPIDO DE MANUTENÇÃO (COMO EDITAR OU ADICIONAR NOVAS COORDENADAS):
    -----------------------------------------------------------------------------
    1. Entre no jogo como Administrador / Moderador / Suporte.
    2. Vá até o local exato desejado e digite: /coords
    3. O painel Kiroshi de coordenadas surgirá na tela. Clique em "COPIAR" no formato "Table".
    4. Cole diretamente no campo 'coords = { ... }' do ponto desejado abaixo!
    5. Para recarregar em tempo real no servidor: 'op77 restart ls_spawn'

    ESTRUTURA DE CADA PONTO:
    - id: Identificador único (texto sem espaços)
    - name: Nome do local exibido na tela
    - district / subdistrict: Região de Night City
    - coords: { x = 0.0, y = 0.0, z = 0.0, heading = 0.0 }
    - blip: { enabled = bool, label = string, color = hex, icon = string }
    - marker: { enabled = bool, shape = "ring", radius = float, color = {r,g,b,a} }
    - interaction: { enabled = bool, radius = float, key = "E", label = string }
    =============================================================================
]]

Config = Config or {}

-- =============================================================================
-- CONTROLES GLOBAIS DE BLIPS E MARCADORES NO MUNDO
-- =============================================================================
Config.WorldBlips = {
    enabled = true,                       -- Ativa exibição de blips no mapa vanilla para pontos públicos
    defaultColor = "#22D8E2",             -- Cor padrão dos blips (Cyan Kiroshi)
    defaultIcon = "CustomPositionVariant" -- Ícone nativo de waypoint do Cyberpunk 2077
}

Config.WorldMarkers = {
    enabled = false,                     -- Se true, desenha anel holográfico 3D no chão de cada spawn
    defaultShape = "ring",               -- "ring", "cylinder", "objective"
    defaultRadius = 2.0,
    defaultColor = { 34, 216, 226, 180 } -- RGBA
}

Config.WorldInteractions = {
    enabled = false, -- Se true, permite abrir o seletor de trânsito ao se aproximar a pé
    interactionKey = "E"
}

-- =============================================================================
-- 1. PRIMEIRO SPAWN OBRIGATÓRIO (PERSONAGEM NOVO / RECÉM-CRIADO)
-- =============================================================================
-- O primeiro spawn de qualquer cidadão novo em Night City é SEMPRE fixo no Megabuilding H10.
-- O jogador não passa pela tela de escolha no seu primeiro nascimento.
Config.FirstSpawn = {
    id = "megabuilding_h10_residence",
    name = "Megabuilding H10 - Little China",
    district = "Watson",
    subdistrict = "Little China",
    badge = "RESIDÊNCIA INICIAL",
    threatLevel = "Baixo (Área Residencial Segura)",
    description =
    "Seu ponto de partida em Night City. Megaestrutura habitacional de alta densidade com infraestrutura residencial completa, acesso ao metrô NCART e mercado interno.",

    -- Coordenadas exatas obtidas via comando /coords:
    coords = {
        x = -1355.20,
        y = 1275.50,
        z = 110.50,
        heading = 180.00
    },

    blip = {
        enabled = false,
        label = "Residência Inicial - H10",
        color = "#22D8E2"
    },

    marker = {
        enabled = false,
        shape = "ring",
        radius = 2.0,
        color = { 34, 216, 226, 200 }
    },

    welcomeMessage = "BEM-VINDO A NIGHT CITY // CONEXÃO NEURAL ESTABELECIDA NO MEGABUILDING H10"
}

-- =============================================================================
-- 2. PONTOS PÚBLICOS DE SPAWN E TRÂNSITO (PARA JOGADORES INICIADOS)
-- =============================================================================
Config.PublicSpawns = {
    {
        id = "h10_atrium",
        name = "Megabuilding H10 - Pátio Central",
        district = "Watson",
        subdistrict = "Little China",
        badge = "MEGABUILDING",
        threatLevel = "Baixo (Área Civil)",
        threatRating = 1, -- 1: Baixo, 2: Médio, 3: Elevado, 4: Extremo
        category = "megabuilding",
        description =
        "O monumental atrium central do Megabuilding H10. Ponto nevrálgico de Watson com lojas de conveniência, ripperdocs credenciados e terminais financeiros da Night City Net.",
        transitInfo = "Acesso direto a elevadores residenciais e linhas do NCART.",
        accentColor = "#22d8e2",

        -- Coordenadas de Spawn / Trânsito
        coords = {
            x = -1431.1136,
            y = 1261.1797,
            z = 23.0705,
            heading = 192.7605
        },

        -- Blip no Mapa Vanilla
        blip = {
            enabled = true,
            label = "Ponto de Spawn // Megabuilding H10",
            color = "#22D8E2"
        },

        -- Marcador 3D no Piso
        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.2,
            color = { 34, 216, 226, 180 }
        }
    },
    {
        id = "h8_japantown",
        name = "Megabuilding H8 - Clouds Terrace",
        district = "Westbrook",
        subdistrict = "Japantown",
        badge = "MEGABUILDING",
        threatLevel = "Médio (Tyger Claws / Entretenimento)",
        threatRating = 2,
        category = "megabuilding",
        description =
        "Megaestrutura icônica de entretenimento e habitação de Japantown. Lar do famoso clube Clouds, cercado por pontes aéreas, letreiros em kanji e intensa vida noturna.",
        transitInfo = "Conexão rápida com os viadutos suspensos de Westbrook.",
        accentColor = "#ff2a8d",

        coords = {
            x = -1120.00,
            y = 350.00,
            z = 32.00,
            heading = 180.00
        },

        blip = {
            enabled = true,
            label = "Ponto de Spawn // Megabuilding H8",
            color = "#FF2A8D"
        },

        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.2,
            color = { 255, 42, 141, 180 }
        }
    },
    {
        id = "corpo_plaza",
        name = "Arasaka Corpo Plaza",
        district = "City Center",
        subdistrict = "Corpo Plaza",
        badge = "METRÓPOLE",
        threatLevel = "Controlado (Segurança Máxima Arasaka)",
        threatRating = 2,
        category = "metropolis",
        description =
        "O coração financeiro e geopolítico de Night City. Arranha-céus colossais da Arasaka, Militech e Kang Tao circundam uma praça monumental vigiada por drones de combate.",
        transitInfo = "Terminais de transporte corporativo de alta velocidade.",
        accentColor = "#00f0ff",

        coords = {
            x = -200.50,
            y = -120.30,
            z = 15.00,
            heading = 45.00
        },

        blip = {
            enabled = true,
            label = "Ponto de Spawn // Corpo Plaza",
            color = "#00F0FF"
        },

        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.5,
            color = { 0, 240, 255, 180 }
        }
    },
    {
        id = "kabuki_roundabout",
        name = "Mercado Noturno de Kabuki",
        district = "Watson",
        subdistrict = "Kabuki",
        badge = "PRAÇA PÚBLICA",
        threatLevel = "Médio (Submundo / Mercado Clandestino)",
        threatRating = 2,
        category = "plaza",
        description =
        "Labirinto pulsante em vários andares com barracas de ramen sintético, modders de implantes de garagem, cabines de braindance e comércio informal sob néon denso.",
        transitInfo = "Acesso imediato às vias secundárias e becos de Watson.",
        accentColor = "#fcee0a",

        coords = {
            x = -1180.00,
            y = 1450.00,
            z = 120.00,
            heading = 90.00
        },

        blip = {
            enabled = true,
            label = "Ponto de Spawn // Mercado Kabuki",
            color = "#FCEE0A"
        },

        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.0,
            color = { 252, 238, 10, 180 }
        }
    },
    {
        id = "japantown_cherry",
        name = "Cherry Blossom Market",
        district = "Westbrook",
        subdistrict = "Japantown",
        badge = "PRAÇA CULTURAL",
        threatLevel = "Baixo / Moderado (Ponto Turístico)",
        threatRating = 1,
        category = "plaza",
        description =
        "A praça mais deslumbrante de Westbrook. Árvores holográficas de cerejeira em flor iluminam fontes de água cibernéticas, pavilhões gastronômicos e lojas de grife oriental.",
        transitInfo = "Praça de pedestres com paradas de táxi Delamain nas proximidades.",
        accentColor = "#ff0077",

        coords = {
            x = -1442.20,
            y = 127.40,
            z = 18.00,
            heading = 270.00
        },

        blip = {
            enabled = true,
            label = "Ponto de Spawn // Cherry Blossom",
            color = "#FF0077"
        },

        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.0,
            color = { 255, 0, 119, 180 }
        }
    },
    {
        id = "glen_city_hall",
        name = "City Hall Plaza - The Glen",
        district = "Heywood",
        subdistrict = "The Glen",
        badge = "CENTRO CÍVICO",
        threatLevel = "Baixo (Distrito Governamental)",
        threatRating = 1,
        category = "plaza",
        description =
        "Grande praça cívica diante da prefeitura de Night City. Ampla área aberta com palmeiras cibernéticas, fontes imponentes e arquitetura neo-brutalista de Heywood.",
        transitInfo = "Hub central de transporte rodoviário e linhas de ônibus metropolitanos.",
        accentColor = "#00ff9d",

        coords = {
            x = -800.00,
            y = -850.00,
            z = 14.50,
            heading = 0.00
        },

        blip = {
            enabled = true,
            label = "Ponto de Spawn // City Hall The Glen",
            color = "#00FF9D"
        },

        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.2,
            color = { 0, 255, 157, 180 }
        }
    },
    {
        id = "pacifica_mall",
        name = "Grand Imperial Mall Plaza",
        district = "Pacifica",
        subdistrict = "Coastview",
        badge = "ZONA LIVRE",
        threatLevel = "Elevado (Área Sem Lei / Voodoo Boys)",
        threatRating = 4,
        category = "metropolis",
        description =
        "Esqueleto do shopping center monumental abandonado na costa sul. Território autônomo com pouca presença do NCPD, dominado pelos netrunners dos Voodoo Boys.",
        transitInfo = "Zona não atendida por transporte público oficial.",
        accentColor = "#ff003c",

        coords = {
            x = -1716.40,
            y = -2421.30,
            z = 62.60,
            heading = 315.00
        },

        blip = {
            enabled = true,
            label = "Ponto de Spawn // Pacifica GIM",
            color = "#FF003C"
        },

        marker = {
            enabled = false,
            shape = "ring",
            radius = 2.5,
            color = { 255, 0, 60, 180 }
        }
    },
    {
        id = "last_position",
        name = "Última Conexão do Biochip",
        district = "Night City",
        subdistrict = "Memória Biomonitor",
        badge = "PERSISTENTE",
        threatLevel = "Conforme Local Anterior",
        threatRating = 2,
        category = "last_position",
        description =
        "Retomar sua consciência e atividade exatamente nas coordenadas onde seu biomonitor Kiroshi transmitiu o último pulso antes de desconectar.",
        transitInfo = "Restauração de coordenadas geodésicas gravadas em nuvem.",
        accentColor = "#22d8e2",
        coords = nil, -- Injetado dinamicamente pelo servidor a partir do perfil do jogador
        blip = { enabled = false },
        marker = { enabled = false }
    }
}

-- =============================================================================
-- 3. TRANSIÇÕES E EXPERIÊNCIA DO USUÁRIO
-- =============================================================================
Config.Transition = {
    fadeDurationMs = 1200, -- Duração da transição suave de tela preta ao spawnar
    soundEnabled = true,   -- Habilita síntese de áudio diegético Kiroshi na interface
    allowCancel = false,   -- Obriga o jogador a escolher um local de spawn válido
    spawnTimeoutSec = 120  -- Se o jogador ficar ocioso por 2 minutos, spawna no padrão
}
