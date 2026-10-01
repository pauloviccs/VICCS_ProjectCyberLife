# Changelog

## [2026-10-01] - Sincronização Geral de Projeto, Memória e Diretrizes

### Adicionado
- **Diretrizes de Desenvolvimento (`.agent/guidelines/`):**
  - `code_style.md`: Convenções obrigatórias para Lua 5.4, autoridade do servidor, tipagem estrita de IDs (64-bit opacos vs session IDs numéricos), polling adaptativo sem `Wait(0)` ocioso e regras de transação com locks InnoDB.
  - `ui_ux.md`: Especificação do Kiroshi Design System para NUI em Svelte 5 (WebView2), tokens de cores, glassmorphism com `backdrop-blur-md`, tipografia tabular mono, chanfros visuais e micro-interações sem VDOM.
- **Backlog Estruturado em 9 Fases:** Atualizado `.agent/memory/todos.md` integrando o plano de implementação completo de Night City Life-Sim RP (Fases 0 a 8).

### Atualizado
- **Sincronização de Status Geral:** Atualizado `.agent/overview/PROJECT_STATUS.md` mapeando todos os módulos do repositório (`Server/`, `GDD_Website/`, `Main_Website/`, `.agent/`, `.agents/`), ferramentas MCP ativas e recursos tipados.
- **Homologação da Stack Real:** Atualizados `.agent/context/stack.md`, `.agent/context/architecture.md` e `.agent/context/database_schema.md` para refletir as capacidades reais da plataforma OPEN//77 (MariaDB 10.11+ / MySQL 8 com InnoDB e `database.access`, aliado a `CacheService` Lua in-memory com Write-Behind, descartando dependências externas incompatíveis de Postgres/Redis).
- **Lançamento Inicial no GitHub (v0.0.1):** Inicializado o repositório Git, configurado `.gitignore`, gerado o `README.md` principal e efetuado o push da branch `main` com tag `v0.0.1` em `https://github.com/pauloviccs/VICCS_ProjectCyberLife.git`.
- **Estado de Memória Ativa:** Atualizado `.agent/memory/active_task.md` finalizando a etapa de fundação e preparando o início da Fase 1 (`server.jsonc`, `ls_core`, `ls_data`).

---

## [2026-09-30] - Inicialização do Ecossistema OPEN//77 e Cortex de Memória

### Adicionado
- **Documentação Técnica Oficial:** Criado `.agent/context/documentation.md` com especificações do OPEN//77 (autoridade do servidor, ciclo de vida de recursos `open77.lua`, IDs de 64 bits da REDengine, compatibilidade FiveM, NUI Chromium WebView2 e APIs de dados TweakDB).
- **Guia do Devkit MCP:** Criado `.agent/context/mcp_install.md` com catálogo de ferramentas e métodos de instalação.
- **Integração MCP na IDE:** Instalado `@open2077/mcp` via `npx` e registrados os esquemas das 27 ferramentas em `C:\Users\oldga\.gemini\antigravity-ide\mcp\open77-devkit` e atualizado `mcp_config.json`.
- **Tipagem Lua 5.4:** Gerados `open77-client.d.lua`, `open77-server.d.lua` e `.luarc.json` em `Server/` para a build `2.31.13+op77.78`.
- **Skill Especializada `open2077-dev`:** Criada em `.agents/skills/open2077-dev/SKILL.md` (local workspace) e `C:\Users\oldga\.gemini\config\skills\open2077-dev\SKILL.md` (global).
- **Procedimento Operacional Padrão:** Criado `.agent/workflows/open2077_dev_skill.md` com diretrizes para criação de recursos.
- **Sincronização do Projeto:** Criado `.agent/overview/PROJECT_STATUS.md` e estrutura da pasta `.agent/memory/` (`active_task.md`, `todos.md`, `changelog.md`).
- **Contexto de Arquitetura & Stack:** Criados `.agent/context/architecture.md`, `.agent/context/stack.md` e `.agent/context/database_schema.md` consolidando os requisitos técnicos do servidor.
