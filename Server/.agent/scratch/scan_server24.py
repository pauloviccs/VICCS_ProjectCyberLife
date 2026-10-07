import sys
sys.stdout.reconfigure(encoding='utf-8')

with open(r'c:\Games\VICCS_CyberpunkServer\Server\.agent\logs\24\server-console.log', 'r', encoding='utf-16le', errors='ignore') as f:
    for idx, line in enumerate(f):
        if any(k in line.lower() for k in ['spawn', 'player', 'session', 'load']):
            print(f"{idx+1}: {line.strip()[:160]}")
