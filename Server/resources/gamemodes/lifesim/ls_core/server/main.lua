--[[
    LIFESIM RP - Core Main Entrypoint
    Path: ls_core/server/main.lua
    Coordena o ciclo de boot do framework, gate de admissão de jogadores e tabela global Core.
]]

Core = {
    bootReady = false,
    sessions = {},
    byLicense = {},
    modules = {}
}

-- Participação no Gate de Prontidão da plataforma
-- Todo jogador que conectar receberá automaticamente 1 hold de prontidão em nome do ls_core
Open77.ready.participate({
    timeoutMs = CoreConfig.GateTimeoutMs or 20000,
    reason = "ls_profile_load"
})

-- Gate de Admissão: Impede entrada enquanto a fundação do core e banco não estiverem prontos
AddEventHandler("onPlayerConnecting", function(player, deferrals)
    if not Core.bootReady then
        deferrals.done(CoreConfig.AdmissionMessage or "Night City esta iniciando. Tente em instantes.")
    end
end)

-- Inicialização Ordenada
AddEventHandler("onResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Open77.log.info("[ls_core] Aguardando camada de dados (ls_data)...")

        -- Aguarda o ls_data ficar totalmente pronto com migrations aplicadas
        local call = Open77.exports.call("ls_data", "waitReady")
        if call then call:await() end

        Open77.log.info("[ls_data] Camada de dados detectada como pronta. Inicializando Core...")

        -- Adotar jogadores existentes caso o core tenha sofrido hot reload com o servidor cheio
        for _, playerId in ipairs(Open77.players.all()) do
            Core.ensureSession(playerId)
            Core.beginLoad(playerId)
        end

        Core.bootReady = true
        Open77.log.info(("[ls_core] Core do Life-Sim online e operacional (v%s)."):format(CoreConfig.Version))

        -- Avisa todo o ecossistema que o core está de pé
        TriggerEvent("ls:core:ready", CoreConfig.Version)
    end)
end)

-- =============================================================================
-- EXPORTS SÍNCRONOS BÁSICOS
-- =============================================================================

exports("getSession", function(playerId)
    local s = Core.sessions[playerId]
    if not s then return nil, "session_not_found" end
    return {
        playerId = s.playerId,
        license = s.license,
        userId = s.userId,
        name = s.name,
        state = s.state,
        loadedAtMs = s.loadedAtMs
    }
end)

exports("getPlayerIdByLicense", function(license)
    if type(license) ~= "string" then return nil end
    return Core.byLicense[license]
end)

exports("isLoaded", function(playerId)
    local s = Core.sessions[playerId]
    return (s and s.state == "loaded") or false
end)

exports("listSessions", function()
    local list = {}
    for _, s in pairs(Core.sessions) do
        table.insert(list, {
            playerId = s.playerId,
            license = s.license,
            state = s.state
        })
    end
    return list
end)

exports("emit", function(eventName, ...)
    if type(eventName) ~= "string" or eventName:sub(1, 3) ~= "ls:" then
        return nil, "invalid_event_prefix"
    end
    TriggerEvent(eventName, ...)
    return true
end)
