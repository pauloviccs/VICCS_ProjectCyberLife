import re
import os

catalog_path = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_inventory\shared\items_catalog.lua"
images_dir = r"c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\images"

with open(catalog_path, "r", encoding="utf-8") as f:
    text = f.read()

images = re.findall(r'image\s*=\s*["\']([^"\']+)["\']', text)
unique_images = sorted(list(set(images)))
existing_files = set(f.lower() for f in os.listdir(images_dir))

missing = [img for img in unique_images if img.lower() not in existing_files]

print(f"Total unique images referenced in catalog: {len(unique_images)}")
print(f"Total files in images dir: {len(existing_files)}")
print(f"Missing images count: {len(missing)}")
if missing:
    print("Missing images:")
    for m in missing:
        print(f"  - {m}")
else:
    print("All referenced images exist in the images folder!")

# Also list items with missing images
item_matches = re.findall(r'\["([^"]+)"\]\s*=\s*\{([^}]+)\}', text)
items_missing = []
for item_id, body in item_matches:
    img_m = re.search(r'image\s*=\s*["\']([^"\']+)["\']', body)
    if not img_m:
        items_missing.append((item_id, "NO_IMAGE_PROPERTY"))
    elif img_m.group(1).lower() not in existing_files:
        items_missing.append((item_id, img_m.group(1)))

print(f"\nItems without valid image: {len(items_missing)}")
for item_id, img in items_missing[:30]:
    print(f"  Item: {item_id} -> {img}")
if len(items_missing) > 30:
    print(f"  ... and {len(items_missing) - 30} more")
