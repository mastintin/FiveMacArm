import sys

with open("scintilla.prg", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "METHOD SetTheme(" in line:
        skip = True
    if skip:
        if "return nil" in line:
            skip = False
        continue
    new_lines.append(line)

with open("scintilla.prg", "w") as f:
    f.writelines(new_lines)
