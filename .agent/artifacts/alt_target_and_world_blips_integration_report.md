# Relatório Técnico: Integração ALT Target & Marcadores de Mapa (Open//77)

## 1. Visão Geral da Arquitetura
A interação com serviços em Night City foi completamente migrada de comandos de chat digitados (`/atm`, `/vending`, etc.) para uma experiência 100% diegética e imersiva baseada em:
1. **ALT Target (Mira/Olho com Raycast):** Integração com o framework nativo [`open77_contextmenu`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_contextmenu/). Segurar **ALT** ativa a mira de precisão Kiroshi e projeta o menu contextual com ícones e rótulos específicos ao clicar nos terminais, máquinas e balcões de atendimento.
2. **In-World 3D Prompts:** Integração com [`open77_interactions`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_interactions/) via `addModel` e `addSphereZone`, projetando anéis e diamantes holográficos com a tecla `[E]` ao se aproximar dos props físicos.
3. **Marcadores no Mapa Mundial (Blips):** Integração com a API nativa `Open77.blips.create` com suporte a traçado de rota GPS (`routable = true`), títulos, descrições e cores neon temáticas.

---

## 2. Componentes e Arquivos Implementados

### 2.1 Configuração Espacial e Catálogo de POIs
- **Arquivo:** [`ls_economy/shared/config.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/shared/config.lua)
- **Implementações:**
  - `EconomyConfig.BlipSettings`: Configurações de sprites, cores neon e descrições para cada categoria:
    - **ATMs:** Ciano Neon (`#22D8E2`), sprite `drop_point`.
    - **Vending Machines:** Amarelo Cyberpunk (`#FCEE0A`), sprite `food`.
    - **Ripperdocs:** Vermelho Neon Cirúrgico (`#FF003C`), sprite `ripperdoc`.
    - **Mercados:** Verde Neon Comercial (`#00FF66`), sprite `vendor`.
  - `EconomyConfig.TargetProps`: Seletores de classes e registros de props (`atm*`, `terminal*`, `vending*`, `ripper*`, `register*`).
  - `EconomyConfig.AtmLocations`: 10 localizações reais de caixas eletrônicos (H10 Lobby, H10 Corredores, Afterlife, Kabuki, Corpo Plaza, Downtown, Japantown, Glen, Pacifica, Badlands).
  - `EconomyConfig.VendingLocations`: 10 localizações de dispensadores de conveniência All-Foods em Watson, Westbrook, Heywood e City Center.
  - `EconomyConfig.RipperdocLocations`: 7 clínicas cirúrgicas completas (Viktor Vector, Robert Rainwater em Kabuki, Fingers em Japantown, Downtown Clinic, Wellsprings, Pacifica e Aldecaldos).
  - `EconomyConfig.MarketLocations`: 6 mercados 24/7 e feiras gastronômicas de Night City.

### 2.2 Gerenciador de Alvo e Mira (ALT Target & 3D Cards)
- **Arquivo:** [`ls_economy/client/targets.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/client/targets.lua)
- **Exportações para Context Menu:**
  - `targetCanInteractAtm` & `targetSelectAtm` -> Aciona `exports["ls_ui"]:openAtm()`.
  - `targetCanInteractVending` & `targetSelectVending` -> Aciona `exports["ls_ui"]:openVending()`.
  - `targetCanInteractRipperdoc` & `targetSelectRipperdoc` -> Aciona `exports["ls_ui"]:openRipperdoc()`.
  - `targetCanInteractMarket` & `targetSelectMarket` -> Aciona `exports["ls_ui"]:openVending()`.
- **World 3D Cards:**
  - Registra standing rules via `open77_interactions`: `addModel` para modelos ambientais e `addSphereZone` para cada local mapeado com cores correspondentes e acionamento pela tecla `E`.

### 2.3 Gerenciador de Marcadores de Mapa Mundial
- **Arquivo:** [`ls_economy/client/blips.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/client/blips.lua)
- **Funcionalidades:**
  - Disparo no ciclo `open77:worldReady` e no `onClientResourceStart`.
  - Criação resiliente com 3 camadas de fallback: Sprite de 2.31 (`drop_point`, `food`, `ripperdoc`, `vendor`), Fallback contextual, e Fallback universal garantido (`fast_travel`).
  - Habilita `routable = true` para permitir marcação de waypoints e navegação GPS do Cyberpunk 2077 direto até a máquina/clínica.
  - Comando `/syncblips` para ressincronização sob demanda.

### 2.4 Manifesto Atualizado
- **Arquivo:** [`ls_economy/open77.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/gamemodes/lifesim/ls_economy/open77.lua)
- **Atualizações:**
  - Dependências: `open77_contextmenu >=1.1.0` e `open77_interactions >=0.1.0`.
  - Scripts: Inclusão de `client/targets.lua` e `client/blips.lua`.
  - Permissões: `"ui.vanilla.map"`, `"local.events"`, `"input.actions"`, `"world.query"`.

---

## 3. Verificação e Testes
- Validação de configurações via `check_config.bat`: **PASS (Código 0)**.
- Integridade estrutural e balanceamento de blocos Lua: **100% Válido**.
