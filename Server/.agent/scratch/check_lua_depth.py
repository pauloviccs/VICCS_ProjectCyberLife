import re

def check_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    depth = 0
    in_block_comment = False
    
    for idx, raw_line in enumerate(lines):
        line = raw_line.strip()
        if '--[[' in line:
            in_block_comment = True
        if in_block_comment:
            if ']]' in line:
                in_block_comment = False
            continue
        
        # Remove single line comments and strings
        line = re.sub(r'--.*$', '', line)
        line = re.sub(r'"[^"\\]*(?:\\.[^"\\]*)*"', '""', line)
        line = re.sub(r"'[^'\\]*(?:\\.[^'\\]*)*'", "''", line)
        
        # Replace elseif with nothing so 'then' in elseif doesn't double count
        line = re.sub(r'\belseif\b.*?\bthen\b', '', line)
        
        tokens = re.findall(r'\b(?:function|then|do|repeat|end|until)\b', line)
        for t in tokens:
            if t in ('function', 'then', 'do', 'repeat'):
                depth += 1
            elif t in ('end', 'until'):
                depth -= 1
        
        if depth < 0:
            print(f"[ERR] {path}:{idx+1} Negative depth! {tokens}")
            return False
            
    if depth != 0:
        print(f"[ERR] {path}: Non-zero final depth ({depth})")
        return False
    print(f"[OK] {path}: Balanced syntax (depth = 0)")
    return True

files = [
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\client\main.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\server\main.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_core\client\main.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_core\server\session.lua',
    r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_ui\client\main.lua',
]

for f in files:
    check_file(f)
