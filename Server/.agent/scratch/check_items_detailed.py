import re
import os
from collections import Counter

catalog_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_inventory\shared\items_catalog.lua"
images_dir = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\images"

with open(catalog_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

existing_files = set(f.lower() for f in os.listdir(images_dir))

items = {}
current_id = None
current_data = {}

for line in lines:
    m_id = re.match(r'^\s*\["([^"]+)"\]\s*=\s*\{', line)
    if m_id:
        if current_id:
            items[current_id] = current_data
        current_id = m_id.group(1)
        current_data = {}
        continue
    
    if current_id:
        m_img = re.search(r'image\s*=\s*["\']([^"\']+)["\']', line)
        if m_img:
            current_data["image"] = m_img.group(1)
        
        m_name = re.search(r'name\s*=\s*["\']([^"\']+)["\']', line)
        if m_name:
            current_data["name"] = m_name.group(1)

        m_type = re.search(r'type\s*=\s*["\']([^"\']+)["\']', line)
        if m_type:
            current_data["type"] = m_type.group(1)

        if line.strip() == "}," or line.strip() == "}":
            items[current_id] = current_data
            current_id = None
            current_data = {}

if current_id:
    items[current_id] = current_data

image_counts = Counter(d.get("image") for d in items.values() if d.get("image"))

print("=== DISTRIBUIÇÃO DAS IMAGENS ===")
print("Top 15 imagens mais compartilhadas entre múltiplos itens:")
for img, cnt in image_counts.most_common(15):
    print(f"  - {img}: usada em {cnt} itens")

single_use = sum(1 for img, cnt in image_counts.items() if cnt == 1)
shared_use = sum(1 for img, cnt in image_counts.items() if cnt > 1)
print(f"\nImagens exclusivas (1 para 1 com o item): {single_use}")
print(f"Imagens compartilhadas (usadas por 2 ou mais itens): {shared_use}")
