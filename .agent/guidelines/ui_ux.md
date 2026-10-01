# Diretrizes de UI/UX — OPEN//77 Kiroshi Design System

> **Escopo:** Identidade visual, tipografia, paleta de cores e princípios de experiência do usuário para todas as interfaces NUI (HUD, Biomonitor Kiroshi, Smartphone, Terminais de Banco, Modo Construção) do servidor OPEN//77 Life-Sim RP.

---

## 1. Filosofia Visual: *Diegetic Kiroshi Interface*

As interfaces do servidor não são simples menus de jogo; elas representam a sobreposição óptica do implante ocular Kiroshi do personagem ou terminais físicos de Night City.
- **Diegese:** Menus devem parecer dados projetados na retina cibernética ou transmitidos por um personal link.
- **Glassmorphism Sutil:** Fundos translúcidos com desfoque de fundo (`backdrop-blur-md`), mantendo Night City visível atrás da interface.
- **Geometria Angular & Chanfros:** Linhas diagonais, cantos chanfrados (`clip-path: polygon(...)`), detalhes em wireframe e linhas guias de HUD militar/médico.

---

## 2. Paleta de Cores & Tokens

| Token | Hex | Opacidade / Efeito | Uso no Sistema |
| :--- | :--- | :--- | :--- |
| **Surface Dark** | `#080E19` | 85% a 95% (`backdrop-blur-md`) | Fundo de painéis, HUD cards e janelas modais |
| **Primary Cyan** | `#22D8E2` | 100% (Glow `0 0 10px rgba(34,216,226,0.3)`) | Ações primárias, bordas ativas, barras cheias de vitais |
| **Secondary Accent** | `#06B6D4` | 100% | Gradientes complementares e destaques de cabeçalho |
| **Text Main** | `#F2F6F8` | 100% | Textos principais, rótulos e valores em destaque |
| **Text Muted** | `#64748B` | 100% | Descrições secundárias, timestamps e unidades |
| **Warning Amber** | `#F59E0B` | 100% | Necessidades em nível de alerta (< 30%), calor de cyberware |
| **Danger / MaxTac Red**| `#FF5964` | 100% (Glow pulsante vermelho) | Crítico (< 10%), ciberpsicose iminente, intervenção armada |
| **Success Emerald** | `#10B981` | 100% | Transações aprovadas, estabilidade neural > 80% |

---

## 3. Tipografia

- **Fontes Principais:**
  - `JetBrains Mono` / `Share Tech Mono`: Valores numéricos, taxas de decaimento, telemetria, logs de sistema, saldos bancários e relógio in-game.
  - `Chakra Petch` / `Inter`: Rótulos, títulos de módulos, nomes de itens e navegação.
- **Regras:**
  - Letras maiúsculas (`uppercase`) com espaçamento estendido (`tracking-widest`) em títulos de seções e status de implantes.
  - Alinhamento tabular numérico (`tabular-nums font-mono`) para evitar saltos visuais durante atualizações contínuas de biometria.

---

## 4. Componentes e Micro-interações

1. **Barras de Vitais (Biomonitor):**
   - Espessura compacta (4px a 8px) com cantos retos ou ligeiramente chanfrados.
   - Indicador de decaimento sutil (transição de opacidade quando há perda rápida).
   - Efeito de pulso de alerta suave quando o valor atinge limiares críticos.

2. **Janelas e Modais:**
   - Borda externa de 1px com cor translúcida (`border-cyan-500/20`).
   - Linha de cabeçalho com identificador de módulo (`MODULE://OPEN77_VITALS_V2`).
   - Botões de fechar com feedback sonoro diegético (som de clique óptico).

3. **Modo Construção (Build Mode HUD):**
   - Informações de alinhamento e coordenadas fixadas no canto superior direito.
   - Grade de seleção de mobílias com miniaturas limpas e preço em Eurodollars claramente visível.

---

## 5. Performance e Regras de Ouro da NUI

- **Zero React / Virtual DOM:** Apenas **Svelte 5** com Runes para atualizações cirúrgicas de DOM sem reconciliação.
- **Evitar Repaints Excessivos:** Utilize `transform: translate3d(...)` e `opacity` para animações em vez de alterar `top`, `left`, `width` ou `height`.
- **Foco e Interatividade:** Ocultar completamente (`display: none` ou remoção do DOM) telas inativas para garantir que a WebView2 não consuma ciclos de CPU durante o gameplay intenso.
