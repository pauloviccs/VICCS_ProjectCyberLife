# Relatório Técnico: Sincronização Integral do Contexto OPEN//77

**Build Oficial do Servidor:** `2.31.21+op77.124` (Protocolo de Rede `1.44`)  
**Data da Sincronização:** Outubro de 2026  
**Fonte Primordial:** [Documentação Oficial OPEN//77](https://open2077.net/docs)  
**Engenheiro Responsável:** The Universal Engineer (UEoE 1)

---

## 1. Visão Geral da Sincronização

Todos os arquivos da pasta `.agent/context/` e `.agent/overview/` foram meticulosamente auditados e alinhados à especificação canônica do ecossistema **OPEN//77 (REDengine 4)**. Foram expurgados conceitos legados de FiveM/RedM e alucinações de APIs externas.

### Arquivos Sincronizados
1. [`.agent/context/documentation.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/documentation.md): Expandido para 14 seções completas contendo todas as regras do runtime, sandboxing, barramento de eventos, CEF WebUI nativo, MariaDB assíncrono, State Bags, PolyZone e armadilhas de migração.
2. [`.agent/context/OPEN77_CORE_AGENT_CONTEXT_FRAMEWORK.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/OPEN77_CORE_AGENT_CONTEXT_FRAMEWORK.md): Atualizado com a Build `2.31.21+op77.124`, permissões explícitas de State Bag (`state.write`) e arquitetura CEF Kiroshi.
3. [`.agent/context/stack.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/stack.md): Tecnologias do host atualizadas (Lua 5.4 isolado, MariaDB via MySqlConnector oficial, Vanilla HTML5/CSS3 CEF WebUI).
4. [`.agent/context/architecture.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/architecture.md): Mapeamento de papéis dos 9 recursos Life-Sim ativos e barramento IPC.
5. [`.agent/context/database_schema.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/database_schema.md): Sincronizado com as 10 tabelas reais do banco `open77_lifesim`, substituindo `os.time()` proibido por `GetUnixTime()` e documentando `MySQL.update.await` / `MySQL.transaction.await`.
6. [`.agent/context/contexto_de_desenvolvimento_resource_open_77.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/contexto_de_desenvolvimento_resource_open_77.md): Correção de formato de manifesto para `open77.lua` canônico e permissões reais.
7. [`.agent/context/lifesim_master_implementation_plan.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/lifesim_master_implementation_plan.md): Remoção de referências obsoletas a Vite/Svelte e `SendNUIMessage`, estabelecendo o padrão nativo Vanilla Kiroshi.
8. [`.agent/overview/PROJECT_STATUS.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/overview/PROJECT_STATUS.md) & [`Server/.agent/overview/PROJECT_STATUS.md`](file:///c:/Games/VICCS_CyberpunkServer/Server/.agent/overview/PROJECT_STATUS.md): Sincronização do status mestre com 47 recursos ativos e histórico de incidentes 0 a 24.

---

## 2. Pilares Críticos Validados com a Documentação Oficial

### A. Sandboxing Severo do Lua 5.4 (Server-Side)
- **Bibliotecas Removidas por Segurança:** `os`, `io`, `debug`, `package`, `require`, `load`, `loadfile`, `dofile`, `collectgarbage`.
- **Impacto Direto:** Tentar chamar `os.time()` ou `require()` no servidor causa crash imediato do recurso (`attempt to index a nil value`).
- **Padrão Canônico:** 
  - Horário de relógio (Unix timestamp): `Open77.time.unix()` ou `GetUnixTime()`.
  - Cronômetro/deltas monotônicos: `GetGameTimer()` ou `Open77.time.monotonic()`.

### B. Arquitetura CEF WebUI (Kiroshi HUD & Menus)
- **Mitos FiveM Destruídos:** `SendNUIMessage`, `RegisterNUICallback`, `SetNuiFocus` **NÃO EXISTEM**.
- **Padrão Canônico OPEN//77:**
  - Criação no cliente:
    ```lua
    local page = Open77.webui.create{
        url = "nui://ls_ui/web/index.html",
        visible = true
    }
    ```
  - Envio de dados (Lua -> JS): `page:send("eventName", data)`
  - Recepção de dados (JS -> Lua): `page:on("eventName", function(data) ... end)`
  - No Navegador (app.js): `Open77.on("eventName", handler)` e `Open77.emit("eventName", data)`.

### C. State Bags Replicadas e Permissões
- O servidor só pode persistir dados em State Bags (`Entity(ent).state:set(...)` ou `Player(src).state:set(...)`) se o manifesto `open77.lua` declarar explicitamente a permissão:
  ```lua
  server_permission "state.write"
  ```
- **Atenção:** 5 métodos da tabela de state bag são sombreados (`get`, `set`, `all`, `clear`, `revision`). Propriedades com esses nomes devem ser acessadas via método: `state:get("get")`.
- `Open77.state.save` / `load` é um stash volátil de 64 KiB para reloads de scripts durante desenvolvimento, e não o barramento de sincronização de rede.

### D. Banco de Dados MariaDB (`open77_mysql`)
- Padrão moderno assíncrono baseado em C# `MySqlConnector`.
- Métodos oficiais: `MySQL.query.await()`, `MySQL.single.await()`, `MySQL.scalar.await()`, `MySQL.insert.await()`, `MySQL.update.await()`, `MySQL.transaction.await()`.
- Utilização estrita de `?` como placeholder para prevenir SQL Injection.

---

## 3. Próximos Passos
- Avançar para a **Fase 6** do Life-Sim (`ls_jobs` e `ls_factions`), aplicando estritamente as regras de manifesto `open77.lua`, permissões `state.write`, transações MariaDB assíncronas e UI nativa CEF.
