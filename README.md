# OPEN//77: Night City Life-Sim RP (`VICCS_ProjectCyberLife`)

> **Versão:** v0.0.1 (Alpha Foundation)  
> **Plataforma:** Cyberpunk 2077 (v2.31 / Phantom Liberty) + OPEN//77 Multiplayer Dedicated Server (.NET 8 Runtime)  
> **Arquitetura:** Server-Authoritative | MariaDB 10.11+ (InnoDB) | Lua 5.4 Write-Behind Cache | Svelte 5 NUI (WebView2)

---

## 🌆 Sobre o Projeto

O **OPEN//77 Life-Sim RP** transforma Night City em uma plataforma persistente de simulação social e biológica profunda inspirada em *The Sims 4* combinada com a distopia corporativa de *Cyberpunk 2077*.

Menos focado em tiroteios aleatórios desestruturados, o servidor é centrado na gestão contínua de necessidades metabólicas (nutrição, hidratação, descanso, higiene), aquisição e customização de apartamentos verticais instanciados (Megabuildings com *Routing Buckets*), economia circular com drenos monetários reais e o risco iminente de **ciberpsicose** com resposta tática da MaxTac.

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia | Descrição |
| :--- | :--- | :--- |
| **Dedicated Host** | .NET 8 (Linux x64 / Windows) | Binário dedicado de alta densidade de rede OPEN//77 |
| **Scripting / Regras** | Lua 5.4 isolado por recurso | Lógica de negócios server-authoritative e eventos seguros |
| **Cache em Memória** | `CacheService` (Lua VM) | Armazenamento volátil sub-milissegundo com *Write-Behind* assíncrono (5 min) |
| **Banco de Dados** | MariaDB 10.11+ / MySQL 8 (InnoDB) | Transações ACID imediatas para finanças, itens e imóveis |
| **Interface In-Game (NUI)** | Svelte 5 (Runes) + Tailwind CSS | HUD Kiroshi diegético renderizado no Chromium WebView2 out-of-process |
| **Áudio Espacial** | `open-voice` | Voz 3D posicional com oclusão geométrica e efeito holocall |
| **Tooling & Devkit** | `@open2077/mcp` (Build 2.31.13+op77.78) | Suite MCP com 27 ferramentas ativas para automação e validação |

---

## 📁 Estrutura do Repositório

```text
VICCS_ProjectCyberLife/
├── .agent/                             # Cérebro de Contexto, Memória e Diretrizes (Antigravity Cortex)
│   ├── context/                        # Arquitetura, esquemas SQL, stack e documentação OPEN//77
│   ├── guidelines/                     # Diretrizes de estilo de código Lua 5.4 e Design System Kiroshi
│   ├── memory/                         # active_task.md, todos.md (9 fases) e changelog.md
│   └── overview/                       # PROJECT_STATUS.md sincronizado
├── .agents/skills/open2077-dev/        # Skill especializada local do workspace
├── GDD_Website/                        # Dashboard interativo executivo do Game Design Document
├── Main_Website/                       # Portal e website oficial da comunidade
└── Server/                             # Núcleo do servidor dedicado OPEN//77
    ├── .luarc.json                     # Configurações do Lua Language Server
    ├── open77-client.d.lua             # Tipagens completas da API do cliente REDengine
    └── open77-server.d.lua             # Tipagens completas da API do servidor
```

---

## 🚀 Status e Próximos Passos (v0.0.1)

- [x] Fundação, documentação e Devkit MCP configurados com sucesso.
- [x] Tipagem de nativas REDengine gerada para a build `2.31.13+op77.78`.
- [x] Definição da arquitetura server-authoritative e esquemas MariaDB InnoDB.
- [ ] Fase 1: Implementação de `Server/server.jsonc`, `ls_core` e `ls_data`.
- [ ] Fase 2: Motor de biometria `ls_vitals` e HUD Kiroshi em Svelte 5.

---

## 📜 Licença e Créditos
Desenvolvido por **Paulo VICCS** e mantido pela equipe do projeto. Baseado na plataforma multijogador aberta OPEN//77.
