import re
import os

img_dir = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\images"
existing = set(os.listdir(img_dir))
print(f"Total de arquivos na pasta images: {len(existing)}")

lua_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_inventory\shared\items_catalog.lua"
js_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\catalog.js"

for path, label in [(lua_path, "Lua Catalog"), (js_path, "JS Catalog")]:
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    
    # regex to find image = "..." or "image": "..."
    images = re.findall(r'["\']?image["\']?\s*[:=]\s*["\']([^"\']+)["\']', text)
    unique_images = set(images)
    missing = [img for img in unique_images if img not in existing]
    
    print(f"\n--- {label} ---")
    print(f"Total de declaracoes de image: {len(images)}")
    print(f"Imagens unicas referenciadas: {len(unique_images)}")
    print(f"Imagens faltando em disco: {len(missing)}")
    if missing:
        print(f"FALTANDO: {missing}")
    
    default_usage = [img for img in images if img == "default_item.svg"]
    print(f"Uso de default_item.svg: {len(default_usage)}")
