# Benchmark de Engenharia: Framework OPX//77 (`opx_infinity` & `opx_lib`)

**Documentação Analisada:** [https://opx77-framework.github.io/opx77_doc/docs/](https://opx77-framework.github.io/opx77_doc/docs/)  
**Autor:** Luís MOUTA  
**Data da Análise:** Outubro de 2026  
**Engenheiro Responsável:** The Universal Engineer (UEoE 1)

---

## 1. Resumo Executivo

O **OPX//77** é um framework open-source maduro construído especificamente para o ecossistema **OPEN//77 (Cyberpunk 2077 / REDengine 4)**. Em setembro de 2026, ele passou por uma das transições arquiteturais mais interessantes do modding moderno: migrou de **21 recursos individuais** para um **único recurso monolítico (`opx_infinity`)** mais uma biblioteca utilitária de cliente (`opx_lib`).

A análise aprofundada de sua documentação e código revela segredos operacionais da REDengine que economizam meses de dor de cabeça e testes às cegas.

---

## 2. As Grandes Descobertas Técnicas

### A. O Fantasma Silencioso do "Instruction Budget" no Cliente
- **O Problema:** No cliente REDengine, corrotinas Lua possuem um limite estrito de instruções por ciclo/frame. Se um script iterar sobre muitos itens ou executar lógica complexa sem ceder (`Wait(0)`), a engine emite `Open77 script execution budget exceeded` e **mata a corrotina silenciosamente** sem gerar crash nem log visível no console.
- **A Solução do OPX:**
  1. No boot, cede 1 frame (`Wait(0)`) após inicializar cada módulo.
  2. Implementou um **Scheduler central** no cliente que processa no máximo **4 tarefas por tick**.
  3. Raycasts e detecção de proximidade (módulo `target`) são fatiados em múltiplos frames.

### B. Diferenças Críticas de Sandbox (Servidor vs Cliente)
| Recurso | Servidor | Cliente |
| :--- | :--- | :--- |
| `require` | ❌ Bloqueado | ✔️ Disponível (usado pelo `opx_lib`) |
| `setmetatable` / `getmetatable` | ✔️ Permitido | ❌ **Bloqueado no cliente** |
| `GetGameTimer()` | ✔️ Permitido | ❌ **Não existe no cliente** (usar `Open77.time.monotonic()`) |
| `TriggerEvent` | ✔️ Broadcast entre todos os recursos | ❌ **Isolado apenas no próprio recurso** |

### C. A Batalha: Monólito vs Multi-Recurso
- **Por que o OPX unificou 21 recursos em 1:** No servidor OPEN//77 não existe `require` entre recursos nem compartilhamento de tabelas em memória. Fazer 21 recursos conversarem exigia disparar dezenas de `TriggerEvent` por segundo, gerando latência de serialização. No monólito `opx_infinity`, eles usam contratos em memória pura (`OPX.Api.Provide` e `OPX.Api.Get`).
- **Nossa Abordagem no VICCS Life-Sim:** Nós mantemos 9 módulos Life-Sim dedicados (`ls_core`, `ls_data`, `ls_vitals`, etc.), o que nos dá isolamento limpo e independência de deploy. A lição que levamos é: **manter o payload dos nossos eventos leve** e cachear no cliente quando possível.

### D. Interface CEF WebUI com Pilha de Foco (`Focus Stack`)
- **Duas Camadas em Uma Página:** 
  - `overlay`: HUD e avisos Kiroshi (nunca rouba mouse ou teclado).
  - `modal`: Inventário e menus (captura foco).
- **Focus Stack:** Garante que ao fechar um submenu, o foco retorne à tela anterior em vez de travar o controle do jogador.
- **Tecla ESC:** Pertence exclusivamente ao `open77_pause` nativo; frameworks nunca devem vincular ESC diretamente em Lua.

### E. Banco de Dados com `EnsureIndex`
- Tabelas novas são criadas com `CREATE TABLE IF NOT EXISTS`, mas índices novos em tabelas antigas falham em servidores já rodando.
- O OPX consulta `information_schema.STATISTICS` antes de rodar `ALTER TABLE ... ADD KEY`, garantindo boots seguros e idênticos em produção.

---

## 3. Próximas Ações no VICCS Cyberpunk Server

1. **Documentação Interna:** Registrado o documento de referência canônica em [`.agent/context/OPX77_FRAMEWORK_ANALYSIS_AND_LESSONS.md`](file:///c:/Games/VICCS_CyberpunkServer/.agent/context/OPX77_FRAMEWORK_ANALYSIS_AND_LESSONS.md).
2. **Blindagem do Client:** Auditar os scripts de cliente de `ls_vitals`, `ls_housing` e `ls_vehicles` para garantir que nenhuma corrotina estoure o Instruction Budget da REDengine.
3. **Padrão de Foco Kiroshi:** Adotar a divisão estrita de `overlay` vs `modal` em nossas interfaces CEF.
