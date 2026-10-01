# Arquitetura Técnica do Servidor OPEN//77

> **Projeto:** OPEN//77 Life-Sim RP (Night City)  
> **Versão:** Cyberpunk 2077 v2.31 / Phantom Liberty  
> **Plataforma:** OPEN//77 Build 2.31.13+op77.78 (.NET 8 Runtime)  
> **Roadmap:** 9 Fases de Implementação (Fase 0 a Fase 8)

---

## 1. Princípios Invioláveis de Arquitetura

1. **Server-Authoritative Completo:**
   - O cliente é tratado como ponto não confiável. Não valida dinheiro, itens, geração de veículos, vida, munição ou propriedades imobiliárias.
   - O cliente submete apenas intenções via eventos seguros (`TriggerServerEvent`).
   - O servidor valida o estado através do banco relacional (MariaDB/MySQL) e do cache em memória (`CacheService`) antes de autorizar qualquer mutação.

2. **Padrão Write-Behind Caching:**
   - Mutações contínuas de alta frequência (fisiologia: fome, sede, exaustão, calor neural, telemetria) atualizam diretamente o `CacheService` na memória da VM Lua com latência zero.
   - Um worker assíncrono descarrega os estados em lotes (*batch flush*) a cada 5 minutos no banco relacional, bem como na desconexão (`playerDropped`) e no desligamento do recurso (`onResourceStop`).
   - Transações financeiras ou transferência de bens NUNCA passam pelo cache intermediário; executam locks transacionais imediatos no banco via `Open77.database` com `SELECT ... FOR UPDATE`.

3. **Sincronização por State Bags:**
   - Dados visíveis para múltiplos clientes (ex: trabalho atual, facção, status visíveis de saúde) são transmitidos via `Entity(ped).state:set(key, val, true)`, gerando apenas pacotes de deltas na rede.

4. **Habitação Vertical & Routing Buckets:**
   - Instanciamento de apartamentos em Megabuildings utiliza **Routing Buckets** (`bucketId` único por propriedade).
   - Múltiplos jogadores ocupam as mesmas coordenadas ($X, Y, Z$) no mapa global, mas isolados fisicamente e visualmente no pipeline de rede pelo servidor.
   - Objetos e decorações no Modo Construção (*Build Mode*) são validados no servidor via limites tridimensionais com `PolyZone` antes de persistir no banco.

5. **Interface Gráfica Sem Virtual DOM (Svelte 5):**
   - A NUI roda em Chromium Edge WebView2 out-of-process.
   - Proibido o uso de React ou bibliotecas com alto overhead de reconciliação de VDOM para evitar paradas de Garbage Collector (GC pauses).
   - Uso obrigatório de Svelte 5 com Runes (`$state`, `$derived`, `$effect`) e Tailwind CSS sob o design system diegético Kiroshi.

6. **Modularidade e Convenção de Resources:**
   - Recursos de gamemode agrupados em `Server/resources/gamemodes/lifesim/` com prefixo `ls_`:
     - `ls_core`: Configurações globais, tunables, autenticação de identificadores, bus de eventos, logging.
     - `ls_data`: Migrações SQL, repositórios, `CacheService`, gerenciador de flush.
     - `ls_vitals`: Motor de necessidades (fome, sede, sono, higiene, estresse), decaimento contínuo e consumo.
     - `ls_cyberware`: Ciberware, contagem de implantes, estabilidade neural, calor, ciberpsicose e intervenção MaxTac.
     - `ls_economy`: Contas correntes, salários, transações com lock, drenos econômicos (money sinks).
     - `ls_inventory`: Itens, inventários modais (bolsos, mochilas, porta-malas, baús), pesos e slots.
     - `ls_housing`: Megabuildings, routing buckets, portas e elevadores, build mode com gizmos.
     - `ls_jobs`: Carreiras corporativas e civis, turnos de trabalho, licenças.
     - `ls_factions`: NCPD, Trauma Team, gangues, reputação e contratos de Fixers.
     - `ls_social`: Bares, afinidade, animações e celular.
     - `ls_ui`: WebUI centralizada em Svelte 5 (HUD Kiroshi, telas modais, smartphone).
