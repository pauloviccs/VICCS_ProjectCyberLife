--[[
    LIFESIM RP - Spawn Points & Fast Transit Configuration
    Path: ls_spawn/shared/config.lua
    
    ARQUIVO DE CONFIGURAÇÃO DE FÁCIL ACESSO:
    Permite adicionar, remover e editar todos os pontos de spawn de Night City,
    definir a localização obrigatória do primeiro spawn de novos personagens e
    configurar detalhes de interface (nomes, distritos, perigo, tags visuais).
]]

Config = Config or {}

-- =============================================================================
-- 1. PRIMEIRO SPAWN OBRIGATÓRIO (PERSONAGEM NOVO / RECÉM-CRIADO)
-- =============================================================================
-- De acordo com as diretrizes do servidor, o primeiro spawn de qualquer cidadão
-- recém-chegado a Night City é SEMPRE fixo no Megabuilding H10 em Watson.
-- O jogador NÃO visualiza o menu de seleção no seu primeiro ciclo de vida.
Config.FirstSpawn = {
    id = "megabuilding_h10_residence",
    name = "Megabuilding H10 - Little China",
    district = "Watson",
    subdistrict = "Little China",
    badge = "RESIDÊNCIA INICIAL",
    threatLevel = "Baixo (Área Residencial Segura)",
    description = "Seu ponto de partida em Night City. Megaestrutura habitacional de alta densidade com infraestrutura residencial completa, acesso ao metrô NCART e mercado interno.",
    coords = {
        x = -1355.2,
        y = 1275.5,
        z = 110.5,
        heading = 180.0
    },
    welcomeMessage = "BEM-VINDO A NIGHT CITY // CONEXÃO NEURAL ESTABELECIDA NO MEGABUILDING H10"
}

-- =============================================================================
-- 2. PONTOS PÚBLICOS DE SELEÇÃO DE SPAWN (PARA JOGADORES JÁ INICIADOS)
-- =============================================================================
-- Locais públicos de grande circulação: Megabuildings, Praças Centrais,
-- Metrópoles Corporativas e a Última Localização Registrada no Biomonitor.
-- Para adicionar um novo local, basta duplicar um dos blocos abaixo!
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
        description = "O monumental atrium central do Megabuilding H10. Ponto nevrálgico de Watson com lojas de conveniência, ripperdocs credenciados e terminais financeiros da Night City Net.",
        transitInfo = "Acesso direto a elevadores residenciais e linhas do NCART.",
        accentColor = "#22d8e2", -- Cyan Neon
        coords = {
            x = -1355.2,
            y = 1275.5,
            z = 110.5,
            heading = 180.0
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
        description = "Megaestrutura icônica de entretenimento e habitação de Japantown. Lar do famoso clube Clouds, cercado por pontes aéreas, letreiros em kanji e intensa vida noturna.",
        transitInfo = "Conexão rápida com os viadutos suspensos de Westbrook.",
        accentColor = "#ff2a8d", -- Magenta Neon
        coords = {
            x = -1120.0,
            y = 350.0,
            z = 32.0,
            heading = 180.0
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
        description = "O coração financeiro e geopolítico de Night City. Arranha-céus colossais da Arasaka, Militech e Kang Tao circundam uma praça monumental vigiada por drones de combate.",
        transitInfo = "Terminais de transporte corporativo de alta velocidade.",
        accentColor = "#00f0ff", -- High-Tech Ice Cyan
        coords = {
            x = -200.5,
            y = -120.3,
            z = 15.0,
            heading = 45.0
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
        description = "Labirinto pulsante em vários andares com barracas de ramen sintético, modders de implantes de garagem, cabines de braindance e comércio informal sob néon denso.",
        transitInfo = "Acesso imediato às vias secundárias e becos de Watson.",
        accentColor = "#fcee0a", -- Yellow Cyberpunk
        coords = {
            x = -1180.0,
            y = 1450.0,
            z = 120.0,
            heading = 90.0
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
        description = "A praça mais deslumbrante de Westbrook. Árvores holográficas de cerejeira em flor iluminam fontes de água cibernéticas, pavilhões gastronômicos e lojas de grife oriental.",
        transitInfo = "Praça de pedestres com paradas de táxi Delamain nas proximidades.",
        accentColor = "#ff0077", -- Cherry Neon
        coords = {
            x = -1442.2,
            y = 127.4,
            z = 18.0,
            heading = 270.0
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
        description = "Grande praça cívica diante da prefeitura de Night City. Ampla área aberta com palmeiras cibernéticas, fontes imponentes e arquitetura neo-brutalista de Heywood.",
        transitInfo = "Hub central de transporte rodoviário e linhas de ônibus metropolitanos.",
        accentColor = "#00ff9d", -- Terminal Emerald
        coords = {
            x = -800.0,
            y = -850.0,
            z = 14.5,
            heading = 0.0
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
        description = "Esqueleto do shopping center monumental abandonado na costa sul. Território autônomo com pouca presença do NCPD, dominado pelos netrunners dos Voodoo Boys.",
        transitInfo = "Zona não atendida por transporte público oficial.",
        accentColor = "#ff003c", -- Danger Red
        coords = {
            x = -1716.4,
            y = -2421.3,
            z = 62.6,
            heading = 315.0
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
        description = "Retomar sua consciência e atividade exatamente nas coordenadas onde seu biomonitor Kiroshi transmitiu o último pulso antes de desconectar.",
        transitInfo = "Restauração de coordenadas geodésicas gravadas em nuvem.",
        accentColor = "#22d8e2",
        coords = nil -- Injetado dinamicamente pelo servidor a partir do perfil do jogador
    }
}

-- =============================================================================
-- 3. CONFIGURAÇÕES GERAIS E EFEITOS DE TRANSIÇÃO
-- =============================================================================
Config.Transition = {
    fadeDurationMs = 1200,    -- Duração da transição suave de tela preta ao spawnar
    soundEnabled = true,      -- Habilita síntese de áudio diegético Kiroshi na interface
    allowCancel = false,      -- Obriga o jogador a escolher um local de spawn válido
    spawnTimeoutSec = 120     -- Se o jogador ficar ocioso por 2 minutos, spawna no padrão
}
