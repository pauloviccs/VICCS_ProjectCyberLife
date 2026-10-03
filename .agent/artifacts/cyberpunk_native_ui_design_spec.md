# WORK ORDER & DESIGN SPEC: 1:1 NATIVE CYBERPUNK 2077 UI/UX PARITY

> **Status:** APPROVED / IN-FORCE  
> **Target Platform:** OPEN//77 (Build 2.31.21+op77.121) · Chromium WebView2 · Lua 5.4.8  
> **Gamemode:** `lifesim` · Primary UI Resource: `ls_ui` · Shared Dialogs: `open77_uikit`  
> **Frontend Stack:** Svelte 5 (Runes) · Tailwind CSS · TypeScript · Vite  
> **Core Directive:** *O Princípio do Mod Invisível* — Toda interface deve ser rigorosamente indistinguível das interfaces nativas do jogo *Cyberpunk 2077* (REDengine 4).

---

## 1. Arquitetura de Diretórios (`ls_ui`)

```text
Server/resources/gamemodes/lifesim/ls_ui/
├── open77.lua                      # Manifesto do resource com ui_page e web_files
├── client/
│   └── main.lua                    # Instanciação da WebUI, escutas de State Bags e RPC
└── web/
    ├── index.html                  # Container base com fontes nativas bundled
    ├── package.json                # Dependências: Svelte 5, Tailwind CSS, Lucide (ou ícones SVG custom)
    ├── vite.config.ts              # Configuração Vite com base relativa ("./")
    ├── tailwind.config.ts          # Extensão do tema com a paleta oficial da REDengine
    └── src/
        ├── app.css                 # Importação de fontes locais, chanfros e scanlines
        ├── main.ts                 # Ponto de entrada Svelte 5
        ├── App.svelte              # Roteador mestre de camadas (HUD, Modais, Apps)
        ├── lib/
        │   ├── bridge.ts           # Wrapper tipado para window.Open77
        │   ├── sound.ts            # Gatilhos de áudio diegético Kiroshi
        │   └── stores/
        │       ├── vitals.svelte.ts# Estado reativo dos vitais ($state)
        │       └── ui.svelte.ts    # Estado de foco, visibilidade e camadas
        ├── components/
        │   ├── hud/
        │   │   ├── Biomonitor.svelte   # Barras de vitais (fome, sede, sono, etc.)
        │   │   ├── StatusIcon.svelte   # Ícones de status com chanfros
        │   │   └── ClockWidget.svelte  # Relógio in-game em fonte tabular
        │   ├── common/
        │   │   ├── KiroshiCard.svelte  # Card com cantos chanfrados e borda técnica
        │   │   ├── KiroshiButton.svelte# Botão com corte a 45° e som de clique
        │   │   └── ScanlineOverlay.svelte # Efeito sutil de tubo CRT/holograma
        │   └── apps/
        │       ├── PhoneApp.svelte     # Smartphone diegético de Night City
        │       └── BankTerminal.svelte # Interface de caixas eletrônicos e extrato
        └── assets/
            ├── fonts/              # Rajdhani, Chakra Petch, Saira, IBM Plex Mono (.woff2)
            └── audio/              # Efeitos Kiroshi (click.ogg, error.ogg, tab.ogg)
```

---

## 2. Design Tokens & Paleta Oficial (Cyberpunk 2077 / REDengine)

### 2.1 Tabela de Tokens de Cores

| Token | Código HEX / RGBA | Finalidade no Jogo |
|---|---|---|
| `--cp-yellow` | `#FCEE0A` | Ação primária, botões de confirmação, logo NC, alertas de tráfego |
| `--cp-cyan` | `#22D8E2` | Biomonitor nominal, dados Kiroshi Optics, links de rede, GPS |
| `--cp-red` | `#FF003C` / `#FF5964` | Níveis críticos de saúde (<10%), ciberpsicose iminente, MaxTac |
| `--cp-amber` | `#F59E0B` | Níveis baixos (<30%), aquecimento de cyberware, advertências |
| `--cp-emerald` | `#10B981` | Transações bancárias concluídas, estabilidade neural >80% |
| `--cp-bg-surface` | `rgba(8, 14, 25, 0.88)` | Fundo holográfico translúcido com `backdrop-blur-md` |
| `--cp-bg-card` | `rgba(13, 22, 36, 0.95)` | Cartões internos, inputs, itens de lista |
| `--cp-text-main` | `#F2F6F8` | Títulos, rótulos destacados e números principais |
| `--cp-text-muted` | `#64748B` | Legendas técnicas, timestamps, unidades (ex: `€$`, `kg`, `bpm`) |
| `--cp-border-tech`| `rgba(34, 216, 226, 0.25)` | Contornos de 1px e divisores técnicos |

---

## 3. Tipografia Oficial (100% Bundled & Local)

> **Invariante:** Nenhuma fonte pode depender de CDN externo (Google Fonts). O build deve empacotar os arquivos `.woff2` diretamente nos assets locais.

```css
/* web/src/app.css */
@font-face {
  font-family: 'Rajdhani';
  src: url('/assets/fonts/Rajdhani-Bold.woff2') format('woff2');
  font-weight: 700;
  font-display: swap;
}

@font-face {
  font-family: 'Chakra Petch';
  src: url('/assets/fonts/ChakraPetch-Medium.woff2') format('woff2');
  font-weight: 500;
  font-display: swap;
}

@font-face {
  font-family: 'Saira';
  src: url('/assets/fonts/Saira-Regular.woff2') format('woff2');
  font-weight: 400;
  font-display: swap;
}

@font-face {
  font-family: 'IBM Plex Mono';
  src: url('/assets/fonts/IBMPlexMono-Medium.woff2') format('woff2');
  font-weight: 500;
  font-display: swap;
}
```

---

## 4. Utilitários de Geometria & Chanfros Kiroshi (CSS & Tailwind)

```css
/* Chanfros Kiroshi e Linhas Guias */
@layer utilities {
  /* Chanfro duplo: superior-direito e inferior-esquerdo */
  .clip-kiroshi-card {
    clip-path: polygon(
      0 0,
      calc(100% - 14px) 0,
      100% 14px,
      100% 100%,
      14px 100%,
      0 calc(100% - 14px)
    );
  }

  /* Chanfro simples para botões e abas: corte no topo-direito */
  .clip-kiroshi-btn {
    clip-path: polygon(
      0 0,
      calc(100% - 10px) 0,
      100% 10px,
      100% 100%,
      0 100%
    );
  }

  /* Efeito de scanline sutil da retina cibernética Kiroshi */
  .kiroshi-scanlines {
    background: linear-gradient(
      rgba(18, 16, 16, 0) 50%, 
      rgba(0, 0, 0, 0.22) 50%
    ), linear-gradient(
      90deg,
      rgba(255, 0, 0, 0.03),
      rgba(0, 255, 0, 0.01),
      rgba(0, 0, 255, 0.03)
    );
    background-size: 100% 3px, 6px 100%;
  }

  /* Borda técnica luminosa */
  .kiroshi-glow-cyan {
    box-shadow: 0 0 10px rgba(34, 216, 226, 0.25);
  }

  .kiroshi-glow-yellow {
    box-shadow: 0 0 10px rgba(252, 238, 10, 0.3);
  }

  .kiroshi-glow-red {
    box-shadow: 0 0 12px rgba(255, 0, 60, 0.4);
  }
}
```

---

## 5. Arquitetura de Código Frontend (Svelte 5 Runes)

### 5.1 Ponte de Comunicação (`web/src/lib/bridge.ts`)

```typescript
// Wrapper tipado e seguro para o runtime WebUI do OPEN//77
declare const Open77: {
  on(event: string, callback: (payload: any) => void): void;
  emit(event: string, payload?: unknown): void;
  invoke<T = unknown>(event: string, payload?: unknown): Promise<T>;
  ready(): void;
};

export const bridge = {
  on: (event: string, cb: (payload: any) => void) => {
    if (typeof Open77 !== 'undefined') Open77.on(event, cb);
  },
  emit: (event: string, payload?: unknown) => {
    if (typeof Open77 !== 'undefined') Open77.emit(event, payload);
  },
  invoke: async <T = unknown>(event: string, payload?: unknown): Promise<T | null> => {
    if (typeof Open77 !== 'undefined') return Open77.invoke<T>(event, payload);
    return null;
  },
  ready: () => {
    if (typeof Open77 !== 'undefined') Open77.ready();
  }
};
```

### 5.2 Estado Reativo de Vitais (`web/src/lib/stores/vitals.svelte.ts`)

```typescript
export interface VitalsState {
  hunger: number;
  thirst: number;
  energy: number;
  hygiene: number;
  stress: number;
}

class VitalsStore {
  current = $state<VitalsState>({
    hunger: 100,
    thirst: 100,
    energy: 100,
    hygiene: 100,
    stress: 0
  });

  isCritical = $derived(
    this.current.hunger < 10 || 
    this.current.thirst < 10 || 
    this.current.energy < 10
  );

  update(newVitals: Partial<VitalsState>) {
    this.current = { ...this.current, ...newVitals };
  }
}

export const vitalsStore = new VitalsStore();
```

---

## 6. Integração com `open77_uikit` & Focus Ledger

1. **Diálogos e Modais:** Não recriar janelas de confirmação ou alertas simples do zero. O pacote oficial `open77_uikit` é a fonte canônica para:
   - `alert`: Confirmações de compra, alertas de perigo, avisos bancários.
   - `input`: Entradas numéricas de transferências e nomes de personagens.
   - `context` & `radial`: Menus contextuais e seletores de ação rápida.
   - `progress`: Barras de progresso com animação nativa.

2. **Garantia de Liberação de Foco (Watchdog):**
   - No cliente Lua (`ls_ui/client/main.lua`), o foco do cursor e teclado é habilitado apenas enquanto uma janela modal estiver ativa.
   - O evento `open77:pauseKey` (tecla Escape) fecha imediatamente qualquer tela aberta e devolve os controles à REDengine em 1 tick, impedindo que o jogador fique travado em tiroteios.

---

## 7. Critérios de Aceite da Paridade Visual (Definition of Done)

- [ ] **Zero Fontes Padrão:** Nenhuma palavra é renderizada com fontes genéricas do sistema operacional (Arial, Segoe UI). Apenas *Rajdhani*, *Chakra Petch*, *Saira* ou *IBM Plex Mono*.
- [ ] **Alinhamento Numérico:** Todos os números utilizam `font-mono tabular-nums`.
- [ ] **Ausência de Curvas Suaves de SaaS:** Todos os painéis possuem bordas retas ou cortes chanfrados Kiroshi em 45°.
- [ ] **Feedback Auditivo:** Cliques em botões e alternância de abas acionam os sons Kiroshi diegéticos.
- [ ] **Performance:** O HUD consome 0% de CPU/GPU adicional quando inativo e opera a 60 FPS estáveis na WebView2.
