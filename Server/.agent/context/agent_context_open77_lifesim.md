# AGENT CONTEXT — OPEN//77 Night City Life-Sim RP

> Coloque este arquivo em `.agent/context.md` na raiz do repositório do servidor.
> Leia-o **inteiro** antes de gerar ou editar qualquer código. Em caso de conflito com outros documentos do projeto, **este arquivo e a documentação oficial (https://open2077.net/docs) prevalecem**.
> Plano de fases completo: `OPEN77_LIFESIM_PLANO_IMPLEMENTACAO.md`.

---

## 0. Regras de ouro (resumo de 10 linhas)

1. O **servidor é a autoridade**. O cliente só renderiza estado aprovado e envia *intenções*.
2. Uma nativa **só existe se o MCP a retornar**. Consulte `open77_search` / `open77_api` antes de usar. Nunca invente API.
3. Declare **exatamente** as permissões que as nativas exigem no manifesto (`permissions { ... }`).
4. Nunca chame nativa de cliente em script de servidor (nem o contrário).
5. APIs retornam `val` ou `nil, reason` (snake_case). **Verifique o retorno.**
6. **Banco = MySQL/MariaDB** via `MySQL.*` / `Open77.database`. **PostgreSQL não é suportado.**
7. Dinheiro, itens e propriedade: **transação síncrona** no MariaDB. Nunca via cache.
8. Vitais/posição/calor: cache em memória + write-behind (flush 5 min + disconnect + resource stop).
9. Nunca aja server-side sobre jogador que não esteja vivo/pronto.
10. NUI: **Svelte 5 (Runes) + Tailwind**, sem React/VDOM. Tema Kiroshi.

---

## 1. Projeto

- **Nome:** OPEN//77 Life-Sim RP.
- **Base:** Cyberpunk 2077 v2.31 + Phantom Liberty, plataforma multiplayer OPEN//77 (**ALPHA** — APIs podem mudar).
- **Build alvo:** `2.31.13+op77.78` (confirmar com `open77_validate`).
- **Conceito:** simulação social e biológica persistente inspirada em The Sims 4, na distopia de Night City: necessidades vitais, trabalho, contas, habitação instanciada, cyberware com risco de ciberpsicose, facções e economia circular.
- **Loop diário:** (1) Manutenção biológica → (2) Atividade produtiva → (3) Socialização e consumo → (4) Gestão patrimonial.

---

## 2. Stack real (com correções em relação ao GDD)

| Camada | Tecnologia | Observação |
| :-- | :-- | :-- |
| Host | OPEN//77 server (.NET 8), Linux x64 ou Windows | Licenciado à conta; Warden para admin; RCON; métricas Prometheus |
| Scripts | Lua 5.4, **uma VM isolada por resource** | Hot-reload; compartilhar serviços via **server exports** |
| Persistência | **MariaDB / MySQL (InnoDB)** | Bridge nativa assíncrona; `database.enabled` em `server.jsonc`; conexão via env `OP77_DATABASE_CONNECTION` |
| Cache | **Em memória (Lua) via `CacheService`** | Redis não está documentado na plataforma; manter abstração para trocar depois |
| NUI | Svelte 5 + Tailwind no WebView2 (out-of-process) | Sem VDOM |
| Voz | `open-voice` | Espacial 3D, oclusão, holocall |

> O GDD cita PostgreSQL 16 + PgBouncer + Redis 7. **Ignore isso ao escrever código**: a plataforma só suporta MySQL/MariaDB. Use `JSON` onde o GDD diz `JSONB`.

---

## 3. Layout do repositório

```text
resources/
└── gamemodes/lifesim/
    ├── ls_core/        # config/tunables, identidade, personagens, event bus, comandos admin
    ├── ls_data/        # migrations, repositórios, CacheService, write-behind
    ├── ls_vitals/      # necessidades, decaimento, consumo
    ├── ls_cyberware/   # implantes, estabilidade neural, ciberpsicose, MaxTac
    ├── ls_economy/     # contas, ledger, transferências, money sinks
    ├── ls_inventory/   # itens, catálogo, uso
    ├── ls_housing/     # buckets, portas, elevadores, build mode, mobília
    ├── ls_jobs/        # carreiras, turnos, salários
    ├── ls_factions/    # NCPD, Trauma Team, gangues, reputação, contratos
    ├── ls_social/      # bares, afinidade, animações, celular
    └── ls_ui/          # Svelte 5 (HUD Kiroshi, apps)
```

Estrutura interna de um resource:

```text
<resource>/
├── open77.lua
├── config.lua                # shared_script
├── server/{main.lua, controllers/, services/}
├── client/{main.lua, nui.lua, camera.lua}
└── web/{package.json, src/, dist/}
```

### Manifesto (formato OFICIAL)

```lua
resource "ls_vitals"
version "0.1.0"
author "Equipe OPEN//77"
description "Motor de necessidades vitais"
auto_start true

shared_script "config.lua"

server_scripts {
    "server/services/*.lua",
    "server/controllers/*.lua",
    "server/main.lua"
}

client_scripts {
    "client/nui.lua",
    "client/main.lua"
}

permissions {
    "network.events",
    "database.access"     -- confirmar nome exato via open77_api / open77_validate
}

server_exports { "GetVitals", "ApplyDelta" }
```

Regras do manifesto:
- `@outro_recurso/arquivo.lua` é **proibido**. Compartilhe via `exports` / `server_exports` ou `require('@recurso/modulo')`.
- Chaves FiveM (`fx_version`, `game`, `lua54`) são ignoradas com aviso.
- `open77_version '...'` **não** faz parte do formato oficial — não usar.
- `preload_mod` só para pacotes `.archive` pré-boot.

---

## 4. Rede, estado e chamadas entre resources

### Eventos

```lua
-- Servidor -> cliente
TriggerClientEvent("ls:vitals:update", targetId, payload)

-- Cliente -> servidor
TriggerServerEvent("ls:vitals:consume", itemId)

-- Handler no servidor: `source` é confiável
RegisterNetEvent("ls:vitals:consume", function(source, itemId)
    local src = tonumber(source)                 -- ID de SESSÃO: tonumber é correto aqui
    if not src or src <= 0 then return end
    -- 1) validar tipo/tamanho do payload
    -- 2) validar autoridade (jogador vivo, pronto, com o item)
    -- 3) aplicar no servidor
    -- 4) replicar via state bag
end)
```

Convenção de nomes: `ls:<dominio>:<acao>`. Todo evento aceita **apenas** dados primitivos validados; nunca confie em valores como preço, quantidade ou posição vindos do cliente.

### State bags (preferido para estado replicado)

```lua
Player(src).state:set("nutrition", 85, true)      -- servidor (true = replica)

AddStateBagChangeHandler("nutrition", nil, function(bagName, key, value, _, replicated)
    -- atualizar HUD
end)
```

Replicar **deltas** e usar histerese para reduzir tráfego.

### Callbacks (request/response)

```lua
Open77.net.handle("ls:vitals:get", function(source, args) return { ... } end)   -- servidor
local res, err = Open77.net.call("ls:vitals:get", {})                            -- cliente
```

### Exports entre resources (serviços compartilhados)

```lua
exports("GetVitals", function(charId) ... end)                                    -- síncrono: NÃO pode dar yield
local v = Open77.exports.call("ls_vitals", "GetVitals", charId):await()            -- chamada assíncrona
-- Valide o chamador com GetInvokingResource(). Valores cruzam por CÓPIA.
```

`TriggerEvent` é local à VM. Export **não** cria ponto de entrada de rede.

### IDs — não confundir

| Tipo | Regra |
| :-- | :-- |
| ID de entidade/REDengine (64-bit) | **Opaco.** Nunca `tonumber()`. Comparar e transmitir intactos. |
| ID de jogador/sessão (evento/lifecycle) | `tonumber()` obrigatório; **não** usar como chave de persistência. |
| Chave de persistência | Identidade autenticada (`Open77.getIdentifier(src, 'license')`) → `character_id`. |

### Movimento e posição

- Mover jogador: **`Open77.players.teleport`** (com fade e espera de assentamento). Nunca escrever transform direto.
- `Open77.players.position` é **snapshot replicado**, não leitura ao vivo. Regras espaciais = "mantido por N segundos" num tick fixo com pequena folga; posição ilegível **congela** o acumulador, nunca o zera.
- Todo evento de cliente sobre zona/checkpoint/fila é **dica**: revalide no servidor.

---

## 5. Banco de dados (MariaDB)

```lua
MySQL.ready(function()
    local rows, err = MySQL.query.await(
        "SELECT nutrition, hydration FROM ls_vitals WHERE character_id = ?", { charId })
    if not rows then print("[ls_vitals] db_error: " .. tostring(err)) return end
end)
```

- Somente **server scripts**, com permissão `database.access`.
- **Sempre parametrizado** (`?` ou `@nome`). **Nunca** concatenar entrada de jogador.
- Prefixo `ls_` em todas as tabelas; chave por `character_id`/`license`.
- Migrations versionadas em `ls_data`; grants mínimos (`SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX`). Sem `DROP` sem revisão.
- `.await` só dentro de corrotina gerenciada (`CreateThread`, handler de evento, `MySQL.ready`).
- `MySQL.ready` é *gate de startup*, **não** health check: trate falha de cada query.
- `maxRows` padrão 10000: use paginação/ordenação explícita.
- **Todos os resources com `database.access` compartilham o mesmo banco/conta.**

### Dois trilhos de persistência

| Tipo de dado | Caminho | Exemplos |
| :-- | :-- | :-- |
| Alta frequência | `CacheService` → flush em lote a cada 5 min **+ disconnect + resource stop** | vitais, calor, stress, posição |
| Crítico | **Transação síncrona** com `SELECT ... FOR UPDATE` | saldo, itens, propriedade, aluguel |

Transferências: travar contas em **ordem determinística de ID**, gravar em `ls_ledger` (append-only) com `idempotency_key` único. Compra = pagamento + entrega de item **na mesma transação**.

---

## 6. Regras de design (invariantes de gameplay)

### 6.1 Vitais (taxas padrão, por minuto REAL, todas em tunables)
- Nutrição −1,0% · Hidratação −1,5% · Energia −0,8% · Higiene −0,7%.
- Cálculo por **delta de tempo** (robusto a lag), clamp 0–100.
- Definir/registrar a relação com o relógio do mundo (`/docs/world-time`) antes de balancear.

### 6.2 Estabilidade neural e ciberpsicose

```text
estabilidade = clamp( 100
                      - implantes * 9
                      - (1 - mult_neurobloqueador) * 30    # 1.0 em dia | 0.3 parcial | 0 esgotado
                      - (stress - 1) * 4                   # stress 1..5
                    , 5, 100 )
calor_ocular = 36.5 + implantes * 1.2 + stress * 1.5
```

- Limiar de ciberpsicose = **tunable único** `psychosis_threshold` (GDD/UI usa 25, regra de negócio usa 20 — padronizar antes de implementar).
- Ao cruzar o limiar: state bag `psychosis=true` → cliente aplica distorção de áudio e pós-processo vermelho.
- Disparo hostil em área urbana durante o episódio → **um** contrato MaxTac (idempotente) + alerta à facção NCPD.
- **Somente o servidor calcula.** O cliente exibe.

### 6.3 Habitação
- Interiores por **routing bucket** (pool reservado, ex.: 10000–19999): alocar ao entrar, **liberar ao esvaziar**, desabilitar população ambiente, isolar rede e voz.
- Mesmas coordenadas globais para todos os apartamentos iguais; isolamento é do bucket.
- Elevadores: `Open77.elevators.goTo`. Portas em rede: `/docs/doors`.
- Build Mode: câmera scriptada + gizmo; **servidor valida perímetro (PolyZone 3D), limite de objetos e saldo** antes de gravar em `ls_furniture` e criar o prop.
- Mobília funcional: cama (energia), fogão de síntese (comida), terminal de rede (banco), chuveiro (higiene), geladeira (inventário).

### 6.4 Economia circular
- **Toda fonte de Eurodólares deve ter dreno correspondente** e ser registrada.
- Drenos: aluguel diário (meia-noite do jogo), manutenção de cyberware/spray criogênico, seguro Trauma Team (Silver/Gold/Platinum), tarifas/licenças NCPD, alimentação.
- Referência de distribuição de drenos: aluguel 35 · cyberware 25 · seguro 15 · alimentação 15 · tarifas 10 (%).
- Nova emissão sem dreno = **não aprovar**.

### 6.5 Carreiras
Corporativo (traje formal, higiene > 80%) · Trauma Team (certificação) · NCPD (ficha limpa) · Ripperdoc clandestino · Edgerunner/Fixers (street cred) · Comércio/Entretenimento. Pagamento só com jogador **em serviço e presente na zona de trabalho** (validação servidor).

---

## 7. Front-end / NUI

- **Svelte 5** com Runes (`$state`, `$derived`, `$effect`) + Tailwind. **Proibido React/VDOM pesado.**
- TypeScript com **interfaces explícitas** para toda mensagem enviada/recebida (`UPDATE_VITALS`, etc.).
- Tema Kiroshi: fundo `#080E19` @ 80–90% + `backdrop-blur-md`; destaque `#22D8E2`; texto `#F2F6F8`; alerta/ciberpsicose `#FF5964`; fontes `JetBrains Mono` / `Chakra Petch` para números.
- Ponte:
  - Lua → UI: `SendNUIMessage({ action = "UPDATE_HUD", data = {...} })`
  - UI → Lua: `fetch("https://open77-webui/<endpoint>", { method: "POST", body: JSON.stringify(...) })` → `RegisterNUICallback("<endpoint>", function(data, cb) ... cb({ ok = true }) end)`
- Ao abrir UI complexa: bloquear input do jogo (`/docs/input-blocking`), foco de cursor; fechar em `ESC`.
- Alta frequência: só re-renderizar quando o valor muda; evitar alocações por frame.
- Consulte `/docs/ui-kit` antes de criar componentes próprios.

---

## 8. Performance

- Nada de `Wait(0)` ocioso. Polling adaptativo: **500 ms** ocioso; **0 ms** só em interação/gizmo ativo.
- Ticks de servidor em lote (ex.: vitais a cada ~10 s para todos os jogadores), nunca um timer por jogador.
- Payloads grandes: eventos latentes (`TriggerLatentClientEvent`), até 4 MiB em pacotes de 40 KiB.
- `SetTick` é cancelado após 5 falhas consecutivas — trate erros.
- 60 Hz é **meta a medir**, não premissa (Prometheus).

---

## 9. Compatibilidade FiveM (armadilhas)

| FiveM | OPEN//77 |
| :-- | :-- |
| `GetHashKey` / `joaat` | Retorna **TweakDBID** (CRC-32 + len), **não** o hash Jenkins. Usar strings TweakDB (`"Vehicle.v_sport2_quadra_turbo_r"`). |
| `RequestModel` / `HasModelLoaded` | **Não existem.** Remover. |
| `@outro_recurso/include.lua` | Rejeitado. Usar exports / `require('@recurso/modulo')`. |
| `SetPedToRagdoll` | `Open77.players.ragdoll(id, { durationMs = 3000 })` (servidor). |
| `FreezeEntityPosition` | `Open77.players.setFrozen` / `Open77.vehicles.setFrozen`. |
| `LoadResourceFile` | Restrito ao próprio resource (`cross_resource_read_denied`). |
| `SaveResourceFile` | Servidor, permissão `filesystem.write`, pasta `data/`. |
| `Citizen.CreateThread` / `Wait` | Idênticos a `CreateThread` / `Wait`. |

Use `open77_fivem_equivalent` para qualquer outra tradução.

---

## 10. Fluxo de trabalho obrigatório do agente

1. **Entender:** ler a fase atual no plano e esta seção de regras.
2. **Pesquisar nativas:** `open77_search` → `open77_api` (assinatura, permissões, razões de retorno, build mínimo).
3. **Dados de jogo:** `open77_data` para veículos, armas, roupas, NPCs, props, sons, animações.
4. **Scaffold:** `open77_new_resource` (correto por construção, incluindo guarda de ownership de exports).
5. **Escrever** respeitando as seções 4–8.
6. **Validar:** `open77_validate` (manifesto, runtime certo, permissões, natives desconhecidas/mais novas que o build).
7. **Tipos:** `npx -y @open2077.net/mcp types` → na verdade `npx -y @open2077/mcp types` (gera `open77-client.d.lua`, `open77-server.d.lua`, `.luarc.json`).
8. **Testar:** unitários (funções puras), integração, e — se tocar dinheiro/itens/buckets — teste de concorrência.
9. **Registrar:** README do resource + changelog.

Se o MCP disser que uma nativa **não está disponível**, aceite: não improvise.

---

## 11. Checklist antes de finalizar qualquer código

- [ ] Nenhuma decisão de dinheiro/item/vida/posse no cliente.
- [ ] Todo `RegisterNetEvent` valida tipo, tamanho, autoridade e taxa.
- [ ] Permissões declaradas = permissões necessárias (nem mais, nem menos).
- [ ] Retornos `nil, reason` tratados.
- [ ] SQL parametrizado; nenhuma concatenação.
- [ ] Dado crítico em transação; dado volátil no cache com flush garantido.
- [ ] Nenhum `Wait(0)` ocioso; nenhum timer por jogador.
- [ ] IDs: entidade opaca / sessão `tonumber` / persistência por `license`.
- [ ] Reload-safe (adota jogadores via `Open77.players.all()`).
- [ ] `open77_validate` limpo.
- [ ] Mensagens diegéticas (Eurodólares, Kiroshi, NCPD, Trauma Team, MaxTac…).
- [ ] Sem código hipotético não tipado na UI.

---

## 12. Fases (onde estamos)

| Fase | Tema | Resources principais |
| :-- | :-- | :-- |
| 0 | Fundação, ambiente e tooling | — |
| 1 | Núcleo: identidade, dados, cache, eventos | `ls_core`, `ls_data` |
| 2 | Vitais + HUD Kiroshi | `ls_vitals`, `ls_ui` |
| 3 | Cyberware, estabilidade neural, ciberpsicose | `ls_cyberware` |
| 4 | Economia, banco, inventário | `ls_economy`, `ls_inventory` |
| 5 | Habitação, buckets, Build Mode | `ls_housing` |
| 6 | Carreiras e facções | `ls_jobs`, `ls_factions` |
| 7 | Imersão social | `ls_social` |
| 8 | Hardening, carga, Alpha Fechado | todos |

> **Fase atual:** _(atualize aqui)_ — Fase ___, tarefa ___.

---

## 13. Referências

- Docs: https://open2077.net/docs · API Lua: https://open2077.net/docs/api · Devblog: https://open2077.net/devblog
- MCP: `@open2077/mcp` (`npx -y @open2077/mcp init`) · endpoint hospedado: `https://mcp.open2077.net/mcp`
- Comunidade/bugs: Discord do OPEN//77.
