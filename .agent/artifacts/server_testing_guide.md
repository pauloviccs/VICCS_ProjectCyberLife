# Guia Completo de Testes: Servidor OPEN//77 Life-Sim RP

> **Projeto:** VICCS Night City Life-Sim RP  
> **Servidor:** Build `2.31.21+op77.121`  
> **Portas do Servidor:** UDP `11778` (Game Socket), TCP `11779` (Asset Download), TCP `11780` (Warden Panel)

---

## 🚀 Método 1: Iniciar o Servidor

1. Certifique-se de que o **MySQL no XAMPP está rodando** (como visto no painel do XAMPP).
2. Vá até a pasta `c:\Games\VICCS_CyberpunkServer\Server`.
3. Dê dois cliques em **`start_server.bat`**.
4. Uma janela de console abrirá mostrando o carregamento dos 37 recursos nativos e a mensagem final:
   ```text
   [INF] VICCS Night City Life-Sim RP listening on UDP 0.0.0.0:11778
   [INF] Visibility=Public, locale=pt-BR, masterListing=enabled.
   [INF] Registered server 38d7c275-... with the Open77 Master.
   ```

---

## 🖥️ Método 2: Teste pelo Console Interativo (Sem Jogo)

Na janela aberta do servidor, você pode digitar comandos diretamente no teclado:

| Comando | O que ele faz |
| :--- | :--- |
| `status` | Mostra FPS do servidor, tickrate atual, jogadores online e tempo ativo. |
| `resources` | Lista todos os recursos em execução (`polyzone`, `open77_appearance`, etc.). |
| `weather status` | Exibe a hora do dia e o clima atual de Night City no servidor. |
| `notification.test` | Dispara um teste do serviço nativo de notificações. |
| `elevator.list` | Lista todos os elevadores mapeados sob autoridade do servidor. |
| `help` | Mostra todos os comandos administrativos disponíveis. |

---

## 🌐 Método 3: Teste pelo Navegador (Painel Warden & Health)

Com o servidor rodando, abra o seu navegador de preferência (Chrome/Edge):

1. **Painel Web Warden (Gerenciamento Visual):**
   * URL: [http://127.0.0.1:11780/](http://127.0.0.1:11780/)
   * O painel permite inspecionar jogadores online, recursos ativos, telemetria e o Workshop oficial.
2. **Health Check de Download de Recursos:**
   * URL: [http://127.0.0.1:11779/health](http://127.0.0.1:11779/health)
   * Resposta esperada: `{"status":"ok","service":"open77-resources"}` (código 200).
   * Você também pode executar [`Server/test_endpoints.bat`](file:///c:/Games/VICCS_CyberpunkServer/Server/test_endpoints.bat) para um teste automático via terminal.

---

## 🎮 Método 4: Conectar pelo Jogo (Cyberpunk 2077)

Para entrar no servidor dentro de Night City:

1. **Requisitos no PC do Jogador:**
   * Ter o **Cyberpunk 2077 v2.31** (ou Phantom Liberty) instalado.
   * Baixar o **OPEN//77 Client** em [open2077.net/host#download](https://open2077.net/host#download) (aba Client) e instalar na pasta do jogo.
2. **Conexão:**
   * Abra o jogo através do inicializador do OPEN//77.
   * No menu multijogador, você pode conectar de duas formas:
     * **Direct Connect (Recomendado para teste local):** Digite `127.0.0.1:11778`.
     * **Server Browser:** Busque por `VICCS Night City Life-Sim RP` na lista pública do Master Server.
3. **Resultado:**
   * O cliente baixará os pacotes pela porta `11779`.
   * O personagem será persistido nas tabelas `open77_characters` e `characters_vitals` do seu banco `open77_lifesim` no XAMPP!

---

## 🗄️ Método 5: Monitorando o Banco de Dados no HeidiSQL

1. Abra o **HeidiSQL**.
2. Clique na conexão e aperte **F5**.
3. Abra o banco de dados **`open77_lifesim`**.
4. Sempre que um jogador entrar ou salvar dados de customização, as tabelas `open77_characters`, `players` e `characters_vitals` receberão os registros atualizados em tempo real!
