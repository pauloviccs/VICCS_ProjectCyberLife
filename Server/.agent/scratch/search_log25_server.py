import sys

def search_log(filepath, terms):
    print(f"=== SEARCHING {filepath} ===")
    with open(filepath, 'r', encoding='utf-16le', errors='ignore') as f:
        for idx, line in enumerate(f):
            for t in terms:
                if t.lower() in line.lower():
                    print(f"{idx+1}: {line.strip()[:180]}")
                    break

search_log(r'c:\Games\VICCS_CyberpunkServer\Server\.agent\logs\25\server-console.log', 
           ['spawn', 'freeze', 'playerloaded', 'clientready', 'worldready', 'ready', 'open', 'session', 'h10'])
