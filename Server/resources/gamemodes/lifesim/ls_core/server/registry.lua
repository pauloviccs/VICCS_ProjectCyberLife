--[[
    LIFESIM RP - Module Registry & Contract Enforcer
    Path: ls_core/server/registry.lua
    Controla o registro e a conformidade de todos os submódulos ls_* conectados ao core.
]]

---Registra um novo módulo do Life-Sim garantindo integridade e conformidade com o ecossistema
---@param d table Descritor do módulo
---@return boolean, string|nil
exports("registerModule", function(d)
    local owner = GetInvokingResource()
    if not owner then
        return nil, "export_call_required"
    end
    if owner:sub(1, 3) ~= "ls_" then
        return nil, "caller_denied"
    end
    if type(d) ~= "table" or type(d.version) ~= "string" or #d.version > 32 then
        return nil, "invalid_descriptor"
    end

    -- Validar orçamento de State Bags (máximo de 2048 bytes por módulo)
    local budget = 0
    local keyCount = 0
    for key, spec in pairs(d.stateKeys or {}) do
        if type(key) ~= "string" or key:sub(1, 3) ~= "ls." then
            return nil, "invalid_state_key_prefix"
        end
        keyCount = keyCount + 1
        budget = budget + (type(spec) == "table" and tonumber(spec.maxBytes) or 256)
    end

    if keyCount > 6 then
        return nil, "too_many_state_keys"
    end
    if budget > 2048 then
        return nil, "state_budget_exceeded"
    end

    local gen = (Open77.resource and Open77.resource.generation) and Open77.resource.generation(owner) or 1

    Core.modules[owner] = {
        name = owner,
        version = d.version,
        generation = gen,
        requires = d.requires or {},
        provides = d.provides or {},
        emits = d.emits or {},
        listens = d.listens or {},
        stateKeys = d.stateKeys or {},
        tables = d.tables or {},
        registeredAtMs = GetGameTimer()
    }

    Open77.log.info(("[ls_core:Registry] Módulo registrado com sucesso: '%s' (v%s)"):format(owner, d.version))
    TriggerEvent("ls:core:moduleRegistered", owner, d.version)
    return true
end)

exports("getModule", function(name)
    return Core.modules[name]
end)

exports("listModules", function()
    local list = {}
    for name, m in pairs(Core.modules) do
        table.insert(list, {
            name = name,
            version = m.version,
            registeredAtMs = m.registeredAtMs
        })
    end
    return list
end)

-- Watchdog de Módulos (detecta reload ou remoção de resources em tempo real)
CreateThread(function()
    while true do
        Wait(5000)
        if Open77.resource and Open77.resource.generation then
            for name, m in pairs(Core.modules) do
                local currentGen = Open77.resource.generation(name)
                if currentGen ~= m.generation then
                    Core.modules[name] = nil
                    Open77.log.warn(("[ls_core:Registry] Módulo '%s' recarregado ou desligado (geração %s -> %s)."):format(
                        name, tostring(m.generation), tostring(currentGen)
                    ))
                    TriggerEvent("ls:core:moduleDown", name, "generation_changed")
                end
            end
        end
    end
end)
