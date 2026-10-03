--[[
    LIFESIM RP - Core Administrative & Diagnostic Commands
    Path: ls_core/server/admin.lua
    Comandos de console e diagnóstico com controle restrito por ACL.
]]

-- Informações de status do Core
RegisterCommand("ls.core.status", function(source, args)
    local sessionsCount = 0
    for _ in pairs(Core.sessions) do sessionsCount = sessionsCount + 1 end

    local modulesCount = 0
    for _ in pairs(Core.modules) do modulesCount = modulesCount + 1 end

    local msg = ("[ls_core:Status] Versão: %s | Boot Ready: %s | Sessões Ativas: %d | Módulos Registrados: %d"):format(
        CoreConfig.Version,
        tostring(Core.bootReady),
        sessionsCount,
        modulesCount
    )
    print(msg)
end, true) -- true = restrito a administradores / console

-- Diagnóstico de posição e estado de um jogador
RegisterCommand("ls.core.where", function(source, args)
    local targetId = tonumber(args[1] or source)
    if not targetId then
        print("[ls.core.where] Uso: ls.core.where <playerId>")
        return
    end

    local s = Core.sessions[targetId]
    local pos = Open77.players and Open77.players.position and Open77.players.position(targetId)
    local isReady = Open77.ready and Open77.ready.isReady and Open77.ready.isReady(targetId)
    local lifeState = Open77.players and Open77.players.getLifeState and Open77.players.getLifeState(targetId)

    local posStr = pos and ("X: %.1f, Y: %.1f, Z: %.1f (Bucket: %s)"):format(pos.x, pos.y, pos.z, tostring(pos.bucket or 0)) or "desconhecida"

    print(("[ls.core.where] Player %d | Estado: %s | Licença: %s | Posição: %s | Ready: %s | Life: %s"):format(
        targetId,
        s and s.state or "sem_sessao",
        s and s.license or "sem_licenca",
        posStr,
        tostring(isReady),
        tostring(lifeState or "nenhum")
    ))
end, true)

-- Listagem de módulos registrados
RegisterCommand("ls.core.modules", function(source, args)
    print("================== MÓDULOS LIFESIM REGISTRADOS ==================")
    local count = 0
    for name, m in pairs(Core.modules) do
        count = count + 1
        print(("- %s (v%s) | Geração: %s"):format(name, m.version, tostring(m.generation)))
    end
    if count == 0 then
        print("Nenhum módulo registrado no momento.")
    end
    print("==================================================================")
end, true)
