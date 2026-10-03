--[[
    LIFESIM RP - Economy, Targeting & World POI Configuration
    Path: ls_economy/shared/config.lua
    Parâmetros financeiros, saldos, coordenadas de ATMs, Máquinas de Venda,
    Clínicas Ripperdoc e Mercados com suporte a Blips e Interação por Alvo (ALT/Target).
]]

EconomyConfig = {
    -- Saldos concedidos na criação da primeira conta do cidadão
    DefaultBalances = {
        Cash = 500,     -- E$ 500 em notas físicas na carteira
        Bank = 2500     -- E$ 2.500 na conta bancária do Night City Bank
    },

    -- Limites de segurança financeira
    Limits = {
        MaxCash = 1000000000, -- E$ 1 bilhão
        MaxBank = 1000000000,
        MinTransaction = 1,
        MaxTransfer = 5000000, -- E$ 5 milhões por transferência bancária
        MaxHandPayDistance = 3.5 -- Raio de proximidade em metros para /money pay
    },

    -- Taxas e operações bancárias
    Banking = {
        AtmWithdrawFee = 0.0, -- 0% de tarifa em caixas eletrônicos padrão
        TransferFee = 0.01    -- 1% de taxa de transferência interbancária
    },

    -- Tipos de moeda reconhecidos
    Currency = {
        Symbol = "E$",
        CASH = "cash",
        BANK = "bank"
    },

    -- =========================================================================
    -- CONFIGURAÇÃO DOS BLIPS NO MAPA MUNDIAL (Open77.blips)
    -- =========================================================================
    BlipSettings = {
        enabled = true,
        atm = {
            sprite = "drop_point",
            fallbackSprite = "tech",
            color = "#22D8E2", -- Ciano Neon Night City Bank
            title = "ATM - Night City Bank",
            description = "Terminal bancário automatizado para saques e depósitos."
        },
        vending = {
            sprite = "food",
            fallbackSprite = "tech",
            color = "#FCEE0A", -- Amarelo Cyberpunk All-Foods
            title = "Dispensador All-Foods",
            description = "Máquina de conveniência com alimentos e bebidas energéticas."
        },
        ripperdoc = {
            sprite = "ripperdoc",
            fallbackSprite = "tech",
            color = "#FF003C", -- Vermelho Neon Cirúrgico
            title = "Clínica Ripperdoc",
            description = "Estação médica cirúrgica para instalação e calibração de ciberimplantes."
        },
        market = {
            sprite = "vendor",
            fallbackSprite = "tech",
            color = "#00FF66", -- Verde Neon Comercial
            title = "Mercado 24/7",
            description = "Loja de conveniência com mantimentos e suprimentos gerais."
        }
    },

    -- =========================================================================
    -- PROP SELECTORS PARA RAYCAST / ALVO DO MOTOR (open77_interactions & context)
    -- =========================================================================
    TargetProps = {
        atm = { "atm*", "terminal*", "droppoint*", "device.atm*", "device.terminal*" },
        vending = { "vending*", "device.vending*", "foodvending*", "drinkvending*" },
        ripperdoc = { "ripper*", "device.surgery*", "chair.ripper*" },
        market = { "register*", "device.cashregister*", "store*" }
    },

    -- =========================================================================
    -- REDE DE CAIXAS ELETRÔNICOS (ATMs) DE NIGHT CITY
    -- =========================================================================
    AtmLocations = {
        { id = "atm_h10_lobby", name = "ATM Megabuilding H10 Atrium", x = -1355.2, y = 1275.5, z = 110.5, radius = 2.5 },
        { id = "atm_h10_hall", name = "ATM H10 Corredor Residencial", x = -1430.2, y = 1257.6, z = 23.1, radius = 2.5 },
        { id = "atm_afterlife", name = "ATM Afterlife Club Entrance", x = -1412.3, y = 1380.2, z = 115.0, radius = 2.5 },
        { id = "atm_watson_kabuki", name = "ATM Kabuki Roundabout", x = -1180.0, y = 1450.0, z = 120.0, radius = 2.5 },
        { id = "atm_corpo_plaza", name = "ATM Arasaka Corpo Plaza", x = -200.5, y = -120.3, z = 15.0, radius = 2.5 },
        { id = "atm_city_center", name = "ATM Downtown 7th Street", x = -667.1, y = -382.6, z = 9.2, radius = 2.5 },
        { id = "atm_japantown", name = "ATM Japantown Cherry Market", x = -1442.2, y = 127.4, z = 18.0, radius = 2.5 },
        { id = "atm_heywood", name = "ATM Glen Plaza", x = -800.0, y = -850.0, z = 14.5, radius = 2.5 },
        { id = "atm_pacifica", name = "ATM Pacifica Coast Promenade", x = -1716.4, y = -2421.3, z = 62.6, radius = 2.5 },
        { id = "atm_badlands", name = "ATM Sunset Motel Gas Station", x = 381.4, y = -2401.8, z = 182.0, radius = 2.5 }
    },

    -- =========================================================================
    -- DISPENSADORES E MÁQUINAS DE VENDA (VENDING MACHINES)
    -- =========================================================================
    VendingLocations = {
        { id = "vending_h10_hall", name = "Dispensador H10 Corredor", x = -1428.5, y = 1255.2, z = 23.1, radius = 2.5 },
        { id = "vending_h10_atrium", name = "Dispensador H10 Pátio Central", x = -1358.0, y = 1272.0, z = 110.5, radius = 2.5 },
        { id = "vending_kabuki", name = "Dispensador Beco de Kabuki", x = -1175.5, y = 1448.2, z = 120.0, radius = 2.5 },
        { id = "vending_afterlife", name = "Dispensador Afterlife Entrada", x = -1415.0, y = 1375.0, z = 115.0, radius = 2.5 },
        { id = "vending_city_center", name = "Dispensador Estação Central", x = -670.0, y = -385.0, z = 9.2, radius = 2.5 },
        { id = "vending_westbrook", name = "Dispensador Japantown Beco", x = -1438.0, y = 125.0, z = 18.0, radius = 2.5 },
        { id = "vending_heywood", name = "Dispensador Glen Central", x = -795.0, y = -845.0, z = 14.5, radius = 2.5 },
        { id = "vending_underpass", name = "Dispensador Lower Watson Viaduto", x = -701.5, y = 1034.0, z = 35.7, radius = 2.5 },
        { id = "vending_junction", name = "Dispensador Watson Junção", x = -645.0, y = 1019.4, z = 36.6, radius = 2.5 },
        { id = "vending_northside", name = "Dispensador Northside Promenade", x = -469.5, y = 931.0, z = 56.5, radius = 2.5 }
    },

    -- =========================================================================
    -- CLÍNICAS RIPPERDOC & CIRURGIÕES DE CIBERIMPLANTES
    -- =========================================================================
    RipperdocLocations = {
        { id = "ripper_viktor", name = "Clínica do Viktor Vector", x = -1380.0, y = 1270.0, z = 110.5, radius = 3.5 },
        { id = "ripper_kabuki", name = "Clínica Kabuki (Dr. Robert)", x = -1165.0, y = 1460.0, z = 120.0, radius = 3.5 },
        { id = "ripper_fingers", name = "Fingers M.D. Japantown", x = -1450.0, y = 135.0, z = 18.0, radius = 3.5 },
        { id = "ripper_downtown", name = "Downtown Ripperdoc Clinic", x = -655.0, y = -395.0, z = 9.2, radius = 3.5 },
        { id = "ripper_heywood", name = "Wellsprings Ripperdoc", x = -810.0, y = -860.0, z = 14.5, radius = 3.5 },
        { id = "ripper_pacifica", name = "West Wind Estate Ripper", x = -1710.0, y = -2410.0, z = 62.6, radius = 3.5 },
        { id = "ripper_badlands", name = "Clínica Nômade Aldecaldos", x = 390.0, y = -2390.0, z = 182.0, radius = 3.5 }
    },

    -- =========================================================================
    -- MERCADOS, LOJAS DE CONVENIÊNCIA & SUPRIMENTOS (24/7)
    -- =========================================================================
    MarketLocations = {
        { id = "market_h10", name = "Loja de Conveniência Megabuilding H10", x = -1350.0, y = 1280.0, z = 110.5, radius = 3.0 },
        { id = "market_kabuki", name = "Mercado Noturno de Kabuki", x = -1185.0, y = 1455.0, z = 120.0, radius = 3.0 },
        { id = "market_city_center", name = "Mercado 24/7 Downtown", x = -675.0, y = -375.0, z = 9.2, radius = 3.0 },
        { id = "market_japantown", name = "Feira Gastronômica de Japantown", x = -1445.0, y = 115.0, z = 18.0, radius = 3.0 },
        { id = "market_heywood", name = "Supermercado Glen", x = -790.0, y = -855.0, z = 14.5, radius = 3.0 },
        { id = "market_northside", name = "Northside Bodega & Suprimentos", x = -475.0, y = 935.0, z = 56.5, radius = 3.0 }
    }
}
