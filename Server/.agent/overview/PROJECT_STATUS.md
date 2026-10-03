# Project Overview

## Project Name
OPEN//77: Night City Life-Sim RP (VICCS Cyberpunk Server)

## Description
Servidor dedicado multijogador para Cyberpunk 2077 (v2.31 / Phantom Liberty) focado em simulação social e biológica profunda (*Life-Sim RP*), inspirado em dinâmicas de The Sims transpostas para o cenário distópico de Night City. O ecossistema opera sobre arquitetura modular com separação estrita de responsabilidades, governança centralizada no Core, persistência Write-Behind no MariaDB (InnoDB com foreign keys e colunas JSON), decaimento metabólico monotônico com histerese em State Bags, penalidades orgânicas severas a 0% de hidratação/nutrição, suite administrativa de vitais com resolução inteligente de alvos, telemetria de ciberimplantes com motor térmico e estabilidade neural (Fase 3 - 100%), economia dinâmica com Eurodólares (Cash/Bank), terminais de autoatendimento ATM, máquinas de conveniência All-Foods 24/7 e clínica Ripperdoc Viktor Vector totalmente operacionais (Fase 4 - 100%), sistema de habitação vertical instanciada por Routing Buckets com Build Mode livre em 360° e detecção de colisões OBB via PolyZone 3D (Fase 5 - 100%), seletor de despertar neural diegético Kiroshi (`ls_spawn`) com primeiro spawn obrigatório no Megabuilding H10 e radar holográfico geodésico, interface NUI diegética em WebUI nativa com pivô holográfico Kiroshi de alta fidelidade (L-brackets táticos, badges de sincronização neural, rodapé diegético com keycaps `<kbd>`, glassmorphism translúcido `blur(16px)` e responsividade fluida via `clamp()` para 1080p, 1440p, 4K e Ultrawide 21:9/32:9), tela de carregamento nativa modular (`ls_loadscreen`) em estrita conformidade com o wireframe oficial de design (botão Topo-Esquerdo "RETORNAR AO HUB", transições cinematográficas suaves entre distritos de Night City, player holográfico de áudio e telemetria de carregamento em tempo real sincronizada via CEF do `open77_shell`), self-hosting via VPN de baixa latência (Radmin VPN), e controle de acesso criptográfico (ACL com papéis administrativos `operator` e comandos de voo/teleporte/veículos).

## Tech Stack
- Languages: Lua 5.4 (Server & Client Resources em VMs isoladas), JavaScript ES6+ / TypeScript, HTML5 / CSS3 (CSS Variables, Clip-Path Polygons, Web Audio API), SQL (MariaDB 10.4+ / MySQL 8 com InnoDB, JSON e transações ACID)
- Frameworks: OPEN//77 Dedicated Server Host (.NET 8 Runtime, Build 2.31.21+op77.121), WebUI CEF / Ultralight HUD Engine
- Tools: `@open2077/mcp` (OPEN//77 Devkit MCP Server com 27 ferramentas), Node.js v22+, Lua Language Server (`.luarc.json` + `.vscode/settings.json`), HeidiSQL / XAMPP MariaDB CLI, PowerShell 7+
- Services: OPEN//77 Dedicated Host (.NET 8 UDP 11778, HTTP 11779, Warden 11780), MariaDB Database Server (`open77_lifesim`), Open77 Master Server Licensing, `CacheService` Lua (Write-Behind in-memory com flush a cada 5m/disconnect/stop), Radmin VPN Mesh Network (`26.102.47.161`)

## Folder Structure
- ```text
c:/Games/VICCS_CyberpunkServer/
├── .agent/                             # Cérebro de Contexto & Memória do Agente (Master Cortex)
│   ├── assets/                         # Referências visuais e wireframes de design
│   │   └── references/png/
│   │       ├── interface-hud/          # 8 referências canônicas do HUD diegético Kiroshi
│   │       └── loading-screen/         # Wireframe oficial da Loading Screen
│   ├── context/
│   │   ├── LIFESIM_CORE_CONTEXT_FRAMEWORK.md   # Marco arquitetural absoluto do Life-Sim RP
│   │   ├── OPEN77_CORE_AGENT_CONTEXT_FRAMEWORK.md # Princípios de governança do Open77
│   │   ├── architecture.md             # Arquitetura, princípios e mapa de resources
│   │   ├── database_schema.md          # Esquemas MariaDB InnoDB e CacheService Lua
│   │   ├── documentation.md            # Documentação técnica oficial OPEN//77 compilada
│   │   ├── ls_housing_free_decoration_polyzone_spec.md # Especificação técnica do Housing OBB
│   │   └── stack.md                    # Detalhamento de stack e dependências reais
│   ├── guidelines/
│   │   ├── CYBERPUNK_NATIVE_UI_DESIGN_SPEC.md  # Especificação técnica do Design System Kiroshi
│   │   ├── code_style.md               # Diretrizes de estilo de código Lua 5.4 e NUI
│   │   └── ui_ux.md                    # Tokens visuais Kiroshi e regras de UX nativa
│   ├── memory/
│   │   ├── active_task.md              # Estado da tarefa atual em execução
│   │   ├── changelog.md                # Histórico de entregas e versões
│   │   └── todos.md                    # Backlog priorizado de tarefas (9 Fases)
│   ├── overview/
│   │   └── PROJECT_STATUS.md           # Visão geral de status sincronizada (este arquivo)
│   └── workflows/
│       └── open2077_dev_skill.md       # SOP de desenvolvimento de recursos Open77
├── .agents/                            # Customizações locais do workspace (Antigravity)
│   └── skills/
│       └── open2077-dev/
│           └── SKILL.md                # Skill nativa do workspace para OPEN//77
├── .vscode/
│   └── settings.json                   # Configuração de IDE, associações e bibliotecas de tipagem
├── .luarc.json                         # Configuração mestre raiz do Lua Language Server
├── GDD_Website/                        # Website do Game Design Document (GDD)
│   └── project_cp2077_lifesim.html     # Dashboard executivo interativo do GDD (Tailwind + Chart.js)
├── Main_Website/                       # Portal e Website oficial do servidor
└── Server/                             # Servidor Dedicado OPEN//77 (Build 2.31.21+op77.121)
    ├── .agent/                         # Espelho local do cortex e comandos de servidor
    │   ├── logs/                       # Bundles de diagnóstico e incidentes (Logs 1 a 18)
    │   ├── overview/
    │   │   └── PROJECT_STATUS.md       # Cópia espelhada da visão geral
    │   └── server-commands/
    │       └── Comandos.txt            # Documentação tática in-game dos comandos /vitals
    ├── .luarc.json                     # Configuração espelhada de diagnósticos Lua
    ├── acl.jsonc                       # Controle de acesso e permissões administrativas (Owner viccs)
    ├── open77-client.d.lua             # Tipagens nativas do runtime do cliente (varargs e exports)
    ├── open77-manifest.d.lua           # Stubs de declaração para manifestos OPEN//77 (inclui loadscreen)
    ├── open77-server.d.lua             # Tipagens nativas do runtime do servidor (varargs e exports)
    ├── resources/                      # Catálogo de recursos do servidor (44 resources)
    │   ├── gamemodes/
    │   │   ├── freeroam/               # Gamemode freeroam nativo de demonstração
    │   │   └── lifesim/                # Gamemode customizado VICCS Life-Sim RP
    │   │       ├── _shared/            # Módulos puros compartilhados (ls_shared.lua)
    │   │       ├── ls_core/            # [FASE 1 - 100%] Sessão, Readiness Gate, Placement & Registry
    │   │       ├── ls_data/            # [FASE 1 - 100%] Persistência MariaDB InnoDB & CacheService
    │   │       ├── ls_vitals/          # [FASE 2 - 100%] Motor de Fisiologia, Penalidades & Admin Suite
    │   │       ├── ls_cyberware/       # [FASE 3 - 100%] Implantes, Estabilidade Neural & Ciberpsicose
    │   │       ├── ls_economy/         # [FASE 4 - 100%] Carteira Cash, Conta Bancária ACID, ATMs e Vending
    │   │       ├── ls_housing/         # [FASE 5 - 100%] Habitação Vertical, Routing Buckets & Build Mode OBB
    │   │       ├── ls_spawn/           # [GATEWAY - 100%] Seletor Holográfico de Despertar & Spawn H10
    │   │       ├── ls_loadscreen/      # [NOVO - 100%] Loading Screen Nativa Diegética Wireframe-Match
    │   │       └── ls_ui/              # [REWORK HOLOGRÁFICO - 100%] NUI Diegética Kiroshi HUD Multi-Resolução
    │   ├── open77_equipment/           # Gestão de equipamentos
    │   ├── open77_wardrobe/            # Guarda-roupa persistente
    │   ├── polyzone/                   # Delimitação de zonas tridimensionais (integração housing)
    │   └── system/                     # 32 recursos oficiais do sistema OPEN//77
    ├── server.jsonc                    # Configuração autoritativa do servidor, rede Radmin e licença Master
    └── Start.cmd                       # Script de inicialização oficial do servidor dedicado
```

## Current Features Implemented
- **Servidor Dedicado OPEN//77 Totalmente Operacional:**
  - Build `2.31.21+op77.121` configurado e validado.
  - Licença Master válida (`op77_live_...`) com Run lease concedido.
  - Rede configurada para conectividade local e externa via Radmin VPN (`26.102.47.161:11778` UDP e `http://26.102.47.161:11779/` HTTP).
  - Testado e homologado com sucesso com conexões de jogadores remotos (terceiros).
- **Controle de Acesso Administrativo (ACL & In-Game Super Admin):**
  - Papel `operator` configurado no `Server/acl.jsonc` com comandos completos e atalhos rápidos (`/noclip`, `/fly`, `/god`, `/heal`, `/car`, `/dv`, `/goto`, `/bring`, `/tp`, `/weapons`, `/gun`, `/announce`, `/kick`, `/ban`).
  - Principal vinculado diretamente à identidade criptográfica Master do criador (`userId: c03e8ff9-22ce-4c15-ac39-5f435a07f5ba`, usuário `viccs`) com permissões irrestritas (`*`).
  - Suporte completo às interfaces administrativas in-game do `open77_admin`: `/admin` (menu lateral tático com setas) e `/adminfull` (painel em tela cheia com mouse).
- **Banco de Dados MariaDB Integrado:**
  - Esquema `open77_lifesim` operando no XAMPP MariaDB (porta 3306).
  - Tabela de rastreamento de migrações `ls_schema_migrations` e tabelas de domínio `ls_players` (v1), `ls_vitals` (v1), `ls_cyberware` (v1), `ls_ui_settings` (v1), `ls_accounts` (v1), `ls_transactions` (v1), `ls_player_apartments` (v1), `ls_apartment_furniture` (v1) e `ls_player_spawns` (v1) ativas com colunas JSON e chaves relacionais estrangeiras.
- **Módulo `ls_data` (Fase 1 - 100% Concluída):**
  - Gerenciador de migrações SQL declarativo com validação de checksum e isolamento por módulo.
  - `CacheService` síncrono em memória com flush assíncrono em thread contínua (5 min) e persistência garantida na desconexão.
  - Registro de perfis de cidadão indexados pela chave de persistência durável `license`.
- **Módulo `ls_core` (Fase 1 - 100% Concluída & Estabilizada):**
  - Roteamento de sessão via máquina de estados de 5 fases (`connected`, `loading`, `loaded`, `rejected`, `dropped`).
  - Gate de prontidão da plataforma integrado com liberação condicionada à sincronização de perfil.
  - Registro de módulos (`registerModule`) com limite de cota de memória para State Bags (máximo de 2048 bytes por módulo).
  - Posicionamento seguro inicial (`spawnDefault` nos Badlands) e comandos administrativos protegidos (`/ls_goto`, `/ls_bring`, `/ls_status`, `/ls_modules`).
  - **Serviço de Placement Síncrono e Não-Yielding:** Removidos pontos de suspensão assíncrona (`Wait`) para total compatibilidade com exportações do Open77 (`exports.ls_core:place`), com permissões nativas completas (`players.life.read`, `players.screen`, `players.life.freeze`, `players.teleport`).
- **Módulo `ls_vitals` (Fase 2 - 100% Concluída & Refinada):**
  - Motor de decaimento metabólico monotônico com tick a cada 3000ms via `GetGameTimer()`.
  - 5 atributos biológicos modelados: Nutrição (Fome), Hidratação (Sede), Stamina (Energia), Sanitário (Higiene) e Carga Neural (Estresse).
  - **Correção de Telemetria Veicular:** Detecção multicamadas de veículos no cliente (`IsPlayerInVehicle`, `IsPlayerDriver`, `IsPlayerPassenger`, `Open77.vehicles.getPlayerSeat`). No servidor, quando o jogador está em veículo, a atividade é travada em `driving` (0.85x), eliminando o bug de sprint por velocidade do carro.
  - **Penalidades Críticas Biológicas:** Implementado dano autoritativo à saúde (`Open77.players.setHealth`) quando hidratação (0% H2O, -3.5 HP/tick) ou nutrição (0% fome, -1.5 HP/tick) zeram. Morte nativa processada pela REDengine se a vida for zerada.
  - **Suite Administrativa `/vitals`:** `/vitals fill [alvo]`, `/vitals drain [alvo]`, `/vitals set [alvo]`, `/vitals rate <mult>`, `/vitals log` e `/vitals help` com resolução inteligente de alvos (`resolvePlayerTarget`) e segurança ACL nativa.
- **Módulo `ls_cyberware` (Fase 3 - 100% Concluída & Operacional):**
  - Catálogo anatômico com mais de 20 implantes, divididos em 11 slots anatômicos corporais.
  - Cálculo contínuo de Estabilidade Neural, calor ocular e limiar de ciberpsicose (< 25%).
  - Farmacêuticos funcionais: neurobloqueadores (supressão sináptica) e spray criogênico (arrefecimento de sensores ópticos).
  - Padrão **Dual Sync** nativo Open77 (`ls:cyberware:sync` e `Open77.state.onChange`), eliminando dependências legadas FiveM.
- **Módulo `ls_economy` (Fase 4 - 100% Concluída & Operacional):**
  - **Transações Bancárias ACID:** Operações de saque, depósito, transferência e pagamentos com travamento pessimista `SELECT ... FOR UPDATE` no MariaDB, garantindo integridade contra race conditions e dupes.
  - **Duplo Saldo Financeiro:** Carteira física em dinheiro vivo (`cash`) e conta bancária digital (`bank`), persistidas em `ls_accounts` com log de auditoria em `ls_transactions`.
  - **Terminal de Autoatendimento ATM Kiosk:** Interface CEF completa com saques e depósitos rápidos (E$ 100, E$ 500, E$ 1.000, Depositar Tudo) e inserção de valores manuais.
  - **Máquinas de Vendas 24/7 (All-Foods Convenience):** Catálogo de conveniência com compra em dinheiro vivo ou débito em conta, aplicando recuperação instantânea aos vitais correspondentes (ex: Nicola Blue restaura sede/energia, Burrito XXL restaura fome).
  - **Clínica Ripperdoc Viktor Vector Integrada:** Interface de cirurgia cibernética para instalação e remoção de implantes, cirurgia plástica facial/corporal e dispensário farmacêutico integrado ao débito bancário do jogador.
- **Módulo de Habitação Vertical e Build Mode `ls_housing` (Fase 5 - 100% Concluída):**
  - **Instanciamento por Routing Buckets:** Isolamento autoritativo de dimensões para apartamentos compartilhados via `exports.ls_core:assignBucket("apartment", ...)` e `Open77.routingBuckets.setPlayer(playerId, bucketId)`. Múltiplos jogadores podem residir no mesmo Megabuilding H10 Apto 0705 sem colisão física ou visual, com reciclagem e liberação automática de buckets quando desocupados.
  - **Build Mode com Movimentação Livre & PolyZone OBB:**
    - Fim da grade rígida: substituição por raycast tridimensional contínuo no piso e rotação Yaw $360^\circ$ livre (`Scroll` ou `Q/E`).
    - Validação de 4 vértices do Oriented Bounding Box (OBB) do móvel contra o `PolyZone` 3D do apartamento em tempo real.
    - Prevenção matemática de atravessamento de paredes e sobreposição indevida com mobílias existentes.
    - Shader holográfico diegético Kiroshi: Verde/Ciano (`#00ff9d`) para posições válidas e Vermelho (`#ff003c`) para colisões.
    - Revalidação autoritativa das coordenadas no servidor antes de gravar no MariaDB.
  - **Catálogo de Imóveis & Mobílias (`shared/config.lua`):**
    - 4 complexos residenciais cadastrados com delimitações PolyZone (`h10_apt_v`, `japantown_loft`, `glen_studio`, `corpo_plaza_suite`).
    - Catálogo diversificado de mobílias com dimensões físicas reais ($W, L, H$), categorias e metadados de interação.
    - Blips temáticos de apartamentos e imobiliárias com auto-registro e anti-sobreposição no mapa de Night City.
  - **Mobílias Interativas Funcionais:**
    - Cama: sono terapêutico integrado ao `ls_vitals` (regeneração de Energia e alívio de Estresse).
    - Chuveiro: banho sônico desinfetante que restaura Higiene a 100%.
    - Baú / Cofre: armazenamento balístico residencial (`stash`).
  - **Persistência MariaDB (`server/main.lua` via `ls_data`):**
    - Tabelas `ls_player_apartments` (contratos `rent`/`owned`, trancas biométricas, vencimento) e `ls_apartment_furniture` (posições $X, Y, Z$, rotações e JSON de template).
    - Integração de débitos financeiros ACID com `ls_economy` para locação, compra de imóveis e aquisição de mobílias com reembolso de 50% na reciclagem.
  - **Terminal Residencial Holográfico Kiroshi NUI (`ls_housing/web`):**
    - Gestão de contratos, chave biométrica, catálogo de mobília filtrável e acionamento do modo de decoração.
- **Módulo de Spawn e Despertar Neural `ls_spawn` (Gateway Pré-Fase 5 - 100% Concluído & Blindado):**
  - **Primeiro Spawn Obrigatório:** Novos personagens nascem automaticamente no Megabuilding H10 em Little China (Watson) sem menu, com notificação de boas-vindas diegética no HUD Kiroshi.
  - **Spawns Subsequentes:** Personagens já existentes recebem a tela holográfica de seleção com locais públicos de Night City (Megabuilding H10, Megabuilding H8 Japantown, Arasaka Corpo Plaza, Mercado Noturno de Kabuki, Cherry Blossom Market, City Hall Plaza The Glen, Grand Imperial Mall Pacifica e Última Conexão do Biochip).
  - **Interface Holográfica Kiroshi:** Cantoneiras L-brackets, recortes em 45°, glassmorphism translúcido (`blur(14px)`), Radar Canvas animado com telemetria geodésica, sintetizador de áudio Web Audio API e navegação por teclado (<kbd>↑</kbd> <kbd>↓</kbd> <kbd>ENTER</kbd>).
  - **Resolução de Conectividade CEF & Export:** Conformidade estrita de eventos CEF (`page:send("spawn:close", {})`), timeout de segurança de 1.5s na WebUI, tratamento idempotente no servidor contra re-clicks, execução incondicional do unfreeze com `pcall` e teleporte nativo no cliente via `Open77.travel.teleport`.
- **Pivô Holográfico do Front-end NUI (`ls_ui/web`):**
  - **Design System Kiroshi Diegético:** Reestruturação visual 1:1 baseada nas 8 referências oficiais de Night City (`interface-hud/1.png` a `8.png`).
  - **Cantoneiras Táticas (L-Brackets):** Injetadas nos 4 cantos de todos os modais (`settings-modal`, `atm-modal`, `vending-modal`, `ripperdoc-modal`).
  - **Sincronização e Telemetria Neural:** Header com `.sync-badge` e micro-ponto de pulso luminoso `.sync-dot`.
  - **Rodapé Diegético com Keycaps `<kbd>`:** Linha de status (`CALIBRAÇÃO RETINIANA ATIVA`, `TELEMETRY ACTIVE`) e atalhos de teclado chanfrados (`<kbd>ESC</kbd>`, `<kbd>ENTER</kbd>`).
  - **Glassmorphism Translúcido:** `backdrop-filter: blur(16px) saturate(140%)` sobre gradientes escuros com bordas ciano (`#22D8E2`) e acentos amarelo (`#FCEE0A`).
  - **Responsividade Multi-Resolução Fluida:** Fórmulas CSS `clamp()` aplicadas em todos os componentes, eliminando distorções em 1080p, 1440p, 4K e Ultrawide 21:9/32:9.
- **Nova Loading Screen Nativa Diegética (`ls_loadscreen`):**
  - **Wireframe Oficial 1:1:** Implementada seguindo estritamente `loading-screen-wireframe-reference.png`.
  - **Botão Superior Esquerdo [ RETORNAR AO HUB ]:** Cantoneiras táticas, tecla `<kbd>ESC</kbd>` e cancelamento imediato de conexão no engine via `Open77.emit("connection:cancel")`.
  - **Media Engine Central Multi-Modo:** Cenas Vanilla de Night City com crossfade de 1.2s, suporte a `.mp4` local e YouTube streaming com fail-safe automático.
  - **Widget "PLAYER" no Canto Inferior Direito:** Header holográfico com badge `STREAM LIVE`, equalizador neon com 6 bandas animadas, controles de áudio, sintetizador Web Audio API e barra de progresso em tempo real sincronizada via CEF do `open77_shell`.

## Incident Resolutions (Histórico Forense Recente)
- **Log 15 (Stall na Conexão do Personagem):**
  - Bypass de colisão de restauração de coordenadas entre `open77_playerstate` e `open77_appearance`.
  - Reconciliação autoritativa do estado no MariaDB e liberação imediata da tela de carregamento.
- **Log 16 (Ativação de Habitação e Blips de Mapa):**
  - Blips de residências e imobiliárias registrados dinamicamente via `Open77.map.createPin` sem duplicidade.
  - Sincronização e ativação do `ls_housing` e `ls_loadscreen` nos manifestos do servidor.
- **Log 17 (Loading Infinito no Seletor de Spawn):**
  - Identificada rejeição de chamadas `page:send("spawn:close")` sem payload no motor CEF do OPEN//77.
  - Adicionado timeout de segurança local na WebUI (1.5s) e emissão de `open77:session:gameplayReady` no `ls_core/client/main.lua` e `open77_appearance/client/main.lua`.
- **Log 18 (Unfreeze e Crash por `export_yielded`):**
  - Identificado erro fatal `open77/runtime.lua:259: export ls_core:place export_yielded` causado por `Wait(100)` dentro de um export síncrono.
  - Removido qualquer yield de `Placement.place`, blindada a execução com `pcall` no servidor para garantir o descongelamento incondicional do jogador (`Open77.players.setFrozen(playerId, false)`).
  - Implementado teleporte nativo client-side via `Open77.travel.teleport` e concedidas as permissões obrigatórias nos manifestos (`players.life.read`, `players.screen`, `players.life.freeze`, `player.travel`).

## Work-in-Progress Items
- **Fase 6: Módulo `ls_jobs` & `ls_factions` (Carreiras, Reputação Urbana & Fixers):**
  - Contratos de Fixers dinâmicos e sistema de entregas/freelancer.
  - Progressão de reputação de gangues (Moxes, Maelstrom, Tyger Claws, Valentinos).
  - Verificação de serviço em ponto com cálculo de produtividade e drenos econômicos.

## Known TODOs or Missing Parts
- Implementar `ls_jobs` e `ls_factions` (Fase 6).
- Implementar `ls_medical` avançado com resgate Trauma Team Platinum aéreo (Fase 7).
- Implementar `ls_social` com rede social urbana in-game (Fase 8).
- Auditoria final de concorrência, otimização de ticks e release candidate (Fase 9).
