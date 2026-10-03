# Protocolo Arquitetural: Interface First (HUD/NUI) vs Comandos Rápidos

## 1. O Princípio "Interface First"
No ecossistema de Night City do VICCS Server, **todo recurso nasce como uma experiência visual (HUD/NUI)**. O uso de comandos de chat é estritamente restrito a interações táteis rápidas de rua ("hand-to-hand") ou funções administrativas de suporte.

A digitação de comandos em caixas de chat quebra a imersão do jogador, oculta informações contextuais cruciais (como status nutricional, saldo ao vivo, tempos de recarga e diagnósticos clínicos) e reduz o valor de produção do servidor.

---

## 2. Matriz de Curadoria: O que é Interface vs O que é Comando

| Domínio / Sistema | Interface NUI / HUD (Primeiro Cidadão) | Comando Rápido (Exceção / Atalho de Rua) | Justificativa do Engenheiro |
| :--- | :--- | :--- | :--- |
| **Banco & Finanças** | **Terminal Kiosk ATM (`#atm-modal`)**<br>- Saque com cédulas prontas<br>- Depósito em maços<br>- Operação manual digitada<br>- Transferência eletrônica entre cidadãos | `/pagar <alvo> <quantia>`<br>`/pay <alvo> <quantia>` | Abrir interface para entregar dinheiro vivo a alguém na rua quebra o ritmo de um assalto, corrida ou negociação. Já o banco exige extrato, segurança e conferência visual. |
| **Alimentação & Vending** | **Vitrine All-Foods 24/7 (`#vending-modal`)**<br>- Cards com stats biológicos (+Fome, +Sede, +Buff)<br>- Seleção de pagamento (Notas vs Cartão)<br>- Checkout com som mecânico | `/comprar <itemKey>`<br>*(Opcional / Fallback)* | O jogador precisa ver o que está comendo, quanto vai encher seu estômago e qual impacto terá em sua carga biológica. |
| **Cibernética & Ripperdoc** | **Clínica Viktor Vector (`#ripperdoc-modal`)**<br>- Diagnóstico com estabilidade neural e calor<br>- Grade anatômica por slots<br>- Cores de raridade cromática<br>- Farmácia cirúrgica com injetores | `/cw_diag`<br>`/cw_give` *(Exclusivo de Admins)* | Cirurgias cerebrais e de membros exigem precisão médica. Um comando de chat não transmite o risco de ciberpsicose nem o calor ocular. |
| **Biometria & Saúde** | **Kiroshi Biomonitor HUD**<br>- Barras vivas de Saúde, Fome, Sede, Higiene, Stress<br>- Indicadores de Cash e Bank<br>- Modal de calibração espacial livre | `/biomonitor`<br>*(Abre calibração visual do HUD)* | O jogador precisa de telemetria periférica contínua sem precisar perguntar ao servidor "qual é o meu HP". |
| **Emergência Médica** | **Alerta Crítico Visual** (Vinheta vermelha de dano, pulsação de ciberpsicose) | `/neuroblocker` / `/usar_bloqueador`<br>*(Hotbar / Tecla de Ação Rápida)* | Em um tiroteio, se o implante esquentar ou a estabilidade despencar, o cidadão precisa de um reflexo motor rápido para injetar o neurobloqueador. |

---

## 3. Regras para Novos Recursos (Fases Futuras: Garagens, Moradia, Empregos)
1. **Garagens / Concessionárias:** NUNCA spawnar carro apenas com `/carro nome`. Criar terminal de pátio automotivo com ficha técnica, fotos/holograma do veículo, nível de blindagem e custo.
2. **Propriedades / Apartamentos:** Criar painel de intercomunicador na porta com chave de acesso, status de aluguel e campainha.
3. **Empregos / Facções:** Painel de contratos e despachos corporativos estilo Fixer Terminal.
