# DOCUMENTAÇÃO OFICIAL & GUIA TÉCNICO CANÔNICO: OPEN//77 (Cyberpunk 2077 Multiplayer)

> **Versão Alvo:** Cyberpunk 2077 v2.31 + Phantom Liberty DLC  
> **Open77 Build Oficial:** 2.31.21+op77.124 (Protocolo 1.44)  
> **Runtime Host:** .NET 8 Dedicated Server (Linux x64 / Windows x64)  
> **Linguagem de Scripting:** Lua 5.4 isolado por recurso (Client & Server VMs)  
> **Fonte Oficial Canônica:** [open2077.net](https://open2077.net/) | [open2077.net/docs](https://open2077.net/docs) | [open2077.net/docs.md](https://open2077.net/docs.md)

---

## 1. Visão Geral da Plataforma & Princípios Canônicos

O **OPEN//77** é a plataforma multiplayer dedicada e autoritativa para o *Cyberpunk 2077* (REDengine 4). O servidor dedicado gerencia o estado da simulação, roteia instâncias virtuais por Routing Buckets, conecta-se a bancos relacionais MariaDB/MySQL via bridge nativa e distribui os recursos assinados aos clientes conectados.

### Princípios Inegociáveis

1. **Server-Authoritative Estrito:**
   O cliente nunca decide inventário, dinheiro, vida, dano canônico, tempo de jogo, clima, autoridade de veículos ou roteamento dimensional. O cliente apenas renderiza a projeção autorizada e submete intenções com parâmetros validados ao servidor.
2. **Identificadores REDengine são Valores Opacos:**
   Identificadores da REDengine (entidades, transações, hashes TweakDB) são inteiros de 64 bits. Devem ser tratados como valores opacos: **nunca passe por `tonumber()`**, pois a perda de precisão float corrompe o ponteiro/ID. Devem ser transmitidos, comparados e armazenados intactos como strings ou inteiros 64-bit nativos.
3. **Falhas como Valores (Sem `pcall` Excessivo):**
   A convenção universal de retornos da API OPEN//77 é:
   - Funções que retornam valores: `value` em sucesso, ou `nil, reason` (string estável em `snake_case`) em falha.
   - Predicados/Ações booleanas: `true` em sucesso, ou `false, reason` em recusa.
4. **Permissões Explícitas no Manifesto:**
   APIs protegidas e com impacto no sistema exigem declaração prévia na tabela `permissions { ... }` do manifesto `open77.lua`. Chamadas sem permissão falham imediatamente com `permission_denied:<permissão>`.
5. **Isolamento Absoluto de Runtimes (Client vs Server):**
   - O código em `server_script` **nunca** é enviado aos clientes.
   - O pacote baixado pelo jogador contém apenas `open77.lua`, `client_script`, `shared_script` e os arquivos declarados em `files` ou `web_files`.
   - Segredos, regras de integridade e transações financeiras pertencem exclusivamente ao servidor.

---

## 2. Estrutura de Diretórios de Recursos (Resources)

A árvore de recursos do servidor organiza-se hierarquicamente sob `resources/`:

```text
resources/
├── system/             # Recursos oficiais da plataforma (open77_shell, open77_chat, open77_props, open-voice, open77_coords, ...)
├── gamemodes/          # Modos de jogo e regras de RP (freeroam, lifesim, cordon, deathmatch, ...)
├── dev/                # Ambientes de teste e diagnóstico (open77_example, open77_dbtest)
├── polyzone/           # Biblioteca geométrica de zonas tridimensionais
└── assets/
    ├── loaders/        # ArchiveXL, TweakXL (redistribuídos pela plataforma)
    ├── maps/           # Pacotes de mapas mundiais (.archive - ignorados por git)
    ├── vehicles/       # Pacotes de veículos customizados (.archive)
    └── mods/           # Pacotes de mods de terceiros gerenciados pelo servidor
```

> **Regras de Carga:** O servidor resolve regras de carga (`resources.load` em `server.jsonc`) recursivamente até 2 níveis de categorias (ex: `"system/*"`, `"gamemodes/lifesim/*"`).

---

## 3. Manifesto do Recurso (`open77.lua`)

Todo recurso requer um manifesto `open77.lua` na sua raiz:

```lua
resource "meu_recurso"
version "1.0.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"   -- ou "restart"

-- Scripts Compartilhados, Servidor e Cliente
shared_script "shared/config.lua"

server_scripts {
    "server/database.lua",
    "server/main.lua"
}

client_scripts {
    "client/blips.lua",
    "client/main.lua"
}

-- Interface Web CEF (Chromium Embedded Framework)
web_ui_page "web/index.html"
web_ui_auto_create false
web_files { "web/**" }

-- Arquivos estáticos consumidos pelo cliente Lua (áudio, texturas, ícones)
files {
    "web/**",
    "assets/blips/*.png",
    "assets/audio/*.wav"
}

-- Dependências formais de outros recursos
dependency "ls_core >=0.1.0"
dependency "polyzone >=1.0.0"

-- Permissões explícitas requisitadas
permissions {
    "network.events",
    "local.events",
    "input.actions",
    "webui.system",
    "database.access"
}

-- Exportações Declarativas (vinculadas automaticamente a funções globais homônimas)
exports { "GetClosestDoor", "IsDoorOpen" }          -- Client exports
server_exports { "GetBalance", "AddMoney" }         -- Server exports
```

### Regras Estritas do Manifesto

1. **Includes Cruzados são Terminantemente Proibidos:**
   - A sintaxe `@outro_recurso/arquivo.lua` em `client_scripts` ou `server_scripts` é **recusada por nome** (`cross_resource_include_refused:@recurso/arquivo.lua`) no parser do manifesto. Cada recurso roda em sua própria VM isolada.
   - O compartilhamento de código deve ser feito via `dependency` + `require('@recurso/modulo')` no cliente, ou via `exports` em ambos os lados.
2. **Exportações Declarativas (`exports` e `server_exports`):**
   - Registram automaticamente a função global correspondente antes do recurso atingir o estado `Running`.
   - Se uma função declarada no manifesto não existir no escopo global, o recurso recusa inicialização com `manifest_export_missing:<nome>`.
3. **Chaves FiveM Toleradas:**
   - Chaves legadas como `fx_version`, `game`, `games`, `lua54`, `author`, `description`, `escrow` são aceitas e ignoradas com aviso informativo no console (`INF|meu_recurso|manifest_ignored_keys=fx_version,lua54`).
4. **Preload de Assets REDengine (`preload_mod` / `preload_mods`):**
   - Declara arquivos `.zip` ou `.7z` contendo pacotes `.archive` (texturas XBM, meshes, etc.) que a REDengine precisa carregar antes da inicialização do Lua. O launcher faz o download antes de abrir o jogo.

---

## 4. Runtimes Lua 5.4 & Sandboxing

### Sandbox do Servidor (Server VM)
O script do servidor roda em Lua 5.4 estritamente seguro:
- **Bibliotecas Disponíveis:** `math`, `string`, `table`, `utf8`, `coroutine`, `json`, `print` e a API global `Open77.*`.
- **Bibliotecas Ausentes (`nil`):** **NÃO EXISTEM** `os`, `io`, `debug`, `package`, `require`, `load`, `loadfile`, `dofile`, `collectgarbage`.
  - Chamar `os.time()` gera `attempt to index a nil value`.
  - Chamar `require` no servidor gera `attempt to call a nil value`.
- **Controle de Tempo no Servidor:**
  - Relógio de parede: `Open77.time.unix()` ou `GetUnixTime()` (segundos fracionários desde 1970 UTC); `Open77.time.utc()` ou `GetUtcTimestamp()` (string ISO 8601).
  - Tempo decorrido: `GetGameTimer()` ou `Open77.time.monotonic()` (milissegundos monotônicos).
- **Divisão de Arquivos:** Divida scripts do servidor listando múltiplos arquivos em `server_scripts { ... }` no manifesto, **nunca via `require`**.

### Sandbox do Cliente (Client VM)
- Possui o runtime REDengine 4 integrado via C++.
- Suporta `require('@recurso/modulo')` para carregar bibliotecas declaradas em dependências (como `polyzone`).
- Acesso à API espacial, CEF, markers, worldui, áudio e HUD.

---

## 5. Scheduler, Threads & Gestão de Ticks

| Função | Assinatura | Descrição e Comportamento |
|---|---|---|
| `CreateThread` / `Citizen.CreateThread` | `(fn)` | Agenda uma corrotina gerenciada no escalonador do recurso. |
| `Wait` / `Citizen.Wait` | `(ms)` | Suspende a corrotina atual (aceita de 0 a 86.400.000 ms). **Requer corrotina gerenciada**. |
| `SetTimeout` / `ClearTimeout` | `(ms, fn)` / `(id)` | Agenda ou cancela um timer de disparo único. |
| `SetTick` / `ClearTick` | `(fn)` / `(id)` | Executa a função a cada frame/tick com `Wait(0)` implícito. |
| `GetGameTimer()` | `()` | Retorna milissegundos monotônicos da sessão. |

> **Proteção Contra Erros em Ticks (`SetTick`):** Se uma função de tick disparar erros por **5 execuções consecutivas**, o engine cancela automaticamente o tick (`tick cancelled after 5 consecutive failures`) para proteger os frames da CPU.

---

## 6. Sistema de Eventos & Event Bus Host-Wide

### 6.1. Barramento Local vs Barramento Host-Wide
- `TriggerLocalEvent(event, ...)` / `Open77.events.emitLocal`: Dispara o evento **apenas** dentro da própria VM do recurso atual. Sem serialização, sem filtros.
- `TriggerEvent(event, ...)` / `Open77.events.emit`: Dispara o evento no **barramento global do servidor**. Alcança todos os recursos ativos que registraram manipulador para esse evento.
  - A entrega é **enfileirada e não-reentrante** (processada nas bordas de tick).
  - Argumentos passam por valor (limite de 32 valores, profundidade 16, envelope de até 48 KiB).
  - `source` **não** é propagado pelo bus local. Se o emissor quiser identificar o jogador, deve passar o ID explicitamente como argumento.

### 6.2. Nomes de Eventos Reservados da Plataforma
A plataforma bloqueia a publicação de eventos internos do motor via `TriggerEvent` (retorna `false, "reserved_event"`):
- Reservados exatos: `onResourceStart`, `onResourceStop`, `onResourceStarting`, `onResourceListRefresh`, `onPlayerConnecting`, `onPlayerConnected`, `onPlayerDisconnected`, `playerDropped`, `playerJoining`, `onPlayerReady`, `onPlayerBucketChange`, `onPlayerLifeStateChanged`, etc.
- Prefixos reservados: `__open77`, `onVehicle`, `onNpc`, `onElevator`, `onCyberware`, `onAbility`, `open77:resource:`, `open77:player`, `open77:admin:`.

### 6.3. Eventos Canceláveis (`TriggerCancellableEvent`)
- Permite que um recurso vete uma ação antes de sua consolidação:
  ```lua
  local verdict = TriggerCancellableEvent("chatMessage", source, name, text)
  if verdict ~= nil and verdict:await() then
      return -- Evento foi cancelado por outro recurso
  end
  ```
- Dentro do handler: `CancelEvent()` para vetar; `WasEventCanceled()` para consultar se já foi cancelado.

---

## 7. Comunicação em Rede: NetEvents, Callbacks & Latent Events

### 7.1. Eventos de Rede Autenticados
- Exige permissão `"network.events"` no manifesto.
- **Servidor -> Cliente:**
  ```lua
  TriggerClientEvent("ls:vitals:sync", playerId, data)  -- Para um cliente específico
  TriggerClientEvent("ls:vitals:sync", -1, data)        -- Broadcast para todos
  ```
- **Cliente -> Servidor:**
  ```lua
  TriggerServerEvent("ls:vitals:consume", itemId)
  ```
- **Recepção no Servidor:**
  ```lua
  RegisterNetEvent("ls:vitals:consume", function(itemId)
      local playerId = source  -- 'source' é atribuído pelo engine a partir da conexão autenticada
  end)
  ```

### 7.2. Network Callbacks Bidirecionais (`Open77.net`)
Permite chamadas síncronas/assíncronas no padrão Request/Response com Promise nativa:
- **Servidor Responde:**
  ```lua
  Open77.net.register("economy:getBalance", function(source, accountType)
      return getPlayerBalance(source, accountType)
  end)
  ```
- **Cliente Pergunta:**
  ```lua
  local balance, reason = Open77.net.call("economy:getBalance", "bank"):await()
  ```
- **Servidor Pergunta ao Cliente:**
  ```lua
  local answer, reason = Open77.net.callClient(playerId, "client:confirmAction", payload):await()
  ```

### 7.3. Eventos Latentes Fragmentados (`Open77.net.emitLatent` / `TriggerLatentClientEvent`)
Para transmissão de grandes payloads (até 4 MiB) sem congelar a rede, fragmentados em pacotes de 40 KiB com taxa controlada em bytes por segundo.

---

## 8. State Bags Replicados (`Open77.state`)

Os State Bags fornecem sincronização de estado chave-valor sem a necessidade de despachar eventos de rede manuais repetitivos.

### Seletor de Bags
- `Open77.state.global`: Estado global do servidor.
- `Open77.state.player(playerId)`: Estado vinculado à sessão de um jogador.
- `Open77.state.entity("vehicle"|"npc"|"prop", entityId)`: Estado vinculado a uma entidade do mundo.
- `Open77.state.localPlayer()`: (Apenas cliente) Estado do próprio jogador local.

### Operações de Leitura & Escrita
```lua
-- Servidor grava (Requer permissão "state.write" no manifesto):
local bag = Open77.state.player(playerId)
bag:set("vitals", { hunger = 90, thirst = 80 })
bag:set("cuffed", true)

-- Cliente ou Servidor lê:
local vitals = bag:get("vitals")
local cuffed = bag.cuffed -- Syntax sugar

-- Escuta Reativa de Mudanças:
Open77.state.onChange("vitals", nil, function(bagName, key, value, _reserved, replicated)
    print("Vitals alterado no bag " .. bagName)
end)
```

> **Atenção:** Cinco nomes de métodos têm precedência e não devem ser usados como chaves diretas sem `:get()`: `get`, `set`, `all`, `clear`, `revision`.

---

## 9. Ponte de Banco de Dados SQL (MariaDB / MySQL InnoDB)

A ponte de banco de dados SQL do OPEN//77 é assíncrona, de altíssimo desempenho e opera diretamente no processo do servidor dedicado através do `MySqlConnector`.

### Configuração no `server.jsonc`
```jsonc
{
  "database": {
    "enabled": true,
    "connectionString": "Server=127.0.0.1;Port=3306;Database=open77_lifesim;User ID=root;Password=;",
    "maxRows": 10000
  }
}
```

### Regras Canônicas de Uso
1. **Permissão Exigida:** Somente scripts de servidor (`server_scripts`) com a permissão `"database.access"` podem usar o banco.
2. **APIs Oficiais:** `MySQL.*` e `Open77.database.*` expõem exatamente a mesma API nativa.
3. **Readiness Gate (`MySQL.ready`):**
   ```lua
   MySQL.ready(function()
       print("Banco de dados pronto e verificado.")
   end)
   ```
4. **Operações Assíncronas com `.await`:**
   Devem ser executadas dentro de corrotinas gerenciadas (`CreateThread`, event handlers, etc.):
   - `MySQL.query.await(sql, params)`: Retorna array de linhas como tabelas Lua.
   - `MySQL.scalar.await(sql, params)`: Retorna uma única coluna/valor escalar.
   - `MySQL.update.await(sql, params)`: Retorna o número de linhas afetadas.
   - `MySQL.insert.await(sql, params)`: Retorna o ID gerado (`insertId`).
   - `MySQL.transaction.await(queries, params)`: Executa lote em transação atômica ACID.
5. **Segurança Contra Injeção SQL:**
   Sempre utilize parâmetros preparados com `?` ou `@parametro`. Nunca concatene strings de entrada do usuário.

---

## 10. Telemetria Espacial, Viagem & Teleporte (`Open77.travel` & `Open77.players`)

### No Cliente: `Open77.travel` (Requer permissão `"player.travel"`)
- `Open77.travel.teleport(x, y, z, heading)`: Disparo imediato (fire-and-forget). Não verifica se o chão já foi carregado pelo motor de streaming.
- `Open77.travel.teleportAndSettle({ x = x, y = y, z = z }, heading)`:
  - Retorna uma Promise.
  - Assertiva tripla por 3 frames consecutivos: **no ponto** (raio de 4m horizontal / 6m vertical), **aterrado** (`grounded == true`) e **sem queda** (`fallState == None`).
  - Se o jogador estiver caindo em chão não renderizado, re-emite o teleporte a cada 250ms por até 7s, prevenindo a morte no vazio antes que o motor carregue os blocos.
- `Open77.travel.setNoclip(enabled)` e `Open77.travel.isNoclip()`: Voo livre relativo à câmera com controles integrados.

### No Servidor: `Open77.players.teleport`
- Quando a decisão de teleporte parte do servidor:
  ```lua
  Open77.players.teleport(playerId, x, y, z, heading)
  ```

---

## 11. Interface Nativa WebUI (Chromium Embedded Framework - CEF)

O OPEN//77 utiliza CEF/Ultralight integrado para renderizar interfaces em alta taxa de quadros fora da thread de renderização principal do REDengine 4.

### 11.1. Comunicação Bidirecional Canônica (Zero FiveM NUI)
> **PROIBIÇÃO ABSOLUTA:** `SendNUIMessage`, `RegisterNUICallback`, `SetNuiFocus` **NÃO EXISTEM** no OPEN//77 e causam crash fatal.

- **Criação da Página no Cliente Lua:**
  ```lua
  local page, reason = Open77.webui.create({
      entry = "web/index.html",
      layer = "modal",          -- "hud" (fundo), "modal" (sobreposto), "cursor"
      zIndex = 100,
      visible = false,
      transparent = true,
      fps = 30
  })
  
  -- Exibir e dar foco de mouse/teclado:
  page:show()
  page:setFocus(true, true)    -- (keyboardFocus, mouseFocus)
  
  -- Enviar dados para o JavaScript:
  page:send("hud:update", { health = 100, eurodollars = 25000 })
  
  -- Receber dados enviados pelo JavaScript:
  page:on("ui:action", function(payload)
      print("Ação recebida da UI: " .. tostring(payload.action))
  end)
  ```

- **Lado JavaScript (`web/js/app.js`):**
  ```javascript
  // Escutar eventos vindos do cliente Lua:
  Open77.on("hud:update", (data) => {
      document.querySelector("#health").textContent = data.health;
      document.querySelector("#money").textContent = data.eurodollars;
  });
  
  // Enviar ações para o cliente Lua:
  function fecharInterface() {
      Open77.emit("ui:action", { action: "close" });
  }
  
  // Notificar que a UI carregou o DOM e está pronta:
  Open77.ready();
  ```

### 11.2. Observação do Ciclo de Loading Screen Nativo
O cliente Lua pode monitorar o estado real de carregamento do REDengine 4 para exibir loading screens customizadas e esconder o HUD durante viagens rápidas:
- Funções: `Open77.screen.isLoading()`, `Open77.screen.loadingState()`
- Eventos locais: `open77:loadingScreen:started`, `open77:loadingScreen:changed`, `open77:loadingScreen:finished`

---

## 12. Geometria Tridimensional & PolyZone

- **No Cliente:**
  - Importação via módulo Lua oficial:
    ```lua
    local PZ = assert(require('@polyzone'))
    local PolyZone, BoxZone, CircleZone, ComboZone = PZ.PolyZone, PZ.BoxZone, PZ.CircleZone, PZ.ComboZone
    ```
  - Requer declaração `dependency "polyzone >=1.0.0"` no manifesto.
  - Permite testes de ponto em polígono, volumes OBB orientados por heading e callbacks de entrada/saída (`onPlayerInOut`, `onPointInOut`).
- **No Servidor:**
  - Como a função `require` **não existe** no runtime do servidor, validações de polígonos no servidor devem utilizar algoritmos matemáticos puros em Lua (como Raycasting / Winding Number - `isPointInPolygon`) para garantir autoridade e isolamento sem quebras no boot.

---

## 13. Vetores e Quaternions Nativos

Tanto o cliente quanto o servidor oferecem suporte nativo de primeira classe a tipos vetoriais:
- Tipos disponíveis: `vector2`, `vector3`, `vector4`, `vec` e `quat`.
- Operações aritméticas suportadas: adição (`a + b`), subtração (`a - b`), magnitude/distância (`#(a - b)`), produto escalar e interpolação `lerp`.
- **Garantia de Interoperabilidade:** Toda API que recebe vetores aceita tabelas puras `{ x = ..., y = ..., z = ... }`. Vetores transmitidos pela rede são desserializados como tabelas seguras.

---

## 14. Equivalências & Armadilhas ao Migrar de FiveM

| Funcionalidade FiveM | Equivalente no OPEN//77 | Detalhe Crítico / Armadilha Evitada |
|---|---|---|
| `GetHashKey(str)` / `joaat(str)` | `GetHashKey(str)` / `joaat(str)` | **Calcula o TweakDBID da REDengine (CRC-32 + len)**, NÃO o hash Jenkins do GTA! Modelos GTA não existem; use registros TweakDB reais (ex: `"Vehicle.v_sport2_quadra_turbo_r"`). |
| `RequestModel` / `HasModelLoaded` | **Não existe** | Desnecessário. O engine e o servidor gerenciam streaming de entidades. Use `Open77.vehicles.whenStreamed(id):await()` ou `Open77.npcs.whenReady(id):await()`. |
| `DrawText` / `DrawText3D` em ticks | `open77_uikit:textUI` / `drawText3D` | Zero loops por tick. Chamadas aceitam descritores persistentes gerenciados pelo host. |
| `DoesEntityExist(id)` | `DoesEntityExist(kind, id)` | O primeiro parâmetro do tipo de entidade é **obrigatório** (`"vehicle"`, `"npc"`, `"prop"`, `"elevator"`, `"player"`, `"loot"`). |
| `SetEntityInvincible(id, bool)` | `Open77.players.setGodMode(id, bool)` | Válido apenas para `"player"`. Recusado para veículos e NPCs (que possuem políticas próprias de integridade). |
| `ExecuteCommand(line)` | `ExecuteCommand(line)` | No cliente: resolve apenas comandos locais daquele cliente (não envia ao servidor). No servidor: enfileirado e restrito por permissões ACL (`runtime.commands` / `resources.control`). |
| `SendNUIMessage` / `RegisterNUICallback` | `page:send` / `page:on` (Lua) + `Open77.on` / `Open77.emit` (JS) | NUI do FiveM não existe. Toda comunicação WebUI ocorre via instâncias CEF de `Open77.webui`. |
| `PlayerId()` / `PlayerPedId()` | `Open77.session.playerId()` | IDs FiveM não existem. Sessões são mapeadas por IDs inteiros autenticados da conexão. |

---

## 15. Catálogo de Cobertura da API OPEN//77 (Métricas Oficiais Canônicas)

O OPEN//77 possui três superfícies de script estritamente isoladas, cobertas pelas ferramentas de auditoria contínua da plataforma:

| Superfície de Execução | Referência Canônica | Cobertura Validada |
|---|---|---|
| **Client Native Runtime** | Referência **CLIENT** (`index.html`) | **443 funções em 59 namespaces**, cobrindo chamadas do host e os prelúdios globais do cliente; assinaturas inspecionadas e descrições detalhadas. |
| **Dedicated Server Runtime** | Referência **SERVER** e `server-api.md` | **413 funções em 43 namespaces**, incluindo 64 métodos autoritativos de veículos e 12 métodos de IA veicular, tipos `Open77.Promise`, `Open77.EventVerdict` e 119 globais de baixo nível. |
| **Official Client Packages** | `resource-exports.md` | **129 exportações ativas** em 25 pacotes oficiais do sistema. |

### Validação de Ferramental:
```powershell
python wiki/tools/extract-api.py --json
python wiki/tools/audit-api.py
```

---

## 16. Mapeamento de Teclas & Input (`RegisterKeyMapping`)

O OPEN//77 implementa a primitiva de motor `RegisterKeyMapping` para configuração de teclas no cliente:
- **Persistência Global:** Atalhos registrados persistem entre sessões e são expostos diretamente na aba **KEY BINDINGS** do menu de pausa nativo do Cyberpunk 2077.
- **Padrão Press/Hold:** Mapeamento de ações contínuas utiliza o par de comandos `+comando` (ao pressionar) e `-comando` (ao soltar), permitindo rodas de seleção e menus radiais.
- **Sintaxe Universal:**
  ```lua
  RegisterCommand("+radialmenu", function()
      -- Tecla pressionada
  end, false)

  RegisterCommand("-radialmenu", function()
      -- Tecla solta
  end, false)

  RegisterKeyMapping("+radialmenu", "Roda de Seleção Kiroshi", "keyboard", "TAB")
  ```
- **Leitura Direta:** APIs adicionais permitem inspeção direta de posição do cursor, botão do mouse, roda de rolagem e gamepads analógicos.
- **Input Blocking:** Capacidade de bloquear temporariamente entradas específicas do jogador com vocabulário curado (`input-blocking.md`).

---

## 17. Interações Contextuais & Substituição de Dispositivos Vanilla

O motor expõe um canal de controle para desligar interações padrão da REDengine em dispositivos urbanos:
- **Interceptação de Dispositivos:** Permite suprimir os prompts nativos de máquinas de conveniência, ATMs e terminais de dados da cidade (`device-interactions.md`).
- **Gatilho Canônico:** O evento `open77:deviceUsed` captura a ativação diegética e direciona o fluxo para o recurso responsável (ex: `ls_economy` assumindo o controle com WebUI CEF).
- **WorldUI:** Elementos de interface e marcadores holográficos ancorados no espaço 3D com rastreamento de visibilidade e descarte automático ao abrir modais CEF.

---

## 18. Painel Administrativo Warden & Roster Operacional

O servidor dedicado expõe nativamente o painel de gerenciamento **Warden** na porta HTTP `11780`:
- **Autenticação:** Setup inicial seguro via PIN temporário gerado no boot do servidor no console.
- **Aba Players:** Roster em tempo real monitorando latência (ping), saúde, estado biológico e sessão. Ações administrativas integradas por linha: warn, kick, ban, concessão de permissões, heal, freeze e teleporte.
- **Aba Hub Resources:** Gerenciamento centralizado de pacotes de recursos (instalação, atualização, reversão/rollback e cópias de segurança com retenção histórica).

---

## 19. Subsistemas de Combate, Veículos & Áudio

- **Leases de Ativação de Habilidades:** Habilidades especiais (Dash, Air Dash, Ground Slam/Quake) operam sob o modelo de concessão de leases temporários (`ability-activation-leases.md`), garantindo responsividade imediata no cliente com validação autoritativa assíncrona no servidor.
- **Combate Veicular:** Suporte a disparo de passageiros em veículos (*Passenger Drive-by*), janelas sincronizadas em rede e controle balístico de armamentos veiculares montados.
- **Voz Integrada (VOIP):** Codec nativo Opus com canais de proximidade 3D com atenuação espacial HRTF, frequências de rádio e ligações telefônicas.
- **Sincronização Labial (Voice Lipsync):** Animação facial e movimentação labial diegética em tempo real guiada pelo sinal de áudio da voz de jogadores masculinos e femininos.

---

## 20. Índice Consolidado de Guias Oficiais OPEN//77

| Guia Oficial | Escopo & Assunto |
|---|---|
| `loading-screens.md` | Loading screens WebUI customizadas, eventos de carregamento e ocultação de HUD |
| `vehicle-seat-switching.md` | Troca de assentos animada na cabine e controle autoritativo de motorista |
| `player-utilities.md` | Verificações de integridade, telemetria e controles do corpo do jogador |
| `package-audio.md` | Pacotes de áudio locais e espaciais via rede |
| `screen-picking.md` | Seleção de entidades e pontos espaciais com raio da tela / cursor |
| `context-menu.md` | Menus contextuais reutilizáveis em terceira/primeira pessoa (ALT + clique) |
| `hacking.md` | Curto-circuito, Self-ICE, expurgo de aliados e combate cibernético |
| `ground-slam.md` | Ground Slam / Quake nativo terrestre e aéreo com validação de impacto |
| `ability-activation-leases.md` | Ativação instantânea de habilidades via leases de autoridade |
| `server-resources.md` | Manifestos, isolamento de runtimes, assinatura criptográfica e recarregamento |
| `community-hub-warden.md` | Gestão de recursos via painel Warden (instalação, atualização e rollback) |
| `warden-players.md` | Monitoramento e moderação de jogadores ao vivo pelo Warden |
| `mods.md` / `server-mods.md` | Camadas de mods de arquivo (.archive), distribuição e validação de hashes |
| `sky-advertising.md` | Painéis holográficos aéreos nos céus de Night City com texturas XBM |
| `server-api.md` | Documentação completa de todas as APIs globais do servidor Lua |
| `fivem-compatibility.md` | Aliases de compatibilidade FiveM (`Citizen`, `SetTick`, `promise.new`) |
| `dash.md` | Habilidades de esquiva rápida terrestre e no ar (*Air Dash*) |
| `connection-control.md` | Controle de fila de conexão, deferrals, rejeições e listas de permissão |
| `world-queries.md` | Raycasts, ray de mira, cálculo de altura do solo e pesquisa de objetos |
| `state-bags.md` | Estado replicado de alto desempenho com cotas e escuta reativa |
| `client-players.md` | Enumeração de jogadores na visão do cliente e mapeamento ID <-> Avatar |
| `travel.md` | Movimentação segura, teleporte com assertiva tripla (*settle watch*) e noclip |
| `vectors.md` | Tipos vetoriais nativos (`vector2`, `vector3`, `vector4`, `quat`) |
| `resource-exports.md` / `server-exports.md` | Exportações cliente e servidor entre recursos isolados |
| `lua-modules.md` | Módulos locais via `require('@recurso/modulo')` no cliente |
| `callbacks.md` | Callbacks de rede bidirecionais assíncronos (`Open77.net.call` / `callClient`) |
| `data-reference.md` / `data-catalogues.md` | Catálogo canônico de NPCs, veículos, assentos, armas, animações e SFX |
| `server-acl.md` / `identity.md` | Autenticação, ACL hierárquica e persistência durável de identidades |
| `equipment.md` / `weapons-api.md` | Gestão de guarda-roupa, slots de armas e snapshots balísticos |
| `perspective.md` / `photo-mode.md` | Câmera de primeira e terceira pessoa jogável e controle de photo mode |
| `player-stats.md` / `player-freeze.md` | Leitura e ajuste autoritativo de vida, stamina e congelamento físico |
| `cyberware.md` / `gorilla-arms.md` | Framework de implantes cibernéticos, transações e braços de gorila |
| `weather.md` / `world-time.md` | Clima dinâmico de Night City e controle de escala temporal (*slow motion*) |
| `vehicles.md` / `vehicle-ai.md` | Direção autônoma, autoridade veicular e controle por IA |
| `native-map.md` / `blips.md` | Waypoints nativos, marcadores no minimapa e pins dinâmicos |
| `interactions.md` / `worldui.md` | Prompts contextuais e cards holográficos diegéticos no mundo |
| `polyzone.md` / `zones.md` | Volumes tridimensionais, histerese de entrada/saída e testes OBB |
| `ui-kit.md` / `notifications.md` | Barras de progresso, alertas, menus e notificações holográficas WebUI |
| `elevators.md` / `doors.md` | Portas dinâmicas em rede e elevadores autoritativos com streaming |
| `rp-animations.md` / `rp-kit.md` | Catálogo de 70 animações de RP sincronizadas e kit de contenção |
| `props.md` / `effects.md` / `sound.md` | Objetos sincronizados, efeitos audiovisuais (VFX/SFX) e áudio 3D HRTF |
| `voice.md` / `voice-lipsync.md` | Chat de voz Opus integrado e sincronização labial diegética |

