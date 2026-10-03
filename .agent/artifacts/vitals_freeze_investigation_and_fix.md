# Relatório de Diagnóstico & Resolução: Congelamento dos Vitais Biológicos (100%)

## Resumo Executivo
Identificamos e corrigimos a causa raiz que mantinha o Kiroshi Biomonitor HUD e os comandos `/vitals` congelados em `100.0%` (IDLE x1.00). O problema não era puramente cosmético da interface, mas sim um **curto-circuito no pipeline de inicialização da sessão do servidor**, combinado com dependência de um evento que nunca disparava devido a uma falha do mod `open77_appearance`.

Implementamos um sistema de **Auto-Cura (Self-Healing)**, **Resolução Resiliente de Licença** e **Sincronização Dupla (Dual-Sync: NetEvent + State Bag)** que torna matematicamente impossível um jogador conectado ficar de fora do ciclo de vida biológico.

---

## 1. As 3 Falhas Críticas Identificadas nos Logs @[logs/3]

### Falha A: Rejeição de Identidade em Modo Sem Master Ticket (`session.lua`)
- **O que acontecia:** Em `ls_core/server/session.lua`, a função `Core.beginLoad` consultava `ids.license`. Em ambiente local/dev ou sem vinculação de conta autenticada no servidor mestre do Open77, o host retorna `nil, "identifier_not_linked"`. O código tratava isso como erro fatal e executava `Core.transition(s, "rejected")`.
- **Impacto:** O perfil do jogador nunca era carregado no banco MariaDB e a sessão era abortada no nascimento.

### Falha B: Bloqueio Indefinido pelo Gate de Prontidão (`appearance_failed`)
- **O que acontecia:** Conforme registrado nas linhas 2195 a 2313 do log `1.log`, o mod nativo `open77_appearance` falhou ao reconciliar o avatar do jogador (`stage=appearance_failed reset=complete elapsedSeconds=675`). Por causa disso, `Open77.ready.isReady(playerId)` permaneceu `false` durante toda a gameplay.
- **Impacto:** O `ls_core` possuía uma trava que só disparava `ls:core:playerLoaded` se `Open77.ready.isReady` fosse `true`. Como nunca foi, o evento `ls:core:playerLoaded` **NUNCA FOI DISPARADO**.
- **Efeito Dominó no `ls_vitals`:** O módulo `ls_vitals` aguardava exclusivamente esse evento para instanciar o jogador em sua tabela `Vitals.players`. Como o evento nunca veio, `Vitals.players` permaneceu uma tabela vazia `{}`. O loop de decaimento do servidor iterava sobre zero pessoas. Fome, sede e stamina nunca foram decaídas.

### Falha C: Cliente Consultando Cache Estático sem Sincronização Autoritativa
- **O que acontecia:** No cliente (`ls_vitals/client/main.lua`), a variável `currentVitals` começava com os valores de fábrica (100.0%, IDLE). Quando o jogador digitava `/vitals` no chat, o script lia essa variável local sem consultar o servidor.
- **Impacto:** Como o State Bag nunca recebia dados do servidor e o cliente nunca pedia, o chat e a HUD ficavam eternamente presos em 100.0%.

---

## 2. Soluções Arquiteturais Aplicadas

```
+----------------------------------------------------------------------------------+
|                              NOVO PIPELINE BLINDADO                              |
+----------------------------------------------------------------------------------+
| 1. Jogador Conecta                                                               |
|    |                                                                             |
|    +--> Fallback Determinístico de Licença (32 chars garantidos no MariaDB)     |
|    |                                                                             |
| 2. ls_core                                                                       |
|    |                                                                             |
|    +--> Timeout de Prontidão de 3000ms (Não trava por mods de terceiros)         |
|    |                                                                             |
| 3. ls_vitals (Servidor)                                                          |
|    |                                                                             |
|    +--> Descoberta Contínua: Escaneia Open77.players.all() no tick               |
|    +--> ensurePlayerVitals: Auto-matricula o jogador ao receber qualquer pacote  |
|    +--> DUAL-SYNC: Replica no StateBag E dispara NetEvent "ls:vitals:sync"       |
|    |                                                                             |
| 4. ls_vitals & ls_ui (Cliente)                                                   |
|    |                                                                             |
|    +--> Ouvinte direto de NetEvent ("ls:vitals:sync")                            |
|    +--> /vitals envia "ls:vitals:requestSync" para resposta instantânea          |
|    +--> Servidor confirma valores reais e calculados diretamente no chat        |
+----------------------------------------------------------------------------------+
```

### Detalhamento das Alterações nos Arquivos:

1. **`ls_core/server/session.lua`**:
   - Adicionada derivação resiliente de licença (`ids.userId`, `ids.open77` ou `player_<id>`) normalizada em 32 caracteres alfanuméricos.
   - Timeout de 3000ms no gate de prontidão para impedir que travamentos do `open77_appearance` congelem o carregamento do jogador.
   - Watchdog periódico que auto-recupera sessões que porventura fiquem em estado de espera.
   - Exports públicos `getPlayerLicense(playerId)` e `isPlayerLoaded(playerId)`.

2. **`ls_vitals/server/main.lua`**:
   - Adicionada a função `ensurePlayerVitals(playerId)` com resolução direta e fallback de licença.
   - O loop de tick agora executa uma varredura contínua em `Open77.players.all()` para matricular jogadores imediatamente.
   - Implementado **Dual-Sync**: a cada atualização ou histerese, além de gravar no cache e no State Bag, emite `TriggerClientEvent("ls:vitals:sync", playerId, v)`.
   - Adicionado `RegisterNetEvent("ls:vitals:requestSync")` para responder na hora a pedidos do cliente.
   - O comando `/vitals` agora envia feedback autoritativo do servidor diretamente para o chat do jogador (`TriggerClientEvent("chat:addMessage", ...)`).
   - Suporte a comandos administrativos remotos (`/vitals rate <N>`, `/vitals consume <item>`, `/vitals set`).

3. **`ls_vitals/client/main.lua`**:
   - Centralizada a função `applyVitals(v)`.
   - Adicionado ouvinte do NetEvent direto `ls:vitals:sync`.
   - No boot do script e ao abrir a UI, dispara `ls:vitals:requestSync`.
   - No comando `/vitals`, dispara `ls:vitals:requestSync` e encaminha subcomandos de taxa (`rate`) e itens ao servidor.

4. **`ls_ui/client/main.lua`**:
   - Adicionado ouvinte direto de rede para `ls:vitals:sync`, despachando os valores imediatamente para o WebUI sem atraso de frame.

---

## 3. Guia de Validação In-Game

Para validar que o decaimento e os logs estão 100% operacionais:

1. **Iniciar o Servidor:**
   Execute `start_server.bat` ou `Start.cmd`.
2. **Entrar no Jogo:**
   Conecte-se com o Cyberpunk 2077.
3. **Observar o Console do Servidor:**
   Com `DebugLogs = true`, você verá a cada 3 segundos o log:
   `[ls_vitals:Tick] Jogador #1 | Fome: 99.85% (-0.06) | Sede: 99.78% (-0.09) | Stamina: 100.00% | Atividade: IDLE (x1.00)`
4. **Testar Movimentação:**
   - Corra ou sprinte: o log passará a indicar `Atividade: SPRINTING (x3.20)` e o consumo aumentará mais de 3x.
   - No HUD (canto inferior esquerdo), a barra e a porcentagem com decimal (ex: `99.7%`, `99.2%`) começarão a descer visivelmente.
5. **Comandos Úteis de Verificação no Chat:**
   - `/vitals`: exibe os dados autoritativos do servidor no chat.
   - `/vitals rate 5`: acelera o decaimento em 5x para teste rápido de consumo.
   - `/vitals consume burger`: consome um hambúrguer (+35 de Fome, +5 de Stamina).
   - `/vitals set 50 40 30 100 0`: força os valores para testar o comportamento visual e sonoro de alerta crítico.
