--[[
    LIFESIM RP - Cyberware, Neural Stability & Psychosis Configuration
    Path: ls_cyberware/shared/config.lua
    Mapeamento de slots anatômicos, catálogo de implantes, farmacêuticos e parâmetros biológicos.
]]

CyberwareConfig = CyberwareConfig or {}

-- =============================================================================
-- PARÂMETROS GERAIS DO MOTOR NEURAL
-- =============================================================================
CyberwareConfig.Enabled = true
CyberwareConfig.TickIntervalMs = 5000         -- Tick de telemetria a cada 5 segundos
CyberwareConfig.HysteresisThreshold = 0.50     -- Variação mínima para disparar State Bag
CyberwareConfig.ForceHeartbeatIntervalMs = 30000 -- Pulso obrigatório a cada 30 segundos

-- Limiares de Estabilidade & Psicose
CyberwareConfig.BaseStability = 100.0         -- Estabilidade máxima natural (%)
CyberwareConfig.MinStability = 5.0            -- Estabilidade mínima permitida (%)
CyberwareConfig.PsychosisThreshold = 25.0      -- Limiar crítico de Ciberpsicose (%)
CyberwareConfig.MaxTacWarningThreshold = 18.0 -- Limiar em que o MaxTac entra em alerta preventivo (%)

-- Limiares de Temperatura Ocular (°C)
CyberwareConfig.BaseOcularTemp = 36.5         -- Temperatura ocular basal normal
CyberwareConfig.WarningOcularTemp = 39.5      -- Aviso de aquecimento ótico
CyberwareConfig.CriticalOcularTemp = 42.0     -- Superaquecimento crítico (distorções visuais)
CyberwareConfig.MaxOcularTemp = 48.0          -- Temperatura de falha de hardware

-- Coeficientes da Equação de Estabilidade Neural:
-- Estabilidade = 100 - (Implantes * 7.5) - (Sem Neurobloqueador ? 25 : 0) - (Stress * 0.25)
CyberwareConfig.ImplantStrainMultiplier = 7.5  -- Impacto por implante instalado
CyberwareConfig.UnmedicatedPenalty = 25.0      -- Penalidade por falta de neurobloqueador
CyberwareConfig.StressStrainMultiplier = 0.25  -- Impacto proporcional ao estresse (0 a 100)

-- Coeficientes do Calor Ocular:
-- Calor = 36.5 + (Implantes * 0.8) + (Stress * 0.04)
CyberwareConfig.ImplantHeatMultiplier = 0.80   -- Aumento de calor por implante
CyberwareConfig.StressHeatMultiplier = 0.04    -- Aumento de calor por estresse

-- =============================================================================
-- SLOTS ANATÔMICOS DISPONÍVEIS
-- =============================================================================
CyberwareConfig.Slots = {
    frontal_cortex = { label = "Córtex Frontal", maxImplants = 3 },
    ocular         = { label = "Sistema Ocular", maxImplants = 1 },
    circulatory    = { label = "Sistema Circulatório", maxImplants = 3 },
    immune         = { label = "Sistema Imunológico", maxImplants = 2 },
    nervous        = { label = "Sistema Nervoso", maxImplants = 2 },
    integumentary  = { label = "Sistema Tegumentar", maxImplants = 3 },
    operating_sys  = { label = "Sistema Operacional", maxImplants = 1 },
    skeleton       = { label = "Esqueleto", maxImplants = 2 },
    hands          = { label = "Mãos", maxImplants = 1 },
    arms           = { label = "Braços", maxImplants = 1 },
    legs           = { label = "Pernas", maxImplants = 1 },
}

-- =============================================================================
-- CATÁLOGO DE CIBERIMPLANTES
-- =============================================================================
CyberwareConfig.Implants = {
    -- Sistema Ocular
    ["kiroshi_optics_mk1"] = {
        name = "Kiroshi Optics Mk.1",
        slot = "ocular",
        quality = "common",
        neuralCost = 6.0,
        heatBonus = 0.4,
        price = 1200,
        description = "Visão tática digital com scanner biomonitor e identificação de alvos."
    },
    ["kiroshi_optics_mk2"] = {
        name = "Kiroshi Optics Mk.2",
        slot = "ocular",
        quality = "rare",
        neuralCost = 10.0,
        heatBonus = 0.8,
        price = 3500,
        description = "Zoom óptico aprimorado, telemetria balística e análise de trajetórias."
    },
    ["kiroshi_optics_stalker"] = {
        name = "Kiroshi Optics 'Stalker' Mk.3",
        slot = "ocular",
        quality = "legendary",
        neuralCost = 18.0,
        heatBonus = 1.6,
        price = 12500,
        description = "Penetração sensorial em espectro termográfico através de superfícies finas."
    },

    -- Córtex Frontal
    ["bioconductor_mk1"] = {
        name = "Biocondutor Zetatech Mk.1",
        slot = "frontal_cortex",
        quality = "rare",
        neuralCost = 10.0,
        heatBonus = 0.6,
        price = 4200,
        description = "Acelera a resposta e resfriamento de sistemas cibernéticos em 15%."
    },
    ["memory_boost_mk2"] = {
        name = "Amplificador de Memória Dynalar",
        slot = "frontal_cortex",
        quality = "epic",
        neuralCost = 14.0,
        heatBonus = 0.9,
        price = 8500,
        description = "Otimiza a taxa de recuperação de RAM e processamento analítico."
    },

    -- Sistema Circulatório
    ["second_heart_mk1"] = {
        name = "Segundo Coração Moore Tech",
        slot = "circulatory",
        quality = "legendary",
        neuralCost = 22.0,
        heatBonus = 1.5,
        price = 28000,
        description = "Módulo cardíaco sintético que ressuscita o usuário de parada letal."
    },
    ["biomonitor_dynalar"] = {
        name = "Biomonitor de Emergência Dynalar",
        slot = "circulatory",
        quality = "rare",
        neuralCost = 8.0,
        heatBonus = 0.4,
        price = 3200,
        description = "Injeção automática de estimulantes quando a vitalidade atinge níveis de risco."
    },

    -- Sistema Imunológico
    ["pain_editor"] = {
        name = "Editor de Dor Neurotech",
        slot = "immune",
        quality = "epic",
        neuralCost = 16.0,
        heatBonus = 0.7,
        price = 9800,
        description = "Filtro sináptico que reduz a percepção de impacto e dor em 10%."
    },
    ["detoxifier"] = {
        name = "Desintoxicador Metabólico",
        slot = "immune",
        quality = "uncommon",
        neuralCost = 6.0,
        heatBonus = 0.3,
        price = 2100,
        description = "Neutralizador autônomo de substâncias tóxicas e gases letais."
    },

    -- Sistema Nervoso
    ["kerenzikov_mk1"] = {
        name = "Kerenzikov Zetatech",
        slot = "nervous",
        quality = "rare",
        neuralCost = 12.0,
        heatBonus = 1.0,
        price = 6500,
        description = "Desacelera a percepção sensorial de tempo durante esquivas e mira tática."
    },
    ["synaptic_accelerator"] = {
        name = "Acelerador Sináptico",
        slot = "nervous",
        quality = "uncommon",
        neuralCost = 8.0,
        heatBonus = 0.5,
        price = 3000,
        description = "Acelera reflexos autônomos ao detectar aproximação hostil iminente."
    },

    -- Sistema Tegumentar
    ["subdermal_armor_mk1"] = {
        name = "Armadura Subdérmica Militech",
        slot = "integumentary",
        quality = "common",
        neuralCost = 7.0,
        heatBonus = 0.2,
        price = 2500,
        description = "Malha de aramida tecida sob a epiderme aumentando a blindagem corporal."
    },
    ["optical_camo_mk1"] = {
        name = "Camuflagem Óptica Arasaka",
        slot = "integumentary",
        quality = "legendary",
        neuralCost = 20.0,
        heatBonus = 2.0,
        price = 22000,
        description = "Camada de nanofibras de desvio de fótons que concede invisibilidade momentânea."
    },

    -- Sistema Operacional
    ["militech_sandevistan_mk4"] = {
        name = "Militech Sandevistan Mk.4",
        slot = "operating_sys",
        quality = "iconic",
        neuralCost = 28.0,
        heatBonus = 3.2,
        price = 35000,
        description = "Hiperaceleração de reflexos com desaceleração de 75% do mundo por 12 segundos."
    },
    ["arasaka_cyberdeck_mk3"] = {
        name = "Arasaka Cyberdeck Mk.3",
        slot = "operating_sys",
        quality = "epic",
        neuralCost = 18.0,
        heatBonus = 2.0,
        price = 16000,
        description = "Processador de invasão de redes e compilação de daemons de combate."
    },

    -- Esqueleto
    ["titanium_bones"] = {
        name = "Ossos de Titânio Reforçados",
        slot = "skeleton",
        quality = "uncommon",
        neuralCost = 6.0,
        heatBonus = 0.1,
        price = 2400,
        description = "Aumenta a resistência mecânica e capacidade de transporte de carga física em 40%."
    },

    -- Mãos
    ["smart_link"] = {
        name = "Smart Link Arasaka",
        slot = "hands",
        quality = "rare",
        neuralCost = 8.0,
        heatBonus = 0.4,
        price = 4500,
        description = "Interface de micro-retransmissor palmar para guiar projéteis de armas inteligentes."
    },

    -- Braços
    ["mantis_blades"] = {
        name = "Lâminas Mantis de Carbono",
        slot = "arms",
        quality = "epic",
        neuralCost = 18.0,
        heatBonus = 1.4,
        price = 15000,
        description = "Lâminas retráteis ultra-afiadas nos antebraços para cortes e estocadas letais."
    },
    ["gorilla_arms"] = {
        name = "Braços de Gorila Reforçados",
        slot = "arms",
        quality = "epic",
        neuralCost = 18.0,
        heatBonus = 1.2,
        price = 15000,
        description = "Pistões de alta pressão que amplificam brutalmente a força de socos e arrombamento."
    },

    -- Pernas
    ["reinforced_tendons"] = {
        name = "Tendões Reforçados (Salto Duplo)",
        slot = "legs",
        quality = "rare",
        neuralCost = 12.0,
        heatBonus = 0.5,
        price = 9000,
        description = "Atuadores de nitrogênio líquido nos calcanhares permitindo salto duplo vertical."
    }
}

-- =============================================================================
-- PRODUTOS FARMACÊUTICOS (DRENOS MONETÁRIOS & CONTROLE DE PSICOSE)
-- =============================================================================
CyberwareConfig.Pharmaceuticals = {
    ["neuroblocker_booster"] = {
        name = "Injetor de Neurobloqueador",
        durationSeconds = 1800,       -- 30 minutos de efeito contínuo
        stabilityBoost = 15.0,        -- Bônus direto de alívio neural
        heatReduction = 1.5,          -- Redução suave de calor
        price = 250,                  -- Custo em Eurodólares
        description = "Bloqueador neural sintético obrigatório para conter a rejeição de cromo."
    },
    ["cryo_spray"] = {
        name = "Spray Criogênico Craniano",
        durationSeconds = 0,          -- Ação imediata
        stabilityBoost = 5.0,         -- Pequeno alívio do choque térmico
        heatReduction = 6.0,          -- Queda imediata de 6.0°C no calor ocular
        price = 180,
        description = "Spray aerossol de refrigeração para arrefecer ciberópticos superaquecidos."
    },
    ["immuno_shot"] = {
        name = "Ampola Imunossupressora",
        durationSeconds = 900,        -- 15 minutos
        stabilityBoost = 10.0,
        heatReduction = 0.8,
        price = 190,
        description = "Acalma o sistema imunológico biológico após procedimentos cirúrgicos."
    }
}

-- Conjunto inicial conferido ao cidadão recém-chegado a Night City
CyberwareConfig.DefaultImplants = {
    "kiroshi_optics_mk1",
    "subdermal_armor_mk1"
}
