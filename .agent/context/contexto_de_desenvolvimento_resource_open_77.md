# CONTEXTO DE DESENVOLVIMENTO: RESOURCE OPEN//77
## Módulo: `open77_arcanum` (Tecno-Ocultismo & Bruxaria Integrada)

> **Documento de Contexto Técnico para Engenharia, IA Prompters e Arquitetura de Scripts**  
> **Plataforma:** [OPEN//77 (open2077.net)](https://open2077.net/docs/)  
> **Target:** Cyberpunk 2077 (2.31+ / Phantom Liberty) Dedicated Multiplayer  
> **Linguagem Principal:** Lua 5.4 (Server & Client Runtimes) + TypeScript/HTML/Tailwind (WebUI/Chromium)  
> **Versão do Documento:** 1.0.0-RC

---

## 1. VISÃO GERAL & DIRETRIZ DA PLATAFORMA

### 1.1 Objetivo do Resource
Implementar no ecossistema de RP da OPEN//77 as mecânicas de **Tecno-Ocultismo e Bruxaria Urbana** de forma 100% canônica e diegética (sem alta fantasia medieval, sem projéteis mágicos genéricos), traduzindo "feitiços" em manipulação de brechas da Blackwall, bioquímica clandestina, hipnose por Braindance e animismo de firmware legado.

### 1.2 Premissas de Engenharia da OPEN//77
1. **Ambiente Dual-Runtime (Lua 5.4):**
   - **Server-Side:** Possui a autoridade definitiva sobre o estado do mundo, validação de inventário, contadores de corrupção, transações e regras anti-cheat/anti-powergame.
   - **Client-Side:** Executa dentro do processo do jogo; responsável por invocar natives da REDengine (efeitos de câmera, animações de link neural, SFX locais, overlays de aberração cromática).
2. **Interface Out-of-Process (Chromium WebUI):**
   - HUD, grimório e terminais operam no processo de WebUI desacoplado via Chromium. O loop de renderização do jogo não paga o custo computacional da UI.
   - A comunicação Client $\leftrightarrow$ WebUI deve ser estritamente assíncrona orientada a eventos.
3. **Hot-Reload & Isolamento de VM:**
   - Cada resource roda em uma VM Lua isolada. O resource deve lidar de maneira idempotente com inicialização e encerramento (`onResourceStart` e `onResourceStop`), garantindo limpeza de listeners e buffers de memória.

---

## 2. ESTRUTURA DE PASTAS DO RESOURCE

O resource deve ser empacotado no diretório `resources/open77_arcanum/` seguindo o padrão oficial da OPEN//77:

```text
resources/open77_arcanum/
├── open77.lua                  # Manifesto do resource (metadados, scripts, dependências, webui)
├── config/
│   ├── schools.lua             # Configuração estática das 4 escolas e presets
│   ├── rituals.lua             # Banco de dados de rituais/feitiços, custos e CD
│   └── balance.lua             # Curvas de dano térmico, corrupção e NetWatch
├── shared/
│   ├── types.lua               # Tipagens e enums compartilhados
│   └── utils.lua               # Funções utilitárias puras (cálculos matemáticos, sanitização)
├── server/
│   ├── main.lua                # Entrypoint autoritativo, hooks de lifecycle
│   ├── state.lua               # Gestão em memória de estresse, corrupção e buffs
│   ├── db.lua                  # Abstração de persistência (PostgreSQL/MySQL/Key-Value)
│   ├── rituals_manager.lua     # Validação de requisitos, execução e cooldowns
│   ├── netwatch_director.lua   # Inteligência de resposta e eventos de caça da NetWatch
│   └── exports.lua             # Métodos expostos via Open77.exports
├── client/
│   ├── main.lua                # Entrypoint do client local
│   ├── visual_fx.lua           # Triggers de câmeras, glitches de tela e pós-processamento
│   ├── audio_fx.lua            # Disparo diegético de sons de hardware e estática
│   ├── sync.lua                # Escuta de eventos do server e atualização da NUI/WebUI
│   └── bridge_nui.lua          # Ponte de mensagens bidirecional com a WebUI
└── webui/                      # Camada Chromium desacoplada
    ├── index.html              # Shell do HUD/Grimório
    ├── css/
    │   └── styles.css          # Tailwind CSS compilado com tokens do projeto
    ├── js/
    │   ├── app.js              # Roteador de telas e dispatch de eventos
    │   ├── terminal.js         # Lógica do terminal diegético e medidores
    │   └── bridge.js           # Receptor de eventos Lua (Open77 WebUI events)
    └── assets/                 # SVGs, ícones e arquivos de áudio web
```

---

## 3. ESPECIFICAÇÃO DE DADOS & SCHEMAS

### 3.1 Manifesto do Resource (`open77.lua`)
```lua
resource "open77_arcanum"
version "1.0.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"

shared_scripts {
    "shared/types.lua",
    "shared/utils.lua",
    "config/balance.lua",
    "config/schools.lua",
    "config/rituals.lua"
}

server_scripts {
    "server/db.lua",
    "server/state.lua",
    "server/netwatch_director.lua",
    "server/rituals_manager.lua",
    "server/exports.lua",
    "server/main.lua"
}

client_scripts {
    "client/bridge_nui.lua",
    "client/visual_fx.lua",
    "client/audio_fx.lua",
    "client/sync.lua",
    "client/main.lua"
}

web_ui_page "webui/index.html"
web_ui_auto_create false
web_files { "webui/**" }
files { "webui/**" }

dependency "open77_inventory >=0.1.0"
dependency "open77_notifications >=0.1.0"

permissions {
    "webui.system",
    "network.events",
    "local.events",
    "database.access"
}
```

### 3.2 Estrutura de Estado do Personagem (Server-Side)
```lua
---@class PlayerOccultState
---@field occult_tier integer 0 a 3 (Nível de sintonização com técnicas arcanas)
---@field blackwall_corruption integer 0 a 5 (Acúmulo de fragmentos de IAs selvagens)
---@field systemic_toxicity number 0.0 a 100.0% (Toxicidade hepática de alquimia)
---@field neural_strain number 0.0 a 100.0% (Aquecimento/sobrecarga de RAM e processador)
---@field netwatch_heat integer 0 a 100 (Nível de atenção/rastreio da autoridade de rede)
---@field active_buffs table<string, BuffPayload>
---@field bound_pacts table<string, boolean>
```

---

## 4. ROTEIRO DE DESENVOLVIMENTO EM FASES (PHASED ROADMAP)

```
[FASE 0: FUNDAÇÃO] ──► [FASE 1: ESTADO & PERSISTÊNCIA] ──► [FASE 2: MOTOR SERVER DE RITUAIS]
                                                                      │
[FASE 5: NETWATCH & MUNDO] ◄── [FASE 4: WEBUI/NUI DIEGÉTICA] ◄── [FASE 3: FX CLIENT-SIDE]
            │
[FASE 6: HARDENING & TESTES]
```

---

### FASE 0: FUNDAÇÃO, MANIFESTO E PIPELINE
**Objetivo:** Criar a casca do resource, validar o carregamento na OPEN//77 e configurar hot-reload.

- [ ] **Passo 0.1:** Criar árvore de pastas e configurar `resource.json`.
- [ ] **Passo 0.2:** Configurar `shared/types.lua` com enums: `SchoolType`, `RitualTarget`, `CostType`.
- [ ] **Passo 0.3:** Validar print de carregamento autoritativo no terminal do servidor dedicado:
  ```lua
  print("^2[OPEN77 ARCANUM]^7 Resource inicializado com sucesso no runtime Lua 5.4")
  ```
- [ ] **Passo 0.4:** Configurar pipeline de build do frontend WebUI (Tailwind CSS com tokens do guia: `ink-950`, `signal-lime`, `signal-cyan`, `signal-coral`).
- **Critério de Aceite da Fase 0:** Resource inicia sem avisos (`warn`) ou erros no log do servidor OPEN//77 ao executar `refresh` e `ensure open77_arcanum`.

---

### FASE 1: GERENCIAMENTO DE ESTADO & PERSISTÊNCIA
**Objetivo:** Modelar o estado ocultista do personagem, persistência segura e sincronização delta.

- [ ] **Passo 1.1:** Criar módulo `server/db.lua` com queries para carregar e salvar a coluna JSON `metadata.occult` da tabela de personagens.
- [ ] **Passo 1.2:** Implementar `server/state.lua` com tabela indexada por `source` (Player Net ID).
- [ ] **Passo 1.3:** Implementar hooks nativos do ciclo de vida de conexão da OPEN//77:
  - Evento `playerJoining` / `Open77:playerLoaded` $\rightarrow$ Carrega dados do BD e monta o cache de estado.
  - Evento `playerDropped` $\rightarrow$ Salva dados pendentes e remove o slot de memória RAM.
- [ ] **Passo 1.4:** Criar rotina de decaimento periódico (`server-side tick`):
  - `systemic_toxicity` decai lentamente com o tempo (se o jogador não usar mais compostos).
  - `neural_strain` resfria com base no cyberware craniano instalado.
  - `blackwall_corruption` **não decai passivamente** (exige intervenção médica ou rituais de purga).
- **Critério de Aceite da Fase 1:** Estado do jogador persiste entre reconexões e comandos administrativos de depuração (`/occult_status`) refletem valores consistentes.

---

### FASE 2: MOTOR DE RITUAIS & ARQUITETURA AUTORITATIVA
**Objetivo:** Execução estritamente validada de rituais pelo servidor, prevenindo *powergaming* e exploits.

- [ ] **Passo 2.1:** Estruturar `config/rituals.lua` com definições completas de cada magia tecno-oculta:
  - Identificador único (`id`), escola associada, tempo de canalização, cooldown em segundos.
  - Requisitos rígidos: itens catalisadores no inventário (`open77_inventory`), tier mínimo de cyberware.
  - Custos intransponíveis: perda imediata de HP térmico, incremento de corrupção e esgotamento de RAM.
- [ ] **Passo 2.2:** Criar o pipeline de invocação no servidor (`server/rituals_manager.lua`):
  1. Recebe requisição via evento `open77:arcanum:requestCast(ritualId, targetNetId)`.
  2. Valida se o conjurador está vivo, consciente e sem cooldown ativo.
  3. Checa via export se o jogador possui o item catalisador exigido:
     ```lua
     local hasItem = exports['open77_inventory']:HasItem(source, ritual.catalyst_item)
     ```
  4. Executa rolagem de dados autoritativa (d20 + bônus de tier/modificadores).
  5. Aplica custos no conjurador (dano térmico irredutível ao HP, adição de corrupção).
  6. Se aprovado: despacha efeitos ao alvo e notifica o cliente do conjurador.
  7. Se falhar criticamente: aplica contra-golpe (*recoil térmico* ou curto-circuito local).
- [ ] **Passo 2.3:** Expor APIs públicas em `server/exports.lua`:
  - `GetPlayerCorruption(source)`
  - `AddPlayerCorruption(source, amount)`
  - `ApplySystemicPoison(source, toxicityLevel)`
- **Critério de Aceite da Fase 2:** É impossível conjurar qualquer habilidade sem possuir os itens exigidos no inventário ou burlando cooldowns via injeção de eventos no cliente.

---

### FASE 3: EFEITOS CLIENT-SIDE & FEEDBACK DIEGÉTICO
**Objetivo:** Traduzir os efeitos para a experiência audiovisual imersiva do jogador na REDengine.

- [ ] **Passo 3.1:** Implementar manipulador de efeitos visuais em `client/visual_fx.lua`:
  - Efeito Blackwall: aplicar aberração cromática severa, distorção de HUD e pós-processamento avermelhado momentâneo.
  - Efeito Alquimia: vinheta esverdeada/turva e leve oscilação da câmera representando descompasso metabólico.
  - Efeito Miragem Braindance: interferência estática nos drivers Kiroshi do alvo, ocultando silhuetas ou clonando projeções.
- [ ] **Passo 3.2:** Implementar camada de áudio em `client/audio_fx.lua`:
  - Ruído de alta frequência sintetizado para indicar superaquecimento de portas neurais.
  - Som de estática analógica e estalos de alta voltagem no cyberáudio.
- [ ] **Passo 3.3:** Integração com mecânica do alvo:
  - Para rituais de controle de hardware (`Espasmo de Hardware`), travar temporariamente inputs de disparo da arma ou forçar animação de recuo/engasgo do membro cibernético.
- **Critério de Aceite da Fase 3:** Ao sofrer ou executar um ritual, o jogador percebe de imediato o impacto visual e sonoro puramente fundamentado em falhas tecnológicas, sem partículas de magia clássica.

---

### FASE 4: WEBUI/NUI DIEGÉTICA & CONTROLE VISUAL
**Objetivo:** Criar a interface em Chromium para consulta de grimório, medidores de calor e telemetria.

- [ ] **Passo 4.1:** Desenvolver layout responsivo em `webui/index.html` seguindo o design system do Guia de Arte:
  - Fundo escuro com classe `bg-ink-950` (`#090B10`).
  - Painéis com `bg-slate-900` e bordas cortadas (`cyber-cut`).
  - Paleta semântica estrita: Perigo = `signal-coral` (`#FF625B`), Dados = `signal-cyan` (`#55D9E8`), Destaque = `signal-lime` (`#D9F34A`).
- [ ] **Passo 4.2:** Configurar bridge em `client/bridge_nui.lua`:
  - Escutar atualizações de estado do servidor e despachar via mensagem para o Chromium (`SendWebUIMessage`).
  - Capturar chamadas de fechamento da UI (`ESC` ou clique) e devolver o foco de entrada para o jogo.
- [ ] **Passo 4.3:** Criar medidores de telemetria no HUD:
  - Barra de Sobrecarga Térmica.
  - Indicador de Corrupção da Blackwall (0/5 nós ativos).
  - Alerta de Proximidade do NetWatch.
- **Critério de Aceite da Fase 4:** Interface abre e fecha com transições rápidas (<150ms), respeitando navegação por teclado e sem vazamento de foco do mouse.

---

### FASE 5: DIRETOR DE RESPOSTA DO MUNDO (NETWATCH & CONSEQUÊNCIAS)
**Objetivo:** Transformar o custo ocultista em narrativa viva e consequências perigosas no RP.

- [ ] **Passo 5.1:** Implementar o diretor de patrulha em `server/netwatch_director.lua`:
  - Monitorar jogadores que atinjam nível de corrupção $\ge 4$.
  - Disparar evento de interceptação de rede: HUD do jogador recebe mensagens misteriosas do NetWatch alertando triangulação de sinal.
- [ ] **Passo 5.2:** Gatilho de Catástrofe (Nível de Corrupção = 5):
  - Opção A: Gerar alerta corporativo com despacho de agentes NPC ou alerta para a facção policial/mercenária do servidor.
  - Opção B: Acionar crise aguda de ciberpsicose temporária (alucinações sonoras contínuas, disparo involuntário de implantes e necessidade de sedativo militar).
- [ ] **Passo 5.3:** Criar interações de purga médica:
  - Permitir que ripperdocs licenciados ou herbanários clandestinos de Kabuki usem itens específicos para limpar a corrupção e desintoxicar o organismo a um custo substancial em Eurodólares (`E$`).
- **Critério de Aceite da Fase 5:** Jogadores que abusam do sistema enfrentam consequências automáticas de mundo, tornando o uso de magia uma escolha calculada e de alto risco.

---

### FASE 6: BALANCEAMENTO, HARDENING & TESTES MULTIPLAYER
**Objetivo:** Homologar estabilidade sob alta concorrência de jogadores e calibrar economia.

- [ ] **Passo 6.1:** Testes de concorrência com múltiplos rituais simultâneos em combates de gangue (validação de lag, sync e event floods).
- [ ] **Passo 6.2:** Proteção contra manipulação de eventos:
  - Rate limiting rígido em todas as chamadas de rede recebidas pelo servidor.
  - Sanitização de argumentos de entrada (`type checking` explícito em cada handler).
- [ ] **Passo 6.3:** Auditoria de acessibilidade e legibilidade:
  - Nenhuma informação crítica de status deve depender unicamente de cor (sempre fornecer texto ou ícone de suporte).
  - Garantir taxa de contraste mínima de 4.5:1 nos textos do terminal.
- **Critério de Aceite da Fase 6:** Zero crashes ou vazamentos de memória após 24 horas contínuas de operação em servidor de staging com 30+ jogadores ativos.

---

## 5. TABELA DE CONTRATO DE EVENTOS (NETWORK API)

| Evento / Canal | Origem $\rightarrow$ Destino | Payload | Descrição |
|---|---|---|---|
| `open77:arcanum:requestCast` | Client $\rightarrow$ Server | `ritualId: string, targetId: number` | Solicita execução de um ritual |
| `open77:arcanum:castAccepted` | Server $\rightarrow$ Client | `ritualId: string, duration: number` | Autoriza canalização e inicia feedback |
| `open77:arcanum:applyEffect` | Server $\rightarrow$ Target Client | `effectId: string, intensity: number` | Aplica debuff/glitch no alvo |
| `open77:arcanum:stateUpdate` | Server $\rightarrow$ Client | `state: PlayerOccultState` | Atualiza medidores de calor e corrupção |
| `open77:arcanum:netwatchAlert` | Server $\rightarrow$ Client | `alertLevel: integer, msg: string` | Notificação diegética de rastreio de rede |

---

## 6. INSTRUÇÕES PARA LLMs & DESENVOLVEDORES (PROMPT DIRECTIVES)

Quando solicitar geração ou refatoração de código para este resource:
1. **Nunca use conceitos ou nomenclatura de fantasia tradicional:** use termos técnicos e diegéticos (`daemon`, `overheat`, `ICE`, `bio-cocktail`, `synaptic feedback`, `neural port`).
2. **Todo cálculo deve ser feito no servidor:** código gerado para o cliente que decide vida, corrupção ou sucesso de ação deve ser rejeitado imediatamente.
3. **Respeite os tokens de UI do Guia:** nunca insira gradientes roxos/rosas genéricos de "cyberpunk neon clichê". Utilize rigorosamente a paleta do guia de arte (`ink-950`, `slate-900`, `signal-lime`, `signal-cyan`, `signal-coral`).
4. **Mantenha os scripts modulares e desacoplados:** cada arquivo de configuração em `config/` deve exportar tabelas puras para fácil ajuste por mestres de RP sem necessidade de alterar a lógica interna da engine.