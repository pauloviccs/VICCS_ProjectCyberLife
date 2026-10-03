--[[
    LIFESIM RP - Economy Client Manager
    Path: ls_economy/client/main.lua
    Controlador do lado do cliente para visualização de saldo, carteira e sincronização reativa com a HUD.
]]

local ClientAccount = {
    cash = 0,
    bank = 0
}

local function applyEconomyData(data)
    if not data or type(data) ~= "table" then return end

    ClientAccount.cash = math.floor(tonumber(data.cash) or ClientAccount.cash)
    ClientAccount.bank = math.floor(tonumber(data.bank) or ClientAccount.bank)

    -- Repassa os saldos para a camada WebUI (HUD Kiroshi / ls_ui)
    TriggerEvent("ls:ui:updateMoney", {
        cash = ClientAccount.cash,
        bank = ClientAccount.bank
    })
end

-- =============================================================================
-- REDE & DUAL SYNC
-- =============================================================================

-- 1. Sincronização direta via NetEvent
RegisterNetEvent("ls:economy:sync", function(data)
    applyEconomyData(data)
end)

-- 2. Observador reativo do State Bag local Open77
if Open77.state and Open77.state.onChange then
    Open77.state.onChange(nil, "ls.economy.v", function(bagName, key, val)
        applyEconomyData(val)
    end)
end

-- 3. Solicitação de sincronização na inicialização do recurso no cliente
AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    TriggerServerEvent("ls:economy:requestSync")
end)

-- =============================================================================
-- COMANDOS RÁPIDOS DIEGÉTICOS DO JOGADOR
-- =============================================================================

local function showWalletBalance()
    TriggerEvent("open77:chat:addMessage", {
        color = { 252, 238, 10 },
        multiline = false,
        args = {
            "CARTEIRA DIGITAL",
            ("E$ %s (Notas em Mãos) | E$ %s (Night City Bank)"):format(
                tostring(ClientAccount.cash),
                tostring(ClientAccount.bank)
            )
        }
    })
end

RegisterCommand("carteira", showWalletBalance, false)
RegisterCommand("wallet", showWalletBalance, false)
RegisterCommand("saldo", showWalletBalance, false)

local function openAtmKiosk()
    local opened = false
    local ok, res = pcall(function()
        return exports["ls_ui"]:openAtm()
    end)
    if ok and res then
        opened = true
    else
        TriggerEvent("ls:ui:openAtm")
        opened = true
    end

    if opened then
        TriggerEvent("open77:chat:addMessage", {
            color = { 34, 216, 226 },
            multiline = false,
            args = { "NIGHT CITY BANK", "Conexão criptografada estabelecida com o Terminal ATM." }
        })
    end
end

RegisterCommand("atm", openAtmKiosk, false)
RegisterCommand("banco", openAtmKiosk, false)
RegisterCommand("bank", openAtmKiosk, false)


-- =============================================================================
-- EXPORTS CLIENTE
-- =============================================================================

exports("getAccount", function()
    return ClientAccount
end)

exports("getCash", function()
    return ClientAccount.cash
end)

exports("getBank", function()
    return ClientAccount.bank
end)

exports("openAtm", function()
    return openAtmKiosk()
end)

