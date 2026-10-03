--[[
    LIFESIM RP - Database Service
    Path: ls_data/server/services/database.lua
    Abstração e segurança sobre a bridge MySQL/MariaDB nativa do OPEN//77.
]]

Database = Database or {}
Database.ready = false

---Verifica se a bridge MySQL está conectada e pronta
---@return boolean
function Database.isReady()
    if Database.ready then return true end
    if MySQL and MySQL.isReady then
        Database.ready = MySQL.isReady()
        return Database.ready
    end
    return false
end

---Aguarda assincronamente até que a conexão com o banco esteja estabelecida
---@param timeoutMs? integer Timeout em milissegundos (padrão: 15000)
---@return boolean
function Database.awaitReady(timeoutMs)
    timeoutMs = timeoutMs or 15000
    local start = GetGameTimer()
    while not Database.isReady() do
        if (GetGameTimer() - start) > timeoutMs then
            Open77.log.error("[ls_data:Database] Timeout ao aguardar conexão com o banco MariaDB.")
            return false
        end
        Wait(100)
    end
    return true
end

---Executa uma query parametrizada assíncrona (SELECT)
---@param query string
---@param params? table
---@return table|nil, string|nil
function Database.query(query, params)
    if not Database.isReady() then
        return nil, "database_not_ready"
    end

    local ok, res = pcall(function()
        if MySQL.query and MySQL.query.await then
            return MySQL.query.await(query, params or {})
        elseif MySQL.query then
            local p = MySQL.query(query, params or {})
            return p and p.await and p:await() or p
        end
        error("API MySQL.query não encontrada")
    end)

    if not ok then
        Open77.log.error(("[ls_data:Database] Erro na query SQL: %s | Query: %s"):format(tostring(res), query))
        return nil, "query_execution_failed"
    end

    return res
end

---Executa uma query de atualização parametrizada assíncrona (UPDATE / INSERT / DELETE)
---@param query string
---@param params? table
---@return integer|nil, string|nil Retorna número de linhas afetadas ou nil, razao
function Database.update(query, params)
    if not Database.isReady() then
        return nil, "database_not_ready"
    end

    local ok, res = pcall(function()
        if MySQL.update and MySQL.update.await then
            return MySQL.update.await(query, params or {})
        elseif MySQL.update then
            local p = MySQL.update(query, params or {})
            return p and p.await and p:await() or p
        end
        error("API MySQL.update não encontrada")
    end)

    if not ok then
        Open77.log.error(("[ls_data:Database] Erro no update SQL: %s | Query: %s"):format(tostring(res), query))
        return nil, "update_execution_failed"
    end

    return res
end

---Executa uma query retornando apenas um valor escalar
---@param query string
---@param params? table
---@return any, string|nil
function Database.scalar(query, params)
    if not Database.isReady() then
        return nil, "database_not_ready"
    end

    local ok, res = pcall(function()
        if MySQL.scalar and MySQL.scalar.await then
            return MySQL.scalar.await(query, params or {})
        elseif MySQL.scalar then
            local p = MySQL.scalar(query, params or {})
            return p and p.await and p:await() or p
        end
        error("API MySQL.scalar não encontrada")
    end)

    if not ok then
        Open77.log.error(("[ls_data:Database] Erro no scalar SQL: %s | Query: %s"):format(tostring(res), query))
        return nil, "scalar_execution_failed"
    end

    return res
end
