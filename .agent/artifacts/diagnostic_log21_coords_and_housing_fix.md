# Diagnóstico & Correção - Log 21 (open77_coords & ls_housing)

## 1. Causa Raiz do Problema [2] (/coords não abria a interface)

### Diagnóstico no Log 21:
No `client-console.log` (linhas 738, 773, 800, 2380, 2472, 2492):
```text
[resource:open77_coords] open77_coords/client/main.lua:37: attempt to index a number value (local 'pos')
```

### O Porquê Técnico (REDengine 4 / Open77):
- Diferente de engines que retornam um vetor como tabela `{x, y, z}`, a native C++ do Open77 (`LuaCharacterPosition` em `ResourceHost.cpp`) empurra **3 retornos numéricos soltos na pilha do Lua** (`x, y, z`).
- Ao executar `local pos = Open77.character.position()`, a variável `pos` recebia apenas o primeiro retorno (um número float `x`). Ao tentar `pos.x` na linha 37, o interpretador Lua abortava imediatamente com `attempt to index a number value`, impedindo que a WebUI chegasse a chamar `page:show()` e `page:setFocus(true, true)`.

### Solução Aplicada:
1. Em [open77_coords/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_coords/client/main.lua):
   - Refatorada a função `captureSpatialSnapshot()` para desempacotar `local r1, r2, r3 = Open77.character.position()` com suporte tanto a 3 números quanto a tabela, e fallback robusto para `Open77.character.state().position`.
   - Adicionada computação segura de vetor frontal (`forward`) via quaternion de orientação (`state.orientation`) e cálculo trigonométrico via `yaw`.
   - Adicionado cache de snapshot (`lastSnapshot`) e sincronização imediata no evento `coords:ready`.
2. Em [open77_coords/open77.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_coords/open77.lua):
   - Adicionadas as permissões oficiais `"webui.system"` e `"network.client"`, além de `files { "web/**" }` no manifesto.

---

## 2. Causa Raiz do Problema [1] (Markers da residência não respondem à tecla "E")

### Diagnóstico no Log 21 & Código Fonte:
1. **Perda de Argumento no Evento do open77_worldui / open77_interactions:**
   - O recurso `open77_worldui` delega a criação do card 3D para `open77_interactions` com o identificador `open77_worldui_housing_door_<id>`.
   - Quando o jogador aciona a interação, o `open77_interactions` emite o evento `ls:housing:openDoorTarget` com uma tabela de `payload` contendo `{ interactionId = "open77_worldui_housing_door_h10_apt_v", ... }`.
   - O cliente de `ls_housing` esperava `args.aptId` ou uma string pura. Como `args.aptId` era `nil`, a verificação `if aptId then` falhava silenciosamente e o evento de rede `TriggerServerEvent("ls:housing:requestInfo", aptId)` **nunca era disparado**.
2. **Incompatibilidade de Polling de Input no Fallback de Proximidade:**
   - A função de proximidade verificava apenas `ChoiceApply` / `IsControlJustPressed`. Em REDengine 4 / Open77, o teclado nativo é lido via `Open77.input.isDown("e")`. Sem essa checagem e sem a detecção de transição (edge-trigger), o clique na tecla física "E" era ignorado.
3. **Desempacotamento de Coordenadas:**
   - `getLocalCoords()` também esperava que `Open77.character.position()` retornasse uma tabela, falhando na leitura de posição em certas chamadas.

### Soluções Aplicadas:
1. Em [ls_housing/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/client/main.lua):
   - Atualizado o handler `ls:housing:openDoorTarget` para extrair o `aptId` via regex do `interactionId`:
     `tostring(args.interactionId):match("housing_door_([%w_]+)")`, com fallback para `nearbyDoorApt.id`.
   - Reescrito `getLocalCoords()` para tratar retornos múltiplos de números float e fallback de estado.
   - Implementada detecção de tecla física `[E]` com `Open77.input.isDown("e")` e detecção de transição (edge-detection), prevenindo repetições e garantindo resposta imediata ao toque.
   - Adicionada chamada explícita `page:show()` e `page:setFocus(true, true)` ao receber os dados do servidor em `ls:housing:receiveInfo`, e `page:hide()` ao fechar a interface.
2. Em [ls_housing/client/interactions.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/client/interactions.lua):
   - Padronizado `getPlayerCoords()` e `isInteractActionPressed()` com suporte nativo a `Open77.input.isDown("e")`.
3. Em [ls_housing/open77.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/open77.lua):
   - Declaradas as dependências explícitas: `dependency "open77_worldui >=0.1.0"` e `dependency "open77_interactions >=0.1.0"`.

---

## 3. Arquivos Alterados

| Arquivo | Mudança Principal |
|---|---|
| [open77_coords/open77.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_coords/open77.lua) | Adicionadas permissões `webui.system`, `network.client` e `files { "web/**" }` |
| [open77_coords/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_coords/client/main.lua) | Desempacotamento de 3 números float de `Open77.character.position()` e sincronização CEF |
| [ls_housing/open77.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/open77.lua) | Adicionadas dependências `open77_worldui` e `open77_interactions` |
| [ls_housing/client/main.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/client/main.lua) | Extração resiliente de `aptId` via `interactionId`, detecção de tecla `[E]` nativa e `page:show()` |
| [ls_housing/client/interactions.lua](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_housing/client/interactions.lua) | Normalização de coordenadas de jogador e polling de input do Open77 |
