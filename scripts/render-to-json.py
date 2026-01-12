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
            if '_' in full_name:
                family, variant = full_name.rsplit('_', 1)
                if variant in ['regular', 'italic', 'bold', 'bolditalic']:
                    pass
                elif 'italic' in variant and 'bold' in variant:
                    variant = 'bolditalic'
                elif 'bold' in variant:
                    variant = 'bold'
                elif 'italic' in variant:
                    variant = 'italic'
            else:
                family = full_name
                variant = 'regular'
                if 'bolditalic' in full_name.lower(): variant = 'bolditalic'
                elif 'bold' in full_name.lower(): variant = 'bold'
                elif 'italic' in full_name.lower(): variant = 'italic'
                elif 'regular' in full_name.lower(): variant = 'regular'

            if family not in font_map:
                font_map[family] = {}

            if variant == 'regular' or variant not in font_map[family]:
                font_map[family][variant] = pkg
            elif variant in ['bold', 'italic', 'bolditalic']:
                if '_' + variant in full_name:
                    font_map[family][variant] = pkg

    return font_map

def find_best_font(family_query, font_map):
    """Finds the best font family match."""
    if family_query in font_map:
        return family_query
    matches = [f for f in font_map.keys() if f.startswith(family_query)]
    if matches:
        return matches[0]
    return None

def generate_moon_mod(font_packages, root_dir):
    """Generates moon.mod.json content."""
    repos = set()
    for pkg in font_packages:
        repos.add('/'.join(pkg.split('/')[:2]))

    deps = {
        "gmlewis/fonts": { "path": root_dir }
    }

    for repo in repos:
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

def generate_main_mbt(lines, family_info, alignment, y_up):
    """Generates main.mbt content."""
    import_aliases = {}
    for variant, pkg in family_info.items():
        alias = pkg.split('/')[-1]
        import_aliases[variant] = alias

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

    # Map Python align string to MoonBit alignment
    align_map = {
        'left': 'CenterLeft',
        'center': 'Center',
        'right': 'CenterRight'
    }
    mb_align = align_map.get(alignment, 'CenterLeft')
    y_up_val = "true" if y_up else "false"

    mbt.append("  let lines = [")
    for line in lines:
        font_var = "font_regular"
        if (line.startswith("**") and line.endswith("**")) or (line.startswith("__") and line.endswith("__")):
            font_var = "font_bold"
            line = line[2:-2]
        elif (line.startswith("*") and line.endswith("*")) or (line.startswith("_") and line.endswith("_")):
            font_var = "font_italic"
            line = line[1:-1]
        safe_line = line.replace('"', '\"')
        mbt.append(f"    try {{ @draw.text({font_var}, \"{safe_line}\", y_up={y_up_val}) }} catch {{ _ => @draw.group([]).as_graphic() }},")
    mbt.append("  ]")

    mbt.append(f"  let scene = @draw.column(lines, alignment=@geom.{mb_align}, spacing=0.2)")

    mbt.append("  println(scene.to_json().stringify())")
    mbt.append("}")

    return "\n".join(mbt)

def main():
    parser = argparse.ArgumentParser(description="Quickly render text to JSON using gmlewis/fonts")
    parser.add_argument("input", nargs="?", help="Input file (Markdown/Text) or string, defaults to stdin")
    parser.add_argument("-f", "--font", default="aaarghnormal", help="Font family name (fuzzy matching supported)")
    parser.add_argument("-o", "--output", help="Output JSON file (defaults to stdout)")
    parser.add_argument("-a", "--align", choices=['left', 'center', 'right'], default='left', help="Horizontal alignment (default: left)")
    parser.add_argument("--y-up", action="store_true", dest="y_up", help="Use y-up coordinates (default)")
    parser.add_argument("--y-down", action="store_false", dest="y_up", help="Use y-down coordinates")
    parser.set_defaults(y_up=True)
    parser.add_argument("--keep", action="store_true", help="Keep the temporary MoonBit project directory")
    parser.add_argument("--list-fonts", action="store_true", help="List all available font families and exit")

    args = parser.parse_args()

    font_map = get_font_map()

    if args.list_fonts:
        for family in sorted(font_map.keys()):
            variants = ", ".join(font_map[family].keys())
            print(f"{family} ({variants})")
        return

    family = find_best_font(args.font, font_map)
    if not family:
        print(f"Error: Could not find font family matching '{args.font}'")
        sys.exit(1)

    family_info = font_map[family]
    font_packages = list(family_info.values())

    if args.input:
        if os.path.exists(args.input):
            with open(args.input, "r") as f:
                lines = f.read().splitlines()
        else:
            lines = [args.input]
    else:
        if sys.stdin.isatty():
            print("Enter text to render (Ctrl-D to finish):")
        lines = sys.stdin.read().splitlines()

    if not lines:
        print("No input text provided.")
        return

    root_dir = os.getcwd()
    tmp_dir = tempfile.mkdtemp(prefix="moon-render-")
    if args.keep:
        print(f"Project directory: {tmp_dir}", file=sys.stderr)
    try:
        with open(os.path.join(tmp_dir, "moon.mod.json"), "w") as f:
            f.write(generate_moon_mod(font_packages, root_dir))
        with open(os.path.join(tmp_dir, "moon.pkg.json"), "w") as f:
            f.write(generate_moon_pkg(font_packages))
        with open(os.path.join(tmp_dir, "main.mbt"), "w") as f:
            f.write(generate_main_mbt(lines, family_info, args.align, args.y_up))

        result = subprocess.run(["moon", "run", "main.mbt", "--target", "native"], cwd=tmp_dir, capture_output=True, text=True)

        if result.returncode != 0:
            print("Error running moon run:")
            print("--- STDOUT ---", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print("--- STDERR ---", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            if not args.keep:
                print(f"Temp directory kept at: {tmp_dir}")
            sys.exit(1)

        json_content = result.stdout
        lines = json_content.strip().splitlines()
        json_output = None
        for line in reversed(lines):
            line = line.strip()
            if line.startswith('{') and line.endswith('}'):
                json_output = line
                break
        
        if not json_output:
            print("Error: Could not find JSON content in moon output.")
            print("--- STDOUT ---", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print("--- STDERR ---", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            if not args.keep:
                print(f"Temp directory kept at: {tmp_dir}")
            sys.exit(1)

        if args.output:
            with open(args.output, "w") as f:
                f.write(json_output)
        else:
            print(json_output)

        if args.keep:
            print(f"Project kept at: {tmp_dir}", file=sys.stderr)
    finally:
        if not args.keep:
            shutil.rmtree(tmp_dir)

if __name__ == "__main__":
    main()
