--[[
    LIFESIM RP - Housing Apartments & Routing Buckets Controller
    Path: ls_housing/server/apartments.lua
    
    Gerencia:
    1. Aquisição e locação de imóveis (integração financeira ACID com ls_economy).
    2. Instanciamento isolado de interiores via Routing Buckets (ls_core / Open77).
    3. Trânsito de entrada/saída de apartamentos e portas trancadas.
]]

local function getTimestamp()
    if Open77 and Open77.time and Open77.time.monotonic then
        return math.floor(Open77.time.monotonic())
    elseif GetGameTimer then
        return math.floor(GetGameTimer() / 1000)
    end
    return 0
end

local function findApartmentConfig(aptId)
    for _, apt in ipairs(Config.Apartments) do
        if apt.id == aptId then
            return apt
        end
    end
    return nil
end

-- =============================================================================
-- CONSULTA E OPERAÇÕES IMOBILIÁRIAS
-- =============================================================================

RegisterNetEvent("ls:housing:requestInfo", function(aptId)
    local playerId = source
    local license = exports["ls_core"]:getPlayerLicense(playerId)
    if not license then return end

    local apt = findApartmentConfig(aptId)
    if not apt then return end

    local rows, err = Database.query(
        "SELECT id, lease_type, is_locked, rent_due_unix, keyholders FROM ls_player_apartments WHERE license = ? AND apartment_id = ? LIMIT 1",
        { license, aptId }
    )

    local lease = rows and rows[1]
    TriggerClientEvent("ls:housing:receiveInfo", playerId, {
        apartment = apt,
        hasLease = lease ~= nil,
        leaseType = lease and lease.lease_type or nil,
        isLocked = lease and (lease.is_locked == 1) or true,
        rentDueUnix = lease and tonumber(lease.rent_due_unix) or 0
    })
end)

RegisterNetEvent("ls:housing:rent", function(aptId)
    local playerId = source
    local license = exports["ls_core"]:getPlayerLicense(playerId)
    if not license then return end

    local apt = findApartmentConfig(aptId)
    if not apt then return end

    -- Débito bancário seguro via ls_economy
    local ok, err = exports["ls_economy"]:removeBank(playerId, apt.rentPrice, "Locação Residencial: " .. apt.name)
    if not ok then
        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = false,
            message = "Saldo bancário insuficiente para locação (E$ " .. apt.rentPrice .. ")."
        })
        return
    end

    local dueUnix = getTimestamp() + (apt.rentPeriodHours * 3600)
    Database.update([[
        INSERT INTO ls_player_apartments (license, apartment_id, lease_type, is_locked, rent_due_unix)
        VALUES (?, ?, 'rent', 1, ?)
        ON DUPLICATE KEY UPDATE lease_type = 'rent', rent_due_unix = VALUES(rent_due_unix)
    ]], { license, aptId, dueUnix })

    Open77.log.info(("[ls_housing] Jogador %d alugou o imóvel '%s' até %s."):format(playerId, apt.name, tostring(dueUnix)))

    TriggerClientEvent("ls:housing:feedback", playerId, {
        success = true,
        message = "Contrato de locação aprovado! Apartamento liberado."
    })
    TriggerEvent("ls:housing:requestInfo", aptId)
end)

RegisterNetEvent("ls:housing:buy", function(aptId)
    local playerId = source
    local license = exports["ls_core"]:getPlayerLicense(playerId)
    if not license then return end

    local apt = findApartmentConfig(aptId)
    if not apt then return end

    local ok, err = exports["ls_economy"]:removeBank(playerId, apt.buyPrice, "Compra de Apartamento: " .. apt.name)
    if not ok then
        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = false,
            message = "Saldo bancário insuficiente para compra (E$ " .. apt.buyPrice .. ")."
        })
        return
    end

    Database.update([[
        INSERT INTO ls_player_apartments (license, apartment_id, lease_type, is_locked, rent_due_unix)
        VALUES (?, ?, 'owned', 1, 0)
        ON DUPLICATE KEY UPDATE lease_type = 'owned', rent_due_unix = 0
    ]], { license, aptId })

    Open77.log.info(("[ls_housing] Jogador %d comprou o imóvel '%s' em definitivo."):format(playerId, apt.name))

    TriggerClientEvent("ls:housing:feedback", playerId, {
        success = true,
        message = "Escritura emitida com sucesso! Você é o proprietário legítimo."
    })
    TriggerEvent("ls:housing:requestInfo", aptId)
end)

-- =============================================================================
-- ENTRADA, SAÍDA E INSTANCIAMENTO VIA ROUTING BUCKETS
-- =============================================================================

RegisterNetEvent("ls:housing:enter", function(aptId)
    local playerId = source
    local license = exports["ls_core"]:getPlayerLicense(playerId)
    if not license then return end

    local apt = findApartmentConfig(aptId)
    if not apt then return end

    -- Verifica se o jogador tem acesso (locatário ou proprietário)
    local rows = Database.query(
        "SELECT id, is_locked FROM ls_player_apartments WHERE license = ? AND apartment_id = ? LIMIT 1",
        { license, aptId }
    )

    if not rows or #rows == 0 then
        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = false,
            message = "Acesso negado: você não possui chave ou contrato para este apartamento."
        })
        return
    end

    -- Aloca routing bucket exclusivo para a instância privada do jogador
    local instKey = license .. "_" .. aptId
    local bucketId = exports["ls_core"]:assignBucket("apartment", instKey)
    if not bucketId then
        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = false,
            message = "Erro ao alocar dimensão residencial (instância cheia)."
        })
        return
    end

    -- Registra ocupação da instância
    Housing.activeInstances[instKey] = Housing.activeInstances[instKey] or { bucketId = bucketId, occupants = {} }
    Housing.activeInstances[instKey].occupants[playerId] = true
    Housing.playerLocations[playerId] = { aptId = aptId, ownerLicense = license, bucketId = bucketId }

    -- Move jogador para o bucket e posiciona no interior
    Open77.routingBuckets.setPlayer(playerId, bucketId)
    exports["ls_core"]:place(playerId, apt.interiorCoords, {
        heading = apt.interiorCoords.heading or 0.0,
        bucket = bucketId,
        fade = true
    })

    -- Carrega a mobília instalada neste apartamento
    local furnitureRows = Database.query(
        "SELECT id, template_id, x, y, z, heading, data FROM ls_apartment_furniture WHERE apartment_id = ? AND owner_license = ?",
        { aptId, license }
    ) or {}

    TriggerClientEvent("ls:housing:enteredApartment", playerId, {
        apartment = apt,
        bucketId = bucketId,
        furniture = furnitureRows
    })

    Open77.log.info(("[ls_housing] Jogador %d entrou no apartamento '%s' (Bucket %d)."):format(playerId, apt.name, bucketId))
end)

RegisterNetEvent("ls:housing:exit", function(aptId)
    local playerId = source
    local loc = Housing.playerLocations[playerId]
    if not loc or loc.aptId ~= aptId then return end

    local apt = findApartmentConfig(aptId)
    if not apt then return end

    local instKey = loc.ownerLicense .. "_" .. loc.aptId
    local inst = Housing.activeInstances[instKey]
    if inst and inst.occupants then
        inst.occupants[playerId] = nil
        local hasOccupants = false
        for _ in pairs(inst.occupants) do
            hasOccupants = true
            break
        end
        if not hasOccupants then
            exports["ls_core"]:releaseBucket(inst.bucketId)
            Housing.activeInstances[instKey] = nil
        end
    end

    Housing.playerLocations[playerId] = nil

    -- Retorna ao mundo público (Bucket 0)
    Open77.routingBuckets.setPlayer(playerId, 0)
    exports["ls_core"]:place(playerId, apt.doorCoords, {
        heading = apt.doorCoords.heading or 0.0,
        bucket = 0,
        fade = true
    })

    TriggerClientEvent("ls:housing:exitedApartment", playerId, {
        apartmentId = aptId
    })

    Open77.log.info(("[ls_housing] Jogador %d saiu do apartamento '%s' e retornou ao mundo aberto."):format(playerId, apt.name))
end)
