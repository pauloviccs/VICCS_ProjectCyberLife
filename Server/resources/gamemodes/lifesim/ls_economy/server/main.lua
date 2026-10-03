--[[
    LIFESIM RP - Economy Server Manager & Financial Core
    Path: ls_economy/server/main.lua
    Controlador de Eurodólares (E$), contas bancárias, carteira física (cash),
    transações atômicas no MariaDB (ACID), trilha de auditoria (ledger) e suite administrativa.
]]

local Module = {
    name = "ls_economy",
    version = "0.1.0",
    ready = false
}

local Economy = {
    players = {},   -- [playerId] = { license = string, cash = integer, bank = integer }
    byLicense = {}  -- [license] = playerId
}

-- =============================================================================
-- INICIALIZAÇÃO & MIGRAÇÕES DE DADOS (MARIADB INNODB)
-- =============================================================================

CreateThread(function()
    -- 1. Aguardar prontidão da camada de dados
    local waitCall = Open77.exports.call("ls_data", "waitReady")
    if waitCall then waitCall:await() end

    -- 2. Registrar migrações declarativas para contas e livro razão (ledger)
    local migrations = {
        {
            version = 1,
            name = "create_ls_accounts_and_transactions",
            sql = [[
                CREATE TABLE IF NOT EXISTS ls_accounts (
                    license      CHAR(32)    NOT NULL,
                    cash         BIGINT      NOT NULL DEFAULT 500,
                    bank         BIGINT      NOT NULL DEFAULT 2500,
                    updated_at   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (license),
                    CONSTRAINT fk_ls_accounts_license FOREIGN KEY (license) REFERENCES ls_players(license) ON DELETE CASCADE,
                    CONSTRAINT chk_cash_positive CHECK (cash >= 0),
                    CONSTRAINT chk_bank_positive CHECK (bank >= 0)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS ls_transactions (
                    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                    license      CHAR(32)     NOT NULL,
                    action       VARCHAR(32)  NOT NULL,
                    target       VARCHAR(64)  NULL,
                    amount       BIGINT       NOT NULL,
                    balance_after BIGINT      NOT NULL,
                    reason       VARCHAR(128) NOT NULL,
                    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_ls_transactions_license (license, created_at)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
        }
    }
    local migCall = Open77.exports.call("ls_data", "registerMigrations", "ls_economy", migrations)
    if migCall then migCall:await() end

    -- 3. Registrar módulo no ls_core
    local regCall = Open77.exports.call("ls_core", "registerModule", {
        version = Module.version,
        requires = { "ls_data", "ls_core" },
        provides = {
            "getAccount", "getCash", "getBank",
            "addMoney", "removeMoney", "setMoney",
            "deposit", "withdraw", "transfer"
        },
        emits = { "ls:economy:updated", "ls:economy:transaction" },
        listens = { "ls:core:playerLoaded", "ls:core:playerUnloading" },
        stateKeys = {
            ["ls.economy.v"] = { maxBytes = 256 }
        },
        tables = { "ls_accounts", "ls_transactions" }
    })
    if regCall then regCall:await() end

    Module.ready = true
    Open77.log.info(("[ls_economy] Motor financeiro e livro razão MariaDB inicializados (v%s)."):format(Module.version))
end)

-- =============================================================================
-- RESOLUÇÃO DE IDENTIDADE & SINCRONIZAÇÃO
-- =============================================================================

---Resolve a licença única do jogador no Core
---@param playerId integer
---@return string|nil
local function resolveLicense(playerId)
    if not LS.isPlayerId(playerId) then return nil end
    local p = Economy.players[playerId]
    if p and p.license then return p.license end

    local license
    local licCall = Open77.exports.call("ls_core", "getPlayerLicense", playerId)
    if licCall then
        license = licCall:await()
    end

    if not license or license == "" then
        local ids = Open77.players and Open77.players.identifiers and Open77.players.identifiers(playerId) or {}
        local rawLicense = ids.license or ids.userId or ids.open77 or ids.fingerprint or ("player_" .. tostring(playerId))
        license = tostring(rawLicense):gsub("[^%w]", ""):lower()
        if #license < 32 then
            license = (license .. string.rep("0", 32)):sub(1, 32)
        else
            license = license:sub(1, 32)
        end
    end

    return license
end

---Dispara atualização de saldo para o State Bag e NetEvent do jogador
---@param playerId integer
---@param account table
local function syncPlayerBalance(playerId, account)
    if not LS.isPlayerId(playerId) or not account then return end

    local payload = {
        cash = math.floor(account.cash or 0),
        bank = math.floor(account.bank or 0)
    }

    -- 1. State Bag autoritativo para bindings de alta performance
    if Open77.state and Open77.state.player then
        Open77.state.player(playerId):set("ls.economy.v", payload)
    end

    -- 2. NetEvent direto (Dual Sync garantido)
    TriggerClientEvent("ls:economy:sync", playerId, payload)
    TriggerEvent("ls:economy:updated", playerId, payload)
end

---Carrega a conta financeira do jogador ou cria uma nova com saldos de fábrica
---@param playerId integer
---@param license string
local function loadPlayerAccount(playerId, license)
    if not LS.isPlayerId(playerId) or not license then return end

    CreateThread(function()
        -- Query resiliente no MariaDB via ls_data ou MySQL.query.await
        local rows = nil
        local ok, res = pcall(function()
            if exports["ls_data"] and exports["ls_data"].query then
                return exports["ls_data"]:query("SELECT cash, bank FROM ls_accounts WHERE license = ? LIMIT 1", { license })
            elseif MySQL and MySQL.query and MySQL.query.await then
                return MySQL.query.await("SELECT cash, bank FROM ls_accounts WHERE license = ? LIMIT 1", { license })
            elseif Open77 and Open77.database and Open77.database.query then
                return Open77.database.query("SELECT cash, bank FROM ls_accounts WHERE license = ? LIMIT 1", { license })
            end
            return nil
        end)
        if ok and type(res) == "table" then
            rows = res
        end

        local account

        if type(rows) == "table" and #rows > 0 then
            account = {
                license = license,
                cash = tonumber(rows[1].cash) or EconomyConfig.DefaultBalances.Cash,
                bank = tonumber(rows[1].bank) or EconomyConfig.DefaultBalances.Bank
            }
        else
            -- Novo cidadão de Night City: concede saldos iniciais de fábrica
            account = {
                license = license,
                cash = EconomyConfig.DefaultBalances.Cash,
                bank = EconomyConfig.DefaultBalances.Bank
            }
            pcall(function()
                if exports["ls_data"] and exports["ls_data"].execute then
                    exports["ls_data"]:execute(
                        "INSERT INTO ls_accounts (license, cash, bank) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE cash = VALUES(cash), bank = VALUES(bank)",
                        { license, account.cash, account.bank }
                    )
                    exports["ls_data"]:execute(
                        "INSERT INTO ls_transactions (license, action, target, amount, balance_after, reason) VALUES (?, 'starter_grant', 'system', ?, ?, 'Night City Starting Funds')",
                        { license, account.cash + account.bank, account.bank }
                    )
                elseif Open77 and Open77.database and Open77.database.execute then
                    Open77.database.execute(
                        "INSERT INTO ls_accounts (license, cash, bank) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE cash = VALUES(cash), bank = VALUES(bank)",
                        { license, account.cash, account.bank }
                    )
                    Open77.database.execute(
                        "INSERT INTO ls_transactions (license, action, target, amount, balance_after, reason) VALUES (?, 'starter_grant', 'system', ?, ?, 'Night City Starting Funds')",
                        { license, account.cash + account.bank, account.bank }
                    )
                end
            end)
            Open77.log.info(("[ls_economy] Nova conta bancária criada para [%d] (%s): E$ %d Cash, E$ %d Bank"):format(
                playerId, license, account.cash, account.bank
            ))
        end

        Economy.players[playerId] = account
        Economy.byLicense[license] = playerId

        syncPlayerBalance(playerId, account)
        Open77.log.info(("[ls_economy] Saldo carregado para jogador [%d]: E$ %d Cash, E$ %d Bank"):format(
            playerId, account.cash, account.bank
        ))
    end)
end

---Descarrega o jogador e remove seu registro volátil
---@param playerId integer
local function unloadPlayerAccount(playerId)
    local p = Economy.players[playerId]
    if not p then return end

    -- Como todas as mutações gravam no banco na hora (ACID), apenas limpamos a memória
    if p.license then
        Economy.byLicense[p.license] = nil
    end
    Economy.players[playerId] = nil
    Open77.log.info(("[ls_economy] Sessão financeira descarregada para jogador [%d]"):format(playerId))
end

AddEventHandler("ls:core:playerLoaded", function(playerId, license)
    loadPlayerAccount(playerId, license)
end)

AddEventHandler("ls:core:playerUnloading", function(playerId, license)
    unloadPlayerAccount(playerId)
end)

AddEventHandler("playerDropped", function(reason)
    unloadPlayerAccount(source)
end)

-- =============================================================================
-- MOTOR DE TRANSAÇÕES ATÔMICAS (ACID)
-- =============================================================================

---Adiciona Eurodólares na carteira (cash) ou no banco (bank)
---@param playerId integer
---@param currencyType string "cash"|"bank"
---@param amount integer
---@param reason? string
---@param targetRef? string
---@return boolean, integer|string
local function addMoney(playerId, currencyType, amount, reason, targetRef)
    if not LS.isPlayerId(playerId) then return false, "invalid_player" end
    currencyType = tostring(currencyType):lower()
    if currencyType ~= "cash" and currencyType ~= "bank" then return false, "invalid_currency_type" end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false, "invalid_amount" end

    local p = Economy.players[playerId]
    if not p then
        local lic = resolveLicense(playerId)
        if lic then loadPlayerAccount(playerId, lic) end
        p = Economy.players[playerId]
        if not p then return false, "player_not_loaded" end
    end

    local maxLimit = currencyType == "cash" and EconomyConfig.Limits.MaxCash or EconomyConfig.Limits.MaxBank
    if p[currencyType] + amount > maxLimit then
        return false, "exceeds_max_limit"
    end

    reason = tostring(reason or "credit_deposit")
    local license = p.license

    -- Operação Atômica no Banco de Dados
    local sql = ("UPDATE ls_accounts SET %s = %s + ? WHERE license = ?"):format(currencyType, currencyType)
    local ok = Open77.database.execute(sql, { amount, license })
    if not ok then return false, "database_error" end

    p[currencyType] = p[currencyType] + amount
    local newBalance = p[currencyType]

    -- Registra transação no livro razão imutável (Audit Trail)
    Open77.database.execute(
        "INSERT INTO ls_transactions (license, action, target, amount, balance_after, reason) VALUES (?, ?, ?, ?, ?, ?)",
        { license, "credit_" .. currencyType, tostring(targetRef or "system"), amount, newBalance, reason }
    )

    syncPlayerBalance(playerId, p)
    Open77.log.info(("[ls_economy] +E$ %d (%s) creditados para [%d] (%s). Novo saldo: %d. Motivo: %s"):format(
        amount, currencyType, playerId, license, newBalance, reason
    ))

    return true, newBalance
end

---Remove Eurodólares com verificação estrita de saldo e prevenção de race conditions
---@param playerId integer
---@param currencyType string "cash"|"bank"
---@param amount integer
---@param reason? string
---@param targetRef? string
---@return boolean, integer|string
local function removeMoney(playerId, currencyType, amount, reason, targetRef)
    if not LS.isPlayerId(playerId) then return false, "invalid_player" end
    currencyType = tostring(currencyType):lower()
    if currencyType ~= "cash" and currencyType ~= "bank" then return false, "invalid_currency_type" end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false, "invalid_amount" end

    local p = Economy.players[playerId]
    if not p then
        local lic = resolveLicense(playerId)
        if lic then loadPlayerAccount(playerId, lic) end
        p = Economy.players[playerId]
        if not p then return false, "player_not_loaded" end
    end

    if p[currencyType] < amount then
        return false, "insufficient_funds"
    end

    reason = tostring(reason or "debit_charge")
    local license = p.license

    -- Operação Atômica com Cláusula Guarda no Banco (impede saldo negativo sob concorrência)
    local sql = ("UPDATE ls_accounts SET %s = %s - ? WHERE license = ? AND %s >= ?"):format(
        currencyType, currencyType, currencyType
    )
    local ok = Open77.database.execute(sql, { amount, license, amount })
    if not ok then return false, "database_concurrency_fail" end

    p[currencyType] = p[currencyType] - amount
    local newBalance = p[currencyType]

    -- Auditoria imutável no ledger
    Open77.database.execute(
        "INSERT INTO ls_transactions (license, action, target, amount, balance_after, reason) VALUES (?, ?, ?, ?, ?, ?)",
        { license, "debit_" .. currencyType, tostring(targetRef or "system"), -amount, newBalance, reason }
    )

    syncPlayerBalance(playerId, p)
    Open77.log.info(("[ls_economy] -E$ %d (%s) debitados de [%d] (%s). Novo saldo: %d. Motivo: %s"):format(
        amount, currencyType, playerId, license, newBalance, reason
    ))

    return true, newBalance
end

---Define o saldo exato (utilitário administrativo com auditoria)
---@param playerId integer
---@param currencyType string "cash"|"bank"
---@param amount integer
---@param reason? string
---@return boolean, integer|string
local function setMoney(playerId, currencyType, amount, reason)
    if not LS.isPlayerId(playerId) then return false, "invalid_player" end
    currencyType = tostring(currencyType):lower()
    if currencyType ~= "cash" and currencyType ~= "bank" then return false, "invalid_currency_type" end

    amount = math.max(0, math.floor(tonumber(amount) or 0))
    local p = Economy.players[playerId]
    if not p then return false, "player_not_loaded" end

    local license = p.license
    local sql = ("UPDATE ls_accounts SET %s = ? WHERE license = ?"):format(currencyType)
    local ok = Open77.database.execute(sql, { amount, license })
    if not ok then return false, "database_error" end

    local delta = amount - p[currencyType]
    p[currencyType] = amount

    Open77.database.execute(
        "INSERT INTO ls_transactions (license, action, target, amount, balance_after, reason) VALUES (?, ?, 'admin', ?, ?, ?)",
        { license, "set_" .. currencyType, delta, amount, tostring(reason or "admin_override") }
    )

    syncPlayerBalance(playerId, p)
    return true, amount
end

---Operação de Depósito no ATM (transfere Cash para Bank)
---@param playerId integer
---@param amount integer
---@return boolean, string
local function deposit(playerId, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false, "invalid_amount" end

    local ok, err = removeMoney(playerId, "cash", amount, "atm_deposit", "atm")
    if not ok then return false, err end

    addMoney(playerId, "bank", amount, "atm_deposit", "atm")
    return true, "success"
end

---Operação de Saque no ATM (transfere Bank para Cash)
---@param playerId integer
---@param amount integer
---@return boolean, string
local function withdraw(playerId, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false, "invalid_amount" end

    local ok, err = removeMoney(playerId, "bank", amount, "atm_withdraw", "atm")
    if not ok then return false, err end

    addMoney(playerId, "cash", amount, "atm_withdraw", "atm")
    return true, "success"
end

---Transferência bancária entre dois cidadãos conectados
---@param fromPlayerId integer
---@param toPlayerId integer
---@param amount integer
---@param reason? string
---@return boolean, string
local function transfer(fromPlayerId, toPlayerId, amount, reason)
    if not LS.isPlayerId(fromPlayerId) or not LS.isPlayerId(toPlayerId) then
        return false, "invalid_players"
    end
    if fromPlayerId == toPlayerId then
        return false, "cannot_transfer_to_self"
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > EconomyConfig.Limits.MaxTransfer then
        return false, "invalid_amount"
    end

    local fromAcc = Economy.players[fromPlayerId]
    local toAcc = Economy.players[toPlayerId]
    if not fromAcc or not toAcc then
        return false, "players_not_loaded"
    end

    reason = tostring(reason or "wire_transfer")

    -- Débito do remetente
    local debitOk, debitErr = removeMoney(fromPlayerId, "bank", amount, reason, "player_" .. tostring(toPlayerId))
    if not debitOk then return false, debitErr end

    -- Crédito do destinatário
    addMoney(toPlayerId, "bank", amount, reason, "player_" .. tostring(fromPlayerId))

    -- Notificação em chat para ambos
    TriggerClientEvent("open77:chat:addMessage", fromPlayerId, {
        color = { 252, 238, 10 },
        multiline = false,
        args = { "NIGHT CITY BANK", ("Transferência de E$ %s enviada com sucesso para o cidadão [%d]."):format(
            tostring(amount), toPlayerId
        ) }
    })
    TriggerClientEvent("open77:chat:addMessage", toPlayerId, {
        color = { 34, 216, 226 },
        multiline = false,
        args = { "NIGHT CITY BANK", ("Você recebeu uma transferência de E$ %s do cidadão [%d]."):format(
            tostring(amount), fromPlayerId
        ) }
    })

    return true, "success"
end

-- =============================================================================
-- REDE & EVENTOS CLIENTE
-- =============================================================================

RegisterNetEvent("ls:economy:requestSync", function()
    local src = source
    if not LS.isPlayerId(src) then return end

    local p = Economy.players[src]
    if p then
        syncPlayerBalance(src, p)
    else
        local lic = resolveLicense(src)
        if lic then loadPlayerAccount(src, lic) end
    end
end)

RegisterNetEvent("ls:economy:atmDeposit", function(amount)
    local src = source
    if not LS.isPlayerId(src) then return end

    local ok, err = deposit(src, amount)
    if not ok then
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "ATM REJEITADO", "Saldo em dinheiro insuficiente para depósito." }
        })
    else
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "ATM COMPLETO", ("Depósito de E$ %s creditado em sua conta bancária."):format(tostring(amount)) }
        })
    end
end)

RegisterNetEvent("ls:economy:atmWithdraw", function(amount)
    local src = source
    if not LS.isPlayerId(src) then return end

    local ok, err = withdraw(src, amount)
    if not ok then
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "ATM REJEITADO", "Saldo bancário insuficiente para saque." }
        })
    else
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "ATM COMPLETO", ("Saque de E$ %s em dinheiro vivo retirado da sua conta."):format(tostring(amount)) }
        })
    end
end)

-- Processamento unificado de ações do Terminal Kiosk WebUI
RegisterNetEvent("ls:economy:atmAction", function(data)
    local src = source
    if not LS.isPlayerId(src) or type(data) ~= "table" then return end

    local action = tostring(data.action or ""):lower()
    local amount = math.floor(tonumber(data.amount) or 0)
    if amount <= 0 then
        TriggerClientEvent("ls:ui:atmFeedback", src, { success = false, message = "Valor inválido para operação bancária." })
        return
    end

    if action == "withdraw" then
        local ok, err = withdraw(src, amount)
        if ok then
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = true,
                message = ("Saque de E$ %s efetuado! Retirado do banco para a carteira."):format(tostring(amount))
            })
        else
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = false,
                message = "Saldo bancário insuficiente para realizar este saque."
            })
        end
    elseif action == "deposit" then
        local ok, err = deposit(src, amount)
        if ok then
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = true,
                message = ("Depósito de E$ %s creditado com sucesso em sua conta bancária."):format(tostring(amount))
            })
        else
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = false,
                message = "Você não possui essa quantia de dinheiro vivo em mãos."
            })
        end
    elseif action == "transfer" then
        local target = tonumber(data.target)
        if not target or not LS.isPlayerId(target) or target == src then
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = false,
                message = "ID do cidadão destinatário inválido ou inacessível."
            })
            return
        end
        local ok, err = transfer(src, target, amount, "atm_wire_transfer")
        if ok then
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = true,
                message = ("Transferência de E$ %s enviada com sucesso para o cidadão [%d]!"):format(tostring(amount), target)
            })
        else
            local reasonText = (err == "insufficient_funds") and "Saldo bancário insuficiente para esta transferência."
                or (err == "players_not_loaded") and "Cidadão destinatário não conectado ao banco."
                or "Falha ao processar transferência na rede Night City."
            TriggerClientEvent("ls:ui:atmFeedback", src, {
                success = false,
                message = reasonText
            })
        end
    end
end)


-- =============================================================================
-- RESOLUÇÃO INTELIGENTE DE ALVOS & PAGAMENTO DIRETO EM MÃOS (STREET CASH)
-- =============================================================================

---Resolve alvos com suporte a "me", números, aspas, nomes parciais e "all"
---@param callerSource integer
---@param targetArg string|nil
---@return table lista de IDs de jogadores resolvidos
local function resolveMoneyTarget(callerSource, targetArg)
    if not targetArg or targetArg == "" or targetArg == "me" then
        if callerSource and callerSource > 0 then
            return { callerSource }
        end
        return {}
    end

    local clean = tostring(targetArg):gsub('^["\']', ''):gsub('["\']$', ''):lower():match("^%s*(.-)%s*$")

    if clean == "all" or clean == "todos" then
        local all = {}
        for playerId, _ in pairs(Economy.players) do
            table.insert(all, playerId)
        end
        return all
    end

    local numId = tonumber(clean)
    if numId and LS.isPlayerId(numId) then
        return { numId }
    end

    local matches = {}
    for playerId, acc in pairs(Economy.players) do
        local pName = tostring(Open77.players.name and Open77.players.name(playerId) or ""):lower()
        if pName:find(clean, 1, true) or acc.license:find(clean, 1, true) then
            table.insert(matches, playerId)
        end
    end

    return matches
end

---Executa a troca imediata de dinheiro físico em mãos entre dois cidadãos
---@param src integer ID do pagador
---@param targetId integer ID do recebedor
---@param amount integer Quantia em Eurodólares
---@return boolean, string
local function executePayHand(src, targetId, amount)
    if not LS.isPlayerId(src) or not LS.isPlayerId(targetId) or src == targetId then
        return false, "invalid_target"
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        return false, "invalid_amount"
    end

    local ok, err = removeMoney(src, "cash", amount, "hand_payment", "player_" .. tostring(targetId))
    if not ok then
        TriggerClientEvent("open77:chat:addMessage", src, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "CARTEIRA", "Você não possui dinheiro vivo suficiente na carteira." }
        })
        return false, "insufficient_funds"
    end

    addMoney(targetId, "cash", amount, "hand_payment", "player_" .. tostring(src))

    TriggerClientEvent("open77:chat:addMessage", src, {
        color = { 252, 238, 10 },
        multiline = false,
        args = { "CARTEIRA", ("Você entregou E$ %s em mãos para o cidadão [%d]."):format(tostring(amount), targetId) }
    })
    TriggerClientEvent("open77:chat:addMessage", targetId, {
        color = { 34, 216, 226 },
        multiline = false,
        args = { "CARTEIRA", ("O cidadão [%d] lhe entregou E$ %s em notas físicas."):format(src, tostring(amount)) }
    })
    return true, "success"
end

-- NetEvent para chamadas de scripts de interação física / proximidade
RegisterNetEvent("ls:economy:payHand", function(targetId, amount)
    executePayHand(source, targetId, amount)
end)

-- Comando diegético rápido de rua: /pagar <alvo> <quantia>
RegisterCommand("pagar", function(source, args, raw)
    if source == 0 then
        print("[ls_economy] O console não pode entregar dinheiro físico em mãos.")
        return
    end

    local targetArg = args[1]
    local amountArg = args[2]

    if not targetArg or not amountArg then
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "CARTEIRA", "Uso ágil: /pagar <id_jogador> <quantia em E$>" }
        })
        return
    end

    local targets = resolveMoneyTarget(source, targetArg)
    if #targets ~= 1 then
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "CARTEIRA", "Destinatário não localizado na proximidade ou identificador ambíguo." }
        })
        return
    end

    local amt = tonumber(amountArg)
    if not amt or amt <= 0 then
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 255, 60, 60 },
            multiline = false,
            args = { "CARTEIRA", "Valor de Eurodólares inválido para pagamento em dinheiro vivo." }
        })
        return
    end

    executePayHand(source, targets[1], amt)
end, false)

-- Alias em inglês /pay
RegisterCommand("pay", function(source, args, raw)
    local targetArg = args[1]
    local amountArg = args[2]
    if source == 0 then
        print("[ls_economy] Use /money give para comandos via console.")
        return
    end
    if not targetArg or not amountArg then
        TriggerClientEvent("open77:chat:addMessage", source, {
            color = { 252, 238, 10 },
            multiline = false,
            args = { "CARTEIRA", "Uso ágil: /pay <id_jogador> <quantia em E$>" }
        })
        return
    end
    local targets = resolveMoneyTarget(source, targetArg)
    if #targets == 1 then
        executePayHand(source, targets[1], tonumber(amountArg))
    end
end, false)

-- =============================================================================
-- SUITE ADMINISTRATIVA (/money)
-- =============================================================================

---Valida permissão administrativa via ACL
---@param source integer
---@return boolean
local function isMoneyAdmin(source)
    if source == 0 then return true end
    if Open77.acl and Open77.acl.hasPermission then
        return Open77.acl.hasPermission(source, "command.money")
            or Open77.acl.hasPermission(source, "command.admin")
            or Open77.acl.hasPermission(source, "role.operator")
            or Open77.acl.hasPermission(source, "*")
    end
    return false
end

RegisterCommand("money", function(source, args, raw)
    local sub = tostring(args[1] or ""):lower()

    if sub == "help" or sub == "?" or sub == "" then
        local help = {
            "--- // NIGHT CITY FINANCIAL COMMANDS // ---",
            "/money bal [alvo] - Consulta saldo (Cash & Bank)",
            "/money pay <alvo> <quantia> - Transfere dinheiro vivo em mãos",
            "/money give <alvo> <cash|bank> <quantia> - (Admin) Concede Eurodólares",
            "/money take <alvo> <cash|bank> <quantia> - (Admin) Remove Eurodólares",
            "/money set <alvo> <cash|bank> <quantia> - (Admin) Calibra saldo exato"
        }
        for _, line in ipairs(help) do
            if source == 0 then print(line) else
                TriggerClientEvent("open77:chat:addMessage", source, { color = { 252, 238, 10 }, multiline = false, args = { "FINANCEIRO", line } })
            end
        end
        return
    end

    -- Consulta de saldo: /money bal [alvo]
    if sub == "bal" or sub == "balance" or sub == "saldo" then
        local targets = resolveMoneyTarget(source, args[2])
        if #targets == 0 then
            local msg = "Nenhum cidadão localizado com o identificador informado."
            if source == 0 then print(msg) else TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 60, 60 }, multiline = false, args = { "FINANCEIRO", msg } }) end
            return
        end

        for _, tId in ipairs(targets) do
            local acc = Economy.players[tId]
            local pName = Open77.players.name and Open77.players.name(tId) or ("Cidadão " .. tostring(tId))
            local msg = acc and ("[%d] %s: E$ %d (Carteira) | E$ %d (Banco)"):format(tId, pName, acc.cash, acc.bank) or ("[%d] Conta não carregada."):format(tId)
            if source == 0 then print(msg) else
                TriggerClientEvent("open77:chat:addMessage", source, { color = { 34, 216, 226 }, multiline = false, args = { "NIGHT CITY BANK", msg } })
            end
        end
        return
    end

    -- Pagamento direto em mãos: /money pay <alvo> <quantia>
    if sub == "pay" or sub == "pagar" then
        if source == 0 then
            print("[ls_economy] O console não pode entregar dinheiro físico em mãos.")
            return
        end
        local targets = resolveMoneyTarget(source, args[2])
        if #targets ~= 1 then
            TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 60, 60 }, multiline = false, args = { "FINANCEIRO", "Especifique um único destinatário válido para o pagamento." } })
            return
        end
        local amt = tonumber(args[3])
        if not amt or amt <= 0 then
            TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 60, 60 }, multiline = false, args = { "FINANCEIRO", "Uso: /money pay <alvo> <quantia>" } })
            return
        end

        executePayHand(source, targets[1], amt)
        return
    end

    -- Comandos Administrativos (give, take, set)
    if not isMoneyAdmin(source) then
        local msg = "Acesso negado: você não tem privilégios corporativos de tesouraria."
        if source == 0 then print(msg) else TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 50, 50 }, multiline = false, args = { "SEGURANÇA", msg } }) end
        return
    end

    if sub == "give" or sub == "take" or sub == "set" then
        local targets = resolveMoneyTarget(source, args[2])
        local curType = tostring(args[3] or "cash"):lower()
        local amt = tonumber(args[4])

        if #targets == 0 then
            local msg = "Nenhum alvo localizado para a operação monetária."
            if source == 0 then print(msg) else TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 60, 60 }, multiline = false, args = { "FINANCEIRO", msg } }) end
            return
        end

        if not amt or amt < 0 then
            local msg = ("Uso: /money %s <alvo> <cash|bank> <quantia>"):format(sub)
            if source == 0 then print(msg) else TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 60, 60 }, multiline = false, args = { "FINANCEIRO", msg } }) end
            return
        end

        for _, tId in ipairs(targets) do
            if sub == "give" then
                addMoney(tId, curType, amt, "admin_grant", "admin_" .. tostring(source))
            elseif sub == "take" then
                removeMoney(tId, curType, amt, "admin_confiscation", "admin_" .. tostring(source))
            elseif sub == "set" then
                setMoney(tId, curType, amt, "admin_set")
            end
        end

        local doneMsg = ("Operação /money %s executada com sucesso em %d cidadão(s)!"):format(sub, #targets)
        if source == 0 then print(doneMsg) else TriggerClientEvent("open77:chat:addMessage", source, { color = { 34, 216, 226 }, multiline = false, args = { "ADMIN FINANÇAS", doneMsg } }) end
        return
    end

    local unknownMsg = "Subcomando não reconhecido. Digite /money help."
    if source == 0 then print(unknownMsg) else TriggerClientEvent("open77:chat:addMessage", source, { color = { 255, 60, 60 }, multiline = false, args = { "FINANCEIRO", unknownMsg } }) end
end, false)

AddEventHandler("ls:economy:payHandDirect", function(src, target, amt)
    executePayHand(src, target, amt)
end)

-- =============================================================================
-- EXPORTS SERVIDOR
-- =============================================================================

exports("getAccount", function(playerId)
    return Economy.players[playerId]
end)

exports("getCash", function(playerId)
    local p = Economy.players[playerId]
    return p and p.cash or 0
end)

exports("getBank", function(playerId)
    local p = Economy.players[playerId]
    return p and p.bank or 0
end)

exports("addMoney", function(playerId, currencyType, amount, reason, targetRef)
    return addMoney(playerId, currencyType, amount, reason, targetRef)
end)

exports("removeMoney", function(playerId, currencyType, amount, reason, targetRef)
    return removeMoney(playerId, currencyType, amount, reason, targetRef)
end)

exports("setMoney", function(playerId, currencyType, amount, reason)
    return setMoney(playerId, currencyType, amount, reason)
end)

exports("deposit", function(playerId, amount)
    return deposit(playerId, amount)
end)

exports("withdraw", function(playerId, amount)
    return withdraw(playerId, amount)
end)

exports("transfer", function(fromPlayerId, toPlayerId, amount, reason)
    return transfer(fromPlayerId, toPlayerId, amount, reason)
end)
