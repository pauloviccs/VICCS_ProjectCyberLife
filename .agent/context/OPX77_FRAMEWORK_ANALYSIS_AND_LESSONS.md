# Análise Arquitetural & Lições do Framework OPX//77 (`opx_infinity` & `opx_lib`)

**Fonte Analisada:** [https://opx77-framework.github.io/opx77_doc/docs/](https://opx77-framework.github.io/opx77_doc/docs/)  
**Repositórios Oficiais:** `opx77-framework/opx_infinity`, `opx77-framework/opx_lib`, `opx77-framework/opx77_doc`  
**Autor:** Luís MOUTA (MIT License, Setembro 2026)  
**Engenheiro Responsável pela Análise:** The Universal Engineer (UEoE 1)

---

## 1. Visão Geral do OPX//77

O **OPX//77** é um framework completo de Roleplay para o **OPEN//77 (Cyberpunk 2077 / REDengine 4)**. Em setembro de 2026, ele passou por uma grande refatoração estrutural: **substituiu 21 recursos individuais (`opx77_*`) por um único recurso monolítico (`opx_infinity`)**, acompanhado de uma biblioteca utilitária no cliente (`opx_lib`).

### Por que eles unificaram tudo em um único recurso?
No OPEN//77:
1. O runtime Lua 5.4 do servidor **não possui `require`** e não pode ler arquivos de outro recurso (`LoadResourceFile` só lê arquivos do próprio recurso).
2. Em múltiplos recursos, a comunicação precisa passar por `TriggerEvent` (barramento de eventos do host) ou exports.
3. Chamar dezenas de `TriggerEvent` com payloads complexos gera overhead de serialização e poluição no canal de eventos.
4. Dentro de um único recurso (`opx_infinity`), os módulos comunicam-se através de **contratos em memória pura** (`OPX.Api.Provide` e `OPX.Api.Get`), eliminando a latência de serialização e permitindo orquestração estrita de ciclo de vida.

---

## 2. Diferenças Cruciais Entre os Dois Runtimes (Server vs Client)

Esta é uma das documentações mais valiosas do ecossistema OPEN//77, revelando peculiaridades do sandbox da REDengine:

| Recurso / Comportamento | Servidor (.NET Dedicated) | Cliente (Game Client REDengine) |
| :--- | :--- | :--- |
| `require` | **NÃO** (bloqueado por segurança) | **SIM** (usado pelo `opx_lib`) |
| `load`, `loadfile`, `dofile` | **NÃO** | **NÃO** |
| `setmetatable`, `getmetatable`| **SIM** | **NÃO** (bloqueado no cliente!) |
| **Instruction Budget** | Sem limite rígido (máx 1.024 tarefas) | **Limitado por frame/resume.** Se estourar, a corrotina morre silenciosamente! |
| Alcance do `TriggerEvent` | Todos os recursos do servidor | **Apenas o próprio recurso cliente!** |
| `GetGameTimer()` | **SIM** | **NÃO** (no cliente deve-se usar `Open77.time.monotonic()`) |
| Ordem de Carregamento | `shared_scripts` rodam **SEMPRE antes** de qualquer `server_script` ou `client_script`. |

### A Armadilha Fatal do "Instruction Budget" no Cliente
- No cliente REDengine, corrotinas Lua possuem um teto de instruções permitidas por ciclo de execução.
- Se uma corrotina rodar um loop muito pesado ou carregar muitas tabelas sem ceder (`Wait(0)`), a engine emite `Open77 script execution budget exceeded` e **mata a corrotina silenciosamente** (sem crash no jogo, sem retry, muitas vezes sem log).
- **Como o OPX contornou isso:**
  1. Cada fase do ciclo de vida cede um frame (`Wait(0)`) após inicializar cada módulo.
  2. Implementou um **Scheduler central** no cliente que executa no máximo **4 tarefas por resume**.
  3. Varreduras pesadas de raycast/interação (como o módulo de `target`) são fatiadas ao longo de múltiplos frames em vez de rodar tudo em um tick.

---

## 3. Arquitetura de Módulos e Contratos (`opx_infinity`)

Em vez de exports globais, o OPX utiliza um sistema formal de microsserviços internos:

```lua
-- modules/thing/module.lua
local M = OPX.Modules.Declare{
    id = 'thing',
    side = 'both',              -- 'server', 'client' ou 'both'
    fatal = false,              -- se falhar, o servidor trava o boot?
    requires = { 'character' }, -- dependências obrigatórias
    optional = { 'downed' },    -- dependências opcionais (apenas ordenação)
}
```

### O Ciclo de Vida em 4 Fases:
1. `M.Init()`: Constrói estado interno, lê configs, registra tabelas (`OPX.Schema.Add`) e parâmetros ajustáveis (`OPX.Tune.Declare`). **Proibido chamar outros módulos aqui.**
2. `M.Api()`: Publica seu contrato com `OPX.Api.Provide('thing', 1, { ... })`. Nenhum código roda aqui além do registro da API.
3. `M.Start()`: Roda em corrotina e pode ceder (`Wait`). Registra eventos, comandos, tarefas no scheduler e lê o banco MariaDB.
4. `M.Stop()`: Desfaz registros, desativa câmeras, libera foco e cancela timers (roda em ordem inversa).

---

## 4. Banco de Dados & Esquemas Inteligentes (`OPX.Storage` & `OPX.Schema`)

O OPX resolveu o problema de migrações e índices de forma muito elegante:

### Auto-Deploy Seguro de Tabelas
Os módulos declaram seus `CREATE TABLE IF NOT EXISTS` durante a fase `Init()`. O núcleo executa tudo em lote entre as fases `Api` e `Start`.

### `EnsureIndex` contra Erros de Índices Duplicados
Como `CREATE TABLE IF NOT EXISTS` não altera tabelas existentes, novos índices quebravam ou geravam erros. O OPX criou uma verificação via `information_schema.STATISTICS`:
```sql
SELECT 1 FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @table AND INDEX_NAME = @index
```
Se o índice não existir, executa `ALTER TABLE ... ADD KEY`. Se já existir, ignora sem estourar erro.

### `OPX.Carry` para Hot-Reloads
Usa o `Open77.state.save` e `Open77.state.load` (stash volátil de 64 KiB em memória da REDengine) para manter estados temporários (ex: relógio do clima, posições de NPCs de teste) durante um restart do recurso no desenvolvimento, sem precisar gravar no MariaDB.

---

## 5. Interface CEF WebUI & Sistema de Foco

O OPX utiliza **uma única página CEF** (`web/index.html`) dividida em duas camadas:
1. **`overlay`**: HUD metabólico, alertas Kiroshi, prompts flutuantes, tags de nomes. **Nunca toma o teclado ou o mouse.**
2. **`modal`**: Inventário, menus, formulários, painéis administrativos. Toma o foco de teclado e mouse.

### Pilha de Foco (`Focus Stack`)
Para evitar conflito quando múltiplos menus ou telas abrem simultaneamente, existe um gerenciador de foco em pilha (`AcquireFocus(owner)` e `ReleaseFocus(owner)`). Quando o inventário fecha, o foco volta suavemente para o menu anterior, em vez de roubar os controles do jogador.

### Regra do Botão ESC
A tecla `Escape` pertence exclusivamente ao recurso `open77_pause` nativo da plataforma. O framework nunca associa ação direta ao ESC para não quebrar a abertura do menu de configurações do jogo.

---

## 6. Inventário e Containers de Itens

A modelagem de inventário do OPX é extremamente robusta:
- Um container é representado por um par `(kind, owner)`.
- **ID Positivo:** Registro persistente no MariaDB (bolsa do jogador, baús fixos, porta-malas de veículos próprios).
- **ID Negativo:** Container puramente em memória RAM (drops no chão, porta-malas de veículos não comprados). Desaparece sem tocar no disco.
- **Eddies Físicos vs Banco:** O dinheiro pode existir como saldo bancário ou como notas físicas no inventário (item `eddies`, peso 0, sem drop no chão para evitar exploits).

---

## 7. O Que Podemos Adotar no VICCS Cyberpunk Server?

1. **Blindagem do Client contra o "Instruction Budget":**
   Garantir que todos os loops de cliente (ex: verificação de zona de moradia em `ls_housing`, HUD updates em `ls_ui`, raycasting de alvos) usem `Wait(0)` estruturado e nunca processem centenas de iterações em um único tick.
2. **Separação de Camadas CEF (Overlay vs Modal):**
   Manter o HUD `ls_ui` sempre na camada `overlay` sem nunca capturar ponteiro/teclado, e criar um helper de foco simples quando abrirmos menus de lojas ou garagens.
3. **`EnsureIndex` no `ls_data`:**
   Implementar a verificação de índices no MariaDB via `information_schema.STATISTICS` para garantir que novas colunas/índices adicionados durante o desenvolvimento não falhem em bancos já existentes.
4. **Respeito às Limitações do Cliente:**
   Nunca tentar usar `setmetatable` ou `GetGameTimer()` no cliente Lua (usar `Open77.time.monotonic()` ou timestamp repassado pelo servidor).
