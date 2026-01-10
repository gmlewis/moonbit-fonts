#!/usr/bin/env python3
import argparse
import os
import sys
import tempfile
import subprocess
import shutil
import re
from pathlib import Path

def get_font_map():
    """Reads all-fonts.txt and returns a map of family -> {variant: package_name}"""
    if not os.path.exists("all-fonts.txt"):
        print("Error: all-fonts.txt not found. Run scripts/enumerate-all-fonts.py first.")
        sys.exit(1)
    
    font_map = {}
    with open("all-fonts.txt", "r") as f:
        for line in f:
            pkg = line.strip()
            if not pkg: continue
            # Example: gmlewis/fonts-a/abeezee_italic
            parts = pkg.split('/')
            full_name = parts[-1]
            
            # Improved heuristic for family and variant
            # Examples: abeezee_italic, abeezee_regular, aaarghnormal, youngserif_regular
            if '_' in full_name:
                family, variant = full_name.rsplit('_', 1)
                # Further refine variant
                if variant in ['regular', 'italic', 'bold', 'bolditalic']:
                    pass
                elif 'italic' in variant and 'bold' in variant:
                    variant = 'bolditalic'
                elif 'bold' in variant:
                    variant = 'bold'
                elif 'italic' in variant:
                    variant = 'italic'
                else:
                    # Keep as is, maybe it's something like 'medium' or 'light'
                    pass
            else:
                family = full_name
                variant = 'regular'
                # Check for common variants embedded in the name
                if 'bolditalic' in full_name.lower(): variant = 'bolditalic'
                elif 'bold' in full_name.lower(): variant = 'bold'
                elif 'italic' in full_name.lower(): variant = 'italic'
                elif 'regular' in full_name.lower(): variant = 'regular'
            
            if family not in font_map:
                font_map[family] = {}
            
            # Prioritize standard names
            if variant == 'regular' or variant not in font_map[family]:
                font_map[family][variant] = pkg
            elif variant in ['bold', 'italic', 'bolditalic']:
                # Prefer exact standard variant names
                if '_' + variant in full_name:
                    font_map[family][variant] = pkg
            
    return font_map

def find_best_font(family_query, font_map):
    """Finds the best font family match."""
    # Exact match first
    if family_query in font_map:
        return family_query
    
    # Fuzzy match: prefix
    matches = [f for f in font_map.keys() if f.startswith(family_query)]
    if matches:
        return matches[0]
    
    return None

def generate_moon_mod(font_packages, root_dir):
    """Generates moon.mod.json content."""
    # We need to map the font repos to their local paths
    # font_packages examples: gmlewis/fonts-a/abeezee_regular
    # root_dir is the absolute path to gmlewis/fonts
    
    # Deduplicate repos
    repos = set()
    for pkg in font_packages:
        repos.add('/'.join(pkg.split('/')[:2])) # e.g., gmlewis/fonts-a
        
    deps = {
        "gmlewis/fonts": { "path": root_dir }
    }
    
    for repo in repos:
        # The repo name is like gmlewis/fonts-a
        # The physical path is ../mbt-fonts-a relative to gmlewis/fonts
        repo_suffix = repo.split('-')[-1]
        phys_repo_path = os.path.join(os.path.dirname(root_dir), f"mbt-fonts-{repo_suffix}")
        deps[repo] = { "path": phys_repo_path }
        
    import json
    return json.dumps({
        "name": "temp-render",
        "version": "0.1.0",
        "deps": deps
    }, indent=2)

def generate_moon_pkg(font_packages):
    """Generates moon.pkg.json content."""
    import json
    return json.dumps({
        "is-main": True,
        "import": [
            "gmlewis/fonts/draw",
            "gmlewis/fonts/geom",
            "gmlewis/fonts/svg"
        ] + font_packages
    }, indent=2)

def generate_main_mbt(lines, family_info):
    """Generates main.mbt content."""
    # family_info is a map of variant -> package_name
    # We'll map variants to import aliases
    
    import_aliases = {}
    for variant, pkg in family_info.items():
        # Alias is the last part of the package name
        alias = pkg.split('/')[-1]
        import_aliases[variant] = alias

    # Choose a default font
    default_alias = import_aliases.get('regular', list(import_aliases.values())[0])

    mbt = ["fn main {"]
    mbt.append(f"  let font_regular = @{default_alias}.font")
    
    if 'bold' in import_aliases:
        mbt.append(f"  let font_bold = @{import_aliases['bold']}.font")
    else:
        mbt.append(f"  let font_bold = font_regular")

    if 'italic' in import_aliases:
        mbt.append(f"  let font_italic = @{import_aliases['italic']}.font")
    else:
        mbt.append(f"  let font_italic = font_regular")
        
    mbt.append("  let mut scene = @draw.group([]).as_graphic()")
    mbt.append("  let mut y_offset = 0.0")
    
    for i, line in enumerate(lines):
        # 1. Detect and strip markers BEFORE escaping for MoonBit
        font_var = "font_regular"
        if (line.startswith("**") and line.endswith("**")) or (line.startswith("__") and line.endswith("__")):
            font_var = "font_bold"
            line = line[2:-2]
        elif (line.startswith("*") and line.endswith("*")) or (line.startswith("_") and line.endswith("_")):
            font_var = "font_italic"
            line = line[1:-1]
            
        # 2. Escape quotes for MoonBit string literal
        safe_line = line.replace('"', '\\"')
            
        mbt.append(f"  let t{i} = try {{")
        mbt.append(f"    @draw.text({font_var}, \"{safe_line}\").translate(@geom.vec2(0.0, y_offset))")
        mbt.append(f"  }} catch {{ _ => @draw.group([]).as_graphic() }}")
        mbt.append(f"  scene = scene + t{i}")
        mbt.append(f"  y_offset = y_offset + 1.2")
        
    mbt.append("  println(")
    mbt.append("    @svg.from_graphic(")
    mbt.append("      scene")
    mbt.append("      .with_margin(top=0.1, right=0.1, bottom=0.1, left=0.1)")
    mbt.append("      .with_background(@draw.Color::white()),")
    mbt.append("      y_up=false,")
    mbt.append("    ),")
    mbt.append("  )")
    mbt.append("}")
    
    return "\n".join(mbt)

def main():
    parser = argparse.ArgumentParser(description="Quickly render text to SVG using gmlewis/fonts")
    parser.add_argument("input", nargs="?", help="Input file (Markdown/Text), defaults to stdin")
    parser.add_argument("-f", "--font", default="aaarghnormal", help="Font family name (fuzzy matching supported)")
    parser.add_argument("-o", "--output", help="Output SVG file (defaults to stdout)")
    parser.add_argument("--keep", action="store_true", help="Keep the temporary MoonBit project directory")
    parser.add_argument("--list-fonts", action="store_true", help="List all available font families and exit")
    
    args = parser.parse_args()
    
    font_map = get_font_map()
    
    if args.list_fonts:
        for family in sorted(font_map.keys()):
            variants = ", ".join(font_map[family].keys())
            print(f"{family} ({variants})")
        return

    # Find the font
    family = find_best_font(args.font, font_map)
    if not family:
        print(f"Error: Could not find font family matching '{args.font}'")
        sys.exit(1)
    
    family_info = font_map[family]
    font_packages = list(family_info.values())
    
    # Read input
    if args.input:
        with open(args.input, "r") as f:
            lines = f.read().splitlines()
    else:
        if sys.stdin.isatty():
            print("Enter text to render (Ctrl-D to finish):")
        lines = sys.stdin.read().splitlines()
        
    if not lines:
        print("No input text provided.")
        return

    root_dir = os.getcwd()
    
    # Create temporary project
    tmp_dir = tempfile.mkdtemp(prefix="moon-render-")
    try:
        # Write files
        with open(os.path.join(tmp_dir, "moon.mod.json"), "w") as f:
            f.write(generate_moon_mod(font_packages, root_dir))
            
        with open(os.path.join(tmp_dir, "moon.pkg.json"), "w") as f:
            f.write(generate_moon_pkg(font_packages))
            
        with open(os.path.join(tmp_dir, "main.mbt"), "w") as f:
            f.write(generate_main_mbt(lines, family_info))
            
        # Run moon run
        result = subprocess.run(["moon", "run", "main.mbt"], cwd=tmp_dir, capture_output=True, text=True)
        
        if result.returncode != 0:
            print("Error running moon run:")
            print(result.stderr)
            if not args.keep:
                print(f"Temp directory kept at: {tmp_dir}")
            sys.exit(1)
            
        svg_content = result.stdout
        # Filter out compiler noise (like "Using cached...") by finding the actual SVG tags
        svg_match = re.search(r"<svg.*</svg>", svg_content, re.DOTALL)
        if svg_match:
            svg_content = svg_match.group(0)
        else:
            print("Error: Could not find SVG content in moon output.")
            if not args.keep:
                print(f"Stdout was: {result.stdout}")
            sys.exit(1)
            
        if args.output:
            with open(args.output, "w") as f:
                f.write(svg_content)
        else:
            print(svg_content)
            
        if args.keep:
            print(f"Project kept at: {tmp_dir}", file=sys.stderr)
            
    finally:
        if not args.keep:
            shutil.rmtree(tmp_dir)

if __name__ == "__main__":
    main()
