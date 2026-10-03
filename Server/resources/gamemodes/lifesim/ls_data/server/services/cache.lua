--[[
    LIFESIM RP - Cache Service (Write-Behind)
    Path: ls_data/server/services/cache.lua
    Gerencia dados em memória para acesso síncrono rápido e persistência em lotes (Write-Behind).
]]

CacheService = CacheService or {}
CacheService.namespaces = {}
CacheService.entities = {}

---Registra um namespace declarativo para cache
---@param name string Identificador do namespace (ex: "vitals", "profile")
---@param tableName string Nome da tabela (deve começar com ls_)
---@param keyColumn? string Coluna de chave primária (padrão: "license")
---@param dataColumn? string Coluna de dados JSON (padrão: "data")
---@return boolean, string|nil
function CacheService.registerNamespace(name, tableName, keyColumn, dataColumn)
    if type(name) ~= "string" or type(tableName) ~= "string" or tableName:sub(1, 3) ~= "ls_" then
        return false, "invalid_namespace_or_table"
    end

    keyColumn = keyColumn or "license"
    dataColumn = dataColumn or "data"

    CacheService.namespaces[name] = {
        table = tableName,
        keyCol = keyColumn,
        dataCol = dataColumn
    }
    CacheService.entities[name] = CacheService.entities[name] or {}

    Open77.log.info(("[ls_data:Cache] Namespace registrado: '%s' -> %s (%s, %s)"):format(
        name, tableName, keyColumn, dataColumn
    ))
    return true
end

---Obtém um valor do cache de forma síncrona (apenas memória)
---@param namespace string
---@param license string
---@return any|nil
function CacheService.get(namespace, license)
    local ns = CacheService.entities[namespace]
    if not ns then return nil end
    local entry = ns[license]
    return entry and entry.value or nil
end

---Define ou atualiza um valor no cache de forma síncrona, marcando-o como 'dirty'
---@param namespace string
---@param license string
---@param value any
---@return boolean
function CacheService.set(namespace, license, value)
    local ns = CacheService.entities[namespace]
    if not ns then return false end

    local entry = ns[license]
    if not entry then
        entry = { value = value, dirty = true, loadedAtMs = GetGameTimer() }
        ns[license] = entry
    else
        entry.value = value
        entry.dirty = true
    end
    return true
end

---Carrega assincronamente os dados do banco para o cache caso não estejam em memória
---@param namespace string
---@param license string
---@return any|nil, string|nil
function CacheService.load(namespace, license)
    local spec = CacheService.namespaces[namespace]
    if not spec then return nil, "unknown_namespace" end

    local existing = CacheService.get(namespace, license)
    if existing ~= nil then return existing end

    local query = ("SELECT %s FROM %s WHERE %s = ? LIMIT 1"):format(spec.dataCol, spec.table, spec.keyCol)
    local rows, err = Database.query(query, { license })
    if err then return nil, err end

    local loadedValue = nil
    if rows and rows[1] then
        local raw = rows[1][spec.dataCol]
        if type(raw) == "string" and raw ~= "" then
            local ok, parsed = pcall(json.decode, raw)
            loadedValue = ok and parsed or raw
        else
            loadedValue = raw
        end
    end

    local ns = CacheService.entities[namespace]
    ns[license] = { value = loadedValue, dirty = false, loadedAtMs = GetGameTimer() }
    return loadedValue
end

---Persiste entradas 'dirty' de uma licença específica no banco de dados
---@param license string
---@return boolean
function CacheService.flushLicense(license)
    for nsName, spec in pairs(CacheService.namespaces) do
        local ns = CacheService.entities[nsName]
        local entry = ns and ns[license]
        if entry and entry.dirty then
            local encodedData = (type(entry.value) == "table") and json.encode(entry.value) or entry.value
            local sql = ([[
                INSERT INTO %s (%s, %s) VALUES (?, ?)
                ON DUPLICATE KEY UPDATE %s = VALUES(%s)
            ]]):format(spec.table, spec.keyCol, spec.dataCol, spec.dataCol, spec.dataCol)

            local _, err = Database.update(sql, { license, encodedData })
            if not err then
                entry.dirty = false
            else
                Open77.log.error(("[ls_data:Cache] Falha ao persistir licença %s no namespace %s: %s"):format(
                    license, nsName, tostring(err)
                ))
            end
        end
    end
    return true
end

---Persiste todas as entradas sujas de todos os namespaces
---@return integer Total de registros persistidos
function CacheService.flushAll()
    local flushedCount = 0
    for nsName, spec in pairs(CacheService.namespaces) do
        local ns = CacheService.entities[nsName]
        if ns then
            for license, entry in pairs(ns) do
                if entry.dirty then
                    local encodedData = (type(entry.value) == "table") and json.encode(entry.value) or entry.value
                    local sql = ([[
                        INSERT INTO %s (%s, %s) VALUES (?, ?)
                        ON DUPLICATE KEY UPDATE %s = VALUES(%s)
                    ]]):format(spec.table, spec.keyCol, spec.dataCol, spec.dataCol, spec.dataCol)

                    local _, err = Database.update(sql, { license, encodedData })
                    if not err then
                        entry.dirty = false
                        flushedCount = flushedCount + 1
                    end
                    Wait(0) -- Cede execução para evitar estouro de quotas de coroutine
                end
            end
        end
    end
    return flushedCount
end

---Inicia a thread de background para flush periódico (Write-Behind a cada 5 minutos)
function CacheService.startWorker()
    CreateThread(function()
        while true do
            Wait(300000) -- 5 minutos
            local count = CacheService.flushAll()
            if count > 0 then
                Open77.log.info(("[ls_data:CacheWorker] Flush periódico concluído: %d registros atualizados."):format(count))
            end
        end
    end)
end
