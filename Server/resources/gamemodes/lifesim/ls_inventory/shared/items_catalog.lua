--[[
    LIFESIM RP - Official Items Catalog (Complete & Canonical)
    Path: ls_inventory/shared/items_catalog.lua
    Catálogo unificado e exaustivo de todos os itens do jogo Cyberpunk 2077 / OPEN//77.
    Total de itens cadastrados: 385 itens.
    Pesos proporcionais calibrados em escala real 1:1 (unidade: gramas, onde 1000g = 1.0kg).
]]

ItemsCatalog = {
    -- =========================================================================
    -- ALIMENTOS & BEBIDAS (CONSUMÍVEIS VITAIS)
    -- =========================================================================
    ["absinthe_absolem"] = {
        name = "Absinto Artesanal Absolem 70%",
        description = "A fada verde engarrafada. Álcool de alta graduação com infusão de absinto e ervas amargas.",
        type = "consumable",
        rarity = "epic",
        weight = 1280,
        max_stack = 5,
        image = "liquor_bottle.svg",
        effects = { thirst = -5, energy = 15, stress = -45 }
    },
    ["beer_arasaka_premium"] = {
        name = "Cerveja Arasaka Puro Malte",
        description = "Garrafa de vidro de cerveja japonesa importada com sabor limpo e lúpulo nobre.",
        type = "consumable",
        rarity = "rare",
        weight = 520,
        max_stack = 15,
        image = "beer_bottle.svg",
        effects = { thirst = 25, stress = -22 }
    },
    ["beer_broseph_dark"] = {
        name = "Cerveja Broseph Stout Escura",
        description = "Cerveja encorpada com notas de malte torrado e teor alcoólico de 7.5%.",
        type = "consumable",
        rarity = "common",
        weight = 360,
        max_stack = 20,
        image = "beer_bottle.svg",
        effects = { thirst = 18, energy = -8, stress = -20 }
    },
    ["beer_broseph_lager"] = {
        name = "Cerveja Broseph Lager",
        description = "Cerveja clara fermentada em lata de alumínio. A preferida de chooms em Heywood.",
        type = "consumable",
        rarity = "common",
        weight = 360,
        max_stack = 20,
        image = "beer_bottle.svg",
        effects = { thirst = 20, energy = -5, stress = -15 }
    },
    ["burrito_xxl"] = {
        name = "Burrito XXL Sintético",
        description = "Massa proteica sintética com recheio apimentado. Enche a barriga de qualquer mercenário.",
        type = "consumable",
        rarity = "common",
        weight = 400,
        max_stack = 20,
        image = "burrito.png",
        effects = { hunger = 40, thirst = -10, stress = -5 }
    },
    ["canned_dog_food"] = {
        name = "Ração Canina Enlatada Rover",
        description = "Comida para cães altamente calórica. Consumida por punks desprovidos de eddis.",
        type = "consumable",
        rarity = "common",
        weight = 400,
        max_stack = 10,
        image = "pet_food.svg",
        effects = { hunger = 25, stress = 10 }
    },
    ["cat_food"] = {
        name = "Comida para Gatos Super-Premium",
        description = "Ração úmida gelatinosa para felinos. Item cobiçado e raríssimo em Night City.",
        type = "consumable",
        rarity = "rare",
        weight = 250,
        max_stack = 10,
        image = "pet_food.svg",
        effects = { hunger = 15, stress = 5 }
    },
    ["chocolate_synth"] = {
        name = "Barra de Chocolate Sintético Dark",
        description = "Manteiga de cacau clonada rica em cafeína e açúcares rápidos.",
        type = "consumable",
        rarity = "uncommon",
        weight = 100,
        max_stack = 25,
        image = "snack_chips.svg",
        effects = { hunger = 12, energy = 20, stress = -10 }
    },
    ["chromanticore"] = {
        name = "Refrigerante Chromanticore",
        description = "Bebida cítrica fluorescente que brilha na luz negra com alta carga de cafeína.",
        type = "consumable",
        rarity = "common",
        weight = 355,
        max_stack = 20,
        image = "soda_can.svg",
        effects = { thirst = 30, energy = 20, stress = 1 }
    },
    ["clean_water"] = {
        name = "Água Mineral Purificada NC",
        description = "Água potável certificada livre de resíduos químicos pesados.",
        type = "consumable",
        rarity = "common",
        weight = 500,
        max_stack = 20,
        image = "water.png",
        effects = { thirst = 50, stress = -5 }
    },
    ["combat_ration"] = {
        name = "Ração Tática Militech MRE",
        description = "Pacote militar concentrado de alto valor calórico e eletrólitos para missões de cerco.",
        type = "consumable",
        rarity = "rare",
        weight = 650,
        max_stack = 10,
        image = "combat_ration.svg",
        effects = { hunger = 70, thirst = 30, energy = 30 }
    },
    ["joy_tea"] = {
        name = "Joy Tea Relaxante",
        description = "Chá gelado de pêssego com calmantes botânicos de ação neural suave.",
        type = "consumable",
        rarity = "uncommon",
        weight = 330,
        max_stack = 20,
        image = "tea_cup.svg",
        effects = { thirst = 40, stress = -20 }
    },
    ["matapang_coffee"] = {
        name = "Café Forte Matapang Robusta",
        description = "Bebida espessa e amarga de café filtrado com dose quádrupla de cafeína.",
        type = "consumable",
        rarity = "uncommon",
        weight = 250,
        max_stack = 20,
        image = "coffee.png",
        effects = { thirst = 10, energy = 45, stress = -8 }
    },
    ["moonchies_chips"] = {
        name = "Salgadinho Moonchies Queijo",
        description = "Batatas sintéticas crocantes infladas com pó de queijo fluorescente.",
        type = "consumable",
        rarity = "common",
        weight = 120,
        max_stack = 30,
        image = "snack_chips.svg",
        effects = { hunger = 15, thirst = -12, stress = -2 }
    },
    ["nicola_blue"] = {
        name = "Refrigerante NiCola Blue",
        description = "O clássico 'Taste the Love!' gaseificado com corante anil e taurina concentrada.",
        type = "consumable",
        rarity = "common",
        weight = 355,
        max_stack = 20,
        image = "soda_can.svg",
        effects = { thirst = 35, energy = 12, stress = -2 }
    },
    ["nicola_sakura"] = {
        name = "NiCola Edição Especial Sakura",
        description = "Refrigerante gaseificado suave com essência de flor de cerejeira e adoçante sintético.",
        type = "consumable",
        rarity = "uncommon",
        weight = 355,
        max_stack = 20,
        image = "soda_can.svg",
        effects = { thirst = 35, energy = 14, stress = -6 }
    },
    ["organic_apple"] = {
        name = "Maçã Orgânica Genuína Biotechnica",
        description = "Fruta colhida em estufa climatizada real. Uma das maiores iguarias de luxo do mundo.",
        type = "consumable",
        rarity = "legendary",
        weight = 180,
        max_stack = 5,
        image = "apple.svg",
        effects = { hunger = 30, thirst = 20, energy = 30, stress = -30 }
    },
    ["real_water"] = {
        name = "Água Mineral Real Natural 500ml",
        description = "Água pura de nascente sem tratamento radioativo ou sabor metálico.",
        type = "consumable",
        rarity = "rare",
        weight = 520,
        max_stack = 20,
        image = "water.png",
        effects = { thirst = 60, energy = 10, stress = -15 }
    },
    ["rum_roaring_twenties"] = {
        name = "Rum Envelhecido Roaring 20s",
        description = "Destilado de cana de açúcar fermentada caribenha com notas de melaço e baunilha.",
        type = "consumable",
        rarity = "rare",
        weight = 1260,
        max_stack = 5,
        image = "liquor_bottle.svg",
        effects = { thirst = 10, stress = -28 }
    },
    ["slurm_synth"] = {
        name = "Refrigerante Slurm Verde",
        description = "Xarope carbonatado ultra-doce altamente viciante e popular nas zonas periféricas.",
        type = "consumable",
        rarity = "common",
        weight = 355,
        max_stack = 20,
        image = "soda_can.svg",
        effects = { thirst = 25, energy = 15, stress = 3 }
    },
    ["spicy_ramen"] = {
        name = "Kabuki Spicy Ramen",
        description = "Tigela térmica de ramen instantâneo apimentado dos becos de Watson.",
        type = "consumable",
        rarity = "common",
        weight = 450,
        max_stack = 15,
        image = "ramen.svg",
        effects = { hunger = 45, thirst = -10, energy = 15, stress = -5 }
    },
    ["spunky_monkey"] = {
        name = "Spunky Monkey Energy Drink",
        description = "Bebida energética hiper-cafeinada com sabor artificial de banana fluorescente.",
        type = "consumable",
        rarity = "uncommon",
        weight = 355,
        max_stack = 20,
        image = "soda_can.svg",
        effects = { thirst = 30, energy = 35, stress = -5 }
    },
    ["spunky_monkey_citrus"] = {
        name = "Spunky Monkey Citrus Blast",
        description = "Explosão ácida de eletrólitos e taurina para mercenários durante tiroteios noturnos.",
        type = "consumable",
        rarity = "uncommon",
        weight = 355,
        max_stack = 20,
        image = "soda_can.svg",
        effects = { thirst = 32, energy = 38, stress = -4 }
    },
    ["synth_burger"] = {
        name = "Captain Caliente Synth Burger",
        description = "Hambúrguer de proteína clonada com queijo sintético derretido.",
        type = "consumable",
        rarity = "common",
        weight = 350,
        max_stack = 15,
        image = "burger.svg",
        effects = { hunger = 30, thirst = -4, energy = 8, stress = -1 }
    },
    ["synth_coffee"] = {
        name = "Café Sintético Hot-Cup",
        description = "Café pressurizado autocalecente de abertura rápida para jornadas exaustivas.",
        type = "consumable",
        rarity = "common",
        weight = 280,
        max_stack = 20,
        image = "coffee.png",
        effects = { thirst = 15, energy = 35, stress = -12 }
    },
    ["synth_steak"] = {
        name = "Bife de Soja Sintética Prime",
        description = "Corte nobre clonado marinado em fumaça líquida e glutamato monossódico.",
        type = "consumable",
        rarity = "uncommon",
        weight = 380,
        max_stack = 10,
        image = "steak.svg",
        effects = { hunger = 50, energy = 12, stress = -8 }
    },
    ["synth_sushi"] = {
        name = "Barca de Sushi Sintético",
        description = "Niguiris de salmão clonado com algas artificiais prensadas de Japantown.",
        type = "consumable",
        rarity = "rare",
        weight = 320,
        max_stack = 10,
        image = "sushi.svg",
        effects = { hunger = 35, energy = 18, stress = -12 }
    },
    ["tequila_centzon"] = {
        name = "Garrafa Tequila Centzon",
        description = "Destilado tradicional de agave mexicano 40% vol. Queima a garganta e aquece o peito.",
        type = "consumable",
        rarity = "rare",
        weight = 1250,
        max_stack = 5,
        image = "liquor_bottle.svg",
        effects = { thirst = 10, energy = 10, stress = -35 }
    },
    ["tiancha_green_tea"] = {
        name = "Chá Verde Imperial Tiancha",
        description = "Chá verde desintoxicante de alta pureza engarrafado pela corporação Kang Tao.",
        type = "consumable",
        rarity = "rare",
        weight = 350,
        max_stack = 20,
        image = "tea_cup.svg",
        effects = { thirst = 45, energy = 15, stress = -25 }
    },
    ["tofu_skewer"] = {
        name = "Espeto de Tofu Crocante",
        description = "Proteína vegetal prensada frita em óleo de palma hidrogenado.",
        type = "consumable",
        rarity = "common",
        weight = 180,
        max_stack = 20,
        image = "skewer.svg",
        effects = { hunger = 20, energy = 5 }
    },
    ["vodka_jackie_welles"] = {
        name = "Coquetel Jackie Welles",
        description = "Dose de vodka com cerveja de gengibre, suco de limão e um toque de amor. Para os heróis do Afterlife.",
        type = "consumable",
        rarity = "iconic",
        weight = 750,
        max_stack = 5,
        image = "liquor_bottle.svg",
        effects = { thirst = 20, energy = 20, stress = -45 }
    },
    ["wet_wipes"] = {
        name = "Lenços Umedecidos Biotechnica",
        description = "Lenços antissépticos bactericidas para assepsia corporal rápida sem necessidade de banho.",
        type = "consumable",
        rarity = "common",
        weight = 100,
        max_stack = 10,
        image = "wet_wipes.svg",
        effects = { hygiene = 40, stress = -3 }
    },
    ["whiskey_johnny_silverhand"] = {
        name = "Uísque Johnny Silverhand",
        description = "Garrafa de uísque com um toque de pimenta chili e cerveja no fundo. Uma lenda de Night City.",
        type = "consumable",
        rarity = "iconic",
        weight = 1300,
        max_stack = 5,
        image = "liquor_bottle.svg",
        effects = { thirst = 15, energy = 25, stress = -50 }
    },
    ["wine_chateau_nightcity"] = {
        name = "Vinho Tinto Reserva Château NC",
        description = "Garrafa de vinho encorpado envelhecido em carvalho sintético com notas de frutas vermelhas.",
        type = "consumable",
        rarity = "epic",
        weight = 1350,
        max_stack = 5,
        image = "liquor_bottle.svg",
        effects = { thirst = 15, stress = -30 }
    },
    ["yakitori_allfoods"] = {
        name = "Espetinho Yakitori All-Foods",
        description = "Frango de laboratório grelhado no carvão com molho teriyaki espesso.",
        type = "consumable",
        rarity = "common",
        weight = 220,
        max_stack = 20,
        image = "skewer.svg",
        effects = { hunger = 25, energy = 8 }
    },

    -- =========================================================================
    -- FARMÁCIA & MEDICINA (ESTIMULANTES, SUPRESSORES & BIOMED)
    -- =========================================================================
    ["biogel"] = {
        name = "Biogel Reparador Dermal",
        description = "Gel cicatrizante antimicrobiano de aplicação tópica imediata para queimaduras e lacerações.",
        type = "medical",
        rarity = "common",
        weight = 200,
        max_stack = 20,
        image = "biogel.svg",
        effects = { health = 25, hygiene = 15 }
    },
    ["black_lace"] = {
        name = "Inalador Black Lace de Combate",
        description = "Narcótico militar altamente proibido que silencia receptores de dor e induz fúria hiperadrenérgica.",
        type = "medical",
        rarity = "epic",
        weight = 140,
        max_stack = 5,
        image = "maxdoc.png",
        effects = { health = 30, energy = 60, stress = 30, stability = -20 }
    },
    ["bounce_back"] = {
        name = "Estimulante Bounce Back Mk.1",
        description = "Injeção de nano-reparadores que promove regeneração corporal biológica contínua.",
        type = "medical",
        rarity = "uncommon",
        weight = 150,
        max_stack = 10,
        image = "bounce_back.png",
        effects = { health = 55, energy = 20 }
    },
    ["bounce_back_mk1"] = {
        name = "Estimulante Bounce Back Mk.1",
        description = "Injeção de nano-reparadores que promove regeneração corporal contínua.",
        type = "medical",
        rarity = "uncommon",
        weight = 150,
        max_stack = 10,
        image = "bounce_back.png",
        effects = { health = 55, energy = 20 }
    },
    ["bounce_back_mk2"] = {
        name = "Estimulante Bounce Back Mk.2",
        description = "Coquetel regenerativo com micro-anticoagulantes e estimulação celular sustentada.",
        type = "medical",
        rarity = "rare",
        weight = 160,
        max_stack = 10,
        image = "bounce_back.png",
        effects = { health = 75, energy = 30 }
    },
    ["bounce_back_mk3"] = {
        name = "Estimulante Bounce Back Mk.3 Militar",
        description = "Fórmula avançada de nanorobôs reparadores para sustentação de mercenários em combate.",
        type = "medical",
        rarity = "epic",
        weight = 170,
        max_stack = 10,
        image = "bounce_back.png",
        effects = { health = 95, energy = 45 }
    },
    ["cryo_spray"] = {
        name = "Spray Criogênico Ocular & Neural",
        description = "Aerossol de arrefecimento rápido para resfriar dissipadores sinápticos e ciberópticos.",
        type = "medical",
        rarity = "uncommon",
        weight = 120,
        max_stack = 10,
        image = "biogel.svg",
        effects = { stability = 15, heat = -6.0, stress = -10 }
    },
    ["dorph_stim"] = {
        name = "Injetor Dorph de Endorfinas",
        description = "Analgésico sintético concentrado que amortece o sistema nervoso central contra choque traumático.",
        type = "medical",
        rarity = "rare",
        weight = 90,
        max_stack = 10,
        image = "bounce_back.png",
        effects = { health = 20, stress = -50 }
    },
    ["glitter"] = {
        name = "Frasco de Glitter Sintético",
        description = "Pó alucinógeno e eufórico consumido por jovens em boates e becos de Westbrook.",
        type = "medical",
        rarity = "uncommon",
        weight = 30,
        max_stack = 20,
        image = "biogel.svg",
        effects = { energy = 40, stress = -40, stability = -10 }
    },
    ["immuno_shot"] = {
        name = "Ampola Imunossupressora",
        description = "Acalma o sistema imunológico biológico após procedimentos cirúrgicos ou instalação de cromo.",
        type = "medical",
        rarity = "uncommon",
        weight = 100,
        max_stack = 10,
        image = "biogel.svg",
        effects = { stability = 20, stress = -15, heat = -1.0 }
    },
    ["maxdoc_mk1"] = {
        name = "Inalador MaxDoc Mk.1",
        description = "Inalador pulmonar de biogel hemostático. Restaura tecido orgânico básico rapidamente.",
        type = "medical",
        rarity = "common",
        weight = 150,
        max_stack = 15,
        image = "maxdoc.png",
        effects = { health = 40, stress = -10 }
    },
    ["maxdoc_mk2"] = {
        name = "Inalador MaxDoc Mk.2 Avançado",
        description = "Nebulizador de grau hospitalar com catalisador de cicatrização acelerada para feridas profundas.",
        type = "medical",
        rarity = "uncommon",
        weight = 160,
        max_stack = 15,
        image = "maxdoc.png",
        effects = { health = 65, stress = -15 }
    },
    ["maxdoc_mk3"] = {
        name = "Inalador MaxDoc Mk.3 Militar Trauma Team",
        description = "Fórmula médica de intervenção emergencial que sela hemorragias arteriais em segundos.",
        type = "medical",
        rarity = "rare",
        weight = 175,
        max_stack = 10,
        image = "maxdoc.png",
        effects = { health = 90, stress = -25 }
    },
    ["neuroblocker"] = {
        name = "Neurobloqueador Imunológico",
        description = "Supressor farmacêutico para ciberimplantes. Estabiliza o córtex e afasta a ciberpsicose.",
        type = "medical",
        rarity = "rare",
        weight = 100,
        max_stack = 15,
        image = "neuroblocker.svg",
        effects = { stability = 35, stress = -40 }
    },
    ["neuroblocker_booster"] = {
        name = "Injetor de Neurobloqueador Booster",
        description = "Bloqueador neural sintético concentrado obrigatório para conter sobrecarga e rejeição de cromo.",
        type = "medical",
        rarity = "rare",
        weight = 120,
        max_stack = 10,
        image = "neuroblocker.svg",
        effects = { stability = 40, stress = -30, heat = -2.0 }
    },
    ["oxy_stim"] = {
        name = "Ampola Respiratória Oxy-Stim",
        description = "Oxigenador biológico de circulação para rápida recuperação de estamina e cansaço físico.",
        type = "medical",
        rarity = "uncommon",
        weight = 110,
        max_stack = 10,
        image = "bounce_back.png",
        effects = { energy = 50, stress = -10 }
    },
    ["surgical_medkit"] = {
        name = "Maleta Cirúrgica Tática de Campo",
        description = "Kit estéril com suturadores a laser, hemostáticos e grampeadores de pele para cirurgias em campo.",
        type = "medical",
        rarity = "rare",
        weight = 2200,
        max_stack = 2,
        image = "medkit_box.svg",
        effects = { health = 80, hygiene = 30 }
    },
    ["trauma_defibrillator"] = {
        name = "Desfibrilador Portátil Trauma Team",
        description = "Equipamento médico automatizado com eletrodos adesivos para reanimação cardíaca de emergência.",
        type = "medical",
        rarity = "epic",
        weight = 850,
        max_stack = 2,
        image = "medkit_box.svg",
        effects = { health = 100, stability = 25 }
    },

    -- =========================================================================
    -- MUNIÇÕES & CARGAS BALÍSTICAS
    -- =========================================================================
    ["ammo_handgun"] = {
        name = "Munição de Pistola (9mm / .45 ACP)",
        description = "Projéteis com estojo de latão e núcleo de chumbo para pistolas semiautomáticas e submetralhadoras.",
        type = "ammo",
        rarity = "common",
        weight = 15,
        max_stack = 500,
        image = "ammo_handgun.png"
    },
    ["ammo_rifle"] = {
        name = "Munição de Fuzil (5.56mm / 7.62mm)",
        description = "Cartuchos perfurantes de alta velocidade para fuzis de assalto automáticos e metralhadoras leves.",
        type = "ammo",
        rarity = "uncommon",
        weight = 24,
        max_stack = 500,
        image = "ammo_rifle.png"
    },
    ["ammo_shotgun"] = {
        name = "Cartuchos de Escopeta (Calibre 12)",
        description = "Balotes pesados de polímero com múltiplos bagos de chumbo denso para dispersão letal.",
        type = "ammo",
        rarity = "uncommon",
        weight = 48,
        max_stack = 250,
        image = "ammo_shotgun.png"
    },
    ["ammo_smart_micro"] = {
        name = "Micro-Mísseis Giro-Estabilizados Smart",
        description = "Projéteis inteligentes microscópicos com lemes aerodinâmicos que buscam alvos travados em voo.",
        type = "ammo",
        rarity = "rare",
        weight = 20,
        max_stack = 400,
        image = "ammo_handgun.png"
    },
    ["ammo_sniper"] = {
        name = "Munição de Precisão (.50 BMG / 12.7mm)",
        description = "Balas maciças de calibre antimaterial pesadas com ogiva perfurante de blindagens de veículos.",
        type = "ammo",
        rarity = "rare",
        weight = 115,
        max_stack = 100,
        image = "ammo_sniper.png"
    },
    ["ammo_tech_battery"] = {
        name = "Célula Eletromagnética Tech",
        description = "Baterias de capacitores ultrarrápidos para alimentar armas com trilhos de aceleração magnética.",
        type = "ammo",
        rarity = "rare",
        weight = 35,
        max_stack = 300,
        image = "ammo_rifle.png"
    },

    -- =========================================================================
    -- ARMAMENTO & BELICISMO (187 ARMAS OFICIAIS DE NIGHT CITY)
    -- =========================================================================
    ["weapon_achilles"] = {
        name = "Militech M-179e Achilles",
        description = "Rifle de precisão Tech eletromagnético capaz de carregar e perfurar blindagens leves.",
        type = "weapon",
        rarity = "rare",
        weight = 4200,
        max_stack = 1,
        image = "weapon_achilles.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_achilles_modified"] = {
        name = "M-179e Achilles Modificado",
        description = "Versão tunada com capacitores de alta voltagem para perfuração reforçada.",
        type = "weapon",
        rarity = "epic",
        weight = 4350,
        max_stack = 1,
        image = "weapon_achilles_modified.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_achilles_xmod2"] = {
        name = "M-179e Achilles x-MOD2",
        description = "Variante icônica customizada para mercenários de Dogtown com slot duplo de customização.",
        type = "weapon",
        rarity = "iconic",
        weight = 4400,
        max_stack = 1,
        image = "weapon_achilles_xmod2.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_agaou"] = {
        name = "Machado Tático Agaou",
        description = "Machado de arremesso que gera uma explosão de pulso eletromagnético em acertos críticos.",
        type = "weapon",
        rarity = "iconic",
        weight = 1600,
        max_stack = 1,
        image = "weapon_agaou.png"
    },
    ["weapon_ajax"] = {
        name = "Militech M251s Ajax",
        description = "Fuzil de assalto padrão das forças armadas da Militech. Robusto, balanceado e letal.",
        type = "weapon",
        rarity = "rare",
        weight = 3850,
        max_stack = 1,
        image = "weapon_ajax.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_alabai"] = {
        name = "Rostović Alabai",
        description = "Escopeta tecnológica icônica de tambor com munição perfurante e incendiária.",
        type = "weapon",
        rarity = "iconic",
        weight = 4600,
        max_stack = 1,
        image = "weapon_alabai.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_ambition"] = {
        name = "Techtronika SPT32 Ambition",
        description = "Pistola Tech de precisão equipada com módulo experimental de cegueira flash.",
        type = "weapon",
        rarity = "iconic",
        weight = 1350,
        max_stack = 1,
        image = "weapon_ambition.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_amnesty"] = {
        name = "Revólver Amnesty",
        description = "Overture modificado por Cassidy com gatilho ultraleve e precisão de longo alcance.",
        type = "weapon",
        rarity = "iconic",
        weight = 1850,
        max_stack = 1,
        image = "weapon_amnesty.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_amstaff"] = {
        name = "Rostović Amstaff",
        description = "Escopeta de combate com cano reforçado e cadência automática de destruição pesada.",
        type = "weapon",
        rarity = "iconic",
        weight = 4100,
        max_stack = 1,
        image = "weapon_amstaff.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_apparition"] = {
        name = "JKE-X2 Kenshin Apparition",
        description = "Pistola Tech icônica de Frank Adams que acelera os disparos quando a vida está baixa.",
        type = "weapon",
        rarity = "iconic",
        weight = 1250,
        max_stack = 1,
        image = "weapon_apparition.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_archangel"] = {
        name = "Overture Archangel de Kerry",
        description = "Revólver clássico banhado com alta condutividade elétrica e recuo estabilizado.",
        type = "weapon",
        rarity = "iconic",
        weight = 1750,
        max_stack = 1,
        image = "weapon_archangel.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_ashura"] = {
        name = "Tsunami Ashura Smart Sniper",
        description = "Rifle de precisão Smart teleguiado monotiro com cálculo automático de trajetória para cabeça.",
        type = "weapon",
        rarity = "legendary",
        weight = 6800,
        max_stack = 1,
        image = "weapon_ashura.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_ba_xing_chong"] = {
        name = "Kang Tao Ba Xing Chong",
        description = "Escopeta Smart lendária pessoal de Adam Smasher disparando micromísseis teleguiados.",
        type = "weapon",
        rarity = "iconic",
        weight = 5800,
        max_stack = 1,
        image = "weapon_ba_xing_chong.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_baby_boomer"] = {
        name = "Taco Baby Boomer",
        description = "Taco de beisebol de duas mãos com aumento exponencial de chance crítica a cada acerto.",
        type = "weapon",
        rarity = "iconic",
        weight = 1400,
        max_stack = 1,
        image = "weapon_baby_boomer.png"
    },
    ["weapon_baseball_bat"] = {
        name = "Taco de Beisebol de Madeira",
        description = "Taco maciço de carvalho reforçado com anéis de alumínio para impacto contundente.",
        type = "weapon",
        rarity = "common",
        weight = 1100,
        max_stack = 1,
        image = "weapon_baseball_bat.png"
    },
    ["weapon_baseball_bat_xmod2"] = {
        name = "Taco de Beisebol x-MOD2",
        description = "Versão pesada de liga de tungstênio com balanceamento cinético especial.",
        type = "weapon",
        rarity = "iconic",
        weight = 1350,
        max_stack = 1,
        image = "weapon_baseball_bat_xmod2.png"
    },
    ["weapon_baton_alpha"] = {
        name = "Cassetete Tático Alpha",
        description = "Bastão retrátil da polícia metropolitana NCPD com revestimento de borracha vulcanizada.",
        type = "weapon",
        rarity = "common",
        weight = 750,
        max_stack = 1,
        image = "weapon_baton_alpha.png"
    },
    ["weapon_baton_beta"] = {
        name = "Bastão Eletrificado Beta",
        description = "Cassetete tático com eletrodos de descarga de alta voltagem para controle de distúrbios.",
        type = "weapon",
        rarity = "uncommon",
        weight = 850,
        max_stack = 1,
        image = "weapon_baton_beta.png"
    },
    ["weapon_baton_gamma"] = {
        name = "Bastão Neuro-Choque Gamma",
        description = "Cassetete de choque militar que sobrecarrega os ciberimplantes motores do alvo.",
        type = "weapon",
        rarity = "rare",
        weight = 950,
        max_stack = 1,
        image = "weapon_baton_gamma.png"
    },
    ["weapon_bfc_9000"] = {
        name = "BFC 9000",
        description = "Arma contundente brutal icônica de duas mãos com vibração motora extrema.",
        type = "weapon",
        rarity = "iconic",
        weight = 2200,
        max_stack = 1,
        image = "weapon_bfc_9000.png"
    },
    ["weapon_black_unicorn"] = {
        name = "Katana Black Unicorn",
        description = "Lâmina forjada à mão por mestres armeiros com inscrição rúnica e velocidade cirúrgica.",
        type = "weapon",
        rarity = "iconic",
        weight = 1250,
        max_stack = 1,
        image = "weapon_black_unicorn.png"
    },
    ["weapon_bloody_maria"] = {
        name = "Tactician Bloody Maria",
        description = "Escopeta pump-action icônica dos Padres com maior dispersão e impacto desmembrador.",
        type = "weapon",
        rarity = "iconic",
        weight = 4400,
        max_stack = 1,
        image = "weapon_bloody_maria.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_blue_fang"] = {
        name = "Faca Neurotóxica Blue Fang",
        description = "Faca de arremesso embebida em veneno neural paralisante dos Nomades.",
        type = "weapon",
        rarity = "iconic",
        weight = 320,
        max_stack = 1,
        image = "weapon_blue_fang.png"
    },
    ["weapon_borzaya"] = {
        name = "Rostović Borzaya",
        description = "Revólver Tech com câmara de alta compressão para perfuração instantânea de barreiras.",
        type = "weapon",
        rarity = "iconic",
        weight = 1650,
        max_stack = 1,
        image = "weapon_borzaya.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_breakthrough"] = {
        name = "Nekomata Breakthrough",
        description = "Sniper Tech icônico com recuo compensado e capacidade de varar múltiplos muros de concreto.",
        type = "weapon",
        rarity = "iconic",
        weight = 8200,
        max_stack = 1,
        image = "weapon_breakthrough.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_burya"] = {
        name = "Techtronika RT-46 Burya",
        description = "Revólver Tech de calibre massivo de 4 tiros capaz de derrubar veículos blindados leves.",
        type = "weapon",
        rarity = "epic",
        weight = 2100,
        max_stack = 1,
        image = "weapon_burya.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_buzzsaw"] = {
        name = "DS1 Pulsar Buzzsaw",
        description = "Submetralhadora icônica que dispara projéteis perfurantes de alta cadência como se fossem lasers.",
        type = "weapon",
        rarity = "iconic",
        weight = 2900,
        max_stack = 1,
        image = "weapon_buzzsaw.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_byakko"] = {
        name = "Katana Byakko de Wakako",
        description = "Katana cerimonial que permite saltos de combate rápidos com cortes encadeados em sequência.",
        type = "weapon",
        rarity = "iconic",
        weight = 1150,
        max_stack = 1,
        image = "weapon_byakko.png"
    },
    ["weapon_caretakers_spade"] = {
        name = "Pá do Coveiro / Caretaker's Spade",
        description = "Pá de aço maciço recuperada de relíquias misteriosas que restaura vida a cada golpe.",
        type = "weapon",
        rarity = "iconic",
        weight = 3200,
        max_stack = 1,
        image = "weapon_caretakers_spade.png"
    },
    ["weapon_carmen"] = {
        name = "Kyubi Carmen",
        description = "Fuzil de assalto de Dogtown com velocidade de disparo acelerada em movimento e pulos.",
        type = "weapon",
        rarity = "iconic",
        weight = 3600,
        max_stack = 1,
        image = "weapon_carmen.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_carnage"] = {
        name = "Budget Arms Carnage",
        description = "Escopeta bruta de calibre 4 que arremessa inimigos para trás com recuo brutal.",
        type = "weapon",
        rarity = "epic",
        weight = 5200,
        max_stack = 1,
        image = "weapon_carnage.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_catahoula"] = {
        name = "Nokota Catahoula",
        description = "Escopeta leve e confiável com empunhadura anatômica e rápida ciclagem de bombeamento.",
        type = "weapon",
        rarity = "iconic",
        weight = 4300,
        max_stack = 1,
        image = "weapon_catahoula.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_chainsword"] = {
        name = "Cut-o-Matic Chainsword",
        description = "Espada-motosserra de dentes rotativos de carbureto para desmembramento industrial.",
        type = "weapon",
        rarity = "epic",
        weight = 4500,
        max_stack = 1,
        image = "weapon_chainsword.png"
    },
    ["weapon_chainsword_xmod2"] = {
        name = "Cut-o-Matic x-MOD2",
        description = "Espada motosserra reforçada com dentes diamantados e motor turboalimentado.",
        type = "weapon",
        rarity = "iconic",
        weight = 4700,
        max_stack = 1,
        image = "weapon_chainsword_xmod2.png"
    },
    ["weapon_chao"] = {
        name = "Kang Tao A-22B Chao",
        description = "Pistola Smart compacta de resposta rápida com bloqueio de múltiplos alvos simultâneos.",
        type = "weapon",
        rarity = "rare",
        weight = 950,
        max_stack = 1,
        image = "weapon_chao.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_chaos"] = {
        name = "JKE-X2 Kenshin Chaos de Royce",
        description = "Pistola Tech que altera aleatoriamente o tipo de dano elementar (fogo, choque, químico, tec) a cada recarga.",
        type = "weapon",
        rarity = "iconic",
        weight = 1200,
        max_stack = 1,
        image = "weapon_chaos.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_cheetah"] = {
        name = "Tsunami Cheetah",
        description = "Submetralhadora Smart de cadência supersônica para emboscadas em distâncias curtas.",
        type = "weapon",
        rarity = "iconic",
        weight = 2600,
        max_stack = 1,
        image = "weapon_cheetah.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_chefs_knife"] = {
        name = "Faca de Chef Profissional",
        description = "Lâmina afiada de cutelaria alemã para cortes de precisão rápida.",
        type = "weapon",
        rarity = "common",
        weight = 250,
        max_stack = 1,
        image = "weapon_chefs_knife.png"
    },
    ["weapon_chesapeake"] = {
        name = "Fuzil Smart Chesapeake",
        description = "Rifle de assalto teleguiado com compensação automática de dispersão atmosférica.",
        type = "weapon",
        rarity = "iconic",
        weight = 3900,
        max_stack = 1,
        image = "weapon_chesapeake.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_chinook"] = {
        name = "Rostović Chinook",
        description = "Fuzil Tech soviético com câmara reforçada para rajadas pesadas de calibre 7.62mm.",
        type = "weapon",
        rarity = "iconic",
        weight = 4100,
        max_stack = 1,
        image = "weapon_chinook.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_cleaver"] = {
        name = "Cutelo de Açougueiro Pesado",
        description = "Lâmina espessa de aço carbono para golpes de impacto cortante profundo.",
        type = "weapon",
        rarity = "common",
        weight = 650,
        max_stack = 1,
        image = "weapon_cleaver.png"
    },
    ["weapon_cocktail_stick"] = {
        name = "Katana Cocktail Stick de Evelyn",
        description = "Katana rosa neon encontrada no Clouds com alta probabilidade de sangramento crítico.",
        type = "weapon",
        rarity = "iconic",
        weight = 1100,
        max_stack = 1,
        image = "weapon_cocktail_stick.png"
    },
    ["weapon_comrades_hammer"] = {
        name = "Comrade's Hammer",
        description = "Revólver Tech RT-46 modificado com câmara de disparo monotiro de alta explosão devastadora.",
        type = "weapon",
        rarity = "iconic",
        weight = 2400,
        max_stack = 1,
        image = "weapon_comrades_hammer.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_copperhead"] = {
        name = "Nokota Copperhead",
        description = "Fuzil de assalto confiável, barato e amplamente usado pelas gangues de Santo Domingo.",
        type = "weapon",
        rarity = "uncommon",
        weight = 3400,
        max_stack = 1,
        image = "weapon_copperhead.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_cottonmouth"] = {
        name = "Bengala Cottonmouth de Fingers",
        description = "Bengala eletrificada e venenosa com cabeça de serpente que aplica toxinas e choque.",
        type = "weapon",
        rarity = "iconic",
        weight = 850,
        max_stack = 1,
        image = "weapon_cottonmouth.png"
    },
    ["weapon_crash"] = {
        name = "Overture Crash de River Ward",
        description = "Revólver pesado que pode ser engatilhado no modo automático ao mirar por tempo prolongado.",
        type = "weapon",
        rarity = "iconic",
        weight = 1800,
        max_stack = 1,
        image = "weapon_crash.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_crowbar"] = {
        name = "Pé de Cabra de Aço Forjado",
        description = "Ferramenta e arma de demolição com haste sextavada e alavanca curvada.",
        type = "weapon",
        rarity = "common",
        weight = 1600,
        max_stack = 1,
        image = "weapon_crowbar.png"
    },
    ["weapon_crusher"] = {
        name = "Rostović Crusher",
        description = "Escopeta semiautomática com carregador de tambor rotativo calibre 12.",
        type = "weapon",
        rarity = "rare",
        weight = 4300,
        max_stack = 1,
        image = "weapon_crusher.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_death_and_taxes"] = {
        name = "Nue Death and Taxes de Judy",
        description = "Pistola Nue que dispara dois projéteis simultâneos com custo pequeno de vitalidade.",
        type = "weapon",
        rarity = "iconic",
        weight = 1380,
        max_stack = 1,
        image = "weapon_death_and_taxes.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_defender"] = {
        name = "Constitutional Arms Defender",
        description = "Metralhadora leve LMG com alimentação por cinta e estabilizador de disparo sustentado.",
        type = "weapon",
        rarity = "epic",
        weight = 8500,
        max_stack = 1,
        image = "weapon_defender.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_dezerter"] = {
        name = "Rostović Dezerter",
        description = "Escopeta de cano duplo modificada com recuo tão violento que queima os alvos e recarrega instantaneamente.",
        type = "weapon",
        rarity = "iconic",
        weight = 4900,
        max_stack = 1,
        image = "weapon_dezerter.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_dian"] = {
        name = "Kang Tao G-58 Dian",
        description = "Submetralhadora Smart chinesa com mira giroscópica de micro-projéteis teleguiados.",
        type = "weapon",
        rarity = "rare",
        weight = 2800,
        max_stack = 1,
        image = "weapon_dian.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_dingo"] = {
        name = "Nokota Dingo",
        description = "Fuzil de precisão semiautomático de calibre médio com supressor acústico interno.",
        type = "weapon",
        rarity = "iconic",
        weight = 4400,
        max_stack = 1,
        image = "weapon_dingo.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_divided_we_stand"] = {
        name = "D5 Sidewinder Divided We Stand",
        description = "Fuzil Smart com pintura patriótica da 6th Street capaz de travar em até 5 inimigos simultâneos com dano químico.",
        type = "weapon",
        rarity = "iconic",
        weight = 3750,
        max_stack = 1,
        image = "weapon_divided_we_stand.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_doom_doom"] = {
        name = "DR5 Nova Doom Doom de Dum Dum",
        description = "Revólver Nova com cilindro de 4 disparos por acionamento e desmembramento garantido.",
        type = "weapon",
        rarity = "iconic",
        weight = 1950,
        max_stack = 1,
        image = "weapon_doom_doom.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_dying_night"] = {
        name = "Lexington Dying Night de V",
        description = "Pistola personalizada recebida de Wilson com taxa de tiro elevada e dano de tiro na cabeça aumentado.",
        type = "weapon",
        rarity = "iconic",
        weight = 1120,
        max_stack = 1,
        image = "weapon_dying_night.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_erebus"] = {
        name = "Militech Erebus Submachine Gun",
        description = "Arma experimental contendo uma IA autônoma da Blackwall que drena e consome a mente dos alvos.",
        type = "weapon",
        rarity = "iconic",
        weight = 3200,
        max_stack = 1,
        image = "weapon_erebus.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_errata"] = {
        name = "Katana Térmica Errata",
        description = "Katana forjada com núcleo incandescente que incendeia inimigos e desfere críticos em alvos em chamas.",
        type = "weapon",
        rarity = "iconic",
        weight = 1250,
        max_stack = 1,
        image = "weapon_errata.png"
    },
    ["weapon_fang"] = {
        name = "Faca Tática Fang",
        description = "Faca de arremesso que prende o alvo ao chão e bloqueia mobilidade motora.",
        type = "weapon",
        rarity = "iconic",
        weight = 300,
        max_stack = 1,
        image = "weapon_fang.png"
    },
    ["weapon_fanged_axe"] = {
        name = "Machado Tático Fanged Axe",
        description = "Machadinha leve com dentes serrilhados para desmembramento rápido.",
        type = "weapon",
        rarity = "rare",
        weight = 1400,
        max_stack = 1,
        image = "weapon_fanged_axe.png"
    },
    ["weapon_fanged_axe_xmod2"] = {
        name = "Fanged Axe x-MOD2",
        description = "Machado icônico customizado com balanceamento perfeito de arremesso.",
        type = "weapon",
        rarity = "iconic",
        weight = 1550,
        max_stack = 1,
        image = "weapon_fanged_axe_xmod2.png"
    },
    ["weapon_fenrir"] = {
        name = "M221 Saratoga Fenrir",
        description = "Submetralhadora icônica dos Maelstrom que cospe fogo e causa dano térmico contínuo.",
        type = "weapon",
        rarity = "iconic",
        weight = 2950,
        max_stack = 1,
        image = "weapon_fenrir.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_foxhound"] = {
        name = "Tsunami Foxhound",
        description = "Rifle sniper Smart avançado com trava de mira instantânea e compensação de vento.",
        type = "weapon",
        rarity = "iconic",
        weight = 6900,
        max_stack = 1,
        image = "weapon_foxhound.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_genjiroh"] = {
        name = "HJKE-11 Yukimura Genjiroh",
        description = "Pistola Smart que dispara rajadas de 4 microbalas elétricas e persegue alvos em cobertura.",
        type = "weapon",
        rarity = "iconic",
        weight = 1250,
        max_stack = 1,
        image = "weapon_genjiroh.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_gold_plated_bat"] = {
        name = "Taco Banhado a Ouro de Denny",
        description = "Taco de beisebol com carcaça de ouro maciço e alto valor de atordoamento.",
        type = "weapon",
        rarity = "iconic",
        weight = 1300,
        max_stack = 1,
        image = "weapon_gold_plated_bat.png"
    },
    ["weapon_grad"] = {
        name = "Techtronika SPT32 Grad",
        description = "Rifle antimaterial pesado de ferrolho. Um disparo penetra paredes espessas e motores de AV.",
        type = "weapon",
        rarity = "epic",
        weight = 8900,
        max_stack = 1,
        image = "weapon_grad.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_gris_gris"] = {
        name = "Tsunami Gris-Gris",
        description = "Revólver Tech com recarga eletrostática automática e chance de penetração cibernética.",
        type = "weapon",
        rarity = "iconic",
        weight = 1750,
        max_stack = 1,
        image = "weapon_gris_gris.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_grit"] = {
        name = "Lexington Grit",
        description = "Pistola automática modificada por operadores dos Valentinos para rajadas estáveis.",
        type = "weapon",
        rarity = "iconic",
        weight = 1150,
        max_stack = 1,
        image = "weapon_grit.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_guillotine"] = {
        name = "Midnight Arms Guillotine",
        description = "Submetralhadora compacta com cadência feroz ideal para tiroteios em interiores.",
        type = "weapon",
        rarity = "uncommon",
        weight = 2600,
        max_stack = 1,
        image = "weapon_guillotine.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_guillotine_xmod2"] = {
        name = "Midnight Arms Guillotine x-MOD2",
        description = "Versão customizada com câmara polida e controle térmico de sobreaquecimento.",
        type = "weapon",
        rarity = "iconic",
        weight = 2750,
        max_stack = 1,
        image = "weapon_guillotine_xmod2.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_guts"] = {
        name = "Carnage Guts de Rebecca",
        description = "A infame escopeta verde de Rebecca de Cyberpunk Edgerunners. Recuo descomunal e dano devastador.",
        type = "weapon",
        rarity = "iconic",
        weight = 5600,
        max_stack = 1,
        image = "weapon_guts.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_gwynbleidd"] = {
        name = "Espada de Aço Gwynbleidd",
        description = "Espada lendária gravada com runas antigas que inflige acertos críticos sucessivos.",
        type = "weapon",
        rarity = "iconic",
        weight = 1350,
        max_stack = 1,
        image = "weapon_gwynbleidd.png"
    },
    ["weapon_hammer"] = {
        name = "Marreta de Demolição Industrial",
        description = "Martelo de duas mãos de 5 kg com cabeça de ferro fundido para estilhaçar armaduras.",
        type = "weapon",
        rarity = "common",
        weight = 5200,
        max_stack = 1,
        image = "weapon_hammer.png"
    },
    ["weapon_hawk"] = {
        name = "Kyubi Hawk da Presidente Myers",
        description = "Fuzil de assalto semiautomático de alta precisão que enfraquece a defesa de quem é atingido.",
        type = "weapon",
        rarity = "iconic",
        weight = 3700,
        max_stack = 1,
        image = "weapon_hawk.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_headhunter"] = {
        name = "Punk Knife Headhunter",
        description = "Faca de arremesso que marca o alvo e multiplica dano na cabeça.",
        type = "weapon",
        rarity = "iconic",
        weight = 280,
        max_stack = 1,
        image = "weapon_headhunter.png"
    },
    ["weapon_headsman"] = {
        name = "M2038 The Headsman",
        description = "Tactician customizada que dispara duas vezes mais balotes com precisão cirúrgica.",
        type = "weapon",
        rarity = "iconic",
        weight = 4500,
        max_stack = 1,
        image = "weapon_headsman.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_her_majesty"] = {
        name = "Her Majesty de Alex",
        description = "Pistola tática com silenciador de nível militar FIA e retículo holográfico perfeito.",
        type = "weapon",
        rarity = "iconic",
        weight = 1280,
        max_stack = 1,
        image = "weapon_her_majesty.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_hercules"] = {
        name = "Hercules 3AX Prototype",
        description = "Fuzil de assalto Smart pesado de Dogtown que explode inimigos abatidos em nuvens químicas tóxicas.",
        type = "weapon",
        rarity = "iconic",
        weight = 4900,
        max_stack = 1,
        image = "weapon_hercules.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_hypercritical"] = {
        name = "SPT32 Hypercritical",
        description = "Rifle de precisão de alta potência que derruba os alvos e causa concussão instantânea.",
        type = "weapon",
        rarity = "iconic",
        weight = 9200,
        max_stack = 1,
        image = "weapon_hypercritical.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_igla"] = {
        name = "Rostović DB-4 Igla",
        description = "Escopeta clássica de dois canos basculantes com grande poder destrutivo imediato.",
        type = "weapon",
        rarity = "uncommon",
        weight = 3800,
        max_stack = 1,
        image = "weapon_igla.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_incineration"] = {
        name = "Escopeta Térmica Incineration",
        description = "Escopeta modificada com defletores incendiários para queimar alvos agrupados.",
        type = "weapon",
        rarity = "epic",
        weight = 4600,
        max_stack = 1,
        image = "weapon_incineration.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_jinchu_maru"] = {
        name = "Katana Jinchu-Maru de Oda",
        description = "Katana de alta tecnologia do guarda-costas pessoal de Hanako Arasaka, letal durante camuflagem óptica.",
        type = "weapon",
        rarity = "iconic",
        weight = 1200,
        max_stack = 1,
        image = "weapon_jinchu_maru.png"
    },
    ["weapon_johnnys_malorian"] = {
        name = "Malorian Arms 3516 de Johnny Silverhand",
        description = "A pistola icônica de Johnny com animação especial de recarga e disparo frontal de lança-chamas.",
        type = "weapon",
        rarity = "iconic",
        weight = 2150,
        max_stack = 1,
        image = "weapon_johnnys_malorian.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_kanabo"] = {
        name = "Kanabo Tático de Cerâmica",
        description = "Bastão japonês cravejado de duas mãos para quebrar ossos e ciberimplantes esqueléticos.",
        type = "weapon",
        rarity = "rare",
        weight = 3800,
        max_stack = 1,
        image = "weapon_kanabo.png"
    },
    ["weapon_kappa"] = {
        name = "Tsunami Kappa",
        description = "Pistola Smart leve com alta capacidade de manobra e cadência em rajadas curtas.",
        type = "weapon",
        rarity = "uncommon",
        weight = 890,
        max_stack = 1,
        image = "weapon_kappa.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_kappa_xmod2"] = {
        name = "Tsunami Kappa x-MOD2",
        description = "Versão customizada da Kappa com circuito neural acelerado de mira autônoma.",
        type = "weapon",
        rarity = "iconic",
        weight = 980,
        max_stack = 1,
        image = "weapon_kappa_xmod2.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_katana"] = {
        name = "Katana Tática Arasaka",
        description = "Lâmina monomolecular forjada em aço carbono e cerâmica reforçada para combates urbanos.",
        type = "weapon",
        rarity = "rare",
        weight = 1250,
        max_stack = 1,
        image = "weapon_katana.png"
    },
    ["weapon_kenshin"] = {
        name = "JKE-X2 Kenshin Tech Pistol",
        description = "Pistola Tech semiautomática japonesa de alta precisão e baixo recuo.",
        type = "weapon",
        rarity = "rare",
        weight = 1180,
        max_stack = 1,
        image = "weapon_kenshin.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_knife"] = {
        name = "Faca Militar Tática",
        description = "Faca de combate multifuncional de gume afiado e ponta tanto perfurante.",
        type = "weapon",
        rarity = "common",
        weight = 320,
        max_stack = 1,
        image = "weapon_knife.png"
    },
    ["weapon_kolac"] = {
        name = "Rostović Kolac Tech Shotgun",
        description = "Escopeta Tech de alto impacto que carrega balotes de choque eletromagnético.",
        type = "weapon",
        rarity = "epic",
        weight = 4500,
        max_stack = 1,
        image = "weapon_kolac.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_kongou"] = {
        name = "Liberty Kongou de Yorinobu",
        description = "Pistola Liberty modificada que permite ricochete de balas mesmo sem o implante de coprocessador balístico.",
        type = "weapon",
        rarity = "iconic",
        weight = 1220,
        max_stack = 1,
        image = "weapon_kongou.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_kukri"] = {
        name = "Facão Tático Kukri",
        description = "Lâmina curva pesada de aço para cortes com grande energia cinética.",
        type = "weapon",
        rarity = "uncommon",
        weight = 580,
        max_stack = 1,
        image = "weapon_kukri.png"
    },
    ["weapon_kyubi"] = {
        name = "Tsunami Kyubi",
        description = "Fuzil de assalto semiautomático japonês de cano longo e precisão inigualável.",
        type = "weapon",
        rarity = "rare",
        weight = 3550,
        max_stack = 1,
        image = "weapon_kyubi.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_kyubi_xmod2"] = {
        name = "Tsunami Kyubi x-MOD2",
        description = "Versão x-MOD2 com receptor reforçado e cano flutuante de precisão cirúrgica.",
        type = "weapon",
        rarity = "iconic",
        weight = 3700,
        max_stack = 1,
        image = "weapon_kyubi_xmod2.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_la_chingona_dorada"] = {
        name = "La Chingona Dorada de Jackie Welles",
        description = "Pistola Nue banhada a ouro e gravada com homenagens à Santa Muerte de Heywood.",
        type = "weapon",
        rarity = "iconic",
        weight = 1420,
        max_stack = 1,
        image = "weapon_la_chingona_dorada.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_laika"] = {
        name = "Techtronika Laika",
        description = "Revólver Tech com cano alargado e munição explosiva de alta velocidade.",
        type = "weapon",
        rarity = "iconic",
        weight = 2250,
        max_stack = 1,
        image = "weapon_laika.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_lexington"] = {
        name = "Militech M-10AF Lexington",
        description = "Pistola totalmente automática de baixo recuo. Excelente para defesa pessoal aproximada.",
        type = "weapon",
        rarity = "uncommon",
        weight = 1080,
        max_stack = 1,
        image = "weapon_lexington.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_lexington_silenced"] = {
        name = "Lexington Tática Silenciada",
        description = "Variante da Lexington equipada com silenciador de titânio integral para infiltração.",
        type = "weapon",
        rarity = "rare",
        weight = 1220,
        max_stack = 1,
        image = "weapon_lexington_silenced.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_lexington_xmod2"] = {
        name = "Militech Lexington x-MOD2",
        description = "Versão de competição da Lexington com controle excepcional de recuo automático.",
        type = "weapon",
        rarity = "iconic",
        weight = 1190,
        max_stack = 1,
        image = "weapon_lexington_xmod2.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_liberty"] = {
        name = "Constitutional Arms Liberty",
        description = "Pistola americana de calibre pesado .45 ACP com frame sólido de aço inoxidável.",
        type = "weapon",
        rarity = "common",
        weight = 1150,
        max_stack = 1,
        image = "weapon_liberty.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_lizzie"] = {
        name = "Omaha Lizzie dos Mox",
        description = "Pistola Tech rosa brilhante dos Mox que dispara rajadas quádruplas quando carregada.",
        type = "weapon",
        rarity = "iconic",
        weight = 1450,
        max_stack = 1,
        image = "weapon_lizzie.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_ma70"] = {
        name = "Militech MA70 HB Heavy Machine Gun",
        description = "Metralhadora pesada de cano grosso com supressão de área e capacidade de atravessar veículos.",
        type = "weapon",
        rarity = "rare",
        weight = 9800,
        max_stack = 1,
        image = "weapon_ma70.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_ma70_xmod2"] = {
        name = "Militech MA70 HB x-MOD2",
        description = "Versão aprimorada da MA70 com refrigeração criogênica e recuo amortecido.",
        type = "weapon",
        rarity = "iconic",
        weight = 10200,
        max_stack = 1,
        image = "weapon_ma70_xmod2.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_machete"] = {
        name = "Facão Machete de Selva",
        description = "Lâmina longa utilitária afiada para abrir caminho e decepar membros.",
        type = "weapon",
        rarity = "common",
        weight = 750,
        max_stack = 1,
        image = "weapon_machete.png"
    },
    ["weapon_machete_borg"] = {
        name = "Machete Borg Ciborgue",
        description = "Lâmina pesada reforçada com reforços de cromo e borda serrilhada monomolecular.",
        type = "weapon",
        rarity = "rare",
        weight = 920,
        max_stack = 1,
        image = "weapon_machete_borg.png"
    },
    ["weapon_malorian"] = {
        name = "Malorian Arms 3516 Padrão",
        description = "Pistola pesada de alta customização criada sob medida para combates urbanos letais.",
        type = "weapon",
        rarity = "legendary",
        weight = 2100,
        max_stack = 1,
        image = "weapon_malorian.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_mancinella"] = {
        name = "Overture Mancinella de Mr. Hands",
        description = "Revólver Overture com silenciador especial e balas de ponta oca envenenada.",
        type = "weapon",
        rarity = "iconic",
        weight = 1920,
        max_stack = 1,
        image = "weapon_mancinella.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_masamune"] = {
        name = "Arasaka HJSH-18 Masamune",
        description = "Fuzil de assalto de rajada tripla de elite utilizado pela segurança pessoal da família Arasaka.",
        type = "weapon",
        rarity = "epic",
        weight = 3650,
        max_stack = 1,
        image = "weapon_masamune.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_metel"] = {
        name = "Techtronika Metel",
        description = "Revólver Tech com câmara de recarga rápida e precisão militar de longa distância.",
        type = "weapon",
        rarity = "rare",
        weight = 1850,
        max_stack = 1,
        image = "weapon_metel.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_moron_labe"] = {
        name = "M251s Ajax Moron Labe",
        description = "Ajax personalizado que aumenta drasticamente a cadência e chance de desmembramento.",
        type = "weapon",
        rarity = "iconic",
        weight = 4100,
        max_stack = 1,
        image = "weapon_moron_labe.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_mox"] = {
        name = "Carnage The Mox de Judy",
        description = "Carnage com coronha acolchoada e acabamento personalizado que recarrega com velocidade estonteante.",
        type = "weapon",
        rarity = "iconic",
        weight = 5100,
        max_stack = 1,
        image = "weapon_mox.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_murphys_law"] = {
        name = "Porrete Murphy's Law",
        description = "Arma contundente eletrificada de Dogtown que derruba alvos com choques em cadeia.",
        type = "weapon",
        rarity = "iconic",
        weight = 1100,
        max_stack = 1,
        image = "weapon_murphys_law.webp"
    },
    ["weapon_nehan"] = {
        name = "Faca Nehan de Saburo Arasaka",
        description = "Faca cerimonial de Saburo Arasaka que causa hemorragia interna progressiva fatal.",
        type = "weapon",
        rarity = "iconic",
        weight = 290,
        max_stack = 1,
        image = "weapon_nehan.png"
    },
    ["weapon_nekomata"] = {
        name = "Techtronika SPT32 Nekomata",
        description = "Rifle sniper Tech de dois disparos de carga magnética que perfura paredes densas com facilidade.",
        type = "weapon",
        rarity = "rare",
        weight = 7900,
        max_stack = 1,
        image = "weapon_nekomata.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_neurotoxin_knife"] = {
        name = "Faca Neurotóxica de Precisão",
        description = "Faca com ranhura de infusão para venenos sintéticos paralisantes.",
        type = "weapon",
        rarity = "rare",
        weight = 310,
        max_stack = 1,
        image = "weapon_neurotoxin_knife.png"
    },
    ["weapon_nova"] = {
        name = "Darra Polytechnic DR5 Nova",
        description = "Revólver clássico de tambor de 6 tiros com excelente alcance e robustez mecânica.",
        type = "weapon",
        rarity = "common",
        weight = 1680,
        max_stack = 1,
        image = "weapon_nova.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_nowaki"] = {
        name = "Arasaka Nowaki",
        description = "Fuzil de assalto em rajadas balanceado para patrulhas corporativas de média distância.",
        type = "weapon",
        rarity = "uncommon",
        weight = 3500,
        max_stack = 1,
        image = "weapon_nowaki.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_nue"] = {
        name = "Tsunami Nue",
        description = "Pistola pesada japonesa com precisão cirúrgica e alto poder de parada.",
        type = "weapon",
        rarity = "rare",
        weight = 1350,
        max_stack = 1,
        image = "weapon_nue.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_o_five"] = {
        name = "SPT32 Grad O'Five",
        description = "Rifle sniper Grad modificado com munição de canhão explosiva capaz de pulverizar alvos.",
        type = "weapon",
        rarity = "iconic",
        weight = 9500,
        max_stack = 1,
        image = "weapon_o_five.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_ogou"] = {
        name = "Kang Tao A-22B Ogou",
        description = "Pistola Smart que dispara microprojéteis explosivos de fragmentação teleguiada.",
        type = "weapon",
        rarity = "iconic",
        weight = 1150,
        max_stack = 1,
        image = "weapon_ogou.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_old_pal"] = {
        name = "Revólver Old Pal",
        description = "Revólver Tech desgastado de Dogtown com velocidade de recarga e saque aprimorados.",
        type = "weapon",
        rarity = "iconic",
        weight = 1900,
        max_stack = 1,
        image = "weapon_old_pal.webp",
        ammoType = "ammo_handgun"
    },
    ["weapon_omaha"] = {
        name = "Militech Omaha Tech Pistol",
        description = "Pistola com acelerador magnético eletromagnético. Dispara rajadas de 3 tiros perfurantes.",
        type = "weapon",
        rarity = "rare",
        weight = 1380,
        max_stack = 1,
        image = "weapon_omaha.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_order"] = {
        name = "Rostović DB-2 Testera Order",
        description = "Escopeta Tech de dois canos que vaporiza alvos ao carregar o disparo com pulso elétrico.",
        type = "weapon",
        rarity = "iconic",
        weight = 4800,
        max_stack = 1,
        image = "weapon_order.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_osprey"] = {
        name = "Tsunami Osprey Sniper",
        description = "Sniper bullpup de Reed com estabilizador balístico e tiro em rajada precisa de 3 disparos.",
        type = "weapon",
        rarity = "iconic",
        weight = 7400,
        max_stack = 1,
        image = "weapon_osprey.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_overture"] = {
        name = "Malorian Arms Overture",
        description = "Revólver pesado tradicional de alta potência com recuo seco e impacto devastador.",
        type = "weapon",
        rarity = "rare",
        weight = 1720,
        max_stack = 1,
        image = "weapon_overture.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_overwatch"] = {
        name = "SPT32 Grad Overwatch de Panam",
        description = "O lendário rifle sniper com silenciador integrado sob medida fabricado pelos Aldecaldos.",
        type = "weapon",
        rarity = "iconic",
        weight = 8700,
        max_stack = 1,
        image = "weapon_overwatch.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_palica"] = {
        name = "Rostović DB-4 Palica Smart Shotgun",
        description = "Escopeta Smart basculante de dois canos que orienta os chumbos diretamente contra os alvos.",
        type = "weapon",
        rarity = "rare",
        weight = 4100,
        max_stack = 1,
        image = "weapon_palica.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_pariah"] = {
        name = "Pariah Silenced Tech Pistol de Reed",
        description = "Pistola Tech com silenciador exclusivo de agente secreto que dispara sem perda de recuo.",
        type = "weapon",
        rarity = "iconic",
        weight = 1420,
        max_stack = 1,
        image = "weapon_pariah.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_peacekeeper"] = {
        name = "Fuzil Peacekeeper Militar",
        description = "Fuzil de assalto tático militar com sistema de mira rápida holográfica.",
        type = "weapon",
        rarity = "epic",
        weight = 3700,
        max_stack = 1,
        image = "weapon_peacekeeper.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_phallustiff"] = {
        name = "Sir John Phallustiff de Meredith",
        description = "Bastão contundente vibratório elétrico hilário e surpreendentemente destruidor.",
        type = "weapon",
        rarity = "iconic",
        weight = 1200,
        max_stack = 1,
        image = "weapon_phallustiff.png"
    },
    ["weapon_pipe"] = {
        name = "Cano de Ferro Galvanizado",
        description = "Tubo metálico pesado recolhido em becos para autodefesa emergencial.",
        type = "weapon",
        rarity = "common",
        weight = 1450,
        max_stack = 1,
        image = "weapon_pipe.png"
    },
    ["weapon_pit_bull"] = {
        name = "Nokota Pit Bull Shotgun",
        description = "Escopeta de combate compacta para confrontos ferozes de curta distância.",
        type = "weapon",
        rarity = "iconic",
        weight = 4150,
        max_stack = 1,
        image = "weapon_pit_bull.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_pizdets"] = {
        name = "Rostović TKI-20 Pizdets",
        description = "Submetralhadora Smart com supressor embutido que acumula disparos rápidos e invisíveis.",
        type = "weapon",
        rarity = "iconic",
        weight = 2750,
        max_stack = 1,
        image = "weapon_pizdets.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_plan_b"] = {
        name = "Liberty Plan B de Dexter DeShawn",
        description = "Pistola personalizada que usa Eurodólares físicos da sua conta como munição.",
        type = "weapon",
        rarity = "iconic",
        weight = 1180,
        max_stack = 1,
        image = "weapon_plan_b.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_pozhar"] = {
        name = "Rostović Pozhar Auto-Shotgun",
        description = "Escopeta automática de tambor com alta taxa de disparo contínuo e dispersão esmagadora.",
        type = "weapon",
        rarity = "epic",
        weight = 4700,
        max_stack = 1,
        image = "weapon_pozhar.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_pozhar_xmod2"] = {
        name = "Rostović Pozhar x-MOD2",
        description = "Versão tunada da Pozhar com câmara compensada e carregador estendido.",
        type = "weapon",
        rarity = "iconic",
        weight = 4950,
        max_stack = 1,
        image = "weapon_pozhar_xmod2.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_prejudice"] = {
        name = "Masamune Prejudice de Rogue",
        description = "Fuzil Masamune com munição de penetração balística extrema que ricocheteia.",
        type = "weapon",
        rarity = "iconic",
        weight = 3850,
        max_stack = 1,
        image = "weapon_prejudice.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_pride"] = {
        name = "Liberty Pride de Rogue Amendiares",
        description = "Pistola personalizada que multiplica por 3x o dano de tiros na cabeça e acertos críticos.",
        type = "weapon",
        rarity = "iconic",
        weight = 1200,
        max_stack = 1,
        image = "weapon_pride.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_problem_solver"] = {
        name = "M221 Saratoga Problem Solver",
        description = "Submetralhadora com carregador duplo ampliado e a maior taxa de disparo por minuto de Night City.",
        type = "weapon",
        rarity = "iconic",
        weight = 3100,
        max_stack = 1,
        image = "weapon_problem_solver.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_psalm"] = {
        name = "Copperhead Psalm 11:6",
        description = "Fuzil de assalto customizado pelo Maelstrom com dano térmico incendiário em cada projétil.",
        type = "weapon",
        rarity = "iconic",
        weight = 3650,
        max_stack = 1,
        image = "weapon_psalm.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_pulsar"] = {
        name = "DS1 Pulsar SMG",
        description = "Submetralhadora leve de polímero com excelente equilíbrio entre cadência e manuseio.",
        type = "weapon",
        rarity = "common",
        weight = 2550,
        max_stack = 1,
        image = "weapon_pulsar.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_punk_knife"] = {
        name = "Faca Punk com Empunhadura Enfaixada",
        description = "Faca artesanal afiada balanceada para arremessos letais em becos.",
        type = "weapon",
        rarity = "common",
        weight = 270,
        max_stack = 1,
        image = "weapon_punk_knife.png"
    },
    ["weapon_pygargue"] = {
        name = "Tsunami Pygargue Sniper",
        description = "Rifle de precisão de longo alcance com estabilizador gravitacional de mira telescópica.",
        type = "weapon",
        rarity = "rare",
        weight = 7100,
        max_stack = 1,
        image = "weapon_pygargue.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_quasar"] = {
        name = "DR-12 Quasar Tech Revolver",
        description = "Revólver Tech com carregador de 20 tiros automático que descarrega rajadas contínuas carregadas.",
        type = "weapon",
        rarity = "epic",
        weight = 2350,
        max_stack = 1,
        image = "weapon_quasar.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_raiju"] = {
        name = "Senkoh LX Raiju",
        description = "Submetralhadora Tech que dispara rajadas de alta frequência e atravessa coberturas sem precisar carregar.",
        type = "weapon",
        rarity = "iconic",
        weight = 2850,
        max_stack = 1,
        image = "weapon_raiju.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_rasetsu"] = {
        name = "Tsunami Rasetsu Tech Sniper",
        description = "Rifle sniper de alta voltagem com balas que se curvam para acertar múltiplos alvos alinhados.",
        type = "weapon",
        rarity = "iconic",
        weight = 8400,
        max_stack = 1,
        image = "weapon_rasetsu.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_raygun"] = {
        name = "Protótipo Raygun",
        description = "Arma de energia experimental desenvolvida em laboratórios secretos corporativos.",
        type = "weapon",
        rarity = "iconic",
        weight = 1600,
        max_stack = 1,
        image = "weapon_raygun.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_riskit"] = {
        name = "Tsunami Riskit",
        description = "Pistola leve de manuseio extremo que garante críticos quando o atirador tem pouca vitalidade.",
        type = "weapon",
        rarity = "iconic",
        weight = 1100,
        max_stack = 1,
        image = "weapon_riskit.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_rook"] = {
        name = "Constitutional Arms Rook",
        description = "Pistola pesada com compensador frontal e trava de segurança tática avançada.",
        type = "weapon",
        rarity = "iconic",
        weight = 1300,
        max_stack = 1,
        image = "weapon_rook.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_rosco"] = {
        name = "Overture Rosco do Padre Ibarra",
        description = "Revólver Overture modificado que atira nas pernas do inimigo para imobilizar e permitir execuções.",
        type = "weapon",
        rarity = "iconic",
        weight = 1780,
        max_stack = 1,
        image = "weapon_rosco.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_saratoga"] = {
        name = "Midnight Arms M221 Saratoga",
        description = "Submetralhadora padrão militar confiável em todas as condições climáticas e poeira.",
        type = "weapon",
        rarity = "uncommon",
        weight = 2900,
        max_stack = 1,
        image = "weapon_saratoga.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_sasquatch_hammer"] = {
        name = "Martelo de Titânio da Sasquatch",
        description = "Marreta brutal empunhada pela líder dos Animals capaz de pulverizar concreto e cromo.",
        type = "weapon",
        rarity = "iconic",
        weight = 7800,
        max_stack = 1,
        image = "weapon_sasquatch_hammer.png"
    },
    ["weapon_satara"] = {
        name = "Rostović DB-2 Satara Tech Shotgun",
        description = "Escopeta Tech de dois canos que acelera projéteis eletromagneticamente para atravessar paredes.",
        type = "weapon",
        rarity = "rare",
        weight = 4850,
        max_stack = 1,
        image = "weapon_satara.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_satori"] = {
        name = "Katana Satori de Saburo Arasaka",
        description = "Espada secular com gume monomolecular perfeito que eleva o multiplicador de dano crítico a 500%.",
        type = "weapon",
        rarity = "iconic",
        weight = 1180,
        max_stack = 1,
        image = "weapon_satori.png"
    },
    ["weapon_scalpel"] = {
        name = "Katana Scalpel Cirúrgica",
        description = "Lâmina eletricamente energizada que atinge acertos críticos brutais durante Sandevistan.",
        type = "weapon",
        rarity = "iconic",
        weight = 1220,
        max_stack = 1,
        image = "weapon_scalpel.png"
    },
    ["weapon_senkoh"] = {
        name = "Arasaka Senkoh LX Tech SMG",
        description = "Submetralhadora Tech corporativa de rajadas de alta velocidade com disparos eletromagnéticos.",
        type = "weapon",
        rarity = "epic",
        weight = 2700,
        max_stack = 1,
        image = "weapon_senkoh.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_seraph"] = {
        name = "Liberty Seraph do Padre",
        description = "Pistola personalizada recebida do Padre Ibarra que inflige dano térmico incendiário contínuo.",
        type = "weapon",
        rarity = "iconic",
        weight = 1260,
        max_stack = 1,
        image = "weapon_seraph.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_shigure"] = {
        name = "Arasaka Shigure SMG",
        description = "Submetralhadora corporativa de baixo perfil com supressão de som avançada.",
        type = "weapon",
        rarity = "uncommon",
        weight = 2650,
        max_stack = 1,
        image = "weapon_shigure.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_shingen"] = {
        name = "Arasaka TKI-20 Shingen",
        description = "Submetralhadora Smart com processador de bordo para travar em 3 inimigos ao mesmo tempo.",
        type = "weapon",
        rarity = "rare",
        weight = 2800,
        max_stack = 1,
        image = "weapon_shingen.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_shingen_mark_v"] = {
        name = "Arasaka Shingen Mark V",
        description = "Versão protótipo da Shingen com balas incendiárias teleguiadas e mira avançada.",
        type = "weapon",
        rarity = "iconic",
        weight = 2950,
        max_stack = 1,
        image = "weapon_shingen_mark_v.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_sidewinder"] = {
        name = "D5 Sidewinder Smart Assault Rifle",
        description = "Fuzil de assalto Smart que orienta projéteis balísticos contornando cantos e obstáculos.",
        type = "weapon",
        rarity = "rare",
        weight = 3600,
        max_stack = 1,
        image = "weapon_sidewinder.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_skippy"] = {
        name = "Yukimura 'Skippy' Pistola com IA",
        description = "Pistola Smart lendária com personalidade própria falante e modos 'Assassino Frio' e 'Pacifista Cachorrinho'.",
        type = "weapon",
        rarity = "iconic",
        weight = 1200,
        max_stack = 1,
        image = "weapon_skippy.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_slaughtomatic"] = {
        name = "Budget Arms C-41 Slaughtomatic",
        description = "Pistola descartável de plástico vendida em máquinas de conveniência. Descarte após esvaziar o pente.",
        type = "weapon",
        rarity = "common",
        weight = 750,
        max_stack = 1,
        image = "weapon_slaughtomatic.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_sor22"] = {
        name = "Midnight Arms SOR-22 Precision Rifle",
        description = "Rifle de precisão pesado semiautomático com calibre de alta parada para atiradores de elite.",
        type = "weapon",
        rarity = "rare",
        weight = 4500,
        max_stack = 1,
        image = "weapon_sor22.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_sovereign"] = {
        name = "Rostović DB-4 Sovereign",
        description = "Escopeta de cano duplo serrada modificada que dispara ambos os canos instantaneamente ao atirar do quadril.",
        type = "weapon",
        rarity = "iconic",
        weight = 3950,
        max_stack = 1,
        image = "weapon_sovereign.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_sparky"] = {
        name = "SPT32 Sparky Sniper Silenciada",
        description = "Rifle sniper modificado em Dogtown que emite uma explosão elétrica ao atingir a cabeça.",
        type = "weapon",
        rarity = "iconic",
        weight = 8800,
        max_stack = 1,
        image = "weapon_sparky.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_stinger"] = {
        name = "Faca Stinger de Scorpion",
        description = "Faca de arremesso dos Aldecaldos com veneno químico que corrói os tecidos do alvo.",
        type = "weapon",
        rarity = "iconic",
        weight = 290,
        max_stack = 1,
        image = "weapon_stinger.png"
    },
    ["weapon_tactician"] = {
        name = "Rostović M2038 Tactician",
        description = "Escopeta de bombeamento de 8 cartuchos amplamente adotada pela polícia e forças táticas.",
        type = "weapon",
        rarity = "rare",
        weight = 4200,
        max_stack = 1,
        image = "weapon_tactician.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_taigan"] = {
        name = "Metel Taigan",
        description = "Revólver Tech de Dogtown com velocidade de disparo explosiva crescente a cada tiro acertado.",
        type = "weapon",
        rarity = "iconic",
        weight = 1950,
        max_stack = 1,
        image = "weapon_taigan.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_tamayura"] = {
        name = "Arasaka Tamayura",
        description = "Pistola pesada clássica dos oficiais executivos da Arasaka com grande autoridade de disparo.",
        type = "weapon",
        rarity = "rare",
        weight = 1400,
        max_stack = 1,
        image = "weapon_tamayura.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_tanto"] = {
        name = "Tanto Cerimonial Tático",
        description = "Adaga tradicional japonesa com lâmina reforçada para estocadas perfurantes rápidas.",
        type = "weapon",
        rarity = "rare",
        weight = 420,
        max_stack = 1,
        image = "weapon_tanto.png"
    },
    ["weapon_testera"] = {
        name = "Rostović DB-2 Testera",
        description = "Escopeta basculante de cano duplo calibre 12 com dispersão maciça para curta distância.",
        type = "weapon",
        rarity = "rare",
        weight = 4600,
        max_stack = 1,
        image = "weapon_testera.png",
        ammoType = "ammo_shotgun"
    },
    ["weapon_ticon"] = {
        name = "Militech Ticon Smart Handgun",
        description = "Pistola Smart de segurança corporativa com acoplamento biométrico e rastreio de alvos.",
        type = "weapon",
        rarity = "rare",
        weight = 1100,
        max_stack = 1,
        image = "weapon_ticon.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_tinker_bell"] = {
        name = "Porrete Tinker Bell de Peter Pan",
        description = "Bastão contundente com choque neural embutido que incapacita inimigos sem deixá-los em estado letal.",
        type = "weapon",
        rarity = "iconic",
        weight = 950,
        max_stack = 1,
        image = "weapon_tinker_bell.png"
    },
    ["weapon_tire_iron"] = {
        name = "Chave de Roda Automotiva",
        description = "Barra de aço cruzada para desparafusar rodas ou quebrar queixos em brigas de bar.",
        type = "weapon",
        rarity = "common",
        weight = 1750,
        max_stack = 1,
        image = "weapon_tire_iron.png"
    },
    ["weapon_tomahawk"] = {
        name = "Machadinha Tomahawk Nômade",
        description = "Machadinha leve de caça e combate corpo a corpo balanceada para arremessos precisos.",
        type = "weapon",
        rarity = "uncommon",
        weight = 850,
        max_stack = 1,
        image = "weapon_tomahawk.png"
    },
    ["weapon_tsumetogi"] = {
        name = "Katana Tsumetogi de Maiko",
        description = "Katana cerimonial dos Tyger Claws eletrificada que concede resistência a choques.",
        type = "weapon",
        rarity = "iconic",
        weight = 1180,
        max_stack = 1,
        image = "weapon_tsumetogi.png"
    },
    ["weapon_umbra"] = {
        name = "Darra Polytechnic Umbra",
        description = "Fuzil de assalto leve de produção econômica com alta cadência e carregador compacto.",
        type = "weapon",
        rarity = "uncommon",
        weight = 3300,
        max_stack = 1,
        image = "weapon_umbra.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_umbra_xmod2"] = {
        name = "Darra Polytechnic Umbra x-MOD2",
        description = "Versão militarizada da Umbra com câmara retrabalhada e trilhos para múltiplos acessórios.",
        type = "weapon",
        rarity = "iconic",
        weight = 3500,
        max_stack = 1,
        image = "weapon_umbra_xmod2.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_unity"] = {
        name = "Constitutional Arms Unity",
        description = "Pistola semiautomática de 9mm com armação de polímero. Confiável e onipresente em Night City.",
        type = "weapon",
        rarity = "common",
        weight = 1200,
        max_stack = 1,
        image = "weapon_unity.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_volkodav"] = {
        name = "Machete Térmico Volkodav",
        description = "Facão pesado de Dogtown com resistência de superaquecimento que incendeia inimigos atingidos.",
        type = "weapon",
        rarity = "iconic",
        weight = 1150,
        max_stack = 1,
        image = "weapon_volkodav.png"
    },
    ["weapon_warden"] = {
        name = "Rostović Warden Smart SMG",
        description = "Submetralhadora Smart soviética com rastreamento de alvos e alta penetração de curto alcance.",
        type = "weapon",
        rarity = "rare",
        weight = 2900,
        max_stack = 1,
        image = "weapon_warden.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_widow_maker"] = {
        name = "M-179e Achilles Widow Maker de Nash",
        description = "Rifle Tech que dispara dois projéteis carregados por ciclo e inflige envenenamento químico contínuo.",
        type = "weapon",
        rarity = "iconic",
        weight = 4450,
        max_stack = 1,
        image = "weapon_widow_maker.png",
        ammoType = "ammo_rifle"
    },
    ["weapon_yasha"] = {
        name = "Tsunami Yasha Smart Sniper",
        description = "Rifle sniper Smart de alta precisão com acabamento em pintura laqueada vermelha e branca.",
        type = "weapon",
        rarity = "iconic",
        weight = 7200,
        max_stack = 1,
        image = "weapon_yasha.png",
        ammoType = "ammo_sniper"
    },
    ["weapon_yinglong"] = {
        name = "Kang Tao G-58 Dian Yinglong",
        description = "Submetralhadora Smart lendária que gera arcos de pulso eletromagnético explosivo em acertos críticos.",
        type = "weapon",
        rarity = "iconic",
        weight = 2900,
        max_stack = 1,
        image = "weapon_yinglong.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_yukimura"] = {
        name = "Arasaka HJKE-11 Yukimura",
        description = "Pistola Smart de 3 canos com rastreamento avançado de micro-projéteis em alta velocidade.",
        type = "weapon",
        rarity = "epic",
        weight = 1150,
        max_stack = 1,
        image = "weapon_yukimura.png",
        ammoType = "ammo_handgun"
    },
    ["weapon_zhuo"] = {
        name = "Kang Tao L-69 Zhuo Smart Shotgun",
        description = "Escopeta Smart de 8 canos giratórios capaz de rastrear e alvejar até 8 inimigos ao mesmo tempo.",
        type = "weapon",
        rarity = "legendary",
        weight = 5400,
        max_stack = 1,
        image = "weapon_zhuo.png",
        ammoType = "ammo_shotgun"
    },

    -- =========================================================================
    -- VESTUÁRIO & ROUPAS (CABEÇA, ROSTO, JAQUETAS, CAMISAS, CALÇAS & CALÇADOS)
    -- =========================================================================
    ["clothing_face_cyber_monocle"] = {
        name = "Monóculo Cibernético Kang Tao",
        description = "Lente inteligente monocular com zoom óptico e leitor de dados térmicos.",
        type = "clothing",
        rarity = "epic",
        weight = 65,
        max_stack = 1,
        image = "clothing_face_visor.svg",
        slot = "face"
    },
    ["clothing_face_gasmask_hazmat"] = {
        name = "Máscara Filtrante NBQ Militar",
        description = "Máscara de gás de borracha vulcanizada com duplo cartucho de carvão ativado contra toxinas.",
        type = "clothing",
        rarity = "rare",
        weight = 480,
        max_stack = 1,
        image = "clothing_face_gasmask.svg",
        slot = "face"
    },
    ["clothing_face_glasses_johnny"] = {
        name = "Óculos Aviador de Johnny Silverhand",
        description = "Óculos de sol polarizados com armação dourada fina e lentes espelhadas avermelhadas.",
        type = "clothing",
        rarity = "iconic",
        weight = 42,
        max_stack = 1,
        image = "clothing_face_glasses.svg",
        slot = "face"
    },
    ["clothing_face_goggles_nomad"] = {
        name = "Óculos de Proteção contra Poeira",
        description = "Lentes com vedação de borracha para resistir às rajadas de areia das estradas do deserto.",
        type = "clothing",
        rarity = "common",
        weight = 110,
        max_stack = 1,
        image = "clothing_face_glasses.svg",
        slot = "face"
    },
    ["clothing_face_mask_maelstrom"] = {
        name = "Respirador Ocular Maelstrom",
        description = "Máscara industrial com válvulas de sucção e LEDs avermelhados de intimidação dos Maelstrom.",
        type = "clothing",
        rarity = "rare",
        weight = 420,
        max_stack = 1,
        image = "clothing_face_gasmask.svg",
        slot = "face"
    },
    ["clothing_face_neoprene_mask"] = {
        name = "Meia-Máscara de Neoprene",
        description = "Máscara de boca e nariz com filtro de partículas para motoristas de motos e runners.",
        type = "clothing",
        rarity = "common",
        weight = 70,
        max_stack = 1,
        image = "clothing_face_gasmask.svg",
        slot = "face"
    },
    ["clothing_face_shades_corpo"] = {
        name = "Óculos Escuros Executivos Arasaka",
        description = "Design retangular sóbrio em titânio preto fosco para diretores de corporações.",
        type = "clothing",
        rarity = "uncommon",
        weight = 48,
        max_stack = 1,
        image = "clothing_face_glasses.svg",
        slot = "face"
    },
    ["clothing_face_tech_visor_dogtown"] = {
        name = "Visor de Varredura Barghest",
        description = "Visor robusto reforçado dos soldados de Kurt Hansen com filtros de fumaça e visão noturna.",
        type = "clothing",
        rarity = "epic",
        weight = 160,
        max_stack = 1,
        image = "clothing_face_visor.svg",
        slot = "face"
    },
    ["clothing_face_visor_kiroshi"] = {
        name = "Visor Tático Holográfico Kiroshi",
        description = "Display montado sobre a ponte nasal com HUD de projeção de dados em tempo real.",
        type = "clothing",
        rarity = "rare",
        weight = 135,
        max_stack = 1,
        image = "clothing_face_visor.svg",
        slot = "face"
    },
    ["clothing_feet_boots_combat_militech"] = {
        name = "Botas Militares de Combate Militech",
        description = "Coturnos de alta resistência com sola tratorada antiderrapante e cano acolchoado.",
        type = "clothing",
        rarity = "rare",
        weight = 1700,
        max_stack = 1,
        image = "clothing_feet_boots.svg",
        slot = "feet"
    },
    ["clothing_feet_boots_cowboy_leather"] = {
        name = "Botas Texanas de Couro Heywood",
        description = "Botas pontudas tradicionais com bico de prata e esporas decorativas dos Valentinos.",
        type = "clothing",
        rarity = "uncommon",
        weight = 1450,
        max_stack = 1,
        image = "clothing_feet_boots.svg",
        slot = "feet"
    },
    ["clothing_feet_boots_steel_toe"] = {
        name = "Botas Industriais com Biqueira de Aço",
        description = "Calçado de segurança pesado com placa de aço forjado na ponta para proteção contra esmagamento.",
        type = "clothing",
        rarity = "common",
        weight = 2400,
        max_stack = 1,
        image = "clothing_feet_boots.svg",
        slot = "feet"
    },
    ["clothing_feet_boots_trauma_team"] = {
        name = "Botas Táticas Isolantes Trauma Team",
        description = "Botas operacionais com solado com isolamento térmico e químico para resgate em áreas radioativas.",
        type = "clothing",
        rarity = "epic",
        weight = 1380,
        max_stack = 1,
        image = "clothing_feet_boots.svg",
        slot = "feet"
    },
    ["clothing_feet_boots_yaiba_biker"] = {
        name = "Botas de Alta Performance Yaiba",
        description = "Botas aerodinâmicas para pilotos de motos de alta cilindrada com protetores laterais de tornozelo.",
        type = "clothing",
        rarity = "rare",
        weight = 1600,
        max_stack = 1,
        image = "clothing_feet_boots.svg",
        slot = "feet"
    },
    ["clothing_feet_runners_aerodynamic"] = {
        name = "Tênis Ultraleves de Corrida de Carbono",
        description = "Tênis com placas propulsoras de fibra de carbono na entressola para arrancadas rápidas.",
        type = "clothing",
        rarity = "uncommon",
        weight = 640,
        max_stack = 1,
        image = "clothing_feet_shoes.svg",
        slot = "feet"
    },
    ["clothing_feet_shoes_corpo_oxford"] = {
        name = "Sapatos Sociais Oxford em Verniz Jinguji",
        description = "Calçado executivo de luxo forrado em couro italiano com acabamento polido reluzente.",
        type = "clothing",
        rarity = "rare",
        weight = 890,
        max_stack = 1,
        image = "clothing_feet_shoes.svg",
        slot = "feet"
    },
    ["clothing_feet_sneakers_exostyle"] = {
        name = "Tênis Streetwear Futurista Exostyle",
        description = "Tênis esportivo com amortecedores pneumáticos visíveis e solado luminoso em LED.",
        type = "clothing",
        rarity = "common",
        weight = 920,
        max_stack = 1,
        image = "clothing_feet_shoes.svg",
        slot = "feet"
    },
    ["clothing_feet_sneakers_high_top"] = {
        name = "Tênis Cano Alto Vintage Anos 2000",
        description = "Clássico tênis de cano alto em lona grossa e borracha com cadarços reforçados.",
        type = "clothing",
        rarity = "common",
        weight = 1050,
        max_stack = 1,
        image = "clothing_feet_shoes.svg",
        slot = "feet"
    },
    ["clothing_feet_tactical_exo_boots"] = {
        name = "Botas com Exoesqueleto Barghest",
        description = "Botas de infantaria de Dogtown integradas a micro-pistões que reduzem o impacto de quedas altas.",
        type = "clothing",
        rarity = "epic",
        weight = 2100,
        max_stack = 1,
        image = "clothing_feet_boots.svg",
        slot = "feet"
    },
    ["clothing_head_balaclava_tactical"] = {
        name = "Balaclava Anti-Rastreamento Facial",
        description = "Máscara justa em poliamida que confunde câmeras de reconhecimento de vigilância urbana.",
        type = "clothing",
        rarity = "uncommon",
        weight = 120,
        max_stack = 1,
        image = "clothing_head_mask.svg",
        slot = "head"
    },
    ["clothing_head_bandana_nomad"] = {
        name = "Bandana Nômade dos Aldecaldos",
        description = "Tecido de algodão resistente para filtrar a poeira das tempestades de areia nas Badlands.",
        type = "clothing",
        rarity = "common",
        weight = 75,
        max_stack = 1,
        image = "clothing_head_mask.svg",
        slot = "head"
    },
    ["clothing_head_beanie_trauma"] = {
        name = "Touca Térmica Trauma Team",
        description = "Gorro tático confeccionado em lã sintética e fibras elásticas de contenção térmica.",
        type = "clothing",
        rarity = "rare",
        weight = 90,
        max_stack = 1,
        image = "clothing_head_hat.svg",
        slot = "head"
    },
    ["clothing_head_beret_militia"] = {
        name = "Boina Militar da 6th Street",
        description = "Boina de lã verde-oliva com broche patriótico dos veteranos de Santo Domingo.",
        type = "clothing",
        rarity = "common",
        weight = 130,
        max_stack = 1,
        image = "clothing_head_hat.svg",
        slot = "head"
    },
    ["clothing_head_cap_samurai"] = {
        name = "Boné Vintage Turnê Samurai 2020",
        description = "Boné de aba curva desgastado com bordado da banda Samurai e logotipo de chamas.",
        type = "clothing",
        rarity = "rare",
        weight = 110,
        max_stack = 1,
        image = "clothing_head_hat.svg",
        slot = "head"
    },
    ["clothing_head_cowboy_hat"] = {
        name = "Chapéu de Couro Texano Heywood",
        description = "Chapéu de abas largas moldado em couro bovino legítimo com faixa trançada.",
        type = "clothing",
        rarity = "uncommon",
        weight = 280,
        max_stack = 1,
        image = "clothing_head_hat.svg",
        slot = "head"
    },
    ["clothing_head_helmet_arasaka"] = {
        name = "Capacete Balístico Avançado Arasaka",
        description = "Proteção craniana corporativa integral com forro anti-impacto e pintura em preto fosco.",
        type = "clothing",
        rarity = "epic",
        weight = 1600,
        max_stack = 1,
        image = "clothing_head_helmet.svg",
        slot = "head"
    },
    ["clothing_head_helmet_biker"] = {
        name = "Capacete Integral Yaiba Kusanagi",
        description = "Capacete aerodinâmico de motociclista com viseira espelhada e vedação hermética contra vento.",
        type = "clothing",
        rarity = "uncommon",
        weight = 1450,
        max_stack = 1,
        image = "clothing_head_helmet.svg",
        slot = "head"
    },
    ["clothing_head_helmet_militech"] = {
        name = "Capacete Tático de Combate Militech",
        description = "Capacete militar em fibra de aramida e compósito cerâmico com trilhos para acessórios.",
        type = "clothing",
        rarity = "rare",
        weight = 1500,
        max_stack = 1,
        image = "clothing_head_helmet.svg",
        slot = "head"
    },
    ["clothing_head_hood_netrunner"] = {
        name = "Capuz Isolante Netrunner",
        description = "Capuz com trama de fios de cobre blindados para dissipar pulsos eletromagnéticos no crânio.",
        type = "clothing",
        rarity = "epic",
        weight = 220,
        max_stack = 1,
        image = "clothing_head_mask.svg",
        slot = "head"
    },
    ["clothing_inner_hoodie_nightcity"] = {
        name = "Moletom Streetwear com Capuz NC",
        description = "Blusão de moletom grosso de algodão com bolso canguru e grafismo urbano nos braços.",
        type = "clothing",
        rarity = "common",
        weight = 680,
        max_stack = 1,
        image = "clothing_inner_hoodie.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_linen_shirt_watson"] = {
        name = "Camisa de Linho Despojada de Watson",
        description = "Camisa casual de tecido leve aberta no colarinho, perfeita para o clima denso de Little China.",
        type = "clothing",
        rarity = "common",
        weight = 210,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_shirt_corporate_silk"] = {
        name = "Camisa Social de Seda Arasaka",
        description = "Camisa de botão cinza-carvão em seda pura com corte italiano para executivos de alto escalão.",
        type = "clothing",
        rarity = "rare",
        weight = 220,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_shirt_samurai"] = {
        name = "Camiseta da Turnê Samurai 2020",
        description = "Camiseta de algodão preto macio com o icônico demônio oni estampado no peito.",
        type = "clothing",
        rarity = "rare",
        weight = 180,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_shirt_tactical_compression"] = {
        name = "Camisa Tática de Compressão Militech",
        description = "Tecido sintético antibacteriano com compressão muscular que ajuda na dissipação de calor.",
        type = "clothing",
        rarity = "uncommon",
        weight = 260,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_subdermal_vest"] = {
        name = "Colete Íntimo Ultrafino de Kevlar",
        description = "Camada interna discreta para usar sob camisas sociais garantindo defesa contra lâminas.",
        type = "clothing",
        rarity = "rare",
        weight = 950,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_suit_netrunner"] = {
        name = "Macacão Neural Netrunner Monomolecular",
        description = "Segunda pele condutiva com canais de resfriamento térmico para mergulhos na Net.",
        type = "clothing",
        rarity = "epic",
        weight = 780,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_tanktop_biker"] = {
        name = "Regata Canelada Desgastada Biker",
        description = "Regata de algodão simples com corte esportivo, confortável para pilotagem e dias quentes.",
        type = "clothing",
        rarity = "common",
        weight = 140,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_tanktop_trauma"] = {
        name = "Top Esportivo Dry-Fit Trauma Team",
        description = "Regata técnica em poliamida com alta respirabilidade usada sob o uniforme operacional.",
        type = "clothing",
        rarity = "uncommon",
        weight = 150,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_inner_tshirt_mox"] = {
        name = "Camiseta Estampada Lizzie's Bar",
        description = "Camiseta colorida com arte dos Mox em rosa e ciano, estilosa e provocativa.",
        type = "clothing",
        rarity = "uncommon",
        weight = 175,
        max_stack = 1,
        image = "clothing_inner_shirt.svg",
        slot = "torso_inner"
    },
    ["clothing_legs_camo_badlands"] = {
        name = "Calça de Combate Camuflada Desértica",
        description = "Padrão de camuflagem militar árido para operações de patrulha e caça nas terras áridas.",
        type = "clothing",
        rarity = "uncommon",
        weight = 1050,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_cargo_militech"] = {
        name = "Calça Cargo Militar Ripstop Militech",
        description = "Calça tática militar com 10 bolsos utilitários reforçados com costura dupla anti-rasgo.",
        type = "clothing",
        rarity = "uncommon",
        weight = 1100,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_combat_heavy"] = {
        name = "Calça Balística Pesada NCPD Swat",
        description = "Calça de intervenção tática blindada com bolsos para carregadores extras e acolchoamento pélvico.",
        type = "clothing",
        rarity = "epic",
        weight = 2100,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_jeans_nomad"] = {
        name = "Jeans Reforçado dos Aldecaldos",
        description = "Jeans bruto resistente com manchas de poeira e reforço de lona nas coxas.",
        type = "clothing",
        rarity = "common",
        weight = 880,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_jogger_streetwear"] = {
        name = "Calça Jogger Streetwear Neon",
        description = "Calça esportiva confortável com barras ajustadas em elástico e faixas luminosas nas laterais.",
        type = "clothing",
        rarity = "common",
        weight = 620,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_leather_spiked"] = {
        name = "Calça Punk com Tachas Maelstrom",
        description = "Calça de couro com correntes laterais e zíperes cromados de atitude hostil.",
        type = "clothing",
        rarity = "rare",
        weight = 1950,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_pants_biker_leather"] = {
        name = "Calça de Couro Reforçada Biker",
        description = "Calça de pilotagem com inserções de placas de titânio nos joelhos e canelas.",
        type = "clothing",
        rarity = "rare",
        weight = 1650,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_pants_jinguji"] = {
        name = "Calça Social Nobre Jinguji",
        description = "Peça de alfaiataria fina confeccionada com lã de vicunha e forro antimicrobiano.",
        type = "clothing",
        rarity = "legendary",
        weight = 580,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_legs_shorts_runner"] = {
        name = "Shorts Esportivo de Corrida",
        description = "Bermuda de secagem ultra-rápida ideal para treinos atléticos e mobilidade máxima.",
        type = "clothing",
        rarity = "common",
        weight = 190,
        max_stack = 1,
        image = "clothing_legs_shorts.svg",
        slot = "legs"
    },
    ["clothing_legs_slacks_corporate"] = {
        name = "Calça Social de Alfaiataria Arasaka",
        description = "Calça social elegante com caimento impecável e tecido com acabamento acetinado resistente a rugas.",
        type = "clothing",
        rarity = "rare",
        weight = 520,
        max_stack = 1,
        image = "clothing_legs_pants.svg",
        slot = "legs"
    },
    ["clothing_outer_coat_arasaka_corpo"] = {
        name = "Sobretudo Executivo Blindado Arasaka",
        description = "Casaco longo de lã pura forrado com entretela de fios de titânio flexível para proteção discreta.",
        type = "clothing",
        rarity = "epic",
        weight = 2600,
        max_stack = 1,
        image = "clothing_outer_coat.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_coat_trauma_team"] = {
        name = "Jaqueta de Intervenção Trauma Team AV",
        description = "Traje impermeável de alta visibilidade verde e branco com bolsos médicos modulares.",
        type = "clothing",
        rarity = "epic",
        weight = 2400,
        max_stack = 1,
        image = "clothing_outer_coat.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_jacket_aldecaldos"] = {
        name = "Jaqueta Bolero dos Aldecaldos",
        description = "Jaqueta de couro rústico curtida ao sol com brasão do clã e reforço nas mangas.",
        type = "clothing",
        rarity = "rare",
        weight = 2100,
        max_stack = 1,
        image = "clothing_outer_jacket.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_jacket_edgerunner"] = {
        name = "Jaqueta Bomber Edgerunner",
        description = "Jaqueta amarela fluorescente com faixa refletiva inspirada no traje EMT de David Martinez.",
        type = "clothing",
        rarity = "iconic",
        weight = 1850,
        max_stack = 1,
        image = "clothing_outer_jacket.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_jacket_samurai"] = {
        name = "Jaqueta Crystaljock Réplica Samurai",
        description = "A lendária jaqueta bomber de couro com gola iluminada em azul neon e logo da banda Samurai nas costas.",
        type = "clothing",
        rarity = "iconic",
        weight = 2200,
        max_stack = 1,
        image = "clothing_outer_jacket.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_jacket_spiked_punk"] = {
        name = "Jaqueta Punk com Espinhos Maelstrom",
        description = "Couro pesado com rebites afiados de aço e pintura desgastada com slogans anarquistas.",
        type = "clothing",
        rarity = "rare",
        weight = 2900,
        max_stack = 1,
        image = "clothing_outer_jacket.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_parka_badlands"] = {
        name = "Parka Térmica das Badlands",
        description = "Casaco grosso acolchoado para enfrentar o frio congelante do deserto durante as noites.",
        type = "clothing",
        rarity = "common",
        weight = 1750,
        max_stack = 1,
        image = "clothing_outer_coat.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_suit_jacket_luxury"] = {
        name = "Paletó de Seda Blindada Jinguji",
        description = "Alfaiataria exclusiva da boutique Jinguji com forro balístico monomolecular de altíssimo luxo.",
        type = "clothing",
        rarity = "legendary",
        weight = 1200,
        max_stack = 1,
        image = "clothing_outer_jacket.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_tactical_harness"] = {
        name = "Arnês Tático Modular de Operações",
        description = "Suspensório militar reforçado com pontos de ancoragem para coldres de saque rápido e granadas.",
        type = "clothing",
        rarity = "uncommon",
        weight = 1400,
        max_stack = 1,
        image = "clothing_outer_vest.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_vest_heavy_tactical"] = {
        name = "Colete Balístico Nível IV com Placas",
        description = "Colete tático pesado com placas de cerâmica e kevlar capaz de conter tiros de fuzil militar.",
        type = "clothing",
        rarity = "epic",
        weight = 4800,
        max_stack = 1,
        image = "clothing_outer_vest.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_vest_light_ncpd"] = {
        name = "Colete Tático Leve da NCPD",
        description = "Colete de patrulha urbana em camadas de aramida leve para mobilidade e proteção básica.",
        type = "clothing",
        rarity = "uncommon",
        weight = 2300,
        max_stack = 1,
        image = "clothing_outer_vest.svg",
        slot = "torso_outer"
    },
    ["clothing_outer_windbreaker_street"] = {
        name = "Corta-Vento Holográfico Streetwear",
        description = "Jaqueta leve de náilon reflexivo com estampas de neon vibrantes dos distritos comerciais.",
        type = "clothing",
        rarity = "common",
        weight = 520,
        max_stack = 1,
        image = "clothing_outer_jacket.svg",
        slot = "torso_outer"
    },

    -- =========================================================================
    -- IMPLANTES & CIBERWARE (ÓPTICOS, SISTEMA NERVOSO, ESQUELETO, BRAÇOS & OS)
    -- =========================================================================
    ["arasaka_cyberdeck_mk3"] = {
        name = "Cyberdeck Arasaka Mk.3",
        description = "Processador neural avançado de invasão cibernética capaz de executar múltiplos daemons.",
        type = "cyberware",
        rarity = "epic",
        weight = 980,
        max_stack = 1,
        image = "cyberdeck.svg",
    },
    ["ballistic_coprocessor"] = {
        name = "Coprocessador Balístico de Mão",
        description = "Módulo de tiro que calcula e exibe trajetórias visuais de ricochete para armas convencionais.",
        type = "cyberware",
        rarity = "uncommon",
        weight = 240,
        max_stack = 1,
        image = "cyber_arms.svg",
    },
    ["bioconductor_mk1"] = {
        name = "Biocondutor Zetatech Mk.1",
        description = "Acelera a taxa de recarga e arrefecimento de todos os ciberimplantes em 15%.",
        type = "cyberware",
        rarity = "rare",
        weight = 200,
        max_stack = 1,
        image = "cyber_brain.svg",
    },
    ["biomonitor_dynalar"] = {
        name = "Biomonitor Circulatório Dynalar",
        description = "Injeta medicação curativa automaticamente quando os vitais caem abaixo de 15%.",
        type = "cyberware",
        rarity = "rare",
        weight = 320,
        max_stack = 1,
        image = "cyber_heart.svg",
    },
    ["detoxifier"] = {
        name = "Desintoxicador Metabólico",
        description = "Módulo de filtragem renal sintética que anula intoxicações e venenos químicos.",
        type = "cyberware",
        rarity = "rare",
        weight = 420,
        max_stack = 1,
        image = "cyber_skeleton.svg",
    },
    ["gorilla_arms"] = {
        name = "Braços de Gorila Reforçados",
        description = "Pistões hidráulicos nos membros superiores para socos brutais e arrombamento de portas pesadas.",
        type = "cyberware",
        rarity = "epic",
        weight = 3200,
        max_stack = 1,
        image = "cyber_arms.svg",
    },
    ["kerenzikov_mk1"] = {
        name = "Sistema Nervoso Kerenzikov Mk.1",
        description = "Desacelera a percepção do tempo ao mirar durante esquivas, escorregões ou pulos.",
        type = "cyberware",
        rarity = "rare",
        weight = 380,
        max_stack = 1,
        image = "cyber_brain.svg",
    },
    ["kiroshi_optics_mk1"] = {
        name = "Kiroshi Optics Mk.1",
        description = "Visão tática digital com scanner biomonitor e identificador de ameaças.",
        type = "cyberware",
        rarity = "common",
        weight = 240,
        max_stack = 1,
        image = "cyber_eye.svg",
    },
    ["kiroshi_optics_mk2"] = {
        name = "Kiroshi Optics Mk.2",
        description = "Zoom óptico quádruplo aprimorado e análise preditiva de trajetórias balísticas.",
        type = "cyberware",
        rarity = "rare",
        weight = 250,
        max_stack = 1,
        image = "cyber_eye.svg",
    },
    ["kiroshi_optics_stalker"] = {
        name = "Kiroshi 'Stalker' Mk.3",
        description = "Penetração sensorial em espectro termográfico através de fumaça e coberturas leves.",
        type = "cyberware",
        rarity = "legendary",
        weight = 260,
        max_stack = 1,
        image = "cyber_eye.svg",
    },
    ["lynx_paws"] = {
        name = "Patas de Lince Silenciadoras",
        description = "Almofadas sintéticas na sola dos pés que abafam 100% do barulho de passos ao caminhar e correr.",
        type = "cyberware",
        rarity = "epic",
        weight = 1100,
        max_stack = 1,
        image = "cyber_legs.svg",
    },
    ["mantis_blades"] = {
        name = "Lâminas Mantis em Carbono",
        description = "Lâminas retráteis afiadas instaladas nos antebraços para golpes de retalhamento rápidos.",
        type = "cyberware",
        rarity = "epic",
        weight = 2400,
        max_stack = 1,
        image = "cyber_arms.svg",
    },
    ["memory_boost_mk2"] = {
        name = "Amplificador de Memória Dynalar",
        description = "Otimiza a taxa de recuperação de memória RAM cibernética ao abater alvos.",
        type = "cyberware",
        rarity = "epic",
        weight = 210,
        max_stack = 1,
        image = "cyber_brain.svg",
    },
    ["militech_sandevistan_mk4"] = {
        name = "Militech Sandevistan Mk.4",
        description = "Acelerador de medula espinhal de ponta que desacelera 75% da velocidade do mundo por 12 segundos.",
        type = "cyberware",
        rarity = "iconic",
        weight = 1500,
        max_stack = 1,
        image = "cyber_brain.svg",
    },
    ["monowire"] = {
        name = "Monocabo Fatiador de Pulso",
        description = "Filamento de fibra monomolecular de espessura de um átomo que chicoteia e fatia grupos de alvos.",
        type = "cyberware",
        rarity = "rare",
        weight = 480,
        max_stack = 1,
        image = "cyber_arms.svg",
    },
    ["optical_camo_mk1"] = {
        name = "Camuflagem Óptica Arasaka",
        description = "Nanofibras corporais de desvio de fótons que concedem invisibilidade temporária ativa.",
        type = "cyberware",
        rarity = "legendary",
        weight = 850,
        max_stack = 1,
        image = "camo_device.svg",
    },
    ["pain_editor"] = {
        name = "Editor de Dor Neural",
        description = "Bloqueador sináptico que reduz todo o dano físico e contundente recebido em 10%.",
        type = "cyberware",
        rarity = "epic",
        weight = 180,
        max_stack = 1,
        image = "cyber_brain.svg",
    },
    ["projectile_launch_system"] = {
        name = "Lançador Subdérmico de Projéteis",
        description = "Canhão embutido no braço capaz de disparar ogivas explosivas, tranquilizantes ou incendiárias.",
        type = "cyberware",
        rarity = "epic",
        weight = 3400,
        max_stack = 1,
        image = "cyber_arms.svg",
    },
    ["reinforced_tendons"] = {
        name = "Tendões Reforçados de Salto",
        description = "Atuadores pneumáticos de alta pressão nas pernas que permitem a execução de salto duplo no ar.",
        type = "cyberware",
        rarity = "rare",
        weight = 1350,
        max_stack = 1,
        image = "cyber_legs.svg",
    },
    ["second_heart_mk1"] = {
        name = "Segundo Coração Moore Tech",
        description = "Prótese de suporte cardiovascular que reanima instantaneamente o portador de parada cardíaca letal.",
        type = "cyberware",
        rarity = "legendary",
        weight = 1600,
        max_stack = 1,
        image = "cyber_heart.svg",
    },
    ["smart_link"] = {
        name = "Conector Palmar Smart Link Arasaka",
        description = "Interface dérmica na palma da mão para guiar e comunicar com armas com miras inteligentes.",
        type = "cyberware",
        rarity = "rare",
        weight = 280,
        max_stack = 1,
        image = "cyber_arms.svg",
    },
    ["subdermal_armor_mk1"] = {
        name = "Armadura Subdérmica Militech",
        description = "Malha de aramida e titânio tecida sob a epiderme aumentando a blindagem corporal geral.",
        type = "cyberware",
        rarity = "common",
        weight = 1800,
        max_stack = 1,
        image = "cyber_skeleton.svg",
    },
    ["synaptic_accelerator"] = {
        name = "Acelerador Sináptico Reflexivo",
        description = "Dilata o tempo momentaneamente no exato segundo em que você é detectado por inimigos.",
        type = "cyberware",
        rarity = "uncommon",
        weight = 290,
        max_stack = 1,
        image = "cyber_brain.svg",
    },
    ["titanium_bones"] = {
        name = "Estrutura Óssea de Titânio",
        description = "Reforço osteometálico completo que eleva substancialmente a capacidade de peso suportada.",
        type = "cyberware",
        rarity = "rare",
        weight = 3500,
        max_stack = 1,
        image = "cyber_skeleton.svg",
    },

    -- =========================================================================
    -- COLETÁVEIS, SUCATAS & DATASHARDS
    -- =========================================================================
    ["ashtray_neon"] = {
        name = "Cinzeiro de Vidro Manchado de Neon",
        description = "Cinzeiro maciço e pesado recolhido de um bar decadente em Watson.",
        type = "misc",
        rarity = "common",
        weight = 380,
        max_stack = 10,
        image = "ashtray.svg",
    },
    ["broken_kiroshi"] = {
        name = "Lente Ocular Kiroshi Quebrada",
        description = "Módulo óptico com o cristal quebrado recolhido de carcaças descartadas.",
        type = "misc",
        rarity = "common",
        weight = 90,
        max_stack = 20,
        image = "cyber_eye.svg",
    },
    ["burnt_copper_wiring"] = {
        name = "Fios de Cobre Tostados",
        description = "Rolo de fiação elétrica com isolamento derretido por curto-circuito.",
        type = "misc",
        rarity = "common",
        weight = 85,
        max_stack = 30,
        image = "component_common.svg"
    },
    ["burnt_cyberware"] = {
        name = "Restos de Ciberimplante Queimado",
        description = "Circuito integrado carbonizado com conexões de solda derretidas por sobretensão elétrica.",
        type = "misc",
        rarity = "common",
        weight = 280,
        max_stack = 20,
        image = "cyber_skeleton.svg",
    },
    ["cassette_tape"] = {
        name = "Fita Cassete Magnética Vintage",
        description = "Fita de áudio analógica antiga gravada com gravações piratas dos clubes dos anos 2000.",
        type = "misc",
        rarity = "uncommon",
        weight = 60,
        max_stack = 10,
        image = "cassette_tape.svg",
    },
    ["chrome_dice"] = {
        name = "Par de Dados de Cassino em Cromo",
        description = "Dados de seis faces com pontos esculpidos em laser de um cassino clandestino de Pacifica.",
        type = "misc",
        rarity = "rare",
        weight = 28,
        max_stack = 5,
        image = "chrome_dice.svg",
    },
    ["crushed_can"] = {
        name = "Lata de Refrigerante Amassada",
        description = "Sucata de alumínio prensada pronta para ser descartada ou reciclada.",
        type = "misc",
        rarity = "common",
        weight = 15,
        max_stack = 50,
        image = "crushed_can.svg",
    },
    ["diamond_ring"] = {
        name = "Anel de Platina com Diamante Sintético",
        description = "Joia fina com diamante clonado em laboratório de alta pureza e lapidação perfeita.",
        type = "misc",
        rarity = "epic",
        weight = 18,
        max_stack = 5,
        image = "jewelry_ring.svg",
    },
    ["empty_bottle"] = {
        name = "Garrafa de Vidro Vazia",
        description = "Garrafa reciclável de bebida que pode ser vendida ou usada como arma improvisada.",
        type = "misc",
        rarity = "common",
        weight = 320,
        max_stack = 20,
        image = "empty_bottle.svg",
    },
    ["fried_motherboard"] = {
        name = "Placa-Mãe Industrial Fritada",
        description = "Circuito impresso antigo com chips queimados com vestígios de ligas de solda aproveitáveis.",
        type = "misc",
        rarity = "common",
        weight = 160,
        max_stack = 20,
        image = "microchip.svg"
    },
    ["gang_patch_6thstreet"] = {
        name = "Broche Patriótico da 6th Street",
        description = "Distintivo em metal com as estrelas e listras dos milicianos de Santo Domingo.",
        type = "misc",
        rarity = "uncommon",
        weight = 30,
        max_stack = 10,
        image = "gang_patch.svg",
    },
    ["gang_patch_maelstrom"] = {
        name = "Placa Facial Cromada Maelstrom",
        description = "Fragmento metálico arrancado de um ciborgue fanático do Northside.",
        type = "misc",
        rarity = "uncommon",
        weight = 120,
        max_stack = 10,
        image = "gang_patch.svg",
    },
    ["gang_patch_tygerclaws"] = {
        name = "Faixa Cerimonial dos Tyger Claws",
        description = "Faixa de seda bordada com kanjis tradicionais e garras de tigre dos mercenários de Japantown.",
        type = "misc",
        rarity = "uncommon",
        weight = 40,
        max_stack = 10,
        image = "gang_patch.svg",
    },
    ["gang_patch_valentinos"] = {
        name = "Emblema Bordado dos Valentinos",
        description = "Patch de jaqueta com a cruz sagrada e rosa vermelha dos membros de Heywood.",
        type = "misc",
        rarity = "uncommon",
        weight = 35,
        max_stack = 10,
        image = "gang_patch.svg",
    },
    ["gold_necklace"] = {
        name = "Corrente Pesada de Ouro 18k",
        description = "Colar de elos grossos em ouro maciço com excelente valor de revenda.",
        type = "misc",
        rarity = "epic",
        weight = 45,
        max_stack = 5,
        image = "jewelry_necklace.svg",
    },
    ["guitar_pick_silverhand"] = {
        name = "Palheta de Guitarra de Johnny Silverhand",
        description = "Palheta desgastada usada nas apresentações lendárias do grupo Samurai.",
        type = "misc",
        rarity = "iconic",
        weight = 3,
        max_stack = 10,
        image = "guitar_pick.svg",
    },
    ["military_dog_tags"] = {
        name = "Plaquetas de Identificação Militares",
        description = "Dog tags de latão de um soldado das Guerras Corporativas com número de série gravado.",
        type = "misc",
        rarity = "uncommon",
        weight = 35,
        max_stack = 10,
        image = "military_dog_tags.svg",
    },
    ["mystery_pill"] = {
        name = "Pílula Misteriosa de Beco",
        description = "Comprimido de cor indefinida e origem desconhecida recolhido nos becos de Kabuki.",
        type = "misc",
        rarity = "common",
        weight = 2,
        max_stack = 50,
        image = "biogel.svg"
    },
    ["neon_keychain"] = {
        name = "Chaveiro com Holograma de Night City",
        description = "Chaveiro luminoso que projeta uma silhueta tridimensional brilhante da metrópole.",
        type = "misc",
        rarity = "common",
        weight = 40,
        max_stack = 10,
        image = "keychain.svg",
    },
    ["pack_of_cigarettes"] = {
        name = "Maço de Cigarros Amassado",
        description = "Embalagem plástica com alguns cigarros de tabaco sintético restantes.",
        type = "misc",
        rarity = "common",
        weight = 25,
        max_stack = 10,
        image = "cigarettes.svg",
    },
    ["shard"] = {
        name = "Datashard Encriptado",
        description = "Dispositivo de armazenamento óptico de dados com especificações de engenharia e blueprints.",
        type = "misc",
        rarity = "uncommon",
        weight = 20,
        max_stack = 20,
        image = "shard.png"
    },
    ["shard_arasaka"] = {
        name = "Datashard Corporativo Arasaka",
        description = "Chip óptico confidencial vermelho e preto selado com biomarcadores da família Arasaka.",
        type = "misc",
        rarity = "epic",
        weight = 22,
        max_stack = 20,
        image = "shard.png"
    },
    ["shard_militech"] = {
        name = "Datashard Militar Militech",
        description = "Mídia de dados protegida por criptografia de grau militar contendo relatórios operacionais.",
        type = "misc",
        rarity = "rare",
        weight = 22,
        max_stack = 20,
        image = "shard.png"
    },
    ["shard_netwatch"] = {
        name = "Datashard de Investigação Netwatch",
        description = "Dispositivo criptografado de agentes da rede contendo registros de IAs rebeldes além da Blackwall.",
        type = "misc",
        rarity = "epic",
        weight = 25,
        max_stack = 20,
        image = "shard.png"
    },
    ["tarot_card_fool"] = {
        name = "Carta de Tarô: O Louco",
        description = "Representa o início da jornada de um mercenário desconhecido em busca de uma lenda.",
        type = "misc",
        rarity = "rare",
        weight = 5,
        max_stack = 10,
        image = "tarot_card.svg",
    },
    ["tarot_card_magician"] = {
        name = "Carta de Tarô: O Mago",
        description = "Símbolo de controle, manipulação e o domínio sobre a tecnologia e o destino.",
        type = "misc",
        rarity = "rare",
        weight = 5,
        max_stack = 10,
        image = "tarot_card.svg",
    },
    ["tarot_card_sun"] = {
        name = "Carta de Tarô: O Sol",
        description = "A promessa de liberdade, glória eterna e esperança além do horizonte da cidade.",
        type = "misc",
        rarity = "rare",
        weight = 5,
        max_stack = 10,
        image = "tarot_card.svg",
    },
    ["tarot_card_world"] = {
        name = "Carta de Tarô: O Mundo",
        description = "A totalidade e a conclusão definitiva dos ciclos de Night City.",
        type = "misc",
        rarity = "rare",
        weight = 5,
        max_stack = 10,
        image = "tarot_card.svg",
    },
    ["tarot_deck"] = {
        name = "Baralho de Tarô de Night City",
        description = "Conjunto de cartas ilustradas com as figuras misteriosas pintadas nos muros da metrópole.",
        type = "misc",
        rarity = "rare",
        weight = 140,
        max_stack = 5,
        image = "tarot_card.svg",
    },
    ["teddy_bear_worn"] = {
        name = "Ursinho de Pelúcia Desgastado",
        description = "Brinquedo antigo com costuras refeitas e um olho de botão. Uma lembrança comovente.",
        type = "misc",
        rarity = "uncommon",
        weight = 210,
        max_stack = 3,
        image = "teddy_bear.svg",
    },
    ["vintage_watch"] = {
        name = "Relógio Suíço Analógico Pré-Guerra",
        description = "Relógio mecânico de corda automática com ponteiros de safira que ainda funcionam com precisão.",
        type = "misc",
        rarity = "legendary",
        weight = 115,
        max_stack = 3,
        image = "vintage_watch.svg",
    },
    ["vinyl_samurai"] = {
        name = "Disco de Vinil Chippin' In - Banda Samurai",
        description = "Prensagem original de vinil da música icônica de Johnny Silverhand e Kerry Eurodyne.",
        type = "misc",
        rarity = "iconic",
        weight = 180,
        max_stack = 5,
        image = "vinyl_record.svg",
    },
    ["zippo_lighter"] = {
        name = "Isqueiro Vintage Prateado",
        description = "Isqueiro de latão cromado com mecanismo de faísca e pavio a óleo. Uma raridade mecânica.",
        type = "misc",
        rarity = "uncommon",
        weight = 65,
        max_stack = 5,
        image = "lighter.svg",
    },

    -- =========================================================================
    -- MATERIAIS DE FABRICAÇÃO & COMPONENTES DE CRAFTING
    -- =========================================================================
    ["ballistic_plate"] = {
        name = "Chapa de Aço Balístico",
        description = "Placa de blindagem temperada para inserção em coletes táticos e portas de veículos blindados.",
        type = "crafting_material",
        rarity = "rare",
        weight = 650,
        max_stack = 50,
        image = "ballistic_plate.svg",
    },
    ["component_common"] = {
        name = "Componente Comum (Tier 1)",
        description = "Fios de cobre, placas básicas e carcaças plásticas para montagem geral.",
        type = "crafting_material",
        rarity = "common",
        weight = 10,
        max_stack = 1000,
        image = "component_common.svg"
    },
    ["component_epic"] = {
        name = "Componente Épico (Tier 4)",
        description = "Compostos poliméricos militares e nano-fiação de ouro puro.",
        type = "crafting_material",
        rarity = "epic",
        weight = 25,
        max_stack = 250,
        image = "component_epic.svg"
    },
    ["component_legendary"] = {
        name = "Componente Lendário (Tier 5)",
        description = "Materiais experimentais de nível aeroespacial e ligas de titânio cristalino.",
        type = "crafting_material",
        rarity = "legendary",
        weight = 30,
        max_stack = 100,
        image = "component_legendary.svg"
    },
    ["component_rare"] = {
        name = "Componente Raro (Tier 3)",
        description = "Filamentos de fibra de carbono e relés semicondutores avançados.",
        type = "crafting_material",
        rarity = "rare",
        weight = 20,
        max_stack = 500,
        image = "component_rare.svg"
    },
    ["component_uncommon"] = {
        name = "Componente Incomum (Tier 2)",
        description = "Ligas de alumínio aeronáutico e solda condutiva de precisão.",
        type = "crafting_material",
        rarity = "uncommon",
        weight = 15,
        max_stack = 1000,
        image = "component_uncommon.svg"
    },
    ["graphene_tape"] = {
        name = "Fita Isolante Térmica de Grafeno",
        description = "Fita adesiva condutiva de calor de alta performance para resfriamento de canos e módulos.",
        type = "crafting_material",
        rarity = "rare",
        weight = 60,
        max_stack = 100,
        image = "component_rare.svg"
    },
    ["gunpowder"] = {
        name = "Pólvora Sintética Refinada",
        description = "Composto propulsor granulado de combustão limpa para fabricação de munições balísticas.",
        type = "crafting_material",
        rarity = "common",
        weight = 5,
        max_stack = 1000,
        image = "gunpowder.svg"
    },
    ["metal_scrap"] = {
        name = "Sucata Metálica Reciclável",
        description = "Pedaços estruturais de aço e chapas descartadas das indústrias pesadas de Watson.",
        type = "crafting_material",
        rarity = "common",
        weight = 50,
        max_stack = 500,
        image = "metal_scrap.svg"
    },
    ["microchip"] = {
        name = "Microprocessador IC-77",
        description = "Chip lógico integrado utilizado na programação de circuitos de armas inteligentes e biomonitores.",
        type = "crafting_material",
        rarity = "rare",
        weight = 50,
        max_stack = 200,
        image = "microchip.svg"
    },
    ["quickhack_comp_tier1"] = {
        name = "Componente de Hack Rápido (Tier 1)",
        description = "Rotinas criptográficas básicas e bibliotecas de ataque de força bruta.",
        type = "crafting_material",
        rarity = "common",
        weight = 5,
        max_stack = 500,
        image = "quickhack_tier.svg",
    },
    ["quickhack_comp_tier2"] = {
        name = "Componente de Hack Rápido (Tier 2)",
        description = "Sub-rotinas de desvio de firewalls e códigos de injeção sináptica.",
        type = "crafting_material",
        rarity = "uncommon",
        weight = 8,
        max_stack = 500,
        image = "quickhack_tier.svg",
    },
    ["quickhack_comp_tier3"] = {
        name = "Componente de Hack Rápido (Tier 3)",
        description = "Scripts polimórficos de exploração de vulnerabilidades zero-day corporativas.",
        type = "crafting_material",
        rarity = "rare",
        weight = 12,
        max_stack = 300,
        image = "quickhack_tier.svg",
    },
    ["quickhack_comp_tier4"] = {
        name = "Componente de Hack Rápido (Tier 4)",
        description = "Daemons autônomos de penetração de gelo ICE e sobrecarga de barramentos neurais.",
        type = "crafting_material",
        rarity = "epic",
        weight = 15,
        max_stack = 200,
        image = "quickhack_tier.svg",
    },
    ["quickhack_comp_tier5"] = {
        name = "Componente de Hack Rápido (Tier 5)",
        description = "Algoritmos quânticos militares avançados desenvolvidos para derrubar servidores centrais.",
        type = "crafting_material",
        rarity = "legendary",
        weight = 20,
        max_stack = 100,
        image = "quickhack_tier.svg",
    },
    ["raw_biogel_flask"] = {
        name = "Frasco de Biogel Puro Não-Refinado",
        description = "Matriz biológica acelular de cicatrização concentrada antes da filtragem farmacêutica.",
        type = "crafting_material",
        rarity = "rare",
        weight = 180,
        max_stack = 50,
        image = "biogel.svg"
    },
    ["synthetic_nanofiber"] = {
        name = "Rolo de Nanofibra Sintética",
        description = "Fibras de carbono entrelaçadas de altíssima tensão usadas na tecelagem de roupas blindadas.",
        type = "crafting_material",
        rarity = "uncommon",
        weight = 40,
        max_stack = 200,
        image = "component_uncommon.svg"
    },
    ["upgrade_part"] = {
        name = "Módulo de Aprimoramento Mecânico",
        description = "Conjunto de atuadores pneumáticos e reguladores de pressão para calibração de armamentos.",
        type = "crafting_material",
        rarity = "rare",
        weight = 100,
        max_stack = 200,
        image = "upgrade_part.svg"
    },

    -- =========================================================================
    -- ECONOMIA & MOEDA
    -- =========================================================================
    ["credchip_blank"] = {
        name = "CredChip Virgem Formatado",
        description = "Chip financeiro magnético desprovido de chaves para transferências anônimas de fundos.",
        type = "misc",
        rarity = "common",
        weight = 15,
        max_stack = 50,
        image = "credchip.svg",
    },
    ["credchip_encrypted"] = {
        name = "CredChip Criptografado",
        description = "Dispositivo bancário bloqueado com saldo protegido por senha criptográfica.",
        type = "misc",
        rarity = "rare",
        weight = 20,
        max_stack = 20,
        image = "credchip.svg",
    },
    ["eddis"] = {
        name = "Eurodólares Físicos (E$)",
        description = "Cédulas plásticas impermeáveis emitidas pelo Banco Central de Night City.",
        type = "currency",
        rarity = "uncommon",
        weight = 0,
        max_stack = 10000000,
        image = "eddis.svg"
    },
}
