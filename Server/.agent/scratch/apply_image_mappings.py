import re
import os

items_mapping = {
    # CLOTHING HEAD
    "clothing_head_helmet_arasaka": "clothing_head_helmet.svg",
    "clothing_head_helmet_biker": "clothing_head_helmet.svg",
    "clothing_head_helmet_militech": "clothing_head_helmet.svg",
    "clothing_head_cap_samurai": "clothing_head_hat.svg",
    "clothing_head_cowboy_hat": "clothing_head_hat.svg",
    "clothing_head_beanie_trauma": "clothing_head_hat.svg",
    "clothing_head_beret_militia": "clothing_head_hat.svg",
    "clothing_head_balaclava_tactical": "clothing_head_mask.svg",
    "clothing_head_bandana_nomad": "clothing_head_mask.svg",
    "clothing_head_hood_netrunner": "clothing_head_mask.svg",

    # CLOTHING FACE
    "clothing_face_glasses_johnny": "clothing_face_glasses.svg",
    "clothing_face_shades_corpo": "clothing_face_glasses.svg",
    "clothing_face_goggles_nomad": "clothing_face_glasses.svg",
    "clothing_face_visor_kiroshi": "clothing_face_visor.svg",
    "clothing_face_tech_visor_dogtown": "clothing_face_visor.svg",
    "clothing_face_cyber_monocle": "clothing_face_visor.svg",
    "clothing_face_gasmask_hazmat": "clothing_face_gasmask.svg",
    "clothing_face_mask_maelstrom": "clothing_face_gasmask.svg",
    "clothing_face_neoprene_mask": "clothing_face_gasmask.svg",

    # CLOTHING OUTER
    "clothing_outer_jacket_samurai": "clothing_outer_jacket.svg",
    "clothing_outer_jacket_edgerunner": "clothing_outer_jacket.svg",
    "clothing_outer_jacket_aldecaldos": "clothing_outer_jacket.svg",
    "clothing_outer_jacket_spiked_punk": "clothing_outer_jacket.svg",
    "clothing_outer_suit_jacket_luxury": "clothing_outer_jacket.svg",
    "clothing_outer_windbreaker_street": "clothing_outer_jacket.svg",
    "clothing_outer_coat_arasaka_corpo": "clothing_outer_coat.svg",
    "clothing_outer_coat_trauma_team": "clothing_outer_coat.svg",
    "clothing_outer_parka_badlands": "clothing_outer_coat.svg",
    "clothing_outer_vest_heavy_tactical": "clothing_outer_vest.svg",
    "clothing_outer_vest_light_ncpd": "clothing_outer_vest.svg",
    "clothing_outer_tactical_harness": "clothing_outer_vest.svg",

    # CLOTHING INNER
    "clothing_inner_shirt_corporate_silk": "clothing_inner_shirt.svg",
    "clothing_inner_shirt_samurai": "clothing_inner_shirt.svg",
    "clothing_inner_tshirt_mox": "clothing_inner_shirt.svg",
    "clothing_inner_linen_shirt_watson": "clothing_inner_shirt.svg",
    "clothing_inner_shirt_tactical_compression": "clothing_inner_shirt.svg",
    "clothing_inner_tanktop_biker": "clothing_inner_shirt.svg",
    "clothing_inner_tanktop_trauma": "clothing_inner_shirt.svg",
    "clothing_inner_subdermal_vest": "clothing_inner_shirt.svg",
    "clothing_inner_suit_netrunner": "clothing_inner_shirt.svg",
    "clothing_inner_hoodie_nightcity": "clothing_inner_hoodie.svg",

    # CLOTHING LEGS
    "clothing_legs_cargo_militech": "clothing_legs_pants.svg",
    "clothing_legs_combat_heavy": "clothing_legs_pants.svg",
    "clothing_legs_jeans_nomad": "clothing_legs_pants.svg",
    "clothing_legs_jogger_streetwear": "clothing_legs_pants.svg",
    "clothing_legs_leather_spiked": "clothing_legs_pants.svg",
    "clothing_legs_pants_biker_leather": "clothing_legs_pants.svg",
    "clothing_legs_pants_jinguji": "clothing_legs_pants.svg",
    "clothing_legs_slacks_corporate": "clothing_legs_pants.svg",
    "clothing_legs_camo_badlands": "clothing_legs_pants.svg",
    "clothing_legs_shorts_runner": "clothing_legs_shorts.svg",

    # CLOTHING FEET
    "clothing_feet_boots_combat_militech": "clothing_feet_boots.svg",
    "clothing_feet_boots_cowboy_leather": "clothing_feet_boots.svg",
    "clothing_feet_boots_steel_toe": "clothing_feet_boots.svg",
    "clothing_feet_boots_trauma_team": "clothing_feet_boots.svg",
    "clothing_feet_boots_yaiba_biker": "clothing_feet_boots.svg",
    "clothing_feet_tactical_exo_boots": "clothing_feet_boots.svg",
    "clothing_feet_runners_aerodynamic": "clothing_feet_shoes.svg",
    "clothing_feet_shoes_corpo_oxford": "clothing_feet_shoes.svg",
    "clothing_feet_sneakers_exostyle": "clothing_feet_shoes.svg",
    "clothing_feet_sneakers_high_top": "clothing_feet_shoes.svg",

    # TAROT & MISC LOOT
    "tarot_card_fool": "tarot_card.svg",
    "tarot_card_magician": "tarot_card.svg",
    "tarot_card_sun": "tarot_card.svg",
    "tarot_card_world": "tarot_card.svg",
    "tarot_deck": "tarot_card.svg",
    "vinyl_samurai": "vinyl_record.svg",
    "vintage_watch": "vintage_watch.svg",
    "teddy_bear_worn": "teddy_bear.svg",
    "zippo_lighter": "lighter.svg",
    "pack_of_cigarettes": "cigarettes.svg",
    "chrome_dice": "chrome_dice.svg",
    "diamond_ring": "jewelry_ring.svg",
    "gold_necklace": "jewelry_necklace.svg",
    "military_dog_tags": "military_dog_tags.svg",
    "guitar_pick_silverhand": "guitar_pick.svg",
    "cassette_tape": "cassette_tape.svg",
    "ashtray_neon": "ashtray.svg",
    "crushed_can": "crushed_can.svg",
    "neon_keychain": "keychain.svg",
    "gang_patch_6thstreet": "gang_patch.svg",
    "gang_patch_maelstrom": "gang_patch.svg",
    "gang_patch_tygerclaws": "gang_patch.svg",
    "gang_patch_valentinos": "gang_patch.svg",
    "credchip_blank": "credchip.svg",
    "credchip_encrypted": "credchip.svg",

    # BEBIDAS
    "beer_arasaka_premium": "beer_bottle.svg",
    "beer_broseph_dark": "beer_bottle.svg",
    "beer_broseph_lager": "beer_bottle.svg",
    "absinthe_absolem": "liquor_bottle.svg",
    "whiskey_johnny_silverhand": "liquor_bottle.svg",
    "tequila_centzon": "liquor_bottle.svg",
    "vodka_jackie_welles": "liquor_bottle.svg",
    "rum_roaring_twenties": "liquor_bottle.svg",
    "wine_chateau_nightcity": "liquor_bottle.svg",
    "chromanticore": "soda_can.svg",
    "nicola_blue": "soda_can.svg",
    "nicola_sakura": "soda_can.svg",
    "slurm_synth": "soda_can.svg",
    "spunky_monkey": "soda_can.svg",
    "spunky_monkey_citrus": "soda_can.svg",
    "joy_tea": "tea_cup.svg",
    "tiancha_green_tea": "tea_cup.svg",
    "empty_bottle": "empty_bottle.svg",

    # COMIDAS
    "synth_burger": "burger.svg",
    "spicy_ramen": "ramen.svg",
    "synth_steak": "steak.svg",
    "synth_sushi": "sushi.svg",
    "tofu_skewer": "skewer.svg",
    "yakitori_allfoods": "skewer.svg",
    "moonchies_chips": "snack_chips.svg",
    "chocolate_synth": "snack_chips.svg",
    "combat_ration": "combat_ration.svg",
    "organic_apple": "apple.svg",
    "canned_dog_food": "pet_food.svg",
    "cat_food": "pet_food.svg",

    # CYBERWARE & MÉDICO
    "kiroshi_optics_mk1": "cyber_eye.svg",
    "kiroshi_optics_mk2": "cyber_eye.svg",
    "kiroshi_optics_stalker": "cyber_eye.svg",
    "broken_kiroshi": "cyber_eye.svg",
    "gorilla_arms": "cyber_arms.svg",
    "mantis_blades": "cyber_arms.svg",
    "monowire": "cyber_arms.svg",
    "projectile_launch_system": "cyber_arms.svg",
    "ballistic_coprocessor": "cyber_arms.svg",
    "smart_link": "cyber_arms.svg",
    "reinforced_tendons": "cyber_legs.svg",
    "lynx_paws": "cyber_legs.svg",
    "second_heart_mk1": "cyber_heart.svg",
    "biomonitor_dynalar": "cyber_heart.svg",
    "militech_sandevistan_mk4": "cyber_brain.svg",
    "kerenzikov_mk1": "cyber_brain.svg",
    "synaptic_accelerator": "cyber_brain.svg",
    "pain_editor": "cyber_brain.svg",
    "memory_boost_mk2": "cyber_brain.svg",
    "bioconductor_mk1": "cyber_brain.svg",
    "subdermal_armor_mk1": "cyber_skeleton.svg",
    "titanium_bones": "cyber_skeleton.svg",
    "detoxifier": "cyber_skeleton.svg",
    "burnt_cyberware": "cyber_skeleton.svg",
    "arasaka_cyberdeck_mk3": "cyberdeck.svg",
    "quickhack_comp_tier1": "quickhack_tier.svg",
    "quickhack_comp_tier2": "quickhack_tier.svg",
    "quickhack_comp_tier3": "quickhack_tier.svg",
    "quickhack_comp_tier4": "quickhack_tier.svg",
    "quickhack_comp_tier5": "quickhack_tier.svg",
    "optical_camo_mk1": "camo_device.svg",
    "surgical_medkit": "medkit_box.svg",
    "trauma_defibrillator": "medkit_box.svg",
    "ballistic_plate": "ballistic_plate.svg",
    "wet_wipes": "wet_wipes.svg"
}

# 1. Atualizar items_catalog.lua
catalog_lua_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_inventory\shared\items_catalog.lua"
with open(catalog_lua_path, "r", encoding="utf-8") as f:
    lua_lines = f.readlines()

new_lua_lines = []
cur_item = None
re_item_start = re.compile(r'^\s*\["([^"]+)"\]\s*=\s*\{')

lua_replacements = 0
for line in lua_lines:
    m = re_item_start.match(line)
    if m:
        cur_item = m.group(1)
        new_lua_lines.append(line)
        continue

    if cur_item and cur_item in items_mapping:
        if re.search(r'image\s*=\s*["\'][^"\']+["\']', line):
            target_img = items_mapping[cur_item]
            indent = line[:len(line) - len(line.lstrip())]
            line = f'{indent}image = "{target_img}",\n'
            lua_replacements += 1
            cur_item = None  # replaced for this item
    
    if line.strip() in ("},", "}"):
        cur_item = None

    new_lua_lines.append(line)

with open(catalog_lua_path, "w", encoding="utf-8") as f:
    f.writelines(new_lua_lines)

print(f"Atualizado items_catalog.lua: {lua_replacements} referências de imagem atualizadas!")

# 2. Atualizar catalog.js
catalog_js_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\catalog.js"
with open(catalog_js_path, "r", encoding="utf-8") as f:
    js_lines = f.readlines()

new_js_lines = []
cur_item = None
re_js_item_start = re.compile(r'^\s*"([^"]+)":\s*\{')

js_replacements = 0
for line in js_lines:
    m = re_js_item_start.match(line)
    if m:
        cur_item = m.group(1)
        new_js_lines.append(line)
        continue

    if cur_item and cur_item in items_mapping:
        if re.search(r'"image":\s*["\'][^"\']+["\']', line):
            target_img = items_mapping[cur_item]
            indent = line[:len(line) - len(line.lstrip())]
            line = f'{indent}"image": "{target_img}",\n'
            js_replacements += 1
            cur_item = None

    if line.strip() in ("},", "}"):
        cur_item = None

    new_js_lines.append(line)

with open(catalog_js_path, "w", encoding="utf-8") as f:
    f.writelines(new_js_lines)

print(f"Atualizado catalog.js: {js_replacements} referências de imagem atualizadas!")
