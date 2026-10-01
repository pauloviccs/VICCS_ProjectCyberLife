# INSTALAÇÃO E USO DO MCP OFICIAL: OPEN//77 DEVKIT (@open2077/mcp)

> **Documentação de Referência:** [open2077.net/docs/agents](https://open2077.net/docs/agents)  
> **Repositório:** [github.com/Open2077/open77-devkit](https://github.com/Open2077/open77-devkit)  
> **Versão do Pacote:** `@open2077/mcp`  
> **Build Suportada:** 2.31.13+op77.78  

---

## 1. Instalação e Registro Automático

A partir da raiz do servidor ou qualquer pasta de projeto com Node.js 20+:

```bash
npx -y @open2077/mcp init
```

### O que o comando realiza:
Registra automaticamente o MCP `open77-devkit` em todos os clientes detectados na máquina:
- **Gemini CLI:** `C:\Users\oldga\.gemini\settings.json`
- **Antigravity IDE:** `C:\Users\oldga\.gemini\antigravity-ide\mcp_config.json` e schemas em `C:\Users\oldga\.gemini\antigravity-ide\mcp\open77-devkit\`
- **Claude Code:** `C:\Users\oldga\.claude.json`
- **Cursor:** `C:\Users\oldga\.cursor\mcp.json`
- **Codex CLI:** `C:\Users\oldga\.codex\config.toml`
- **VS Code:** `C:\Users\oldga\AppData\Roaming\Code\User\mcp.json`

---

## 2. Geração de Tipos Lua e Autocomplete (.luarc.json)

Para habilitar autocompletar e tipagem no VS Code / Cursor / Lua Language Server:

```bash
npx -y @open2077/mcp types
```

Gera na pasta atual:
- `open77-client.d.lua` (Tipagem nativa do cliente)
- `open77-server.d.lua` (Tipagem nativa do servidor)
- `.luarc.json` (Configuração do Lua Language Server)

---

## 3. Ferramentas Disponibilizadas pelo MCP (27 Tools)

| Ferramenta | Propósito |
| :--- | :--- |
| `open77_search` | Busca lexical por nativas, guias, eventos e permissões |
| `open77_api` | Exibe o card completo de uma nativa com parâmetros e retorno |
| `open77_namespace` | Lista nativas pertencentes a um namespace (ex: `Open77.vehicles`) |
| `open77_guide` | Lê qualquer guia da documentação oficial em formato Markdown |
| `open77_events` | Consulta eventos de rede por prefixo (`open77:map`, `open77:vitals`) |
| `open77_permissions` | Consulta permissões necessárias do manifesto |
| `open77_data` | Busca identificadores de veículos, armas, roupas e NPCs do TweakDB |
| `open77_fivem_equivalent` | Tradutor de nativas FiveM -> Open77 |
| `open77_manifest_schema` | Validador e esquema do arquivo `open77.lua` |
| `open77_server_config_schema`| Validador do arquivo `server.jsonc` |
| `open77_validate` | Realiza análise estática completa de um recurso |
| `open77_new_resource` | Cria um recurso com a estrutura padrão correta |
| `open77_server_status` | Status do servidor via painel Warden |
| `open77_resources` | Lista de recursos ativos no servidor |
| `open77_console_command` | Executa comandos no console do servidor |
| `open77_tunables` | Gerencia tunables em tempo real |
| `open77_workshop_*` | Pesquisa e instalação de recursos do Workshop comunitário |
