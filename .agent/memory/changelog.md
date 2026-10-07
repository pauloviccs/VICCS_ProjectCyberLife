# Changelog

## [2026-10-06] - Auditoria de Paridade Visual de Itens (Log 31) & Poka-Yoke MP-013

### Adicionado
- **58 Novos Ícones Vetoriais SVG Cyberpunk Dedicados (`ls_ui/web/images/`):**
  - Desenvolvidos com padrão diegético Kiroshi Optics: moldura L-brackets, scanlines, paleta neon (`#22d8e2`, `#fcee0a`, `#ff003c`, `#05ffa1`) e fundos chanfrados escuros translúcidos.
  - Cobertura de 15 tipos de vestuário, 14 itens alimentícios/bebidas, 18 colecionáveis/loot e 11 itens de cyberware, blindagem balística e primeiros socorros.
  - Biblioteca visual ampliada de 210 para **268 ativos físicos em disco**.
- **Poka-Yoke Knowledge Base Expandida:**
  - Registrado `[MP-013]` (Paridade Estrita de Catálogos Lua/CEF & Prevenção de Placeholders Visuais Fantasmas) em `.agents/skills/mistake-proof/SKILL.md` e `.agent/workflows/mistake_proof_skill.md`.

### Modificado
- **Catálogo Canônico Compartilhado (`items_catalog.lua` & `catalog.js`):**
  - Reescritas 151 declarações de `image` substituindo `default_item.svg` e `shard.png` por referências diretas e exclusivas aos novos SVGs dedicados.
  - Paridade 1:1 absoluta e atômica estabelecida entre o backend autoritativo Lua e a interface Web CEF.
  - 100% dos 385 itens catalogados agora possuem arte individual e representativa.
- **Auditoria de Integridade Automatizada (`verify_images.py`):**
  - Validada ausência de erros 404 (0 links quebrados).
  - Eliminado 100% do uso de `default_item.svg` (contagem zerada tanto em Lua quanto em JS).

---

## [2026-10-06] - Correções Críticas Urgentes (Log 28) & Poka-Yoke MP-011 a MP-012

### Corrigido
- **Inventário Vazio e Erro Fatal de Export no Servidor (`ls_inventory`):**
  - Eliminado o erro fatal `export ls_core:GetPlayerCharacterId export_not_found` nos logs do servidor.
  - Criada função autoritativa `resolvePlayerLicense(src)` consultando a sessão canônica `exports["ls_core"]:getSession(src).license` e `Open77.players.identifiers(src).license`.
  - Conectado o inventário ao evento canônico de login `ls:core:playerLoaded(playerId, license)`.
  - Adicionado suporte a hot-reload em `onResourceStart` para sincronizar jogadores já conectados.
  - Adicionada permissão `"database.access"` no manifesto `ls_inventory/open77.lua`.
  - Injetado starter kit de sobrevivência (`weapon_unity`, `ammo_handgun`, `burrito_xxl`, `clean_water`, `maxdoc_mk1`, `component_common`, `metal_scrap`) para novos jogadores ou contas vazias.
  - Adicionado cache `cachedInventoryBag` no cliente Lua (`ls_ui/client/main.lua`) para entrega instantânea ao CEF assim que o evento `ls:ui:ready` for emitido, além de solicitar sync sob demanda ao abrir a mochila.
- **Redimensionamento e Responsividade do Inventário (Box Verde) (`ls_ui`):**
  - Substituídas as dimensões fixas de 1150px x 740px (box vermelha) por escala responsiva fluida `width: clamp(1050px, 92vw, 1720px); height: clamp(680px, 88vh, 980px);` (box verde).
  - `.inv-body` ajustado para `flex: 1; height: auto; min-height: 0;`, aproveitando toda a área útil da tela sem sobrepor barras do sistema.
  - Grid de slots redesenhado com `grid-auto-rows: clamp(72px, 8.2vh, 92px); gap: 8px;`, slots maiores, ícones nítidos com drop-shadow vibrante e responsividade impecável em Full HD, 2K, 4K e Ultrawide.

### Adicionado
- **Sistema de Equipar Itens no Quick Radial Menu (`ls_ui` / `ls_inventory`):**
  - Implementado painel de **8 Atalhos Rápidos // Radial Loadout [1] a [8]** no inventário, com indicadores de bússola direcional (`[1] ↑`, `[2] ↗`, `[3] →`, `[4] ↘`, `[5] ↓`, `[6] ↙`, `[7] ←`, `[8] ↖`).
  - Suporte completo a **Drag & Drop** (arrastar itens da mochila para os slots do radial) e **Clique com Botão Direito** em qualquer item para equipar/desequipar instantaneamente.
  - Persistência imediata no `localStorage` (`ls_radial_loadout_slots`).
  - Quick Radial Menu (`CAPSLOCK`) totalmente acoplado ao loadout: valida estoque em tempo real, mostra contagem de itens, alerta visual para itens esgotados e dispara uso/equipamento nativo (`radial:triggerAction`).
- **Poka-Yoke Knowledge Base Expandida:**
  - Registrados `[MP-011]` (Resolução de Identidade de Inventário & Caching de Estado CEF) e `[MP-012]` (Loadout Persistente do Quick Radial Menu & Dimensionamento Responsivo CEF) em `.agents/skills/mistake-proof/SKILL.md` e `.agent/workflows/mistake_proof_skill.md`.

---

## [2026-10-06] - Resolução Forense de Bugs Críticos (Log 27) & Poka-Yoke MP-008 a MP-010

### Corrigido
- **Front-End do Inventário e Quick Radial Menu Invisíveis (`ls_ui`):**
  - Identificada a causa raiz de `#inventory-modal` e `#radial-overlay` não renderizarem: fechamento ausente (`</footer></div></div>`) em `#ripperdoc-modal` na linha 465 de `ls_ui/web/index.html`.
  - Ambos os modais estavam aninhados como elementos-filho de `#ripperdoc-modal`, que possuía a classe `.hidden` (`display: none !important`), causando a supressão de renderização pelo Chromium CEF por herança CSS.
  - Fechamento aplicado, isolando `#inventory-modal` e `#radial-overlay` como elementos root de `<main id="hud-viewport">`.
  - Atualizada a sincronização do Biomonitor HUD em `app.js` (`syncBiomonitorVisibilityWithModals`) para ocultar o Biomonitor ao abrir o inventário.
- **Desacoplamento da Tecla TAB & Quick Radial Reconfigurável in-Game (`ls_inventory`):**
  - Mudada a keybind padrão de `TAB` para `CAPSLOCK` em `ls_inventory/shared/config.lua` e `ls_inventory/client/main.lua`, liberando o `TAB` para o futuro sistema de Scanner/Quickhacking vanilla.
  - Registrados mapeamentos no motor OPEN//77 (`inventory_toggle` e `radial_menu_hold`) via `Open77.input.registerKeyMapping`. Eles aparecem automaticamente nas configurações in-game (**ESC > Settings > KEY BINDINGS**), onde o próprio usuário pode personalizar livremente suas teclas.
  - Criados comandos `/keybinds` e `/atalhos` notificando os jogadores, e comandos `/radial` e `/mochila`.
  - Adicionado cálculo vetorial de ângulo do mouse com deadzone de 45px no overlay do Radial Menu em `ls_ui/web/app.js` para navegação fluida e precisa.
- **Transparência e Exibição das Cutscenes 3D Vanilla na Loading Screen (`ls_loadscreen`):**
  - Removido background sólido `#040810` e gradientes escuros opacos que cobriam o viewport 3D da REDengine.
  - Definidos `html, body { background: transparent !important; }`, `.media-viewport { background: transparent !important; }` e `.scene-backdrop` com `mix-blend-mode: screen; pointer-events: none;`.
  - Gradientes escuros de 98% de opacidade substituídos por iluminação holográfica ambiente transparente (`rgba(..., 0.12) 0%, transparent 65%`) em `config.json` e `app.js`.
  - As cutscenes 3D cinematográficas vanilla do Cyberpunk 2077 agora aparecem 100% nítidas sob o HUD holográfico da loadscreen.

### Adicionado
- **Poka-Yoke Knowledge Base Expandida:**
  - Registrados `[MP-008]` (Modais CEF Aninhados), `[MP-009]` (Oclusão de Cutscene 3D por Fundo Opaco) e `[MP-010]` (Desacoplamento de Keybinds Nativas e Mapeamento Reconfigurável) em `.agents/skills/mistake-proof/SKILL.md` e `.agent/workflows/mistake_proof_skill.md`.

---

## [2026-10-06] - Mistake-Proof Skill (Poka-Yoke Protocol) & Resolução de Falhas Críticas (Logs 25-26)

### Adicionado
- **Poka-Yoke Mistake-Proof Skill (`mistake-proof.skill`):**
  - Criada skill nativa em `.agents/skills/mistake-proof/SKILL.md` e workflow canônico em `.agent/workflows/mistake_proof_skill.md`.
  - Catálogo inicial de 7 soluções definitivas (`[MP-001]` a `[MP-007]`) cobrindo keymappings no OPEN//77, prevenção de `export_yielded`, blindagem contra rollback financeiro, deduplicação de marcadores 3D, polling adaptativo, visibilidade de WebUI e foco de mouse em camadas CEF.

### Corrigido
- **Keybindings "I" (Inventário) e "TAB" (Quick Radial) no `ls_inventory` & `ls_ui`:**
  - Adicionada permissão primordial `"input.actions"` no manifesto `ls_inventory/open77.lua`.
  - Migrado registro de teclas para a spec table nativa do motor OPEN//77 (`Open77.input.registerKeyMapping`), eliminando a assinatura inválida herdada do FiveM.
  - Implementado `page:setFocus(false, true)` no `ls_ui/client/main.lua` para liberar navegação de cursor nas fatias SVG do Quick Menu.
  - Adicionado listener universal de Escape e tecla I no `app.js` da WebUI.
- **Rollback de Dinheiro no `ls_economy` (Currency Bug):**
  - Substituídas chamadas a exports de banco com corrotinas (que quebravam com `export_yielded`) por queries diretas nativas `MySQL.query.await` e `MySQL.update.await`.
  - Blindada a função `loadPlayerAccount`: falhas na consulta SQL (`rows == nil`) nunca concedem `starter_grant` e não sobrescrevem a conta do jogador no MariaDB.
- **Stuttering Próximo a Apartamentos e Megabuilding H10 no `ls_housing`:**
  - Removida a duplicação de anéis 3D no REDengine, centralizando renderização de chão e card diegético no `open77_worldui`.
  - Substituídos loops agressivos de 10ms/15ms por polling adaptativo (500ms ocioso, 100ms quando próximo).
  - Inicialização da WebUI de habitação corrigida para `visible = false`, poupando ciclos de renderização do Chromium Embedded Framework.

---

## [2026-10-03] - Resolução de Incidentes (Logs 20 e 21), Ferramenta open77_coords & Regra Primordial Global

### Adicionado
- **Regra Primordial Canônica Global do Projeto:** Documentação oficial do OPEN//77 (`https://open2077.net/docs`) fixada como fonte de autoridade exclusiva em `AGENTS.md` e diretrizes, proibindo estritamente o uso de APIs ou suposições legadas do FiveM/GTA V.
- **Ferramenta de Telemetria e Coordenadas Espaciais `open77_coords` (Comando `/coords`):**
  - Desenvolvido scanner holográfico Kiroshi em WebUI CEF com cantoneiras cibernéticas, sintetizador Web Audio API e atalho `ESC`.
  - Captura precisa de coordenadas espaciais ($X, Y, Z$), orientação de cabeça e câmera ($ForwardX, ForwardY, ForwardZ, Pitch$), osso Head e Yaw/Heading normalizados.
  - Exportação e cópia em 1-clique para Lua Config Table (`ls_housing/shop`), `vec4`, `vec3`, PolyZone 2D, Open77 Ground Marker Spec, Spawner NPC e JSON.
  - Segurança autoritativa com restrição de acesso por roles (`admin`, `moderator`, `support`) via `Server/acl.jsonc`.

### Corrigido
- **Resolução do Log 20 (Falha de Débito de Saldo e Exports no Banco de Dados):**
  - O módulo `ls_data` não possuía exportações formais das funções de banco de dados (`query`, `update`, `execute`, `transaction`), gerando falhas silenciosas nas operações de aluguel/compra do `ls_economy`.
  - Registrados todos os exports oficiais em `ls_data/server/main.lua`.
  - Adicionados exports autoritativos no `ls_economy` (`removeBank`, `addBank`, `removeCash`, `addCash`, `getBalance`).
  - Implementado fallback automático de cobrança para dinheiro vivo (`Cash`) em `ls_housing/server/apartments.lua` e `furniture.lua`.
- **Eliminação de Crash Fatal no `/coords` (Log 21):**
  - A API nativa em C++ `Open77.character.position()` retorna 3 números float soltos na pilha do Lua (`x, y, z`), e não uma tabela. A atribuição a uma única variável gerava o crash `open77_coords/client/main.lua:37: attempt to index a number value (local 'pos')`.
  - Refatorada a função `captureSpatialSnapshot()` para desempacotar `local px, py, pz = Open77.character.position()` com suporte a 3 números ou tabela, fallback para `Open77.character.state().position`, cálculo de vetor frontal via quaternions e yaw, e sincronização no `coords:ready`.
  - Concedidas as permissões `"webui.system"`, `"network.client"` e `files { "web/**" }` no manifesto `open77_coords/open77.lua`.
- **Correção dos Gatilhos de Residência e Tecla [E] no `ls_housing` (Log 21):**
  - O evento `ls:housing:openDoorTarget` emitido via `open77_interactions` não continha o campo `args.aptId`, trazendo apenas `payload.interactionId`. O script recebia `nil` e nunca enviava `ls:housing:requestInfo` ao servidor.
  - Implementada extração de `aptId` via regex em `args.interactionId` (`housing_door_([%w_]+)`) com fallback para o imóvel mais próximo (`nearbyDoorApt.id`).
  - Substituído o polling de controle legado por escuta contínua da tecla física `[E]` nativa via `Open77.input.isDown("e")` com detecção de transição (edge-triggering).
  - Adicionadas chamadas `page:show()` e `page:setFocus(true, true)` na exibição da WebUI e dependências `open77_worldui` e `open77_interactions` no manifesto.

---

## [2026-10-03] - Resolução de Incidentes (Logs 16, 17 e 18): Estabilização Total de Spawn, CEF, Exports & Permissões

### Corrigido
- **Eliminação de Crash por `export_yielded` no Servidor (Log 18):**
  - Removidos quaisquer pontos de yield (`Wait`) de dentro de `Placement.place` em `ls_core/server/placement.lua`. Exports síncronos no OPEN//77 não podem ceder ticks.
  - Blindada a chamada de `exports["ls_core"]:place` no `ls_spawn/server/main.lua` com `pcall`, garantindo que o descongelamento no servidor (`Open77.players.setFrozen(playerId, false)`) e o envio de `ls:spawn:completed` sejam executados incondicionalmente.
- **Teleporte e Restauração de Controles no Cliente (Log 18):**
  - Migrado o teleporte do cliente de FiveM legado (`SetEntityCoords`) para a API nativa oficial do Cyberpunk 2077 / REDengine (`Open77.travel.teleport`).
  - Restauração explícita de controles locais no cliente (`allowInteraction`, `allowAim`, `allowRunning`, `allowJump`, `allowCrouch`, `allowWeapons`, `freezePosition(false)`).
- **Conformidade de Payload CEF no Seletor de Spawn (Log 17):**
  - Corrigido `page:send("spawn:close", {})` no `ls_spawn/client/main.lua` passando tabela como payload obrigatório, eliminando o descarte silencioso do evento pelo motor CEF.
  - Adicionado timeout de segurança de 1.5s na WebUI (`ls_spawn/web/js/app.js`) para fechamento autônomo do modal em caso de perda ou atraso de pacotes na rede.
- **Reconciliação do Gate de Prontidão da Plataforma (Log 17):**
  - Implementado envio de `open77:session:gameplayReady` a partir do `ls_core/client/main.lua` com watchdog automático para abertura do readiness gate da plataforma.
  - Removido o bloqueio em `open77_appearance/client/main.lua` que impedia o anúncio de gameplay caso ocorresse desvio cosmético não fatal.
- **Ativação e Registro Dinâmico de Blips de Habitação (Log 16):**
  - Blips de apartamentos e imobiliárias registrados dinamicamente via `Open77.map.createPin` sem duplicidade ou sobreposição no mapa.
  - Adição de permissões nativas completas nos manifestos `open77.lua`: `"players.life.read"`, `"players.screen"`, `"players.life.freeze"` no `ls_core` e `"player.travel"`, `"players.screen"` no `ls_spawn`.

---

## [2026-10-03] - Resolução de Incidente (Log 15): Desbloqueio do Checkpoint 04, Correção do ls_housing & Resiliência

### Corrigido
- **Falha de Inicialização do `ls_housing` no Servidor (Causa Raiz do Bloqueio no Checkpoint 04):**
  - No Open77, o ambiente Lua do servidor não possui a função global `require` (restrita à VM do cliente). A linha `local PZ = assert(require('@polyzone'))` em `ls_housing/server/furniture.lua` gerava `attempt to call a nil value (global 'require')` durante o boot.
  - Como a falha ocorria na fila de inicialização de recursos, o Open77 abortava o carregamento dos recursos restantes (`ls_loadscreen`, `ls_spawn`, `open77_appearance`, `open77_shell`, etc.).
  - Sem o `open77_appearance` ativo no servidor, o bootstrap de personagem do cliente ficava aguardando indefinidamente no **Checkpoint 04 ("Prepare your character")**, estagnando em 100% por mais de 125 segundos.
  - **Correção:** Implementada validação puramente matemática em Lua de Raycasting / Winding Number para ponto em polígono (`isPointInPolygon`) no servidor, eliminando a dependência de `require` e `polyzone` no lado do servidor.
- **Objeto `Database` em `ls_housing`:**
  - Adicionado adaptador autoritativo `Database` (`query`, `update`, `execute`) em `ls_housing/server/main.lua` delegando com segurança e fallback para `exports.ls_data` e `Open77.database`.
- **Erro de Tipo Booleano em `ls_economy/server/main.lua:148`:**
  - A query de conta bancária chamava `Open77.database.query` sem validação do tipo de retorno, fazendo com que `#rows` disparasse `attempt to get length of a boolean value`.
  - **Correção:** Implementada consulta assíncrona protegida via `ls_data:query` / `MySQL.query.await` com guarda explícita `type(rows) == "table" and #rows > 0`.
- **Erro de Indexação de Coordenadas em `ls_economy/client/blips.lua:182`:**
  - `Open77.character.position()` retornava valores numéricos diretos em certas fases de conexão, causando `attempt to index a number value (local 'pos')` na checagem `pos.x`.
  - **Correção:** Extração segura e desacoplada que aceita tanto tabelas `{x, y}` quanto valores de retorno múltiplos `px, py`.
- **Resiliência do Cliente no Build Mode (`ls_housing/client/build_mode.lua`):**
  - O carregamento da biblioteca `polyzone` foi encapsulado em `pcall` com suporte a variáveis globais e fallback nativo para a rotina geométrica `isPointInPolygon` caso o recurso não esteja disponível.

---

### Adicionado
- **Módulo `ls_housing` (Fase 5 - 100% Concluída):**
  - **Instanciamento por Routing Buckets:** Isolamento autoritativo de dimensões para apartamentos compartilhados via `exports.ls_core:assignBucket("apartment", ...)` e `Open77.routingBuckets.setPlayer(playerId, bucketId)`. Múltiplos jogadores podem residir no mesmo Megabuilding H10 Apto 0705 sem colisão física ou visual, com reciclagem e liberação automática de buckets.
  - **Build Mode com Movimentação Livre & PolyZone OBB:**
    - Fim da grade rígida: substituição por raycast tridimensional contínuo e rotação Yaw $360^\circ$ livre (`Scroll` ou `Q/E`).
    - Validação de 4 vértices do Oriented Bounding Box (OBB) do móvel contra o `PolyZone` 3D do apartamento em tempo real.
    - Prevenção matemática de atravessamento de paredes e sobreposição indevida com mobílias existentes.
    - Shader holográfico diegético Kiroshi: Verde/Ciano (`#00ff9d`) para posições válidas e Vermelho (`#ff003c`) para colisões.
    - Revalidação autoritativa das coordenadas no servidor antes de gravar no MariaDB.
  - **Catálogo de Imóveis & Mobílias (`shared/config.lua`):**
    - 4 complexos residenciais cadastrados com delimitações PolyZone (`h10_apt_v`, `japantown_loft`, `glen_studio`, `corpo_plaza_suite`).
    - Catálogo diversificado de mobílias com dimensões físicas reais ($W, L, H$), categorias e metadados de interação.
  - **Mobílias Interativas Funcionais:**
    - Cama: sono terapêutico integrado ao `ls_vitals` (regeneração de Energia e alívio de Estresse).
    - Chuveiro: banho sônico desinfetante que restaura Higiene a 100%.
    - Baú / Cofre: armazenamento balístico residencial (`stash`).
  - **Persistência MariaDB (`server/main.lua` via `ls_data`):**
    - Tabelas `ls_player_apartments` (contratos `rent`/`owned`, trancas biométricas, vencimento) e `ls_apartment_furniture` (posições $X, Y, Z$, rotações e JSON de template).
    - Integração de débitos financeiros ACID com `ls_economy` para locação, compra de imóveis e aquisição de mobílias com reembolso de 50% na reciclagem.
  - **Terminal Residencial Holográfico Kiroshi NUI (`ls_housing/web`):**
    - Gestão de contratos, chave biométrica, catálogo de mobília filtrável e acionamento do modo de decoração.

---

## [2026-10-02] - Implementação do Seletor de Spawn (`ls_spawn`) & Pivô da Fase 5 para Movimentação Livre com PolyZone

### Adicionado
- **Módulo de Tela de Spawn (`ls_spawn`):**
  - **Primeiro Spawn Obrigatório:** Novos personagens são direcionados compulsoriamente para o Megabuilding H10 (Watson - Little China) sem exibição de seletor, com notificação de boas-vindas diegética Kiroshi no HUD.
  - **Spawns Subsequentes:** Personagens já iniciados recebem a tela holográfica de seleção com pontos públicos:
    - Megabuilding H10 - Pátio Central (Watson)
    - Megabuilding H8 - Clouds Terrace (Westbrook)
    - Arasaka Corpo Plaza (City Center)
    - Mercado Noturno de Kabuki (Watson)
    - Cherry Blossom Market (Westbrook)
    - City Hall Plaza - The Glen (Heywood)
    - Grand Imperial Mall Plaza (Pacifica)
    - Última Conexão do Biochip (Coordenadas geodésicas persistidas)
  - **Arquivo de Configuração Modular:** `Server/resources/gamemodes/lifesim/ls_spawn/shared/config.lua` permitindo adicionar, editar ou remover locais e ajustar coordenadas geodésicas de forma rápida e segura.
  - **Front-end Holográfico Kiroshi (`ls_spawn/web`):**
    - Visual alinhado ao design code do servidor: cantoneiras táticas L-brackets, recortes em 45°, glassmorphism translúcido (`blur(14px)`), paleta Neon Cyan (`#22d8e2`), Neon Yellow (`#fcee0a`), Neon Magenta e Neon Red.
    - Canvas Radar animado em tempo real com varredura angular, anéis concêntricos e telemetria de coordenadas geodésicas.
    - Síntese de áudio diegético Kiroshi via Web Audio API (ticks ao navegar, bips de seleção e pulso energético no spawn).
    - Navegação completa por teclado (<kbd>↑</kbd> <kbd>↓</kbd> e <kbd>ENTER</kbd>) e mouse.
    - Timer regressivo com auto-spawn preventivo contra AFK (120s).
  - **Persistência Segura (MariaDB + ls_data):**
    - Tabela `ls_player_spawns` com namespace `spawn_state` no `CacheService`.
    - Gravação automática da última posição no `ls:core:playerUnloading`.
  - **Congelamento Seguro:** Bloqueio de locomoção e interação no cliente e servidor durante a seleção para prevenir quedas no mapa ou bugs físicos.
- **Pivô Arquitetural da Fase 5 (`ls_housing`):**
  - Redefinição do modo de decoração residencial para **Movimentação Livre 3D** contínua (raycast de superfície + rotação yaw 360°) em substituição à grade rígida anterior.
  - Especificação matemática detalhada da validação de vértices OBB contra o `PolyZone` do apartamento e colisão inter-mobília com suporte a empilhamento de superfícies (`.agent/context/ls_housing_free_decoration_polyzone_spec.md`).

---

## [2026-10-02] - Conclusão da Fase 4 (Economia, ATMs & Vending), Pivô Holográfico NUI, Nova Loading Screen Nativa & Fix do Log 14

### Adicionado
- **Módulo `ls_economy` (Fase 4 - 100% Concluída):**
  - Implementado sistema monetário de Eurodólares com duplo saldo: carteira em dinheiro vivo (`cash`) e conta bancária digital (`bank`).
  - Transações bancárias com consistência ACID e travamento pessimista `SELECT ... FOR UPDATE` no MariaDB contra condições de corrida e duplicação.
  - Tabela `ls_accounts` (v1) e log de auditoria `ls_transactions` (v1) integrados ao `CacheService` do `ls_data`.
  - Terminal de Autoatendimento ATM Kiosk diegético interativo em WebUI com saques/depósitos rápidos e manuais.
  - Máquinas de Vendas 24/7 (All-Foods Convenience) com catálogo de comidas e bebidas restaurando atributos biológicos do `ls_vitals`.
  - Integração da Estação Cirúrgica Ripperdoc Viktor Vector com instalação de ciberimplantes, cirurgia plástica e compra de farmacêuticos mediante débito bancário.
- **Pivô Holográfico do Front-end NUI (`ls_ui/web`):**
  - Reestruturação visual diegética 1:1 baseada nas 8 referências canônicas (`interface-hud/1.png` a `8.png`).
  - Cantoneiras táticas (L-Brackets) `.hologram-bracket.tl`, `.tr`, `.bl`, `.br` injetadas em todos os modais.
  - Badges de sincronização neural (`.sync-badge` com `.sync-dot` pulsante).
  - Rodapé diegético com status HUD (`.hud-status-line`) e keycaps `<kbd>` (`<kbd>ESC</kbd>`, `<kbd>ENTER</kbd>`).
  - Glassmorphism translúcido `backdrop-filter: blur(16px)` com acentos ciano (`#22D8E2`) e amarelo (`#FCEE0A`).
  - Fórmulas CSS `clamp()` fluidas para perfeita exibição em 1080p, 1440p, 4K e Ultrawide 21:9/32:9.
- **Nova Loading Screen Nativa (`ls_loadscreen`):**
  - Conformidade estrita ao wireframe oficial (`loading-screen-wireframe-reference.png`).
  - Botão Topo-Esquerdo [ RETORNAR AO HUB ] com atalho `ESC` e cancelamento de conexão direto no motor OPEN//77.
  - Media Engine Central com transições suaves (crossfade 1.2s entre cenários de Watson, Corpo Plaza, Japantown, Pacifica e Badlands), com suporte a vídeo local MP4 (`web/media/intro.mp4`) ou YouTube via `web/config.json`.
  - Mecanismo Fail-Safe automático contra tela preta.
  - Widget "PLAYER" holográfico inferior direito: equalizador gráfico neon de 6 bandas, controles de áudio, sintetizador Web Audio API e barra de progresso em tempo real sincronizada via CEF do `open77_shell`.

### Corrigido
- **Erro de Conexão `resource_activation_failed` (Log 14):**
  - Identificada e eliminada chamada à função inexistente do FiveM (`RegisterNUICallback`) em `ls_loadscreen/client/main.lua`.
  - Removido script de cliente FiveM desnecessário da tela de carregamento, adequando o manifesto `ls_loadscreen/open77.lua` à arquitetura OPEN//77 onde a loading screen é instanciada e controlada pelo `open77_shell`.
  - Integrados ouvintes nativos `connection:cancel` e `shell:launcher` diretamente na instância `loadScreenPage` de `open77_shell/client/main.lua`.

---

## [2026-10-02] - Conclusão da Fase 3 (Cyberware & Neural Stability), Persistência de HUD no MariaDB & Suite Administrativa /vitals

### Adicionado
- **Persistência Espacial do Biomonitor HUD (`ls_ui`):**
  - Tabela `ls_ui_settings` criada no MariaDB com chave primária `license`, coluna `data JSON` e chave estrangeira `ON DELETE CASCADE` vinculada a `ls_players`.
  - Cache write-behind do `ls_data` registrado para o namespace `ui_settings`.
  - Manifest `ls_ui/open77.lua` atualizado com dependência `ls_data` e script `server/main.lua`.
  - Sincronização bidirecional de coordenadas X/Y do Biomonitor entre o frontend CEF e o servidor: coordenadas salvas pelo usuário são persistidas no banco e restauradas automaticamente na reconexão.
  - Evento de reset de fábrica (`biomonitor:resetPosition`) implementado.
- **Suite de Comandos Administrativos `/vitals` (`ls_vitals`):**
  - Adicionado comando `/vitals fill [alvo]` (ou `/vitals heal` / `/vitals max`): restauração total de atributos (100% fome, sede, energia, higiene; 0% estresse) e cura ao HP máximo via `Open77.players.setHealth`.
  - Adicionado comando `/vitals drain [alvo]`: dreno instantâneo para 0% para testes de emergência biológica e vinheta de dano.
  - Adicionado comando `/vitals set [alvo] <h> <t> <e> <hy> <s>`: calibração granular.
  - Adicionado comando `/vitals rate <mult>`: ajuste do multiplicador global de decaimento em tempo real.
  - Adicionado comando `/vitals log` e `/vitals help`.
  - Resolução inteligente de alvos (`resolvePlayerTarget`) com suporte a omitido (`me`), aspas (`"jogador"`), ID numérico (`1`), substring/nome parcial (`vic`) e global (`all`/`todos`).
  - Permissão de segurança `acl.read` no manifesto `ls_vitals/open77.lua` restringindo acesso a administradores (`operator`).
- **Módulo `ls_cyberware` (Fase 3):**
  - Catálogo de 20+ implantes cibernéticos distribuídos em 11 slots anatômicos corporais.
  - Motor de estabilidade neural e carga térmica ocular com histerese e limiar de ciberpsicose (< 25%).
  - Farmacêuticos funcionais: neurobloqueadores e spray criogênico operando via exports diegéticos sem comandos de chat.

### Corrigido
- **Crash de Runtime em `ls_cyberware` (Linha 25 - `PlayerId` Nil):**
  - Eliminado loop legado do FiveM `while not NetworkIsPlayerActive(PlayerId()) do` e `Player(GetPlayerServerId(PlayerId()))`.
  - Implementada arquitetura reativa nativa Open77 com **Dual Sync**: `RegisterNetEvent("ls:cyberware:sync")`, observador de State Bags `Open77.state.onChange(nil, "ls.cyberware.v")` e solicitação de sincronização no boot `ls:cyberware:requestSync`.
  - No servidor `ls_cyberware/server/main.lua`, substituídas chamadas legadas `Player(playerId).state:set` por `Open77.state.player(playerId):set` e transmissões de rede em tempo real.
  - Desacoplamento da leitura de estresse dos vitais via export seguro `Open77.exports.call("ls_vitals", "getVitals", playerId)`.
- **Dreno de Sprint em Veículos (`ls_vitals`):**
  - Detecção multicamadas no cliente (`IsPlayerInVehicle`, assentos de motorista/passageiro) e trava de atividade em `driving` (0.85x) no servidor, eliminando o consumo acidental acelerado de hidratação e carga neural.
- **Penalidades Críticas Biológicas a 0% de Hidratação/Nutrição (`ls_vitals`):**
  - Dano periódico à saúde do ped com vinheta visual diegética `#damage-vignette` e alertas sonoros Kiroshi.

---

## [2026-10-02] - Homologação In-Game, Self-Hosting Radmin VPN, Fix de Aparência & Super Admin In-Game

### Adicionado
- **Self-Hosting Radmin VPN:** Servidor integrado para conexões de terceiros via Radmin VPN (`26.102.47.161:11778` UDP / `11779` HTTP).
- **Super Admin In-Game (`Server/acl.jsonc`):** 
  - Vinculado o criador `viccs` (`userId: c03e8ff9-22ce-4c15-ac39-5f435a07f5ba`) com o papel `operator` e permissões master (`*`).
  - Habilitados atalhos `/noclip`, `/fly`, `/god`, `/heal`, `/car`, `/dv`, `/goto`, `/bring`, `/tp`, `/weapons`, `/gun`, `/announce`.
  - Habilitado acesso às interfaces `/admin` (menu lateral) e `/adminfull` (painel em tela cheia).
- **Homologação In-Game da Fase 2:**
  - Confirmado decaimento biológico dinâmico e telemetria funcional do Kiroshi Biomonitor em sessão ao vivo nos Badlands.

### Corrigido
- **Loop de Erro de Aparência (`open77_appearance`):**
  - Resolvida a incompatibilidade entre o snapshot do criador e a captura de gameplay do REDengine quando o personagem veste roupas normais.
  - Ajustada a validação para avaliar apenas opções corporais observáveis (`actual ~= nil`) e aceitar o registro canônico (`settledSnapshot = record.snapshot`, `failed = nil`).
  - Eliminado o alerta repetitivo no chat: `! APPEARANCE Restored appearance does not match its stored options.`.
  - Desbloqueada a publicação de corpo e roupas na rede (`publishBody()`) e anúncio de prontidão (`gameplayReady`).
  - Corrigida a prioridade de carregamento em `Server/server.jsonc` (`"system/*"` no topo da lista).

---

## [2026-10-01] - Conclusão da Fase 2: Biometria, Vitais & HUD Kiroshi + Resolução de Overlap e DX

### Adicionado
- **Módulo `ls_vitals`:**
  - Migração MariaDB v1 para criação da tabela `ls_vitals` com suporte a colunas JSON e chaves relacionais.
  - Motor de decaimento biológico monotônico de 5000ms com histerese de rede em `ls.vitals.v` (> 0.5% ou pulso de 30s).
  - Cálculo de decaimento offline para reentradas de jogadores.
  - Catálogo de consumíveis e evento de rede seguro `ls:vitals:consume`.
- **Módulo `ls_ui` (Kiroshi Biomonitor HUD):**
  - WebUI nativa em resolução 1920x1080 @ 30 FPS na camada `hud` (transparente e sem captura de input de movimento).
  - Design Tokens oficiais REDengine 4 / Cyberpunk 2077: chanfros 45° via `clip-path`, cantoneiras táticas, scanlines CRT e paleta oficial Kiroshi.
  - Sintetizador de áudio diegético 100% offline via Web Audio API.
  - Observador reativo de alta performance integrado ao State Bag `ls.vitals.v`.
- **Tipagens e Linter:**
  - `open77-manifest.d.lua` gerado com todas as diretivas oficiais de recursos OPEN//77.
  - Correção de stubs `open77-server.d.lua` e `open77-client.d.lua` para suporte a `...` varargs em eventos e exports.

### Corrigido
- **HUD Overlap:**
  - Corrigida a diretiva no manifesto `ls_ui/open77.lua` para `web_ui_auto_create false` (eliminando a criação duplicada automática pelo host).
  - Adicionado hook de teardown `page:destroy()` em `onClientResourceStop` em `ls_ui/client/main.lua`.
  - Cache de chunks antigos em `.open77/resource-cache` completamente purgado.
- **Erros de Diagnósticos Lua:**
  - Configurados `.luarc.json` e `.vscode/settings.json` com `diagnostics.ignoredFiles: "Disable"` para manifests `open77.lua`.
  - Assinatura de `Open77.state.onChange` padronizada para 3 parâmetros obrigatórios.

---

## [2026-10-01] - Conclusão da Fase 1: Núcleo do Gamemode, Governança & Persistência Reativa

### Adicionado
- **Módulo `ls_core`:**
  - Máquina de estados de 5 fases (`connected`, `loading`, `loaded`, `rejected`, `dropped`).
  - Gate de prontidão da plataforma e handshake com cliente (`clientReady`).
  - Registro de módulos (`registerModule`) e comandos administrativos (`/ls_goto`, `/ls_bring`, `/ls_status`, `/ls_modules`).
  - Ponto de spawn inicial seguro nos Badlands.
- **Módulo `ls_data`:**
  - Sistema de migrações automáticas em `ls_schema_migrations`.
  - `CacheService` síncrono em memória com flush assíncrono em thread contínua (5 min) e persistência garantida na desconexão.

---

## [2026-10-01] - Estruturação e Conexão com Banco de Dados MariaDB (XAMPP)

### Adicionado
- **Script SQL de Estruturação (`Server/database/setup_database.sql`):** Criado script completo com 8 tabelas InnoDB (`open77_characters`, `open77_player_appearances`, `open77_character_presentation`, `players`, `characters_vitals`, `inventories`, `properties`, `bank_transactions`).
- **Banco de Dados Operacional:** Aplicado no MariaDB 10.4.32 (porta 3306 do XAMPP) criando o esquema `open77_lifesim`.
- **Habilitação da Bridge no `server.jsonc`:** Configurada a chave `"database"` com string de conexão `Server=127.0.0.1;Port=3306;Database=open77_lifesim;User ID=root;Password=;`.
- **Validação de Produção:** Teste de inicialização executado com sucesso acusando `[resource:open77_appearance] database=ready` e `Open77 persistent appearance database ready`.

---

## [2026-10-01] - Instalação do Servidor OPEN//77 e Autenticação Master (Build 2.31.21+op77.121)

### Adicionado
- **Servidor Dedicado OPEN//77:** Extraído e organizado o pacote oficial `open77-server-2.31.21+op77.121-win-x64.zip` na pasta `Server/`.
- **Configuração do Servidor (`Server/server.jsonc`):** Criado com a chave do usuário (`op77_live_svWGISMFenupfaZhE31mGddAGzuTQHE-hP-YnxUZbh0`), configurando portas (UDP 11778, TCP 11779), identidade, `masterServer` e carregamento modular de recursos.
- **Controle de Acesso (`Server/acl.jsonc`):** Configurado arquivo de controle de acesso com perfis `helper`, `moderator` e `operator`.
- **Validação de Inicialização:** Executado teste do servidor comprovando matrícula automática no Master Server, obtenção de Run Lease e carregamento com sucesso de recursos nativos.
