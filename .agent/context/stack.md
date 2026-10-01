# Stack Tecnológica Oficial — OPEN//77 Life-Sim RP

| Camada | Tecnologia | Versão | Papel no Projeto | Invariante Técnico |
| :--- | :--- | :--- | :--- | :--- |
| **Servidor Host** | Linux x64 / Windows (.NET 8 Runtime) | .NET 8 / Build 2.31.13+op77.78 | Binário dedicado OPEN//77; gerenciamento de conexões assíncronas e alta densidade de rede. | Licenciado à conta; Warden para administração; RCON; métricas Prometheus. |
| **Scripting / Lógica** | Lua 5.4 isolado por recurso | 5.4 | Regras de gameplay, economia, biometria, eventos e controllers. Cada recurso possui VM própria. | Server-authoritative estrito. Comunicação entre recursos via server exports. |
| **Cache em Memória** | CacheService (Tabelas Lua in-memory) | Nativo Lua 5.4 | Estado volátil de alta frequência: biometria, sessões ativas, calor de ciberware, coordenadas temporárias. | Descarregado via Write-Behind em lotes a cada 5m, no disconnect e no resource stop. |
| **Persistência Relacional** | MariaDB 10.11+ / MySQL 8 (InnoDB) | MariaDB / MySQL 8 | Inventários, carteiras monetárias, escrituras de imóveis, histórico financeiro e colunas `JSON`. | Bridge SQL nativa OPEN//77 (`database.access`). Transações com locks explícitos (`SELECT ... FOR UPDATE`). |
| **Front-End / NUI** | Svelte 5 (Runes) + Tailwind CSS | Svelte 5 / Tailwind 3.4+ | Interfaces diegéticas in-game (HUD Kiroshi, terminais, smartphone, menu de construção). | Renderizado em Chromium WebView2 out-of-process. Zero VDOM / Zero React para evitar micro-stutters. |
| **Áudio Espacial** | `open-voice` | Nativo OPEN//77 | Comunicação de voz 3D com oclusão geométrica por paredes e efeitos de rádio/holocall. | Configurado nativamente na plataforma. |
| **Ferramentas de IA/IDE** | `@open2077/mcp` (Devkit) | 2.31.13+op77.78 | 27 ferramentas MCP para busca de nativas, validação de recursos e documentação interativa. | Suporte a Antigravity IDE, Claude Code, Cursor e Gemini CLI. |

> **Nota de Compatibilidade:** A bridge nativa do OPEN//77 suporta **MySQL e MariaDB**. O plano inicial previa PostgreSQL e Redis externo; a arquitetura atual utiliza MariaDB 10.11+ com tabelas InnoDB e CacheService em memória integrado no kernel Lua com estratégia Write-Behind, garantindo máxima performance sem dependências externas incompatíveis.
