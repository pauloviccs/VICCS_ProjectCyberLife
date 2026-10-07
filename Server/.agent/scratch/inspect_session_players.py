with open(r'c:\Games\VICCS_CyberpunkServer\Server\open77-client.d.lua', 'r', encoding='utf-8') as f:
    capture = False
    for line in f:
        if line.startswith('---@class Open77.session') or line.startswith('---@class Open77.players'):
            capture = True
        elif capture and line.startswith('---@class Open77.'):
            capture = False
        if capture:
            print(line.strip())
