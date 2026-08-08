import os
import re

lib_dir = 'lib'
matches = []

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            if 'assets/images/boy.png' in content:
                # Find all occurrences
                lines = content.split('\n')
                for i, line in enumerate(lines):
                    if 'assets/images/boy.png' in line:
                        matches.append((filepath, i+1, line.strip()))

for filepath, line_num, line in matches:
    print(f"{filepath}:{line_num}: {line}")
