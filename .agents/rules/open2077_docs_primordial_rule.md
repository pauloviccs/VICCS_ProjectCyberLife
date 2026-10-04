# Regra Primordial: Documentação Oficial OPEN//77 como Fonte da Verdade

> **URL OFICIAL:** [https://open2077.net/docs](https://open2077.net/docs)  
> **APLICABILIDADE:** Global, obrigatória e inegociável para todos os recursos, scripts, sistemas, ferramentas e agentes do projeto.

---

## 1. O Princípio da Verdade Canônica

O ecossistema **OPEN//77** é um ambiente multiplayer dedicado para Cyberpunk 2077 construído sobre a **REDengine 4**. Ele **NÃO É** FiveM, **NÃO É** RedM, **NÃO É** QBCore, **NÃO É** ESX e **NÃO É** ox_lib.

Qualquer implementação, refatoração, criação de script ou diagnóstico **DEVE OBRIGATORIAMENTE** seguir a documentação oficial da plataforma:
👉 **[https://open2077.net/docs](https://open2077.net/docs)**

---

## 2. Diretrizes Inegociáveis de Engenharia

1. **Consulta Prévia Mandatória (Docs First):**
   - Antes de escrever ou sugerir qualquer linha de código Lua, NUI/CEF ou manifesto `open77.lua`, verifique a documentação oficial e os stubs de tipagem do projeto (`Server/open77-client.d.lua`, `Server/open77-server.d.lua`).
   - Se uma função ou API não constar na documentação do OPEN//77 ou nos stubs oficiais, **ela NÃO existe e é proibido inventá-la**.

2. **Proibição Absoluta de Padrões FiveM/GTA V Alucinados:**
   - ❌ **PROIBIDO:** `RegisterNUICallback`, `SendNUIMessage`, `PlayerPedId()`, `GetEntityCoords()`, `SetEntityCoords()`, `IsControlJustPressed(0, 38)`, `exports['ox_target']:addSphereZone`, `TriggerClientEvent` com sintaxe FiveM legada.
   - ✅ **PADRÃO OPEN//77:**
     - Posição do jogador: `Open77.character.position()`
     - Teleporte: `Open77.travel.teleport(coords, heading)`
     - 3D World Markers: `Open77.markers.create(...)` e `exports.open77_worldui:create(...)`
     - Map Pins / Blips: `Open77.blips.create(...)` com permissão `ui.vanilla.map` e evento `open77:worldReady`
     - Input do jogador: `Open77.input.isActionJustPressed(...)`
     - Eventos CEF: `page:send(eventName, payloadTable)` e `Open77.on(eventName, handler)`
     - Chamadas de export: `Open77.exports.call(resource, method, ...):await()`

3. **Permissões Explícitas no Manifesto (`open77.lua`):**
   - Cada API nativa do OPEN//77 exige uma permissão declarada no bloco `permissions { ... }` do manifesto do recurso.
   - Exemplos:
     - `Open77.markers.*` exige `"world.markers"`
     - `Open77.blips.*` exige `"ui.vanilla.map"`
     - `Open77.travel.teleport` exige `"player.travel"`
     - `Open77.input.*` exige `"input.actions"`
     - WebUI nativa exige `"webui.system"`

4. **Tratamento de Assincronismo e Exports:**
   - Exports síncronos no servidor e cliente **NUNCA** podem conter `Wait()` ou ceder ticks (`export_yielded`).
   - Recursos do sistema e serviços inter-recursos devem ser chamados via promises protegidas (`promise:await()`).

5. **Resolução de Conflitos:**
   - Em caso de discrepância entre código legado, comentários de terceiros ou memória do modelo vs. **https://open2077.net/docs**, a **documentação oficial prevalece 100% das vezes**.
