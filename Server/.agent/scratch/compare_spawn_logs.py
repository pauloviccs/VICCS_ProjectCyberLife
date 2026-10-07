def print_spawn_logs(filepath, label):
    print(f"=== {label}: {filepath} ===")
    try:
        with open(filepath, 'r', encoding='utf-16le', errors='ignore') as f:
            for idx, line in enumerate(f):
                if 'ls_spawn' in line.lower() or 'spawn' in line.lower() and 'resource' in line.lower():
                    print(f"{idx+1}: {line.strip()[:160]}")
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

print_spawn_logs(r'c:\Games\VICCS_CyberpunkServer\Server\.agent\logs\24\game-console.log', "LOG 24 GAME")
print_spawn_logs(r'c:\Games\VICCS_CyberpunkServer\Server\.agent\logs\25\game-console.log', "LOG 25 GAME")
