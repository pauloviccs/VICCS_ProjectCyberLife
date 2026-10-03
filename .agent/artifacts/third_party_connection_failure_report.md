# Relatório de Diagnóstico: Falha de Conexão de Jogador Externo (Logs 4)

## Causa Raiz Identificada
O jogador externo (`JudyEnjoyer`) conseguiu alcançar o servidor e iniciar o aperto de mão (*handshake*) com sucesso via UDP. No entanto, a conexão foi encerrada abruptamente 16 segundos depois com **falha terminal** porque o cliente não conseguiu baixar os scripts e recursos do servidor.

### Prova nos Logs do Cliente (`.agent/logs/4/launcher.log`):
```text
2026-10-01 22:25:21.964  connect monitor: phase -> active
2026-10-01 22:25:37.184  connect monitor: phase -> offline
2026-10-01 22:25:37.199  connect monitor: the client reported a terminal failure: resource_download_failed:resource_http_send_failed
```

### Prova nos Logs do Servidor OPEN//77 no Boot:
```text
[INF] Server configuration: UDP port=11778, advertised=147.185.221.213:5494, maxPlayers=32
[INF] Resource downloads: listen=http://0.0.0.0:11779, public=http://127.0.0.1:11779
[WRN] The advertised resource download address is loopback: remote players cannot use it. Set --public-ip to your VPS IP or --set resources.download.publicBaseUrl=https://your-download-host/.
```

---

## 1. O que aconteceu na prática? (ELI5)

> *Imagine que você abriu um parque temático e colocou uma catraca na entrada principal (`147.185.221.213:5494` UDP). O visitante passou o crachá e a catraca liberou a entrada dele (`phase -> active`).*
>
> *Só que para poder entrar nos brinquedos, ele precisa pegar o mapa e o cinto de segurança no balcão de atendimento (`Porta 11779 HTTP`). Quando ele perguntou onde ficava o balcão, o sistema disse: "fica na sua própria casa, na sua sala de estar (`127.0.0.1:11779`)!". O visitante olhou ao redor, não achou o balcão na casa dele, foi barrado pelos seguranças e teve que ir embora (`resource_download_failed:resource_http_send_failed`).*

Para você (localhost), o endereço `127.0.0.1` funciona perfeitamente porque o servidor está rodando na sua própria máquina. Mas para qualquer pessoa de fora, `127.0.0.1` aponta para o próprio computador dela!

---

## 2. A Arquitetura de Portas do OPEN//77

O servidor OPEN//77 necessita de **duas conexões separadas**:
1. **Porta do Jogo (UDP `11778`)**: Responsável pela movimentação, física, voz e sincronização em tempo real. Esta porta já está tunelada pelo seu Playit.gg em `147.185.221.213:5494` (UDP).
2. **Porta de Recursos (TCP / HTTP `11779`)**: Um servidor web embutido que entrega os scripts, estilos e interfaces (`ls_core`, `ls_vitals`, `ls_ui`, `open77_wardrobe`, etc.) para o jogo do cliente fazer o download antes de renderizar o mundo.

---

## 3. Passo a Passo para Solucionar

### Se você utiliza o Playit.gg:

1. Acesse o painel de gerenciamento do seu Playit: [https://playit.gg/manage](https://playit.gg/manage)
2. Clique no seu agente local e selecione **Add Tunnel** (Adicionar Túnel).
3. Configure o novo túnel com os seguintes parâmetros:
   - **Tunnel Type**: `Custom` ou `TCP`
   - **Protocol**: `TCP`
   - **Local Port**: `11779`
4. O Playit.gg criará o túnel e exibirá o endereço público gerado, por exemplo:
   `147.185.221.213:XXXXX` (ou algo como `seu-tunel.gl.at.ply.gg:XXXXX`).
5. No arquivo `server.jsonc`, configure o bloco `download` dentro de `resources`:

```jsonc
  "resources": {
    "enabled": true,
    "root": "resources",
    "download": {
      "enabled": true,
      "listenUrl": "http://0.0.0.0:11779/",
      "publicBaseUrl": "http://ENDERECO_PUBLICO_PLAYIT_TCP:PORTA_TCP/"
    },
    "load": [
      "polyzone",
      "open77_equipment",
      "open77_wardrobe",
      "system/*",
      "gamemodes/lifesim/*"
    ]
  }
```
*(Substitua `http://ENDERECO_PUBLICO_PLAYIT_TCP:PORTA_TCP/` pelo endereço TCP e porta que o Playit gerou para o túnel da porta 11779).*

---

### Se você for abrir portas no roteador (Port Forwarding direto sem Playit):

1. No seu roteador, crie duas regras de redirecionamento para o IP local do seu PC:
   - Porta `11778` -> Protocolo **UDP**
   - Porta `11779` -> Protocolo **TCP**
2. No `server.jsonc`:
   - `network.publicEndpoint`: `"SEU_IP_PUBLICO:11778"`
   - `resources.download.publicBaseUrl`: `"http://SEU_IP_PUBLICO:11779/"`
