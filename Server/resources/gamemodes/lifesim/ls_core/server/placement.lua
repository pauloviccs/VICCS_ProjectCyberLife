--[[
    LIFESIM RP - Placement & Routing Bucket Management
    Path: ls_core/server/placement.lua
    Controla movimentação segura no mundo, teleporte e alocação de instâncias (Routing Buckets).
]]

Placement = Placement or {}
Placement.allocatedBuckets = {} -- [bucketId] = { kind = kind, ownerKey = ownerKey, allocatedAtMs = int }
Placement.byOwner = {}         -- [ownerKey] = bucketId

local BUCKET_START = (CoreConfig.Buckets and CoreConfig.Buckets.HousingStart) or 10000
local BUCKET_END   = (CoreConfig.Buckets and CoreConfig.Buckets.HousingEnd) or 19999

---Aloca um Routing Bucket do pool isolado para uma residência ou interior específico
---@param kind string Tipo de instância (ex: "apartment", "garage")
---@param ownerKey string Chave única do proprietário/imóvel
---@return integer|nil, string|nil
function Placement.assignBucket(kind, ownerKey)
    local caller = GetInvokingResource()
    if caller and caller:sub(1, 3) ~= "ls_" then
        return nil, "caller_denied"
    end

    -- Se o dono já possui um bucket ativo, reusar
    if Placement.byOwner[ownerKey] then
        return Placement.byOwner[ownerKey]
    end

    -- Encontrar próximo bucket livre
    for id = BUCKET_START, BUCKET_END do
        if not Placement.allocatedBuckets[id] then
            Placement.allocatedBuckets[id] = {
                kind = kind,
                ownerKey = ownerKey,
                allocatedAtMs = GetGameTimer()
            }
            Placement.byOwner[ownerKey] = id

            -- Desativar tráfego e população ambiente no interior instanciado se suportado
            if Open77.routingBuckets and Open77.routingBuckets.setPopulationEnabled then
                Open77.routingBuckets.setPopulationEnabled(id, false)
            end

            Open77.log.info(("[ls_core:Placement] Bucket %d alocado para '%s' (%s)"):format(id, ownerKey, kind))
            return id
        end
    end

    return nil, "bucket_pool_exhausted"
end

---Libera um Routing Bucket de volta para o pool
---@param bucketId integer
---@return boolean
function Placement.releaseBucket(bucketId)
    local caller = GetInvokingResource()
    if caller and caller:sub(1, 3) ~= "ls_" then
        return false
    end

    local alloc = Placement.allocatedBuckets[bucketId]
    if alloc then
        Placement.byOwner[alloc.ownerKey] = nil
        Placement.allocatedBuckets[bucketId] = nil
        Open77.log.info(("[ls_core:Placement] Bucket %d liberado com sucesso."):format(bucketId))
        return true
    end
    return false
end

---Teleporta um jogador vivo com validação estrita de integridade
---@param playerId integer
---@param position table { x = number, y = number, z = number }
---@param opts? table { heading?: number, bucket?: integer, fade?: boolean }
---@return boolean, string|nil
function Placement.place(playerId, position, opts)
    local caller = GetInvokingResource()
    if caller and caller:sub(1, 3) ~= "ls_" then
        return nil, "caller_denied"
    end

    if not LS.isPlayerId(playerId) then
        return nil, "invalid_player_id"
    end

    if not (position and position.x and position.y and position.z) then
        return nil, "invalid_position"
    end

    opts = opts or {}

    -- Chamar a API nativa de teleporte do OPEN//77 (estritamente síncrona/não-yielding para exports)
    local ok, res, reason = pcall(function()
        if Open77.players and Open77.players.teleport then
            return Open77.players.teleport(playerId, position, opts)
        end
        error("API Open77.players.teleport não disponível")
    end)

    if not ok then
        Open77.log.error(("[ls_core:Placement] Falha ao invocar teleporte para jogador %d: %s"):format(playerId, tostring(res)))
        return nil, "teleport_failed"
    end

    if res == false or res == nil then
        Open77.log.warn(("[ls_core:Placement] Open77.players.teleport recusou jogador %d: %s"):format(playerId, tostring(reason or "unknown")))
        return nil, reason or "teleport_rejected"
    end

    return true
end

-- =============================================================================
-- EXPORTS
-- =============================================================================

exports("place", function(playerId, position, opts)
    return Placement.place(playerId, position, opts)
end)

exports("assignBucket", function(kind, ownerKey)
    return Placement.assignBucket(kind, ownerKey)
end)

exports("releaseBucket", function(bucketId)
    return Placement.releaseBucket(bucketId)
end)
