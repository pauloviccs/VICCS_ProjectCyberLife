--[[
    LIFESIM RP - Spawn Points & Fast Transit Server Manager
    Path: ls_spawn/server/main.lua
    
    Gerencia o ciclo de vida do spawn após a loading screen:
    1. Primeiro spawn obrigatório no Megabuilding H10 sem menu.
    2. Spawns subsequentes em locais públicos (Megabuildings, Praças, Metrópoles, Última Posição).
    3. Persistência de estado e última posição conhecida via ls_data (MariaDB / cache).
    4. Teleporte seguro e autoritativo com congelamento/descongelamento via Open77 e ls_core.
]]

local function getTimestamp()
    if Open77 and Open77.time and Open77.time.monotonic then
        return math.floor(Open77.time.monotonic())
    elseif GetGameTimer then
        return math.floor(GetGameTimer() / 1000)
    end
    return 0
end

local SpawnServer = {
    pendingSpawns = {}, -- [playerId] = { license = string, openedAt = number }
    activePlayers = {}  -- [playerId] = { license = string, spawnState = table }
}

-- =============================================================================
-- INICIALIZAÇÃO E INTEGRAÇÃO COM BANCO (ls_data)
-- =============================================================================

CreateThread(function()
    -- 1. Aguarda prontidão do ls_data
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registra migração SQL da tabela de spawns
    local migrations = {
        {
            version = 1,
            description = "Criação da tabela ls_player_spawns",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_player_spawns (
                    license CHAR(32) NOT NULL,
                    data LONGTEXT NOT NULL,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (license)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]],
            up = [[
                CREATE TABLE IF NOT EXISTS ls_player_spawns (
                    license CHAR(32) NOT NULL,
                    data LONGTEXT NOT NULL,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (license)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }

    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_spawn", migrations)
    if migCall then migCall:await() end

    -- 3. Registra namespace no CacheService do ls_data (write-behind resiliente)
    local cacheCall = Open77.exports.call("ls_data", "registerCacheNamespace", "spawn_state", "ls_player_spawns", "license", "data")
    if cacheCall then cacheCall:await() end

    Open77.log.info("[ls_spawn] Servidor de spawn points inicializado e conectado ao MariaDB.")
end)

-- =============================================================================
-- GERENCIAMENTO DE SPAWN NO LOGIN
-- =============================================================================

---Executa o primeiro spawn automático e obrigatório no Megabuilding H10
---@param playerId integer
---@param license string
---@param spawnState table
local function handleFirstSpawn(playerId, license, spawnState)
    local first = Config.FirstSpawn
    local coords = first.coords

    Open77.log.info(("[ls_spawn] Primeiro spawn do cidadão %d (%s) -> %s"):format(
        playerId, license, first.name
    ))

    -- Atualiza o estado para marcar que o primeiro spawn já foi realizado
    spawnState = spawnState or {}
    spawnState.firstSpawnDone = true
    spawnState.lastPosition = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = coords.heading or 180.0
    }
    spawnState.lastSpawnId = first.id
    spawnState.spawnCount = 1
    spawnState.firstSpawnAt = getTimestamp()

    SpawnServer.activePlayers[playerId] = {
        license = license,
        spawnState = spawnState
    }

    -- Persiste imediatamente no ls_data
    Open77.exports.call("ls_data", "cacheSet", "spawn_state", license, spawnState)
    Open77.exports.call("ls_data", "flushLicense", license)

    -- Executa teleporte autoritativo com fade (protegido por pcall)
    local ok, res = pcall(function()
        return exports["ls_core"]:place(playerId, coords, {
            heading = coords.heading or 180.0,
            fade = true
        })
    end)

    if not ok or not res then
        Open77.log.error(("[ls_spawn] Falha ao posicionar jogador %d no primeiro spawn: %s"):format(playerId, tostring(res)))
    end

    -- Notifica o cliente para exibir a boas-vindas diegética Kiroshi
    TriggerClientEvent("ls:spawn:firstSpawnWelcome", playerId, {
        locationName = first.name,
        district = first.district,
        subdistrict = first.subdistrict,
        message = first.welcomeMessage
    })
end

---Abre a tela de seleção de spawns públicos para personagens já existentes
---@param playerId integer
---@param license string
---@param spawnState table
local function handlePublicSpawnSelection(playerId, license, spawnState)
    Open77.log.info(("[ls_spawn] Cidadão %d (%s) abrindo menu de seleção de spawn."):format(playerId, license))

    SpawnServer.pendingSpawns[playerId] = {
        license = license,
        openedAt = getTimestamp()
    }
    SpawnServer.activePlayers[playerId] = {
        license = license,
        spawnState = spawnState
    }

    -- Congela locomoção no servidor durante a seleção para evitar quedas no vazio
    pcall(function()
        if Open77.players and Open77.players.setFrozen then
            Open77.players.setFrozen(playerId, true)
        end
    end)

    -- Prepara lista de pontos de spawn enriquecida
    local availableSpawns = {}
    local lastPos = spawnState.lastPosition

    for _, sp in ipairs(Config.PublicSpawns) do
        local copy = {
            id = sp.id,
            name = sp.name,
            district = sp.district,
            subdistrict = sp.subdistrict,
            badge = sp.badge,
            threatLevel = sp.threatLevel,
            threatRating = sp.threatRating or 1,
            category = sp.category or "plaza",
            description = sp.description,
            transitInfo = sp.transitInfo,
            accentColor = sp.accentColor,
            coords = sp.coords
        }

        if sp.id == "last_position" then
            if lastPos and lastPos.x and lastPos.y and lastPos.z then
                copy.coords = lastPos
                copy.available = true
            else
                -- Fallback se não houver última posição registrada
                copy.coords = Config.FirstSpawn.coords
                copy.available = false
                copy.description = "Nenhum ponto anterior gravado. Padrão: Megabuilding H10."
            end
        else
            copy.available = true
        end

        table.insert(availableSpawns, copy)
    end

    -- Dispara para o cliente abrir a WebUI
    TriggerClientEvent("ls:spawn:open", playerId, {
        spawns = availableSpawns,
        lastPosition = lastPos,
        timeoutSec = Config.Transition.spawnTimeoutSec or 120
    })
end

-- =============================================================================
-- EVENT HANDLERS DO LIFESIM
-- =============================================================================

-- Disparado pelo ls_core quando o jogador carrega sua sessão no servidor
AddEventHandler("ls:core:playerLoaded", function(playerId, license)
    playerId = tonumber(playerId)
    if not playerId or not license then return end

    CreateThread(function()
        -- 1. Carrega dados de spawn do jogador via ls_data
        local loadCall = Open77.exports.call("ls_data", "cacheLoad", "spawn_state", license)
        local stateData = nil
        if loadCall then
            stateData = loadCall:await()
        else
            stateData = exports["ls_data"]:cacheGet("spawn_state", license)
        end

        -- Se não tiver registro ou firstSpawnDone for falso/nulo:
        -- Inicializa o estado com firstSpawnDone = true para liberar o seletor público com as opções!
        if not stateData or not stateData.firstSpawnDone then
            stateData = stateData or {}
            stateData.firstSpawnDone = true
            stateData.lastPosition = nil -- Sem última posição gravada ainda
            stateData.spawnCount = 0
            stateData.firstSpawnAt = getTimestamp()
            
            Open77.exports.call("ls_data", "cacheSet", "spawn_state", license, stateData)
        end

        -- Abre o seletor para o jogador escolher seu ponto de despertar (Megabuildings, Praças, etc.)
        handlePublicSpawnSelection(playerId, license, stateData)
    end)
end)

-- Recebe a escolha do jogador a partir da WebUI
RegisterNetEvent("ls:spawn:select", function(spawnId)
    local playerId = source
    local pending = SpawnServer.pendingSpawns[playerId]
    local playerEntry = SpawnServer.activePlayers[playerId]
    local license = (pending and pending.license) or (playerEntry and playerEntry.license)

    if not pending then
        Open77.log.warn(("[ls_spawn] Jogador %d selecionou spawn sem pendência ativa (re-click ou atraso de rede). Reconfirmando liberação."):format(playerId))
        -- Garante que o jogador seja descongelado no servidor
        pcall(function()
            if Open77.players and Open77.players.setFrozen then
                Open77.players.setFrozen(playerId, false)
            end
        end)
        TriggerClientEvent("ls:spawn:completed", playerId, {
            spawnId = spawnId or "last_position",
            name = "Sincronização Neural",
            district = "Night City",
            coords = playerEntry and playerEntry.spawnState and playerEntry.spawnState.lastPosition or Config.FirstSpawn.coords
        })
        return
    end

    local spawnState = playerEntry and playerEntry.spawnState or {}

    -- Resolve as coordenadas do spawn selecionado
    local targetCoords = nil
    local targetName = "Desconhecido"
    local targetDistrict = "Night City"

    if spawnId == "last_position" then
        if spawnState.lastPosition and spawnState.lastPosition.x then
            targetCoords = spawnState.lastPosition
            targetName = "Última Conexão Registrada"
            targetDistrict = "Night City"
        else
            targetCoords = Config.FirstSpawn.coords
            targetName = Config.FirstSpawn.name
            targetDistrict = Config.FirstSpawn.district
        end
    else
        for _, sp in ipairs(Config.PublicSpawns) do
            if sp.id == spawnId then
                targetCoords = sp.coords
                targetName = sp.name
                targetDistrict = sp.district
                break
            end
        end
    end

    -- Fallback de segurança se ID for inválido
    if not targetCoords then
        Open77.log.warn(("[ls_spawn] ID de spawn desconhecido '%s' para jogador %d. Aplicando fallback H10."):format(tostring(spawnId), playerId))
        targetCoords = Config.FirstSpawn.coords
        targetName = Config.FirstSpawn.name
        targetDistrict = Config.FirstSpawn.district
    end

    -- Remove da lista de pendentes
    SpawnServer.pendingSpawns[playerId] = nil

    -- Atualiza última posição e estatísticas no estado
    spawnState.lastPosition = {
        x = targetCoords.x,
        y = targetCoords.y,
        z = targetCoords.z,
        heading = targetCoords.heading or 0.0
    }
    spawnState.lastSpawnId = spawnId
    spawnState.spawnCount = (spawnState.spawnCount or 0) + 1
    spawnState.lastSpawnAt = getTimestamp()

    -- Salva no ls_data
    Open77.exports.call("ls_data", "cacheSet", "spawn_state", license, spawnState)

    -- Executa o teleporte via ls_core protegido com pcall
    local ok, res = pcall(function()
        return exports["ls_core"]:place(playerId, targetCoords, {
            heading = targetCoords.heading or 0.0,
            fade = true
        })
    end)

    if not ok or not res then
        Open77.log.error(("[ls_spawn] Erro ao posicionar jogador %d em '%s': %s"):format(playerId, targetName, tostring(res)))
    end

    -- Descongela o jogador no servidor incondicionalmente
    pcall(function()
        if Open77.players and Open77.players.setFrozen then
            Open77.players.setFrozen(playerId, false)
        end
    end)

    Open77.log.info(("[ls_spawn] Jogador %d spawnou com sucesso em '%s' (%s)."):format(
        playerId, targetName, targetDistrict
    ))

    -- Notifica o cliente para fechar a interface, teleportar nativamente e restaurar o HUD
    TriggerClientEvent("ls:spawn:completed", playerId, {
        spawnId = spawnId,
        name = targetName,
        district = targetDistrict,
        coords = targetCoords
    })
end)

-- Grava a última posição ao descarregar a sessão do jogador
AddEventHandler("ls:core:playerUnloading", function(playerId, license, reason)
    playerId = tonumber(playerId)
    if not playerId or not license then return end

    local pos = nil
    pcall(function()
        if Open77.players and Open77.players.position then
            pos = Open77.players.position(playerId)
        end
    end)

    if pos and pos.x and pos.y and pos.z then
        local pEntry = SpawnServer.activePlayers[playerId]
        local spawnState = pEntry and pEntry.spawnState or {}
        spawnState.lastPosition = {
            x = pos.x,
            y = pos.y,
            z = pos.z,
            heading = 0.0
        }
        Open77.exports.call("ls_data", "cacheSet", "spawn_state", license, spawnState)
    end

    SpawnServer.pendingSpawns[playerId] = nil
    SpawnServer.activePlayers[playerId] = nil
end)

-- =============================================================================
-- EXPORTS PÚBLICOS
-- =============================================================================

exports("getFirstSpawn", function()
    return Config.FirstSpawn
end)

exports("getPublicSpawns", function()
    return Config.PublicSpawns
end)
