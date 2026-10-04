--[[
    OPEN//77 - Spatial Positioning & Coordinate Inspector (Coords Tool)
    Path: open77_coords/shared/config.lua
    Configuração de permissões e formatos de cópia de coordenadas.
]]

CoordsConfig = CoordsConfig or {}

-- Roles autorizados a utilizar o /coords
CoordsConfig.AllowedRoles = {
    ["owner"] = true,
    ["operator"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    ["support"] = true,
    ["helper"] = true
}

-- Permissões ACL do Open77 válidas
CoordsConfig.AllowedPermissions = {
    "command.coords",
    "command.admin",
    "command.adminfull",
    "*"
}

-- Nome do comando
CoordsConfig.CommandName = "coords"
