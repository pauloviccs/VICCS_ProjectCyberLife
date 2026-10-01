# Project TODOs

## Fase 0: Fundação, Ambiente e Tooling (Concluída)
- [x] Sincronizar documentação técnica oficial OPEN//77 (`.agent/context/documentation.md`).
- [x] Configurar Devkit MCP (`@open2077/mcp`) com 27 ferramentas registradas na IDE.
- [x] Gerar stubs de tipagem Lua 5.4 (`open77-client.d.lua`, `open77-server.d.lua`) e `.luarc.json`.
- [x] Criar skill de desenvolvimento `open2077-dev` e SOP de criação de recursos.
- [x] Resolver divergências técnicas (MariaDB/MySQL InnoDB, `database.access`, `CacheService` in-memory).
- [x] Criar diretrizes de estilo e design system em `.agent/guidelines/` (`code_style.md`, `ui_ux.md`).
- [x] Sincronizar visão geral do projeto (`PROJECT_STATUS.md`) e cortex de memória.

## Fase 1: Núcleo, Identidade, Dados e Event Bus (Em Aberto / Imediato)
- [ ] Criar estrutura base de pastas em `Server/resources/gamemodes/lifesim/`.
- [ ] Criar configuração do servidor `Server/server.jsonc` (portas, database connection, resources.load).
- [ ] Implementar `ls_core`: tunables globais, validação de identidade (`Open77.getIdentifier`), player session tracking, event bus e comandos administrativos.
- [ ] Implementar `ls_data`: migrações SQL MariaDB (`players`, `characters_vitals`, etc.), repositórios e `CacheService` com worker de Write-Behind (5 minutos + disconnect + stop).

## Fase 2: Vitais & HUD Kiroshi (Svelte 5)
- [ ] Implementar `ls_vitals`: loop autoritativo de decaimento (fome, sede, energia, higiene, estresse) e API de consumo de alimentos/itens.
- [ ] Implementar `ls_ui`: scaffolding do projeto Svelte 5 com Tailwind CSS e montagem do Biomonitor Kiroshi diegético no WebView2.
- [ ] Integrar ponte NUI (`SendNuiMessage` e callbacks `fetch`) entre `ls_vitals` e `ls_ui`.

## Fase 3: Cyberware, Estabilidade Neural e Ciberpsicose
- [ ] Implementar `ls_cyberware`: catálogo de implantes, limite de capacidade corporal, geração de calor neural por uso de habilidades.
- [ ] Implementar medidor de estabilidade neural, alucinações visuais/auditivas em níveis críticos e disparo de alerta MaxTac.

## Fase 4: Economia, Banco e Inventário
- [ ] Implementar `ls_economy`: transações atômicas com `SELECT ... FOR UPDATE`, transferências bancárias, impostos diários e drenos monetários (*money sinks*).
- [ ] Implementar `ls_inventory`: sistema de inventário por peso/slots com suporte a bolsos, porta-malas e baús.

## Fase 5: Habitação Vertical, Buckets e Build Mode
- [ ] Implementar `ls_housing`: gerenciamento de Megabuildings, elevadores, portas e instanciamento via `SetPlayerRoutingBucket`.
- [ ] Integrar Build Mode com limites `PolyZone` para colocação autoritativa de mobílias.

## Fase 6: Carreiras e Facções
- [ ] Implementar `ls_jobs`: carreiras corporativas, serviços de entrega, turnos e progressão salarial.
- [ ] Implementar `ls_factions`: reputação de gangues, contratos de Fixers, rádio policial NCPD e Trauma Team.

## Fase 7: Imersão Social & Vida Noturna
- [ ] Implementar `ls_social`: interações de bares, animações sincronizadas, canais de voz 3D (`open-voice`) e aplicativo de celular.

## Fase 8: Hardening, Testes de Carga e Alpha Fechado
- [ ] Instrumentação de telemetria e métricas com Prometheus (`/docs/metrics`).
- [ ] Auditoria de segurança de eventos e testes de estresse com bots virtuais.
- [ ] Lançamento do Alpha Fechado do servidor.
