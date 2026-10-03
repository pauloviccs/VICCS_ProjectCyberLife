--[[
    LIFESIM RP - Core Configuration
    Path: ls_core/shared/config.lua
    Apenas dados estáticos. Tunables são declarados exclusivamente no servidor (main.lua).
]]

CoreConfig = CoreConfig or {}

-- Identificação do Gamemode
CoreConfig.Version = "0.1.0"
CoreConfig.GamemodeName = "lifesim"

-- Configurações de Gate e Conexão
CoreConfig.AdmissionMessage = "Night City esta iniciando. Tente em instantes."
CoreConfig.GateTimeoutMs = 20000

-- Roteamento e Instâncias (Habitação)
CoreConfig.Buckets = {
    HousingStart = 10000,
    HousingEnd   = 19999
}

-- Posição padrão de Spawn inicial (Apartamento H10 do V em Little China)
CoreConfig.DefaultSpawn = {
    x = -1370.2,
    y = 1290.4,
    z = 128.5,
    heading = 180.0
}
