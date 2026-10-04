--[[
    LIFESIM RP - Housing Apartments & Routing Buckets Controller
    Path: ls_housing/server/apartments.lua
    
    Gerencia:
    1. Aquisição e locação de imóveis (integração financeira ACID com ls_economy).
    2. Instanciamento isolado de interiores via Routing Buckets (ls_core / Open77).
    3. Trânsito de entrada/saída de apartamentos e portas trancadas.
]]

--- Obtém epoch timestamp real via MariaDB (o sandbox Open77 NÃO expõe `os`).
--- Fallback: GetGameTimer() convertido a pseudo-epoch (não é UTC real, mas não crasheia).
local _cachedEpoch = 0
local _cachedAt = 0
local CACHE_TTL_MS = 2000 -- Reusa o valor por 2s para não floodar queries

local function getEpochTime()
    local now = GetGameTimer()
    if _cachedEpoch > 0 and (now - _cachedAt) < CACHE_TTL_MS then
        -- Interpola a diferença em ms para manter precisão sem query extra
        return _cachedEpoch + math.floor((now - _cachedAt) / 1000)
    end
    local ok, rows = pcall(function()
        return Database.query("SELECT UNIX_TIMESTAMP() AS epoch", {})
    end)
    if ok and rows and rows[1] and rows[1].epoch then
        _cachedEpoch = tonumber(rows[1].epoch) or 0
        _cachedAt = now
        return _cachedEpoch
    end
    -- Fallback resiliente: se já tínhamos um epoch real sincronizado anteriormente, extrapola a partir dele
    if _cachedEpoch > 0 then
        return _cachedEpoch + math.floor((now - _cachedAt) / 1000)
    end
    -- Fallback absoluto caso o banco ainda esteja indisponível:
    return math.floor(now / 1000)
end

--- Formata epoch em string legível para logs (substitui os.date que não existe no sandbox)
local function formatEpochUTC(epoch)
    -- Cálculo manual simplificado: apenas para log humano
    local days = math.floor(epoch / 86400)
    local rem = epoch % 86400
    local h = math.floor(rem / 3600)
    local m = math.floor((rem % 3600) / 60)
    local s = rem % 60
    return string.format("epoch:%d (%02d:%02d:%02d UTC +%dd)", epoch, h, m, s, days % 365)
end

local function findApartmentConfig(aptId)
    for _, apt in ipairs(Config.Apartments) do
        if apt.id == aptId then
            return apt
        end
    end
    return nil
end

--- Normaliza doorCoords (objeto único OU array de portas) em uma lista uniforme
local function getDoorList(apt)
    local d = apt and apt.doorCoords
    if not d then return {} end
    if d[1] and type(d[1]) == "table" and d[1].x then
        return d
    end
    if d.x then
        return { d }
    end
    return {}
end

-- =============================================================================
-- CONSULTA E OPERAÇÕES IMOBILIÁRIAS
-- =============================================================================

local function sendApartmentInfo(targetPlayer, aptId, license)
    local apt = findApartmentConfig(aptId)
    if not apt or not license then return end

    local rows, err = Database.query(
        "SELECT id, lease_type, is_locked, rent_due_unix, keyholders FROM ls_player_apartments WHERE license = ? AND apartment_id = ? LIMIT 1",
        { license, aptId }
    )

    local lease = rows and rows[1]
    local now = getEpochTime()
    local hasLease = lease ~= nil
    local leaseType = lease and lease.lease_type or nil
    local rentDueUnix = lease and tonumber(lease.rent_due_unix) or 0
    local isRentActive = (leaseType == "owned") or (leaseType == "rent" and rentDueUnix > now)
    local GRACE_PERIOD_SEC = 24 * 3600
    local inGracePeriod = false
    local graceHoursLeft = 0

    if leaseType == "rent" and rentDueUnix > 0 and rentDueUnix < now then
        local overdueSeconds = now - rentDueUnix
        if overdueSeconds <= GRACE_PERIOD_SEC then
            inGracePeriod = true
            graceHoursLeft = math.ceil((GRACE_PERIOD_SEC - overdueSeconds) / 3600)
        end
    end

    TriggerClientEvent("ls:housing:receiveInfo", targetPlayer, {
        apartment = apt,
        hasLease = hasLease,
        leaseType = leaseType,
        isLocked = lease and (tonumber(lease.is_locked) == 1) or false,
        rentDueUnix = rentDueUnix,
        isRentActive = isRentActive,
        inGracePeriod = inGracePeriod,
        graceHoursLeft = graceHoursLeft,
        serverTime = now
    })
end

RegisterNetEvent("ls:housing:requestInfo", function(aptId)
    local playerId = source
    CreateThread(function()
        local license = exports["ls_core"]:getPlayerLicense(playerId)
        if not license then return end
        sendApartmentInfo(playerId, aptId, license)
    end)
end)

---Executa a entrada autoritativa do jogador no interior instanciado (Routing Bucket)
---@param playerId integer
---@param aptId string
---@param license string
---@param doorIndex integer|nil
---@return boolean, string|nil
local function enterApartmentInternal(playerId, aptId, license, doorIndex)
    local apt = findApartmentConfig(aptId)
    if not apt then return false, "apt_not_found" end

    doorIndex = tonumber(doorIndex) or 1

    -- Aloca routing bucket exclusivo para a instância privada do jogador
    local instKey = license .. "_" .. aptId
    local bucketId = exports["ls_core"]:assignBucket("apartment", instKey)
    if not bucketId then
        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = false,
            message = "Erro ao alocar dimensão residencial (instância cheia)."
        })
        return false, "bucket_error"
    end

    -- Registra ocupação da instância e a porta de entrada utilizada
    Housing.activeInstances[instKey] = Housing.activeInstances[instKey] or { bucketId = bucketId, occupants = {} }
    Housing.activeInstances[instKey].occupants[playerId] = true
    Housing.playerLocations[playerId] = {
        aptId = aptId,
        ownerLicense = license,
        bucketId = bucketId,
        doorIndex = doorIndex
    }

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
        furniture = furnitureRows,
        entryDoorIndex = doorIndex
    })

    Open77.log.info(("[ls_housing] Jogador %d entrou no apartamento '%s' (Bucket %d, Porta #%d)."):format(playerId, apt.name, bucketId, doorIndex))
    return true
end

RegisterNetEvent("ls:housing:rent", function(aptId, doorIndex)
    local playerId = source
    CreateThread(function()
        local license = exports["ls_core"]:getPlayerLicense(playerId)
        if not license then return end

        local apt = findApartmentConfig(aptId)
        if not apt then return end

        -- Tenta débito em conta bancária; caso insuficiente, tenta carteira em mãos (Cash)
        local ok, err = exports["ls_economy"]:removeBank(playerId, apt.rentPrice, "Locação Residencial: " .. apt.name)
        if not ok then
            ok, err = exports["ls_economy"]:removeCash(playerId, apt.rentPrice, "Locação Residencial (Dinheiro Vivo): " .. apt.name)
        end

        if not ok then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Saldo insuficiente para locação (E$ " .. apt.rentPrice .. "). Verifique sua conta bancária ou carteira."
            })
            return
        end

        local dueUnix = getEpochTime() + (apt.rentPeriodHours * 3600)
        local updateRes, updateErr = Database.update([[
            INSERT INTO ls_player_apartments (license, apartment_id, lease_type, is_locked, rent_due_unix)
            VALUES (?, ?, 'rent', 1, ?)
            ON DUPLICATE KEY UPDATE lease_type = 'rent', rent_due_unix = VALUES(rent_due_unix)
        ]], { license, aptId, dueUnix })

        if not updateRes and updateErr then
            Open77.log.error(("[ls_housing] Falha ao persistir aluguel no MariaDB: %s"):format(tostring(updateErr)))
        end

        Open77.log.info(("[ls_housing] Jogador %d alugou o imóvel '%s' até %s."):format(playerId, apt.name, formatEpochUTC(dueUnix)))

        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = true,
            message = "Contrato de locação aprovado! Entrando no apartamento..."
        })

        sendApartmentInfo(playerId, aptId, license)
        enterApartmentInternal(playerId, aptId, license, doorIndex)
    end)
end)

RegisterNetEvent("ls:housing:buy", function(aptId, doorIndex)
    local playerId = source
    CreateThread(function()
        local license = exports["ls_core"]:getPlayerLicense(playerId)
        if not license then return end

        local apt = findApartmentConfig(aptId)
        if not apt then return end

        -- Tenta débito bancário; se insuficiente, tenta carteira
        local ok, err = exports["ls_economy"]:removeBank(playerId, apt.buyPrice, "Compra de Apartamento: " .. apt.name)
        if not ok then
            ok, err = exports["ls_economy"]:removeCash(playerId, apt.buyPrice, "Compra de Apartamento (Dinheiro Vivo): " .. apt.name)
        end

        if not ok then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Saldo insuficiente para compra (E$ " .. apt.buyPrice .. "). Verifique sua conta bancária ou carteira."
            })
            return
        end

        local updateRes, updateErr = Database.update([[
            INSERT INTO ls_player_apartments (license, apartment_id, lease_type, is_locked, rent_due_unix)
            VALUES (?, ?, 'owned', 1, 0)
            ON DUPLICATE KEY UPDATE lease_type = 'owned', rent_due_unix = 0
        ]], { license, aptId })

        if not updateRes and updateErr then
            Open77.log.error(("[ls_housing] Falha ao persistir compra no MariaDB: %s"):format(tostring(updateErr)))
        end

        Open77.log.info(("[ls_housing] Jogador %d comprou o imóvel '%s' em definitivo."):format(playerId, apt.name))

        TriggerClientEvent("ls:housing:feedback", playerId, {
            success = true,
            message = "Escritura emitida com sucesso! Entrando na sua nova residência..."
        })

        sendApartmentInfo(playerId, aptId, license)
        enterApartmentInternal(playerId, aptId, license, doorIndex)
    end)
end)

-- =============================================================================
-- ENTRADA, SAÍDA E INSTANCIAMENTO VIA ROUTING BUCKETS
-- =============================================================================

RegisterNetEvent("ls:housing:enter", function(aptId, doorIndex)
    local playerId = source
    CreateThread(function()
        local license = exports["ls_core"]:getPlayerLicense(playerId)
        if not license then return end

        local apt = findApartmentConfig(aptId)
        if not apt then return end

        -- Verifica se o jogador tem acesso (locatário ou proprietário)
        local rows = Database.query(
            "SELECT id, is_locked, lease_type, rent_due_unix FROM ls_player_apartments WHERE license = ? AND apartment_id = ? LIMIT 1",
            { license, aptId }
        )

        if not rows or #rows == 0 then
            TriggerClientEvent("ls:housing:feedback", playerId, {
                success = false,
                message = "Acesso negado: você não possui chave ou contrato para este apartamento."
            })
            return
        end

        local lease = rows[1]
        local now = getEpochTime()
        local due = tonumber(lease.rent_due_unix) or 0
        local GRACE_PERIOD_SEC = 24 * 3600

        if lease.lease_type == "rent" and due > 0 and due < now then
            local overdueSeconds = now - due
            if overdueSeconds <= GRACE_PERIOD_SEC then
                local hoursLeft = math.ceil((GRACE_PERIOD_SEC - overdueSeconds) / 3600)
                TriggerClientEvent("ls:housing:feedback", playerId, {
                    success = true,
                    message = ("AVISO KIROSHI: Contrato em carência (restam %d horas para despejo). Regularize seu aluguel."):format(hoursLeft)
                })
            else
                TriggerClientEvent("ls:housing:feedback", playerId, {
                    success = false,
                    message = "Acesso bloqueado: contrato de locação expirado além do prazo de carência. Regularize no terminal."
                })
                return
            end
        end

        enterApartmentInternal(playerId, aptId, license, doorIndex)
    end)
end)

RegisterNetEvent("ls:housing:exit", function(aptId, exitDoorIndex)
    local playerId = source
    CreateThread(function()
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

        local usedDoorIndex = exitDoorIndex or loc.doorIndex or 1
        Housing.playerLocations[playerId] = nil

        -- Determina qual porta retornar no mundo aberto
        local doors = getDoorList(apt)
        local targetDoor = doors[usedDoorIndex] or doors[1] or apt.doorCoords

        -- Retorna ao mundo público (Bucket 0)
        Open77.routingBuckets.setPlayer(playerId, 0)
        exports["ls_core"]:place(playerId, targetDoor, {
            heading = targetDoor.heading or 0.0,
            bucket = 0,
            fade = true
        })

        TriggerClientEvent("ls:housing:exitedApartment", playerId, {
            apartmentId = aptId,
            doorCoords = targetDoor
        })

        Open77.log.info(("[ls_housing] Jogador %d saiu do apartamento '%s' pela porta #%d e retornou ao mundo aberto."):format(playerId, apt.name, usedDoorIndex))
    end)
end)

-- Thread de inicialização e sincronização inicial do relógio mestre MariaDB
CreateThread(function()
    Wait(1500)
    local epoch = getEpochTime()
    Open77.log.info(("[ls_housing] Relógio residencial sincronizado com o MariaDB. Epoch inicial: %d"):format(epoch))
end)
