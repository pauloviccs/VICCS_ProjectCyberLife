# Active Task

## Tarefa Atual
- **Nome:** Sincronização Geral do Cortex de Memória e Preparação da Fase 1 (Núcleo do Servidor)
- **Status:** Sincronização concluída com sucesso. Pronto para execução da Fase 1.
- **Responsável:** UEoE 1

## Entregas Desta Etapa
- [x] Leitura profunda e consolidação dos arquivos de contexto (`OPEN77_LIFESIM_PLANO_IMPLEMENTACAO.md`, `agent_context_open77_lifesim.md`, `architecture.md`).
- [x] Homologação da stack real: alinhamento com MariaDB 10.11+ / MySQL 8 (InnoDB + JSON) e `CacheService` Lua in-memory.
- [x] Criação dos nós ausentes em `.agent/guidelines/` (`code_style.md` e `ui_ux.md`).
- [x] Atualização completa de `stack.md`, `architecture.md` e `database_schema.md`.
- [x] Sincronização do `.agent/overview/PROJECT_STATUS.md`.
- [x] Reestruturação do backlog em `.agent/memory/todos.md` baseado no plano de 9 fases.
- [x] Registro da sincronização em `.agent/memory/changelog.md`.

## Próximo Marco de Execução (Fase 1: Núcleo do Servidor)
- [ ] Criar arquivo de configuração `Server/server.jsonc` (portas, database connection, autorizações e lista de inicialização).
- [ ] Criar a estrutura base de diretórios dos resources em `Server/resources/gamemodes/lifesim/`.
- [ ] Scaffolding do resource primordial `ls_core` (manifesto `open77.lua`, `config.lua`, entrypoint do servidor e event bus).
- [ ] Scaffolding do resource de dados `ls_data` (migrações SQL MariaDB e `CacheService` com worker Write-Behind).
