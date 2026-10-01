# OPEN//77 Night City Life-Sim RP — Plano de Implementação

> Baseado em: GDD (`project_cp2077_lifesim.html`), `documentation.md`, `SKILL.md`, `open2077_dev_skill.md`, `agents.md`, contexto de arquitetura e na documentação oficial em https://open2077.net/docs (plataforma em **ALPHA**, sujeita a mudanças de API).
> Build alvo: `2.31.13+op77.78` (ou mais recente — confirmar com `open77_validate` a cada atualização).

---

## 0. Resumo executivo

O servidor é um **gamemode modular** composto por vários resources Lua 5.4 (prefixo `ls_`) com UIs Svelte 5. A plataforma OPEN//77 já fornece: state bags, callbacks de rede, routing buckets, elevadores, portas, PolyZone, gizmos, câmeras scriptadas, voz, chat, blips, UI kit e bridge SQL. O trabalho do projeto é **compor essas peças em regras de Life-Sim**, não reinventá-las.

Entrega em **9 fases (0–8)**, mapeadas às 4 fases do GDD:

| Fase deste plano | Tema | Fase do GDD |
| :-- | :-- | :-- |
| 0 | Fundação, ambiente e tooling | (pré-requisito) |
| 1 | Núcleo: identidade, dados, cache, eventos | Fase 1 |
| 2 | Vitais + HUD Kiroshi (Svelte 5) | Fase 2 |
| 3 | Cyberware, estabilidade neural e ciberpsicose | Fase 2 (estendida) |
| 4 | Economia, banco e inventário | Fase 3 |
| 5 | Habitação, buckets e Build Mode | Fase 3 |
| 6 | Carreiras e facções | Fase 4 |
| 7 | Imersão social (voz, animações, celular) | Fase 4 |
| 8 | Hardening, carga e Alpha Fechado | Fase 4 |

---

## 1. Divergências entre o GDD e a plataforma (resolver ANTES de codar)

Encontradas ao cruzar o GDD com a documentação oficial. São as decisões mais importantes do plano.

| # | GDD / contexto diz | Documentação oficial diz | Decisão proposta |
| :-- | :-- | :-- | :-- |
| D1 | **PostgreSQL 16 + PgBouncer** | A bridge SQL suporta **somente MySQL/MariaDB**. PostgreSQL, SQLite e SQL Server **não são suportados** (https://open2077.net/docs/database). | Usar **MariaDB 10.11+/MySQL 8** com `InnoDB` (ACID, `SELECT ... FOR UPDATE`, transações) e colunas `JSON`. Onde o GDD diz "JSONB", usar `JSON`. PgBouncer deixa de existir. |
| D2 | **Redis 7** como cache de biometria/sessão | Não encontrei Redis documentado na plataforma. | Criar `CacheService` abstrato: **cache em memória na VM Lua** (tabelas) + write-behind para MariaDB. Se Redis for necessário depois, só a implementação do `CacheService` muda. Validar no MCP (`open77_search "redis"`) antes de descartar. |
| D3 | Permissão `database.query` (documentation.md) | A doc oficial usa **`database.access`**. | Usar `database.access` e validar com `open77_api`/`open77_validate`. |
| D4 | Manifesto com `open77_version 'v2.31'` (contexto de arquitetura) | Manifesto oficial usa `resource "nome"`, `version`, `server_scripts`, `permissions {}` etc. | Usar o formato oficial (seção 4 do `documentation.md`). Corrigir o arquivo de contexto do agente. |
| D5 | "Tickrate estável de 60 Hz" | Não há garantia documentada; a doc fala em ticks e schedulers por resource. | Tratar 60 Hz como **meta a medir** com Prometheus (`/docs/metrics`), não como premissa. |
| D6 | Decaimento: `-1,0%/60 s` (contexto) vs. curva do gráfico do GDD (0% em ~24 h) | Existe controle de escala de tempo do mundo (`/docs/world-time`). | Definir **relógio único**: taxas por *minuto real* como tunable, e derivar a curva do GDD. Decidir na Fase 2 (tarefa 2.1). |
| D7 | "Nunca `tonumber()` em IDs REDengine" | Player IDs de eventos chegam como string e **devem** virar número (`tonumber`) no contrato do gamemode. | São coisas distintas: **entity/REDengine IDs (64-bit) = opacos**; **player IDs de sessão = `tonumber`**. Chave de persistência = **identidade autenticada** (`Open77.getIdentifier`), nunca o ID de sessão. |
| D8 | Cliente pode chamar routing bucket etc. | Servidor é autoritativo; posição é snapshot replicado, não leitura ao vivo. | Toda regra baseada em posição = "mantido por N segundos" num tick fixo (padrão do kernel de gamemode). |

---

## 2. Arquitetura-alvo

### 2.1 Mapa de resources

```text
resources/
├── system/                     # plataforma (não alterar)
└── gamemodes/
    └── lifesim/
        ├── ls_core/            # config/tunables, identidade, personagens, event bus, logging, comandos admin
        ├── ls_data/            # migrations SQL, repositórios, CacheService, write-behind, flush
        ├── ls_vitals/          # motor de necessidades (server) + consumo
        ├── ls_cyberware/       # implantes, estabilidade neural, calor, ciberpsicose, MaxTac
        ├── ls_economy/         # contas, ledger, transferências, money sinks, tarifas
        ├── ls_inventory/       # itens, stacks, uso, catálogo
        ├── ls_housing/         # propriedades, buckets, portas, elevadores, build mode, mobília
        ├── ls_jobs/            # carreiras, turnos, salários, licenças
        ├── ls_factions/        # NCPD, Trauma Team, gangues, reputação, fixers/contratos
        ├── ls_social/          # bares, afinidade, animações, celular
        └── ls_ui/              # projeto Svelte 5 (HUD Kiroshi, apps) — ver nota abaixo
```

> **Nota NUI:** validar na doc (`/docs/ui-kit`, `/docs/resource-exports`) se múltiplas WebUIs por resource coexistem bem. Se sim, cada resource com UI própria mantém a sua pasta `web/`; se não, centralizar em `ls_ui` e receber mensagens via exports/eventos. Decidir na Fase 2.

### 2.2 Camadas e invariantes

1. **Servidor autoritativo.** Cliente envia *intenções*; servidor valida, aplica e replica.
2. **Serviços compartilhados via server exports** (`exports(name, fn)` / `Open77.exports.call(resource, name, ...):await()`), sempre validando o chamador (`GetInvokingResource()`). Valores cruzam resources **por cópia**. Exports síncronos **não podem** dar `yield`.
3. **Estado replicado via State Bags** (`Player(src).state:set(k, v, true)`), apenas deltas.
4. **Persistência em dois trilhos:**
   - *Alta frequência* (vitais, calor, posição): memória (`CacheService`) → flush em lote a cada 5 min **+ flush em disconnect + flush em resource stop**.
   - *Crítica* (dinheiro, itens, propriedade): **transação síncrona** no MariaDB (`MySQL.*.await`, `SELECT ... FOR UPDATE`). Nunca passa pelo cache.
5. **Falhas como valores:** `val` ou `nil, reason` (snake_case). Sem `pcall` de rotina; `pcall` só em parsing JSON e limites de I/O.
6. **Sem `Wait(0)` ocioso.** Polling adaptativo (500 ms ocioso, 0 ms só em interação/gizmo).
7. **Sempre validar `Open77.players` "vivo"** antes de agir server-side sobre um jogador.
8. **UI:** Svelte 5 (Runes) + Tailwind, sem React/VDOM. Estética Kiroshi (`#080E19` @85%, `#22D8E2`, `#F2F6F8`, alerta `#FF5964`, `JetBrains Mono`/`Chakra Petch`).

### 2.3 Esquema inicial do banco (MariaDB / InnoDB, `utf8mb4`)

> Prefixo `ls_` nas tabelas. Chave de jogador = identidade autenticada (`license`).

```sql
CREATE TABLE ls_accounts (
  license        VARCHAR(64) PRIMARY KEY,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_seen_at   TIMESTAMP NULL
);

CREATE TABLE ls_characters (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  license        VARCHAR(64) NOT NULL,
  first_name     VARCHAR(48) NOT NULL,
  last_name      VARCHAR(48) NOT NULL,
  lifepath       VARCHAR(24) NOT NULL,          -- nomad | streetkid | corpo
  appearance     JSON NULL,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (license)
);

CREATE TABLE ls_vitals (
  character_id   BIGINT PRIMARY KEY,
  nutrition      FLOAT NOT NULL DEFAULT 100,
  hydration      FLOAT NOT NULL DEFAULT 100,
  energy         FLOAT NOT NULL DEFAULT 100,
  hygiene        FLOAT NOT NULL DEFAULT 100,
  stress         FLOAT NOT NULL DEFAULT 0,
  updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE ls_cyberware (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  character_id   BIGINT NOT NULL,
  implant_record VARCHAR(96) NOT NULL,          -- registro TweakDB
  installed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  wear           FLOAT NOT NULL DEFAULT 0,
  INDEX (character_id)
);

CREATE TABLE ls_bank_accounts (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  character_id   BIGINT NOT NULL UNIQUE,
  balance        BIGINT NOT NULL DEFAULT 0,     -- eurodólares inteiros
  CHECK (balance >= 0)
);

CREATE TABLE ls_ledger (                         -- imutável, append-only
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id     BIGINT NOT NULL,
  delta          BIGINT NOT NULL,
  reason         VARCHAR(48) NOT NULL,           -- salary | rent | sink_cyberware | ...
  ref            VARCHAR(96) NULL,
  idempotency_key VARCHAR(64) NULL UNIQUE,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (account_id, created_at)
);

CREATE TABLE ls_items (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  owner_type     VARCHAR(16) NOT NULL,           -- character | property | vehicle
  owner_id       BIGINT NOT NULL,
  item_id        VARCHAR(64) NOT NULL,
  qty            INT NOT NULL,
  meta           JSON NULL,
  INDEX (owner_type, owner_id)
);

CREATE TABLE ls_properties (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  building_id    VARCHAR(48) NOT NULL,
  unit_label     VARCHAR(16) NOT NULL,           -- ex.: "402"
  owner_char_id  BIGINT NULL,
  bucket_id      INT NULL,                        -- alocado em runtime, não fixo
  rent_daily     BIGINT NOT NULL,
  rent_due_at    TIMESTAMP NULL,
  UNIQUE (building_id, unit_label)
);

CREATE TABLE ls_furniture (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  property_id    BIGINT NOT NULL,
  furniture_id   VARCHAR(64) NOT NULL,
  pos_x DOUBLE, pos_y DOUBLE, pos_z DOUBLE,
  rot_x DOUBLE, rot_y DOUBLE, rot_z DOUBLE, rot_w DOUBLE,
  INDEX (property_id)
);

CREATE TABLE ls_jobs (
  character_id   BIGINT PRIMARY KEY,
  job_id         VARCHAR(32) NOT NULL,
  rank_level     INT NOT NULL DEFAULT 1,
  on_duty        TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE ls_reputation (
  character_id   BIGINT NOT NULL,
  faction_id     VARCHAR(32) NOT NULL,
  value          INT NOT NULL DEFAULT 0,
  PRIMARY KEY (character_id, faction_id)
);
```

Migrações: versionadas (`ls_migrations`), aplicadas em `MySQL.ready`, grants mínimos (`SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX`). **Sem `DROP` sem revisão.**

---

## 3. Fases de implementação

Convenção: cada tarefa tem ID `F.T` (fase.tarefa). Critérios de aceite são **testáveis**.

---

### FASE 0 — Fundação, ambiente e tooling

**Objetivo:** ambiente reproduzível onde qualquer resource pode ser criado, validado e testado.

**Tarefas**

- **0.1 Acesso Alpha e licença.** Garantir Alpha access (`/alpha apply` no Discord), baixar o server e licenciar (`/docs/server-licensing`).
- **0.2 Host de desenvolvimento.** Subir servidor local (`/docs/host-a-server`, `/docs/server-startup`); registrar argumentos de startup e logging.
- **0.3 MariaDB.** Instalar, criar DB `open77` e usuário dedicado (`127.0.0.1`), grants mínimos; `database.enabled: true` em `server.jsonc`; segredo via `OP77_DATABASE_CONNECTION` (nunca em git).
- **0.4 Sonda de readiness.** Criar resource `sql_probe` (do guia) e confirmar `MySQL.scalar.await("SELECT ?", {77})`.
- **0.5 Tooling do agente.** Rodar `npx -y @open2077/mcp init` na pasta do servidor; `npx -y @open2077/mcp types` para gerar `open77-*.d.lua` + `.luarc.json`.
- **0.6 Repositório e convenções.** Monorepo, `.gitignore` (segredos, `data/`), `.agent/context.md`, guia de estilo Lua (stylua/luacheck), guia Svelte (TS estrito).
- **0.7 Scaffolding.** Gerar resources vazios com `open77_new_resource` (ou `scripts/new-resource.ps1 -Kind gamemode` para o kernel) e passar por `open77_validate`.
- **0.8 Observabilidade.** Habilitar métricas Prometheus (`/docs/metrics`) e Warden (`/docs/warden`); RCON para automação (`/docs/rcon`).
- **0.9 CI.** Pipeline: luacheck + `open77_validate` + build Svelte + testes unitários Lua puros.
- **0.10 Backup.** Rotina de dump do MariaDB + teste de restauração em DB separado (cópia de `resources/` **não** é backup).

**Critérios de aceite**
- `ensure sql_probe` imprime `connected; parameterized SELECT returned 77`.
- `open77_validate` passa em todos os resources vazios sem avisos.
- Autocomplete `Open77.*` funcionando no editor.
- Dump + restore comprovados.

**Riscos:** Alpha muda API → travar versão do build e registrar em `docs/BUILD_LOCK.md`.

---

### FASE 1 — Núcleo: identidade, dados, cache e eventos  *(GDD Fase 1)*

**Objetivo:** base sobre a qual todos os sistemas dependem.

**Resources:** `ls_core`, `ls_data`.

**Tarefas**

- **1.1 Config/Tunables.** Tabela única de constantes (taxas de decaimento, custos, limites) exposta como tunables de operador (`/docs/tunables`) e `shared_script` de config.
- **1.2 Identidade.** Resolver `license` via `Open77.getIdentifier` (`/docs/identity`); mapa `playerId → license → characterId`; **adoção segura em reload** (`Open77.players.all()` + `ensurePlayer`).
- **1.3 Admissão.** Regras de conexão e whitelist se aplicável (`/docs/connection-control`); *join-time readiness gate* (`/docs/readiness-gate`) para não agir sobre jogador não pronto.
- **1.4 Personagens.** Criação/seleção/exclusão; lifepaths; aparência via player models/morphs (`/docs/player-models`); spawn inicial com `Open77.players.teleport` (nunca escrita direta de transform).
- **1.5 Camada de dados.** Migrations versionadas; repositórios (`CharacterRepo`, `VitalsRepo`…) com queries parametrizadas; wrappers `nil, reason`.
- **1.6 `CacheService`.** API: `get/set/incr/hget/hset/flush(charId)`; *dirty set*; flush em lote a cada 5 min (tunable); **flush em `onPlayerDropped` e `onResourceStop`**; contador de métricas.
- **1.7 Barramento de eventos.** Convenção `ls:<dominio>:<acao>`; validação de payload (schema simples); rate limit por jogador; log de recusas.
- **1.8 Comandos e permissões.** ACL (`/docs/server-acl`), comandos de admin (`ls.where`, `ls.setvital`, `ls.give`, `ls.tp`), todos protegidos.
- **1.9 Callbacks.** Padrão `Open77.net.handle/call` para consultas cliente→servidor (`/docs/callbacks`).
- **1.10 Diagnóstico.** Comando `ls.where` (posição, bucket, estado, veredito da regra) — o kernel de gamemode recomenda como primeira ferramenta.

**Critérios de aceite**
- Latência de leitura/escrita no cache < 2 ms (p95) sob 128 clientes simulados.
- Reload de `ls_core` não perde jogadores conectados.
- Kill do processo → no máximo 5 min de vitais perdidos (nunca dinheiro/itens).
- Zero SQL com concatenação de string (revisão + grep no CI).

**Riscos:** VM Lua isolada por resource → estado do `CacheService` vive em `ls_data`; demais resources acessam por export assíncrono. Definir contrato de export cedo.

---

### FASE 2 — Vitais e HUD Kiroshi  *(GDD Fase 2)*

**Objetivo:** loop biológico funcional e visível.

**Resources:** `ls_vitals`, `ls_ui` (HUD).

**Tarefas**

- **2.1 Relógio e taxas (resolve D6).** Definir unidade: taxas em **% por minuto real** (defaults do contexto: nutrição −1,0; hidratação −1,5; energia −0,8; higiene −0,7), com multiplicador global e por atividade (correr, dash, trabalho). Documentar e comparar com a curva do GDD; ajustar tunables.
- **2.2 Motor de decaimento.** Tick fixo (ex.: 10 s) processando lote de jogadores; cálculo por delta de tempo (robusto a lag); clamp 0–100.
- **2.3 Efeitos por limiar.** Fome/sede/sono/higiene baixos → penalidades (stamina, regen de vida, pós-processamento via cliente). Usar APIs de stats (`/docs/player-stats`).
- **2.4 Replicação.** State bags `nutrition`, `hydration`, `energy`, `hygiene`, `neural` (só deltas com histerese para reduzir tráfego).
- **2.5 Consumo.** `RegisterNetEvent('ls:vitals:consume')` → valida item no inventário (stub até Fase 4) → aplica efeito → cache → state bag.
- **2.6 Higiene/sono na moradia.** Hooks preparados (`ls_vitals:applyFurniture`) — ativados na Fase 5.
- **2.7 HUD Svelte 5.** Componente `BiometricsHud` com `$state/$derived`, tipos TS explícitos das mensagens (`UPDATE_VITALS`), leitura por `AddStateBagChangeHandler`; `requestAnimationFrame` só quando há mudança.
- **2.8 Ponte NUI.** `SendNUIMessage` ↔ `fetch("https://open77-webui/…")` ↔ `RegisterNUICallback`; controle de foco e bloqueio de input (`/docs/input-blocking`) com `ESC` para fechar.
- **2.9 Notificações.** Usar sistema nativo (`/docs/notifications`) com linguagem diegética (Eurodólares, Kiroshi, NCPD…).
- **2.10 Persistência.** Vitais no `CacheService`; hidratar ao logar, flush conforme Fase 1.

**Critérios de aceite**
- HUD a 60+ FPS sem crescimento de nós DOM após 30 min (perfil do WebView2).
- Desvio das taxas < 2% em 1 h de simulação com lag artificial.
- Nenhum evento cliente altera vital diretamente (teste de "cliente malicioso").

---

### FASE 3 — Cyberware, estabilidade neural e ciberpsicose

**Objetivo:** risco/recompensa dos implantes.

**Resource:** `ls_cyberware` (+ painel no `ls_ui`).

**Fórmulas de referência (do simulador do GDD)**

```text
estabilidade = clamp( 100
                      - implantes * 9
                      - (1 - mult_neurobloqueador) * 30      # 1.0 em dia | 0.3 parcial | 0 esgotado
                      - (stress - 1) * 4                      # stress 1..5
                    , 5, 100 )
calor_ocular = 36.5 + implantes * 1.2 + stress * 1.5           # °C
faixas: >60 normal | 25–60 alerta de tensão | <25 (GDD UI) / <20 (regra de gatilho) ciberpsicose
```

> **Ponto a decidir (D9):** o simulador do GDD muda de estado em 25%, mas a regra de negócio diz `< 20%`. Padronizar num tunable único (`psychosis_threshold`) e alinhar UI e servidor.

**Tarefas**

- **3.1 Modelo de implantes.** Catálogo (registros TweakDB) com custo, carga de estabilidade, desgaste; consulta via `Open77.data.*` / `open77_data`.
- **3.2 Cálculo no servidor.** Função pura `computeStability(implants, blockerState, stress)` com testes unitários; recalcular em eventos (instalar/remover, dose, esforço).
- **3.3 Neurobloqueadores.** Item consumível; janela de efeito; estados `em dia/parcial/esgotado` derivados do tempo desde a última dose.
- **3.4 Stress.** Alimentado por uso de Sandevistan/Dash (`/docs/dash`), combate, necessidades críticas (integração Fase 2).
- **3.5 Habilidades.** Integrar cyberware nativo (`/docs/cyberware`, Gorilla Arms, Dash, Ground Slam, Overdrive) e *activation leases* (`/docs/ability-activation-leases`) para o servidor autorizar uso.
- **3.6 Episódio de ciberpsicose.** Ao cruzar o limiar: state bag `psychosis=true` → cliente aplica distorção de áudio/pós-processo vermelho; se houver **disparo hostil em área urbana** (zona/PolyZone), servidor abre **contrato MaxTac** (prioridade máxima) e notifica facção NCPD.
- **3.7 Ripperdoc (base).** Instalar/remover implante, cobrar (transação Fase 4), reduzir desgaste com spray criogênico.
- **3.8 UI.** Painel "Diagnóstico Neuro-Cibernético" (espelho do simulador do GDD, alimentado por dados reais).
- **3.9 Anti-abuso.** Só o servidor calcula; cliente apenas exibe; cooldown de recálculo; log de auditoria de episódios.

**Critérios de aceite**
- Testes unitários cobrem fronteiras (0–8 implantes × 3 estados × stress 1–5).
- Episódio dispara exatamente ao cruzar o limiar (histerese para não oscilar).
- Contrato MaxTac criado uma única vez por episódio (idempotência).

---

### FASE 4 — Economia, banco e inventário  *(GDD Fase 3, parte 1)*

**Objetivo:** economia circular à prova de duplicação.

**Resources:** `ls_economy`, `ls_inventory`.

**Tarefas**

- **4.1 Contas bancárias.** Uma conta por personagem; saldo `BIGINT` inteiro; `CHECK (balance >= 0)`.
- **4.2 Transações ACID.** API única `Economy.transfer(from, to, amount, reason, idemKey)`: transação → `SELECT ... FOR UPDATE` nas duas contas em ordem determinística de ID (evita deadlock) → atualiza → grava `ls_ledger`; **idempotência** via `idempotency_key UNIQUE`.
- **4.3 Ledger imutável.** Somente `INSERT`; relatórios e auditoria; job de reconciliação (soma do ledger = saldo).
- **4.4 Emissões e drenos (money sinks).** Registro central de **toda fonte** de dinheiro com **dreno correspondente**:
  - Aluguel diário à meia-noite do jogo (→ Fase 5);
  - Manutenção de cyberware/spray criogênico (→ Fase 3);
  - Seguro Trauma Team (Silver/Gold/Platinum);
  - Tarifas/pedágios/licenças NCPD;
  - Alimentação e bebidas.
  Distribuição de referência do GDD: aluguel 35 · cyberware 25 · seguro 15 · alimentação 15 · tarifas 10 (%). Painel admin com **emissão × dreno** por dia.
- **4.5 Inventário.** Itens com `item_id`, `qty`, `meta JSON`; peso/slots; mover/usar/dropar com validação servidor; operações multi-item em transação.
- **4.6 Catálogo de itens.** Comida, bebida, neurobloqueadores, sprays, ferramentas; efeitos referenciam `ls_vitals`.
- **4.7 Lojas e vendedores.** NPCs vendedores (`/docs/npcs`), menus de contexto (`/docs/context-menu`), compra = `transfer` + `addItem` em **uma** transação.
- **4.8 Terminal de rede/banco.** UI Svelte para saldo, extrato, pagamento de contas.
- **4.9 Segurança.** Nada de valores vindos do cliente; limites por minuto; alertas para transferências anômalas.

**Critérios de aceite**
- Teste de concorrência: 1.000 transferências paralelas → soma total invariável; zero saldo negativo; zero duplicação.
- Repetir o mesmo `idemKey` → efeito aplicado uma única vez.
- Reconciliação ledger×saldo = 0 divergência.

---

### FASE 5 — Habitação, buckets e Build Mode  *(GDD Fase 3, parte 2)*

**Objetivo:** apartamentos individuais instanciados nos Megabuildings.

**Resource:** `ls_housing`.

**Tarefas**

- **5.1 Catálogo de prédios.** `building_id`, saguão, elevadores, andares, unidades; mapeamento manual das coordenadas com ferramenta de captura (comando admin).
- **5.2 Alocação de buckets.** Pool reservado (ex.: 10000–19999); alocar ao entrar, **liberar ao sair/vazio**; desabilitar população ambiente no bucket; nunca fixar `bucket_id` no banco como verdade permanente.
- **5.3 Elevadores e portas.** `Open77.elevators.goTo` (`/docs/elevators`) + portas em rede (`/docs/doors`); servidor decide acesso (dono, convidados, aluguel em dia).
- **5.4 Entrada/saída.** Fluxo: interação no saguão → validação de posse → `players.teleport` com fade → set bucket → carregar mobília do bucket.
- **5.5 PolyZone 3D.** Perímetro por unidade (`/docs/polyzone`); validação **servidor** de cada objeto colocado (pontos + margem).
- **5.6 Build Mode.** Câmera aérea (`/docs/cameras`), gizmo de precisão (`/docs/gizmos`), UI de catálogo; cliente propõe → servidor valida (perímetro, limite de objetos, saldo) → grava `ls_furniture` → `server.CreateProp` (`/docs/props`).
- **5.7 Mobília funcional.** Cama ortopédica (regenera energia 100%), fogão de síntese (comida com saciedade estendida), terminal de rede (banco/mercado), chuveiro (higiene), geladeira (inventário da casa).
- **5.8 Aluguel.** Cobrança diária à meia-noite do jogo via `Economy.transfer`; inadimplência → aviso → bloqueio → despejo (regras configuráveis).
- **5.9 Visitas.** Convidar/aceitar; bucket compartilhado; voz e rede isoladas por bucket.
- **5.10 Limpeza e recuperação.** Reload/crash: reconstruir buckets ativos a partir dos jogadores online; sem "props fantasmas".

**Critérios de aceite**
- **100+ interiores simultâneos** sem sobreposição de estado (teste com bots).
- Objeto fora do perímetro é rejeitado no servidor mesmo com cliente adulterado.
- Ao esvaziar o interior, bucket volta ao pool (sem vazamento após 1 h).

**Riscos:** limites de props por bucket/cliente; medir custo de streaming antes de fixar o teto de móveis.

---

### FASE 6 — Carreiras e facções  *(GDD Fase 4, parte 1)*

**Objetivo:** renda ativa com regras de RP.

**Resources:** `ls_jobs`, `ls_factions`.

**Tarefas**

- **6.1 Framework de empregos.** Definição declarativa (id, requisitos, ranks, salário, turno); entrar/sair de serviço; pagamento por tick de trabalho via `Economy` (emissão registrada).
- **6.2 Requisitos.** Ex.: Corpo-Rat exige traje formal e higiene > 80% (lê vitais/aparência); NCPD exige ficha limpa; Trauma Team exige certificação.
- **6.3 Corporativo.** Minigames de auditoria/relatórios; escritório instanciado.
- **6.4 Trauma Team.** Chamados de biomonitor (jogador com vida crítica gera chamado), veículo/voo tático, extração e cobrança do seguro (dreno).
- **6.5 NCPD.** Viaturas, multas e prisão (PolyZone de delegacia), scanner Kiroshi; integração com contratos MaxTac (Fase 3).
- **6.6 Ripperdoc clandestino.** Licenciamento, estoque de implantes e sprays, precificação.
- **6.7 Edgerunner/Fixers.** Contratos pontuais (entregar, resgatar, espionar); *street cred* e reputação por facção (`ls_reputation`).
- **6.8 Comércio & entretenimento.** Bares/clubes arrendáveis, coquetéis com buffs, eventos.
- **6.9 Painel de facção.** Roster, cargos, permissões via ACL; auditoria.
- **6.10 Balanceamento.** Planilha salário × drenos; alvo: jogador médio trabalhando N horas cobre custos de vida com folga configurável.

**Critérios de aceite**
- Cada job passa em teste E2E (entrar → trabalhar → receber → ledger consistente).
- Emissão total/dia ≤ drenos totais/dia + margem definida (painel admin).
- Nenhum job pagável sem estar em serviço e presente na zona de trabalho (validação servidor).

---

### FASE 7 — Imersão social

**Objetivo:** convivência e atmosfera.

**Resource:** `ls_social` (+ apps no `ls_ui`).

**Tarefas**

- **7.1 Voz espacial.** Configurar `open-voice` (`/docs/voice`, lipsync): oclusão geométrica, atenuação em veículos, canais de rádio por facção, efeito de holocall (`/docs/holocall-eyes`).
- **7.2 Chat.** Canais (local, OOC, facção, rádio) com filtros (`/docs/chat`).
- **7.3 Animações e interações.** Animações sincronizadas bilaterais (`/docs/rp-animations`, `/docs/player-interactions`), attachments, `rp-kit`.
- **7.4 Afinidade.** Bônus passivos por socialização (redução de estresse/energia em bares) com anti-farm (cooldown, diminishing returns, exige interação real).
- **7.5 Celular (Smartphone).** App Svelte: contatos, mensagens, chamadas, banco, mapa, empregos; armazenamento server-side.
- **7.6 Mapa e blips.** Blips por facção/emprego/propriedade (`/docs/blips`, `/docs/native-map`).
- **7.7 Áudio ambiente e rádio.** Áudio de pacote 3D (`/docs/package-audio`).
- **7.8 Veículos.** Compra/propriedade/garagem, combustível opcional, tráfego (`/docs/vehicles`, `/docs/vehicle-ai`).

**Critérios de aceite**
- Voz isolada por bucket (jogador em apartamento A não ouve B).
- Celular funcional offline-safe (mensagens entregues ao logar).
- Bônus de afinidade não farmável com 2 contas em AFK (teste).

---

### FASE 8 — Hardening, carga e Alpha Fechado  *(GDD Fase 4, final)*

**Objetivo:** estabilidade e segurança antes de abrir à comunidade.

**Tarefas**

- **8.1 Testes de carga.** Bots simulados (`/docs/agent-testing`) escalando 32 → 128 → 256 → 512 CCU (degraus do estimador do GDD: 8 vCPU/16 GB até 32 vCPU/128 GB — **estimativas a validar**, não garantias); medir tick, GC das VMs, latência SQL, tráfego por jogador.
- **8.2 Perfil de hotspots.** Prometheus + logs; otimizar loops, lotes de flush, tamanho de payloads (usar eventos latentes para catálogos grandes).
- **8.3 Revisão de segurança.** Auditar **todos** os `RegisterNetEvent`: validação, rate limit, autorização, tipo/tamanho; fuzz de payloads; checar permissões mínimas por manifesto.
- **8.4 Anti-exploit econômico.** Testes de dupe (desconexão no meio de transação, reload, crash), limites diários, alertas.
- **8.5 Resiliência.** Reload de cada resource com jogadores online; queda do MariaDB (fila/mensagem amigável, sem corromper); restart limpo.
- **8.6 Backup/DR.** Backups agendados, restauração ensaiada, runbook de incidente.
- **8.7 Operação.** Warden (roles de staff), RCON, dashboards Grafana, alertas.
- **8.8 Conteúdo mínimo.** Tutorial de onboarding, regras do servidor, FAQ, canal de bugs.
- **8.9 Alpha Fechado.** Lista de convidados, telemetria de retenção/economia, ciclo semanal de patches; changelog público.
- **8.10 Critérios de saída.** Ver checklist abaixo.

**Critérios de aceite (Go/No-Go para Alpha Fechado)**
- Tick estável sob o CCU-alvo em horário de pico simulado por ≥ 2 h (meta 60 Hz, **medida**, ver D5).
- 0 dupes em suíte de exploit; reconciliação ledger×saldo = 0.
- 0 vazamento de memória (Lua e DOM) em soak test de 6 h.
- Restore de backup validado nas últimas 48 h.

---

## 4. Estratégia de testes (transversal)

| Nível | O que | Como |
| :-- | :-- | :-- |
| Unitário | Funções puras (decay, estabilidade, preços, ledger) | Lua puro fora do runtime (busted) + Vitest para TS |
| Integração | Repos + MariaDB, exports entre resources | Ambiente de teste com DB descartável; bots de agente |
| Segurança | Eventos com payload malicioso, cliente adulterado | Suíte de fuzz + revisão manual |
| Concorrência | Transferências, compras, buckets | Testes de estresse paralelos |
| Carga | CCU 32→512 | Bots + Prometheus |
| Soak | 6 h contínuas | Métricas de memória/tick |

## 5. Definition of Done (por tarefa)

1. `open77_validate` limpo (manifesto, permissões, runtime certo, natives existentes no build).
2. Nativas consultadas via `open77_api` (nada "de cabeça").
3. Permissões declaradas **exatamente** as necessárias.
4. Nenhum valor confiável vindo do cliente; autoridade no servidor.
5. Retornos `nil, reason` tratados.
6. Sem SQL concatenado; migrations versionadas.
7. Sem `Wait(0)` ocioso; polling adaptativo.
8. Testes unitários + (se aplicável) integração.
9. Documentação curta no README do resource + entrada no changelog.
10. Linguagem diegética nas mensagens ao jogador.

## 6. Riscos globais

| Risco | Impacto | Mitigação |
| :-- | :-- | :-- |
| API em Alpha muda | Retrabalho | Travar build; camada de adaptação por resource; acompanhar `/devblog` |
| Sem Redis nativo | Menor durabilidade de cache | `CacheService` abstrato + flush agressivo + tunables |
| Custo de props/buckets | Limite de móveis/interiores | Medir na Fase 5 antes de prometer números |
| Economia inflacionária | Servidor "quebra" | Registro emissão×drenos + painel + tunables ao vivo |
| VMs isoladas | Estado fragmentado | Serviços compartilhados por exports + contratos versionados |
| Escopo enorme | Atraso | Entregar por fase com critérios de saída; MVP jogável ao fim da Fase 5 |

## 7. Marcos jogáveis

- **M1 (fim Fase 2):** conectar, criar personagem, ver HUD, sobreviver (comer/beber/dormir).
- **M2 (fim Fase 4):** trabalhar (job básico), ganhar e gastar dinheiro com segurança.
- **M3 (fim Fase 5):** alugar, decorar e viver num apartamento instanciado — **MVP Life-Sim**.
- **M4 (fim Fase 7):** cidade viva (facções, voz, celular).
- **M5 (fim Fase 8):** Alpha Fechado.

## 8. Referências (documentação oficial)

Plataforma: `/docs/platform`, `/docs/alpha-access` · Hosting: `/docs/host-a-server`, `/docs/server-licensing`, `/docs/database`, `/docs/metrics`, `/docs/warden`, `/docs/rcon` · Resources: `/docs/server-resources`, `/docs/resource-runtime`, `/docs/server-exports`, `/docs/lua-modules` · Rede: `/docs/identity`, `/docs/connection-control`, `/docs/server-acl`, `/docs/callbacks`, `/docs/state-bags`, `/docs/readiness-gate` · Gamemode: `/docs/writing-a-gamemode`, `/docs/gamemode-kernel`, `/docs/tunables` · Mundo: `/docs/elevators`, `/docs/doors`, `/docs/props`, `/docs/gizmos`, `/docs/polyzone`, `/docs/zones`, `/docs/cameras` · UI: `/docs/ui-kit`, `/docs/notifications`, `/docs/input-blocking` · Áudio: `/docs/voice`, `/docs/chat` · Dados: `/docs/data-reference`, `/docs/data-catalogues` · Agentes: `/docs/agents`, `/docs/agent-testing`.
(Todas em `https://open2077.net`.)
