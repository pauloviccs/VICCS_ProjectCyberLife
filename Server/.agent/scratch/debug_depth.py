import re

def debug_file(path):
    print(f"=== DEBUGGING {path} ===")
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
        
        # Strip comments
        line = re.sub(r'--.*$', '', line)
        line = re.sub(r'"[^"\\]*(?:\\.[^"\\]*)*"', '""', line)
        line = re.sub(r"'[^'\\]*(?:\\.[^'\\]*)*'", "''", line)
        
        tokens = re.findall(r'\b(?:function|then|do|repeat|end|until)\b', line)
        for t in tokens:
            old_depth = depth
            if t in ('function', 'then', 'do', 'repeat'):
                depth += 1
            elif t in ('end', 'until'):
                depth -= 1
            print(f"Line {idx+1}: {t} (depth {old_depth} -> {depth}) | {raw_line.strip()}")

debug_file(r'c:\Games\VICCS_CyberpunkServer\Server\resources\gamemodes\lifesim\ls_spawn\client\main.lua')
