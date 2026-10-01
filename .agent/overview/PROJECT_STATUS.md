# Project Overview

## Project Name
OPEN//77: Night City Life-Sim RP (VICCS Cyberpunk Server)

## Description
Servidor dedicado multijogador para Cyberpunk 2077 (v2.31 / Phantom Liberty) focado em simulação social e biológica profunda (*Life-Sim RP*), inspirado em dinâmicas de The Sims 4 transpostas para o cenário distópico de Night City. O projeto contempla gestão vital/metabólica contínua, risco de ciberpsicose com intervenção MaxTac, habitação multi-instanciada via *Routing Buckets*, economia circular com drenos monetários (*money sinks*), interfaces NUI em Chromium WebView2 (Svelte 5) e persistência de alto desempenho com transações ACID (MariaDB 10.11+ / MySQL 8 com InnoDB e CacheService em memória na VM Lua com Write-Behind).

## Tech Stack
- Languages: Lua 5.4 (Server & Client Resources com VMs isoladas), TypeScript / JavaScript (WebUI NUI & Devkit Tooling), HTML5 / CSS3, SQL (MariaDB 10.11+ / MySQL 8 com InnoDB e colunas JSON)
- Frameworks: Svelte 5 (Runes: `$state`, `$derived`, `$effect`) + Tailwind CSS (WebUI/NUI), .NET 8 Runtime (OPEN//77 Dedicated Server Host)
- Tools: `@open2077/mcp` (OPEN//77 Devkit MCP Server Build 2.31.13+op77.78), Node.js v22.17, Lua Language Server (`.luarc.json`), Antigravity IDE MCP Suite
- Services: Open77 Dedicated Server Host (.NET 8), MariaDB 10.11+ / MySQL 8 (Bridge nativa via `database.access`), `CacheService` Lua (Write-Behind in-memory com flush a cada 5m/disconnect/stop), `open-voice` (Áudio espacial 3D com oclusão geométrica)

## Folder Structure
```text
c:/Games/VICCS_CyberpunkServer/
├── .agent/                             # Cérebro de Contexto & Memória do Agente (Master Cortex)
│   ├── agents/
│   │   └── agents.md                   # Documentação de agentes e MCP
│   ├── assets/                         # Assets estáticos de documentação
│   ├── context/
│   │   ├── architecture.md             # Arquitetura, princípios e mapa de resources
│   │   ├── database_schema.md          # Esquemas MariaDB InnoDB e CacheService Lua
│   │   ├── documentation.md            # Documentação técnica oficial OPEN//77 compilada
│   │   ├── mcp_install.md              # Guia e status do Devkit MCP
│   │   └── stack.md                    # Detalhamento de stack e dependências reais
│   ├── guidelines/
│   │   ├── code_style.md               # Diretrizes de estilo de código Lua 5.4 e NUI
│   │   └── ui_ux.md                    # Design System Kiroshi e regras de UX para WebView2
│   ├── memory/
│   │   ├── active_task.md              # Estado da tarefa atual em execução
│   │   ├── changelog.md                # Histórico de entregas e versões
│   │   └── todos.md                    # Backlog priorizado de tarefas (9 Fases)
│   ├── overview/
│   │   └── PROJECT_STATUS.md           # Visão geral de status sincronizada
│   └── workflows/
│       └── open2077_dev_skill.md       # SOP de desenvolvimento de recursos Open77
├── .agents/                            # Customizações locais do workspace (Antigravity)
│   └── skills/
│       └── open2077-dev/
│           └── SKILL.md                # Skill nativa do workspace para OPEN//77
├── GDD_Website/                        # Website do Game Design Document (GDD)
│   ├── .agent/                         # Contexto espelhado do módulo GDD
│   └── project_cp2077_lifesim.html     # Dashboard executivo interativo do GDD (Tailwind + Chart.js)
├── Main_Website/                       # Portal e Website oficial do servidor
│   └── .agent/                         # Contexto espelhado do módulo Main Website
└── Server/                             # Diretório do servidor dedicado OPEN//77
    ├── .agent/                         # Contexto e regras de arquitetura específicas do servidor
    │   └── context/
    │       ├── OPEN77_LIFESIM_PLANO_IMPLEMENTACAO.md  # Plano de implementação em 9 fases
    │       ├── agent_context_open77_lifesim.md        # Contexto operacional detalhado
    │       ├── implementation_plan_open77_lifesim.md  # Especificações de arquitetura
    │       └── open_77_agent_context_architecture_rules.md # Regras técnicas da REDengine
    ├── .luarc.json                     # Configuração do Lua Language Server
    ├── open77-client.d.lua             # Tipagens nativas do runtime do cliente (558 KB)
    └── open77-server.d.lua             # Tipagens nativas do runtime do servidor (722 KB)
```

## Current Features Implemented
- **MCP Devkit Integrado:** `@open2077/mcp` inicializado e configurado para Antigravity IDE, Gemini CLI, Claude Code, Cursor e VS Code com 27 ferramentas ativas.
- **Tipagem Lua Completa:** `open77-client.d.lua`, `open77-server.d.lua` e `.luarc.json` gerados na raiz do servidor para a build `2.31.13+op77.78`.
- **Base de Conhecimento Oficial:** Documentação técnica completa compilada em `.agent/context/documentation.md`.
- **Diretrizes e Regras Operacionais:** Criados `.agent/guidelines/code_style.md` e `.agent/guidelines/ui_ux.md` estabelecendo padrões de codificação Lua 5.4 e Design System Kiroshi.
- **Plano de Implementação em 9 Fases:** Catalogado e consolidado em `Server/.agent/context/OPEN77_LIFESIM_PLANO_IMPLEMENTACAO.md` cobrindo desde a Fundação (Fase 0) até o Alpha Fechado (Fase 8).
- **Skill Especializada `open2077-dev`:** Instalada no workspace e no escopo global para orientar criação de recursos, autoridade de servidor e NUI.
- **GDD Interativo:** Dashboard do Game Design Document pronto em `GDD_Website/project_cp2077_lifesim.html` contendo simuladores de biometria, matriz de carreiras, economia e arquitetura.
- **Homologação da Stack Real:** Resolvidas divergências de documentação (suporte a MariaDB/MySQL com InnoDB via `database.access` e `CacheService` in-memory na VM Lua com Write-Behind).

## Work-in-Progress Items
- Estruturação do servidor dedicado: criação de `Server/server.jsonc` e diretório de resources `Server/resources/`.
- Scaffolding dos resources fundacionais: `ls_core` (config, identidade, event bus) e `ls_data` (migrations, repositórios, `CacheService`).
- Estruturação do portal `Main_Website`.

## Known TODOs or Missing Parts
- Implementar `Server/server.jsonc` com portas, permissões ACL e lista de recursos de inicialização.
- Criar a camada base de persistência (`ls_data`) com migrações SQL MariaDB e `CacheService` in-memory.
- Desenvolver o motor de necessidades vitais (`ls_vitals`) com decaimento autoritativo.
- Criar o primeiro componente de HUD Kiroshi em Svelte 5 (`ls_ui`).
