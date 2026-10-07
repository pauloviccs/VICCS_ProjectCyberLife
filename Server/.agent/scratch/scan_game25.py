with open(r'c:\Games\VICCS_CyberpunkServer\Server\.agent\logs\25\game-console.log', 'r', encoding='utf-16le', errors='ignore') as f:
    for idx, line in enumerate(f):
        lower = line.lower()
        if any(k in lower for k in ['ls_spawn', 'ls_ui', 'ls_core', 'spawn', 'modal', 'webui', 'freeze', 'playerloaded', 'error', 'fail']):
            if not any(ign in lower for ign in ['sound', 'audiodevice', 'wscript']):
                print(f"{idx+1}: {line.strip()[:160]}")
