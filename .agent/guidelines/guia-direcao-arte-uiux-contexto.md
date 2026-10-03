# Guia de Direção de Arte, UI/UX e Geração Visual

> **Arquivo de contexto para IDE, Gemini e Nano Banana**  
> **Projeto:** [NOME DO JOGO] · **Plataforma:** roleplay multiplayer · **Versão:** 1.0  
> **Idioma de trabalho:** português; manter nomes de componentes, tokens e IDs em inglês quando forem usados no projeto.

Este documento é a referência principal para criar, revisar e iterar artes de mundo, personagens, HUD, menus, interfaces diegéticas, UX e material promocional de **[NOME DO JOGO]**. A direção deve evocar ficção científica urbana, desigualdade, tecnologia cotidiana, cultura de rua e vida corporativa por meio de decisões originais. O livro *The World of Cyberpunk 2077* foi consultado como referência de alto nível para variedade editorial, contraste de ambientes, combinação de fotografia/ilustração/anúncio/documento e apresentação de um mundo através de artefatos. **Não reproduzir** logotipos, personagens, textos, marcas, layouts específicos, ilustrações, ícones distintivos, armas, veículos ou páginas do livro/jogo. Criar identidade própria para este projeto.

---

## 0. Ordem obrigatória de decisão

Quando houver conflito entre instruções, seguir a ordem abaixo. A decisão de prioridade mais alta vence; registrar ambiguidades em vez de inventar fatos do cânone.

1. **Pedido atual do usuário e requisitos do recurso**: objetivo, público, plataforma, resolução, formato, conteúdo obrigatório.
2. **Cânone aprovado do projeto**: lore, facções, personagens, geografia, economia e tecnologia já definidos.
3. **Usabilidade, legibilidade e acessibilidade**: a interface precisa funcionar antes de parecer estilosa.
4. **Este guia**: identidade visual, tokens, composição e regras de consistência.
5. **Brief do artefato**: particularidades de uma tela, imagem ou campanha.
6. **Sugestões da ferramenta generativa**: usar apenas se não conflitam com as camadas acima.

Se algo essencial estiver ausente, usar placeholders visíveis como `[NOME DA FACÇÃO]`, `[TEXTO EXATO]` ou `[LOCAL]`. Não criar lore apresentado como fato. Para artes sem texto, não inserir palavras legíveis inventadas.

## 1. Intenção e princípios de direção

### 1.1 Pilares

- **Futuro habitado:** tecnologia integrada a trabalho, transporte, lazer e sobrevivência; telas, cabos, manutenção, desgaste e infraestrutura têm função no mundo.
- **Contraste social visível:** riqueza protegida e limpa pode coexistir no mesmo quadro com precariedade, densidade, remendos e vigilância. Evitar reduzir comunidades a caricaturas.
- **Cultura local:** cada bairro, grupo e negócio tem materiais, códigos, ritmos e sinais próprios. Evitar cenário genérico de “cidade neon”.
- **Utilidade diegética:** telas e objetos parecem criados por uma instituição real do mundo, com objetivo, usuário e contexto reconhecíveis.
- **Narrativa por camadas:** primeiro lê-se a silhueta/ideia; depois a ação ou informação; por fim, pequenos detalhes de história e material.
- **Risco com humanidade:** dureza, violência ou decadência nunca apagam a presença de pessoas, humor, descanso, afeto e cotidiano.
- **Coerência com variação:** uma família visual comum une o jogo; bairros, marcas ficcionais e facções variam dentro desse sistema.

### 1.2 Sensação-alvo

Urbano, denso, tátil, tecnicamente plausível, vivido, tenso mas legível, com cor usada como sinal e não como decoração constante. A cidade precisa parecer funcionar mesmo fora do enquadramento: energia, água, logística, comunicação, segurança, comércio e manutenção deixam vestígios visuais.

### 1.3 Evitar

- Neon em toda superfície, chuva permanente, hologramas aleatórios e excesso de ciano/magenta como atalho de gênero.
- “Futurismo limpo” em todos os bairros ou “sucata” em todos os personagens.
- Interfaces cheias de ruído, texto microscópico, brilho atrás de cada botão ou estética de terminal sem motivo de uso.
- Códigos visuais que confundam legibilidade com realismo: glitch decorativo em informação crítica, baixo contraste ou animação constante.
- Misturar épocas, tecnologias, sinais corporativos e culturas sem razão de lore.

## 2. Referência analisada e tradução para o projeto

A referência consultada organiza o universo por assuntos (história, tecnologia, zonas urbanas, classes sociais, lei e grupos) e alterna imagens cinematográficas, retratos, anúncios, fichas de equipamento, mapas/ambientes, páginas editoriais e documentos diegéticos. Há contrastes fortes entre áreas claras e escuras, acentos amarelos de alta energia, fotografia/arte com iluminação colorida, tipografia condensada de impacto e blocos de texto editorial. A principal lição de produção é **mudar o formato visual conforme a função narrativa** e fazer o próprio material parecer parte do mundo.

Aplicação: construir uma biblioteca de formatos originais — dossiê, anúncio, mapa, tela de serviço, boletim, retrato, placa, interface de equipamento e pôster — usando os tokens deste guia. Não copiar uma página específica, nem sua organização ou identidade de marca.

## 3. Sistema visual base

### 3.1 Paleta inicial (tokens provisórios)

A paleta abaixo é ponto de partida. A direção de arte pode criar cores por distrito/facção, mas deve preservar funções semânticas e contraste. Validar os valores finais sobre os fundos reais do jogo.

| Token | Hex inicial | Uso | Regra |
|---|---:|---|---|
| `ink-950` | `#090B10` | fundo profundo, HUD noturna | não usar como único fundo em toda experiência |
| `slate-900` | `#151B22` | painéis, superfícies técnicas | principal superfície escura |
| `slate-700` | `#303A45` | contorno, divisores, texto secundário | separação sutil, não competir com conteúdo |
| `paper-100` | `#E9E6DD` | painéis editoriais claros | branco quente reduz dureza visual |
| `paper-300` | `#C7C5BD` | superfície secundária clara | evitar texto claro sobre ela |
| `signal-lime` | `#D9F34A` | ação principal, seleção, aviso da marca | usar em pequenas áreas e manter contraste com texto escuro |
| `signal-cyan` | `#55D9E8` | dados, navegação, tecnologia | não codificar estado crítico exclusivamente pela cor |
| `signal-coral` | `#FF625B` | perigo, dano, urgência | reservar para erro/ameaça real |
| `signal-amber` | `#FFB547` | atenção, energia, informação temporária | distinto de perigo fatal |
| `signal-violet` | `#B18CFF` | social, rede, conteúdo especial | uso controlado; não presumir semântica sem lore |
| `success` | `#71D6A4` | confirmado, seguro | sempre combinar com ícone/rótulo |

**Proporção de enquadramento recomendada:** 65–80% tons-base/neutros, 15–25% cores ambientais/faccionais e 3–8% acentos de alta saturação. Isso é uma métrica composicional inicial, não uma obrigação por pixel. Para telas de alerta, a cor de estado pode ultrapassar esse intervalo. Evitar usar mais de dois acentos saturados dominantes no mesmo componente.

**Regras semânticas:** perigo não é lime; seleção não é a mesma coisa que confirmação; indisponível não é apenas cinza; raridade não deve depender só de cor. Usar rótulo, ícone, forma, posição e/ou padrão além da cor. Criar tokens de tema por distrito sem alterar os estados universais.

### 3.2 Tipografia

- **Display:** sans condensada ou grotesca de personalidade para títulos curtos, códigos e campanhas. Uso pontual, nunca em parágrafos longos.
- **Interface:** sans altamente legível, ampla cobertura de acentos/idiomas e boa leitura em tamanhos pequenos.
- **Dados/código:** monoespaçada para IDs, coordenadas, timestamps e telemetria; não usar em toda a interface.
- Usar fontes licenciadas e disponíveis no projeto. Se a ferramenta não puder renderizar texto confiável, produzir a arte sem texto e adicionar a tipografia no layout final.
- Hierarquia recomendada em tela 1080p: título de tela 28–40 px; cabeçalho de seção 20–28 px; corpo 16–20 px; metadados 12–14 px. Alvos e plataformas móveis podem exigir aumento. Não reduzir texto crítico abaixo de 14 px em mockup de 1080p.
- Limitar a duas famílias tipográficas por peça, três pesos principais e três níveis de caixa alta. Evitar blocos longos em caixa alta.
- Usar espaçamento consistente, números tabulares em dados alinhados e quebras de linha intencionais. Nunca deformar tipografia para caber.

### 3.3 Forma, materiais e textura

- Geometria primária: retângulos modulares, cantos levemente cortados ou arredondados conforme fabricante, linhas de alinhamento e módulos de informação.
- A silhueta deve comunicar função: painel corporativo preciso; equipamento de rua remendado; interface pública acessível; sistema clandestino improvisado.
- Materiais: polímero fosco, metal pintado, vidro riscado, tecido técnico, papel térmico, sinalização retroiluminada, concreto e cerâmica. Cada material responde à luz de forma diferente.
- Textura é secundária à forma. Limitar ruído/grão a uma camada discreta; desgaste deve ocorrer em pontos plausíveis de toque, impacto, sol, água ou reparo.
- Cabos, parafusos, avisos e danos devem explicar montagem, manutenção, risco ou uso. Não usar “detalhe técnico” sem função.

### 3.4 Luz e imagem

- Definir uma luz principal, uma luz de recorte ou fonte prática e um nível de preenchimento antes de adicionar reflexos coloridos.
- Separar sujeito e fundo por valor, silhueta, foco e temperatura. A iluminação colorida não pode dissolver o contorno importante.
- Escolher clima conforme narrativa: manhã industrial, interior fluorescente, pôr do sol contaminado, publicidade excessivamente limpa, abrigo quente, rua fria. Não impor noite/ch chuva em todas as imagens.
- Composição: ponto focal único; linha de ação clara; primeiro plano, plano médio e fundo com funções diferentes; reservar área negativa quando houver texto de campanha.
- Retratos: expressão e postura legíveis; roupas/equipamento ajudam a contar papel, origem ou rotina. Evitar pose promocional idêntica para todos.

## 4. Linguagem de interface e UX

### 4.1 Regras de produto

1. **Estado acima do enfeite:** o jogador deve entender o que está acontecendo sem interpretar efeitos.
2. **Uma ação primária por contexto:** a ação de maior consequência tem hierarquia visual e texto específico.
3. **Feedback imediato:** pressionado, carregando, concluído, falhou e bloqueado têm estados visuais e sonoros distintos.
4. **Progressão legível:** mostrar requisito, custo, consequência e reversibilidade antes de confirmar uma ação importante.
5. **Contexto multiplayer:** indicar quem vê, quem controla, escopo do chat, propriedade/estado compartilhado e latência quando relevante.
6. **Sem surpresa irreversível:** confirmar operações de alto impacto e explicar a consequência em linguagem direta.
7. **Recuperação:** falhas apresentam causa provável e próximo passo; preservar entrada do usuário quando possível.

### 4.2 Componentes e prioridade

- **HUD persistente:** somente informação de uso frequente durante ação. Meta inicial: até 5 grupos persistentes; cada grupo com até 3 elementos principais. Remover dados redundantes que já aparecem no mundo.
- **Retículo/indicador de alvo:** forma simples, escala consistente, estados distintos (neutro, foco, hostil, aliado, interativo). Não cobrir rosto ou detalhe crítico.
- **Saúde/recursos:** usar barra + valor/estado textual em situações críticas; mostrar mudanças com animação breve e não pulsar continuamente.
- **Mapa/minimapa:** distinguir jogador, grupo, destino, perigo e serviço por ícone/forma. Orientação e escala devem ser configuráveis se o jogo permitir.
- **Inventário/equipamento:** comparação lado a lado com diferenças positivas/negativas explícitas; sinalizar peso, slot, requisitos e ação atual. Não depender de cor de raridade.
- **Social/voz:** indicar canal/escopo, quem fala, mute e status de conexão de modo discreto. Ícone de microfone não pode ser ambíguo entre enviar áudio e silenciar.
- **Notificações:** agrupar eventos repetidos, manter prioridade, expiração e origem. Não cobrir controles nem texto essencial. Usuário pode ajustar categorias quando possível.
- **Menus diegéticos:** justificar a tela dentro do mundo, mas preservar navegação previsível e leitura acessível. Não esconder padrões de interação atrás de “realismo”.

### 4.3 Medidas relativas e responsividade

- Usar grade de 8 px como base; subdivisões de 4 px para ajustes finos. Margens de tela seguras: 4% em cada borda como início; aumentar para áreas com overscan/recorte ou UI de console.
- Espaçamento: 8/12/16/24/32 px; componentes repetidos não devem introduzir valores arbitrários sem motivo.
- Alvo de interação: mínimo 44×44 px em contexto de controle por toque/mouse; para controle, região de foco claramente maior que o ícone. Manter distância suficiente entre ações destrutivas e comuns.
- Layout em 16:9 é referência, não verdade universal. Preservar foco e hierarquia em 16:10, 21:9, 4:3 e resoluções reduzidas com reflow; não apenas esticar.
- Em telas pequenas, colapsar metadados secundários, não a ação principal nem o estado crítico. Em ultrawide, limitar largura de leitura e distribuir painéis em colunas.
- Respeitar zona segura e área ocupada por câmera/stream overlay quando o brief indicar transmissão.

### 4.4 Acessibilidade

- Não depender apenas de cor, som, movimento ou posição. Fornecer redundância por rótulo, forma, padrão ou feedback alternativo.
- Garantir contraste de texto suficiente conforme padrão do produto; como alvo mínimo, 4.5:1 para texto normal e 3:1 para texto grande/componentes significativos. Revalidar em cada tema.
- Suportar escala de UI, legendas, redução de movimento, remapeamento de controles e filtros de cor conforme escopo técnico.
- Evitar flashes rápidos e animação infinita em conteúdo crítico. Respeitar preferência de movimento reduzido.
- Escrever mensagens com verbo/ação e consequência: “Sair do grupo?” em vez de “Confirmar?”.

### 4.5 Animação e som (brief visual)

- A transição comunica causalidade: aparecer, selecionar, confirmar, atualizar, alertar. Evitar movimento só para parecer tecnológico.
- Microinteração padrão: rápida e curta; transição de navegação não deve atrasar tarefas repetidas. Definir duração em milissegundos como token do produto e documentar easing.
- Glitch só pode representar instabilidade narrativa ou sinal degradado, nunca a única leitura de informação importante.
- Cor e animação devem ser avaliadas com efeitos desligados. Para sons, documentar evento, prioridade, intensidade, repetição e alternativa visual.

## 5. Famílias de artefatos e especificações

Para cada pedido, selecionar uma família antes de compor. Registrar: finalidade, público, canal, proporção, escala de leitura, conteúdo obrigatório, texto exato, local de uso, safe area e variantes.

### 5.1 Key art / pôster promocional

- Uma promessa visual e um protagonista/objeto focal; leitura clara em miniatura.
- Camadas: silhueta principal, ambiente que contextualiza, sinais de escala, acentos de cor, área de título/copy reservada.
- Para thumbnail, testar em 10–15% do tamanho final. Se a ideia desaparecer, simplificar.
- Evitar incluir logotipo/texto inventado pela imagem generativa. Reservar área limpa para composição final.

### 5.2 Retrato de personagem

- Capturar idade aparente, postura, expressão, roupa, ferramentas e sinais de uso compatíveis com briefing/cânone.
- Fundo fornece contexto sem competir. Incluir versões de corpo inteiro, busto e avatar quando solicitado; manter características-chave entre ângulos.
- Não inferir etnia, identidade, trauma ou condição médica não fornecida. Representação deliberada e respeitosa.

### 5.3 Ambiente e distrito

- Definir função urbana, época do dia, clima, densidade, fluxo humano, materiais, fonte de energia, serviços e sinais de controle.
- Mostrar pelo menos uma pista de escala e uma evidência de uso/manutenção. Fundo não deve virar catálogo de letreiros aleatórios.
- Ao criar vistas de mapa/ambiente, preservar geografia já aprovada; pedir mapa de referência se continuidade espacial for crítica.

### 5.4 Props, armas, veículos e equipamento

- Começar pelo usuário, tarefa, restrições, material, manutenção e segurança; depois criar forma/silhueta e detalhes.
- Mostrar pontos de empunhadura, acesso, montagem e desgaste de maneira funcional. Se proporções exatas importarem, usar desenho técnico/model sheet, não geração livre.
- Evitar imitar designs reconhecíveis de franquias ou produtos reais quando a intenção for criar IP própria.

### 5.5 Tela de UI ou HUD

- Usar wireframe ou descrição textual para fixar hierarquia e conteúdo; gerar arte de fundo/skin separadamente da interface textual quando precisão for importante.
- Renderizar texto e ícones reais no motor/UI, não confiar em letras da imagem generativa.
- Entregar estados: normal, foco/selecionado, pressionado, carregando, concluído, erro, desabilitado; variantes claro/escuro e escala/resolução se aplicável.

### 5.6 Peça diegética/editorial

Anúncio, aviso, notícia, ficha, mapa, recibo, relatório ou interface pública deve responder: quem publicou, para quem, onde aparece, que ação deseja, que viés possui e que sinais físicos/digitais indicam autenticidade. Texto ficcional precisa ser fornecido ou revisado por autor; não permitir gibberish como copy final.

## 6. Protocolo de prompts para Gemini e Nano Banana

### 6.1 Ordem obrigatória do prompt

Sempre escrever o prompt nesta sequência, preenchendo o que se aplica:

1. **Tarefa:** criar/editar/variar; tipo de artefato e finalidade.
2. **Cânone e contexto:** nome do projeto, local, época, facção/personagem aprovada; não inventar dados ausentes.
3. **Sujeito e ação:** quem/o quê, pose/estado e interação.
4. **Composição:** plano, ângulo, ponto focal, distribuição, perspectiva, espaço reservado para texto.
5. **Direção de arte:** pilares, paleta/tokens, material, atmosfera, luz e nível de detalhe.
6. **Requisitos de produto:** proporção/resolução, safe area, leitura em miniatura, layout, estados de UI ou consistência entre vistas.
7. **Texto:** usar exatamente o texto fornecido entre aspas; indicar idioma e posicionamento. Se nenhum texto: “sem letras, sem logotipo, sem pseudo-texto”.
8. **Restrições:** elementos que não podem surgir, IP/branding alheio a evitar, elementos fixos que devem permanecer.
9. **Critérios de sucesso:** três a seis verificações objetivas.
10. **Saída:** número de imagens/variantes, formato, fundo/transparência e entrega.

### 6.2 Modelo de prompt preenchível

```text
TAREFA: [criar / editar / gerar variações de] [tipo de artefato] para [uso/canal].
PROJETO: [nome]; contexto aprovado: [fatos do cânone]. Se um dado não estiver indicado, não invente lore; use [placeholder] ou mantenha neutro.
SUJEITO/AÇÃO: [descrição específica e observável].
COMPOSIÇÃO: [proporção], [plano/ângulo], ponto focal em [posição], [primeiro plano/plano médio/fundo], reservar [área] para [copy/UI]. Silhueta e hierarquia legíveis em thumbnail.
DIREÇÃO: ficção urbana futurista vivida; [materiais], [clima], luz principal [fonte/direção], paleta [tokens], acento em [cor e função]. Detalhe concentrado no foco; fundo subordinado.
REQUISITOS: [resolução], safe area [margens], [plataforma], [estado/variante], coerência com [referência aprovada].
TEXTO: [texto exato e posição] / ou “sem texto legível, sem letras, sem logotipo, sem pseudo-texto”.
EVITAR: [lista de exclusões]. Não copiar personagens, marcas, layouts ou ilustrações de obras existentes.
SUCESSO: 1) [critério]; 2) [critério]; 3) [critério]; 4) [critério].
SAÍDA: [quantidade], [formato/fundo], [variações solicitadas].
```

### 6.3 Edição usando imagem de referência

Separar explicitamente **o que fica**, **o que muda** e **o que deve ser preservado**. Exemplo de instrução: “Preserve enquadramento, identidade do personagem, pose e leitura de luz. Altere somente [item]. Não mude roupa, expressão, escala, perspectiva, cenário ou paleta fora da alteração pedida.” Para múltiplas referências, nomear como `REF-A`, `REF-B`; atribuir a cada uma uma função (“REF-A: composição”; “REF-B: material”). Não pedir combinação total sem indicar prioridade.

### 6.4 Prompt negativo / guardrails

Usar exclusões específicas ao problema, sem uma lista genérica interminável:

- sem logotipo ou nome de franquia existente;
- sem texto ilegível ou pseudo-escrita quando a peça precisa de copy limpa;
- sem duplicação de membro, objeto flutuante, perspectiva impossível ou equipamento sem ponto de apoio;
- sem glow cobrindo bordas/silhueta, sem excesso de bloom, lens flare ou glitch;
- sem elementos de HUD sobrepostos se a solicitação for arte de fundo;
- sem mudança no rosto/roupa/composição quando se pede edição localizada;
- sem símbolos políticos, religiosos, gangues ou marcas não aprovadas pelo cânone;
- sem violência gráfica se não houver pedido e classificação apropriada.

## 7. Continuidade e gestão de assets

- Manter uma **bíblia visual** versionada com fichas de personagens, facções, locais, tokens, tipografia licenciada, ícones e regras de nomenclatura.
- Uma referência aprovada deve ter ID, versão, uso permitido e detalhes imutáveis. Ex.: `CHAR-014_v03_front-approved`.
- Ao derivar uma imagem, registrar prompt, modelo/ferramenta, data, imagem de referência, edição solicitada e decisão humana. Não tratar saída generativa como canon até aprovação.
- Para personagem, fixar ficha visual: silhueta, proporções, rosto/cabelo, roupa por camada, materiais, itens, paleta, marcas distintivas e itens proibidos. Gerar turnaround/model sheet antes de cenas complexas.
- Para UI, manter fonte de verdade em componentes/tokens do projeto; imagens geradas são referência ou textura e não especificação de comportamento.
- Arquivos: `[categoria]_[id]_[descritor]_[aspecto ou estado]_vNN`. Evitar “final_final2”. Usar datas ISO quando a equipe precisar de rastreabilidade.

## 8. Revisão e aprovação

Dar nota de 0 a 2 em cada critério: 0 falha; 1 precisa de ajuste; 2 aprovado. Rejeitar ou iterar qualquer peça que receba 0 em legibilidade, cânone ou segurança de uso.

| Critério | Pergunta de revisão |
|---|---|
| Brief | A peça cumpre a finalidade e o canal definidos? |
| Hierarquia | O foco e a ação/informação principal são percebidos primeiro? |
| Legibilidade | Funciona no tamanho final, em escala reduzida e sobre o fundo previsto? |
| Mundo | Materiais, sinais e tecnologia pertencem ao lugar e à instituição? |
| Coerência | Personagem, mapa, facção, paleta e estados respeitam assets aprovados? |
| Usabilidade | A ação, consequência, estado e retorno são claros? |
| Acessibilidade | Há redundância além de cor/animação? Contraste e escala foram verificados? |
| Originalidade | A identidade é própria e evita cópia reconhecível de IP externa? |
| Acabamento | Há artefatos generativos, texto falso, anatomia/objetos impossíveis ou ruído sem função? |
| Produção | Formato, safe area, camadas, dimensões e variantes estão corretos? |

**Ajuste em ordem:** (1) corrigir briefing/cânone; (2) corrigir silhueta e composição; (3) corrigir hierarquia/legibilidade; (4) corrigir material e luz; (5) adicionar detalhe; (6) exportar e registrar. Não polir microdetalhes de uma composição que ainda falha.

## 9. Checklist antes de entregar

- [ ] Tipo de artefato, finalidade, usuário, plataforma e proporção estão declarados.
- [ ] Cânone vem de fonte aprovada; dúvidas estão marcadas como placeholders.
- [ ] Hierarquia funciona em thumbnail e em escala de uso.
- [ ] Copy é exata e revisada; nenhum texto generativo falso ficou visível.
- [ ] UI mostra estados, foco e feedback necessários; dados críticos não dependem só da cor.
- [ ] Contraste, safe area, escala, recorte e variante foram conferidos.
- [ ] Luz, cor e textura reforçam o foco; nenhum efeito encobre conteúdo.
- [ ] Sem marcas, logotipos, personagens ou composição copiados de propriedade intelectual alheia.
- [ ] Arquivo e versões estão nomeados; prompt/decisões relevantes foram registrados.

## 10. Brief mínimo para novas solicitações

Antes de gerar uma peça, preencher (ou inferir somente o que for seguro):

```yaml
project: "[NOME DO JOGO]"
asset_type: "[key_art | character | environment | prop | HUD | menu | promo | diegetic]"
purpose: "[o que deve comunicar ou permitir]"
audience: "[jogador novo | jogador ativo | comunidade | imprensa etc.]"
platform: "[PC | console | mobile | social | in-game]"
canvas: "[width x height, aspect ratio]"
canon_refs: []
required_content: []
exact_copy: "[texto exato ou none]"
immutable_elements: []
exclude: []
accessibility: "[contrast, scale, motion, color needs]"
variants: []
output_format: "[PNG/SVG/layers/mockup/etc.]"
```

Se o usuário não especificar dimensões, perguntar apenas quando a escolha mudar materialmente a composição; caso contrário, propor o formato mais comum para o canal e sinalizar essa suposição no nome/brief do asset.
