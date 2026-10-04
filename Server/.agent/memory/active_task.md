# Active Task

## Tarefa Atual
- **Nome:** Estabilização Forense de Housing & Coords (Logs 19, 20 e 21) & Preparação para Fase 6
- **Status:** Resolução forense de 100% dos incidentes de moeda, banco de dados, comando `/coords` e interações diegéticas de habitação; Fases 1 a 5 totalmente operacionais; Pronto para avanço para a Fase 6 (`ls_jobs` & `ls_factions`).
- **Responsável:** UEoE 1

## Entregas Desta Etapa (Estabilização & Incidentes Logs 19-21)
- [x] **Regra Primordial Global:** Fixação canônica da documentação oficial do OPEN//77 (`https://open2077.net/docs`) como fonte primária da verdade em `AGENTS.md`.
- [x] **Resolução do Log 20 (Moeda e Banco de Dados):**
  - Adicionadas exportações formais no `ls_data` (`query`, `update`, `execute`, `transaction`).
  - Adicionados exports autoritativos no `ls_economy` (`removeBank`, `addBank`, `removeCash`, `addCash`, `getBalance`).
  - Fallback automático para dinheiro vivo (`Cash`) no `ls_housing/server/apartments.lua` e `furniture.lua`.
- [x] **Criação do Recurso `open77_coords`:**
  - Scanner holográfico de coordenadas Kiroshi com comando autoritativo `/coords` para roles `admin`, `moderator`, `support`.
  - Exportação em 1-clique para Lua Config Table, Vector3/4, PolyZone 2D, Open77 Marker Spec e JSON.
- [x] **Resolução do Log 21 (Crash no `/coords` e Gatilho [E] no `ls_housing`):**
  - Corrigido desempacotamento de múltiplos retornos numéricos (`x, y, z`) de `Open77.character.position()` em C++, eliminando o erro `attempt to index a number value (local 'pos')`.
  - Resolução da perda de `aptId` no evento `ls:housing:openDoorTarget` emitido pelo `open77_interactions` via regex do `interactionId`.
  - Implementação de escuta da tecla física `[E]` nativa via `Open77.input.isDown("e")` com edge-triggering.
  - Sincronização de exibição de janela CEF com `page:show()` e `page:setFocus(true, true)`.

## Próximo Marco de Execução (Fase 6: `ls_jobs` & `ls_factions`)
- [ ] Planejamento e scaffolding do módulo de carreiras (`ls_jobs`).
- [ ] Sistema de ponto e serviço com turnos e pagamentos integrados ao `ls_economy`.
- [ ] Sistema de facções urbanas e contratos de Fixers (`ls_factions`).
