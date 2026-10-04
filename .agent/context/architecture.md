# Arquitetura Técnica do Servidor OPEN//77

> **Projeto:** OPEN//77 Life-Sim RP (Night City)  
> **Versão do Jogo:** Cyberpunk 2077 v2.31 / Phantom Liberty  
> **Plataforma:** OPEN//77 Build 2.31.21+op77.124 (Protocolo 1.44) (.NET 8 Runtime)  
> **Roadmap:** 9 Fases de Implementação (Fases 1 a 5 Concluídas & Operacionais; Fase 6 em Planejamento)

---

## 1. Princípios Invioláveis de Arquitetura

1. **Server-Authoritative Completo:**
   - O cliente é tratado como ponto não confiável. Não valida dinheiro, itens, geração de veículos, vida, munição ou propriedades imobiliárias.
   - O cliente submete apenas intenções via eventos seguros (`TriggerServerEvent`).
   - O servidor valida o estado através do banco relacional (MariaDB/MySQL) e do cache em memória (`CacheService`) antes de autorizar qualquer mutação.

2. **Padrão Write-Behind Caching:**
   - Mutações contínuas de alta frequência (fisiologia: fome, sede, exaustão, calor neural, telemetria) atualizam diretamente o `CacheService` na memória da VM Lua com latência zero.
   - Um worker assíncrono descarrega os estados em lotes (*batch flush*) a cada 5 minutos no banco relacional, bem como na desconexão (`playerDropped`) e no desligamento do recurso (`onResourceStop`).
   - Transações financeiras ou transferência de bens NUNCA passam pelo cache intermediário; executam locks transacionais imediatos no banco via `MySQL.transaction.await` / `Open77.database` com `SELECT ... FOR UPDATE`.

3. **Sincronização por State Bags (`Open77.state`):**
   - Dados de estado compartilhado (ex: vitais, trabalho atual, facção, status visíveis) são gravados pelo servidor via `Open77.state.player(playerId):set(key, val)` (requer permissão `state.write` no manifesto).
   - O cliente consome o estado de forma reativa através de `Open77.state.player(playerId):get(key)` e manipuladores de evento `Open77.state.onChange`.

4. **Habitação Vertical & Routing Buckets:**
   - Instanciamento de apartamentos em Megabuildings utiliza **Routing Buckets** (`bucketId` único por propriedade via `Open77.routingBuckets.setPlayer`).
   - Múltiplos jogadores ocupam as mesmas coordenadas ($X, Y, Z$) no mapa global, mas isolados fisicamente e visualmente no pipeline de rede pelo servidor.
   - Objetos e decorações no Modo Construção (*Build Mode*) operam com movimentação livre 3D contínua e validação de 4 vértices do Oriented Bounding Box (OBB) contra o polígono `PolyZone` do imóvel.

5. **Interface Gráfica Diegética CEF (Chromium Embedded Framework):**
   - A NUI roda em Chromium CEF out-of-process.
   - Proibido o uso de React ou frameworks pesados com VDOM para evitar coletas de lixo e micro-stutters.
   - Uso obrigatório de Vanilla HTML5, Vanilla CSS3 (tokens Kiroshi, recortes angulares `clip-path: polygon()`, cantoneiras L-brackets, glassmorphism `blur(16px)` e fórmulas `clamp()` multi-resolução para 1080p, 1440p, 4K e Ultrawide 21:9/32:9) e JavaScript ES6+ modular com Web Audio API para síntese sonora diegética em tempo real.
   - Comunicação estrita via bridge nativa `Open77.webui` (`page:send` / `page:on` no Lua, `Open77.on` / `Open77.emit` no JavaScript). Zero FiveM NUI alucinado (`SendNUIMessage`, `RegisterNUICallback` são terminantemente proibidos).

6. **Modularidade e Convenção de Resources:**
   - Recursos de gamemode agrupados em `Server/resources/gamemodes/lifesim/` com prefixo `ls_`:
     - `ls_core`: [FASE 1 - 100%] Máquina de estados de sessão, tunables globais, gate de prontidão `open77:session:gameplayReady`, placement síncrono e event bus.
     - `ls_data`: [FASE 1 - 100%] Migrações SQL automáticas, repositórios MariaDB InnoDB, exports de banco e `CacheService` com Write-Behind.
     - `ls_vitals`: [FASE 2 - 100%] Fisiologia (fome, sede, energia, higiene, estresse), decaimento monotônico com histerese, penalidades orgânicas e suite `/vitals`.
     - `ls_cyberware`: [FASE 3 - 100%] 20+ implantes anatômicos, cálculo de Estabilidade Neural, calor ocular, limiar de ciberpsicose e farmacêuticos funcionais.
     - `ls_economy`: [FASE 4 - 100%] Carteira Cash, conta bancária Bank com transações ACID, ATMs de autoatendimento, Vending 24/7 e clínica Ripperdoc Viktor Vector.
     - `ls_spawn`: [GATEWAY PRÉ-FASE 5 - 100%] Primeiro spawn obrigatório no Megabuilding H10, seletor holográfico diegético de despertar e radar geodésico Canvas.
     - `ls_housing`: [FASE 5 - 100%] Habitação vertical por Routing Buckets, calibração canônica do AP de V, suporte a múltiplas portas, blips dinâmicos e Build Mode livre OBB.
     - `ls_loadscreen`: [100%] Loading screen nativa diegética modular 1:1 com wireframe oficial, Media Engine multi-modo e sintetizador Web Audio API.
     - `ls_ui`: [100%] HUD Kiroshi Biomonitor em NUI diegética multi-resolução com persistência espacial de coordenadas no banco de dados.
     - `ls_jobs`: [FASE 6 - Planejamento] Carreiras corporativas e serviços urbanos, turnos de trabalho, ponto e pagamentos integrados ao `ls_economy`.
     - `ls_factions`: [FASE 6 - Planejamento] Reputação de gangues (Moxes, Maelstrom, Tyger Claws, Valentinos), contratos de Fixers e canais policiais NCPD.
