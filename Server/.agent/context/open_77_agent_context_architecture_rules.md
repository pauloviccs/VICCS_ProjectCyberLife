# AGENT CONTEXT: OPEN//77 NIGHT CITY LIFE-SIM RP

> **Escopo do Sistema:** Contexto operacional e técnico para agentes de IA autônomos e assistentes de desenvolvimento atuando no desenvolvimento do servidor *OPEN//77 Life-Sim RP* (baseado no ecossistema multijogador independente de *Cyberpunk 2077* v2.31 / *Phantom Liberty*).

---

## 1. Visão Geral e Identidade do Projeto

- **Nome do Projeto:** OPEN//77 Life-Sim RP.
- **Propósito:** Converter Night City em uma plataforma persistente de simulação social e biológica profunda (*Life-Sim*), inspirada em mecânicas clássicas de *The Sims 4* transpostas para a distopia corporativa e tecnológica de *Cyberpunk 2077*.
- **Foco de Gameplay:** Menos focado em tiroteios aleatórios desestruturados; focado em sobrevivência metabólica diária, progressão patrimonial, trabalho corporativo/serviços públicos, habitação vertical instanciada, gestão de ciberpsicose e relações sociais mediadas por sistemas autoritativos.

---

## 2. Stack Tecnológica e Invariantes Arquiteturais

Qualquer código gerado ou refatorado pelo agente DEVE obedecer rigorosamente à divisão de camadas da stack:

| Camada | Tecnologia | Papel Crítico | Invariante Técnico |
| :--- | :--- | :--- | :--- |
| **Servidor Host** | Linux x64 (.NET 8 Runtime) | Binário do servidor OPEN//77 | Processos assíncronos, alta densidade de I/O em rede. |
| **Runtime de Scripts** | Lua 5.4 isolado por recurso | Lógica de negócio e regras de RP | Cada recurso executa em VM Lua isolada; suporte nativo a Hot-Reload. |
| **Estado Volátil / Cache** | Redis 7 (In-Memory) | Biometria, sessões, calor neural e coordenadas | Leituras e escritas atômicas sub-milissegundo via scripts Lua Redis. |
| **Persistência Central** | PostgreSQL 16 + PgBouncer | Inventários, propriedades, histórico financeiro | Conformidade estrita com ACID, locks de transação e colunas `JSONB`. |
| **Front-End / NUI** | Svelte 5 (Runes) + Tailwind CSS | HUD Kiroshi, Smartphone, Terminais, Modo Construção | Renderização no Edge WebView2 (Chromium out-of-process). Sem VDOM. |
| **Áudio Espacial** | `open-voice` | Comunicação 3D com oclusão geométrica | Atenuação por paredes/veículos e efeito diegético de holocalls Kiroshi. |

### Regras Mandatórias de Autoridade e Rede:
1. **Server-Authoritative:** O cliente NUNCA valida dinheiro, integridade física, criação de itens ou posse imobiliária. O cliente apenas envia intenções de comando (`events`) com parâmetros higienizados.
2. **Estratégia Write-Behind Caching:** Mutações contínuas de alta frequência (digestão de comida, exaustão, calor de ciberware) são gravadas no Redis. Um agendador assíncrono descarrega em lotes a cada 5 minutos no PostgreSQL.
3. **Prevenção de Duplicação Financeira:** Operações monetárias e transferência de bens NUNCA utilizam o cache intermediário. Devem invocar transações relacionais imediatas com lock no PostgreSQL via `Open77.database`.
4. **Sincronização por State Bags:** Atualizações de estado visíveis na rede devem priorizar a infraestrutura de `Entity(id).state[key] = value`, transmitindo apenas diferenciais (*deltas*).

---

## 3. Estrutura Padrão de Diretórios dos Recursos (Resources)

Todo recurso do servidor deve seguir o layout modular abaixo:

```text
resources/
└── [open77_modulo]/
    ├── open77.lua          # Manifesto autoritativo do recurso
    ├── config.lua          # Tabelas de configuração expostas
    ├── server/
    │   ├── main.lua        # Entry-point do servidor
    │   ├── controllers/    # Controladores de regras de negócio
    │   └── services/       # Conexões diretas Redis / Postgres
    ├── client/
    │   ├── main.lua        # Entry-point do cliente (REDengine bridge)
    │   ├── camera.lua      # Câmeras scriptadas e Raycasts
    │   └── nui.lua         # Ponte de eventos bidirecional com a WebUI
    └── web/                # Projeto Svelte 5 (compilado para dist/)
        ├── package.json
        ├── svelte.config.js
        ├── src/
        │   ├── App.svelte
        │   ├── stores/     # Svelte 5 Runes ($state, $derived)
        │   └── components/ # Componentes HUD / Janelas modais
        └── dist/           # Arquivos estáticos consumidos pelo WebView2
```

### Manifesto Padrão (`open77.lua`):
```lua
open77_version 'v2.31'
author 'Equipe OPEN//77'
description 'Modulo de Biometria e Ciberpsicose'

server_scripts {
    'config.lua',
    'server/services/*.lua',
    'server/controllers/*.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/camera.lua',
    'client/nui.lua',
    'client/main.lua'
}

web_ui_page 'web/dist/index.html'

web_files {
    'web/dist/index.html',
    'web/dist/assets/**'
}
```

---

## 4. Diretrizes dos Sistemas Centrais (Game Design Invariants)

### 4.1. Gestão Biomecânica & Degradação Vital
- **Taxas de decaimento padrão:**
  - Nutrição: `-1.0%` a cada 60s reais.
  - Hidratação: `-1.5%` a cada 60s reais.
  - Sono/Energia: `-0.8%` a cada 60s reais.
  - Higiene: `-0.7%` a cada 60s reais.
- **Cálculo de Estabilidade Neural:**
  $$\text{Estabilidade Base} = 100 - (\text{Qtd Implantes} \times 9) - \text{Fator Stress} - \text{Penalidade Neurobloqueador}$$
- **Gatilho de Ciberpsicose:** Quando a estabilidade neural atinge $< 20\%$, o cliente dispara distorções de áudio/pós-processamento avermelhado na REDengine. Se o jogador efetuar disparos hostis no raio urbano, o servidor despacha um alerta com prioridade máxima gerando contrato para as patrulhas MaxTac.

### 4.2. Habitação Vertical & Routing Buckets
- Megabuildings utilizam instanciamento por **Routing Buckets** (`bucket` id único associado ao imóvel).
- Interiores compartilham as mesmas coordenadas cartesianas globais ($X, Y, Z$), mas são fisicamente e visualmente isolados no pipeline de rede pelo servidor.
- Limites habitacionais para colocação de móveis no Modo Construção (*Build Mode*) DEVEM ser validados via `PolyZone` tridimensional no lado do servidor antes de persistir no PostgreSQL e emitir `server.CreateProp`.
- Transição de andares e saguões deve ser gerida via `Open77.elevators.goTo`.

### 4.3. Economia Circular & Drenos Monetários (*Money Sinks*)
- Toda nova fonte de emissão de Eurodólares ($E\$$) DEVE possuir um dreno correspondente:
  - Aluguel diário descontado automaticamente à meia-noite do jogo.
  - Degradação de próteses exigindo sprays criogênicos em Ripperdocs.
  - Mensalidades de planos de saúde Trauma Team (Silver/Gold/Platinum).
  - Tarifas corporativas de trânsito e pedágios automatizados de distritos.

---

## 5. Diretrizes de Front-End & NUI (Svelte 5 + WebView2)

1. **Sem Virtual DOM:** Proibido o uso de React ou bibliotecas com ciclos pesados de reconciliação de VDOM. A UI roda dentro do Edge WebView2 e não pode alocar lixo de memória (*Garbage Collector pauses*).
2. **Utilizar Svelte 5 Runes:** Utilize `$state`, `$derived` e `$effect` para gerenciamento de estado reativo de alta frequência.
3. **Padrão Estético Diegético (Kiroshi Optical Overlay):**
   - Backgrounds: `#080E19` com opacidade de $80\%$ a $90\%$ e `backdrop-blur-md`.
   - Cores primárias de destaque: Cyan elétrico (`#22D8E2`) e Branco Frio (`#F2F6F8`).
   - Alertas críticos e ciberpsicose: Signal Coral / Vermelho Néon (`#FF5964`).
   - Fontes: Monoespaçadas para números e telemetria (`JetBrains Mono`, `Chakra Petch`).
4. **Comunicação NUI Bidirecional:**
   - Client -> WebUI: Disparar via evento de mensagem WebView2.
   - WebUI -> Client: Realizar requisições `fetch` capturadas pelo manipulador seguro do OPEN//77 (`fetch("https://open77-webui/endpoint", ...)`).
   - Bloqueio de controle: Ao abrir UIs complexas, invocar a rotina de travamento de cursor e teclado no cliente; fechá-la ao pressionar `ESC` ou botão correspondente.

---

## 6. Padrões de Código e Exemplos

### 6.1. Exemplo de Manipulador de Servidor (Lua 5.4 + Redis Cache)
```lua
-- server/controllers/vitals.lua
local VitalsController = {}

RegisterNetEvent('open77:vitals:consumeItem', function(source, itemId)
    local src = source
    local playerLicense = Open77.getIdentifier(src, 'license')
    if not playerLicense then return end

    -- Validação do item no inventário (PostgreSQL / Memory Cache)
    if not InventoryService.hasItem(playerLicense, itemId, 1) then
        TriggerClientEvent('open77:notify', src, { type = 'error', text = 'Item inexistente.' })
        return
    end

    local itemMeta = ItemDatabase[itemId]
    if not itemMeta then return end

    InventoryService.removeItem(playerLicense, itemId, 1)

    -- Atualização atômica em Redis (Sub-milissegundo)
    local redisKey = string.format("player:%s:vitals", playerLicense)
    local currentNutrition = tonumber(RedisService.hget(redisKey, "nutrition") or "100")
    local newNutrition = math.min(100, currentNutrition + (itemMeta.nutritionValue or 0))
    RedisService.hset(redisKey, "nutrition", tostring(newNutrition))

    -- Atualiza state bag com delta para o cliente
    Entity(GetPlayerPed(src)).state:set('nutrition', newNutrition, true)
    
    TriggerClientEvent('open77:notify', src, { 
        type = 'success', 
        text = string.format('Consumido: %s (+%d Nutrição)', itemMeta.label, itemMeta.nutritionValue)
    })
end)
```

### 6.2. Exemplo de Componente NUI (Svelte 5)
```html
<!-- web/src/components/BiometricsHud.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';

  let nutrition = $state(100);
  let neuralStability = $state(100);
  let isCyberpsychosisRisk = $derived(neuralStability < 20);

  onMount(() => {
    window.addEventListener('message', (event) => {
      const { action, data } = event.data;
      if (action === 'UPDATE_VITALS') {
        nutrition = data.nutrition;
        neuralStability = data.neuralStability;
      }
    });
  });
</script>

<aside class="fixed bottom-6 right-6 p-4 rounded-lg bg-[#080E19]/85 backdrop-blur-md border border-cyan-500/30 text-[#F2F6F8] font-mono w-64 shadow-2xl">
  <div class="flex justify-between items-center text-xs text-cyan-400 mb-2 border-b border-cyan-900/50 pb-1">
    <span>KIROSHI BIOMONITOR</span>
    <span class="animate-pulse">● LIVE</span>
  </div>

  <div class="space-y-3 text-xs">
    <div>
      <div class="flex justify-between mb-1">
        <span class="text-slate-400">Nutrição:</span>
        <span class="font-bold">{nutrition}%</span>
      </div>
      <div class="w-full bg-slate-800 h-1.5 rounded-full overflow-hidden">
        <div class="bg-cyan-400 h-full transition-all duration-300" style="width: {nutrition}%"></div>
      </div>
    </div>

    <div>
      <div class="flex justify-between mb-1">
        <span class="text-slate-400">Estabilidade Neural:</span>
        <span class="font-bold {isCyberpsychosisRisk ? 'text-red-500 animate-pulse' : 'text-emerald-400'}">{neuralStability}%</span>
      </div>
      <div class="w-full bg-slate-800 h-1.5 rounded-full overflow-hidden">
        <div class="h-full transition-all duration-300 {isCyberpsychosisRisk ? 'bg-red-500' : 'bg-emerald-400'}" style="width: {neuralStability}%"></div>
      </div>
    </div>
  </div>

  {#if isCyberpsychosisRisk}
    <div class="mt-3 p-2 bg-red-950/70 border border-red-600 text-red-200 text-[10px] uppercase font-bold text-center tracking-wider animate-bounce">
      ALERTA: Tensão Neural Crítica
    </div>
  {/if}
</aside>
```

---

## 7. Regras de Atuação para o Agente na IDE

Ao gerar ou editar código neste projeto, o agente DEVE:
1. **Verificar Performance de Alocação:** Nunca criar loops com `Citizen.Wait(0)` desnecessários em Lua. Em clientes, escaneamentos de proximidade devem ter taxa adaptativa (`500ms` quando ocioso, `0ms` apenas no ponto de colisão ou renderização ativa de gizmo).
2. **Isolamento de Erros:** Sempre proteger parsing de JSON ou chamadas a banco de dados com `pcall` ou blocos estruturados de captura para evitar derrubar a VM do recurso.
3. **Preservar a Diegese:** Mensagens de sistema, erros de UI e interações com o jogador devem adotar a terminologia do universo Cyberpunk (ex.: Eurodólares, Edgerunners, Kiroshi, Neurobloqueadores, Trauma Team, NCPD).
4. **Sem Código Hipotético Não Tipado na UI:** Código TypeScript/Svelte deve possuir interfaces explícitas para as mensagens enviadas e recebidas da REDengine.