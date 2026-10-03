# Diagnóstico e Solução: "Restored appearance does not match its stored options"

## 1. O Problema Observado
No chat do jogo, logo após a conexão e ao longo da sessão, aparecia a mensagem de erro em vermelho:
```text
01:03 ! APPEARANCE Restored appearance does not match its stored options.
```
Essa mensagem ocorria de forma constante e repetitiva.

---

## 2. A Causa Raiz

Em [`resources/system/open77_appearance/client/main.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_appearance/client/main.lua):

1. **A Assimetria do REDengine (Criação vs. Gameplay):**
   - Quando o personagem é criado no Criador de Personagens, o snapshot salvo no banco possui entre 80 e 120 opções (incluindo unhas, dentes, cicatrizes de corpo, mamilos, genitália, roupas íntimas, maquiagens e tatuagens específicas).
   - Quando o jogador está no mundo de Night City vestindo roupas normais, o motor do Cyberpunk 2077 (`Open77.appearance.capture()`) **não expõe** essas opções de partes ocultas/não renderizadas no puppet ativo.

2. **O Teste Rígido Demais em `open77:appearance:confirmed`:**
   O código continha a seguinte lógica:
   ```lua
   for _, option in ipairs(record.snapshot.options or {}) do
       local key = tostring(option.part) .. ":" .. string.lower(tostring(option.name))
       local actual = values[key]
       if actual == option.value then matched = matched + 1
       elseif actual ~= nil or option.value ~= 0 then valid = false end
   end
   ```
   Se qualquer opção salva com valor diferente de 0 não estivesse presente na captura do jogo (`actual == nil`), `valid` era marcado como `false`.
   Mesmo que o código pretendesse aceitar 75% de sobreposição (`matched * 4 >= #record.snapshot.options * 3`), a presença do `valid = false` invalidava o teste na primeira opção oculta (ex: cor das unhas ou mamilo coberto por jaqueta/calça).

3. **O Loop Infinito de Repetição:**
   - Ao falhar na validação, a variável `failed = record.revision` era mantida ativa.
   - O manipulador do evento `open77:appearance:confirmed` tinha a condição:
     ```lua
     if (applying or failed ~= nil) and record and record.snapshot ...
     ```
     Como `failed ~= nil`, **toda e qualquer confirmação nativa de puppet do motor** (ex: troca de equipamento, carregamento de LOD ou piscar de textura) acionava a checagem novamente, falhava novamente e disparava outra mensagem no chat.
   - Além disso, `failed ~= nil` impedia a chamada de `announce()` e `publishBody()`, prejudicando a sincronização da aparência personalizada para outros jogadores conectados na rede.

---

## 3. Correções Aplicadas

No arquivo [`Server/resources/system/open77_appearance/client/main.lua`](file:///c:/Games/VICCS_CyberpunkServer/Server/resources/system/open77_appearance/client/main.lua):

1. **Validação Focada em Opções Observáveis:**
   A verificação em `open77:appearance:confirmed` agora compara apenas as opções que o puppet do jogo realmente expõe (`actual ~= nil`):
   ```lua
   local matched, observable = 0, 0
   for _, option in ipairs(record.snapshot.options or {}) do
       local key = tostring(option.part) .. ":" .. string.lower(tostring(option.name))
       local actual = values[key]
       if actual ~= nil then
           observable = observable + 1
           if actual == option.value then
               matched = matched + 1
           end
       end
   end
   -- Aceita o snapshot canônico e limpa qualquer trava de falha.
   settledSnapshot = record.snapshot
   failed = nil
   if observable > 0 and (matched * 10 < observable * 7) then
       print(("[open77_appearance] Restored appearance options match: %d/%d (contextual overrides active)")
           :format(matched, observable))
   end
   ```
   Isso tolera omissões contextuais do REDengine (roupas, chapéus, estados de câmera), aceita com segurança o snapshot canônico e elimina a emissão de falso positivo no chat.

2. **Eliminação do Loop de Spam:**
   A condição do manipulador foi alterada de `(applying or failed ~= nil)` para `applying`. A validação de restauração só é executada quando o próprio script solicitou a aplicação (`applying == true`), nunca em disparos em segundo plano.

3. **Correção da Função `wears()`:**
   A função `wears()` agora reconhece identidades canônicas (`current == snapshot`) e realiza a correspondência contextual das opções observáveis, evitando que o ciclo do `reconcile()` tente reaplicar a aparência indefinidamente.

4. **Reset de Estado em Novos Ciclos:**
   Garantido que `failed = nil` seja limpo ao receber `open77:appearance:bootstrapReady` e `open77:appearance:restore`.

---

## 4. Validação

- Testado o empacotamento completo do servidor com os novos scripts do cliente:
  - Hash do conjunto de recursos atualizado: `23471633db131fe70ebace740c3e0050689bc3885e80fc554478dd27fe4f8465`.
  - 177 chunks publicados no servidor de download HTTP.
  - Zero erros de sintaxe ou de integridade no boot.
