# WORKFLOW SOP: MISTAKE-PROOF (POKA-YOKE PROTOCOL)

> **Regra Canônica:** Sempre que um problema (comum ou raro) for diagnosticado e resolvido no ecossistema OPEN//77, documente a solução definitiva neste workflow e em `.agents/skills/mistake-proof/SKILL.md` para impedir qualquer regressão futura.

---

## 1. Diretriz de Operação
1. **Consultar Sempre Antes de Escrever:**
   - Ao criar novos scripts ou refatorar recursos existentes, verifique este catálogo para não incorrer em erros conhecidos do REDengine/OPEN//77.
2. **Atualização Imediata (The "Missing Node" Rule):**
   - Ao resolver um incidente no servidor ou no cliente, documente a causa raiz e o padrão de correção antes de dar a tarefa por concluída.

---

## 2. Catálogo de Soluções Definitivas Ativas

| ID | Área | Sintoma | Causa Raiz | Solução Poka-Yoke |
|---|---|---|---|---|
| **MP-001** | Input & Teclado | Atalhos "I", "TAB" inoperantes | Falta de `"input.actions"` no manifesto e uso da sintaxe legado FiveM. | Declarar permissão `"input.actions"` e usar `Open77.input.registerKeyMapping` com spec table (`{ id, name, key, hold, onPressed, onReleased }`). |
| **MP-002** | Banco & Exports | Erro `export_yielded`, queries retornam `nil` | Chamadas de exports não podem yieldar/esperar com `.await` no OPEN//77. | Declarar `"database.access"` no manifesto e usar diretamente `MySQL.query.await` / `MySQL.update.await`. |
| **MP-003** | Economia & ACID | Rollback de saldo ao relogar | Tratar erro de banco (`nil`) como novo jogador e conceder `starter_grant` sobrescrevendo a conta. | Distinguir explicitamente `#rows == 0` de `rows == nil`. Em falhas técnicas, nunca conceder `starter_grant`. |
| **MP-004** | Render & Instâncias | Stuttering próximo a apartamentos | Marcador 3D duplicado: `Open77.markers.create` chamado em duplicidade com `open77_worldui:create`. | Deixar o `open77_worldui` gerenciar o anel holográfico e o card diegético de forma única. |
| **MP-005** | Performance & Loops | Queda de frames e gargalo de CPU | Threads em loops com `Wait(10)` e `Wait(15)` checando input continuamente. | Implementar polling adaptativo (dormir 500ms quando ocioso, 100ms quando próximo). |
| **MP-006** | WebUI & CEF | Consumo excessivo de GPU em repouso | `WebUI.create` com `visible = true` a 60 FPS em modais transparentes fechados. | Inicializar sempre com `visible = false`. Chamar `page:show()` somente ao abrir o modal. |
| **MP-007** | CEF & Foco de Mouse | Roda de seleção (Radial) sem cursor ou modal travado | Falta de `page:setFocus(false, true)` no cliente e ausência de listener para tecla Escape na UI. | Liberar mouse no CEF ao abrir o radial e incluir listener universal de teclado no `app.js`. |
| **MP-008** | WebUI & DOM | Inventário e Radial Menu invisíveis ao abrir | Modais inseridos por engano dentro de `#ripperdoc-modal` que possuía `display: none !important`. | Todo modal deve ser irmão direto (sibling) no DOM root, nunca aninhado dentro de containers fechados. |
| **MP-009** | LoadScreen & REDengine | Cutscenes 3D vanilla encobertas na tela de carregamento | CEF renderizado sobre o viewport 3D com background sólido `#040810` e gradientes 98% opacos. | `body` e camadas de viewport 100% transparentes, vinhetas suaves nos cantos e blend `screen`. |
| **MP-010** | Keybinds & Motor | Conflito da tecla TAB com Scanner de Hacking vanilla | Tecla TAB vinculada estaticamente; jogador impossibilitado de alterar atalhos in-game. | Migrar atalho padrão para `CAPSLOCK`, registrar via `Open77.input.registerKeyMapping` e expor na aba KEY BINDINGS do Pause Menu. |
| **MP-011** | Inventário & Lifecycle | Erro `export ls_core:GetPlayerCharacterId export_not_found`, inventário vazio | Tentativa de chamar export inexistente; não escutar `ls:core:playerLoaded(playerId, license)`; descarte de sync antes do CEF `ready`. | Obter licença oficial via `exports["ls_core"]:getSession(src).license`, escutar `ls:core:playerLoaded`, tratar hot-reload e cachear bag no cliente Lua (`cachedInventoryBag`). |
| **MP-012** | Radial & UI Responsiva | Impossível equipar itens no Radial; card do inventário estreito (box vermelha) | Ausência de slots de loadout mapeados e dimensões CSS travadas em pixels fixos (1150px x 740px). | Criar 8 slots direcionais (`[1] ↑` a `[8] ↖`) com drag & drop persistidos no `localStorage`; expandir escala CSS com `clamp(1050px, 92vw, 1720px)` (box verde). |
| **MP-013** | Catálogo & Assets Visuais | Itens com interrogação `?` ou imagem incorreta; divergência Lua/JS | Itens sem asset próprio na pasta `images/` e falta de sincronização entre `items_catalog.lua` e `catalog.js`. | Criar ícones dedicados em SVG vetorial Cyberpunk; manter espelhamento estrito 1:1 entre Lua e JS; rodar verificação automatizada com 0 links quebrados e 0 placeholders. |

---

## 3. Manutenção Perpétua da Memória
Toda nova adição deve ser sincronizada entre:
- `.agents/skills/mistake-proof/SKILL.md`
- `.agent/workflows/mistake_proof_skill.md`
- `.agent/memory/changelog.md`
