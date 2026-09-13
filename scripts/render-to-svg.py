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

def get_repo_version(repo_dir):
    """Reads the version from a local moon.mod file."""
    try:
        with open(os.path.join(repo_dir, "moon.mod")) as f:
            match = re.search(r'^version\s*=\s*"([^"]+)"', f.read(), re.MULTILINE)
        if match:
            return match.group(1)
    except OSError:
        pass
    return "0.1.0"

def generate_moon_work(member_dirs):
    """Generates moon.work content (workspace members resolve dependencies locally,
    since the modern moon.mod format no longer supports path dependencies)."""
    members = "\n".join(f'  "{d}",' for d in member_dirs)
    return f"members = [\n{members}\n]\n"

def generate_moon_mod(font_packages, root_dir):
    """Generates moon.mod content (versions are ignored for local workspace members,
    but are read from the local repos so a registry fallback stays correct)."""
    repos = set()
    for pkg in font_packages:
        repos.add('/'.join(pkg.split('/')[:2]))

    deps = [("gmlewis/fonts", root_dir)]
    for repo in sorted(repos):
        repo_suffix = repo.split('-')[-1]
        phys_repo_path = os.path.abspath(os.path.join(os.path.dirname(root_dir), f"mbt-fonts-{repo_suffix}"))
        deps.append((repo, phys_repo_path))

    imports = "\n".join(f'  "{name}@{get_repo_version(path)}",' for name, path in deps)
    return (
        'name = "temp-render"\n'
        '\n'
        'version = "0.1.0"\n'
        '\n'
        f'import {{\n{imports}\n}}\n'
        '\n'
        'preferred_target = "native"\n'
    )

def generate_moon_work_deps(font_packages, root_dir):
    """Returns the workspace member directories for the used font repos."""
    members = [".", root_dir]
    repos = set()
    for pkg in font_packages:
        repos.add('/'.join(pkg.split('/')[:2]))
    for repo in sorted(repos):
        repo_suffix = repo.split('-')[-1]
        members.append(os.path.abspath(os.path.join(os.path.dirname(root_dir), f"mbt-fonts-{repo_suffix}")))
    return members

def generate_moon_pkg(font_packages):
    """Generates moon.pkg content."""
    imports = "\n".join(
        f'  "{pkg}",' for pkg in
        ["gmlewis/fonts/draw", "gmlewis/fonts/geom", "gmlewis/fonts/svg"] + sorted(font_packages))
    return (
        f'import {{\n{imports}\n}}\n'
        '\n'
        'pkgtype(kind: "executable")\n'
    )

def generate_main_mbt(lines, family_info, alignment):
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
        mbt.append(f"    try {{ @draw.text({font_var}, \"{safe_line}\") }} catch {{ _ => @draw.group([]).as_graphic() }},")
    mbt.append("  ]")

    mbt.append(f"  let scene = @draw.column(lines, alignment=@geom.{mb_align}, spacing=0.2)")

    mbt.append("  println(")
    mbt.append("    @svg.from_graphic(")
    mbt.append("      scene")
    mbt.append("      .with_margin(top=0.1, right=0.1, bottom=0.1, left=0.1)")
    mbt.append("      .with_background(@draw.Color::white()),")
    mbt.append("      y_up=false,")
    mbt.append("    ).to_string()")
    mbt.append("  )")
    mbt.append("}")

    return "\n".join(mbt)

def main():
    parser = argparse.ArgumentParser(description="Quickly render text to SVG using gmlewis/fonts")
    parser.add_argument("input", nargs="?", help="Input file (Markdown/Text) or string, defaults to stdin")
    parser.add_argument("-f", "--font", default="aaarghnormal", help="Font family name (fuzzy matching supported)")
    parser.add_argument("-o", "--output", help="Output SVG file (defaults to stdout)")
    parser.add_argument("-a", "--align", choices=['left', 'center', 'right'], default='left', help="Horizontal alignment (default: left)")
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
            # Handle literal \n in string input
            lines = args.input.replace('\\n', '\n').splitlines()
    else:
        if sys.stdin.isatty():
            print("Enter text to render (Ctrl-D to finish):")
        lines = sys.stdin.read().splitlines()

    if not lines:
        print("No input text provided.")
        return

    root_dir = os.getcwd()
    tmp_dir = tempfile.mkdtemp(prefix="moon-render-")
    try:
        with open(os.path.join(tmp_dir, "moon.work"), "w") as f:
            f.write(generate_moon_work(generate_moon_work_deps(font_packages, root_dir)))
        with open(os.path.join(tmp_dir, "moon.mod"), "w") as f:
            f.write(generate_moon_mod(font_packages, root_dir))
        with open(os.path.join(tmp_dir, "moon.pkg"), "w") as f:
            f.write(generate_moon_pkg(font_packages))
        with open(os.path.join(tmp_dir, "main.mbt"), "w") as f:
            f.write(generate_main_mbt(lines, family_info, args.align))

        result = subprocess.run(["moon", "run", "main.mbt", "--target", "native"], cwd=tmp_dir, capture_output=True, text=True)

        if result.returncode != 0:
            print("Error running moon run:")
            print(result.stderr)
            if args.keep:
                print(f"Temp directory kept at: {tmp_dir}")
            sys.exit(1)

        svg_content = result.stdout
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
