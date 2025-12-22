#!/usr/bin/env python3
import sys
import os
import shutil
import subprocess

def split_font_mbt(file_path):
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return

    # Create a backup
    bak_path = file_path + ".bak"
    shutil.copy2(file_path, bak_path)
    print(f"Created backup at {bak_path}")

    with open(file_path, "r") as f:
        lines = f.readlines()

    total_lines = len(lines)
    header = []
    glyphs_start_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith("let glyphs"):
            glyphs_start_idx = i
            break
        header.append(line)
    
    if glyphs_start_idx == -1:
        print(f"Could not find 'let glyphs' in {file_path}")
        return

    # Clean up header - remove trailing empty lines or ///| lines
    while header and (not header[-1].strip() or header[-1].strip() == "///|"):
        header.pop()

    # Find the end of glyphs map
    # It ends with '}' on its own line followed by '///|' or 'pub let font'
    glyphs_end_idx = -1
    for i in range(glyphs_start_idx + 1, len(lines)):
        if lines[i].strip() == "}":
            # Check if next non-empty line starts with ///| or pub let font
            next_idx = i + 1
            while next_idx < len(lines) and not lines[next_idx].strip():
                next_idx += 1
            
            if next_idx == len(lines) or lines[next_idx].startswith("///|") or lines[next_idx].startswith("pub let font"):
                glyphs_end_idx = i
                break
    
    if glyphs_end_idx == -1:
        print(f"Could not find end of glyphs map in {file_path}")
        return

    glyphs_content_lines = lines[glyphs_start_idx+1:glyphs_end_idx]
    
    glyph_blocks = []
    current_block = []
    
    for line in glyphs_content_lines:
        stripped = line.strip()
        # A glyph block starts with "char": {
        if stripped.startswith('"') and stripped.endswith('{'):
            if current_block:
                glyph_blocks.append(current_block)
            current_block = [line]
        else:
            if current_block:
                current_block.append(line)
    if current_block:
        glyph_blocks.append(current_block)

    if not glyph_blocks:
        print("No glyph blocks found!")
        return

    target_split_line = total_lines // 2
    current_line_num = glyphs_start_idx + 1
    split_idx = len(glyph_blocks) // 2
    
    for i, block in enumerate(glyph_blocks):
        if current_line_num >= target_split_line:
            split_idx = i
            break
        current_line_num += len(block)
    
    part1_blocks = glyph_blocks[:split_idx]
    part2_blocks = glyph_blocks[split_idx:]

    dir_path = os.path.dirname(file_path) or "."
    
    # 1 & 2. Write part1.mbt and part2.mbt
    for name, blocks in [("part1", part1_blocks), ("part2", part2_blocks)]:
        p_path = os.path.join(dir_path, f"{name}.mbt")
        with open(p_path, "w") as f:
            f.writelines(header)
            f.write("\n\n///|\n")
            f.write(f"let {name} : Map[String, @fonts.Glyph] = {{\n")
            for block in blocks:
                f.writelines(block)
            f.write("}\n")

    # 3. Update the original file
    font_section = lines[glyphs_end_idx+1:]

    with open(file_path, "w") as f:
        f.writelines(header)
        f.write("\n\n///|\n")
        f.write("let glyphs : Map[String, @fonts.Glyph] = {\n")
        
        def process_blocks(blocks, part_name):
            for block in blocks:
                line = block[0].strip()
                if line.endswith("{"):
                    line = line[:-1].strip()
                    if line.endswith(":"):
                        key_val = line[:-1].strip()
                        if key_val.startswith('"') and key_val.endswith('"'):
                            key = key_val[1:-1]
                            f.write(f'  "{key}": {part_name}["{key}"],\n')

        process_blocks(part1_blocks, "part1")
        process_blocks(part2_blocks, "part2")
        f.write("}\n")
        f.writelines(font_section)

    # Final step: Format the files
    print(f"Formatting files in {dir_path}...")
    original_cwd = os.getcwd()
    try:
        os.chdir(dir_path)
        subprocess.run(["moon", "fmt"], check=False)
    finally:
        os.chdir(original_cwd)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file_path>")
        sys.exit(1)
    split_font_mbt(sys.argv[1])