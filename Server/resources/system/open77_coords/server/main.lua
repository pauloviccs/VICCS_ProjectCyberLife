--[[
    OPEN//77 - Spatial Positioning & Coordinate Inspector (Coords Tool)
    Path: open77_coords/server/main.lua
    Validação autoritativa de roles/permissões e disparo da interface de coordenadas.
]]

---Valida se o jogador possui role autorizada (admin, moderator, support, etc.)
---@param playerId integer
---@return boolean
local function isPlayerAuthorized(playerId)
    if playerId == 0 then return true end

    if Open77 and Open77.acl then
        -- 1. Verificação de permissões diretas via ACL
        if Open77.acl.isAllowed then
            for _, perm in ipairs(CoordsConfig.AllowedPermissions) do
                local ok, allowed = pcall(Open77.acl.isAllowed, playerId, perm)
                if ok and allowed == true then
                    return true
                end
            end
        end

        -- 2. Verificação de roles atribuídas ao jogador
        if Open77.acl.roles then
            local ok, roles = pcall(Open77.acl.roles, playerId)
            if ok and type(roles) == "table" then
                for _, r in ipairs(roles) do
                    local roleLower = tostring(r):lower()
                    if CoordsConfig.AllowedRoles[roleLower] then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- =============================================================================
-- REGISTRO DO COMANDO /coords
-- =============================================================================

RegisterCommand(CoordsConfig.CommandName, function(source, args, raw)
    local playerId = source
    if playerId == nil or playerId <= 0 then
        print("[open77_coords] O comando /" .. CoordsConfig.CommandName .. " requer uma sessão ativa em jogo.")
        return
    end

    if not isPlayerAuthorized(playerId) then
        Open77.log.warn(("[open77_coords] Tentativa de acesso negada ao /coords pelo jogador %d."):format(playerId))
        TriggerClientEvent("open77:chat:addMessage", playerId, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "SEGURANÇA KIROSHI", "Acesso negado: o inspetor de coordenadas é restrito a Admin/Moderator/Support." }
        })
        return
    end

    Open77.log.info(("[open77_coords] Jogador %d abriu o inspetor de coordenadas."):format(playerId))
    TriggerClientEvent("open77_coords:openUI", playerId)
end, false)

-- Sugestão de comando no chat
RegisterNetEvent("chat:ready", function()
    TriggerClientEvent("chat:addSuggestions", source, {
        {
            command = "/" .. CoordsConfig.CommandName,
            help = "Abre o inspetor holográfico de coordenadas espaciais (Kiroshi Spatial Scanner).",
            parameters = {}
        }
    })
end)

exports("isAuthorized", isPlayerAuthorized)
