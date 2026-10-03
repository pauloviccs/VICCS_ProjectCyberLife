# OPEN//77 Life-Sim RP — Especificação Técnica & Plano da Fase 4 (Economia, Carteira & Ledger)

## 1. Visão Geral Executiva

A **Fase 4 (`ls_economy`)** implementa o motor financeiro e a circulação de Eurodólares (E$) em Night City. A arquitetura obedece estritamente às premissas do protocolo de 12 perguntas:
- **Separação de Saldos:** Dinheiro físico em notas na carteira (`cash`) e saldo digital em conta corrente (`bank`).
- **Garantia ACID Total no MariaDB:** Diferente do motor de vitais que utiliza cache *write-behind* por tolerar pequenas divergências, **o dinheiro nunca utiliza cache volátil**. Todas as mutações (`addMoney`, `removeMoney`, `transfer`, `deposit`, `withdraw`) são executadas com queries atômicas e cláusulas guarda (`WHERE cash >= ?`), eliminando vetores de duplicação monetária por deslogamento ou concorrência.
- **Trilha de Auditoria Imutável (Ledger):** Cada centavo movimentado é registrado na tabela `ls_transactions` com ação, alvo, montante, saldo resultante, carimbo de tempo e motivo.
- **Integração Visual Kiroshi (UI):** Faixa de telemetria financeira embutida diretamente no Biomonitor HUD (`ls_ui`), sincronizada em tempo real via **Dual Sync** (State Bags reativos + NetEvents diretos).

---

## 2. Esquema Relacional MariaDB (InnoDB)

```sql
-- Contas Financeiras dos Cidadãos
CREATE TABLE IF NOT EXISTS `ls_accounts` (
    `license`      CHAR(32)    NOT NULL,
    `cash`         BIGINT      NOT NULL DEFAULT 500,
    `bank`         BIGINT      NOT NULL DEFAULT 2500,
    `updated_at`   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`),
    CONSTRAINT `fk_ls_accounts_license` FOREIGN KEY (`license`) REFERENCES `ls_players`(`license`) ON DELETE CASCADE,
    CONSTRAINT `chk_cash_positive` CHECK (`cash` >= 0),
    CONSTRAINT `chk_bank_positive` CHECK (`bank` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Livro Razão Imutável de Auditoria (Ledger)
CREATE TABLE IF NOT EXISTS `ls_transactions` (
    `id`           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `license`      CHAR(32)     NOT NULL,
    `action`       VARCHAR(32)  NOT NULL, -- 'credit_cash', 'debit_cash', 'credit_bank', 'debit_bank', 'set_cash', 'set_bank', etc.
    `target`       VARCHAR(64)  NULL,     -- Identificador de origem/destino ('system', 'atm', 'player_2', 'admin_1')
    `amount`       BIGINT       NOT NULL, -- Delta da operação (+ ou -)
    `balance_after` BIGINT      NOT NULL, -- Saldo final pós-operação
    `reason`       VARCHAR(128) NOT NULL, -- Descrição textual da transação
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ls_transactions_license` (`license`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 3. Matriz de Componentes & Arquivos Implementados

| Componente | Caminho do Arquivo | Função / Responsabilidade |
|---|---|---|
| **Manifesto** | [`ls_economy/open77.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/open77.lua) | Registro declarativo, permissões `database.access`, `acl.read`, `state.write` |
| **Configuração** | [`ls_economy/shared/config.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/shared/config.lua) | Saldos iniciais (E$ 500 Cash, E$ 2.500 Bank), limites e caixas eletrônicos |
| **Utilitários** | [`ls_economy/shared/ls_shared.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/shared/ls_shared.lua) | Helpers puros compartilhados (`clamp`, `isPlayerId`, validações) |
| **Core Servidor** | [`ls_economy/server/main.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/server/main.lua) | Transações atômicas MariaDB, auditoria `ls_transactions`, saques/depósitos e `/money` |
| **Cliente** | [`ls_economy/client/main.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/client/main.lua) | Dual Sync, observador de State Bags, `/carteira` e repasse para `ls_ui` |
| **UI Markup** | [`ls_ui/web/index.html`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/index.html) | Faixa `.economy-strip` com exibição de E$ CASH e E$ BANK |
| **UI Estilos** | [`ls_ui/web/app.css`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.css) | Tokens Kiroshi: amarelo Cyberpunk `#FCEE0A` (cash), ciano `#22D8E2` (bank) |
| **UI Script** | [`ls_ui/web/app.js`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.js) | Formatação monetária com separadores de milhar e binding `economy:update` |
| **UI Bridge Lua** | [`ls_ui/client/main.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/client/main.lua) | Despacho de saldo para a WebUI em tempo real e reentradas |

---

## 4. API de Exports para Outros Módulos

Qualquer recurso do servidor pode integrar compras e cobranças com facilidade:

```lua
-- Leitura de saldos
local account = exports["ls_economy"]:getAccount(playerId) -- { cash = 500, bank = 2500 }
local cash = exports["ls_economy"]:getCash(playerId)
local bank = exports["ls_economy"]:getBank(playerId)

-- Cobrança (ex: compra de comida no ls_vitals ou implante no ls_cyberware)
local ok, err = exports["ls_economy"]:removeMoney(playerId, "cash", 45, "Compra de Burrito XXL")
if not ok then
    -- Tratar recusa: err == "insufficient_funds"
end

-- Pagamento / Recompensa (ex: salário de emprego ou contrato de Fixer)
local ok, newBal = exports["ls_economy"]:addMoney(playerId, "bank", 1200, "Salário Arasaka Corp")

-- Transferência entre jogadores
local ok, err = exports["ls_economy"]:transfer(fromPlayerId, toPlayerId, 500, "Pagamento de serviço")
```

---

## 5. Suite de Comandos Administrativos & Jogador

### Jogador:
- `/carteira` (ou `/wallet` ou `/saldo`): Exibe no chat os saldos de dinheiro físico e banco.
- `/money pay <alvo> <quantia>`: Entrega dinheiro vivo em mãos para outro jogador.

### Administrador (Permissão `operator` / `acl.read`):
- `/money bal [alvo]`: Consulta saldo de qualquer jogador conectado por ID, nome parcial ou `"all"`.
- `/money give <alvo> <cash|bank> <quantia>`: Concede Eurodólares com auditoria.
- `/money take <alvo> <cash|bank> <quantia>`: Remove Eurodólares com auditoria.
- `/money set <alvo> <cash|bank> <quantia>`: Calibra o saldo exato.
- `/money help`: Manual in-game com exemplos.
