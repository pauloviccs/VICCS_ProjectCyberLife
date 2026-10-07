# RELATÓRIO EXECUTIVO: FIXES CRÍTICOS (LOG 27) & POKA-YOKE PROTOCOL

**Engenheiro Responsável:** The Universal Engineer (UEoE 1)  
**Ambiente:** REDengine 4 / Cyberpunk 2077 v2.31 + OPEN//77 Build `2.31.21+op77.124`  
**Status dos 3 Bugs:** 100% Diagnosticados, Corrigidos e Validados nos Arquivos do Servidor.

---

## 1. Diagnóstico Forense & Causa Raiz

### Bug 1: Quick Radial Menu & Keybinds Reconfiguráveis
* **Causa Raiz da Inoperância Visual:** O elemento `#radial-overlay` estava aninhado dentro de `#ripperdoc-modal` (que tinha `.hidden` com `display: none !important`), impedindo sua exibição física.
* **Causa do Conflito de Tecla:** O uso do `TAB` causava colisão arquitetural com o scanner neural vanilla do Cyberpunk (futuro Quickhacking/Scanner).
* **Solução Canônica:**
  - Migração da tecla padrão de `TAB` para `CAPSLOCK` (ergonomia imediata na mão esquerda abaixo do TAB, sem atrito com atalhos de sistema como Alt+Tab).
  - Registro de `inventory_toggle` e `radial_menu_hold` via `Open77.input.registerKeyMapping`. O motor OPEN//77 expõe automaticamente essas entradas no menu nativo do jogo (**ESC > Configurações > KEY BINDINGS**), permitindo que qualquer jogador reconfigure ou resete os atalhos.
  - Implementação de rastreamento vetorial de ângulo do mouse com deadzone de 45px no `ls_ui/web/app.js`.

---

## 2. Cutscenes 3D Vanilla Encobertas na Loading Screen
* **Causa Raiz:** O Chromium Embedded Framework (CEF) renderiza a loadscreen diretamente sobre o viewport 3D do REDengine. O CSS original continha:
  - `body { background-color: #040810; }` (cor sólida opaca);
  - `.screen-vignette` com cantos atingindo 95% de opacidade preta;
  - `.scene-backdrop` com gradientes radiais de 98% de opacidade azul/preta (`rgba(3, 7, 14, 0.98)`).
* **Solução Canônica:**
  - `html, body { background: transparent !important; }` e `.media-viewport { background: transparent !important; }`.
  - `.screen-vignette` suavizada para manter vinheta diegética leve (máx 35% nos cantos).
  - Gradientes escuros substituídos por iluminação holográfica ambiente transparente (`rgba(..., 0.12) 0%, transparent 65%`) com `mix-blend-mode: screen; pointer-events: none;`.
  - A cutscene 3D nativa do Cyberpunk 2077 (Watson, chuva, viadutos e prédios) agora aparece 100% nítida em tempo real sob o HUD Kiroshi.

---

## 3. Front-End do Inventário Não Aparecia (NUI Focus Vazio)
* **Causa Raiz:** No arquivo `ls_ui/web/index.html` (linha 465), o `#ripperdoc-modal` foi deixado sem as tags de fechamento `</footer></div></div>`. Por consequência, a árvore DOM colocou o `#inventory-modal` **dentro** da maca do Ripperdoc. Como o Ripperdoc permanecia oculto (`.hidden` com `display: none !important`), o Chromium suprimia a renderização do inventário por herança CSS, mesmo quando o JS removia o `.hidden` do inventário.
* **Solução Canônica:**
  - Fechamento formal do Ripperdoc aplicado no HTML, libertando `#inventory-modal` e `#radial-overlay` como filhos diretos do `<main id="hud-viewport">`.
  - Integração do `inventoryModalEl` na rotina de ocultação do Biomonitor HUD.

---

## 2. Arquivos Modificados Diretamente no Projeto

1. [`ls_inventory/shared/config.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_inventory/shared/config.lua):
   - `Keys.radial` alterado para `"CAPSLOCK"`.
2. [`ls_inventory/client/main.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_inventory/client/main.lua):
   - Atualizado registro de keymappings canônicos no motor OPEN//77 (`inventory_toggle` e `radial_menu_hold`).
   - Adicionados comandos `/keybinds` e `/atalhos` (instruções de remapeamento in-game), `/radial` e `/mochila`.
3. [`ls_ui/web/index.html`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/index.html):
   - Adicionadas tags de fechamento `</footer></div></div>` na linha 465, isolando os modais na raiz do viewport.
4. [`ls_ui/web/app.js`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_ui/web/app.js):
   - Adicionado listener de `mousemove` com cálculo trigonométrico de ângulo e deadzone central na Roda Radial.
   - Sincronização de ocultação do Biomonitor HUD ao abrir a mochila.
5. [`ls_loadscreen/web/css/style.css`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_loadscreen/web/css/style.css):
   - Fundo 100% transparente para `body`, `html`, `.media-viewport` e `.vanilla-layer`.
   - `.scene-backdrop` com `mix-blend-mode: screen; pointer-events: none;`.
6. [`ls_loadscreen/web/config.json`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_loadscreen/web/config.json):
   - Gradientes das 5 cenas vanilla convertidos para iluminação neon transparente.
7. [`ls_loadscreen/web/js/app.js`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_loadscreen/web/js/app.js):
   - `defaultConfig` sincronizado com os gradientes transparentes para tolerância a falhas.
8. [`.agents/skills/mistake-proof/SKILL.md`](file:///c:/Games/VICCS_CyberpunkServer/.agents/skills/mistake-proof/SKILL.md) & [`.agent/workflows/mistake_proof_skill.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/workflows/mistake_proof_skill.md):
   - Catalogados `[MP-008]`, `[MP-009]` e `[MP-010]`.
9. [`.agent/memory/active_task.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/memory/active_task.md) & [`.agent/memory/changelog.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/memory/changelog.md):
   - Sincronização de estado concluída no Cortex do agente.

---

## 3. Guia de Verificação In-Game

1. **Testando a Loading Screen:**
   - Ao iniciar o servidor e conectar o cliente, a tela de carregamento exibirá a câmera 3D de Night City (Watson, chuva, viaduto) em tempo real no fundo, com o player de áudio Kiroshi e o botão "Retornar ao Hub" flutuando suavemente sobre a cena.
2. **Testando o Quick Radial Menu:**
   - Segure **CAPSLOCK**: a roda holográfica de 8 setores abre instantaneamente no centro da tela.
   - Mova o cursor em direção aos setores para ver a fatia se iluminar com som holográfico e exibir o item no núcleo. Solte a tecla para equipar ou consumir o item.
   - Digite `/keybinds` no chat para ver a instrução de personalização.
   - Pressione **ESC > Configurações (Settings) > KEY BINDINGS**: remapeie a "Mochila Kiroshi" ou o "Menu Radial Rápido" para a tecla que desejar e teste a reconfiguração.
3. **Testando o Inventário:**
   - Pressione **I** (ou digite `/inv` ou `/mochila`): a interface completa de 40 slots, peso corporal e bancada de crafting abre com animação Kiroshi, permitindo arrastar itens, clicar duas vezes para equipar/consumir e fechar com **ESC** ou **I**.
