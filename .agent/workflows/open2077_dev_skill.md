# WORKFLOW SOP: OPEN//77 RESOURCE DEVELOPMENT

> Procedimento Operacional Padrão (SOP) para criação e manutenção de recursos e sistemas no servidor OPEN//77.

---

## 1. Verificação Prévia e Validação de Nativas
1. Antes de codificar qualquer recurso, pesquise as nativas via MCP (`open77_search` ou `open77_api`).
2. Confirme a permissão requerida e adicione-a no `open77.lua`.
3. Garanta que a assinatura respeite a divisão de runtimes (Client vs Server).

## 2. Criação do Recurso
1. Crie a pasta do módulo em `resources/<categoria>/[modulo]`.
2. Configure o manifesto `open77.lua` declarando:
   - `client_scripts`
   - `server_scripts`
   - `shared_scripts` (se houver)
   - `permissions`
   - `web_ui_page` e `web_files` (se possuir NUI)
3. Execute `open77_validate` no MCP para garantir que a gramática está em conformidade com o build `2.31.13+op77.78`.

## 3. Padrão de Autoridade e Rede
1. NUNCA valide inventário, saldo bancário ou vida no cliente.
2. Comunique intenções via `TriggerServerEvent` e deixe o controlador no servidor validar e descontar no PostgreSQL/Redis.
3. Para dados reativos contínuos (ex: biomonitor Kiroshi), utilize `Entity(ped).state:set("chave", valor, true)` via State Bags.
4. Para transferências pesadas de dados (ex: catálogos complexos), utilize `TriggerLatentClientEvent`.

## 4. Front-End NUI (Svelte 5)
1. Crie componentes com `$state` e `$derived`.
2. Estilize seguindo o padrão Kiroshi (`#080E19` com 85% de opacidade, `#22D8E2` Cyan e `#FF5964` Neon Red).
3. Conecte requisições via `fetch("https://open77-webui/<endpoint>", ...)` e capture com `RegisterNUICallback`.

## 5. Verificação e Build
1. Gere os stubs de tipagem atualizados: `npx -y @open2077/mcp types`.
2. Valide o código Lua sem erros de sintaxe ou vazamento de ticks desnecessários (`Wait(0)`).
