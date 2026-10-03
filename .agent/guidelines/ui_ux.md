# Diretrizes de UI/UX — OPEN//77 Kiroshi & REDengine Native Design System

> **Escopo:** Identidade visual, tipografia, paleta de cores, componentes e princípios de experiência do usuário para todas as interfaces WebUI/NUI (HUD de Vitais, Biomonitor Kiroshi, Smartphone diegético, Terminais bancários, Modo Construção e Diálogos) do servidor OPEN//77 Life-Sim RP.
> **Princípio Supremo (O "Mod Invisível"):** Toda e qualquer interface desenvolvida deve ter paridade estética e comportamental 1:1 com a interface nativa do próprio jogo *Cyberpunk 2077* (REDengine 4). O jogador **nunca deve perceber a diferença** entre um menu vanilla do jogo e um recurso criado pelo servidor.

---

## 1. Filosofia Visual: *100% Native Cyberpunk 2077 Parity*

As interfaces do servidor não são simples janelas da Web convencional ou temas comuns de servidores FiveM; elas são extensões diretas do HUD Kiroshi Optics e dos sistemas corporativos de Night City (Arasaka, Militech, Zetatech, Kang Tao).

1. **Diegese e Imersão Óptica:**
   - Menus em primeira pessoa representam dados projetados diretamente na retina cibernética pelo implante Kiroshi Optics ou transmitidos por um *Personal Link*.
   - Telas físicas no mundo (terminais de banco, caixas eletrônicos) emulam o visual de monitores CRT/LCD com fósforo verde, âmbar ou azul corporativo.
2. **Glassmorphism Tático:**
   - Fundos holográficos escuros translúcidos (`#080E19` a 85-92% de opacidade com `backdrop-blur-md`), mantendo o mundo vivo de Night City visível atrás do painel.
3. **Geometria Angular & Chanfros Kiroshi:**
   - **Zero cantos arredondados convencionais de SaaS (sem `rounded-xl` ou `rounded-2xl` estilo iOS/macOS).**
   - Utilização estrita de cantos chanfrados em 45 graus (`clip-path: polygon(...)`), chanfros diagonais, linhas guias de HUD militar, marcadores de calibração holográfica e bordas técnicas finas (1px).
4. **Áudio Diegético Kiroshi:**
   - Todo clique de botão, navegação de abas, abertura e fechamento de modal deve acionar feedback sonoro diegético idêntico aos bips táteis do implante Kiroshi do Cyberpunk 2077.

---

## 2. Paleta de Cores Oficial & Tokens de Design

| Token | Hex | Opacidade / Efeito | Uso no Sistema (Paridade CP2077) |
| :--- | :--- | :--- | :--- |
| **Cyberpunk Yellow** | `#FCEE0A` | 100% (Glow `0 0 10px rgba(252,238,10,0.3)`) | Destaques da marca Night City, botões primários de ação, badges corporativos |
| **Kiroshi Cyan** | `#22D8E2` | 100% (Glow `0 0 10px rgba(34,216,226,0.3)`) | HUD de biometria, links de rede, dados de telemetria, escaneamento óptico |
| **Surface Dark** | `#080E19` | 85% a 92% (`backdrop-blur-md`) | Fundo de painéis, HUD cards, janelas modais e menus |
| **Surface Accent** | `#0D1624` | 95% | Cartões internos, itens de lista selecionáveis e inputs |
| **Text Main** | `#F2F6F8` | 100% | Textos principais, títulos, rótulos e valores em foco |
| **Text Muted** | `#64748B` | 100% | Legendas técnicas, timestamps, unidades de medida e dados secundários |
| **Warning Amber** | `#F59E0B` | 100% | Necessidades baixas (< 30%), aquecimento de cyberware, notificações de aviso |
| **Danger / MaxTac Red**| `#FF003C` / `#FF5964` | 100% (Glow pulsante vermelho) | Crítico (< 10%), ciberpsicose iminente, falha de transação, intervenção armada |
| **Success Emerald** | `#10B981` | 100% | Transações aprovadas, estabilidade neural > 80%, conexões seguras |
| **Border Technical** | `rgba(34,216,226,0.25)` | Linha de 1px | Divisores e contornos de cards holográficos |

---

## 3. Tipografia Oficial (100% Bundled & Local)

> **Inviolável:** Nunca utilize links de CDN externo (Google Fonts) em produção. As fontes devem ser embarcadas diretamente nos `web_files` do resource `ls_ui` para evitar latência ou dependência de internet durante o jogo.

- **Famílias Tipográficas:**
  - `Rajdhani` / `Chakra Petch`: Cabeçalhos, títulos de módulos, nomes de itens, abas e navegação.
  - `Saira`: Textos corridos, diálogos, descrições de contratos e termos de serviço.
  - `IBM Plex Mono` / `JetBrains Mono`: Métricas numéricas, coordenadas de GPS, telemetria, logs de sistema, relógio in-game e saldos em Eurodollars (€$).
- **Regras Tipográficas:**
  - Títulos de seções sempre em caixa alta (`uppercase`) com espaçamento estendido (`tracking-widest` ou `letter-spacing: 0.15em`).
  - Alinhamento numérico tabular obrigatório (`tabular-nums font-mono`) para que valores atualizados em tempo real não causem saltos indesejados no layout.

---

## 4. Utilitários CSS & Classes de Chanfro (Tailwind)

Para manter a consistência visual em todos os componentes Svelte, utilize as classes utilitárias de chanfro Kiroshi:

```css
/* Chanfro nos cantos superior-direito e inferior-esquerdo */
.kiroshi-chamfer {
  clip-path: polygon(
    0 0,
    calc(100% - 12px) 0,
    100% 12px,
    100% 100%,
    12px 100%,
    0 calc(100% - 12px)
  );
}

/* Chanfro apenas no canto superior-direito (botões e abas) */
.kiroshi-tab {
  clip-path: polygon(
    0 0,
    calc(100% - 10px) 0,
    100% 10px,
    100% 100%,
    0 100%
  );
}

/* Efeito de scanline sutil (linhas CRT Kiroshi) */
.kiroshi-scanlines {
  background: linear-gradient(
    rgba(18, 16, 16, 0) 50%, 
    rgba(0, 0, 0, 0.25) 50%
  ), linear-gradient(
    90deg,
    rgba(255, 0, 0, 0.03),
    rgba(0, 255, 0, 0.01),
    rgba(0, 0, 255, 0.03)
  );
  background-size: 100% 3px, 6px 100%;
}
```

---

## 5. Integração com `open77_uikit` e Ledger de Foco

O servidor OPEN//77 fornece a biblioteca oficial `open77_uikit`. Siga rigorosamente estas regras:

1. **Uso Prioritário do UIKit para Diálogos e Prompts:**
   - Alertas e confirmações (`alert`), caixas de texto (`input`), seletores radiais (`radial`), menus de contexto (`context`), barras de progresso (`progress`) e avisos na tela (`textUI`) devem usar o `open77_uikit`.
   - Chame sempre de forma **assíncrona** (`Open77.exports.call('open77_uikit', 'alert', ...):await()`) dentro de coroutines.
2. **Respeito ao Ledger de Foco:**
   - Tomar o foco do teclado/cursor suspende os controles de gameplay do jogador.
   - O `open77_uikit` já possui um sistema à prova de falhas com liberação automática de foco em caso de fechamento, cancelamento, morte do personagem ou pressão da tecla `Escape` (capturada nativamente via `open77:pauseKey`).
3. **Páginas Customizadas (`ls_ui`):**
   - Reservadas apenas para HUD persistente de vitais, smartphone diegético do lifesim, inventário visual em grade e terminais do `ls_economy`.
   - Toda página customizada do `ls_ui` deve implementar o mesmo watchdog de liberação de foco para que o jogador jamais fique preso.

---

## 6. Performance e Regras de Ouro da NUI

- **Zero Virtual DOM:** Usar exclusivamente **Svelte 5** com Runes (`$state`, `$derived`, `$effect`) para reatividade granular no DOM sem o overhead de reconciliação de frameworks pesados (React/Vue).
- **Sem Repaints por Propriedades de Geometria:** Proibido animar `width`, `height`, `top` ou `left`. Animações devem usar estritamente `transform: translate3d(...)`, `scale(...)` e `opacity` com aceleração por hardware da GPU.
- **Ciclo de Vida Limpo na WebView2:** Ocultar completamente (`display: none` ou destruição do componente) telas inativas para garantir consumo residual zero de CPU/GPU durante o combate ou direção em alta velocidade por Night City.
