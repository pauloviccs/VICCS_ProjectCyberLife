import sys

with open(r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\web\js\app.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for idx, line in enumerate(lines):
    if 'spawn:open' in line or 'open' in line.lower() or 'function' in line:
        if 'open' in line.lower() or 'modal' in line.lower():
            print(f"{idx+1}: {line.strip()}")
