# Relatório de Engenharia: Correção dos Blips Visíveis no Mapa (Keybind: M) e Traçado de Rota GPS

---

## 1. Diagnóstico e Causa-Raiz (O "Porquê" dos Erros)

Na engenharia de jogos do Cyberpunk 2077 acoplada ao framework Open77, o sistema de mapa mundial (`WorldMapMenuGameController`) opera de forma radicalmente diferente do minimapa do HUD (`MinimapContainerController`). A investigação minuciosa dos scripts decompilados e dos logs revelou dois bloqueios críticos:

### Causa 1: A "Fábrica Fantasma" de Widgets de Marcadores (`CreateMappinUIProfile`)
* **Analogia ELI5:** Imagine que a prefeitura criou uma placa de trânsito nova e catalogou no livro de registros (`MAP INDEX` na direita da tela), mas na hora de mandar a fábrica de metal estampar a placa física no chão (`default_mappin.inkwidget`), a fábrica olhava para o carimbo, não reconhecia o modelo oficial da CD Projekt Red para multiplayer e simplesmente jogava o metal no lixo (`MappinUIProfile.None()`).
* **No Código:** Em [`Open77MultiplayerPolicy.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77MultiplayerPolicy.reds), o minimapa tinha um desvio mapeando para `minimap_poi_mappin.inkwidget`, mas o mapa mundial (`WorldMapMenuGameController`) **não fazia o bind do blip e nem instanciava o perfil de spawn do mapa fullscreen**.
* **Efeito Cascata:** Sem o widget instanciado com o perfil `MapMappinUIProfile.Default` e `MappinUISpawnProfile.Always`, o `Open77BlipId(marker)` retornava 0, e no [`Open77MapScreen.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77MapScreen.reds) a opacidade caía no fallback vanilla que avaliava `inZoomLevel = false`, forçando `opacity = 0.0` e `interactive = false`. O ponto existia no banco de dados, mas era 100% transparente e não recebia cliques.

---

### Causa 2: O Filtro Rígido que Estrangulava o Botão Direito / GPS (`TryTrackQuestOrSetWaypoint`)
* **Analogia ELI5:** Imagine que para pedir uma rota de entrega, o sistema exigia que um laser tocasse o chão físico 3D através de uma janela. Porém, o offset da câmera 3D de Night City estava deslocado (-320, -430) e, como os ícones dos blips estavam invisíveis e sem colisão interativa, o laser nunca batia em nada. O sistema entrava em pânico e dizia: *"Não posso selecionar nada aqui, cancela a operação!"*
* **No Código:** Em [`Open77NativeMap.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77NativeMap.reds), o método `TryTrackQuestOrSetWaypoint()` tinha a trava:
  ```redscript
  if Open77MultiplayerPolicyActive() && !this.Open77MapCanSelectPoint() { return; }
  ```
  Como `selectedMappin` era nulo e o cursor não interceptava colisão nas margens, essa linha abortava o fluxo antes que a função nativa do jogo `TrackCustomPositionMappin()` pudesse calcular o caminho de pedestre ou veículo no grafo de navegação viária.

---

## 2. Soluções Arquiteturais Aplicadas

As alterações foram implementadas de maneira cirúrgica e atômica em 5 scripts do cliente Redscript:

### 1. [`Open77MultiplayerPolicy.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77MultiplayerPolicy.reds)
* No `WorldMapMenuGameController.CreateMappinUIProfile`, agora executamos `Open77BindBlipProfile(mappin)`.
* Se for um blip do servidor (`blipId != 0`), retornamos o widget de mapa mundial nativo do jogo:
  ```redscript
  return MappinUIProfile.Create(
    r"base\gameplay\gui\fullscreen\world_map\mappins\default_mappin.inkwidget",
    t"MappinUISpawnProfile.Always",
    t"MapMappinUIProfile.Default"
  );
  ```

### 2. [`Open77BlipVisuals.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77BlipVisuals.reds)
* Adicionado fallback de auto-vinculação `Open77BindBlipProfile(marker)` dentro de `Open77ApplyBlipVisual()` e `BaseWorldMapMappinController.Update()`.
* Corrigida a inicialização de opacidade em `Open77BlipInkVisual.Apply`: se a opacidade inicial for `0.0`, forçamos `1.0` e `visible = true`.
* Preservado o estilo do ícone no mapa mundial via hook em `BaseWorldMapMappinController.UpdateIcon()`.

### 3. [`Open77MapScreen.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77MapScreen.reds)
* Em `BaseWorldMapMappinController.GetDesiredOpacityAndInteractivity`:
  Garantido que qualquer marcador associado a um blip ativo do servidor receba `interactive = true` e `opacity = 1.0`, permitindo seleção, hover e clique direto no mapa mundial.

### 4. [`Open77NativeMap.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77NativeMap.reds)
* Em `WorldMapMenuGameController.TryTrackQuestOrSetWaypoint`:
  Removido o bloqueio cego de seleção no modo de mapa comum. A verificação restritiva `Open77MapCanSelectPoint()` agora só é acionada no modo de "picking" (quando uma interface Lua solicita explicitamente escolher um ponto no mapa). No uso normal, o clique com o botão direito flui diretamente para a engine nativa calcular a rota do GPS.
* Atualizado `Open77MapObserve` para reconhecer marcadores do tipo `"resource"` como destinos rastreáveis válidos.

### 5. [`Open77MapLegend.reds`](file:///C:/Games/Cyberpunk%202077/r6/scripts/Open77/Open77MapLegend.reds)
* Ao clicar em qualquer local na lista **MAP INDEX** na lateral direita:
  Além de centralizar a câmera cinematográfica sobre o ponto, o sistema localiza o `BaseWorldMapMappinController` no contêiner do mapa, seleciona-o (`SetSelectedMappin`), limpa rotas manuais temporárias (`UntrackCustomPositionMappin`) e invoca `this.TrackMappin(ctrl)` com reprodução do áudio diegético `MapPin / OnEnable`. A linha azul/amarela do GPS de Night City é traçada imediatamente na estrada.

---

## 3. Validação e Compilação

1. **Compilador Redscript (`scc.exe`):**
   * Comando executado:
     ```powershell
     & "C:\Games\Cyberpunk 2077\engine\tools\scc.exe" -compile "C:\Games\Cyberpunk 2077\r6\scripts" -customCacheDir "C:\Games\Cyberpunk 2077\r6\cache\modded"
     ```
   * Resultado: **100% de sucesso**. Compilação limpa sem nenhum erro ou aviso de tipo/sintaxe.
2. **Sincronização de Cache de Scripts:**
   * Atualizados atomicamente tanto `C:\Games\Cyberpunk 2077\r6\cache\modded\final.redscripts` quanto `C:\Games\Cyberpunk 2077\r6\cache\final.redscripts.modded` (tamanho: 16.645.355 bytes).
3. **Consistência do Servidor:**
   * O utilitário `check_config.bat` foi executado no servidor e confirmou validade de todas as configurações de rede (UDP 11778 e TCP 11779).

---

## 4. Como Testar no Jogo

1. Inicie o jogo normalmente pelo client do Open77.
2. Pressione **M** para abrir o Mapa Mundial:
   * **Visualização:** Os 34 pontos de interesse (ATMs, Lojas de Conveniência, Clínicas Ripperdoc e Mercados) agora aparecem desenhados diretamente na malha do mapa de Night City com seus ícones e cores temáticas.
   * **Traçado via Mapa (Botão Direito):** Clique com o botão direito do mouse em qualquer local livre do mapa ou sobre um marcador. A rota de GPS será traçada na hora no chão e no minimapa (seja o jogador a pé ou em um veículo).
   * **Traçado via Índice (Clique Esquerdo na Lista):** Clique em qualquer POI na lista "MAP INDEX" da lateral direita. A câmera voará suavemente até o local e a rota GPS será ativada instantaneamente com efeito sonoro da interface Kiroshi.
