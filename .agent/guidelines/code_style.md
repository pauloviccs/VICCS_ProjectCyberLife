# Diretrizes de Estilo de Código (Code Style) — OPEN//77 Life-Sim RP

> **Escopo:** Padrões obrigatórios de codificação para todos os recursos Lua 5.4, interfaces WebUI (Svelte 5) e consultas de banco de dados no ecossistema OPEN//77.

---

## 1. Regras Fundamentais da Plataforma

1. **REGRA PRIMORDIAL: Documentação Oficial OPEN//77 como Fonte da Verdade:**
   - Toda implementação, arquitetura, script Lua e interface NUI DEVE ter como fonte primária e absoluta a documentação oficial: **https://open2077.net/docs** e os stubs do Devkit (`open77-client.d.lua`, `open77-server.d.lua`).
   - É terminantemente proibido utilizar ou alucinar APIs do FiveM/GTA V (`PlayerPedId`, `GetEntityCoords`, `SetEntityCoords`, `IsControlJustPressed(0, 38)`, `RegisterNUICallback`, `SendNUIMessage`, `ox_target:addSphereZone`, etc.).

2. **Autoridade Estrita do Servidor (Server-Authoritative):**
   - O cliente é considerado ambiente não confiável. Nunca aceite valores de inventário, dinheiro, vida, coordenadas ou decaimento calculados no cliente.
   - O cliente emite apenas *intenções* (`events` sanitizados). O servidor valida permissões, estados, inventário e saldo antes de efetuar a mutação.

3. **Nativas Autorizadas e Validação de Permissões:**
   - Nunca presuma a existência de uma nativa. Sempre consulte a documentação oficial ou os stubs de tipagem.
   - Declare explicitamente todas as permissões exigidas no manifesto `open77.lua` via bloco `permissions { ... }` (ex: `world.markers`, `ui.vanilla.map`, `input.actions`, `player.travel`).

3. **Isolamento de Ambientes:**
   - Proibido chamar nativas de cliente em arquivos do servidor ou nativas de servidor em arquivos de cliente.
   - Cada recurso executa em uma VM Lua 5.4 isolada. Comunicação entre recursos DEVE ser feita via `exports`.

---

## 2. Padrões de Lua 5.4

### 2.1. Nomenclatura e Formatação
- **Variáveis locais e funções:** `snake_case` (ex: `local player_license`, `function calculate_stress()`).
- **Módulos, Tabelas de Configuração e Classes:** `PascalCase` (ex: `VitalsController`, `Config.VitalsDecay`).
- **Constantes globais:** `UPPER_SNAKE_CASE` (ex: `MAX_IMPLANTS_LIMIT = 8`).
- **Prefixos de Recursos:** `ls_` para recursos de gamemode Life-Sim (ex: `ls_core`, `ls_vitals`, `ls_economy`).

### 2.2. Tratamento de Erros e Retornos
- Padrão Go / Lua idiomático: retorne `val` no sucesso ou `nil, reason` (em `snake_case`) na falha.
  ```lua
  function Database.getPlayer(source)
      local license = Open77.getIdentifier(source)
      if not license then
          return nil, 'invalid_license'
      end
      -- query...
      return playerData
  end
  ```
- Use `pcall` apenas em limites de I/O (ex: `json.decode`) ou operações não controladas pela VM.

### 2.3. Tipagem de Identificadores (Atenção Crítica)
- **REDengine Entity IDs (64-bit):** São IDs de 64 bits representados como strings ou dados opacos. **NUNCA use `tonumber()`** em IDs de entidades ou componentes da REDengine (causa perda de precisão e estouro de ponteiro).
- **Player Session IDs (`source`):** Devem ser convertidos via `tonumber(src)`.
- **Identificador de Persistência:** Utilize sempre `Open77.getIdentifier(src)` (ex: `license:xxx`), nunca o ID de sessão volátil.

### 2.4. Performance e Loops
- **Proibido `Wait(0)` ocioso:** Loops com `Wait(0)` travam a renderização de frames do cliente e sobrecarregam o scheduler do servidor.
- Use **polling adaptativo**:
  - Estado ocioso: `Wait(500)` a `Wait(1000)`.
  - Próximo a interação/marcador: `Wait(100)` a `Wait(250)`.
  - Apenas em renderização ativa de gizmo ou raycast no frame: `Wait(0)`.

---

## 3. Persistência e Cache (MariaDB / MySQL & Memória)

1. **Transações Críticas (Dinheiro, Itens, Imóveis):**
   - Sempre execute de forma síncrona/esperada (`MySQL.*.await` ou `Open77.database`).
   - Use transações com locks explícitos (`SELECT ... FOR UPDATE`) para evitar condições de corrida (race conditions) e duplicações.
   - NUNCA armazene saldos bancários ou inventários apenas em cache.

2. **Alta Frequência (Biometria, Necessidades, Posição):**
   - Utilize o `CacheService` (cache volátil em tabela de memória na VM Lua).
   - Efetue o *Write-Behind*: descarregue os dados consolidados no banco a cada 5 minutos em lote (*batch flush*), na desconexão do jogador (`playerDropped`) e no desligamento do recurso (`onResourceStop`).

---

## 4. Front-End NUI (Svelte 5)

1. **Proibido VDOM Clássico (React):** A NUI roda em Chromium Edge WebView2 out-of-process. Para evitar pausas de Garbage Collection e perda de FPS no jogo, use exclusivamente **Svelte 5**.
2. **Svelte 5 Runes:** Use `$state()`, `$derived()`, e `$effect()`. Não use a sintaxe antiga de Svelte 3/4 (`let`, `$:`) nem stores legadas.
3. **Ponte de Mensagens NUI:**
   - Mensagens do cliente para a NUI: `SendNuiMessage(json.encode({ action = 'updateVitals', data = ... }))`.
   - Callbacks da NUI para o cliente: `fetch('https://' .. GetCurrentResourceName() .. '/action', { method: 'POST', body: JSON.stringify(data) })`.
   - Registre callbacks no cliente com `RegisterNuiCallbackType('action')` e `AddEventHandler('__cfx_nui:action', ...)`.
