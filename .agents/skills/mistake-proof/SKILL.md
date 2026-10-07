---
name: mistake-proof
description: Skill de Poka-Yoke (à prova de erros) e catálogo de soluções definitivas para problemas comuns e raros no OPEN//77 e ecossistema REDengine. Consulta obrigatória para prevenir regressões e registro contínuo de novas soluções encontradas.
risk: low
source: workspace
date_added: '2026-10-06'
---

# MISTAKE-PROOF SKILL // POKA-YOKE PROTOCOL (OPEN//77)

> **Regra Primordial:** Sempre que um bug, falha de arquitetura, incompatibilidade de motor ou comportamento inesperado for solucionado no projeto, registre a solução imediatamente neste catálogo e siga este padrão para prevenir regressões perpétuas.

---

## 1. Como Usar Esta Skill

1. **Antes de Criar ou Refatorar um Recurso:**
   - Consulte os registros desta skill para evitar armadilhas conhecidas (ex: `export_yielded`, keybindings incorretos, duplicação de marcadores 3D).
2. **Após Solucionar Qualquer Problema (Comum ou Raro):**
   - Adicione um novo registro nesta tabela e nos arquivos de contexto da pasta `.agent/`.
   - Formato obrigatório:
     - **ID e Título**
     - **Sintoma Observado**
     - **Causa Raiz Real**
     - **Anti-Padrão (O que NÃO fazer)**
     - **Solução Canônica Comprovada**
     - **Arquivos de Referência**

---

## 2. Catálogo de Soluções Definitivas (Poka-Yoke Knowledge Base)

### [MP-001] Atalhos de Teclado no OPEN//77 (Keymapping & Input Actions)
* **Sintoma:** Atalhos ("I", "TAB", etc.) não disparam ações, comandos não respondem às teclas físicas.
* **Causa Raiz:** 
  1. Falta da permissão `"input.actions"` no manifesto `open77.lua`.
  2. Uso da assinatura do FiveM `RegisterKeyMapping(cmd, desc, "keyboard", key)`. No OPEN//77, o 3º parâmetro é a tecla e o 4º é a função callback.
* **Anti-Padrão:** Passar `"keyboard"` como se fosse parâmetro no OPEN//77.
* **Solução Canônica:**
  ```lua
  -- No open77.lua:
  permissions { "input.actions", ... }

  -- No client Lua:
  Open77.input.registerKeyMapping({
      id = "action_id",
      name = "Descrição do Atalho",
      key = "I", -- tecla física
      hold = false, -- true se for tecla de segurar (ex: TAB)
      onPressed = function() ... end,
      onReleased = function() ... end -- opcional para hold
  })
  ```
* **Referência:** `ls_inventory/client/main.lua`, `open77-client.d.lua:4135`.

---

### [MP-002] Erro de Export com Corrotina/Await (`export_yielded`)
* **Sintoma:** Consultas a banco de dados através de `exports["ls_data"]:query` falham silenciosamente, retornam `nil` ou disparam `open77/runtime.lua: export_yielded`.
* **Causa Raiz:** No OPEN//77, funções chamadas através de `exports` são **estritamente não-yielding** (não podem pausar a thread do motor). Funções assíncronas internas com `.await` quebram o boundary de export.
* **Anti-Padrão:** Chamar operações assíncronas com `.await` dentro de exports compartilhados entre recursos.
* **Solução Canônica:**
  - Declarar a permissão `"database.access"` no `open77.lua` do recurso consumidor.
  - Usar diretamente os drivers nativos assíncronos no servidor:
  ```lua
  local rows = MySQL.query.await("SELECT ...", { param1 })
  local affected = MySQL.update.await("UPDATE ...", { param1 })
  ```
* **Referência:** `ls_economy/server/main.lua`, `ls_housing/server/main.lua`.

---

### [MP-003] Prevenção de Rollback Financeiro & Starter Grant em Loop
* **Sintoma:** Jogador gasta dinheiro, desloga e ao logar novamente recebe saldo inicial de novo (E$ 500 / E$ 2.500), apagando seu progresso.
* **Causa Raiz:** O código trata retorno `nil` (erro de conexão com banco de dados) como "jogador novo", caindo no bloco `else` que concede `starter_grant` e sobrescreve a tabela no MariaDB.
* **Anti-Padrão:** `if rows and #rows > 0 then ... else grantStarter() end`.
* **Solução Canônica:**
  - Distinguir explicitamente `#rows == 0` (novo) de `rows == nil` (falha técnica):
  ```lua
  if type(rows) == "table" and #rows > 0 then
      -- Carrega dados existentes
  elseif type(rows) == "table" and #rows == 0 then
      -- Novo jogador legítimo: concede starter funds
  else
      -- Falha de banco (rows == nil): JAMAIS conceder starter funds por engano.
      -- Aguardar e tentar novamente ou usar fallback sem sobrescrever o banco!
  end
  ```
* **Referência:** `ls_economy/server/main.lua:loadPlayerAccount`.

---

### [MP-004] Duplicação de Marcadores 3D no REDengine & Stuttering Próximo a Instâncias
* **Sintoma:** Queda de frames e micro-travamentos (stuttering) de até 200ms ao se aproximar de portas e edifícios (ex: Megabuilding H10).
* **Causa Raiz:** Chamar `Open77.markers.create` e também `open77_worldui:create` nas mesmas coordenadas. O recurso oficial `open77_worldui` **já cria nativamente um marcador 3D de chão** sob o card. Dois marcadores sobrepostos causam z-fighting e sobrecarga brutal de shaders.
* **Anti-Padrão:** Chamar `markers.create` manualmente para pontos que já usam `open77_worldui`.
* **Solução Canônica:**
  - Deixar o `open77_worldui` gerenciar o anel e o card de forma centralizada.
  - Usar `Open77.markers.create` apenas como fallback isolado se o `open77_worldui` não estiver disponível.
* **Referência:** `ls_housing/client/main.lua:registerDoorInteractions`.

---

### [MP-005] Polling Agressivo de Teclas em Threads (`Wait(10)` / `Wait(15)`)
* **Sintoma:** Queda contínua de FPS e engasgos periódicos no cliente enquanto o jogador caminha ou interage.
* **Causa Raiz:** Threads em loop checando teclas (`isDown`, `isActionJustPressed`) 60 a 100 vezes por segundo, chamando múltiplos métodos de input a cada tick mesmo a quilômetros de distância de qualquer ponto interativo.
* **Anti-Padrão:** `while true do Wait(10); if isNear then check() end end`.
* **Solução Canônica:**
  - Implementar **polling adaptativo**:
  ```lua
  CreateThread(function()
      while true do
          if isNearInteractionZone then
              Wait(100) -- Responsividade ágil (0.1s)
              -- Checagem de teclas
          else
              Wait(500) -- Hibernação quando inativo
          end
      end
  end)
  ```
  - Priorizar eventos orientados a ação disparados pelo próprio `open77_worldui` (ex: `ls:housing:openDoorTarget`) ao invés de listeners manuais.
* **Referência:** `ls_housing/client/main.lua`, `ls_housing/client/interactions.lua`.

---

### [MP-006] Inicialização de WebUI Invisível Consumindo GPU CEF
* **Sintoma:** Consumo elevado de CPU/GPU do processo Chromium Embedded Framework mesmo com a tela do jogo livre de interfaces.
* **Causa Raiz:** Chamar `WebUI.create` com `visible = true` em páginas de menus e modais de 1920x1080. Mesmo com fundo transparente, o compositor CEF renderiza a 60 FPS continuamente.
* **Anti-Padrão:** `WebUI.create({ ..., visible = true, fps = 60 })` para modais que iniciam fechados.
* **Solução Canônica:**
  - Inicializar sempre com `visible = false`.
  - Chamar `page:show()` somente no momento da abertura e `page:hide()` no fechamento.
* **Referência:** `ls_housing/client/main.lua:createHousingPage`.

---

### [MP-007] Foco de Mouse e Fechamento Universal em Interfaces CEF
* **Sintoma:** Menus circulares (Quick Radial) abrem mas o mouse não navega pelas opções; ou modais de tela cheia travam o jogo porque o ESC/teclas físicas não respondem.
* **Causa Raiz:** 
  1. No Quick Radial, o cliente Lua não chamava `page:setFocus(false, true)` para liberar o ponteiro do mouse na camada WebUI.
  2. Ao focar teclado no CEF (`page:setFocus(true, true)`), o motor do jogo para de receber teclas; se a página WebUI não tiver um listener de `keydown` para ESC ou a tecla de atalho, a interface fica travada.
* **Solução Canônica:**
  - No cliente Lua para menus com cursor sem travar a câmera:
    `page:setFocus(false, active)` (false para teclado, true para mouse).
  - No `app.js` da WebUI:
    Adicionar listener universal de `keydown` para `Escape` e para a tecla de atalho de fechamento em qualquer modal ativo.
* **Referência:** `ls_ui/client/main.lua`, `ls_ui/web/app.js`.

---

### [MP-008] Modais CEF Aninhados e Ocultação por Herança CSS (`display: none !important`)
* **Sintoma:** O jogo entra em modo de foco NUI (cursor aparece, controles bloqueiam), o JS recebe o evento de abertura e remove a classe `.hidden`, mas a interface do modal (Inventário, Radial Menu) simplesmente não é desenhada na tela.
* **Causa Raiz:** O modal secundário (`#inventory-modal` ou `#radial-overlay`) foi inserido acidentalmente dentro das tags de outro modal (ex: `#ripperdoc-modal`) que estava sem fechamento `</footer></div></div>`. Como o elemento-pai possui a classe `.hidden` com `display: none !important`, os filhos herdam o cancelamento de renderização da árvore DOM do Chromium (CEF), tornando impossível sua exibição visual.
* **Anti-Padrão:** Aninhar múltiplos modais de tela cheia ou esquecer de fechar tags `div` de containers anteriores.
* **Solução Canônica:**
  - Todo modal ou overlay WebUI deve ser **irmão direto (sibling)** de `<main id="hud-viewport">` ou do `<body>`, nunca aninhado dentro de outro modal.
  - Validar a árvore DOM com linting ou checagem de fechamento de tags antes de publicar.
* **Referência:** `ls_ui/web/index.html:465-472`.

---

### [MP-009] Oclusão de Cutscenes 3D Nativas por Background Opaco na LoadScreen
* **Sintoma:** Ao carregar o servidor, a cutscene 3D vanilla do Cyberpunk 2077 (cenas aéreas de Watson, chuva, prédios) não aparece; a tela exibe um fundo azul-marinho ou preto sólido cobrindo todo o jogo.
* **Causa Raiz:** O Chromium Embedded Framework (CEF) renderiza a página declarada em `loadscreen "web/index.html"` diretamente sobre o viewport 3D do REDengine. Se o CSS (`body`, `html`, `.media-viewport`, `.scene-backdrop`) tiver cores sólidas (ex: `#040810`) ou gradientes com alfa `>= 0.90`, o Chromium cobre e oclui 100% da renderização do motor nativo.
* **Anti-Padrão:** `body { background-color: #040810; }` ou gradientes radiais opacos cobrindo a viewport da loadscreen.
* **Solução Canônica:**
  - `html, body { background: transparent !important; background-color: transparent !important; }`.
  - Camadas centrais (`.media-viewport`, `.vanilla-layer`) devem ter fundo transparente.
  - Efeitos diegéticos de cenário (`.scene-backdrop`) devem utilizar iluminação ambiente suave (`rgba(..., 0.12) 0%, transparent 65%`) com `mix-blend-mode: screen; pointer-events: none;`.
  - Vinhetas de tela (`.screen-vignette`) devem ter opacidade leve nos cantos (máx `0.35` alfa) sem cobrir o centro.
* **Referência:** `ls_loadscreen/web/css/style.css:27-70`, `ls_loadscreen/web/config.json`.

---

### [MP-010] Desacoplamento de Keybinds Nativas do REDengine e Mapeamento Reconfigurável (open77_pause)
* **Sintoma:** Tecla `TAB` ou `ALT` em atalhos customizados conflita com funções vitais do Cyberpunk (Scanner de Hacking, Quickhacks) ou atalhos do Windows (Alt+Tab); usuário não consegue personalizar atalhos dentro do jogo.
* **Causa Raiz:** Vinculação estática com tecla `TAB` e uso de hardcoding de atalhos sem registrar no motor OPEN//77.
* **Anti-Padrão:** Hardcode de teclas conflituosas em `RegisterKeyMapping` sem registro na tabela de mapeamento do motor.
* **Solução Canônica:**
  - Utilizar `CAPSLOCK` como tecla ergonômica padrão para menus de segurar com a mão esquerda (ao lado de WASD e abaixo do TAB), deixando o `TAB` livre para o futuro Scanner/Hacking.
  - Registrar atalhos através de `Open77.input.registerKeyMapping({ id, name, key, hold, onPressed, onReleased })`. O menu de pausa nativo (`open77_pause`) varre automaticamente todos os mappings e permite que o próprio jogador altere a tecla em **ESC > Configurações > KEY BINDINGS**.
  - Criar comandos informativos `/keybinds` e `/atalhos` notificando o jogador sobre a reconfiguração in-game.
* **Referência:** `ls_inventory/client/main.lua:initKeyBindings`, `ls_inventory/shared/config.lua`.

---

### [MP-011] Resolução de Identidade de Inventário & Caching de Estado CEF
* **Sintoma:** Erro `export ls_core:GetPlayerCharacterId export_not_found`, mochila do jogador abre sempre vazia (`0 / 40 SLOTS`, `0.0 / 35.0 kg`), mesmo com itens gravados no banco de dados.
* **Causa Raiz:**
  1. No ecossistema Life-Sim, a identidade permanente é a `license` (`CHAR(32)`), obtida por `exports["ls_core"]:getSession(src).license`. O export `GetPlayerCharacterId` não existe.
  2. O evento de carregamento oficial do jogador é `ls:core:playerLoaded(playerId, license)`. Listeners como `ls:core:characterSelected` nunca eram disparados.
  3. Descarte de pacotes de dados: Se o evento de sync do servidor chegasse ao cliente antes do CEF terminar de carregar (`ready == false`), o pacote era descartado silenciosamente.
* **Anti-Padrão:** Presumir exports de frameworks FiveM (como ESX/QBCore) e não cachear payloads antes do `ready` da WebUI.
* **Solução Canônica:**
  - No servidor: Obter licença via `exports["ls_core"]:getSession(src)` com fallback para `Open77.players.identifiers(src).license`.
  - Escutar `AddEventHandler("ls:core:playerLoaded", function(playerId, license) loadPlayerInventory(playerId, license) end)`.
  - Garantir injeção de starter kit mesmo se o inventário já existia mas estava com 0 itens (`#itemRows == 0`).
  - No cliente: Implementar `cachedInventoryBag`. Reenviar imediatamente quando a página emitir `ls:ui:ready` e quando o modal de inventário for aberto (`toggleInventoryModal`).
* **Referência:** `ls_inventory/server/main.lua`, `ls_ui/client/main.lua`.

---

### [MP-012] Loadout Persistente do Quick Radial Menu (8 Slots) & Dimensionamento Responsivo CEF
* **Sintoma:** Jogador sem conseguir equipar itens específicos na roda radial (`CAPSLOCK`), setores pegavam itens aleatórios ou ficavam vazios; interface do inventário comprimida no centro da tela (box vermelha de 1150px x 740px).
* **Causa Raiz:**
  1. Ausência de slots de loadout mapeados para a roda radial: o frontend lia os primeiros 8 itens da mochila sequencialmente sem controle do usuário.
  2. Dimensões CSS fixas em pixels (`width: 1150px; height: 740px; .inv-body { height: 590px; }`), impedindo que a interface se expandisse proporcionalmente à resolução do monitor (box verde).
* **Anti-Padrão:** Tamanhos absolutos em pixels para modais complexos e atalhos rápidos sem drag & drop ou persistência.
* **Solução Canônica:**
  - No CSS: Utilizar escalas fluidas com `clamp()`:
    ```css
    .inventory-card {
        width: clamp(1050px, 92vw, 1720px);
        height: clamp(680px, 88vh, 980px);
    }
    .inv-body {
        flex: 1;
        height: auto;
        min-height: 0;
    }
    .inventory-grid {
        grid-auto-rows: clamp(72px, 8.2vh, 92px);
    }
    ```
  - No JS/HTML: Criar painel `.radial-loadout-panel` com 8 slots direcionais (`[1] ↑` a `[8] ↖`), salvos no `localStorage` (`ls_radial_loadout_slots`).
  - Permitir equipar via **Drag & Drop** (arrastar da mochila para o slot do radial) ou **Clique com Botão Direito** no item da mochila.
  - No Quick Radial Menu (`CAPSLOCK`): mapear rigorosamente cada setor (0 a 7) para o item configurado no loadout, checando a disponibilidade de estoque na mochila em tempo real.
* **Referência:** `ls_ui/web/app.js:renderRadialLoadout`, `ls_ui/web/app.css:2012-2330`.

---

### [MP-013] Paridade Estrita de Catálogos Lua/CEF & Prevenção de Placeholders Visuais Fantasmas
* **Sintoma:** Itens no inventário ou máquinas de venda aparecem com ícone de interrogação `?` (`default_item.svg`) ou com imagem inadequada (ex: cartas de tarô, relógios e discos de vinil aparecendo como datashard `shard.png`); discrepâncias de atributos ou imagens entre o backend e a interface CEF.
* **Causa Raiz:**
  1. Criação de itens no catálogo de inventário sem os respectivos arquivos visuais em `ls_ui/web/images/`, forçando o fallback para `default_item.svg` ou reuso indiscriminado de assets genéricos.
  2. Modificação de `items_catalog.lua` sem atualizar o arquivo espelho `catalog.js`, causando dessincronização entre a validação de regras do servidor e a renderização do cliente WebUI.
* **Anti-Padrão:** Deixar itens sem arte própria com `default_item.svg` ou alterar apenas um dos lados do catálogo (Lua ou JS).
* **Solução Canônica:**
  - Todo novo item deve possuir um ícone dedicado na pasta `Server/resources/gamemodes/lifesim/ls_ui/web/images/` (preferencialmente vetorial SVG estilizado em HUD neon Cyberpunk).
  - Toda alteração em `items_catalog.lua` deve ser espelhada atomicamente em `catalog.js`.
  - Executar rotina automatizada de verificação de integridade (`verify_images.py`) para certificar que 100% das referências de imagem existem em disco e que o uso de `default_item.svg` é exatamente **ZERO**.
* **Referência:** `items_catalog.lua`, `ls_ui/web/catalog.js`, `Server/.agent/scratch/verify_images.py`.

---

## 3. Diretriz de Manutenção Perpétua

1. Cada nova solução descoberta DEVE receber um novo código sequencial `[MP-00X]`.
2. A solução deve sempre privilegiar a documentação canônica em `https://open2077.net/docs`.
3. Nunca regrida um código já protegido pelas regras deste catálogo.
