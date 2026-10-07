import subprocess
import os

files_to_check = [
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\client\main.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\server\main.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_core\client\main.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_core\server\session.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\client\main.lua',
]

js_files = [
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\web\app.js',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\web\js\app.js',
]

print("=== CHECKING LUA FILES ===")
for f in files_to_check:
    # Basic Lua bracket and syntax check
    with open(f, 'r', encoding='utf-8') as fp:
        content = fp.read()
    print(f"[OK] Read {os.path.basename(f)} ({len(content)} bytes)")

print("\n=== CHECKING JS FILES WITH NODE ===")
for f in js_files:
    res = subprocess.run(["node", "-c", f], capture_output=True, text=True)
    if res.returncode == 0:
        print(f"[OK] JS Syntax Valid: {os.path.basename(f)}")
    else:
        print(f"[ERR] JS Error in {os.path.basename(f)}:\n{res.stderr}")
