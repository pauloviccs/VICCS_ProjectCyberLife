with open(r'c:\Games\VICCS_CyberpunkServer\Server\open77-client.d.lua', 'r', encoding='utf-8') as f:
    for line in f:
        if 'function Open77.players.' in line or 'function Open77.session.' in line or 'function Open77.runtime.' in line:
            print(line.strip())
