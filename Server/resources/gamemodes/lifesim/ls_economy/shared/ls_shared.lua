--[[
    LIFESIM RP - Shared Utilities (Canonical Source)
    Path: ls_economy/shared/ls_shared.lua
    This file is synchronized across all ls_* resources via scripts/sync-shared.ps1.
    DO NOT EDIT DIRECTLY INSIDE INDIVIDUAL RESOURCES.
]]

LS = LS or {}

---Valida se o valor é um ID de jogador válido (inteiro positivo >= 1)
---@param v any
---@return boolean
function LS.isPlayerId(v)
    return type(v) == "number" and v >= 1 and (v % 1 == 0)
end

---Converte de forma segura strings de eventos do host (onPlayerConnected, etc.) para ID de jogador numérico
---@param v any
---@return integer|nil
function LS.toPlayerId(v)
    local n = tonumber(v)
    return (n and LS.isPlayerId(n)) and math.floor(n) or nil
end

---Limita um valor numérico entre mínimo e máximo
---@param v number
---@param lo number
---@param hi number
---@return number
function LS.clamp(v, lo, hi)
    if v < lo then return lo elseif v > hi then return hi end
    return v
end

---Arredonda um número para N casas decimais
---@param num number
---@param decimals? integer
---@return number
function LS.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

---Helper padronizado para retornos de falha
---@param reason string
---@return nil, string
function LS.fail(reason)
    return nil, reason
end

---Gera uma máquina de estados finita com validação e log de transição ilegal
---@param edges table<string, table<string, boolean>> Tabela de transições permitidas [origem] = { [destino] = true }
---@param onChange? fun(rec: table, prev: string, target: string, detail: any) Callback opcional ao mudar de estado
---@return fun(rec: table, target: string, detail?: any): boolean
function LS.makeTransition(edges, onChange)
    return function(rec, target, detail)
        if not rec or type(rec) ~= "table" then return false end
        local current = rec.state or "none"
        local allowed = edges[current]
        if not allowed or not allowed[target] then
            if Open77 and Open77.log and Open77.log.warn then
                Open77.log.warn(("[LS.Transition] Transição ilegal detectada: %s -> %s (detalhe: %s)"):format(
                    tostring(current), tostring(target), tostring(detail or "none")
                ))
            else
                print(("[LS.Transition WARN] Transição ilegal: %s -> %s"):format(tostring(current), tostring(target)))
            end
            return false
        end

        local prev = current
        rec.state = target
        if onChange then
            onChange(rec, prev, target, detail)
        end
        return true
    end
end
