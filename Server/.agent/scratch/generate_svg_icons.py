import os

images_dir = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\images"

# Template generator helper
def svg_wrap(content, stroke_color="#22d8e2", bg_gradient=("rgba(12, 18, 30, 0.95)", "rgba(18, 36, 56, 0.95)"), glow_color="#22d8e2"):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="{bg_gradient[0]}"/>
      <stop offset="100%" stop-color="{bg_gradient[1]}"/>
    </linearGradient>
    <filter id="neonGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="1.5" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
  </defs>
  <!-- Background Card com cantos chanfrados -->
  <polygon points="12,4 88,4 96,12 96,88 88,96 12,96 4,88 4,12" fill="url(#bgGrad)" stroke="{stroke_color}" stroke-width="1.8" stroke-opacity="0.85"/>
  <!-- Cantoneiras Cibernéticas (L-Brackets) -->
  <path d="M 8 16 L 8 8 L 16 8" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <path d="M 92 16 L 92 8 L 84 8" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <path d="M 8 84 L 8 92 L 16 92" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <path d="M 92 84 L 92 92 L 84 92" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <!-- Conteúdo Principal do Ícone -->
  {content}
</svg>'''

svgs = {}

# ==============================================================================
# VESTUÁRIO (CLOTHING)
# ==============================================================================

# 1. Capacete Balístico / Biker
svgs["clothing_head_helmet.svg"] = svg_wrap('''
  <!-- Capacete Tático / Integral -->
  <path d="M 28 42 C 28 24, 72 24, 72 42 C 72 58, 68 76, 50 78 C 32 76, 28 58, 28 42 Z" fill="#142232" stroke="#22d8e2" stroke-width="2.2"/>
  <!-- Visor Frontal Kiroshi -->
  <path d="M 32 38 L 68 38 L 64 54 L 36 54 Z" fill="#00e5ff" fill-opacity="0.35" stroke="#00e5ff" stroke-width="2"/>
  <line x1="36" y1="46" x2="64" y2="46" stroke="#fcee0a" stroke-width="1.5" stroke-dasharray="3,2"/>
  <!-- Placas de Ventilação e Blindagem -->
  <line x1="42" y1="62" x2="58" y2="62" stroke="#22d8e2" stroke-width="2"/>
  <line x1="45" y1="68" x2="55" y2="68" stroke="#22d8e2" stroke-width="2"/>
  <circle cx="28" cy="48" r="3" fill="#22d8e2"/>
  <circle cx="72" cy="48" r="3" fill="#22d8e2"/>
''', stroke_color="#22d8e2")

# 2. Chapéu / Boné / Boina
svgs["clothing_head_hat.svg"] = svg_wrap('''
  <!-- Copa do Chapéu / Boné -->
  <path d="M 32 48 C 32 32, 68 32, 68 48 Z" fill="#182638" stroke="#fcee0a" stroke-width="2"/>
  <!-- Aba Curvada -->
  <path d="M 18 52 C 30 46, 70 46, 82 52 C 86 54, 78 60, 50 60 C 22 60, 14 54, 18 52 Z" fill="#122030" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Faixa de Detalhe com Logo -->
  <path d="M 32 46 Q 50 42 68 46" fill="none" stroke="#22d8e2" stroke-width="2"/>
  <circle cx="50" cy="40" r="3" fill="#ff003c"/>
''', stroke_color="#fcee0a")

# 3. Máscara / Balaclava / Capuz
svgs["clothing_head_mask.svg"] = svg_wrap('''
  <!-- Capuz / Balaclava Facial -->
  <path d="M 28 32 C 28 18, 72 18, 72 32 C 72 55, 68 76, 50 82 C 32 76, 28 55, 28 32 Z" fill="#101c2a" stroke="#05ffa1" stroke-width="2"/>
  <!-- Abertura dos Olhos -->
  <ellipse cx="50" cy="38" rx="16" ry="6" fill="#060c14" stroke="#05ffa1" stroke-width="1.8"/>
  <circle cx="44" cy="38" r="2.5" fill="#00e5ff"/>
  <circle cx="56" cy="38" r="2.5" fill="#00e5ff"/>
  <!-- Malha Tática Filtrante na Boca -->
  <path d="M 40 56 L 60 56 L 56 68 L 44 68 Z" fill="#162636" stroke="#05ffa1" stroke-width="1.5"/>
  <line x1="43" y1="62" x2="57" y2="62" stroke="#05ffa1" stroke-width="1.2" stroke-dasharray="2,2"/>
''', stroke_color="#05ffa1")

# 4. Óculos de Sol / Aviador / Shades
svgs["clothing_face_glasses.svg"] = svg_wrap('''
  <!-- Ponteira Central -->
  <line x1="45" y1="42" x2="55" y2="42" stroke="#fcee0a" stroke-width="2.5"/>
  <line x1="43" y1="38" x2="57" y2="38" stroke="#fcee0a" stroke-width="1.5"/>
  <!-- Lente Esquerda -->
  <path d="M 22 40 L 45 40 C 45 56, 32 62, 22 56 Z" fill="#ff003c" fill-opacity="0.4" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Lente Direita -->
  <path d="M 55 40 L 78 40 C 78 56, 68 62, 55 56 Z" fill="#ff003c" fill-opacity="0.4" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Hastes Laterais -->
  <line x1="22" y1="41" x2="14" y2="36" stroke="#fcee0a" stroke-width="2"/>
  <line x1="78" y1="41" x2="86" y2="36" stroke="#fcee0a" stroke-width="2"/>
  <!-- Brilho de Reflexo -->
  <line x1="26" y1="44" x2="32" y2="52" stroke="#ffffff" stroke-width="1.5" stroke-opacity="0.7"/>
  <line x1="59" y1="44" x2="65" y2="52" stroke="#ffffff" stroke-width="1.5" stroke-opacity="0.7"/>
''', stroke_color="#fcee0a")

# 5. Visor Holográfico Kiroshi / Monóculo
svgs["clothing_face_visor.svg"] = svg_wrap('''
  <!-- Estrutura do Visor Tech -->
  <path d="M 18 42 L 82 42 L 76 56 L 24 56 Z" fill="#00e5ff" fill-opacity="0.3" stroke="#00e5ff" stroke-width="2.2"/>
  <!-- Sensores e HUD interno -->
  <line x1="26" y1="49" x2="74" y2="49" stroke="#fcee0a" stroke-width="1.5" stroke-dasharray="4,3"/>
  <circle cx="34" cy="49" r="3" fill="#ff003c"/>
  <circle cx="66" cy="49" r="3" fill="#ff003c"/>
  <!-- Armação Lateral Cibernética -->
  <rect x="14" y="38" width="8" height="20" rx="2" fill="#182c40" stroke="#00e5ff" stroke-width="1.8"/>
  <rect x="78" y="38" width="8" height="20" rx="2" fill="#182c40" stroke="#00e5ff" stroke-width="1.8"/>
  <line x1="16" y1="44" x2="16" y2="52" stroke="#fcee0a" stroke-width="2"/>
''', stroke_color="#00e5ff")

# 6. Máscara de Gás / Respirador Maelstrom
svgs["clothing_face_gasmask.svg"] = svg_wrap('''
  <!-- Corpo da Máscara -->
  <path d="M 32 30 C 32 24, 68 24, 68 30 L 74 62 L 50 78 L 26 62 Z" fill="#121e2a" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Lentes Oculares Circulares Vermelhas -->
  <circle cx="38" cy="38" r="7" fill="#ff003c" fill-opacity="0.5" stroke="#ff003c" stroke-width="2"/>
  <circle cx="62" cy="38" r="7" fill="#ff003c" fill-opacity="0.5" stroke="#ff003c" stroke-width="2"/>
  <!-- Filtro Respirador Duplo Frontal -->
  <circle cx="50" cy="62" r="11" fill="#1c2c3c" stroke="#fcee0a" stroke-width="2"/>
  <circle cx="50" cy="62" r="6" fill="#101822" stroke="#fcee0a" stroke-width="1.5"/>
  <line x1="50" y1="53" x2="50" y2="71" stroke="#fcee0a" stroke-width="1.5"/>
  <line x1="41" y1="62" x2="59" y2="62" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#ff003c")

# 7. Jaqueta Bomber / Samurai / Edgerunner
svgs["clothing_outer_jacket.svg"] = svg_wrap('''
  <!-- Silhueta da Jaqueta -->
  <path d="M 36 24 L 20 38 L 26 74 L 38 72 L 38 78 L 62 78 L 62 72 L 74 74 L 80 38 L 64 24 Z" fill="#162436" stroke="#22d8e2" stroke-width="2.2"/>
  <!-- Gola Alta Samurai -->
  <path d="M 36 24 L 50 36 L 64 24" fill="none" stroke="#fcee0a" stroke-width="2.5"/>
  <!-- Zíper Frontal com Destaque -->
  <line x1="50" y1="36" x2="50" y2="78" stroke="#22d8e2" stroke-width="2"/>
  <!-- Faixas Neon nos Ombros/Mangas -->
  <line x1="23" y1="46" x2="34" y2="43" stroke="#fcee0a" stroke-width="2"/>
  <line x1="77" y1="46" x2="66" y2="43" stroke="#fcee0a" stroke-width="2"/>
  <!-- Insígnia no Peito -->
  <circle cx="43" cy="46" r="3" fill="#ff003c"/>
''', stroke_color="#22d8e2")

# 8. Sobretudo / Parka
svgs["clothing_outer_coat.svg"] = svg_wrap('''
  <!-- Sobretudo Longo Executivo Arasaka -->
  <path d="M 38 22 L 22 36 L 26 84 L 40 82 L 40 86 L 60 86 L 60 82 L 74 84 L 78 36 L 62 22 Z" fill="#101824" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Lapelas Largas -->
  <path d="M 38 22 L 48 48 L 38 60" fill="none" stroke="#22d8e2" stroke-width="2"/>
  <path d="M 62 22 L 52 48 L 62 60" fill="none" stroke="#22d8e2" stroke-width="2"/>
  <!-- Linha Central de Fechamento -->
  <line x1="50" y1="48" x2="50" y2="86" stroke="#ff003c" stroke-width="2"/>
  <!-- Cinto / Fivela Central -->
  <rect x="44" y="56" width="12" height="6" fill="#1c2c3c" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#ff003c")

# 9. Colete Balístico / Tático / Arnês
svgs["clothing_outer_vest.svg"] = svg_wrap('''
  <!-- Colete Balístico Tático com Placas -->
  <path d="M 34 26 L 24 38 L 26 74 L 74 74 L 76 38 L 66 26 L 56 34 L 44 34 Z" fill="#14202e" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Placas de Armadura no Peito -->
  <rect x="32" y="40" width="36" height="14" rx="2" fill="#1a2e42" stroke="#22d8e2" stroke-width="1.8"/>
  <text x="50" y="51" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="8" font-weight="bold">TRAUMA</text>
  <!-- Bolsos MOLLE Inferiores -->
  <rect x="30" y="58" width="11" height="12" fill="#182636" stroke="#fcee0a" stroke-width="1.5"/>
  <rect x="44.5" y="58" width="11" height="12" fill="#182636" stroke="#fcee0a" stroke-width="1.5"/>
  <rect x="59" y="58" width="11" height="12" fill="#182636" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#fcee0a")

# 10. Camisa / Camiseta / Macacão
svgs["clothing_inner_shirt.svg"] = svg_wrap('''
  <!-- Camiseta / Top Streetwear -->
  <path d="M 36 26 L 22 36 L 30 48 L 36 44 L 36 76 L 64 76 L 64 44 L 70 48 L 78 36 L 64 26 C 60 32, 40 32, 36 26 Z" fill="#162638" stroke="#05ffa1" stroke-width="2.2"/>
  <!-- Estampa / Logo Lizzie -->
  <polygon points="50,38 56,48 44,48" fill="#ff003c"/>
  <circle cx="50" cy="54" r="5" fill="none" stroke="#fcee0a" stroke-width="1.5"/>
  <!-- Costuras de Ajuste -->
  <line x1="40" y1="46" x2="40" y2="76" stroke="#05ffa1" stroke-width="1.2" stroke-dasharray="3,2"/>
  <line x1="60" y1="46" x2="60" y2="76" stroke="#05ffa1" stroke-width="1.2" stroke-dasharray="3,2"/>
''', stroke_color="#05ffa1")

# 11. Moletom com Capuz (Hoodie)
svgs["clothing_inner_hoodie.svg"] = svg_wrap('''
  <!-- Moletom Streetwear com Capuz -->
  <path d="M 36 28 L 18 40 L 26 52 L 34 46 L 34 76 L 66 76 L 66 46 L 74 52 L 82 40 L 64 28 Z" fill="#142232" stroke="#22d8e2" stroke-width="2.2"/>
  <!-- Capuz Traseiro Sobreposto -->
  <path d="M 36 28 C 36 18, 64 18, 64 28 C 60 36, 40 36, 36 28 Z" fill="#101a26" stroke="#22d8e2" stroke-width="2"/>
  <!-- Bolso Canguru Frontal -->
  <path d="M 40 58 L 60 58 L 64 70 L 36 70 Z" fill="#182c3e" stroke="#fcee0a" stroke-width="1.8"/>
  <line x1="46" y1="36" x2="46" y2="48" stroke="#fcee0a" stroke-width="1.5"/>
  <line x1="54" y1="36" x2="54" y2="48" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#22d8e2")

# 12. Calças de Combate / Cargo / Jeans
svgs["clothing_legs_pants.svg"] = svg_wrap('''
  <!-- Calça Cargo Militar com Bolsos -->
  <path d="M 32 24 L 68 24 L 66 80 L 53 80 L 50 44 L 47 80 L 34 80 Z" fill="#142232" stroke="#22d8e2" stroke-width="2.2"/>
  <!-- Cós / Cinto Tático -->
  <rect x="32" y="24" width="36" height="6" fill="#1a2e42" stroke="#fcee0a" stroke-width="1.8"/>
  <!-- Bolsos Cargo Laterais -->
  <rect x="28" y="42" width="8" height="14" rx="2" fill="#1a2e40" stroke="#22d8e2" stroke-width="1.5"/>
  <rect x="64" y="42" width="8" height="14" rx="2" fill="#1a2e40" stroke="#22d8e2" stroke-width="1.5"/>
  <!-- Reforço Acolchoado nos Joelhos -->
  <rect x="36" y="56" width="9" height="8" rx="2" fill="#182a3c" stroke="#fcee0a" stroke-width="1.5"/>
  <rect x="55" y="56" width="9" height="8" rx="2" fill="#182a3c" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#22d8e2")

# 13. Shorts / Bermudas
svgs["clothing_legs_shorts.svg"] = svg_wrap('''
  <!-- Shorts Esportivo / Streetwear -->
  <path d="M 32 28 L 68 28 L 67 56 L 54 56 L 50 40 L 46 56 L 33 56 Z" fill="#162638" stroke="#05ffa1" stroke-width="2.2"/>
  <!-- Faixa Elástica de Cintura -->
  <rect x="32" y="28" width="36" height="6" fill="#1a2e44" stroke="#05ffa1" stroke-width="1.8"/>
  <!-- Linhas Esportivas Neon Laterais -->
  <line x1="36" y1="36" x2="36" y2="54" stroke="#fcee0a" stroke-width="2"/>
  <line x1="64" y1="36" x2="64" y2="54" stroke="#fcee0a" stroke-width="2"/>
''', stroke_color="#05ffa1")

# 14. Botas Militares / Biker / Exo
svgs["clothing_feet_boots.svg"] = svg_wrap('''
  <!-- Par de Botas de Combate de Cano Alto -->
  <!-- Bota Esquerda -->
  <path d="M 28 26 L 40 26 L 40 64 L 46 64 L 48 76 L 22 76 L 22 66 L 28 64 Z" fill="#14202e" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Bota Direita -->
  <path d="M 60 26 L 72 26 L 72 64 L 78 64 L 80 76 L 54 76 L 54 66 L 60 64 Z" fill="#14202e" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Solados Reforçados Tratorados -->
  <line x1="22" y1="73" x2="48" y2="73" stroke="#ff003c" stroke-width="2"/>
  <line x1="54" y1="73" x2="80" y2="73" stroke="#ff003c" stroke-width="2"/>
  <!-- Fivelas Táticas Metálicas -->
  <line x1="28" y1="36" x2="40" y2="36" stroke="#22d8e2" stroke-width="2"/>
  <line x1="28" y1="46" x2="40" y2="46" stroke="#22d8e2" stroke-width="2"/>
  <line x1="60" y1="36" x2="72" y2="36" stroke="#22d8e2" stroke-width="2"/>
  <line x1="60" y1="46" x2="72" y2="46" stroke="#22d8e2" stroke-width="2"/>
''', stroke_color="#fcee0a")

# 15. Tênis Streetwear / Sapatos Sociais
svgs["clothing_feet_shoes.svg"] = svg_wrap('''
  <!-- Par de Tênis Futuristas / Sneakers NC -->
  <!-- Tênis Esquerdo -->
  <path d="M 26 44 L 38 44 L 36 62 L 48 64 L 48 74 L 16 74 L 18 64 L 26 62 Z" fill="#18283c" stroke="#00e5ff" stroke-width="2.2"/>
  <!-- Tênis Direito -->
  <path d="M 62 44 L 74 44 L 72 62 L 84 64 L 84 74 L 52 74 L 54 64 L 62 62 Z" fill="#18283c" stroke="#00e5ff" stroke-width="2.2"/>
  <!-- Detalhe Neon de Amortecimento -->
  <path d="M 16 71 L 48 71" stroke="#fcee0a" stroke-width="2.5"/>
  <path d="M 52 71 L 84 71" stroke="#fcee0a" stroke-width="2.5"/>
  <line x1="28" y1="52" x2="36" y2="52" stroke="#00e5ff" stroke-width="1.8"/>
  <line x1="64" y1="52" x2="72" y2="52" stroke="#00e5ff" stroke-width="1.8"/>
''', stroke_color="#00e5ff")

# ==============================================================================
# MISCELÂNEA, COLECIONÁVEIS & RARIDADES
# ==============================================================================

# 16. Carta de Tarô de Night City
svgs["tarot_card.svg"] = svg_wrap('''
  <!-- Carta Retangular de Tarô com Borda Mística -->
  <rect x="28" y="16" width="44" height="68" rx="4" fill="#101826" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Moldura Interna Dourada -->
  <rect x="32" y="20" width="36" height="60" rx="2" fill="none" stroke="#22d8e2" stroke-width="1.2" stroke-dasharray="3,2"/>
  <!-- Símbolo Místico / Sol / Runa Central -->
  <circle cx="50" cy="50" r="12" fill="#182436" stroke="#fcee0a" stroke-width="2"/>
  <polygon points="50,32 54,42 64,46 56,52 58,62 50,56 42,62 44,52 36,46 46,42" fill="#fcee0a" fill-opacity="0.35"/>
  <circle cx="50" cy="50" r="4" fill="#ff003c"/>
''', stroke_color="#fcee0a")

# 17. Disco de Vinil da Banda Samurai
svgs["vinyl_record.svg"] = svg_wrap('''
  <!-- Disco de Vinil Preto com Ranhuras -->
  <circle cx="50" cy="50" r="34" fill="#080c14" stroke="#ff003c" stroke-width="2.2"/>
  <circle cx="50" cy="50" r="28" fill="none" stroke="#1c2838" stroke-width="1.5"/>
  <circle cx="50" cy="50" r="22" fill="none" stroke="#1c2838" stroke-width="1.5"/>
  <!-- Rótulo Central Samurai Vermelho -->
  <circle cx="50" cy="50" r="14" fill="#ff003c" stroke="#fcee0a" stroke-width="1.8"/>
  <circle cx="50" cy="50" r="3.5" fill="#080c14" stroke="#fcee0a" stroke-width="1.2"/>
  <text x="50" y="47" text-anchor="middle" fill="#ffffff" font-family="monospace" font-size="6" font-weight="bold">SAMURAI</text>
''', stroke_color="#ff003c")

# 18. Relógio Suíço Analógico Vintage
svgs["vintage_watch.svg"] = svg_wrap('''
  <!-- Pulseira de Couro -->
  <rect x="42" y="14" width="16" height="72" rx="3" fill="#1a2636" stroke="#fcee0a" stroke-width="1.5"/>
  <!-- Caixa Redonda de Ouro -->
  <circle cx="50" cy="50" r="22" fill="#0c1624" stroke="#fcee0a" stroke-width="2.5"/>
  <!-- Mostrador e Ponteiros de Safira -->
  <circle cx="50" cy="50" r="18" fill="none" stroke="#22d8e2" stroke-width="1"/>
  <line x1="50" y1="50" x2="50" y2="36" stroke="#22d8e2" stroke-width="2"/>
  <line x1="50" y1="50" x2="60" y2="50" stroke="#fcee0a" stroke-width="2"/>
  <circle cx="50" cy="50" r="2.5" fill="#ff003c"/>
  <!-- Coroa de Ajuste -->
  <rect x="72" y="47" width="4" height="6" fill="#fcee0a"/>
''', stroke_color="#fcee0a")

# 19. Ursinho de Pelúcia Desgastado
svgs["teddy_bear.svg"] = svg_wrap('''
  <!-- Orelhas -->
  <circle cx="34" cy="30" r="8" fill="#1a2432" stroke="#22d8e2" stroke-width="2"/>
  <circle cx="66" cy="30" r="8" fill="#1a2432" stroke="#22d8e2" stroke-width="2"/>
  <!-- Cabeça -->
  <circle cx="50" cy="42" r="18" fill="#16202e" stroke="#22d8e2" stroke-width="2.2"/>
  <!-- Olho de Botão e Olho Normal -->
  <circle cx="42" cy="38" r="3" fill="#fcee0a"/>
  <!-- Olho com Costura em X -->
  <line x1="56" y1="36" x2="60" y2="40" stroke="#ff003c" stroke-width="1.8"/>
  <line x1="60" y1="36" x2="56" y2="40" stroke="#ff003c" stroke-width="1.8"/>
  <!-- Focinho com Ponto de Sutura -->
  <ellipse cx="50" cy="46" rx="6" ry="4" fill="#203042" stroke="#22d8e2" stroke-width="1.2"/>
  <circle cx="50" cy="45" r="2" fill="#080c14"/>
  <!-- Corpo com Remendo -->
  <path d="M 36 58 C 36 58, 24 78, 50 78 C 76 78, 64 58, 64 58 Z" fill="#141e2a" stroke="#22d8e2" stroke-width="2"/>
  <rect x="44" y="62" width="8" height="8" fill="#22364c" stroke="#fcee0a" stroke-width="1.2" stroke-dasharray="2,2"/>
''', stroke_color="#22d8e2")

# 20. Isqueiro Zippo Vintage
svgs["lighter.svg"] = svg_wrap('''
  <!-- Tampa Aberta em Ângulo -->
  <path d="M 34 32 L 20 22 L 32 10 L 46 20 Z" fill="#162436" stroke="#22d8e2" stroke-width="2"/>
  <!-- Pavio com Chama Neon -->
  <polygon points="46,16 50,4 54,16 50,22" fill="#ff7700" stroke="#fcee0a" stroke-width="1.5"/>
  <circle cx="50" cy="12" r="3" fill="#fcee0a"/>
  <!-- Roda de Fricção -->
  <circle cx="42" cy="28" r="4" fill="#22d8e2" stroke="#ffffff" stroke-width="1"/>
  <!-- Corpo Retangular Prateado do Isqueiro -->
  <rect x="36" y="32" width="28" height="48" rx="3" fill="#14202e" stroke="#22d8e2" stroke-width="2.2"/>
  <!-- Gravação Decorativa no Metal -->
  <line x1="42" y1="42" x2="58" y2="42" stroke="#fcee0a" stroke-width="1.5"/>
  <line x1="42" y1="50" x2="58" y2="50" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#22d8e2")

# 21. Maço de Cigarros Amassado
svgs["cigarettes.svg"] = svg_wrap('''
  <!-- Maço de Cigarros Retangular -->
  <rect x="32" y="30" width="36" height="52" rx="3" fill="#162434" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Cigarro Saliente com Ponta Acesa -->
  <rect x="46" y="16" width="6" height="20" fill="#f0ede6" stroke="#22d8e2" stroke-width="1.2"/>
  <rect x="46" y="14" width="6" height="4" fill="#ff7700"/>
  <!-- Grafismo / Logo do Maço (Cyberpunk Brand) -->
  <rect x="36" y="40" width="28" height="18" fill="#ff003c" fill-opacity="0.3" stroke="#fcee0a" stroke-width="1.5"/>
  <text x="50" y="52" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="7" font-weight="bold">BLACK LACE</text>
''', stroke_color="#ff003c")

# 22. Dados de Cromo (Cassino)
svgs["chrome_dice.svg"] = svg_wrap('''
  <!-- Dado 1 em Perspectiva Isométrica -->
  <polygon points="34,22 54,12 54,34 34,44" fill="#182c40" stroke="#00e5ff" stroke-width="2"/>
  <polygon points="54,12 74,22 74,44 54,34" fill="#102030" stroke="#00e5ff" stroke-width="2"/>
  <polygon points="34,44 54,34 74,44 54,54" fill="#203a54" stroke="#00e5ff" stroke-width="2"/>
  <!-- Pontos do Dado 1 (Neon) -->
  <circle cx="44" cy="28" r="2.5" fill="#fcee0a"/>
  <circle cx="64" cy="28" r="2.5" fill="#fcee0a"/>
  <circle cx="54" cy="44" r="2.5" fill="#fcee0a"/>
  <!-- Dado 2 Sobreposto -->
  <polygon points="22,54 40,46 40,66 22,74" fill="#182c40" stroke="#ff003c" stroke-width="2"/>
  <polygon points="40,46 58,54 58,74 40,66" fill="#102030" stroke="#ff003c" stroke-width="2"/>
  <polygon points="22,74 40,66 58,74 40,82" fill="#203a54" stroke="#ff003c" stroke-width="2"/>
  <circle cx="31" cy="60" r="2.5" fill="#fcee0a"/>
  <circle cx="49" cy="60" r="2.5" fill="#fcee0a"/>
''', stroke_color="#00e5ff")

# 23. Jóia: Anel com Diamante
svgs["jewelry_ring.svg"] = svg_wrap('''
  <!-- Aro do Anel em Platina -->
  <circle cx="50" cy="56" r="22" fill="none" stroke="#22d8e2" stroke-width="4"/>
  <circle cx="50" cy="56" r="18" fill="none" stroke="#ffffff" stroke-width="1.2" stroke-opacity="0.8"/>
  <!-- Diamante Lapidado Superior com Brilho -->
  <polygon points="50,22 62,34 50,42 38,34" fill="#00e5ff" fill-opacity="0.6" stroke="#fcee0a" stroke-width="2"/>
  <line x1="38" y1="34" x2="62" y2="34" stroke="#ffffff" stroke-width="1.5"/>
  <line x1="50" y1="22" x2="50" y2="42" stroke="#ffffff" stroke-width="1.5"/>
''', stroke_color="#22d8e2")

# 24. Jóia: Corrente de Ouro 18k
svgs["jewelry_necklace.svg"] = svg_wrap('''
  <!-- Elo Principal da Corrente Pesada -->
  <path d="M 24 30 C 24 64, 76 64, 76 30" fill="none" stroke="#fcee0a" stroke-width="4.5" stroke-dasharray="6,3"/>
  <path d="M 28 30 C 28 58, 72 58, 72 30" fill="none" stroke="#ffd700" stroke-width="2"/>
  <!-- Pingente de Dólar / Emblema Heywood -->
  <circle cx="50" cy="64" r="10" fill="#182638" stroke="#fcee0a" stroke-width="2"/>
  <text x="50" y="69" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="12" font-weight="bold">E$</text>
''', stroke_color="#fcee0a")

# 25. Plaquetas de Identificação Militar (Dog Tags)
svgs["military_dog_tags.svg"] = svg_wrap('''
  <!-- Corrente de Bolinhas -->
  <path d="M 34 20 Q 50 12 66 20" fill="none" stroke="#22d8e2" stroke-width="2" stroke-dasharray="3,2"/>
  <!-- Plaqueta 1 -->
  <rect x="32" y="24" width="22" height="36" rx="6" fill="#142232" stroke="#22d8e2" stroke-width="2"/>
  <circle cx="43" cy="29" r="2" fill="#00e5ff"/>
  <line x1="36" y1="36" x2="50" y2="36" stroke="#22d8e2" stroke-width="1.5"/>
  <line x1="36" y1="42" x2="50" y2="42" stroke="#22d8e2" stroke-width="1.5"/>
  <line x1="36" y1="48" x2="46" y2="48" stroke="#22d8e2" stroke-width="1.5"/>
  <!-- Plaqueta 2 Inclinada Atrás -->
  <rect x="46" y="34" width="22" height="36" rx="6" fill="#101a26" stroke="#fcee0a" stroke-width="2"/>
  <circle cx="57" cy="39" r="2" fill="#fcee0a"/>
  <line x1="50" y1="46" x2="64" y2="46" stroke="#fcee0a" stroke-width="1.5"/>
  <line x1="50" y1="52" x2="64" y2="52" stroke="#fcee0a" stroke-width="1.5"/>
''', stroke_color="#22d8e2")

# 26. Broche / Patch de Gangue
svgs["gang_patch.svg"] = svg_wrap('''
  <!-- Brasão Hexagonal de Gangue -->
  <polygon points="50,18 78,32 78,68 50,82 22,68 22,32" fill="#14202e" stroke="#ff003c" stroke-width="2.5"/>
  <!-- Símbolo de Caveira / Facção -->
  <circle cx="50" cy="46" r="14" fill="#1c2838" stroke="#fcee0a" stroke-width="2"/>
  <!-- Olhos da Caveira -->
  <ellipse cx="45" cy="44" rx="3.5" ry="4.5" fill="#ff003c"/>
  <ellipse cx="55" cy="44" rx="3.5" ry="4.5" fill="#ff003c"/>
  <polygon points="50,50 52,54 48,54" fill="#fcee0a"/>
  <!-- Dentes da Caveira -->
  <line x1="44" y1="58" x2="44" y2="62" stroke="#fcee0a" stroke-width="1.8"/>
  <line x1="50" y1="58" x2="50" y2="62" stroke="#fcee0a" stroke-width="1.8"/>
  <line x1="56" y1="58" x2="56" y2="62" stroke="#fcee0a" stroke-width="1.8"/>
''', stroke_color="#ff003c")

# 27. CredChip / Cartão Financeiro
svgs["credchip.svg"] = svg_wrap('''
  <!-- Cartão CredChip Retangular -->
  <rect x="22" y="28" width="56" height="44" rx="4" fill="#0e1826" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Chip Dourado de Contato -->
  <rect x="30" y="38" width="16" height="14" rx="2" fill="#fcee0a" fill-opacity="0.8" stroke="#ffd700" stroke-width="1.5"/>
  <line x1="38" y1="38" x2="38" y2="52" stroke="#0e1826" stroke-width="1.2"/>
  <line x1="30" y1="45" x2="46" y2="45" stroke="#0e1826" stroke-width="1.2"/>
  <!-- Faixa Magnética Holográfica -->
  <line x1="52" y1="40" x2="72" y2="40" stroke="#00e5ff" stroke-width="2"/>
  <line x1="52" y1="46" x2="68" y2="46" stroke="#00e5ff" stroke-width="2"/>
  <text x="68" y="64" text-anchor="end" fill="#fcee0a" font-family="monospace" font-size="8" font-weight="bold">CRED // 77</text>
''', stroke_color="#fcee0a")

# ==============================================================================
# ALIMENTOS & BEBIDAS
# ==============================================================================

# 28. Cerveja (Garrafa / Lata)
svgs["beer_bottle.svg"] = svg_wrap('''
  <!-- Garrafa de Cerveja Broseph / Arasaka -->
  <path d="M 46 16 L 54 16 L 54 28 C 58 34, 62 40, 62 48 L 62 82 L 38 82 L 38 48 C 38 40, 42 34, 46 28 Z" fill="#162436" stroke="#fcee0a" stroke-width="2.2"/>
  <rect x="44" y="14" width="12" height="4" fill="#fcee0a"/>
  <!-- Rótulo Frontal da Cerveja -->
  <rect x="40" y="50" width="20" height="22" rx="2" fill="#1c2c3e" stroke="#22d8e2" stroke-width="1.5"/>
  <text x="50" y="62" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="6" font-weight="bold">BEER</text>
  <circle cx="50" cy="67" r="2.5" fill="#ff003c"/>
''', stroke_color="#fcee0a")

# 29. Destilado Fino (Garrafa de Absinto / Uísque / Tequila)
svgs["liquor_bottle.svg"] = svg_wrap('''
  <!-- Garrafa de Bebida Destilada de Luxo -->
  <path d="M 44 14 L 56 14 L 56 26 L 66 36 L 66 82 L 34 82 L 34 36 L 44 26 Z" fill="#121e2c" stroke="#22d8e2" stroke-width="2.2"/>
  <rect x="42" y="12" width="16" height="5" fill="#22d8e2"/>
  <!-- Nível do Líquido Ambar/Verde -->
  <path d="M 36 44 L 64 44 L 64 80 L 36 80 Z" fill="#00e5ff" fill-opacity="0.25"/>
  <!-- Selo e Rótulo de Luxo -->
  <rect x="38" y="50" width="24" height="24" fill="#18283a" stroke="#fcee0a" stroke-width="1.8"/>
  <text x="50" y="62" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="6" font-weight="bold">70% VOL</text>
  <line x1="42" y1="68" x2="58" y2="68" stroke="#ff003c" stroke-width="1.5"/>
''', stroke_color="#22d8e2")

# 30. Lata de Refrigerante (NiCola / Chromanticore / Spunky Monkey)
svgs["soda_can.svg"] = svg_wrap('''
  <!-- Lata Cilíndrica de Alumínio -->
  <path d="M 36 20 C 36 16, 64 16, 64 20 L 64 78 C 64 82, 36 82, 36 78 Z" fill="#182638" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Tampa com Anel de Abertura -->
  <ellipse cx="50" cy="20" rx="14" ry="4" fill="#24384c" stroke="#fcee0a" stroke-width="1.8"/>
  <circle cx="50" cy="20" r="2" fill="#ffffff"/>
  <!-- Logo Diagonal NiCola -->
  <path d="M 38 42 Q 50 36 62 46" fill="none" stroke="#22d8e2" stroke-width="3"/>
  <text x="50" y="58" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="8" font-weight="bold">SODA</text>
  <line x1="40" y1="64" x2="60" y2="64" stroke="#ff003c" stroke-width="2"/>
''', stroke_color="#ff003c")

# 31. Hambúrguer Sintético (Synth Burger)
svgs["burger.svg"] = svg_wrap('''
  <!-- Pão Superior -->
  <path d="M 24 44 C 24 24, 76 24, 76 44 Z" fill="#fcee0a" fill-opacity="0.3" stroke="#fcee0a" stroke-width="2.2"/>
  <!-- Gergelim -->
  <circle cx="42" cy="32" r="1.5" fill="#fcee0a"/>
  <circle cx="52" cy="28" r="1.5" fill="#fcee0a"/>
  <circle cx="60" cy="34" r="1.5" fill="#fcee0a"/>
  <!-- Queijo Sintético Derretido Neon -->
  <polygon points="26,44 74,44 70,52 62,48 54,54 44,48 36,54 30,48" fill="#fcee0a" stroke="#fcee0a" stroke-width="1.5"/>
  <!-- Bife de Proteína Clonada -->
  <rect x="22" y="52" width="56" height="8" rx="4" fill="#ff003c" stroke="#ff003c" stroke-width="2"/>
  <!-- Pão Inferior -->
  <path d="M 26 64 C 26 72, 74 72, 74 64 Z" fill="#fcee0a" fill-opacity="0.3" stroke="#fcee0a" stroke-width="2.2"/>
''', stroke_color="#fcee0a")

# 32. Tigela de Ramen Apimentado de Watson
svgs["ramen.svg"] = svg_wrap('''
  <!-- Tigela de Ramen Térmica -->
  <path d="M 22 42 C 22 74, 78 74, 78 42 Z" fill="#142232" stroke="#22d8e2" stroke-width="2.2"/>
  <ellipse cx="50" cy="42" rx="28" ry="8" fill="#ff7700" fill-opacity="0.4" stroke="#22d8e2" stroke-width="1.8"/>
  <!-- Hashis Atravessados -->
  <line x1="20" y1="28" x2="72" y2="44" stroke="#fcee0a" stroke-width="2"/>
  <line x1="24" y1="24" x2="76" y2="40" stroke="#fcee0a" stroke-width="2"/>
  <!-- Vapor Quente Subindo -->
  <path d="M 42 34 Q 40 24 44 16" fill="none" stroke="#22d8e2" stroke-width="1.5" stroke-dasharray="2,2"/>
  <path d="M 50 32 Q 52 22 48 14" fill="none" stroke="#22d8e2" stroke-width="1.5" stroke-dasharray="2,2"/>
  <path d="M 58 34 Q 56 24 60 16" fill="none" stroke="#22d8e2" stroke-width="1.5" stroke-dasharray="2,2"/>
''', stroke_color="#22d8e2")

# 33. Bife de Soja Sintética Prime
svgs["steak.svg"] = svg_wrap('''
  <!-- Corte de Carne Sintética -->
  <path d="M 26 44 C 26 30, 68 28, 76 40 C 82 50, 72 70, 56 72 C 40 74, 26 62, 26 44 Z" fill="#ff003c" fill-opacity="0.35" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Marcas de Grelha Térmica -->
  <line x1="36" y1="38" x2="64" y2="60" stroke="#fcee0a" stroke-width="2"/>
  <line x1="46" y1="36" x2="70" y2="54" stroke="#fcee0a" stroke-width="2"/>
  <line x1="32" y1="46" x2="56" y2="66" stroke="#fcee0a" stroke-width="2"/>
''', stroke_color="#ff003c")

# 34. Sushi Sintético
svgs["sushi.svg"] = svg_wrap('''
  <!-- Bandeja de Sushi -->
  <rect x="20" y="34" width="60" height="42" rx="3" fill="#121e2c" stroke="#05ffa1" stroke-width="2.2"/>
  <!-- Peça 1 (Nigiri) -->
  <rect x="26" y="44" width="20" height="12" rx="4" fill="#ffffff" stroke="#05ffa1" stroke-width="1.5"/>
  <rect x="26" y="42" width="20" height="6" rx="2" fill="#ff003c"/>
  <!-- Peça 2 (Maki) -->
  <circle cx="62" cy="50" r="8" fill="#101c24" stroke="#05ffa1" stroke-width="1.8"/>
  <circle cx="62" cy="50" r="4" fill="#ff7700"/>
  <!-- Wasabi Verde -->
  <circle cx="64" cy="66" r="3" fill="#05ffa1"/>
''', stroke_color="#05ffa1")

# ==============================================================================
# CIBERIMPLANTES (CYBERWARE ANATÔMICO)
# ==============================================================================

# 35. Olhos Cibernéticos Kiroshi (Óptica)
svgs["cyber_eye.svg"] = svg_wrap('''
  <!-- Globo Ocular Mecânico Kiroshi -->
  <circle cx="50" cy="50" r="28" fill="#0e1a28" stroke="#00e5ff" stroke-width="2.5"/>
  <!-- Íris Tecnológica com Marcadores de Alvo -->
  <circle cx="50" cy="50" r="16" fill="#12263a" stroke="#fcee0a" stroke-width="2"/>
  <circle cx="50" cy="50" r="8" fill="#ff003c"/>
  <circle cx="50" cy="50" r="3" fill="#ffffff"/>
  <!-- Retículo de Varredura / Mira Kiroshi -->
  <line x1="50" y1="24" x2="50" y2="30" stroke="#00e5ff" stroke-width="2"/>
  <line x1="50" y1="70" x2="50" y2="76" stroke="#00e5ff" stroke-width="2"/>
  <line x1="24" y1="50" x2="30" y2="50" stroke="#00e5ff" stroke-width="2"/>
  <line x1="70" y1="50" x2="76" y2="50" stroke="#00e5ff" stroke-width="2"/>
''', stroke_color="#00e5ff")

# 36. Braços Cibernéticos (Gorilla Arms / Mantis Blades)
svgs["cyber_arms.svg"] = svg_wrap('''
  <!-- Braço Mecânico Reforçado -->
  <path d="M 28 30 L 48 30 L 58 48 L 52 74 L 38 74 L 42 50 Z" fill="#142232" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Articulação de Ombro com Pistão -->
  <circle cx="36" cy="30" r="8" fill="#1c2c3e" stroke="#fcee0a" stroke-width="2"/>
  <!-- Lâmina Retrátil Mantis / Pistão Hidráulico -->
  <line x1="52" y1="46" x2="78" y2="24" stroke="#00e5ff" stroke-width="2.5"/>
  <line x1="56" y1="52" x2="82" y2="30" stroke="#00e5ff" stroke-width="1.8"/>
  <circle cx="56" cy="48" r="4" fill="#fcee0a"/>
''', stroke_color="#ff003c")

# 37. Pernas Cibernéticas / Tendões de Salto
svgs["cyber_legs.svg"] = svg_wrap('''
  <!-- Perna com Tendões e Molas Mecânicas -->
  <path d="M 44 18 L 56 18 L 52 46 L 64 68 L 52 78 L 38 74 L 46 50 Z" fill="#142232" stroke="#05ffa1" stroke-width="2.2"/>
  <!-- Joelheira Pneumática -->
  <circle cx="49" cy="48" r="7" fill="#1c2c3e" stroke="#fcee0a" stroke-width="2"/>
  <!-- Mola de Amortecimento de Salto -->
  <path d="M 52 56 L 60 60 L 52 64 L 60 68" fill="none" stroke="#05ffa1" stroke-width="2.2"/>
''', stroke_color="#05ffa1")

# 38. Segundo Coração / Sistema Circulatório
svgs["cyber_heart.svg"] = svg_wrap('''
  <!-- Coração Mecânico Moore Tech -->
  <path d="M 50 78 C 30 58, 22 42, 32 30 C 42 20, 50 32, 50 32 C 50 32, 58 20, 68 30 C 78 42, 70 58, 50 78 Z" fill="#ff003c" fill-opacity="0.35" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Tubulação de Sangue Sintético e Válvulas -->
  <line x1="42" y1="18" x2="42" y2="30" stroke="#00e5ff" stroke-width="3"/>
  <line x1="58" y1="18" x2="58" y2="30" stroke="#00e5ff" stroke-width="3"/>
  <!-- Núcleo de Pulsação Central -->
  <circle cx="50" cy="48" r="7" fill="#14202e" stroke="#fcee0a" stroke-width="2"/>
  <circle cx="50" cy="48" r="3" fill="#fcee0a"/>
''', stroke_color="#ff003c")

# 39. Sandevistan / Sistema Nervoso Neural
svgs["cyber_brain.svg"] = svg_wrap('''
  <!-- Coluna Vertebral Cibernética Sandevistan -->
  <rect x="44" y="16" width="12" height="10" rx="2" fill="#1a2a3c" stroke="#fcee0a" stroke-width="2"/>
  <rect x="44" y="30" width="12" height="10" rx="2" fill="#1a2a3c" stroke="#fcee0a" stroke-width="2"/>
  <rect x="44" y="44" width="12" height="10" rx="2" fill="#1a2a3c" stroke="#fcee0a" stroke-width="2"/>
  <rect x="44" y="58" width="12" height="10" rx="2" fill="#1a2a3c" stroke="#fcee0a" stroke-width="2"/>
  <rect x="44" y="72" width="12" height="10" rx="2" fill="#1a2a3c" stroke="#fcee0a" stroke-width="2"/>
  <!-- Fios Neurais e Impulsos Rápidos -->
  <path d="M 32 24 L 44 35 L 32 46 L 44 57 L 32 68" fill="none" stroke="#00e5ff" stroke-width="2"/>
  <path d="M 68 24 L 56 35 L 68 46 L 56 57 L 68 68" fill="none" stroke="#00e5ff" stroke-width="2"/>
''', stroke_color="#fcee0a")

# 40. Cyberdeck Arasaka
svgs["cyberdeck.svg"] = svg_wrap('''
  <!-- Deck Netrunner com Luzes de Barramento -->
  <rect x="22" y="24" width="56" height="52" rx="4" fill="#0e1624" stroke="#ff003c" stroke-width="2.2"/>
  <!-- Entradas de Cabo Monowire / Jack de Conexão -->
  <circle cx="32" cy="34" r="3.5" fill="#16283c" stroke="#00e5ff" stroke-width="1.8"/>
  <circle cx="44" cy="34" r="3.5" fill="#16283c" stroke="#00e5ff" stroke-width="1.8"/>
  <circle cx="56" cy="34" r="3.5" fill="#16283c" stroke="#00e5ff" stroke-width="1.8"/>
  <circle cx="68" cy="34" r="3.5" fill="#16283c" stroke="#00e5ff" stroke-width="1.8"/>
  <!-- Display de RAM e Buffer -->
  <rect x="28" y="46" width="44" height="20" fill="#122438" stroke="#fcee0a" stroke-width="1.5"/>
  <text x="50" y="58" text-anchor="middle" fill="#05ffa1" font-family="monospace" font-size="8" font-weight="bold">RAM // 16</text>
  <line x1="32" y1="62" x2="68" y2="62" stroke="#ff003c" stroke-width="1.5" stroke-dasharray="3,2"/>
''', stroke_color="#ff003c")

# Salvar todos os arquivos em images/
count_written = 0
for filename, content in svgs.items():
    file_path = os.path.join(images_dir, filename)
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    count_written += 1

print(f"Sucesso: {count_written} SVGs de alta fidelidade criados e salvos em {images_dir}!")
