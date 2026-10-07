# Project TODOs

## Fase 0: Fundação, Ambiente e Tooling (100% Concluída)
- [x] Sincronizar documentação técnica oficial OPEN//77 (`.agent/context/documentation.md`).
- [x] Configurar Devkit MCP (`@open2077/mcp`) com 27 ferramentas registradas na IDE.
- [x] Gerar stubs de tipagem Lua 5.4 (`open77-client.d.lua`, `open77-server.d.lua`) e `.luarc.json`.
- [x] Criar skill de desenvolvimento `open2077-dev` e SOP de criação de recursos.
- [x] Resolver divergências técnicas (MariaDB/MySQL InnoDB, `database.access`, `CacheService` in-memory).
- [x] Criar diretrizes de estilo e design system em `.agent/guidelines/` (`code_style.md`, `ui_ux.md`).
- [x] Sincronizar visão geral do projeto (`PROJECT_STATUS.md`) e cortex de memória.
- [x] Extrair, organizar e configurar binários do servidor OPEN//77 (Build `2.31.21+op77.121`).
- [x] Configurar `server.jsonc` com a chave Master oficial e validar via `--check-config`.
- [x] Configurar `acl.jsonc` e scripts de automação (`start_server.bat`, `check_config.bat`).
- [x] Validar inicialização do servidor com matrícula automática no Master Server (Run lease concedido).
- [x] Criar estrutura de banco de dados `open77_lifesim` via `setup_database.sql` (8 tabelas InnoDB).
- [x] Conectar o servidor ao MySQL/MariaDB (XAMPP na porta 3306) com validação de `database=ready`.

## Fase 1: Núcleo, Identidade, Dados e Event Bus (100% Concluída)
- [x] Criar diretório base para o gamemode: `Server/resources/gamemodes/lifesim/`.
- [x] Implementar `ls_core`: tunables globais, validação de identidade (`license`, `userId`, `name`), player session tracking, event bus e comandos administrativos (`/ls_goto`, `/ls_bring`, `/ls_status`, `/ls_modules`).
- [x] Implementar `ls_data`: migrações SQL declarativas (`ls_schema_migrations`, `ls_players`), repositórios SQL e `CacheService` com worker de Write-Behind (5 minutos + disconnect + stop).
- [x] Validar persistência e reconexão de jogadores sem duplicação de perfil.

## Fase 2: Vitais, Fisiologia & HUD Kiroshi Biomonitor (100% Concluída & Refinada)
- [x] Implementar `ls_vitals`: migração v1 no MariaDB (`ls_vitals`), loop autoritativo de decaimento (fome, sede, energia, higiene, estresse) e API de consumo de alimentos/itens (`ls:vitals:consume`).
- [x] Implementar filtro de histerese de rede em `ls.vitals.v` (variação > 0.1% ou batimento a cada 15s) e decaimento offline seguro.
- [x] Implementar `ls_ui`: WebUI nativa em resolução 1920x1080 @ 30 FPS na camada `hud` com paridade visual à REDengine 4.
- [x] Resolver bug de HUD Overlap: `web_ui_auto_create false` no manifesto, `page:destroy()` em `onClientResourceStop` e limpeza de cache `.open77/resource-cache`.
- [x] Integrar ponte de eventos reativa entre `ls_vitals` e `ls_ui` via State Bag `ls.vitals.v` e NetEvent `ls:vitals:sync` (Dual Sync).
- [x] Homologação in-game com clientes ao vivo: decaimento de vitais verificado nos Badlands e conexão via Radmin VPN (`26.102.47.161`).
- [x] Corrigir bug de restauração de opções de aparência em `open77_appearance` (tolerância a omissões de roupas no REDengine e fim do loop de chat).
- [x] Configurar permissões de Super Admin (`operator` com `*`) em `acl.jsonc` para o usuário `viccs`.
- [x] Refinamento Veicular: Detecção multicamadas de veículos no cliente e trava de atividade em `driving` (0.85x) no servidor.
- [x] Penalidades Críticas Biológicas: Dano autoritativo à saúde (`Open77.players.setHealth`) a 0% de hidratação ou nutrição com vinheta vermelha diegética e alertas Kiroshi.
- [x] Comandos Administrativos de Vitais: `/vitals fill [alvo]`, `/vitals drain`, `/vitals set`, `/vitals rate`, `/vitals log` e `/vitals help` com resolução inteligente de alvos (`resolvePlayerTarget`) e segurança ACL `acl.read`.

## Fase 3: Cyberware, Estabilidade Neural & Persistência de UI (100% Concluída & Operacional)
- [x] Implementar `ls_cyberware`: scaffolding do módulo, manifesto `open77.lua` e migração v1 da tabela `ls_cyberware`.
- [x] Implementar catálogo anatômico de 20+ implantes distribuídos em 11 slots anatômicos corporais com custo neural e térmico.
- [x] Implementar equação contínua de Estabilidade Neural e Carga Térmica Ocular.
- [x] Implementar limiar de Ciberpsicose (< 25% de estabilidade) com supressores sinápticos e avisos diegéticos Kiroshi.
- [x] Implementar farmacêuticos funcionais: neurobloqueadores (`neuroblocker_booster`) e spray criogênico (`cryo_spray`) operando via exports diegéticos.
- [x] Correção de Crash de Runtime: Removidas chamadas legadas do FiveM `PlayerId()` e `NetworkIsPlayerActive()`, adotando arquitetura reativa Dual Sync nativa Open77 (`RegisterNetEvent("ls:cyberware:sync")` e `Open77.state.onChange`).
- [x] Modernização de Servidor: Substituídas chamadas `Player(playerId).state:set` por `Open77.state.player(playerId):set`.
- [x] Persistência Espacial do Biomonitor HUD: Criação da tabela `ls_ui_settings` no MariaDB, ativação do script de servidor e dependência `ls_data` em `ls_ui/open77.lua`, e sincronização bidirecional completa entre CEF e banco na reconexão do jogador.

## Fase 4: Economia, Carteira, Banco, Terminais, Vending & UI/Loadscreen (100% Concluída & Operacional)
- [x] Implementar `ls_economy`: carteira física em dinheiro vivo (`cash`) e conta bancária digital (`bank`) com transações ACID (`SELECT ... FOR UPDATE` no MariaDB).
- [x] Implementar Terminal ATM de Autoatendimento diegético em WebUI com saques/depósitos rápidos e manuais.
- [x] Implementar Máquinas de Vendas 24/7 (All-Foods Convenience) com itens consumíveis e recuperação integrada aos vitais do `ls_vitals`.
- [x] Integrar Estação Cirúrgica Ripperdoc Viktor Vector com instalação de implantes e farmacêuticos com débito bancário do jogador.
- [x] **Pivô Holográfico NUI (`ls_ui/web`):** L-Brackets táticos nos 4 cantos, badges de sincronização neural (`.sync-badge`), rodapé diegético com keycaps `<kbd>`, glassmorphism translúcido `blur(16px)` e fórmulas CSS `clamp()` para suporte pleno a 1080p, 1440p, 4K e Ultrawide 21:9/32:9.
- [x] **Nova Loading Screen Nativa (`ls_loadscreen`):** Wireframe-match 1:1, botão [ RETORNAR AO HUB ] com atalho `ESC` e desconexão nativa, Media Engine multi-modo (Vanilla, MP4 local, YouTube), widget "PLAYER" holográfico com equalizador neon, sintetizador Web Audio API e barra de progresso em tempo real sincronizada via CEF do `open77_shell`.
- [x] **Correção do Log 14 (`resource_activation_failed`):** Remoção de chamada FiveM incompatível (`RegisterNUICallback`) e conexão direta ao `open77_shell`.

## Gateway Pré-Fase 5: Módulo de Spawn (`ls_spawn`) (100% Concluído & Validado)
- [x] Implementar `ls_spawn`: manifesto `open77.lua`, dependências `ls_core` e `ls_data`, e permissões `players.controls` / `players.life.freeze`.
- [x] Configuração modular em `shared/config.lua`: parametrização de fácil acesso para primeiro spawn e lista de locais públicos (Megabuildings, Praças, Metrópoles e Última Posição).
- [x] Primeiro Spawn Obrigatório no Megabuilding H10 sem menu para novos personagens.
- [x] Tela de seleção Kiroshi Holographic para personagens existentes com Canvas Radar em tempo real, navegação por teclado e áudio diegético Web Audio API.
- [x] Persistência de estado de spawn e última posição conhecida no MariaDB (`ls_player_spawns`) via `ls_data`.
- [x] Congelamento seguro de locomoção e interação no cliente e servidor durante a escolha de spawn.

## Fase 5: Habitação Vertical, Buckets e Build Mode Livre com PolyZone (100% Concluída & Validada)
- [x] **Pivô Arquitetural do Build Mode:** Redefinição do modo de decoração residencial para **Movimentação Livre 3D** contínua (raycast de superfície + rotação yaw 360°) em substituição à grade rígida anterior.
- [x] **Motor de Prevenção de Colisões PolyZone:** Especificação detalhada da validação de vértices OBB contra o `PolyZone` do apartamento e colisão inter-mobília com suporte a empilhamento de superfícies (`.agent/context/ls_housing_free_decoration_polyzone_spec.md`).
- [x] **Scaffolding e Manifesto `ls_housing/open77.lua`:** Vínculo com `polyzone`, `ls_core` e `ls_data`.
- [x] **Migrações e Persistência MariaDB:** Tabelas `ls_player_apartments` e `ls_apartment_furniture` criadas com suporte a contratos (`rent`/`owned`), trancas e posições $(X, Y, Z, \text{heading})$.
- [x] **Instanciamento por Routing Buckets:** Isolamento de dimensões para apartamentos compartilhados via `exports.ls_core:assignBucket` e `Open77.routingBuckets.setPlayer`, com limpeza automática ao desocupar.
- [x] **Build Mode com Colisão PolyZone OBB:** Movimentação livre contínua, rotação yaw $360^\circ$ e teste dos 4 vértices do Oriented Bounding Box a cada frame com shader holográfico (Ciano/Verde vs Vermelho).
- [x] **Mobílias Interativas Funcionais:** Cama (regeneração de Energia/alívio de Estresse em `ls_vitals`), Chuveiro (restauração de Higiene a 100%) e Baú residencial (stash).
- [x] **Terminal Residencial Holográfico Kiroshi NUI (`web/`):** Visão geral de contratos, compra/aluguel integrado ao `ls_economy` e catálogo de mobília com filtros e preços.
- [x] **Resolução do Log 20 (Débito de Moeda e Banco de Dados):** Exportações formais no `ls_data` (`query`, `update`, `execute`, `transaction`) e exports autoritativos no `ls_economy` com fallback automático de débito para dinheiro vivo (Cash).
- [x] **Ferramenta de Telemetria e Coordenadas (`open77_coords`):** Interface Kiroshi Spatial Scanner com comando `/coords` autoritativo para roles `admin`, `moderator`, `support` e exportação multidimensional.
- [x] **Resolução do Log 21 (Crash `/coords` e Gatilho [E] no Housing):** Desempacotamento de vetores numéricos múltiplos de `Open77.character.position()` em C++, extração regex de `aptId` via `interactionId` do `open77_worldui`, detecção de tecla [E] nativa via `Open77.input.isDown("e")` e sincronização de visibilidade CEF com `page:show()`.
- [x] **Poka-Yoke Protocol & Mistake-Proof Skill (`mistake-proof.skill`):** Criação da workspace skill `.agents/skills/mistake-proof/SKILL.md` e SOP `.agent/workflows/mistake_proof_skill.md` com 7 padrões comprovados para prevenção perpétua de regressões.
- [x] **Estabilização de Inventário, Quick Radial & Moeda (Logs 25-26):** Permissão `input.actions` no `ls_inventory`, spec table nativa do OPEN//77 para teclas "I" e "TAB", foco de mouse no CEF radial, eliminação do erro `export_yielded` no `ls_economy` com queries diretas `MySQL.*.await` e proteção de persistência de conta sem rollback.
- [x] **Otimização de Performance Espacial no Housing (Log 26):** Deduplicação de anéis 3D no REDengine, eliminação de loops frênicos de 10ms/15ms com polling adaptativo e WebUI de moradia criada com `visible = false`.

## Fase 5.5: Inventário, Crafting, Itens Canônicos & Quick Radial Loadout (100% Concluída & Validada)
- [x] **Persistência Relacional de Inventário (`ls_inventory`):** Esquema relacional no MariaDB (`ls_inventories` e `ls_inventory_items`) com integridade referencial `ON DELETE CASCADE`, limites estritos de 40 slots e 35.000g (35kg).
- [x] **Resolução Canônica de Identidade (Log 28):** Substituição do método inexistente `GetPlayerCharacterId` pela função autoritativa `resolvePlayerLicense(src)` via `exports["ls_core"]:getSession(src).license`, listener do evento canônico `ls:core:playerLoaded` e suporte a hot-reload em `onResourceStart`.
- [x] **Starter Kit de Sobrevivência:** Injeção automática de kit inicial (`weapon_unity`, `ammo_handgun`, `burrito_xxl`, `clean_water`, `maxdoc_mk1`, `component_common`, `metal_scrap`) para novos jogadores ou contas vazias.
- [x] **Eliminação de Perda de Pacotes no Cliente CEF:** Criação de `cachedInventoryBag` no cliente Lua (`ls_ui`), garantindo entrega íntegra da mochila após `ls:ui:ready` e sync sob demanda ao abrir a mochila.
- [x] **Catálogo Canônico de Itens (`items_catalog.lua`):** Mais de 40 itens cadastrados com identificadores canônicos, descrições ricas, raridades, pesos em gramas, categorias e integração diegética de consumo com vitais e equipamento de armas no REDengine 4.
- [x] **Bancada de Manufatura e Crafting:** Catálogo declarativo de receitas (`recipes.lua`), validação atômica de insumos no servidor e barra de progresso holográfica no HUD CEF.
- [x] **Sistema de Loadout do Quick Radial Menu (8 Slots Direcionais):** Painel diegético de 8 atalhos na base da mochila (`[1] ↑` a `[8] ↖`), suporte completo a Drag & Drop e Clique com Botão Direito, persistência no `localStorage` (`ls_radial_loadout_slots`) e Roda Radial SVG (`CAPSLOCK`) sincronizada em tempo real com validação de estoque e disparo nativo de ações.
- [x] **Redimensionamento Responsivo (Box Verde Aprovada):** Substituição da moldura rígida de 1150px x 740px (box vermelha) por dimensionamento fluido com `width: clamp(1050px, 92vw, 1720px); height: clamp(680px, 88vh, 980px);` e grid adaptável para 1080p, 1440p, 4K e Ultrawide 21:9/32:9.
- [x] **Desacoplamento de Keybinds Nativas e Reconfiguração in-Game:** Migração de `TAB` para `CAPSLOCK`, registro de keymappings no menu Pause nativo do jogo e comandos `/keybinds`, `/atalhos`, `/mochila`, `/inv` e `/radial`.
- [x] **Transparência de Loading Screen:** Eliminação de fundos escuros sólidos, tornando as cutscenes 3D vanilla visíveis sob o HUD durante o carregamento.

## Fase 6: Carreiras e Facções
- [ ] Implementar `ls_jobs`: carreiras corporativas, serviços de entrega, turnos e progressão salarial.
- [ ] Implementar `ls_factions`: reputação de gangues, contratos de Fixers, rádio policial NCPD e Trauma Team.

## Fase 7: Sistema Médico & Trauma Team Aéreo
- [ ] Implementar `ls_medical`: resgate aéreo Trauma Team Platinum via aerodino (AV), extração de feridos e tratamento em UTI.

## Fase 8: Interações Sociais & Rede Urbana
- [ ] Implementar `ls_social`: rede social in-game Kiroshi Net, reputação urbana e agenda de contatos.

## Fase 9: Auditoria, Polish e Release Candidate
- [ ] Auditoria final de performance, stress test de concorrência no MariaDB e empacotamento de produção.
