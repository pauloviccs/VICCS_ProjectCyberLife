--[[
    LIFESIM RP - Housing Server Lifecycle & Migrations
    Path: ls_housing/server/main.lua
    
    Gerencia:
    1. Migrações de banco de dados MariaDB via ls_data (ls_player_apartments, ls_apartment_furniture).
    2. Namespaces de cache com política write-behind resiliente.
    3. Rastreamento e encerramento de routing buckets em desconexões.
]]

Housing = Housing or {}
Housing.activeInstances = {} -- [ownerLicense .. "_" .. aptId] = { bucketId = int, occupants = { [playerId] = true } }
Housing.playerLocations = {} -- [playerId] = { aptId = string, ownerLicense = string, bucketId = int }

Database = {
    query = function(sql, params)
        local ok, rows = pcall(function()
            if exports["ls_data"] and exports["ls_data"].query then
                return exports["ls_data"]:query(sql, params)
            elseif MySQL and MySQL.query and MySQL.query.await then
                return MySQL.query.await(sql, params or {})
            elseif Open77 and Open77.database and Open77.database.query then
                return Open77.database.query(sql, params or {})
            end
            return nil
        end)
        if ok and type(rows) == "table" then
            return rows
        end
        return {}
    end,
    update = function(sql, params)
        local ok, res, err = pcall(function()
            if exports["ls_data"] and exports["ls_data"].execute then
                return exports["ls_data"]:execute(sql, params)
            elseif MySQL and MySQL.update and MySQL.update.await then
                return MySQL.update.await(sql, params or {})
            elseif Open77 and Open77.database and Open77.database.execute then
                return Open77.database.execute(sql, params or {})
            end
            return nil
        end)
        if ok then
            return res, err
        end
        return nil, tostring(res)
    end,
    execute = function(sql, params)
        return Database.update(sql, params)
    end
}

CreateThread(function()
    -- 1. Aguarda prontidão do motor de banco ls_data
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registra migrações SQL declarativas
    local migrations = {
        {
            version = 1,
            description = "Criação das tabelas ls_player_apartments e ls_apartment_furniture",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_player_apartments (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    license CHAR(32) NOT NULL,
                    apartment_id VARCHAR(64) NOT NULL,
                    lease_type ENUM('rent', 'owned') NOT NULL DEFAULT 'rent',
                    is_locked TINYINT(1) NOT NULL DEFAULT 1,
                    rent_due_unix BIGINT NOT NULL DEFAULT 0,
                    keyholders LONGTEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_license (license),
                    INDEX idx_apt (apartment_id),
                    UNIQUE KEY uq_player_apt (license, apartment_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS ls_apartment_furniture (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    apartment_id VARCHAR(64) NOT NULL,
                    owner_license CHAR(32) NOT NULL,
                    template_id VARCHAR(64) NOT NULL,
                    x FLOAT NOT NULL,
                    y FLOAT NOT NULL,
                    z FLOAT NOT NULL,
                    heading FLOAT NOT NULL,
                    data LONGTEXT,
                    placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_apt_owner (apartment_id, owner_license)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]],
            up = [[
                CREATE TABLE IF NOT EXISTS ls_player_apartments (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    license CHAR(32) NOT NULL,
                    apartment_id VARCHAR(64) NOT NULL,
                    lease_type ENUM('rent', 'owned') NOT NULL DEFAULT 'rent',
                    is_locked TINYINT(1) NOT NULL DEFAULT 1,
                    rent_due_unix BIGINT NOT NULL DEFAULT 0,
                    keyholders LONGTEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_license (license),
                    INDEX idx_apt (apartment_id),
                    UNIQUE KEY uq_player_apt (license, apartment_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS ls_apartment_furniture (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    apartment_id VARCHAR(64) NOT NULL,
                    owner_license CHAR(32) NOT NULL,
                    template_id VARCHAR(64) NOT NULL,
                    x FLOAT NOT NULL,
                    y FLOAT NOT NULL,
                    z FLOAT NOT NULL,
                    heading FLOAT NOT NULL,
                    data LONGTEXT,
                    placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_apt_owner (apartment_id, owner_license)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }

    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_housing", migrations)
    if migCall then migCall:await() end

    Open77.log.info("[ls_housing] Servidor de habitação vertical inicializado e conectado ao MariaDB.")
end)

-- Limpeza de buckets ao desconectar jogador
AddEventHandler("ls:core:playerUnloading", function(playerId, license, reason)
    playerId = tonumber(playerId)
    if not playerId then return end

    local loc = Housing.playerLocations[playerId]
    if loc then
        local instKey = loc.ownerLicense .. "_" .. loc.aptId
        local inst = Housing.activeInstances[instKey]
        if inst and inst.occupants then
            inst.occupants[playerId] = nil
            -- Se não houver mais ocupantes no apartamento, libera o bucket
            local hasOccupants = false
            for _ in pairs(inst.occupants) do
                hasOccupants = true
                break
            end
            if not hasOccupants then
                exports["ls_core"]:releaseBucket(inst.bucketId)
                Housing.activeInstances[instKey] = nil
                Open77.log.info(("[ls_housing] Instância '%s' liberada (bucket %d) por falta de ocupantes."):format(instKey, inst.bucketId))
            end
        end
        Housing.playerLocations[playerId] = nil
    end
end)
