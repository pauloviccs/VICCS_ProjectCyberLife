# REGRAS DO PROJETO - VICCS CYBERPUNK SERVER (OPEN//77)

## REGRA PRIMORDIAL GLOBAL (DOCUMENTAÇÃO OFICIAL COMO FONTE DA VERDADE)

1. **Fonte Canônica Absoluta:**
   Toda arquitetura, lógica, script Lua, interface NUI/CEF, manifesto `open77.lua` ou integração desenvolvida neste projeto **DEVE TER COMO FONTE PRIMORDIAL E EXCLUSIVA A DOCUMENTAÇÃO OFICIAL DO OPEN//77**:
   👉 **https://open2077.net/docs**

2. **Proibição de APIs Alucinadas ou Estrangeiras (Zero FiveM/RedM/GTA V):**
   - Este projeto roda sobre o motor **REDengine 4 (Cyberpunk 2077)**. É terminantemente proibido utilizar ou presumir APIs do FiveM/GTA V (`PlayerPedId`, `GetEntityCoords`, `SetEntityCoords`, `IsControlJustPressed(0, 38)`, `RegisterNUICallback`, `SendNUIMessage`, `ox_target:addSphereZone`, etc.).
   - Utilize sempre as tipagens e módulos oficiais do OPEN//77 expostos em `Server/open77-client.d.lua`, `Server/open77-server.d.lua` e nos 34 recursos do sistema em `Server/resources/system/`.

3. **Validação de Permissões de Manifesto:**
   - Manifestos `open77.lua` devem declarar todas as permissões exigidas pelas APIs nativas (`world.markers`, `ui.vanilla.map`, `player.travel`, `players.controls`, `webui.system`, `input.actions`, etc.).
   - Dependências devem ser explicitadas (`open77_worldui`, `open77_interactions`, etc.).

4. **Princípio do Cortex (.agent):**
   - Respeite o estado, a arquitetura e as diretrizes contidas na pasta `.agent/` (`context/`, `guidelines/`, `memory/`, `overview/`).
