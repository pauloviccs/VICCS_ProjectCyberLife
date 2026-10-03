--[[
    LIFESIM RP - Vitals Configuration
    Path: ls_vitals/shared/config.lua
    Parâmetros calibrados para decaimento biológico, histerese, telemetria e consumíveis.
]]

VitalsConfig = VitalsConfig or {}

-- Intervalo de atualização do motor de decaimento (3000ms para alta reatividade)
VitalsConfig.TickIntervalMs = 3000

-- Variação mínima para disparar replicação de rede via State Bag (0.1% para feedback imediato)
VitalsConfig.HysteresisThreshold = 0.10

-- Tempo máximo em ms para forçar replicação mesmo sem grande variação (15s)
VitalsConfig.ForceReplicateIntervalMs = 15000

-- Multiplicador global de taxa de decaimento (ajustável dinamicamente via /vitals rate <N>)
VitalsConfig.GlobalRateMultiplier = 1.0

-- Flag para exibição de logs periódicos no console do servidor (ajustável via /vitals log)
VitalsConfig.DebugLogs = true

-- Taxas de decaimento base por minuto em repouso (100 -> 0)
VitalsConfig.Decay = {
    HungerPerMin  = 1.20,  -- ~83 minutos em repouso
    ThirstPerMin  = 1.80,  -- ~55 minutos em repouso
    EnergyPerMin  = 0.80,  -- ~125 minutos em repouso
    HygienePerMin = 0.40,  -- ~250 minutos em repouso
    StressRecoveryPerMin = 0.50 -- Recuperação passiva quando calmo
}

-- Multiplicadores de atividade física e esforço motor
VitalsConfig.Multipliers = {
    Idle      = 1.0,
    Walking   = 1.3,
    Running   = 2.0,
    Sprinting = 3.2,
    Jumping   = 2.5,
    Sliding   = 2.2,
    Driving   = 0.85,
    Combat    = 3.0,
    Sleeping  = 0.2
}

-- Regras para decaimento em modo Offline (quando o jogador reconecta)
VitalsConfig.Offline = {
    DecayRateMultiplier = 0.15, -- 15% da velocidade normal
    MaxDecayHours       = 48.0, -- Máximo de 48 horas simuladas
    MinHunger           = 15.0, -- Piso seguro para não logar morto
    MinThirst           = 15.0,
    MinEnergy           = 20.0
}

-- Limiares críticos de alerta
VitalsConfig.Thresholds = {
    CriticalHunger  = 15.0,
    CriticalThirst  = 15.0,
    CriticalEnergy  = 15.0,
    CriticalHygiene = 20.0,
    HighStress      = 75.0
}

-- Penalidades e dano orgânico quando vitais atingem 0%
VitalsConfig.Starvation = {
    ThirstDamagePerTick = 3.5, -- Dano a cada 3s com 0% de hidratação (~1.16 HP/s)
    HungerDamagePerTick = 1.5, -- Dano a cada 3s com 0% de nutrição (~0.50 HP/s)
}

-- Tabela de consumíveis padrão
VitalsConfig.Consumables = {
    ["burrito_xxl"] = {
        label = "XXL All-Foods Burrito",
        price = 25,
        hunger = 35.0, thirst = -5.0, energy = 10.0, stress = -2.0, hygiene = 0.0
    },
    ["spicy_ramen"] = {
        label = "Kabuki Spicy Ramen",
        price = 45,
        hunger = 45.0, thirst = -10.0, energy = 15.0, stress = -5.0, hygiene = 0.0
    },
    ["synth_burger"] = {
        label = "Captain Caliente Synth Burger",
        price = 30,
        hunger = 30.0, thirst = -4.0, energy = 8.0, stress = -1.0, hygiene = 0.0
    },
    ["nicola_blue"] = {
        label = "NiCola Blue (Taste the Love)",
        price = 15,
        hunger = 2.0, thirst = 35.0, energy = 8.0, stress = -2.0, hygiene = 0.0
    },
    ["spunky_monkey"] = {
        label = "Spunky Monkey Energy Drink",
        price = 20,
        hunger = 0.0, thirst = 40.0, energy = 25.0, stress = 4.0, hygiene = 0.0
    },
    ["real_water"] = {
        label = "Night City Purified Water",
        price = 10,
        hunger = 0.0, thirst = 50.0, energy = 5.0, stress = -5.0, hygiene = 0.0
    },
    ["chromanticore"] = {
        label = "Chromanticore Soda",
        price = 12,
        hunger = 1.0, thirst = 30.0, energy = 10.0, stress = 1.0, hygiene = 0.0
    },
    ["bounce_back_mk1"] = {
        label = "Bounce-Back Mk.1 (Stim)",
        price = 150,
        hunger = 0.0, thirst = 0.0, energy = 30.0, stress = -10.0, hygiene = 0.0
    },
    ["wet_wipes"] = {
        label = "Biotechnica Sanitizing Wipes",
        price = 18,
        hunger = 0.0, thirst = 0.0, energy = 0.0, stress = -3.0, hygiene = 40.0
    }
}
