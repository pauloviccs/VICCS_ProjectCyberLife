import os

images_dir = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\images"

def svg_wrap(content, stroke_color="#22d8e2", bg_gradient=("rgba(12, 18, 30, 0.95)", "rgba(18, 36, 56, 0.95)")):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="{bg_gradient[0]}"/>
      <stop offset="100%" stop-color="{bg_gradient[1]}"/>
    </linearGradient>
  </defs>
  <polygon points="12,4 88,4 96,12 96,88 88,96 12,96 4,88 4,12" fill="url(#bgGrad)" stroke="{stroke_color}" stroke-width="1.8" stroke-opacity="0.85"/>
  <path d="M 8 16 L 8 8 L 16 8" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <path d="M 92 16 L 92 8 L 84 8" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <path d="M 8 84 L 8 92 L 16 92" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  <path d="M 92 84 L 92 92 L 84 92" fill="none" stroke="{stroke_color}" stroke-width="2"/>
  {content}
</svg>'''

extra_svgs = {}

# 41. Lenços Sanitizantes Biotechnica (wet_wipes)
extra_svgs["wet_wipes.svg"] = svg_wrap('''
  <rect x="26" y="32" width="48" height="40" rx="6" fill="#122638" stroke="#05ffa1" stroke-width="2.2"/>
  <!-- Tampa de Puxar -->
  <ellipse cx="50" cy="40" rx="14" ry="6" fill="#1e3e56" stroke="#fcee0a" stroke-width="1.8"/>
  <path d="M 46 36 Q 50 24 54 36" fill="none" stroke="#ffffff" stroke-width="2"/>
  <text x="50" y="60" text-anchor="middle" fill="#05ffa1" font-family="monospace" font-size="7" font-weight="bold">CLEAN 99%</text>
''', stroke_color="#05ffa1")

# 42. Comida para Pets (pet_food)
extra_svgs["pet_food.svg"] = svg_wrap('''
  <path d="M 32 30 C 32 24, 68 24, 68 30 L 68 74 C 68 80, 32 80, 32 74 Z" fill="#162434" stroke="#fcee0a" stroke-width="2.2"/>
  <ellipse cx="50" cy="30" rx="18" ry="6" fill="#203448" stroke="#fcee0a" stroke-width="1.8"/>
  <text x="50" y="54" text-anchor="middle" fill="#ff003c" font-family="monospace" font-size="8" font-weight="bold">PET // NC</text>
  <circle cx="50" cy="64" r="3" fill="#22d8e2"/>
''', stroke_color="#fcee0a")

# 43. Salgadinhos / Chips (snack_chips)
extra_svgs["snack_chips.svg"] = svg_wrap('''
  <polygon points="32,24 68,24 62,78 38,78" fill="#182c40" stroke="#fcee0a" stroke-width="2.2"/>
  <line x1="32" y1="28" x2="68" y2="28" stroke="#ff003c" stroke-width="2"/>
  <line x1="38" y1="74" x2="62" y2="74" stroke="#ff003c" stroke-width="2"/>
  <text x="50" y="52" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="8" font-weight="bold">CHIPS</text>
''', stroke_color="#fcee0a")

# 44. Espetinho Yakitori / Tofu (skewer)
extra_svgs["skewer.svg"] = svg_wrap('''
  <line x1="24" y1="76" x2="76" y2="24" stroke="#fcee0a" stroke-width="2.5"/>
  <rect x="36" y="52" width="12" height="12" rx="2" fill="#ff7700" stroke="#22d8e2" stroke-width="1.5" transform="rotate(-45 42 58)"/>
  <rect x="46" y="42" width="12" height="12" rx="2" fill="#ff7700" stroke="#22d8e2" stroke-width="1.5" transform="rotate(-45 52 48)"/>
  <rect x="56" y="32" width="12" height="12" rx="2" fill="#ff7700" stroke="#22d8e2" stroke-width="1.5" transform="rotate(-45 62 38)"/>
''', stroke_color="#ff7700")

# 45. Ração Militar MRE (combat_ration)
extra_svgs["combat_ration.svg"] = svg_wrap('''
  <rect x="28" y="24" width="44" height="52" rx="4" fill="#14202c" stroke="#05ffa1" stroke-width="2.2"/>
  <rect x="34" y="32" width="32" height="18" fill="#1a2e3e" stroke="#fcee0a" stroke-width="1.5"/>
  <text x="50" y="44" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="7" font-weight="bold">MRE // MIL</text>
  <line x1="34" y1="58" x2="66" y2="58" stroke="#05ffa1" stroke-width="2" stroke-dasharray="3,2"/>
''', stroke_color="#05ffa1")

# 46. Maçã Orgânica (apple)
extra_svgs["apple.svg"] = svg_wrap('''
  <circle cx="50" cy="56" r="22" fill="#ff003c" fill-opacity="0.5" stroke="#ff003c" stroke-width="2.2"/>
  <path d="M 50 34 Q 54 22 58 18" fill="none" stroke="#05ffa1" stroke-width="2.5"/>
  <ellipse cx="62" cy="24" rx="6" ry="3" fill="#05ffa1" transform="rotate(-25 62 24)"/>
''', stroke_color="#ff003c")

# 47. Maleta Médica / Desfibrilador (medkit_box)
extra_svgs["medkit_box.svg"] = svg_wrap('''
  <rect x="24" y="32" width="52" height="44" rx="4" fill="#162638" stroke="#00e5ff" stroke-width="2.2"/>
  <path d="M 40 32 L 40 22 L 60 22 L 60 32" fill="none" stroke="#fcee0a" stroke-width="2.5"/>
  <rect x="46" y="44" width="8" height="20" fill="#ff003c"/>
  <rect x="40" y="50" width="20" height="8" fill="#ff003c"/>
''', stroke_color="#00e5ff")

# 48. Chapa Balística (ballistic_plate)
extra_svgs["ballistic_plate.svg"] = svg_wrap('''
  <polygon points="34,22 66,22 74,38 74,74 26,74 26,38" fill="#121e2a" stroke="#22d8e2" stroke-width="2.2"/>
  <text x="50" y="52" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="8" font-weight="bold">LVL IV</text>
  <line x1="32" y1="62" x2="68" y2="62" stroke="#22d8e2" stroke-width="1.8"/>
''', stroke_color="#22d8e2")

# 49. Chaveiro Holográfico (keychain)
extra_svgs["keychain.svg"] = svg_wrap('''
  <circle cx="50" cy="30" r="12" fill="none" stroke="#fcee0a" stroke-width="2.5"/>
  <line x1="50" y1="42" x2="50" y2="52" stroke="#22d8e2" stroke-width="2"/>
  <polygon points="50,52 64,66 50,80 36,66" fill="#14263a" stroke="#00e5ff" stroke-width="2"/>
  <circle cx="50" cy="66" r="3" fill="#ff003c"/>
''', stroke_color="#00e5ff")

# 50. Cinzeiro com Neon (ashtray)
extra_svgs["ashtray.svg"] = svg_wrap('''
  <ellipse cx="50" cy="54" rx="28" ry="18" fill="#142232" stroke="#ff003c" stroke-width="2.2"/>
  <ellipse cx="50" cy="54" rx="18" ry="10" fill="#0a121c" stroke="#fcee0a" stroke-width="1.5"/>
  <line x1="28" y1="42" x2="38" y2="50" stroke="#fcee0a" stroke-width="2.5"/>
''', stroke_color="#ff003c")

# 51. Lata Amassada (crushed_can)
extra_svgs["crushed_can.svg"] = svg_wrap('''
  <path d="M 38 24 L 62 24 L 56 44 L 64 58 L 58 74 L 34 74 L 42 56 L 36 42 Z" fill="#162436" stroke="#22d8e2" stroke-width="2"/>
  <line x1="42" y1="36" x2="56" y2="40" stroke="#ff003c" stroke-width="1.8"/>
''', stroke_color="#22d8e2")

# 52. Palheta de Guitarra Silverhand (guitar_pick)
extra_svgs["guitar_pick.svg"] = svg_wrap('''
  <path d="M 50 78 C 30 62, 28 32, 38 22 C 48 14, 52 14, 62 22 C 72 32, 70 62, 50 78 Z" fill="#182638" stroke="#ff003c" stroke-width="2.2"/>
  <text x="50" y="44" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="7" font-weight="bold">SILVER</text>
  <text x="50" y="52" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="7" font-weight="bold">HAND</text>
''', stroke_color="#ff003c")

# 53. Fita Cassete (cassette_tape)
extra_svgs["cassette_tape.svg"] = svg_wrap('''
  <rect x="22" y="30" width="56" height="40" rx="4" fill="#101a26" stroke="#fcee0a" stroke-width="2.2"/>
  <circle cx="36" cy="50" r="7" fill="#1e3248" stroke="#22d8e2" stroke-width="1.8"/>
  <circle cx="64" cy="50" r="7" fill="#1e3248" stroke="#22d8e2" stroke-width="1.8"/>
  <rect x="42" y="44" width="16" height="12" fill="#080e16" stroke="#fcee0a" stroke-width="1"/>
''', stroke_color="#fcee0a")

# 54. Xícara / Chá Joy Tea (tea_cup)
extra_svgs["tea_cup.svg"] = svg_wrap('''
  <path d="M 32 40 L 68 40 L 64 68 C 64 74, 36 74, 36 68 Z" fill="#142636" stroke="#05ffa1" stroke-width="2.2"/>
  <path d="M 68 46 Q 78 52 66 60" fill="none" stroke="#05ffa1" stroke-width="2.5"/>
  <path d="M 46 34 Q 44 24 48 18" fill="none" stroke="#22d8e2" stroke-width="1.5" stroke-dasharray="2,2"/>
  <path d="M 54 34 Q 56 24 52 18" fill="none" stroke="#22d8e2" stroke-width="1.5" stroke-dasharray="2,2"/>
''', stroke_color="#05ffa1")

# 55. Garrafa de Vidro Vazia (empty_bottle)
extra_svgs["empty_bottle.svg"] = svg_wrap('''
  <path d="M 46 18 L 54 18 L 54 30 L 64 42 L 64 80 L 36 80 L 36 42 L 46 30 Z" fill="none" stroke="#22d8e2" stroke-width="2.2"/>
  <line x1="42" y1="46" x2="58" y2="76" stroke="#ffffff" stroke-width="1.2" stroke-opacity="0.6"/>
''', stroke_color="#22d8e2")

# 56. Camuflagem Óptica (camo_device)
extra_svgs["camo_device.svg"] = svg_wrap('''
  <circle cx="50" cy="50" r="26" fill="#102030" stroke="#00e5ff" stroke-width="2.2" stroke-dasharray="6,3"/>
  <polygon points="50,32 64,50 50,68 36,50" fill="none" stroke="#fcee0a" stroke-width="2"/>
  <circle cx="50" cy="50" r="4" fill="#00e5ff"/>
''', stroke_color="#00e5ff")

# 57. Esqueleto / Ossos de Titânio (cyber_skeleton)
extra_svgs["cyber_skeleton.svg"] = svg_wrap('''
  <line x1="50" y1="20" x2="50" y2="80" stroke="#fcee0a" stroke-width="4"/>
  <circle cx="50" cy="22" r="6" fill="#182c40" stroke="#fcee0a" stroke-width="2"/>
  <line x1="30" y1="36" x2="70" y2="36" stroke="#22d8e2" stroke-width="3"/>
  <line x1="34" y1="48" x2="66" y2="48" stroke="#22d8e2" stroke-width="3"/>
  <line x1="38" y1="60" x2="62" y2="60" stroke="#22d8e2" stroke-width="3"/>
''', stroke_color="#fcee0a")

# 58. Componente de Hack Rápido (quickhack_tier)
extra_svgs["quickhack_tier.svg"] = svg_wrap('''
  <rect x="28" y="22" width="44" height="56" rx="4" fill="#0e1a26" stroke="#05ffa1" stroke-width="2.2"/>
  <line x1="36" y1="32" x2="64" y2="32" stroke="#00e5ff" stroke-width="2"/>
  <line x1="36" y1="40" x2="54" y2="40" stroke="#00e5ff" stroke-width="2"/>
  <text x="50" y="60" text-anchor="middle" fill="#fcee0a" font-family="monospace" font-size="9" font-weight="bold">.DAEMON</text>
''', stroke_color="#05ffa1")

count = 0
for fn, content in extra_svgs.items():
    fp = os.path.join(images_dir, fn)
    with open(fp, "w", encoding="utf-8") as f:
        f.write(content)
    count += 1

print(f"Sucesso: {count} SVGs adicionais gerados em {images_dir}!")
