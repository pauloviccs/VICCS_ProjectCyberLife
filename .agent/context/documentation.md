# DOCUMENTAÇÃO OFICIAL & GUIA TÉCNICO: OPEN//77 (Cyberpunk 2077 Multiplayer)

> **Versão Alvo:** Cyberpunk 2077 v2.31 + Phantom Liberty DLC  
> **Open77 Build:** 2.31.13+op77.78 (ou mais recente)  
> **Runtime:** Lua 5.4 isolado por recurso (Client & Server)  
> **Fonte Oficial:** [open2077.net](https://open2077.net/) | [open2077.net/docs](https://open2077.net/docs)

---

## 1. Visão Geral da Plataforma

O **OPEN//77** é a camada multiplayer dedicada para *Cyberpunk 2077*. O servidor é totalmente autoritativo (*server-authoritative*), operando em Linux x64 (.NET 8 Runtime) ou Windows, e executa recursos empacotados em Lua 5.4 com sincronização em rede de alta performance.

### Princípios Fundamentais

1. **Server-Authoritative:** O cliente NUNCA decide dinheiro, integridade física, criação de itens, inventário, dano canônico, tempo, clima ou rotas. O cliente apenas renderiza o estado aprovado e submete intenções com parâmetros validados.
2. **IDs Opassos da REDengine:** Identificadores da REDengine são inteiros de 64 bits. Devem ser tratados como valores opacos: nunca convertidos com `tonumber()`, mas comparados e transmitidos intactos.
3. **Falhas como Valores:** As APIs do Open77 retornam `val` em sucesso ou `nil, reason` (string estável em snake_case) em falha. Isso dispensa o uso excessivo de `pcall`.
4. **Permissões Explícitas:** Todo acesso a APIs protegidas requer declaração no manifesto `open77.lua` via `permissions { ... }`.
5. **Isolamento de Runtimes:** O código de `server_script` nunca trafega para o cliente. Apenas `client_script`, `shared_script` e arquivos declarados em `files` ou `web_files` são empacotados, assinados e transmitidos aos jogadores.

---

## 2. Estrutura de Diretórios de Recursos (Resources)

A pasta raiz de recursos do servidor organiza-se em categorias:

```text
resources/
├── system/             # Recursos base da plataforma (open77_shell, open77_chat, open-voice, etc.)
├── gamemodes/          # Modos de jogo e regras de RP (freeroam, life-sim, race, deathmatch, cordon)
├── dev/                # Ambientes de teste, testes de banco de dados
└── assets/
    ├── loaders/        # ArchiveXL, TweakXL (redistribuídos pela plataforma)
    ├── maps/           # Pacotes de mapas mundiais (.archive)
    ├── vehicles/       # Pacotes de veículos customizados
    └── mods/           # Outros mods terceiros (gerenciados pelo servidor)
```

---

## 3. Estrutura e Manifesto do Recurso (`open77.lua`)

Todo recurso requer um arquivo `open77.lua` na sua raiz:

```lua
resource "meu_recurso"
version "1.0.0"
author "Equipe do Servidor"
description "Sistema de Economia e Inventário"
auto_start true

-- Scripts Compartilhados, Servidor e Cliente
shared_script "shared/config.lua"

server_scripts {
    "server/services/*.lua",
    "server/controllers/*.lua",
    "server/main.lua"
}

client_scripts {
    "client/camera.lua",
    "client/nui.lua",
    "client/main.lua"
}

-- Interface Web (WebView2)
web_ui_page "web/dist/index.html"
web_files {
    "web/dist/index.html",
    "web/dist/assets/**"
}

-- Arquivos estáticos consumidos pelo cliente Lua (áudio, texturas, blips)
files {
    "assets/blips/*.png",
    "assets/audio/*.wav"
}

-- Permissões explícitas requisitadas
permissions {
    "network.events",
    "world.loot",
    "database.query"
}

-- Exportações Declarativas (opcional, exporta funções globais do nome correspondente)
exports { "GetClosestDoor", "IsDoorOpen" }
server_exports { "GetBalance", "AddMoney" }
```

### Regras do Manifesto

- **`shared_script` / `shared_scripts`**: Carregado em ambos os runtimes.
- **`preload_mod` / `preload_mods`**: Declara pacotes de assets pré-boot (.zip/.7z contendo .archive/XBM). Baixados pelo launcher antes de iniciar o Cyberpunk.
- **Inclusões cruzadas proibidas:** `@outro_recurso/arquivo.lua` é **proibido** e rejeitado pelo parser do manifesto. O compartilhamento entre recursos é feito via `exports` ou `require('@recurso/modulo')`.
- **Compatibilidade com FiveM:** Chaves como `fx_version`, `game`, `lua54` são toleradas e ignoradas com um aviso informativo (`manifest_ignored_keys`).

---

## 4. Comunicação em Rede & Eventos

### 4.1. Eventos Tradicionais

- **Servidor -> Cliente:**

  ```lua
  -- No Servidor:
  TriggerClientEvent("open77:vitals:update", targetPlayerId, payload)
  TriggerClientEvent("open77:vitals:broadcast", -1, payload) -- broadcast para todos
  ```

- **Cliente -> Servidor:**

  ```lua
  -- No Cliente:
  TriggerServerEvent("open77:vitals:requestSync", itemId)
  ```

- **Manipulador de Evento:**

  ```lua
  RegisterNetEvent("open77:vitals:consumeItem", function(source, itemId)
      -- 'source' no servidor é sempre o ID confiável da sessão
  end)
  ```

### 4.2. State Bags Replicados (State Replication)

Permite armazenar e sincronizar estados contínuos sem disparar eventos manuais repetitivos:

```lua
-- No Servidor:
Entity(ped).state:set("nutrition", 85, true) -- true replica para clientes

-- No Cliente (leitura reativa):
local nutrition = Entity(ped).state.nutrition
AddStateBagChangeHandler("nutrition", nil, function(bagName, key, value, _reserved, replicated)
    print("Nutrição atualizada para: " .. tostring(value))
end)
```

### 4.3. Callbacks de Rede (`Open77.net`)

Permite chamadas no estilo Request/Response assíncronas:

```lua
-- Servidor define o handler:
Open77.net.handle("vitals:getHealth", function(source, args)
    return { current = 100, max = 100 }
end)

-- Cliente invoca e aguarda:
local res, err = Open77.net.call("vitals:getHealth", {})
```

### 4.4. Eventos Latentes Fragmentados (`TriggerLatentClientEvent` / `Open77.net.emitLatent`)

Para transferências volumosas de dados (até 4 MiB) sem saturar a banda, divididos em pacotes de 40 KiB com taxa definida.

---

## 5. Camada de Compatibilidade FiveM: Equivalências & Armadilhas

| Recurso FiveM | Suporte no Open77 | Equivalente / Detalhe no Open77 |
| :--- | :--- | :--- |
| `Citizen.CreateThread` / `Wait` | Sim | É idêntico ao `CreateThread` e `Wait` globais. |
| `SetTick(fn)` / `ClearTick(id)` | Sim | Executa a cada tick/frame. Cancela após 5 falhas consecutivas para proteger performance. |
| `promise.new()` | Sim | Mesma tipagem do `Open77.Promise`. `Citizen.Await(p)` ou `p:await()`. |
| `IsDuplicityVersion()` | Sim | Retorna `true` no servidor e `false` no cliente. |
| `LoadResourceFile(res, path)` | Sim | Restrito ao próprio recurso. Rejeita acesso cruzado (`cross_resource_read_denied`). |
| `SaveResourceFile(res, path, data)` | Servidor | Restrito ao servidor com permissão `filesystem.write`. Grava na pasta `data/`. |
| `GetHashKey(str)` / `joaat(str)` | Sim | **Atenção:** Gera o **TweakDBID** (CRC-32 + len), **NÃO** o hash Jenkins do GTA! |
| `RequestModel` / `HasModelLoaded` | **Não existe** | **Desnecessário**. A REDengine gerencia o streaming de modelos internamente. |
| `@outro_recurso/include.lua` | **Rejeitado** | Substituído por `exports` ou `require('@outro/modulo')`. |
| `SetPedToRagdoll` | Servidor | `Open77.players.ragdoll(id, { durationMs = 3000 })`. |
| `FreezeEntityPosition` | Ambos | `Open77.vehicles.setFrozen` / `Open77.players.setFrozen`. |

---

## 6. Interface Gráfica & NUI (Chromium WebView2)

- **Renderização Fora de Processo:** A interface roda em WebView2 no Edge Chromium out-of-process. O jogo não sofre quedas de framerate por repaints de UI.
- **Framework Recomendado:** Svelte 5 (Runes `$state`, `$derived`) ou Vanilla HTML/JS. Evitar React/VDOM pesado para minimizar coletas de lixo (GC pauses).
- **Padrão de Comunicação Bidirecional:**
  - **Cliente Lua -> WebUI:**

    ```lua
    SendNUIMessage({
        action = "UPDATE_HUD",
        data = { health = 100, money = 5000 }
    })
    ```

  - **WebUI -> Cliente Lua:**

    ```javascript
    fetch("https://open77-webui/meu_endpoint", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: "close" })
    });
    ```

  - **Captura no Cliente Lua:**

    ```lua
    RegisterNUICallback("meu_endpoint", function(data, cb)
        SetNuiFocus(false, false)
        cb({ ok = true })
    end)
    ```

---

## 7. Dados do Jogo (Catalogues & Identificadores)

- **Registros TweakDB:** Todos os veículos, itens, armas e roupas seguem a convenção de strings do TweakDB:
  - Veículos: `"Vehicle.v_standard2_thorton_galena_player"`, `"Vehicle.v_sport2_quadra_turbo_r"`
  - Armas: `"Items.Preset_Lexington_Default"`, `"Items.Preset_Katana_Default"`
  - Vestuário: `"Items.Coat_01_basic_01"`, etc.
  - NPCs: Mais de 6.582 registros sob `"Character.*"`.
- **Pesquisa via APIs:**
  - `Open77.data.vehicle(record)`
  - `Open77.data.weapon(record)`
  - `Open77.data.npc(record)`
  - `Open77.data.localize(key)` (Textos e legendas em múltiplos idiomas)

---

## 8. Ferramentas de Desenvolvimento e MCP (@open2077/mcp)

O pacote `@open2077/mcp` fornece 27 ferramentas MCP para o ecossistema de desenvolvimento:

- **`open77_search`**: Busca lexical em nativas, guias, eventos e permissões.
- **`open77_api`**: Retorna assinatura completa, permissões exigidas e razões de retorno.
- **`open77_validate`**: Análise estática do recurso e manifesto.
- **`open77_data`**: Procura nomes spawnáveis de veículos, armas, NPCs e props.
- **`open77_fivem_equivalent`**: Conversor e guia de equivalência FiveM -> Open77.
- **`open77_new_resource`**: Cria scaffolding de recurso correto por construção.
- **Tipagens para VS Code / Cursor:**

  ```bash
  npx -y @open2077/mcp types
  ```

  Gera `open77-client.d.lua`, `open77-server.d.lua` e `.luarc.json` para intellisense e autocompletion no Lua Language Server.
