# Relatório de Diagnóstico & Resolução: Travamento de Spawn e Modais CEF

## 1. Visão Geral do Incidente
- **Sintoma Relatado:** Ao conectar no servidor, o jogador ficava permanentemente paralisado no ponto padrão de spawn (Watson / Megabuilding H10). Os modais das interfaces criadas (como `ls_spawn`, inventário, etc.) pararam de abrir ou receber interação.
- **Evidências Analisadas:** Diretórios de logs `Server/.agent/logs/24` e `Server/.agent/logs/25` (`game-console.log`, `server-console.log`, incidentes REDengine).

---

## 2. Diagnóstico & Causas Raiz

### Causa 1: Parede de Vidro Invisível no CEF (Bloqueio de Pointer Events)
- **O que acontecia:** No arquivo [app.css](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.css), a div do menu radial rápido (`#radial-overlay`) possuía:
  ```css
  .radial-overlay { position: fixed; inset: 0; z-index: 9999; pointer-events: auto; }
  ```
  Porém, **não existia nenhuma regra para `.radial-overlay.hidden`** nem uma regra global `.hidden`.
- **Efeito:** Mesmo com a classe `hidden` aplicada no HTML, a div ocupava 100% da viewport (1920x1080) com `pointer-events: auto`. Isso criava uma "parede de vidro" invisível por cima do jogo e de outros modais, engolindo os cliques do mouse antes que chegassem aos botões ou ao modal de spawn.

### Causa 2: Descompasso Fatal de Tempo (Race Condition de Bootstrap)
- **O que acontecia:** O motor do Cyberpunk 2077 (REDengine 4) leva cerca de 10 a 25 segundos para carregar o mundo e finalizar o bootstrap do avatar (`open77:playerReset:complete`). Durante esse tempo, a apresentação de superfícies WebUI/CEF fica bloqueada pelo motor (`server WebUI presentation opened: reason=player_bootstrap_complete`).
- **O gatilho prematuro:** No servidor [session.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_core/server/session.lua), o anúncio de jogador carregado (`ls:core:playerLoaded`) disparava após apenas 3 segundos de conexão.
- **Efeito cascata:** O módulo [ls_spawn](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_spawn/server/main.lua) escutava o anúncio precoce, congelava o jogador no servidor (`Open77.players.setFrozen(playerId, true)`) e enviava a ordem para abrir a UI. Porém, a tela de apresentação do jogo ainda estava no carregamento inicial; o evento passava despercebido, o modal nunca era desenhado e o jogador ficava congelado eternamente no Megabuilding H10 sem menu na tela.

### Causa 3: APIs Estrangeiras de FiveM no Cliente do Core
- **O que acontecia:** O arquivo [main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_core/client/main.lua) continha chamadas herdadas de GTA V (`PlayerPedId()`, `DoesEntityExist()`, `IsEntityDead()`), que não existem no Cyberpunk 2077 / Open//77, impedindo que o watchdog de prontidão do cliente funcionasse.

### Causa 4: Ausência de Handshake Ativo e Watchdog de Segurança
- Se o evento de abertura de spawn fosse perdido durante a conexão, o cliente nunca requisitava o menu de novo e o servidor não possuía um timeout de resgate para descongelar o jogador inativo.

---

## 3. Modificações e Soluções Aplicadas

### A. Eliminação das Barreiras de Pointer-Events no CEF
1. **[ls_ui/web/app.css](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.css):**
   - Inserida a regra global inviolável:
     ```css
     .hidden, .radial-overlay.hidden, .kiroshi-modal.hidden, .kiroshi-tooltip.hidden, .side-panel.hidden, [hidden] {
         display: none !important;
         pointer-events: none !important;
         visibility: hidden !important;
         opacity: 0 !important;
     }
     ```
   - Definido `pointer-events: none;` no `body` de todas as superfícies transparentes de HUD (`ls_ui`, `ls_spawn`, `ls_housing`), garantindo que apenas modais e botões explicitamente abertos capturem cliques.

2. **[ls_ui/web/app.js](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.js) & [ls_ui/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/client/main.lua):**
   - Adequado o envio de payloads em tabela no padrão nativo OPEN//77 (`{ open = true }`, `{ active = true }`).
   - Normalizado o leitor JS para tratar payloads tanto primitivos quanto em objetos de forma segura.

### B. Sincronização Precisa com o Ciclo de Vida do REDengine 4
1. **[ls_core/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_core/client/main.lua):**
   - Removidas todas as chamadas herdadas de FiveM/GTA V.
   - Vinculada a prontidão física do cliente ao evento canônico oficial `open77:playerReset:complete` e ao módulo nativo `Open77.players.localId()`.
2. **[ls_core/server/session.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_core/server/session.lua):**
   - Ajustado o fallback de anúncio (`maybeAnnounce`) para 25 segundos, priorizando a confirmação real do cliente (`clientReady == true`), eliminando o disparo prematuro de spawn.

### C. Handshake Resiliente e Watchdog de Segurança no Spawn
1. **[ls_spawn/server/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_spawn/server/main.lua):**
   - Adicionado `RegisterNetEvent("ls:spawn:requestOpen")`: permite ao cliente solicitar o menu de spawn sob demanda assim que sua WebUI estiver montada.
   - Adicionado `RegisterNetEvent("ls:spawn:unlock")`: garante a liberação de locomoção autoritativa no servidor.
   - Implementado **Watchdog Automático de Segurança**: se um jogador permanecer no menu de spawn por mais de 75 segundos, o servidor realiza o auto-spawn seguro na última posição ou Megabuilding H10 e o descongela incondicionalmente.
   - Adicionado comando de console/admin `/unlockspawn [id]`.
2. **[ls_spawn/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_spawn/client/main.lua):**
   - Vinculado ao evento `open77:playerReset:complete` para reaplicar foco e dados do seletor no instante exato em que a engine encerra o carregamento.
   - Adicionados comandos `/spawnmenu`, `/respawnmenu` e `/unfreezeme` para recuperação imediata em qualquer cenário de desincronização.

---

## 4. Matriz de Arquivos Modificados & Verificação

| Arquivo | Componente | Status Sintático |
| :--- | :--- | :--- |
| [ls_ui/web/app.css](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.css) | Estilos / Input Gating | Validado |
| [ls_ui/web/app.js](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.js) | CEF Bridge Listeners | Validado (Node.js) |
| [ls_ui/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/client/main.lua) | Client Lua Bridge | Validado (Balanced 0) |
| [ls_spawn/web/css/style.css](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_spawn/web/css/style.css) | Estilos / Pointer Events | Validado |
| [ls_spawn/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_spawn/client/main.lua) | Handshake & Lifecycle | Validado (Balanced 0) |
| [ls_spawn/server/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_spawn/server/main.lua) | Watchdog & Handshake | Validado (Balanced 0) |
| [ls_core/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_core/client/main.lua) | Native Engine Events | Validado (Balanced 0) |
| [ls_core/server/session.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_core/server/session.lua) | Lifecycle Announce Timing | Validado (Balanced 0) |
| [ls_housing/web/css/style.css](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/web/css/style.css) | CEF Input Isolation | Validado |
