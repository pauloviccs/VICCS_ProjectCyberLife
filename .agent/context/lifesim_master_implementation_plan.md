# OPEN//77 Night City Life-Sim RP — Plano Mestre de Implementação & Roadmap

> **Status:** Arquitetura Validada & Fundação Conectada (Build 23100 / MariaDB Ativo)  
> **Target:** Cyberpunk 2077 v2.31 + Phantom Liberty / Plataforma OPEN//77  
> **Gamemode:** `gamemodes/lifesim/`  

---

## 1. Visão Geral & Decisões Arquiteturais Consolidadas

O projeto transforma Night City em uma plataforma persistente de simulação social e biológica profunda (*Life-Sim*), inspirada no ciclo vital de *The Sims 4* e inserida na distopia transumanista de *Cyberpunk 2077*.

### Matriz de Resolução de Divergências (GDD vs. Plataforma Real)

| Componente | Premissa Inicial (GDD) | Realidade OPEN//77 (Oficial) | Decisão Arquitetural Fixada |
| :--- | :--- | :--- | :--- |
| **Banco de Dados** | PostgreSQL 16 + PgBouncer | Bridge oficial suporta **MySQL / MariaDB** | **MariaDB 10.4.32+ (InnoDB)** com transações ACID (`SELECT ... FOR UPDATE`), índices e colunas `JSON`. |
| **Cache de Biometria** | Redis 7 | Redis não é nativo na plataforma | **`CacheService` in-memory em Lua 5.4** com padrão *Write-Behind* (flush a cada 5m, disconnect e shutdown). |
| **Transações Financeiras** | Redis + Sync Postgres | Risco de duplicação por cache | **Transações síncronas imediatas no MariaDB** sem cache intermediário (`ls_ledger` append-only). |
| **Interface NUI** | Variável / React | Chromium WebView2 out-of-process | **Svelte 5 (Runes) + Tailwind CSS** (Zero VDOM, zero pausas de GC, alta performance a 60 FPS). |
| **Identificadores** | Mistura de int / string | REDengine 64-bit int vs Sessão int | **IDs de Entidade REDengine são opacos** (nunca `tonumber`). **IDs de Sessão usam `tonumber`**. Chave de persistência é a `license`. |
| **Voz & Comunicação** | Sistema genérico | `open-voice` integrado | **`open-voice` nativo** com atenuação 3D, oclusão por paredes e filtro diegético de holocall. |

---

## 2. Estrutura Canônica de Recursos (`Server/resources/gamemodes/lifesim/`)

```text
Server/resources/gamemodes/lifesim/
├── ls_core/            # Identidade, sessões, lifecycle, comandos admin e event bus
├── ls_data/            # Migrations MariaDB, repositórios, CacheService (write-behind)
├── ls_vitals/          # Motor de biometria (nutrição, água, energia, higiene, stress)
├── ls_cyberware/       # Implantes, calor ocular, estabilidade neural e ciberpsicose
├── ls_economy/         # Sistema bancário, dinheiro, carteira, ledger e money sinks
├── ls_inventory/       # Inventário em slots/peso, itens usáveis e containers
├── ls_housing/         # Megabuildings, routing buckets, elevadores, portas e build mode
├── ls_jobs/            # Carreiras corporativas, serviços públicos, turnos e salários
├── ls_factions/        # NCPD, Trauma Team, Fixers, contratos e reputação
├── ls_social/          # Bares, animações sincronizadas, afinidade social e smartphone
└── ls_ui/              # Frontend centralizado Svelte 5 (HUD Kiroshi, Apps e Modais)
```

---

## 3. Roadmap Detalhado de Implementação por Fases

```mermaid
flowchart TD
    F0["Fase 0: Fundação & Conectividade [CONCLUÍDO]"] --> F1["Fase 1: Núcleo do Gamemode (ls_core & ls_data)"]
    F1 --> F2["Fase 2: Biometria & HUD Kiroshi (ls_vitals & ls_ui)"]
    F2 --> F3["Fase 3: Ciberpsicose & Implantes (ls_cyberware)"]
    F2 --> F4["Fase 4: Economia Circular & Inventário (ls_economy & ls_inventory)"]
    F4 --> F5["Fase 5: Habitação Vertical & Buckets (ls_housing)"]
    F4 --> F6["Fase 6: Carreiras & Facções (ls_jobs & ls_factions)"]
    F5 & F6 --> F7["Fase 7: Imersão Social & Celular (ls_social)"]
    F7 --> F8["Fase 8: Hardening, Testes de Carga & Alpha Fechado"]
```

---

### Fase 0: Fundação, Infraestrutura & Conectividade (100% CONCLUÍDA)
- [x] Extração e scaffold do servidor OPEN//77 v2.31.21+op77.121.
- [x] Banco de dados `open77_lifesim` estruturado no MariaDB local (XAMPP).
- [x] Correção de compatibilidade da build (`expectedGameBuild = 23100`).
- [x] Ajuste do alvará Master Server (`publicEndpoint = 147.185.221.213:5494`).
- [x] Validação in-game: jogador `viccs` conectado com sucesso em Night City.

---

### Fase 1: Núcleo do Gamemode & Persistência Reativa
**Objetivo:** Criar a fundação estrutural do gamemode onde os jogadores são carregados, autenticados e têm seus dados salvos de forma confiável.

#### Módulo `ls_core`:
* **`open77.lua`**: Manifesto com permissões `network.events`, auto start.
* **`server/main.lua`**:
  * Listener do evento nativo de conexão/pronto do jogador (`Open77:playerLoaded` / `playerJoining`).
  * Resolução de identidade autenticada (`license`).
  * Criação ou carregamento do perfil do personagem (`players`).
  * Inicialização dos State Bags reativos no servidor: `Player(src).state:set("loaded", true, true)`.
* **`client/main.lua`**:
  * Handshake de prontidão com o servidor ao completar o spawn no mundo.
  * Bloqueio temporário de controles durante a carga inicial.

#### Módulo `ls_data`:
* **`server/services/database.lua`**:
  * Wrapper síncrono/assíncrono para queries MariaDB via `Open77.database` (`MySQL.query.await`, `MySQL.insert.await`).
* **`server/services/cache.lua`**:
  * Implementação do `CacheService` com tabelas Lua em memória.
  * Gerenciamento de `is_dirty` por chave e entidade.
  * Worker cron em corrotina (`CreateThread`) executando flush em lote a cada 5 minutos.
  * Handler de flush forçado em desconexão de jogador (`playerDropped`) e parada do recurso (`onResourceStop`).
* **Testes de Aceitação da Fase 1:**
  * Jogador entra no servidor -> registro criado em `players` -> reconexão lê dados existentes sem duplicar.

---

### Fase 2: Biometria, Vitais & HUD Kiroshi (Svelte 5)
**Objetivo:** Implementar a sobrevivência metabólica estilo Life-Sim e a interface visual diegética Kiroshi Optics.

#### Módulo `ls_vitals`:
* **Cálculo Metabólico (Server-Authoritative):**
  * Equação de decaimento temporal independente de frame rate (baseada em `os.time()` delta):
    * Nutrição: `-1.0% / min real`
    * Hidratação: `-1.5% / min real`
    * Sono/Energia: `-0.8% / min real`
    * Higiene: `-0.7% / min real`
    * Stress: acrescido por combate, barulho e falta de sono.
* **Trilho de Cache:**
  * Atualizações salvas no `CacheService.vitals[license]`.
* **State Bags:**
  * Servidor atualiza `Player(src).state:set("vitals", currentVitals, true)` com histerese (somente quando varia mais de 0.5%).
* **Consumo de Itens:**
  * Evento `ls:vitals:consume` para restaurar atributos após validação no servidor.

#### Módulo `ls_ui`:
* **Setup do Frontend CEF WebUI (Kiroshi HUD):**
  * Vanilla HTML5, CSS3 Glassmorphism (`backdrop-filter: blur(12px)`), e ES6+ modular em `web/`.
  * Carregamento nativo via `Open77.webui.create{ url = "nui://ls_ui/web/index.html", visible = true }`.
  * Estilização seguindo paleta Kiroshi Optics:
    * Fundo: `#080E19` com opacidade 85% e `backdrop-blur-md`.
    * Destaques: Ciano Elétrico (`#22D8E2`) e Branco Puro (`#F2F6F8`).
    * Alertas: Vermelho Neon (`#FF5964`).
    * Tipografia: `JetBrains Mono` e `Rajdhani` / `Chakra Petch`.
* **HUD Reativo & IPC:**
  * Barras de status (Fome, Sede, Sono, Higiene, Stress) alimentadas por IPC nativo `page:send("ls_ui:updateNeeds", payload)` e consumidas no browser via `Open77.on("ls_ui:updateNeeds", handler)`.
* **Testes de Aceitação da Fase 2:**
  * Jogador vê barras decaindo suavemente; consome comida -> barra sobe e salva no banco após o ciclo de flush.

---

### Fase 3: Cyberware, Estabilidade Neural & Ciberpsicose
**Objetivo:** Traduzir a mecânica central do universo Cyberpunk: a tensão entre modificação corporal e perda de humanidade.

#### Módulo `ls_cyberware`:
* **Fórmula de Estabilidade Neural:**
  $$\text{Estabilidade} = \text{clamp}(100 - (\text{implantes} \times 9) - (1 - \text{neurobloqueador}) \times 30 - (\text{stress} - 1) \times 4, 5, 100)$$
* **Calor Ocular & Carga Térmica:**
  $$\text{Calor} = 36.5 + (\text{implantes} \times 1.2) + (\text{stress} \times 1.5)$$
* **Limiar de Psicose (`psychosis_threshold = 25`):**
  * Quando Estabilidade < 25%:
    * Servidor define `Player(src).state:set("psychosis", true, true)`.
    * Cliente ativa shader de aberração cromática, vinheta vermelha e distorção sonora nos ouvidos.
* **Protocolo de Resposta MaxTac:**
  * Se o jogador em psicose disparar arma em área urbana: emissão de contrato MaxTac no servidor e notificação à facção policial.
* **Spray Criogênico & Neurobloqueadores:** Itens farmacêuticos como dreno contínuo de dinheiro.

---

### Fase 4: Economia Circular, Banco & Inventário
**Objetivo:** Estabelecer a sustentabilidade econômica, eliminando hiperinflação através de drenos obrigatórios e transações ACID.

#### Módulo `ls_economy`:
* **Transações Bancárias ACID:**
  * Executadas estritamente no MariaDB com `START TRANSACTION` e `SELECT balance FROM players WHERE license = ? FOR UPDATE`.
  * Registro imutável em `ls_ledger` com `idempotency_key` (evita cobrança dupla em lag).
* **Matriz de Money Sinks (Drenos Automáticos):**
  * Aluguel diário descontado à meia-noite do jogo (35%).
  * Manutenção de implantes e farmácia (25%).
  * Seguro Trauma Team (15%).
  * Alimentação diária (15%).
  * Tarifas e licenças NCPD (10%).

#### Módulo `ls_inventory`:
* **Arquitetura de Itens em Slots e Peso:**
  * Persistência em JSON na tabela `inventories`.
  * Tipos de inventário: `player`, `glovebox` (porta-luvas), `trunk` (porta-malas), `stash` (baú residencial).
  * Verificação server-side estrita de capacidade máxima antes de permitir transferências.

---

### Fase 5: Habitação Vertical, Routing Buckets & Build Mode Livre (PolyZone)
**Objetivo:** Permitir que dezenas de jogadores morem no mesmo Megabuilding (ex: H10 do V) sem sobreposição visual ou física, com modo de decoração livre de alta precisão e prevenção matemática de colisões.

#### Módulo `ls_housing`:
* **Routing Buckets Dinâmicos:**
  * Pool de instâncias isoladas (IDs de bucket 10000–19999).
  * Ao entrar no apartamento: `Open77.players.setRoutingBucket(playerId, bucketId)`.
  * População e tráfego ambiente desativados dentro do interior do interior instanciado.
  * Oclusão de voz e rede restrita aos membros do mesmo bucket.
* **Portas & Elevadores:**
  * Integração com as APIs nativas do Open77 (`Open77.elevators.goTo`).
* **Build Mode (Decoração Residencial com Movimentação Livre & PolyZone):**
  * **Movimentação Livre Contínua (Substituindo Grid Rígido):** Raycast contínuo de superfície do cursor para coordenadas milimétricas $(X, Y, Z)$ e rotação yaw 360° fluida (`Q/E` ou Scroll), permitindo disposição orgânica de mobília sem as restrições artificiais de grade.
  * **Prevenção de Colisão com Paredes via PolyZone 3D:** Cada planta de apartamento possui um `PolyZone` ou `ComboZone` delimitando o volume habitável (com `minZ` piso e `maxZ` teto). O sistema calcula os 4 vértices do Oriented Bounding Box (OBB) da mobília e exige que todos estejam contidos dentro do `PolyZone:isPointInside(v)`.
  * **Prevenção de Sobreposição Inter-Mobília:** Mobílias existentes geram `BoxZones` dinâmicos orientados. A nova peça é validada contra colisões antes de permitir fixação, suportando empilhamento controlado (ex: luminária sobre mesa) via detecção de superfície de apoio.
  * **Feedback Visual Diegético (Shader Holográfico):** Projeção holográfica em Verde/Ciano Neon (`#00ff9d`) para posições válidas e Vermelho Neon (`#ff003c`) para colisões ou transposição de paredes.
  * **Validação Autoritativa no Servidor:** Verificação das coordenadas contra a PolyZone no backend antes de persistir em `ls_furniture`.
* **Mobília Interativa:**
  * Cama (restaura Energia), Chuveiro (restaura Higiene), Fogão (cozinha sintética).

---

### Fase 6: Carreiras Produtivas & Facções
**Objetivo:** Fornecer rotinas de trabalho com verificação de serviço e dinâmica social de facções.

#### Módulo `ls_jobs`:
* **Carreiras:** Corporativo Arasaka/Militech, Atendente/Comerciante, Ripperdoc, Freelancer Edgerunner.
* **Verificação de Serviço:**
  * Salário pago apenas se o jogador estiver marcado em serviço (`on_duty = true`) e fisicamente presente dentro do PolyZone da empresa.
  * Exigências de vestimenta (ex: terno formal para corporativos) e higiene > 80%.

#### Módulo `ls_factions`:
* **NCPD:** Despacho de crimes, histórico policial, acesso a viaturas e armaria.
* **Trauma Team:** Chamados médicos automáticos quando um jogador VIP entra em estado crítico (`health < 15`).
* **Fixers & Contratos:** Sistema de missões geradas dinamicamente com recompensa em Eurodólares e Street Cred.

---

### Fase 7: Imersão Social, Celular & Interações
**Objetivo:** Conectar os jogadores através de canais diegéticos e interações sociais.

#### Módulo `ls_social`:
* **Smartphone NUI Kiroshi:**
  * Interface de smartphone deslizante (tecla padrão `M` ou `F1`).
  * Aplicativo Bancário (transferências PIX/Eddies).
  * Aplicativo de Mensagens e Holocall com áudio espacial filtrado via `open-voice`.
* **Socialização & Bares:**
  * Consumo de bebidas alcoólicas em balcões com animações sincronizadas REDengine.
  * Efeito de redução temporária de stress com aumento transitório de sonolência.

---

### Fase 8: Hardening, Testes de Carga & Alpha Fechado
**Objetivo:** Blindar o ecossistema contra falhas, perdas de dados e sobrecarga.

* **Auditoria de Concorrência Financeira:** Teste de estresse com múltiplas transferências simultâneas com a mesma conta para comprovar ausência de race conditions.
* **Auditoria de Vazamento de Buckets:** Garantir que quando o último jogador sai de uma casa, o bucket é desalocado.
* **Métricas Prometheus:** Exportação de tick rate, latência média e tempo de ciclo de hooks do Open77 via porta de métricas.
* **Tag de Versão:** Publicação e commit final da versão estável `v0.1.0`.

---

## 4. Próxima Ação Imediata (Início da Fase 1)

Após a aprovação deste plano, iniciaremos a **Fase 1** com a criação dos recursos:
1. `resources/gamemodes/lifesim/ls_core` (Bootstrap, identidade e sessões).
2. `resources/gamemodes/lifesim/ls_data` (Conector MariaDB e CacheService).
3. Registro dos recursos no arquivo de configuração [`Server/server.jsonc`](file:///c:/Games/VICCS_CyberpunkServer/Server/server.jsonc).
