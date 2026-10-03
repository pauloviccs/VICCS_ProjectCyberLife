# Diretrizes Visuais & Design System (UI/UX) - LifeSim RP

## 1. O Padrão Visual: Kiroshi Optics & Cyberpunk 2077 High-Tech Low-Life
Nenhuma interface deste servidor pode se parecer com um painel genérico de web corporativa ou Material Design de 2014. Toda interface deve parecer software diegético de Night City gerado diretamente pelo firmware de um implante ocular Kiroshi Optics ou por um terminal de rua da Arasaka / Central Bank.

---

## 2. Paleta Cromática Obrigatória
| Nome | Hex | Propósito |
| :--- | :--- | :--- |
| **Kiroshi Yellow** | `#FCEE0A` | Títulos primários, bordas de foco, branding Night City, destaques de valor. |
| **Data Cyan** | `#22D8E2` | Telemetria secundária, dados bancários, confirmações, botões de ação tática. |
| **Trauma Red** | `#FF003C` | Alertas críticos, débitos, recusas de transação, aviso de ciberpsicose, perigo. |
| **Bio Green** | `#4FE3A9` | Depósitos, estado vital saudável, restauração biológica, taxas metabólicas ótimas. |
| **Deep Matrix** | `rgba(10, 10, 15, 0.94)` | Fundo com glassmorphism fosco, backdrop filter blur de 12px e corte chanfrado. |

---

## 3. Elementos Estruturais
1. **Geometria Chanfrada (Chamfered Borders):**
   - Uso de `clip-path: polygon(0 0, calc(100% - 15px) 0, 100% 15px, 100% 100%, 15px 100%, 0 calc(100% - 15px));` em cartões e botões.
   - Cantos arredondados comuns do Bootstrap são expressamente proibidos.
2. **Texturas CRT & Scanlines:**
   - Camadas translúcidas com linhas de varredura verticais/horizontais sutis e vinhetas escuras.
3. **Tipografia:**
   - Fontes monoespacadas ou geométricas futuristas (`Rajdhani`, `Orbitron`, `Share Tech Mono`, `Consolas`).
   - Uso obrigatório de prefixos diegéticos: `// NIGHT CITY FINANCIAL`, `// DIAGNOSTICS: ACTIVE`, `[ CONFIRMAR ]`.
4. **Áudio Diegético Sintético (Web Audio API):**
   - Cliques, abertura de modais e transações devem sintetizar beeps e bips eletrônicos sem carregar MP3s pesados, mantendo 0ms de latência.
