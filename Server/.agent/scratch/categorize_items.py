import re
from collections import defaultdict

catalog_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_inventory\shared\items_catalog.lua"
with open(catalog_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

items = {}
cur_id = None
cur_data = {}

for line in lines:
    m_id = re.match(r'^\s*\["([^"]+)"\]\s*=\s*\{', line)
    if m_id:
        if cur_id: items[cur_id] = cur_data
        cur_id = m_id.group(1)
        cur_data = {"id": cur_id}
        continue
    if cur_id:
        m_img = re.search(r'image\s*=\s*["\']([^"\']+)["\']', line)
        if m_img: cur_data["image"] = m_img.group(1)
        m_name = re.search(r'name\s*=\s*["\']([^"\']+)["\']', line)
        if m_name: cur_data["name"] = m_name.group(1)
        m_type = re.search(r'type\s*=\s*["\']([^"\']+)["\']', line)
        if m_type: cur_data["type"] = m_type.group(1)
        if line.strip() in ("},", "}"):
            items[cur_id] = cur_data
            cur_id = None
            cur_data = {}

by_img = defaultdict(list)
for iid, data in items.items():
    by_img[data.get("image", "none")].append(data)

for img in ["default_item.svg", "shard.png", "microchip.svg", "water.png", "burrito.png", "upgrade_part.svg"]:
    print(f"\n==================== {img} ({len(by_img[img])} itens) ====================")
    for d in by_img[img]:
        print(f"  [{d['id']}] ({d.get('type')}) -> {d.get('name')}")
