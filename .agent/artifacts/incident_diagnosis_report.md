# Relatório Consolidado de Diagnóstico de Incidentes (OPEN//77)

## Incidente 0: Rejeição por Incompatibilidade de Build (RESOLVIDO)
* **Evidência:** `expected game build: 231`.
* **Causa Raiz:** O Cyberpunk 2077 v2.31 utiliza o identificador canônico de build **`23100`** no protocolo do Open77 (`CLIENT_PROFILE.gameBuild = 23100`).
* **Solução:** `expectedGameBuild` atualizado para `23100` em [`server.jsonc`](file:///c:/Games/VICCS_CyberpunkServer/Server/server.jsonc).

---

## Incidente 1: Servidor Local Offline vs Servidor Público "Iluv" (RESOLVIDO)
* **Evidência:** Conexão travada em *"Preparing your session... Connecting - Iluv 34.32.22.165:11778"*.
* **Causa Raiz:** O usuário clicou no servidor comunitário "Iluv" (Google Cloud) que estava fora do ar, e em seguida tentou conectar localmente quando o executável do servidor local ainda não tinha sido ligado.
* **Solução:** O servidor foi iniciado e a conexão direta por `127.0.0.1:11778` funcionou perfeitamente (comprovado pela captura de tela dentro do jogo em Badlands).

---

## Incidente 2: `lease_endpoint_mismatch` na Conexão via Playit (RESOLVIDO)

### 1. Evidência do Erro
* **Mensagem:**
  ```text
  The server's run lease was rejected by the Master.
  Reason: server_lease_invalid:lease_endpoint_mismatch
  Server: 147.185.221.213:5494
  Endpoint: 147.185.221.213:5494
  ```
* **Log do Launcher:** [`Server/.agent/logs/2/launcher.log`](file:///c:/Games/VICCS_CyberpunkServer/Server/.agent/logs/2/launcher.log) (linhas 881-883):
  `connect monitor: connect-pass status = rejected:lease_endpoint_mismatch`
  `connect monitor: the client reported a terminal failure: server_lease_invalid:lease_endpoint_mismatch`

### 2. Causa Raiz
No arquivo [`server.jsonc`](file:///c:/Games/VICCS_CyberpunkServer/Server/server.jsonc), a seção de rede estava configurada como:
```jsonc
"network": {
  "port": 11778,
  "publicEndpoint": "127.0.0.1:11778",
  "maximumPlayers": 32
}
```
Quando o servidor inicia, ele envia sua chave de licença ao **Open77 Master Server** junto com o seu `publicEndpoint`. O Master Server gera um "Run Lease" (contrato de execução assinado criptograficamente) atrelado especificamente ao endereço `127.0.0.1:11778`.

Quando você ou outros jogadores tentam conectar através do IP público do Playit (`147.185.221.213:5494`), o launcher pede ao Master Server um ticket de admissão para `147.185.221.213:5494`. O Master Server confere no banco de dados e diz:
*"O servidor registrado com essa licença só tem permissão para receber conexões no endereço `127.0.0.1:11778`, e não em `147.185.221.213:5494`!"*
Resultado: rejeição imediata com `server_lease_invalid:lease_endpoint_mismatch`.

### 3. Correção Aplicada
1. Editado [`server.jsonc`](file:///c:/Games/VICCS_CyberpunkServer/Server/server.jsonc):
   ```jsonc
   "network": {
     "port": 11778,
     "publicEndpoint": "147.185.221.213:5494",
     "maximumPlayers": 32
   }
   ```
2. Testado o registro no Master Server:
   ```text
   [INF] Server configuration: UDP port=11778, advertised=147.185.221.213:5494, maxPlayers=32
   [INF] Run lease granted by the master (expires 2026-10-01T17:42:41+00:00).
   [INF] Registered server 38d7c275-be7a-4ece-b0d2-7c8ac12ac265 with the Open77 Master.
   ```
   O Master Server validou e emitiu o lease oficial para `147.185.221.213:5494`.

---

## 4. Instruções de Verificação

1. **Iniciar o Servidor:**
   * Execute o [`start_server.bat`](file:///c:/Games/VICCS_CyberpunkServer/Server/start_server.bat).
   * Ele iniciará e anunciará publicamente ao Master Server o endereço `147.185.221.213:5494`.
2. **Conectar via Launcher:**
   * No launcher do **OPEN//77**, selecione o endereço do Playit: **`147.185.221.213:5494`** (ou o servidor **`VICCS Night City Life-Sim RP`** na lista pública).
   * Clique em **Play**.
   * O Master Server reconhecerá o endpoint correspondente e autorizará o handshake sem erros!
