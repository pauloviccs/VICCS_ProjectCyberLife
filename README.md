# OPEN//77: Night City Life-Sim RP (`VICCS_ProjectCyberLife`)

> **Versão do Projeto:** `v0.0.3` (Alpha Functional Foundation)  
> **Plataforma:** Cyberpunk 2077 (v2.31 / Phantom Liberty) + OPEN//77 Multiplayer Dedicated Server (`2.31.21+op77.124` / Protocolo de Rede `1.44`)  
> **Arquitetura:** Server-Authoritative | MariaDB 10.11+ (InnoDB via `open77_mysql` / `MySqlConnector`) | Lua 5.4 Sandboxed Write-Behind Cache | Vanilla HTML5/CSS3/ES6+ Kiroshi Optics CEF WebUI (`Open77.webui`) | Radmin VPN Mesh  
> **Documentação Canônica:** [https://open2077.net/docs](https://open2077.net/docs)

---

## 🌆 Sobre o Projeto

O **OPEN//77 Life-Sim RP** transforma Night City em uma plataforma viva e persistente de simulação social, biológica e urbana de alta fidelidade. Inspirado nos sistemas de necessidades e progressão do *The Sims 4* e na atmosfera corporativa distópica de *Cyberpunk 2077*, o projeto prioriza a imersão de interpretação de papéis (Roleplay) em detrimento do combate desordenado.

O servidor implementa um ecossistema econômico circular rigoroso, gestão contínua de necessidades metabólicas humanas (nutrição, hidratação, sono, higiene, stress), moradias verticais instanciadas nos Megabuildings através de *Routing Buckets*, persistência veicular completa e o risco latente de **ciberpsicose** por sobrecarga de implantes com resposta armada da MaxTac.

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia | Especificação / Descrição |
| :--- | :--- | :--- |
| **Dedicated Host** | .NET 8 (Linux x64 / Windows) | OPEN//77 Dedicated Server Server-Authoritative (`2.31.21+op77.124`, Protocolo `1.44`) |
| **Scripting / Regras** | Lua 5.4 isolado por recurso | Lógica server-side sandboxed (sem bibliotecas de SO como `os` ou `io`), eventos assíncronos seguros |
| **Cache em Memória** | `CacheService` (Lua VM) | Estrutura de dados em memória de latência sub-milissegundo com *Write-Behind* assíncrono (5 min) e flush no shutdown |
| **Banco de Dados** | MariaDB 10.11+ (InnoDB) | 10 tabelas relacionais ativas, bridge assíncrona oficial `open77_mysql` (`MySQL.*.await`), transações ACID para economia e inventário |
| **Interface In-Game (WebUI)** | Vanilla HTML5 / CSS3 / ES6+ | HUD Kiroshi Optics diegético com Glassmorphism (`backdrop-filter: blur(12px)`) renderizado em Chromium CEF nativo (`nui://` scheme com `Open77.webui`) |
| **Áudio Espacial** | `open-voice` | Voz posicional 3D nativa do REDengine com oclusão acústica geométrica e rádio/holocall |
| **Rede & Conectividade** | Radmin VPN / Direct IP | Rede virtual de baixa latência em malha fechada (`26.102.47.161:7777`) |
| **Cortex de Contexto** | Antigravity AI (`.agent`) | Memória persistente, diretrizes de código, histórico de 24 incidentes resolvidos e especificações canônicas |

---

## 📦 Módulos do Sistema Life-Sim (47 Recursos Ativos)

O servidor opera com **47 recursos carregados** (35 módulos oficiais do sistema OPEN//77, 9 recursos Life-Sim autoritativos e 3 recursos auxiliares/modding):

### 🧬 Módulos Life-Sim (`Server/resources/lifesim/`)
1. **`ls_core`**: Registro autoritativo de sessões de jogadores, controle de Routing Buckets (instanciamento de interiores), monitor de conexões e rate limiting.
2. **`ls_data`**: ORM assíncrono e Write-Behind Cache em MariaDB. Gerencia 10 tabelas relacionais (`ls_characters`, `ls_character_vitals`, `ls_character_cyberware`, `ls_character_accounts`, `ls_inventories`, `ls_inventory_items`, `ls_vehicles`, `ls_player_apartments`, `ls_apartment_furniture`, `ls_player_spawns`).
3. **`ls_vitals`**: Motor biológico com decaimento metabólico contínuo (Fome, Sede, Sono, Higiene, Stress) e processamento em lote.
4. **`ls_ui`**: Interface Kiroshi Optics HUD em CEF nativo (Vanilla HTML5/CSS3/ES6+). Exibe telemetria metabólica, alertas corporais e estado neural sem frameworks pesados.
5. **`ls_cyberware`**: Sistema de estabilidade neural, estresse biológico e carga térmica ocular. Gatilho de ciberpsicose em <25% de estabilidade com aberração cromática e intervenção MaxTac.
6. **`ls_economy`**: Economia circular com contas bancárias criptografadas, dinheiro em espécie (eddis), transações financeiras com isolamento ACID e log de auditoria.
7. **`ls_inventory`**: Inventário server-authoritative baseado em slots, peso e integridade de itens, com consumo seguro de suprimentos alimentares e farmacêuticos.
8. **`ls_housing`**: Aquisição e locação de apartamentos instanciados em Megabuildings (H10, H4, etc.) via Routing Buckets, trancas de segurança e aluguéis periódicos.
9. **`ls_vehicles`**: Concessionárias, garagens corporativas, reboque via Trauma/Delamain e persistência de dados de integridade da REDengine.

---

## 📁 Estrutura do Repositório

```text
VICCS_ProjectCyberLife/
├── .agent/                             # Cérebro de Contexto, Memória e Diretrizes (Antigravity Cortex)
│   ├── context/                        # Arquitetura, esquemas SQL, stack e documentação canônica OPEN//77
│   ├── guidelines/                     # Diretrizes de estilo Lua 5.4, Design System Kiroshi e regras de código
│   ├── memory/                         # active_task.md, todos.md (9 fases) e changelog.md
│   └── overview/                       # PROJECT_STATUS.md mestre sincronizado
├── .agents/skills/open2077-dev/        # Skill especializada local do workspace OPEN//77
├── GDD_Website/                        # Dashboard interativo executivo do Game Design Document
├── Main_Website/                       # Portal e website oficial da comunidade
└── Server/                             # Núcleo do servidor dedicado OPEN//77
    ├── .agent/                         # Espelho de documentação e histórico de 24 incidentes operacionais
    ├── resources/
    │   ├── lifesim/                    # Módulos autoritativos do ecossistema Life-Sim (9 recursos)
    │   ├── system/                     # Módulos oficiais da plataforma OPEN//77 (35 recursos)
    │   └── auxiliary/                  # Recursos de coordenadas e criador de personagens
    ├── server.jsonc                    # Configuração central de rede, binds de IP e recursos carregados
    ├── open77-client.d.lua             # Tipagens de metadados da API de cliente REDengine
    ├── open77-server.d.lua             # Tipagens de metadados da API de servidor
    └── start_server.bat                # Script de inicialização do servidor dedicado
```

---

## 🚦 Roadmap de Implementação

- [x] **Fase 1: Fundação & Núcleo do Servidor** (`ls_core`, `ls_data`)
- [x] **Fase 2: Biometria, Fisiologia & Kiroshi HUD** (`ls_vitals`, `ls_ui`)
- [x] **Fase 3: Cyberware, Estabilidade Neural & Ciberpsicose** (`ls_cyberware`)
- [x] **Fase 4: Economia Circular & Inventário** (`ls_economy`, `ls_inventory`)
- [x] **Fase 5: Habitação em Megabuildings & Garagens** (`ls_housing`, `ls_vehicles`)
- [ ] **Fase 6: Empregos Corporativos, Mercado Negro & Facções** (`ls_jobs`, `ls_factions`)
- [ ] **Fase 7: Sistema Jurídico, NCPD & Prisão**
- [ ] **Fase 8: Relacionamentos, Status Social & Redes In-Game**
- [ ] **Fase 9: Eventos Dinâmicos Urbanos, Polimento & Lançamento Alpha Público**

---

## 🔧 Como Iniciar o Servidor

### Requisitos Prévios
1. **Cyberpunk 2077 v2.31** com a expansão *Phantom Liberty*.
2. **MariaDB 10.11+** ativo na porta `3306` com a database `open77_lifesim` criada e o schema executado.
3. **Radmin VPN** conectado à rede do projeto (IP: `26.102.47.161`).

### Execução
1. Certifique-se de que o serviço MariaDB está em execução:
   ```cmd
   net start MariaDB
   ```
2. Inicie o servidor dedicado executando o arquivo em lote:
   ```cmd
   cd Server
   start_server.bat
   ```
3. O servidor carregará os 47 recursos e inicializará na porta UDP/TCP `7777`.

---

## 📜 Licença e Créditos

Desenvolvido por **Paulo VICCS** e equipe técnica do projeto VICCS.  
Construído sobre a plataforma multijogador aberta [OPEN//77](https://open2077.net). Todos os direitos de *Cyberpunk 2077* e *REDengine 4* pertencem à CD PROJEKT RED.
