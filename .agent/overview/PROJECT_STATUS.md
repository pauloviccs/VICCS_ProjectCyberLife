# Project Overview

## Project Name
OPEN//77: Night City Life-Sim RP (VICCS Cyberpunk Server) - Release v0.0.5

## Description
Servidor dedicado multijogador para Cyberpunk 2077 (v2.31 / Phantom Liberty, Build oficial 2.31.21+op77.124, Protocolo 1.44) focado em simulação social e biológica profunda (*Life-Sim RP*), transpondo a complexidade comportamental de The Sims para a distopia urbana de Night City. O ecossistema opera sobre arquitetura modular com separação estrita de responsabilidades, governança centralizada no Core (`ls_core`), persistência direta e resiliente no MariaDB (InnoDB com chaves estrangeiras, transações ACID e colunas JSON), decaimento biológico monotônico com histerese em State Bags (`ls_vitals`), penalidades orgânicas severas a 0% de hidratação/nutrição, telemetria de ciberimplantes com motor térmico e estabilidade neural (`ls_cyberware`), economia bivalente com Eurodólares Cash/Bank e travas pessimistas `SELECT ... FOR UPDATE` (`ls_economy`), terminais ATM, máquinas de conveniência 24/7 e clínica cirúrgica Ripperdoc Viktor Vector operacionais, habitação vertical instanciada por Routing Buckets com portas dinâmicas, interior canônico de V no Megabuilding H10 calibrado contra quedas no vazio, anel holográfico WorldUI, Build Mode livre em 360° com detecção de colisões OBB via PolyZone 3D (`ls_housing`), sistema de inventário e manufatura autoritativo com pesos/slots (`ls_inventory`), catálogo canônico ampliado com 385 itens e acervo visual com 268 ícones canônicos e vetores SVG Cyberpunk dedicados (58 novos vetores criados, 0 placeholders, 100% dos 385 itens com imagem própria) em `ls_ui/web/images/`, Quick Radial Menu com 8 setores angulares holográficos acoplados ao painel de Loadout Tático configurável via Drag & Drop / clique direito com persistência em `localStorage`, dimensionamento responsivo fluido (`clamp(1050px, 92vw, 1720px)`) cobrindo harmoniosamente o viewport conforme a Box Verde aprovada, seletor de despertar neural diegético Kiroshi (`ls_spawn`) com primeiro spawn obrigatório no Megabuilding H10 em Watson e radar holográfico geodésico, ferramenta de telemetria espacial autoritativa (`open77_coords`) com captura em tempo real de vetores REDengine 4, interface NUI diegética em WebUI nativa com pivô holográfico Kiroshi (L-brackets táticos, isolamento estrito de `pointer-events: none` em camadas passivas, glassmorphism `blur(16px)` e responsividade fluida), tela de carregamento nativa modular transparente (`ls_loadscreen`) permitindo a visualização das cutscenes 3D cinematográficas vanilla do Cyberpunk 2077, catálogo de blindagem Poka-Yoke (`mistake-proof.skill` com 13 padrões [MP-001] a [MP-013]), conectividade via VPN Radmin de baixa latência (`26.102.47.161`), ferramentas de administração remota RCON CLI, 35 recursos de sistema oficiais OPEN//77 integrados, 10 módulos customizados Life-Sim e controle de acesso criptográfico ACL (`operator`, `admin`, `moderator`, `support`, `helper`).

## Tech Stack
- Languages: Lua 5.4 (Server & Client Resources em VMs isoladas), JavaScript ES6+ / TypeScript, HTML5 / CSS3 (CSS Variables, Clip-Path Polygons, Web Audio API), SQL (MariaDB 10.4+ / MySQL 8 com InnoDB, JSON e transações ACID), Python 3.12 (Auditoria automatizada de paridade, processamento de texto e geração de assets vetoriais SVG)
- Frameworks: OPEN//77 Dedicated Server Host (.NET 8 Runtime, Build 2.31.21+op77.124, Protocolo 1.44), WebUI CEF / Ultralight HUD Engine
- Tools: `@open2077/mcp` (OPEN//77 Devkit MCP Server com 27 ferramentas), Node.js v22+, Lua Language Server (`.luarc.json` + `.vscode/settings.json`), HeidiSQL / XAMPP MariaDB CLI, PowerShell 7+, RCON CLI Tool (`Server/tools/rcon/`)
- Services: OPEN//77 Dedicated Host (.NET 8 UDP 11778, HTTP 11779, Warden 11780), MariaDB Database Server (`open77_lifesim`), Open77 Master Server Licensing, `CacheService` Lua (Write-Behind in-memory com flush a cada 5m/disconnect/stop), Radmin VPN Mesh Network (`26.102.47.161`)

## Folder Structure
- ```text
c:/Games/VICCS_CyberpunkServer/
├── .agent/                             # Cérebro de Contexto & Memória do Agente (Master Cortex)
│   ├── artifacts/                      # Especificações técnicas, relatórios e diagnósticos forenses
│   │   ├── alt_target_and_world_blips_integration_report.md
│   │   ├── appearance_restore_mismatch_fix.md
│   │   ├── character_connection_stall_investigation_and_fix.md
│   │   ├── coords_tool_and_currency_fix_spec.md
│   │   ├── cyberpunk_native_ui_design_spec.md
│   │   ├── database_setup_report.md
│   │   ├── diagnostic_and_fix_report.md
│   │   ├── diagnostic_log21_coords_and_housing_fix.md
│   │   ├── housing_markers_log19_diagnostic_spec.md
│   │   ├── housing_overlap_and_coords_architecture_spec.md
│   │   ├── incident_diagnosis_report.md
│   │   ├── inventory_and_radial_urgent_fixes_report.md # Relatório de resolução crítica dos 3 bugs (Log 28)
│   │   ├── inventory_crafting_radial_spec.md
│   │   ├── lifesim_master_implementation_plan.md
│   │   ├── lifesim_phase2_report.md
│   │   ├── lifesim_phase4_economy_delivery_report.md
│   │   ├── lifesim_phase4_economy_spec_and_plan.md
│   │   ├── opx77_framework_lessons_report.md
│   │   ├── project_overview_and_docs_sync_report.md
│   │   ├── project_sync_report.md
│   │   ├── self_hosting_options_guide.md
│   │   ├── server_installation_report.md
│   │   ├── server_testing_guide.md
│   │   ├── spawn_and_modal_freeze_fix_report.md
│   │   ├── sync_open77_documentation_context_report.md
│   │   ├── sync_project_overview_report.md
│   │   ├── third_party_connection_failure_report.md
│   │   ├── urgent_fixes_report.md
│   │   ├── vitals_freeze_investigation_and_fix.md
│   │   └── world_map_blips_and_gps_fix_report.md
│   ├── assets/                         # Referências visuais e wireframes de design
│   │   └── references/
│   │       ├── gemini/                 # Imagens geradas e referências conceituais
│   │       ├── mp4/                    # Capturas de vídeo do inventário e HUD
│   │       │   ├── inventory.mp4
│   │       │   └── inventory_conv_1080p_lowbitrate.mp4
│   │       ├── png/
│   │       │   ├── interface-hud/      # 8 referências canônicas do HUD diegético Kiroshi
│   │       │   └── loading-screen/     # Wireframe oficial da Loading Screen
│   │       ├── psb/                    # Wireframes mestres em Photoshop Big
│   │       │   └── Wireframes.psb
│   │       └── pureref/                # Moodboards de direção de arte (0.pur)
│   ├── context/                        # Documentação profunda de arquitetura, banco e regras
│   │   ├── LIFESIM_CORE_CONTEXT_FRAMEWORK.md   # Marco arquitetural absoluto do Life-Sim RP
│   │   ├── OPEN77_CORE_AGENT_CONTEXT_FRAMEWORK.md # Princípios de governança do Open77
│   │   ├── OPX77_FRAMEWORK_ANALYSIS_AND_LESSONS.md # Análise forense de engenharia e lições aprendidas
│   │   ├── architecture.md             # Arquitetura, princípios e mapa de resources
│   │   ├── contexto_de_desenvolvimento_resource_open_77.md # Diretrizes de development workflow
│   │   ├── database_schema.md          # Esquemas MariaDB InnoDB e CacheService Lua
│   │   ├── documentation.md            # Documentação técnica oficial OPEN//77 compilada
│   │   ├── documento_de_design_magia_e_bruxaria_em_cyberpunk_2077_open77_rp.md # GDD complementar
│   │   ├── lifesim_master_implementation_plan.md # Plano mestre de implementação (Fases 1 a 9)
│   │   ├── ls_housing_free_decoration_polyzone_spec.md # Especificação técnica do Housing OBB
│   │   ├── mcp_install.md              # Documentação de setup do devkit MCP
│   │   └── stack.md                    # Detalhamento de stack e dependências reais
│   ├── guidelines/                     # Design systems e guias de codificação
│   │   ├── CYBERPUNK_NATIVE_UI_DESIGN_SPEC.md  # Especificação técnica do Design System Kiroshi
│   │   ├── code_style.md               # Diretrizes de estilo de código Lua 5.4 e NUI
│   │   ├── guia-direcao-arte-uiux-contexto.md  # Guia master de direção de arte e UX
│   │   └── ui_ux.md                    # Tokens visuais Kiroshi e regras de UX nativa
│   ├── indexes/                        # Guias e índices de desenvolvedor
│   │   └── open77_tecno_ocultismo_codex_developer_guide.html
│   ├── memory/                         # Cortex de memória operacional
│   │   ├── active_task.md              # Estado da tarefa atual em execução
│   │   ├── changelog.md                # Histórico de entregas e versões (v0.0.1 a v0.0.5)
│   │   └── todos.md                    # Backlog priorizado de tarefas (9 Fases)
│   ├── notebook-lm/                    # Mídia e material de suporte do projeto
│   │   └── OPEN_77_Life-Sim.mp4
│   ├── open77-changelogs-alpha/        # Changelogs oficiais do motor OPEN//77
│   │   ├── build.124.txt               # Changelog oficial Build .124 (Protocolo 1.44)
│   │   └── unstable.123.txt            # Changelog Build .123
│   ├── overview/                       # Sincronização executiva do estado do projeto
│   │   └── PROJECT_STATUS.md           # Visão geral de status sincronizada (este arquivo)
│   └── workflows/
│       ├── mistake_proof_skill.md      # SOP de Poka-Yoke e catálogo de 13 soluções definitivas ([MP-001] a [MP-013])
│       └── open2077_dev_skill.md       # SOP de desenvolvimento de recursos Open77
├── .agents/                            # Customizações locais do workspace (Antigravity)
│   ├── rules/
│   │   └── open2077_docs_primordial_rule.md # Regra de ouro da documentação oficial Open77
│   └── skills/
│       ├── mistake-proof/
│       │   └── SKILL.md                # Skill nativa de Poka-Yoke com catálogo [MP-001] a [MP-013]
│       └── open2077-dev/
│           └── SKILL.md                # Skill nativa do workspace para OPEN//77
├── .vscode/
│   └── settings.json                   # Configuração de IDE, associações e bibliotecas de tipagem
├── .luarc.json                         # Configuração mestre raiz do Lua Language Server
├── AGENTS.md                           # Regras Primordiais do Projeto (Documentação Oficial https://open2077.net/docs)
├── GDD_Website/                        # Website do Game Design Document (GDD)
│   ├── .agent/                         # Cortex isolado do portal GDD
│   └── project_cp2077_lifesim.html     # Dashboard executivo interativo do GDD (Tailwind + Chart.js)
├── Main_Website/                       # Portal e Website oficial do servidor
│   ├── .agent/                         # Cortex isolado do portal principal
│   └── README.md                       # Documentação do portal
└── Server/                             # Servidor Dedicado OPEN//77 (Build 2.31.21+op77.124)
    ├── .agent/                         # Espelho local do cortex e diagnósticos forenses
    │   ├── logs/                       # Bundles de diagnóstico e incidentes (Logs 0 a 31)
    │   ├── overview/
    │   │   └── PROJECT_STATUS.md       # Cópia espelhada da visão geral
    │   ├── scratch/                    # Scripts de validação e sondagem forense (verify_images.py)
    │   └── server-commands/
    │       └── Comandos.txt            # Documentação in-game dos comandos administrativos /vitals, /money e /coords
    ├── .luarc.json                     # Configuração espelhada de diagnósticos Lua
    ├── acl.jsonc                       # Controle de acesso e permissões (Owner viccs, roles operator, admin, moderator, helper)
    ├── database/
    │   └── setup_database.sql          # Esquema MariaDB completo (13 tabelas InnoDB com integridade referencial)
    ├── open77-client.d.lua             # Tipagens nativas do runtime do cliente (varargs e exports)
    ├── open77-manifest.d.lua           # Stubs de declaração para manifestos OPEN//77
    ├── open77-server.d.lua             # Tipagens nativas do runtime do servidor (varargs e exports)
    ├── open77-server-2.31.21+op77.124-win-x64.zip # Pacote oficial dos binários do host
    ├── package-manifest.json           # Manifesto oficial da build 2.31.21+op77.124
    ├── resources/                      # Catálogo de recursos do servidor (51 resources ativos com open77.lua)
    │   ├── gamemodes/
    │   │   ├── freeroam/               # Gamemode freeroam nativo de demonstração
    │   │   ├── lifesim/                # Gamemode customizado VICCS Life-Sim RP (10 módulos + _shared)
    │   │   │   ├── _shared/            # Módulos puros compartilhados (ls_shared.lua)
    │   │   │   ├── ls_core/            # [FASE 1 - 100%] Sessão, Readiness Gate, Placement & Registry
    │   │   │   ├── ls_data/            # [FASE 1 - 100%] Persistência MariaDB InnoDB & CacheService
    │   │   │   ├── ls_vitals/          # [FASE 2 - 100%] Motor de Fisiologia, Penalidades & Admin Suite
    │   │   │   ├── ls_cyberware/       # [FASE 3 - 100%] Implantes, Estabilidade Neural & Ciberpsicose
    │   │   │   ├── ls_economy/         # [FASE 4 - 100%] Carteira Cash, Conta Bancária ACID, ATMs e Vending
    │   │   │   ├── ls_housing/         # [FASE 5 - 100%] Habitação Vertical, Routing Buckets & Build Mode OBB
    │   │   │   ├── ls_inventory/       # [FASE 5.5 - 100%] Inventário, Crafting, 385 Itens Canônicos & Quick Radial Loadout
    │   │   │   │   ├── client/         # Client controller e sincronização com HUD
    │   │   │   │   ├── server/         # Database Adapter resiliente, pesos, starter kit e rotinas atômicas
    │   │   │   │   └── shared/         # config.lua, crafting_recipes.lua e items_catalog.lua (385 itens)
    │   │   │   ├── ls_spawn/           # [GATEWAY - 100%] Seletor Holográfico de Despertar & Spawn H10 Blindado
    │   │   │   ├── ls_loadscreen/      # [NOVO - 100%] Loading Screen Nativa Diegética Wireframe-Match com Cutscenes 3D
    │   │   │   ├── ls_ui/              # [REWORK HOLOGRÁFICO - 100%] NUI Diegética Kiroshi HUD Multi-Resolução (Box Verde)
    │   │   │   │   └── web/
    │   │   │   │       ├── app.css     # Design system, layout responsivo e HUD Tokens
    │   │   │   │       ├── app.js      # Controlador NUI CEF, reatividade e catálogos
    │   │   │   │       ├── catalog.js  # Catálogo espelho frontend com 385 itens canônicos
    │   │   │   │       ├── index.html  # Modais diegéticos Kiroshi
    │   │   │   │       └── images/     # Biblioteca de 268 ícones canônicos e vetores SVG Cyberpunk dedicados (zero placeholders)
    │   │   │   └── scripts/            # Automação de criação e sincronização (new-module, sync-shared)
    │   │   ├── open77_cyberware_lab/   # Gamemode experimental de laboratório de cyberware
    │   │   └── open77_freeroam/        # Gamemode freeroam alternativo
    │   ├── open77_equipment/           # Gestão de equipamentos
    │   ├── open77_wardrobe/            # Guarda-roupa persistente
    │   ├── polyzone/                   # Delimitação de zonas tridimensionais (integração housing)
    │   ├── viccs/                      # Recursos customizados da comunidade VICCS
    │   └── system/                     # 35 recursos oficiais do sistema OPEN//77
    │       ├── open-voice/             # Chat por voz nativo WebRTC / Proximity
    │       ├── open77_admin/           # Painéis administrativos /admin e /adminfull
    │       ├── open77_animations/      # Emotes e animações REDengine
    │       ├── open77_appearance/      # Customização de personagem e trajes
    │       ├── open77_blips/           # Gerenciamento de marcadores no minimapa
    │       ├── open77_chat/            # Chat diegético multi-canal
    │       ├── open77_contextmenu/     # Menu contextual de interação
    │       ├── open77_coords/          # Ferramenta autoritativa Kiroshi Spatial Scanner (/coords)
    │       ├── open77_cyberware/       # Suporte base do sistema a implantes
    │       ├── open77_dash/            # Mecânicas de esquiva e mobilidade
    │       ├── open77_death/           # Pipeline de morte e ragdoll
    │       ├── open77_doors/           # Controle de portas estáticas e interativas
    │       ├── open77_effects/         # Efeitos audiovisuais diegéticos
    │       ├── open77_elevators/       # Elevadores de Megabuildings operacionais
    │       ├── open77_interactions/    # Gatilhos de interação com o mundo
    │       ├── open77_media/           # Reprodução de mídia e streaming
    │       ├── open77_nameplates/      # Identificadores holográficos de jogadores
    │       ├── open77_notifications/   # Notificações holográficas estilo Kiroshi
    │       ├── open77_pause/           # Menu de pausa e desconexão
    │       ├── open77_perspective/     # Câmeras de primeira e terceira pessoa
    │       ├── open77_player_interactions/ # Interações interpessoais entre jogadores
    │       ├── open77_prediction/      # Reconciliação preditiva de rede
    │       ├── open77_prevention/      # Sistema de polícia e mandados de prisão
    │       ├── open77_props/           # Instanciação autoritativa de objetos
    │       ├── open77_reflex/          # Modificadores de combate e reações
    │       ├── open77_remote_camera/   # Câmeras de segurança e vigilância urbana
    │       ├── open77_shell/           # Gateway do cliente, CEF bridge e lobby
    │       ├── open77_vehicles/        # Sincronização, spawn e assentos de veículos
    │       ├── open77_voice/           # Rádio e voz diegética
    │       ├── open77_wardrobe_ui/     # Interface visual de troca de roupas
    │       ├── open77_watermark/       # Marca d'água oficial OPEN//77
    │       ├── open77_weapons/         # Gestão balística e inventário de armas
    │       ├── open77_weather/         # Ciclo de tempo dinâmico e clima de Night City
    │       ├── open77_worldui/         # Renderização de texto e ícones 3D no mundo
    │       └── open77_zones/           # Zonas seguras e restritas da cidade
    ├── tools/
    │   └── rcon/                       # Cliente RCON Node.js para administração remota
    ├── server.jsonc                    # Configuração autoritativa do servidor, rede Radmin e licença Master
    ├── Start.cmd                       # Script de inicialização oficial do servidor dedicado
    └── start_server.bat                # Script de execução rápida para Windows
```

## Current Features Implemented
- **Regra Primordial Canônica Global do Projeto:**
  - Imposição da documentação oficial do OPEN//77 (`https://open2077.net/docs`) como fonte primária e inegociável da verdade.
  - Banimento terminante de alucinações de APIs FiveM/RedM/GTA V (`PlayerPedId`, `GetEntityCoords`, `RegisterNUICallback`, `IsControlJustPressed(0, 38)`, etc.).
  - Registro formal da regra em `AGENTS.md`, `.agent/guidelines/code_style.md` e `.agents/rules/open2077_docs_primordial_rule.md`.
- **Servidor Dedicado OPEN//77 Totalmente Operacional (Release v0.0.5):**
  - Build oficial `2.31.21+op77.124` configurado e validado no .NET 8 Runtime (Protocolo 1.44).
  - Licença Master válida (`op77_live_...`) com Run lease concedido pelo Master Server.
  - Conectividade de rede híbrida validada via Radmin VPN (`26.102.47.161:11778` UDP e `http://26.102.47.161:11779/` HTTP de download de recursos).
  - Homologado com sucesso com conexões de jogadores remotos simultâneos.
- **Módulo de Inventário & Crafting Completo (`ls_inventory` - Fase 5.5 - 100% Concluída):**
  - **Arquitetura Autoritativa de Armazenamento:**
    - Esquema relacional no MariaDB (`ls_inventories` e `ls_inventory_items`) com integridade referencial `ON DELETE CASCADE`.
    - Controle rígido de peso máximo em gramas (padrão: 35.000g / 35kg) e limite de 40 slots por personagem.
    - Suporte nativo para múltiplos donos (`owner_type = 'character'`, `'apartment'`, `'vehicle_trunk'`, `'glovebox'`).
    - Resolução de identidade canônica vinculada à `license` do jogador via `exports["ls_core"]:getSession(src).license` e escuta formal de `ls:core:playerLoaded`.
    - Garantia de starter kit de sobrevivência (`weapon_unity`, `ammo_handgun`, `burrito_xxl`, `clean_water`, `maxdoc_mk1`, `component_common`, `metal_scrap`) para novos jogadores ou inventários vazios (7 itens, 6.050g).
    - Caching local no cliente Lua (`cachedInventoryBag`) em `ls_ui`, prevenindo perdas de pacotes antes de `ls:ui:ready` do CEF e solicitando sincronização sob demanda ao abrir a mochila.
  - **Catálogo Canônico com 385 Itens & Acervo Visual com 268 Ativos (`items_catalog.lua`, `catalog.js` & `LOCAL_CATALOG`):**
    - **385 itens canônicos cadastrados** com identificadores canônicos, descrições ricas, raridades (comum a icônico), pesos em gramas, limites de empilhamento e categorias (`weapon`, `ammo`, `consumable`, `medical`, `cyberware`, `component`, `misc`).
    - Itens de conveniência sincronizados com as máquinas de autoatendimento All-Foods 24/7 (`chromanticore`, `bounce_back_mk1`, `wet_wipes`, `synth_burger`, `spicy_ramen`, etc.).
    - Biblioteca visual com **268 ícones canônicos e vetores SVG Cyberpunk dedicados** em `Server/resources/gamemodes/lifesim/ls_ui/web/images/` (58 novos vetores gerados, 0 placeholders, 100% dos 385 itens com imagem própria):
      - **Armas e Munições:** Armas canônicas de Cyberpunk 2077 (Unity, Nue, Lexington, Copperhead, Katana, Crusher, Malorian, etc.) e caixas de munição balística/smart/elétrica.
      - **Vestuário (15 SVGs dedicados):** Capacetes, máscaras, óculos táticos, visores Kiroshi, jaquetas de couro/punk, sobretudos, coletes balísticos, camisas, moletons, calças de combate, bermudas, botas de combate e tênis urbanos.
      - **Alimentos & Bebidas (14 SVGs dedicados):** Cervejas (Centzon, Broseph), licores (Nicola Blue, Spunky Monkey), refrigerantes, xícaras de café/chá, garrafas vazias, hambúrgueres sintéticos, ramens de Watson, bifes de proteína cultivada, sushis de Kabuki, espetinhos yakitori, salgadinhos chips, rações de combate militares, maçãs e ração de gato/pet.
      - **Colecionáveis & Loot (18 SVGs dedicados):** Cartas de tarô de Night City (Fool, Magician, Sun, etc.), discos de vinil vintage, relógio de ouro analógico, ursinho de pelúcia, isqueiro zippo, maço de cigarros real, dados cromados de cassino, anéis de ouro, colares com pingente, dog tags militares, palheta de guitarra cromada, fita cassete synthwave, cinzeiro, lata de refrigerante amassada, chaveiro, patches de gangue bordados e credchips criptografados.
      - **Cyberware, Blindagem & Medicina (11 SVGs dedicados):** Olhos cibernéticos Kiroshi Optics, braços gorila e lâminas mantis, pernas reforçadas com tendões de titânio, coração sintético com regulador de adrenalina, processador neural bio-chip, exoesqueleto subcutâneo, cyberdecks táticos Militech/Arasaka, cartuchos de quickhacks por tier, dispositivo de camuflagem óptica, maletas médicas de primeiros socorros, placas de blindagem balística e lenços umedecidos sanitários.
    - Mapeamento declarativo frontend em `catalog.js` com resolução dinâmica de imagens, fallback gracioso para `default_item.svg` e tooltips diegéticos Kiroshi de alta fidelidade com raridade, peso, contagem e efeitos.
    - Propriedades de consumo diegéticas integradas com os vitais (`hunger`, `thirst`, `energy`, `stress`, `health`).
    - Integração de armas canônicas com equipamento no REDengine 4 via `Open77.weapons.equip`.
  - **Sistema de Crafting e Manufatura de Bancada:**
    - Catálogo declarativo de receitas (`crafting_recipes.lua` e `CRAFTING_RECIPES` no frontend) cobrindo armas, munições balísticas/smart, injetores médicos (MaxDoc Mk.1 a Mk.3, BounceBack) e componentes eletrônicos.
    - Layout split-view moderno: lista lateral de blueprints + painel de detalhes da receita selecionada com insumos necessários e checagem de estoque em tempo real.
    - Validação atômica server-side de ingredientes antes de iniciar a manufatura.
    - Barra de progresso holográfica sincronizada em tempo real com o HUD CEF e cancelamento defensivo.
  - **Sistema de Loadout do Quick Radial Menu (8 Slots Direcionais):**
    - Painel diegético de 8 atalhos rápidos na base da mochila com indicação de bússola (`[1] ↑ NORTE` a `[8] ↖ NOROESTE`).
    - Suporte completo a **Drag & Drop** (arrastar itens da mochila para o slot do radial) e **Clique com Botão Direito** no item da mochila para equipar/desequipar instantaneamente.
    - Persistência imediata no `localStorage` (`ls_radial_loadout_slots`).
    - Roda angular SVG de 8 setores no HUD (`CAPSLOCK`) vinculada estritamente aos 8 slots configurados pelo jogador: valida estoque na mochila em tempo real, mostra ícone, nome e contagem, alerta itens esgotados e executa `radial:triggerAction` para consumir ou equipar.
- **Redimensionamento e Responsividade do Inventário (Box Verde Aprovada):**
  - Substituição da moldura rígida de 1150px x 740px (box vermelha) por dimensionamento fluido com `width: clamp(1050px, 92vw, 1720px); height: clamp(680px, 88vh, 980px);` (box verde).
  - `.inv-body` com `flex: 1; height: auto; min-height: 0;` garantindo proporção e harmonia total com a tela do jogo.
  - Grid de 40 slots com `grid-auto-rows: clamp(72px, 8.2vh, 92px); gap: 8px;`, slots ampliados e responsivos para resoluções Full HD (1080p), Quad HD (1440p), 4K e monitores Ultrawide (21:9 e 32:9).
- **Atalhos Nativos e Reconfiguração in-Game (open77_pause):**
  - Migração da keybind padrão da Roda Radial de `TAB` para `CAPSLOCK`, liberando a tecla `TAB` para o futuro Scanner/Hacking vanilla do Cyberpunk.
  - Registro de `inventory_toggle` e `radial_menu_hold` com `Open77.input.registerKeyMapping`, aparecendo automaticamente na aba **Pause > Configurações > KEY BINDINGS** para remapeamento livre pelo jogador.
  - Comandos in-game `/keybinds` e `/atalhos`, além de `/inv`, `/mochila` e `/radial`.
- **Loading Screen Nativa Diegética Transparente (`ls_loadscreen`):**
  - Conformidade total com o wireframe oficial 1:1 (`loading-screen-wireframe-reference.png`).
  - Remoção de background sólido escuro (`#040810`) e gradientes opacos: definição de `background: transparent !important` e blend mode `screen`.
  - As cutscenes 3D cinematográficas vanilla do Cyberpunk 2077 aparecem 100% nítidas no background enquanto os dados do servidor carregam.
  - Botão de escape `[ RETORNAR AO HUB ]` com cancelamento seguro via `Open77.emit("connection:cancel")`.
- **Ferramenta de Telemetria e Coordenadas Espaciais `open77_coords` (Comando `/coords`):**
  - Modal CEF em alta definição com glassmorphism, cantoneiras cibernéticas e sintetizador Web Audio API.
  - Extração precisa de coordenadas espaciais ($X, Y, Z$), orientação da cabeça/câmera ($ForwardX, ForwardY, ForwardZ, Pitch$), posição do osso Head e Yaw/Heading normalizados ($0^\circ..360^\circ$).
  - Exportação em 1-clique para Lua Config Table, `vec4`, `vec3`, PolyZone Point 2D, Open77 Ground Marker Spec, Spawner NPC e JSON.
  - Segurança autoritativa ACL restrita a cargos administrativos.
- **Controle de Acesso Administrativo (ACL & In-Game Super Admin):**
  - Papel `operator` configurado no `Server/acl.jsonc` com permissões irrestritas (`*`) vinculadas ao userId Master `c03e8ff9-22ce-4c15-ac39-5f435a07f5ba` (`viccs`).
  - Menus in-game `/admin` e `/adminfull` do recurso oficial `open77_admin`.
  - Ferramenta remota RCON CLI (`Server/tools/rcon/cli.mjs`).
- **Banco de Dados MariaDB Integrado:**
  - Esquema `open77_lifesim` operando no XAMPP MariaDB (porta 3306) com 13 tabelas de domínio (`ls_players`, `ls_vitals`, `ls_cyberware`, `ls_ui_settings`, `ls_accounts`, `ls_transactions`, `ls_player_apartments`, `ls_apartment_furniture`, `ls_player_spawns`, `ls_inventories`, `ls_inventory_items`, `properties`, `bank_transactions`).
- **Módulos Core do Life-Sim RP Operacionais:**
  - `ls_data` (Fase 1 - 100%): Migrações declarativas, exports de banco e `CacheService` síncrono write-behind.
  - `ls_core` (Fase 1 - 100%): Sessão em 5 fases, gateway de prontidão com timeout de 25s, colocação física síncrona (`exports.ls_core:place`) e isolamento por Routing Buckets.
  - `ls_vitals` (Fase 2 - 100%): Decaimento biológico monotônico de 5 atributos, detecção veicular com travamento em `driving` (0.85x), penalidades severas de saúde a 0% e suite administrativa `/vitals`.
  - `ls_cyberware` (Fase 3 - 100%): 20 implantes em 11 slots corporais, cálculo de estabilidade neural, aquecimento óptico, limiar de ciberpsicose e farmacêuticos supressores.
  - `ls_economy` (Fase 4 - 100%): Transações bancárias ACID no MariaDB (`SELECT ... FOR UPDATE`), ATMs Kiosk, lojas de conveniência 24/7 e clínica Ripperdoc Viktor Vector.
  - `ls_housing` (Fase 5 - 100%): Instanciação por Routing Buckets, múltiplas portas de entrada com blips individuais, interior canônico de V no Megabuilding H10 calibrado contra quedas no vazio, anel holográfico de saída WorldUI e Build Mode 360° com validação de colisões PolyZone OBB.
  - `ls_spawn` (Gateway - 100%): Primeiro spawn obrigatório no Megabuilding H10 em Watson sem menu, spawns subsequentes com seletor holográfico de locais públicos de Night City e watchdog automático contra travamentos (75s).
  - `ls_ui` (Rework Holográfico - 100%): HUD Kiroshi diegético baseado nas 8 referências canônicas de design, gating estrito de `pointer-events: none` em camadas transparentes e dimensionamento fluido via `clamp()`.

## Incident Resolutions & Diagnostic Forensics (Logs 0 a 31)
- **Log 0 a 13 (Fundação, Conectividade e Validação de Ambiente):** Host .NET 8, MariaDB, portas UDP/HTTP e licença Master.
- **Log 14 (Falha de Ativação / Incompatibilidades FiveM):** Eliminação de `RegisterNUICallback`, `PlayerId()` e APIs legadas.
- **Log 15 (Stall de Conexão no Checkpoint 04 & Require do Servidor):** Falha no `require('@polyzone')` substituída por algoritmo puro em Lua de Winding Number / Raycasting.
- **Log 16 (Habitação e Blips):** Mapeamento dinâmico sem duplicidade via `Open77.map.createPin`.
- **Log 17 (Loading Infinito no Seletor de Spawn):** Correção de payloads de `page:send` e emissão de `open77:session:gameplayReady`.
- **Log 18 (Unfreeze e Crash por `export_yielded`):** Eliminação de yields assíncronos dentro de exports síncronos de placement.
- **Log 19 (Bundle Pré-Release v0.0.2):** Auditoria de integridade RED4ext e projeções de estado.
- **Log 20 (Exports de Banco de Dados e Débito de Moeda):** Registro de exports formais de banco no `ls_data` e `ls_economy`.
- **Log 21 (Crash no `/coords` e Gatilho [E] no `ls_housing`):** Desempacotamento de retornos múltiplos numéricos de `Open77.character.position()` e extração regex de `interactionId` no WorldUI.
- **Log 22 (Overlap de Marcadores 3D com NUI):** Limpeza atômica de marcadores ao abrir interfaces CEF residenciais.
- **Log 23 (Múltiplas Portas e Blips Individuais):** Suporte a array de portas com rastreamento da porta de entrada original do jogador.
- **Log 24 (Persistência MariaDB, Void Death e Interior Canônico de V):** Calibração de coordenadas oficiais de V no Megabuilding H10 (`z = 123.06`), permissão `"database.access"` e sincronização de Unix Epoch real.
- **Log 25 (Travamento de Spawn, Parede de Vidro CEF & Race Condition de Bootstrap):** Correção de `.radial-overlay` cobrindo a tela inteira com `pointer-events: auto`, alinhamento temporal do `maybeAnnounce` (25s) e watchdog server-side (75s).
- **Log 26 (Homologação de Gameplay Operacional & Resolução do Comando `/inv`):** Validação de 10 minutos de gameplay contínuo, 33 blips econômicos no mapa, elevador do Megabuilding H10 adotado pelo `open77_elevators` e adição do alias `/inv`.
- **Log 27 (Atalhos do Quick Radial, Visibilidade da LoadScreen e Front-end NUI):**
  - Migração de `TAB` para `CAPSLOCK` com `RegisterKeyMapping` integrado ao menu Pause do jogo.
  - Correção de fundo sólido `#040810` na loading screen, tornando as cutscenes 3D vanilla visíveis sob o HUD.
  - Resolução de fechamento ausente (`</footer></div></div>`) em `#ripperdoc-modal` na linha 465 de `ls_ui/web/index.html` que ocultava o inventário e a roda radial no Chromium CEF por herança de estilo.
- **Log 28 (Sistema de Equipar no Radial, Exibição de Itens na Mochila e Redimensionamento da Box Verde):**
  - **Bug 1 (Equipar no Radial):** Criação do painel de 8 atalhos direcionais (`[1] ↑` a `[8] ↖`) na mochila com drag & drop, clique direito e persistência no `localStorage`. Roda radial acoplada diretamente ao loadout, validando estoque e executando `radial:triggerAction`.
  - **Bug 2 (Mochila Vazia & Crash de Export):** Erro fatal `export ls_core:GetPlayerCharacterId export_not_found` eliminado. Implementada `resolvePlayerLicense(src)` consultando `exports["ls_core"]:getSession(src).license`, conectado ao evento canônico `ls:core:playerLoaded(playerId, license)`, concedida permissão `"database.access"`, injetado starter kit de sobrevivência e criado `cachedInventoryBag` no cliente Lua para entrega sem perda de pacotes.
  - **Bug 3 (Dimensões do Inventário - Box Verde):** Interface expandida de 1150px x 740px (box vermelha) para `width: clamp(1050px, 92vw, 1720px); height: clamp(680px, 88vh, 980px);` (box verde), com `.inv-body` flexível e slots ampliados para Full HD, Quad HD, 4K e Ultrawide.
- **Log 29 (Resolução de Escopo do Adapter de Banco `Database`):**
  - Diagnosticado erro fatal `ls_inventory/server/main.lua:34: attempt to index a nil value (global 'Database')` gerado pela ordem de declaração de adaptadores de banco no runtime.
  - Refatorado o escopo da tabela `Database` para o topo absoluto do arquivo `ls_inventory/server/main.lua`, provendo adaptadores canônicos para `query`, `single`, `update` e `insert` com delegação defensiva entre `MySQL.*.await`, `Open77.database.*.await` e `exports["ls_data"]`.
- **Log 30 (Sincronização de Starter Kit, Auditoria de Compras All-Foods Vending e Integridade de Esquema):**
  - Homologada com sucesso a injeção e sincronização do Starter Kit (`[ls_inventory] Inventário sincronizado para jogador [1] (Licença: 31d9b55ac77645bca0cafb957705ba32, Itens: 7, Peso: 6050g)`).
  - Identificada falha nas compras da máquina de vendas All-Foods (`chromanticore`, `bounce_back_mk1`, `wet_wipes`), onde o sistema acionou o reembolso preventivo de segurança (`Reembolso: Falha no Inventário`) devido à ausência desses itens no catálogo canônico compartilhado. Itens devidamente cadastrados com propriedades biofisiológicas e visuais completas em `items_catalog.lua` e `catalog.js` (totalizando 385 itens).
  - Diagnosticado erro de coluna ausente `database_schema_error (SQL 1054)` nas rotinas de atualização de item, isolando a necessidade de alinhamento estrito dos identificadores de chave primária (`id` vs `(inventory_id, slot)`) no MariaDB e blindando queries de consumo contra parâmetros nulos.
- **Log 31 (Auditoria de Paridade Visual de Itens & Criação de Ícones SVG Cyberpunk Dedicados):**
  - Diagnosticada disparidade visual onde 175 itens do catálogo canônico compartilhavam imagens inadequadas (61 roupas com fallback genérico `default_item.svg` [`?`], 29 itens de loot/tarô/colecionáveis apontando indevidamente para datashard `shard.png`, comidas apontando para `burrito.png` e bebidas para `water.png`).
  - Desenvolvidos e injetados **58 novos arquivos vetoriais SVG** de alta fidelidade diegética Kiroshi (`ls_ui/web/images/`), cobrindo 15 categorias de vestuário, 14 de alimentos/bebidas, 18 de colecionáveis/loot e 11 de cyberware/blindagem/medicina.
  - Reescrito o mapeamento de **151 itens** em `items_catalog.lua` (backend Lua) e `catalog.js` (frontend CEF).
  - Executada auditoria forense via script de teste automatizado (`verify_images.py`):
    - 268 arquivos físicos em disco.
    - 267 arquivos únicos referenciados pelos 385 itens canônicos.
    - 0 links quebrados (404).
    - 0 itens usando `default_item.svg` (`?`).
    - Paridade absoluta e total entre Lua e JS.

## Catálogo de Blindagem Poka-Yoke (mistake-proof.skill)
1. **[MP-001]** Keymapping & Input Actions no OPEN//77 (permissão `input.actions` e spec table `{ id, name, key, hold, onPressed, onReleased }`).
2. **[MP-002]** Prevenção de `export_yielded` (permissão `database.access` e queries nativas com corrotinas `CreateThread`).
3. **[MP-003]** Blindagem contra Rollback Financeiro (distinção entre `#rows == 0` e `rows == nil`).
4. **[MP-004]** Prevenção de Marcadores 3D Duplicados e Stuttering Próximo a Instâncias (gestão unificada via `open77_worldui`).
5. **[MP-005]** Polling Adaptativo de Teclas e Interações (hibernação de 500ms ocioso, 100ms próximo).
6. **[MP-006]** Inicialização de WebUI Oculta com `visible = false` (economia de GPU CEF).
7. **[MP-007]** Foco de Mouse e Fechamento Universal em Interfaces CEF (`page:setFocus(false, true)` e listener de Escape).
8. **[MP-008]** Modais CEF Aninhados e Ocultação por Herança CSS (fechamento rigoroso de tags e nós root no DOM).
9. **[MP-009]** Transparência de LoadScreen para Exibição de Cutscenes 3D Nativas (`background: transparent !important`).
10. **[MP-010]** Desacoplamento de Keybinds Nativas e Mapeamento Reconfigurável no Pause Menu (`CAPSLOCK` e `RegisterKeyMapping`).
11. **[MP-011]** Resolução de Identidade Canônica de Inventário (`exports["ls_core"]:getSession(src).license`, `ls:core:playerLoaded` e `cachedInventoryBag`).
12. **[MP-012]** Loadout Persistente do Quick Radial Menu (8 Slots Direcionais) & Dimensionamento Responsivo CEF (`clamp(1050px, 92vw, 1720px)`).
13. **[MP-013]** Paridade Estrita de Catálogos Lua/CEF & Prevenção de Placeholders Visuais Fantasmas (auditoria automatizada via script e paridade 1:1 entre `items_catalog.lua` e `catalog.js`).

## Work-in-Progress Items
- **Validação In-Game & Homologação de Carga dos Logs 28 a 31:**
  - Teste de consumo contínuo e movimentação de itens com persistência direta no MariaDB sem advertências de esquema.
  - Homologação da compra de consumíveis nas máquinas All-Foods sem acionamento de reembolso.
  - Validação visual dos 58 novos ícones SVG neon no inventário e roda radial em tempo real.
- **Fase 6: Módulo `ls_jobs` & `ls_factions` (Carreiras, Reputação Urbana & Fixers):**
  - Scaffolding de `ls_jobs`: contratos de Fixers dinâmicos, entregas/freelancer, turnos e progressão salarial.
  - Scaffolding de `ls_factions`: progressão de reputação de gangues (Moxes, Maelstrom, Tyger Claws, Valentinos) e canais de rádio corporativos/policiais.
  - Sistema de ponto e serviço com cálculo de produtividade e drenos econômicos integrados ao `ls_economy`.

## Known TODOs or Missing Parts
- Implementar `ls_jobs` e `ls_factions` (Fase 6).
- Implementar `ls_medical` avançado com resgate Trauma Team Platinum aéreo via AV (Fase 7).
- Implementar `ls_social` com rede social urbana in-game Kiroshi Net (Fase 8).
- Auditoria final de concorrência, stress test de banco de dados e empacotamento de produção (Fase 9).
