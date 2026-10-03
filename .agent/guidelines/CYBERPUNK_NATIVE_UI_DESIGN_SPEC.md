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

- **Rajdhani**: Títulos de janelas, cabeçalhos, botões principais de confirmação.
- **Chakra Petch**: Subtítulos de módulos, identificadores técnicos e rótulos de status.
- **Saira**: Textos corridos, mensagens de texto, contratos de trabalho, logs narrativos.
- **IBM Plex Mono**: Valores de telemetria, relógio in-game, saldo de Eurodollars, coordenadas (`tabular-nums font-mono`).

---

## 4. Utilitários de Geometria & Chanfros Kiroshi (CSS & Tailwind)

```css
@layer utilities {
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

  .clip-kiroshi-btn {
    clip-path: polygon(
      0 0,
      calc(100% - 10px) 0,
      100% 10px,
      100% 100%,
      0 100%
    );
  }

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
}
```

---

## 5. Integração com `open77_uikit` & Focus Ledger

- Diálogos padronizados usam sempre `open77_uikit` assíncrono.
- A tecla `Escape` é interceptada nativamente pelo evento `open77:pauseKey`, restaurando imediatamente o foco de jogo.
- Telas customizadas complexas (`ls_ui`) seguem a arquitetura de camadas com Svelte 5 Runes.
