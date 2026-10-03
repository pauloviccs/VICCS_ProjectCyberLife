# Mídia Local da Loading Screen (ls_loadscreen)

Para utilizar um vídeo local em vez das cut-scenes Vanilla de Night City:

1. Coloque o seu arquivo de vídeo neste diretório com o nome `intro.mp4`:
   `Server/resources/gamemodes/lifesim/ls_loadscreen/web/media/intro.mp4`
2. No arquivo `web/config.json` ou `shared/config.lua`, altere o modo para `"local"`:
   ```json
   "mode": "local",
   "localVideoUrl": "./media/intro.mp4"
   ```
3. Se o arquivo `intro.mp4` não for encontrado ou falhar na reprodução, o sistema ativará automaticamente o fallback suave para as cenas Vanilla de Cyberpunk 2077 para garantir que a tela nunca fique preta.
