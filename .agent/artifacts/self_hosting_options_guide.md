# Guia Arquitetural de Self-Hosting: OPEN//77 Life-Sim RP

Este guia detalha as melhores opções de hospedagem para o estado atual do servidor, balanceando facilidade, custo, latência (ping) e estabilidade de conexão para jogadores externos.

---

## Comparativo Direto das Opções

| Método | Custo | Dificuldade | Qualidade do Ping | Estabilidade | Ideal Para |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Tailscale / ZeroTier (VPN Mesh)** | **R$ 0,00** | Muito Baixa | Excelente (P2P Direto) | Altíssima | Testes com amigos próximos (2 a 10 players) |
| **2. Port Forwarding no Roteador** | **R$ 0,00** | Média | Máxima (Sua Internet) | Alta | Se você não estiver em CGNAT |
| **3. Oracle Cloud Free Tier (VPS)** | **R$ 0,00** | Alta (Linux/DevOps) | Imbatível (Datacenter SP) | 24/7 Profissional | Servidor permanente gratuito |
| **4. VPS Paga no Brasil (Hostinger/OVH)** | **R$ 35 - 70/mês**| Média | Imbatível (< 15ms) | 24/7 Profissional | Comunidade aberta / Lançamento oficial |
| **5. Túnel Híbrido (Playit UDP + Cloudflare TCP)** | **R$ 0,00** | Baixa | Regular (+40ms a +80ms)| Média | Quebrar galho imediato no PC atual |

---

## 1. Opção 1: Tailscale (A Melhor para Testar AGORA com Amigos)

> **Analogia ELI5:** *É como passar um cabo de rede invisível da sua casa direto para a casa do seu amigo. Vocês ficam na mesma "LAN virtual". Não precisa abrir portas, não precisa de túnel e fura qualquer bloqueio de operadora.*

### Como funciona:
O **Tailscale** utiliza a tecnologia WireGuard para conectar o seu PC ao PC dos seus amigos diretamente ponto-a-ponto (P2P).

### Passo a passo:
1. Você e seus amigos criam uma conta gratuita em [tailscale.com](https://tailscale.com) (grátis até 100 máquinas).
2. Baixam o app no Windows e fazem login.
3. Você receberá um IP virtual fixo (ex: `100.85.20.10`).
4. No seu `server.jsonc`:
   ```jsonc
   "network": {
     "port": 11778,
     "publicEndpoint": "100.85.20.10:11778",
     "maximumPlayers": 32
   },
   "resources": {
     "download": {
       "enabled": true,
       "listenUrl": "http://0.0.0.0:11779/",
       "publicBaseUrl": "http://100.85.20.10:11779/"
     }
   }
   ```
5. Seu amigo abre o launcher do Cyberpunk e digita `100.85.20.10:11778`. Ele entra direto, com ping baixíssimo e baixa os arquivos na velocidade máxima da sua conexão!

---

## 2. Opção 2: Port Forwarding no Roteador de Casa (100% Nativo)

> **Analogia ELI5:** *Abrir a porta da frente da sua casa para a rua, sem precisar de intermediários como o Playit.*

### Requisito: Não estar em CGNAT (Carrier-Grade NAT)
Muitas operadoras (Claro, Vivo, etc.) colocam vários clientes sob o mesmo IP público compartilhado (CGNAT). Se você estiver em CGNAT, portas abertas no roteador não chegam na internet.

### Como testar se você está em CGNAT:
1. Olhe o IP WAN no painel do seu roteador (192.168.x.x).
2. Se ele começar com `100.64.x.x` até `100.127.x.x` ou `10.x.x.x`, você está em CGNAT.
3. **Dica de ouro de Pro:** Ligue no suporte da sua operadora e diga: *"Sou desenvolvedor e jogo consoles, preciso que desativem o CGNAT da minha linha e me coloquem em IP Público Dinâmico para liberar NAT Aberto"*. A maioria das operadoras desativa na hora sem custo.

### Se o CGNAT for desativado:
1. No roteador, redirecione para o IP local do seu PC (`192.168.x.x`):
   - Porta `11778` -> Protocolo **UDP**
   - Porta `11779` -> Protocolo **TCP**
2. No `server.jsonc`, coloque o seu IP público real (que você vê em `meuip.com.br`).

---

## 3. Opção 3: Oracle Cloud Free Tier (A "Joia Escondida" Gratuita)

> **Analogia ELI5:** *A Oracle te dá um computador potente de graça dentro de um datacenter em São Paulo para sempre, com internet de 1 Gbps e IP fixo.*

### O que eles oferecem de graça (Always Free):
- Máquina virtual ARM Ampere com até **4 OCPUs (vCPUs) e 24 GB de Memória RAM**.
- 200 GB de disco NVMe.
- Tráfego de 10 TB/mês.
- IP público estático IPv4 fixo.
- Datacenter em Vinhedo/São Paulo (ping de 5ms a 15ms para o Brasil todo).

### Prós:
- O servidor fica ligado 24 horas por dia sem você precisar deixar o seu computador pessoal ligado.
- Desempenho profissional para até 32-64 jogadores simultâneos.
- Sem problemas de operadora de internet residencial.

### Contras:
- Exige cartão de crédito para verificação de cadastro (não cobra nada).
- O servidor roda em Linux (Ubuntu 24.04), exigindo rodar o Open77 Server no Linux (o Open77 é baseado em .NET Core e roda nativamente no Linux).

---

## 4. Opção 4: VPS Dedicada Paga no Brasil (Para quando o Projeto Lançar)

Quando o servidor estiver na Fase 4/Fase 5 e você quiser abrir para a comunidade sem dor de cabeça:
- **Hostinger Brasil / OVH / Maxihost / Latitude.sh**:
  - Máquina com 4 vCPUs e 8GB-16GB RAM em São Paulo.
  - Custo médio: R$ 40 a R$ 90/mês.
  - Proteção Anti-DDoS profissional incluída.

---

## Veredito & Recomendação Pragmática

1. **Para os testes de hoje/amanhã com amigos conhecidos:**
   - Use o **Tailscale** (Opção 1). É configurado em 2 minutos, zero dor de cabeça com operadora, e você testa os vitais, chat e gameplay sem nenhum lag de túnel internacional.
2. **Para deixar o servidor público para qualquer pessoa sem instalar nada extra:**
   - Criar uma conta no **Oracle Cloud Free Tier** ou assinar uma VPS barata em São Paulo.
