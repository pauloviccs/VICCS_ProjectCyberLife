import re
from collections import defaultdict

catalog_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_inventory\shared\items_catalog.lua"

with open(catalog_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

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

by_image = defaultdict(list)
for item_id, data in items.items():
    img = data.get("image", "none")
    by_image[img].append((item_id, data.get("name", "sem nome"), data.get("type", "unknown")))

print("=== ITENS COM default_item.svg (61 itens) ===")
for item_id, name, itype in by_image["default_item.svg"]:
    print(f"  [{item_id}] ({itype}) - {name}")

print("\n=== ITENS COM shard.png (29 itens) ===")
for item_id, name, itype in by_image["shard.png"]:
    print(f"  [{item_id}] ({itype}) - {name}")
