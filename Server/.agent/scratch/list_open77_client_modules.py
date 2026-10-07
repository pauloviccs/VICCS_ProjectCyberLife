with open(r'c:\Games\VICCS_CyberpunkServer\Server\open77-client.d.lua', 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('---@class Open77.'):
            print(line.strip())
