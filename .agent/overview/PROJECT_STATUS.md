# Project Overview

## Project Name
OPEN//77: Night City Life-Sim RP (VICCS Cyberpunk Server) - Release v0.0.2

## Description
Servidor dedicado multijogador para Cyberpunk 2077 (v2.31 / Phantom Liberty, Build 2.31.21+op77.121) focado em simulação social e biológica profunda (*Life-Sim RP*), inspirado em dinâmicas de The Sims transpostas para o cenário distópico de Night City. O ecossistema opera sobre arquitetura modular com separação estrita de responsabilidades, governança centralizada no Core, persistência direta e resiliente no MariaDB (InnoDB com foreign keys e colunas JSON), decaimento metabólico monotônico com histerese em State Bags, penalidades orgânicas severas a 0% de hidratação/nutrição, suite administrativa de vitais com resolução inteligente de alvos, telemetria de ciberimplantes com motor térmico e estabilidade neural (Fase 3 - 100%), economia dinâmica com Eurodólares (Cash/Bank), terminais de autoatendimento ATM, máquinas de conveniência All-Foods 24/7 e clínica Ripperdoc Viktor Vector totalmente operacionais (Fase 4 - 100%), sistema de habitação vertical instanciada por Routing Buckets com suporte a múltiplas portas de acesso, blips dinâmicos no minimapa, interior canônico de V calibrado contra clipping de paredes, mecânica diegética de saída com anel holográfico e WorldUI, Build Mode livre em 360° e detecção de colisões OBB via PolyZone 3D (Fase 5 - 100%), seletor de despertar neural diegético Kiroshi (`ls_spawn`) com primeiro spawn obrigatório no Megabuilding H10 e radar holográfico geodésico, ferramenta de inspeção e telemetria espacial autoritativa (`open77_coords`) com captura em tempo real de vetores REDengine 4 e exportação para múltiplos formatos Lua/JSON, interface NUI diegética em WebUI nativa com pivô holográfico Kiroshi de alta fidelidade (L-brackets táticos, badges de sincronização neural, rodapé diegético com keycaps `<kbd>`, glassmorphism translúcido `blur(16px)` e responsividade fluida via `clamp()` para 1080p, 1440p, 4K e Ultrawide 21:9/32:9), tela de carregamento nativa modular (`ls_loadscreen`) em estrita conformidade com o wireframe oficial de design, self-hosting via VPN de baixa latência (Radmin VPN), ferramentas de administração remota (RCON CLI), 35 recursos de sistema oficiais OPEN//77 integrados e controle de acesso criptográfico (ACL com papéis administrativos `operator`, `admin`, `moderator`, `support`).

## Tech Stack
- Languages: Lua 5.4 (Server & Client Resources em VMs isoladas), JavaScript ES6+ / TypeScript, HTML5 / CSS3 (CSS Variables, Clip-Path Polygons, Web Audio API), SQL (MariaDB 10.4+ / MySQL 8 com InnoDB, JSON e transações ACID)
- Frameworks: OPEN//77 Dedicated Server Host (.NET 8 Runtime, Build 2.31.21+op77.121), WebUI CEF / Ultralight HUD Engine
- Tools: `@open2077/mcp` (OPEN//77 Devkit MCP Server com 27 ferramentas), Node.js v22+, Lua Language Server (`.luarc.json` + `.vscode/settings.json`), HeidiSQL / XAMPP MariaDB CLI, PowerShell 7+, RCON CLI Tool (`Server/tools/rcon/`)
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
│   │   ├── lifesim_master_implementation_plan.md # Plano mestre de implementação (Fases 1 a 9)
│   │   ├── ls_housing_free_decoration_polyzone_spec.md # Especificação técnica do Housing OBB
│   │   ├── mcp_install.md              # Documentação de setup do devkit MCP
│   │   └── stack.md                    # Detalhamento de stack e dependências reais
│   ├── guidelines/
│   │   ├── CYBERPUNK_NATIVE_UI_DESIGN_SPEC.md  # Especificação técnica do Design System Kiroshi
│   │   ├── code_style.md               # Diretrizes de estilo de código Lua 5.4 e NUI
│   │   └── ui_ux.md                    # Tokens visuais Kiroshi e regras de UX nativa
│   ├── memory/
│   │   ├── active_task.md              # Estado da tarefa atual em execução
│   │   ├── changelog.md                # Histórico de entregas e versões (v0.0.1, v0.0.2)
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
├── AGENTS.md                           # Regras Primordiais do Projeto (Documentação Oficial https://open2077.net/docs)
├── GDD_Website/                        # Website do Game Design Document (GDD)
│   └── project_cp2077_lifesim.html     # Dashboard executivo interativo do GDD (Tailwind + Chart.js)
├── Main_Website/                       # Portal e Website oficial do servidor
│   └── README.md                       # Documentação do portal
└── Server/                             # Servidor Dedicado OPEN//77 (Build 2.31.21+op77.121)
    ├── .agent/                         # Espelho local do cortex e diagnósticos forenses
    │   ├── logs/                       # Bundles de diagnóstico e incidentes (Logs 0 a 24)
    │   ├── overview/
    │   │   └── PROJECT_STATUS.md       # Cópia espelhada da visão geral
    │   └── server-commands/
    │       └── Comandos.txt            # Documentação in-game dos comandos administrativos /vitals e /coords
    ├── .luarc.json                     # Configuração espelhada de diagnósticos Lua
    ├── acl.jsonc                       # Controle de acesso e permissões administrativas (Owner viccs, roles admin/mod/support)
    ├── open77-client.d.lua             # Tipagens nativas do runtime do cliente (varargs e exports)
    ├── open77-manifest.d.lua           # Stubs de declaração para manifestos OPEN//77
    ├── open77-server.d.lua             # Tipagens nativas do runtime do servidor (varargs e exports)
    ├── resources/                      # Catálogo de recursos do servidor (47 resources ativos)
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
    │   │       ├── ls_ui/              # [REWORK HOLOGRÁFICO - 100%] NUI Diegética Kiroshi HUD Multi-Resolução
    │   │       └── scripts/            # Automação de criação e sincronização (new-module, sync-shared)
    │   ├── open77_equipment/           # Gestão de equipamentos
    │   ├── open77_wardrobe/            # Guarda-roupa persistente
    │   ├── polyzone/                   # Delimitação de zonas tridimensionais (integração housing)
    │   └── system/                     # 35 recursos oficiais do sistema OPEN//77
    │       ├── open-voice/             # Chat por voz nativo WebRTC / Proximity
    │       ├── open77_admin/           # Painéis administrativos /admin e /adminfull
    │       ├── open77_animations/      # Emotes e animações REDengine
    │       ├── open77_appearance/      # Customização de personagem e trajes
    │       ├── open77_blips/           # Gerenciamento de marcadores no minimapa
    │       ├── open77_chat/            # Chat diegético multi-canal
    │       ├── open77_contextmenu/     # Menu contextual de interação
    │       ├── open77_coords/          # [NOVO] Ferramenta autoritativa Kiroshi Spatial Scanner (/coords)
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
  - Registro da regra em `AGENTS.md`, `.agent/guidelines/code_style.md` e `.agents/rules/`.
- **Ferramenta de Telemetria e Coordenadas Espaciais `open77_coords` (Comando `/coords`):**
  - **Interface Holográfica Kiroshi Spatial Scanner:** Modal CEF em alta definição com glassmorphism, cantoneiras cibernéticas, feedback sonoro sintético via Web Audio API e atalho `ESC`.
  - **Captura Multidimensional REDengine 4:** Extração precisa de coordenadas espaciais ($X, Y, Z$), orientação da cabeça/câmera ($ForwardX, ForwardY, ForwardZ, Pitch$), posição do osso Head ($BoneX, BoneY, BoneZ$) e Yaw/Heading normalizados ($0^\circ..360^\circ$).
  - **Múltiplos Formatos com Cópia em 1-Clique:**
    - Lua Config Table (estilo `ls_housing/shop`).
    - `vec4(x, y, z, heading)`.
    - `vec3(x, y, z)`.
    - PolyZone Point 2D (`{ x = ..., y = ... }`).
    - Open77 Ground Marker Spec (`Open77.markers.create`).
    - Spawner de NPC / Ped com vetor de visão da cabeça.
    - JSON Data Object.
  - **Alternador de Precisão Decimal:** Ajuste dinâmico entre 2, 4 ou 6 casas decimais.
  - **Segurança Autoritativa ACL:** Restrição estrita no servidor para papéis administrativos (`admin`, `moderator`, `support`) configurados no `Server/acl.jsonc`.
- **Servidor Dedicado OPEN//77 Totalmente Operacional (Release v0.0.2):**
  - Build `2.31.21+op77.121` configurado e validado no .NET 8 Runtime.
  - Licença Master válida (`op77_live_...`) com Run lease concedido pelo Master Server.
  - Conectividade de rede híbrida validada via Radmin VPN (`26.102.47.161:11778` UDP e `http://26.102.47.161:11779/` HTTP de download de recursos).
  - Testado e homologado com sucesso com conexões de jogadores remotos simultâneos.
- **Controle de Acesso Administrativo (ACL & In-Game Super Admin):**
  - Papel `operator` configurado no `Server/acl.jsonc` com comandos completos e atalhos rápidos (`/noclip`, `/fly`, `/god`, `/heal`, `/car`, `/dv`, `/goto`, `/bring`, `/tp`, `/weapons`, `/gun`, `/announce`, `/kick`, `/ban`).
  - Principal vinculado diretamente à identidade criptográfica Master do criador (`userId: c03e8ff9-22ce-4c15-ac39-5f435a07f5ba`, usuário `viccs`) com permissões irrestritas (`*`).
  - Suporte completo às interfaces administrativas in-game do `open77_admin`: `/admin` (menu lateral tático com setas) e `/adminfull` (painel em tela cheia com mouse).
  - Ferramenta de linha de comando remota RCON (`Server/tools/rcon/cli.mjs`) para comandos sem necessidade de cliente conectado.
- **Banco de Dados MariaDB Integrado:**
  - Esquema `open77_lifesim` operando no XAMPP MariaDB (porta 3306).
  - Tabela de rastreamento de migrações `ls_schema_migrations` e tabelas de domínio ativas:
    - `ls_players` (v1) - Registro de jogadores e dados JSON persistentes.
    - `ls_vitals` (v1) - Atributos fisiológicos e carimbos de decaimento.
    - `ls_cyberware` (v1) - Implantes instalados e estado neural.
    - `ls_ui_settings` (v1) - Posicionamento espacial persistente do HUD Kiroshi.
    - `ls_accounts` (v1) - Saldos bancários e em carteira.
    - `ls_transactions` (v1) - Log de auditoria financeira ACID.
    - `ls_player_apartments` (v1) - Contratos imobiliários e senhas biométricas.
    - `ls_apartment_furniture` (v1) - Mobílias com coordenadas 3D, rotações e templates.
    - `ls_player_spawns` (v1) - Registro do último local de spawn e coordenadas geodésicas.
- **Módulo `ls_data` (Fase 1 - 100% Concluída):**
  - Gerenciador de migrações SQL declarativo com validação de checksum e isolamento por módulo.
  - `CacheService` síncrono em memória com flush assíncrono em thread contínua (5 min) e persistência garantida na desconexão do jogador e interrupção de recurso.
  - Registro de perfis de cidadão indexados pela chave de persistência durável `license`.
- **Módulo `ls_core` (Fase 1 - 100% Concluída & Estabilizada):**
  - Roteamento de sessão via máquina de estados de 5 fases (`connected`, `loading`, `loaded`, `rejected`, `dropped`).
  - Gate de prontidão da plataforma (`open77:session:gameplayReady`) com watchdog para sincronização completa de perfil.
  - Registro de módulos (`registerModule`) com limite de cota de memória para State Bags (máximo de 2048 bytes por módulo).
  - Posicionamento seguro inicial (`spawnDefault` nos Badlands) e comandos administrativos protegidos (`/ls_goto`, `/ls_bring`, `/ls_status`, `/ls_modules`).
  - **Serviço de Placement Síncrono e Não-Yielding:** Removidos pontos de suspensão assíncrona (`Wait`) para total compatibilidade com exportações do Open77 (`exports.ls_core:place`), com permissões nativas completas (`players.life.read`, `players.screen`, `players.life.freeze`, `players.teleport`).
  - **Isolamento Espacial por Routing Buckets:** Roteador autoritativo de dimensões virtuais (`assignBucket`) para instâncias residenciais e interiores sem vazamento de áudio ou colisões.
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
- **Módulo de Habitação Vertical e Build Mode `ls_housing` (Fase 5 - 100% Concluída & Blindada):**
  - **Suporte a Múltiplas Portas de Entrada e Blips Dinâmicos:**
    - Arquitetura de configuração flexível em `doorCoords`: aceita objeto único ou array com múltiplos acessos por complexo (ex: Megabuilding H10 com Porta Principal 0705 no 8º andar e acessos nos corredores do 7º e 8º andares).
    - Blips individuais mapeados no minimapa via `Open77.map.createPin`.
    - Rastreamento autoritativo da porta de entrada do jogador (`loc.doorIndex`), garantindo que na saída ele retorne à porta exata por onde entrou.
  - **Calibração Canônica do Apartamento de V (Megabuilding H10):**
    - Coordenadas interiores canônicas da REDengine 4: sala de estar (`x = -1380.58, y = 1271.44, z = 123.06, heading = 270.00`).
    - Ponto de saída interno (`interiorExitCoords`): `x = -1394.80, y = 1277.50, z = 123.08, heading = 85.00`.
    - Eliminação completa de bugs de queda no vazio e clipping de paredes.
    - Delimitação tridimensional via `polyzone` calibrada para o piso acabado e teto (`minZ = 122.5, maxZ = 126.5`).
  - **Mecânica Diegética de Saída do Apartamento:**
    - Registro automático de anel holográfico de chão 3D (`Open77.markers.create`) e card WorldUI (`[E] Porta de Saída`) ao entrar no interior.
    - Fallback de proximidade física direta (< 2.5m) acionado com tecla `[E]`.
    - Restituição autoritativa no mundo público (Routing Bucket 0) na porta externa original.
  - **Persistência MariaDB Direta e Resiliente:**
    - Inclusão da permissão `"database.access"` no manifesto `open77.lua`.
    - Operações assíncronas do MariaDB gerenciadas diretamente pelo driver nativo com corrotinas `CreateThread`, eliminando stalls de `export_yielded`.
    - Sincronização de Unix Epoch real na inicialização contra bugs de data de 1970 (`rent_due_unix`).
  - **Anti-Overlap de Interface NUI:**
    - Ocultação dos marcadores 3D e cards WorldUI enquanto o terminal residencial CEF estiver aberto, restaurando a visão limpa.
  - **Build Mode com Movimentação Livre & PolyZone OBB:**
    - Fim da grade rígida: substituição por raycast tridimensional contínuo no piso e rotação Yaw $360^\circ$ livre (`Scroll` ou `Q/E`).
    - Validação de 4 vértices do Oriented Bounding Box (OBB) do móvel contra o `PolyZone` 3D do apartamento em tempo real.
    - Prevenção matemática de atravessamento de paredes e sobreposição indevida com mobílias existentes.
    - Shader holográfico diegético Kiroshi: Verde/Ciano (`#00ff9d`) para posições válidas e Vermelho (`#ff003c`) para colisões.
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

## Incident Resolutions & Diagnostic Forensics (Logs 0 a 24)
- **Log 0 a 13 (Fundação, Conectividade e Validação de Ambiente):**
  - Inicialização do host .NET 8, configuração do XAMPP MariaDB, registro da chave Master, validação de portas UDP/HTTP e correção de dependências globais.
- **Log 14 (Falha de Ativação de Recursos / FiveM Incompatibilities):**
  - Removidas chamadas legadas (`RegisterNUICallback`, `PlayerId()`, `NetworkIsPlayerActive()`) que quebravam o pipeline CEF no OPEN//77.
- **Log 15 (Stall na Conexão do Personagem & Falha de Require no Servidor):**
  - Identificado erro fatal no servidor onde `require('@polyzone')` gerava `attempt to call a nil value` durante o boot, travando a fila de carregamento e congelando o cliente no Checkpoint 04 ("Prepare your character").
  - Substituída a dependência de require no servidor por algoritmo matemático puro em Lua de Winding Number / Raycasting (`isPointInPolygon`).
  - Correção de retorno booleano em query de banco no `ls_economy` e guarda para coordenadas em `ls_economy/client/blips.lua`.
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
- **Log 19 (Bundle de Diagnóstico de Pré-Release v0.0.2):**
  - Coletado em 2026-10-03 02:43:57 UTC-3 / 05:43:57 UTC com client package `2.31.21+op77.124` e launcher `2.31.21+op77.121`.
  - Verificação de integridade de módulos RED4ext, REDscript (`redscript_rCURRENT.log`) e projeções de estado (`state/projection.json`).
  - Servidor em `26.102.47.161:11778` operando na versão `0.1.0`, protocolo `1.44` e gameBuild `23100`.
- **Log 20 (Falha de Débito de Moeda e Exports de Banco de Dados):**
  - Identificado que o módulo `ls_data` não exportava formalmente as funções `query`, `update` e `execute`, causando falhas silenciosas nas operações do `ls_economy` e impedindo a dedução de saldo de aluguel/compra.
  - Declaradas e registradas todas as exportações no `ls_data` (`query`, `update`, `execute`, `transaction`).
  - Adicionados exports autoritativos no `ls_economy`: `removeBank`, `addBank`, `removeCash`, `addCash`, `getBalance`.
  - Implementado fallback automático para dinheiro vivo (`Cash`) no `ls_housing/server/apartments.lua` e `furniture.lua`.
- **Log 21 (Crash no Comando `/coords` e Falha de Gatilho [E] no `ls_housing`):**
  - **Diagnóstico do `/coords`:** O runtime do REDengine 4 / Open77 retorna múltiplos valores numéricos soltos (`x, y, z`) em `Open77.character.position()` (C++ `LuaCharacterPosition`), e não uma tabela. A chamada `local pos = Open77.character.position()` atribuía apenas o primeiro valor float à variável `pos`, causando o crash fatal `open77_coords/client/main.lua:37: attempt to index a number value (local 'pos')` e impedindo a exibição do CEF.
  - **Correção do `/coords`:** Refatorada a função `captureSpatialSnapshot()` para desempacotar `local px, py, pz = Open77.character.position()` com suporte a 3 números ou tabela, fallback para `Open77.character.state().position`, cálculo de vetor frontal via quaternions e yaw, sincronização de snapshot e adição de permissões `"webui.system"`, `"network.client"` e `files { "web/**" }` no manifesto `open77.lua`.
  - **Diagnóstico do `ls_housing`:** O card 3D criado por `open77_worldui` delega o disparo para `open77_interactions`, emitindo `ls:housing:openDoorTarget` com uma tabela de `payload` contendo `interactionId = "open77_worldui_housing_door_<id>"`, sem o campo `aptId`. O código antigo esperava `args.aptId`, resultando em `nil` e impedindo o disparo de `ls:housing:requestInfo` para o servidor.
  - **Correção do `ls_housing`:** Implementada extração regex de `aptId` a partir de `args.interactionId`, detecção da tecla física [E] via `Open77.input.isDown("e")` com edge-triggering, reescrita de `getLocalCoords()` e `getPlayerCoords()` para desempacotar retornos múltiplos de números, inclusão de `page:show()` no recebimento de dados e declaração das dependências `open77_worldui` e `open77_interactions` no manifesto.
- **Log 22 (Overlap de Marcadores 3D com Interface NUI e Centralização de Coordenadas):**
  - Marcadores 3D holográficos e cards WorldUI permaneciam visíveis e flutuando por cima do modal CEF aberto.
  - Implementada limpeza atômica dos marcadores e cards WorldUI via `clearDoorInteractions()` quando `housing:showInfo` é recebido, restaurando-os apenas no fechamento do modal (`housing:close`).
  - Criação de guia padronizado em [config.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/shared/config.lua) para manutenção intuitiva de coordenadas com 1-clique via `/coords`.
- **Log 23 (Acesso ao Painel Residencial, Múltiplas Portas e Blips Individuais):**
  - Implementado suporte completo a múltiplas portas de entrada por complexo residencial em `doorCoords = { ... }`.
  - Registro de blips dinâmicos no mapa para cada porta com labels e raios customizados.
  - Rastreamento autoritativo de qual porta externa o jogador utilizou para entrar, persistindo em `Housing.playerLocations[playerId].doorIndex`.
- **Log 24 (Resolução Crítica de Persistência MariaDB, Void Death e Interior Canônico de V):**
  - **Problema de Morte no Vazio e Clipping:** As coordenadas antigas do Megabuilding H10 Apto 0705 (`interiorCoords` com `z = 111.10` e posteriormente `x = -1392.50, y = 1296.50, z = 119.10`) estavam localizadas no fosso de ar livre do átrio e em paredes ocas entre módulos, fazendo o personagem clipar e cair no vazio.
  - **Solução das Coordenadas:** Calibradas as coordenadas canônicas oficiais da REDengine 4 para o interior mobiliado do apartamento do V (`x = -1380.58, y = 1271.44, z = 123.06, heading = 270.00`) e porta de saída interior (`interiorExitCoords`: `x = -1394.80, y = 1277.50, z = 123.08`), com `polyzone` 3D englobando com precisão o piso e teto acabados (`minZ = 122.5, maxZ = 126.5`).
  - **Problema de Persistência do Aluguel/Compra:** O manifesto `ls_housing/open77.lua` não possuía a permissão `"database.access"`, e o `Database.query` chamava `exports["ls_data"]`, que causava `export_yielded` no Open77 ao pausar corrotinas assíncronas do MariaDB através de exports. O erro era engolido por `pcall`, retornando tabelas vazias `{}`.
  - **Solução do Banco de Dados:** Adicionada a permissão `"database.access"`, substituídas chamadas via export por acesso direto ao driver `MySQL` / `Open77.database` com `.await`, e envelopados todos os handlers de eventos de rede em corrotinas `CreateThread`.
  - **Bug do Relógio Epoch:** Devido à falha anterior da query de horário no banco, `getEpochTime()` caía no fallback do tempo de ligamento do servidor (`GetGameTimer() / 1000 = 262s`), gravando `rent_due_unix` como `259462` (ano de 1970). A interface WebUI comparava esse valor com a data atual e julgava o aluguel permanentemente vencido. Implementada sincronização mestre de horário com MariaDB logo no boot do servidor.
  - **Mecânica Completa de Saída:** Criação de anel holográfico e card WorldUI (`[E] Porta de Saída`) no interior do imóvel com restituição do jogador no mundo público (Bucket 0) na porta externa exata de entrada.

## Work-in-Progress Items
- **Fase 6: Módulo `ls_jobs` & `ls_factions` (Carreiras, Reputação Urbana & Fixers):**
  - Scaffolding de `ls_jobs`: contratos de Fixers dinâmicos, entregas/freelancer, turnos e progressão salarial.
  - Scaffolding de `ls_factions`: progressão de reputação de gangues (Moxes, Maelstrom, Tyger Claws, Valentinos) e canais de rádio corporativos/policiais.
  - Sistema de ponto e serviço com cálculo de produtividade e drenos econômicos.

## Known TODOs or Missing Parts
- Implementar `ls_jobs` e `ls_factions` (Fase 6).
- Implementar `ls_medical` avançado com resgate Trauma Team Platinum aéreo via AV (Fase 7).
- Implementar `ls_social` com rede social urbana in-game Kiroshi Net (Fase 8).
- Auditoria final de concorrência, stress test de banco de dados e empacotamento de produção (Fase 9).
