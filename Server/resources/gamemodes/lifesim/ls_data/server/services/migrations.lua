--[[
    LIFESIM RP - Migrations Service
    Path: ls_data/server/services/migrations.lua
    Gerenciamento declarativo e versionado de esquemas SQL por módulo.
]]

Migrations = Migrations or {}

---Inicializa a tabela mestre de rastreamento de migrações e aplica as migrações base do core
---@return boolean
function Migrations.init()
    -- 1. Garantir tabela ls_schema_migrations
    local createTableSql = [[
        CREATE TABLE IF NOT EXISTS ls_schema_migrations (
            module     VARCHAR(32) NOT NULL,
            version    INT         NOT NULL,
            checksum   CHAR(64)    NOT NULL,
            applied_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (module, version)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
    local _, err = Database.update(createTableSql)
    if err then
        Open77.log.error("[ls_data:Migrations] Falha ao criar ls_schema_migrations: " .. tostring(err))
        return false
    end

    -- 2. Registrar e aplicar migrações base do ls_data
    local baseMigrations = {
        {
            version = 1,
            checksum = "base_ls_players_schema_v1",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_players (
                    license      CHAR(32)    NOT NULL,
                    user_id      VARCHAR(36) NULL,
                    display_name VARCHAR(64) NOT NULL,
                    data         JSON        NULL,
                    created_at   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    last_seen_at TIMESTAMP   NULL,
                    PRIMARY KEY (license)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }

    return Migrations.apply("ls_data", baseMigrations)
end

---Aplica uma lista de migrações para um módulo específico de forma sequencial e idempotente
---@param moduleName string Nome do módulo (deve iniciar com ls_)
---@param migrationsList table Array de tabelas { version: integer, checksum: string, sql: string }
---@return boolean
function Migrations.apply(moduleName, migrationsList)
    if type(moduleName) ~= "string" or moduleName:sub(1, 3) ~= "ls_" then
        Open77.log.error("[ls_data:Migrations] Nome de módulo inválido para migração: " .. tostring(moduleName))
        return false
    end

    -- Buscar versões já aplicadas
    local rows, err = Database.query("SELECT version FROM ls_schema_migrations WHERE module = ?", { moduleName })
    if err then
        Open77.log.error(("[ls_data:Migrations] Falha ao consultar histórico do módulo %s: %s"):format(moduleName, tostring(err)))
        return false
    end

    local appliedVersions = {}
    if rows then
        for _, r in ipairs(rows) do
            appliedVersions[r.version] = true
        end
    end

    -- Ordenar por versão
    table.sort(migrationsList, function(a, b) return a.version < b.version end)

    for _, mig in ipairs(migrationsList) do
        if not appliedVersions[mig.version] then
            Open77.log.info(("[ls_data:Migrations] Aplicando migração %s v%d..."):format(moduleName, mig.version))
            local sqlText = mig.sql or mig.up
            if not sqlText or type(sqlText) ~= "string" or #sqlText == 0 then
                Open77.log.error(("[ls_data:Migrations] Migração %s v%d não contém instrução SQL válida."):format(moduleName, mig.version))
                return false
            end

            -- Executa cada instrução DDL separada por ponto-e-vírgula individualmente
            local hasFailed = false
            local lastErr = nil
            for stmt in sqlText:gmatch("[^;]+") do
                local trimmed = stmt:match("^%s*(.-)%s*$")
                if trimmed and #trimmed > 0 then
                    local _, stmtErr = Database.update(trimmed)
                    if stmtErr then
                        hasFailed = true
                        lastErr = stmtErr
                        break
                    end
                end
            end

            if hasFailed then
                Open77.log.error(("[ls_data:Migrations] ERRO ao aplicar migração %s v%d: %s"):format(moduleName, mig.version, tostring(lastErr)))
                return false
            end

            -- Registrar aplicação
            local _, logErr = Database.update(
                "INSERT INTO ls_schema_migrations (module, version, checksum) VALUES (?, ?, ?)",
                { moduleName, mig.version, mig.checksum or "none" }
            )
            if logErr then
                Open77.log.error(("[ls_data:Migrations] Falha ao registrar log da migração %s v%d: %s"):format(moduleName, mig.version, tostring(logErr)))
                return false
            end
            Open77.log.info(("[ls_data:Migrations] Migração %s v%d aplicada com sucesso."):format(moduleName, mig.version))
        end
    end

    return true
end
