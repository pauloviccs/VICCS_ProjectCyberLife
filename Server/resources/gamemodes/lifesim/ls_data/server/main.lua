--[[
    LIFESIM RP - Data Resource Entrypoint
    Path: ls_data/server/main.lua
    Coordena ciclo de vida, inicialização do banco, migrations e exports públicos.
]]

DataReady = false

---Carrega ou cria um perfil na tabela ls_players
---@param license string
---@param userId? string
---@param displayName? string
---@return table|nil, string|nil
local function loadOrCreateProfile(license, userId, displayName)
    if type(license) ~= "string" or license == "" then
        return nil, "invalid_license"
    end

    displayName = displayName or "V"
    userId = userId or "local"

    -- 1. Tentar carregar perfil existente
    local rows, err = Database.query(
        "SELECT license, user_id, display_name, data, created_at FROM ls_players WHERE license = ? LIMIT 1",
        { license }
    )
    if err then return nil, err end

    if rows and rows[1] then
        local p = rows[1]
        local parsedData = nil
        if type(p.data) == "string" and p.data ~= "" then
            local ok, d = pcall(json.decode, p.data)
            parsedData = ok and d or {}
        else
            parsedData = p.data or {}
        end

        -- Atualizar last_seen_at
        Database.update("UPDATE ls_players SET last_seen_at = CURRENT_TIMESTAMP WHERE license = ?", { license })

        return {
            license = p.license,
            userId = p.user_id,
            displayName = p.display_name,
            data = parsedData
        }
    end

    -- 2. Não existe -> Criar novo perfil
    local defaultData = { onboarding = true, level = 1 }
    local encoded = json.encode(defaultData)

    local _, insertErr = Database.update([[
        INSERT INTO ls_players (license, user_id, display_name, data, last_seen_at)
        VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE display_name = VALUES(display_name), last_seen_at = CURRENT_TIMESTAMP
    ]], { license, userId, displayName, encoded })

    if insertErr then
        return nil, insertErr
    end

    Open77.log.info(("[ls_data] Novo perfil registrado para licença %s (%s)"):format(license, displayName))

    return {
        license = license,
        userId = userId,
        displayName = displayName,
        data = defaultData
    }
end

-- =============================================================================
-- EXPORTS
-- =============================================================================

-- Síncronos
exports("isReady", function()
    return DataReady and Database.isReady()
end)

exports("cacheGet", function(ns, license)
    return CacheService.get(ns, license)
end)

exports("cacheSet", function(ns, license, value)
    return CacheService.set(ns, license, value)
end)

exports("registerCacheNamespace", function(name, tableName, keyCol, dataCol)
    return CacheService.registerNamespace(name, tableName, keyCol, dataCol)
end)

-- Assíncronos
exports("waitReady", function()
    while not (DataReady and Database.isReady()) do
        Wait(50)
    end
    return true
end)

exports("loadOrCreateProfile", function(license, userId, displayName)
    return loadOrCreateProfile(license, userId, displayName)
end)

exports("cacheLoad", function(ns, license)
    return CacheService.load(ns, license)
end)

exports("flushLicense", function(license)
    return CacheService.flushLicense(license)
end)

exports("flushAll", function()
    return CacheService.flushAll()
end)

exports("registerMigrations", function(moduleName, migrationsList)
    return Migrations.apply(moduleName, migrationsList)
end)

-- Operações de Banco de Dados Diretas
local function sanitizeSqlArgs(arg1, arg2, arg3)
    if type(arg1) == "table" and type(arg2) == "string" then
        -- Chamado com sintaxe de dois pontos (ex: exports["ls_data"]:query(sql, params))
        return arg2, arg3
    end
    return arg1, arg2
end

exports("query", function(a, b, c)
    local sql, params = sanitizeSqlArgs(a, b, c)
    return Database.query(sql, params)
end)

exports("update", function(a, b, c)
    local sql, params = sanitizeSqlArgs(a, b, c)
    return Database.update(sql, params)
end)

exports("execute", function(a, b, c)
    local sql, params = sanitizeSqlArgs(a, b, c)
    return Database.update(sql, params)
end)


-- =============================================================================
-- CICLO DE VIDA (LIFECYCLE)
-- =============================================================================

AddEventHandler("onResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Open77.log.info("[ls_data] Inicializando camada de dados do Life-Sim...")

        -- 1. Aguardar banco
        if not Database.awaitReady(20000) then
            Open77.log.error("[ls_data] FALHA CRÍTICA: Banco de dados indisponível após 20 segundos.")
            return
        end

        -- 2. Inicializar migrações
        if not Migrations.init() then
            Open77.log.error("[ls_data] FALHA CRÍTICA: Falha ao aplicar migrações base.")
            return
        end

        -- 3. Registrar namespaces padrão
        CacheService.registerNamespace("profile", "ls_players", "license", "data")

        -- 4. Iniciar rotinas de background
        CacheService.startWorker()

        DataReady = true
        Open77.log.info("[ls_data] Camada de dados pronta e operacional (v0.1.0).")
        TriggerEvent("ls:data:ready")
    end)
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    Open77.log.info("[ls_data] Parando resource: executando flush final de dados em cache...")
    CacheService.flushAll()
    Open77.log.info("[ls_data] Flush final concluído.")
end)
