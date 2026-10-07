with open(r'c:\Games\VICCS_CyberpunkServer\Server\.agent\logs\25\game-console.log', 'r', encoding='utf-16le', errors='ignore') as f:
    for idx, line in enumerate(f):
        if any(k in line.lower() for k in ['appearance', 'shell-transition', 'readiness', 'ls_spawn']):
            print(f"{idx+1}: {line.strip()[:180]}")
