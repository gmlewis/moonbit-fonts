#!/usr/bin/env python3
import argparse
import os
import sys
import tempfile
import subprocess
import shutil
import re
import time
from pathlib import Path

def get_all_fonts():
    """Reads all-fonts.txt and returns a list of package names."""
    if not os.path.exists("all-fonts.txt"):
        print("Error: all-fonts.txt not found. Run scripts/enumerate-all-fonts.py first.")
        sys.exit(1)
    
    with open("all-fonts.txt", "r") as f:
        return [line.strip() for line in f if line.strip()]

def find_label_font_pkg(query, all_packages):
    """Finds the best package for the requested label font."""
    # Exact match of the last part
    for pkg in all_packages:
        if pkg.endswith('/' + query) or pkg == query:
            return pkg
    # Fuzzy prefix match on the last part
    for pkg in all_packages:
        if pkg.split('/')[-1].startswith(query):
            return pkg
    return None

def generate_moon_mod(font_packages, label_font_pkg, root_dir):
    """Generates moon.mod.json content."""
    repos = set()
    for pkg in font_packages + [label_font_pkg]:
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
        "name": "temp-sample-all",
        "version": "0.1.0",
        "deps": deps
    }, indent=2)

def generate_moon_pkg(font_packages, label_font_pkg):
    """Generates moon.pkg.json content."""
    import json
    all_imports = set([
        "gmlewis/fonts/draw",
        "gmlewis/fonts/geom",
        "gmlewis/fonts/svg",
        label_font_pkg
    ])
    all_imports.update(font_packages)
    return json.dumps({
        "is-main": True,
        "import": sorted(list(all_imports))
    }, indent=2)

def generate_main_mbt(font_packages, label_font_pkg, sample_lines):
    """Generates main.mbt content."""
    
    label_font_alias = label_font_pkg.split('/')[-1]

    # Join lines with \n for multiline support
    sample_text = "\\n".join(line.replace('"', '\\"') for line in sample_lines)

    mbt = ["fn main {"]
    mbt.append(f'  let sample_text = "{sample_text}"')
    mbt.append("  let mut scene = @draw.group([]).as_graphic()")
    mbt.append("  let cols = 6")
    
    # Heuristic for cell sizing
    line_count = len(sample_lines)
    col_width = 12.0
    row_height = 1.2 + (line_count * 1.2)
    
    for i, pkg in enumerate(font_packages):
        alias = pkg.split('/')[-1]
        x = (i % 6) * col_width
        y = (i // 6) * row_height
        
        mbt.append(f"  // Font {i}: {alias}")
        mbt.append(f"  let label = try {{ @draw.text(@{label_font_alias}.font, \"{alias}\").scale(@geom.vec2(0.3, 0.3)).translate(@geom.vec2(0.0, -0.8)) }} catch {{ _ => @draw.group([]).as_graphic() }}")
        mbt.append(f"  let sample = try {{ @draw.text(@{alias}.font, sample_text) }} catch {{ _ => @draw.group([]).as_graphic() }}")
        mbt.append(f"  scene = scene + (label + sample).translate(@geom.vec2({x}, {y}))")
        
    mbt.append("  println(")
    mbt.append("    @svg.from_graphic(")
    mbt.append("      scene")
    mbt.append("      .with_margin(top=0.5, right=0.5, bottom=0.5, left=0.5)")
    mbt.append("      .with_background(@draw.Color::white()),")
    mbt.append("      y_up=false,")
    mbt.append("    ).to_string(),")
    mbt.append("  )")
    mbt.append("}")
    
    return "\n".join(mbt)

def process_batch(font_packages, label_font_pkg, sample_lines, output_file, root_dir, args):
    start_time = time.time()
    tmp_dir = tempfile.mkdtemp(prefix="moon-sample-all-")
    try:
        if args.debug:
            print(f"--- Batch setup starting ({len(font_packages)} fonts) ---", file=sys.stderr)
            
        with open(os.path.join(tmp_dir, "moon.mod.json"), "w") as f:
            f.write(generate_moon_mod(font_packages, label_font_pkg, root_dir))
            
        with open(os.path.join(tmp_dir, "moon.pkg.json"), "w") as f:
            f.write(generate_moon_pkg(font_packages, label_font_pkg))
            
        with open(os.path.join(tmp_dir, "main.mbt"), "w") as f:
            f.write(generate_main_mbt(font_packages, label_font_pkg, sample_lines))
            
        if args.debug:
            print(f"Setup took: {time.time() - start_time:.2f}s", file=sys.stderr)
            
        print(f"Generating SVG for batch of {len(font_packages)} fonts...", file=sys.stderr)
        
        moon_start = time.time()
        # Using --target native as requested. We don't need moon add/update because we write moon.mod.json directly.
        result = subprocess.run(["moon", "run", "main.mbt", "--target", "native"], cwd=tmp_dir, capture_output=True, text=True)
        moon_end = time.time()
        
        if args.debug:
            print(f"moon run took: {moon_end - moon_start:.2f}s", file=sys.stderr)
        
        if result.returncode != 0 or "failed:" in result.stdout:
            print(f"Error running moon run (exit code {result.returncode}):", file=sys.stderr)
            if result.stdout:
                print("--- STDOUT ---", file=sys.stderr)
                print(result.stdout, file=sys.stderr)
            if result.stderr:
                print("--- STDERR ---", file=sys.stderr)
                print(result.stderr, file=sys.stderr)
            if not args.keep:
                print(f"Temp directory kept at: {tmp_dir}", file=sys.stderr)
            return False
            
        svg_content = result.stdout
        svg_match = re.search(r"<svg.*</svg>", svg_content, re.DOTALL)
        if svg_match:
            svg_content = svg_match.group(0)
        else:
            print("Error: Could not find SVG content in moon output.", file=sys.stderr)
            print("--- STDOUT ---", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print("--- STDERR ---", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            if not args.keep:
                print(f"Temp directory kept at: {tmp_dir}", file=sys.stderr)
            return False
            
        if output_file:
            with open(output_file, "w") as f:
                f.write(svg_content)
            print(f"Successfully wrote SVG to {output_file}", file=sys.stderr)
        else:
            print(svg_content)
        return True
    finally:
        if not args.keep:
            shutil.rmtree(tmp_dir)

def main():
    parser = argparse.ArgumentParser(description="Render sample text in batches of available fonts to SVG files")
    parser.add_argument("input", nargs="?", help="Input file (Markdown/Text) or string, defaults to stdin")
    parser.add_argument("-o", "--output", help="Output SVG file base name (e.g., sample.svg -> sample-001.svg)")
    parser.add_argument("-n", "--batch-size", type=int, default=221, help="Number of fonts per SVG (default 221)")
    parser.add_argument("--label-font", default="aileron_bold", help="Font to use for labels (default aileron_bold)")
    parser.add_argument("--limit", type=int, help="Limit the total number of fonts to render (for testing)")
    parser.add_argument("--keep", action="store_true", help="Keep the temporary MoonBit project directory")
    parser.add_argument("--debug", action="store_true", help="Show timing information")
    
    args = parser.parse_args()
    
    all_packages = get_all_fonts()
    if not all_packages:
        print("No fonts found in all-fonts.txt")
        sys.exit(1)

    label_font_pkg = find_label_font_pkg(args.label_font, all_packages)
    if not label_font_pkg:
        print(f"Error: Could not find label font matching '{args.label_font}'")
        sys.exit(1)

    font_packages = all_packages
    if args.limit:
        font_packages = font_packages[:args.limit]

    # Read input
    if args.input:
        if os.path.exists(args.input):
            with open(args.input, "r") as f:
                sample_lines = f.read().splitlines()
        else:
            sample_lines = [args.input]
    else:
        if sys.stdin.isatty():
            print("Enter text to render (Ctrl-D to finish):")
        sample_lines = sys.stdin.read().splitlines()
        
    if not sample_lines:
        sample_lines = ["ABC abc 123"]

    root_dir = os.getcwd()
    
    batch_size = args.batch_size
    num_batches = (len(font_packages) + batch_size - 1) // batch_size
    
    total_start = time.time()
    for i in range(num_batches):
        start = i * batch_size
        end = min((i + 1) * batch_size, len(font_packages))
        batch = font_packages[start:end]
        
        output_file = args.output
        if num_batches > 1 and args.output:
            base, ext = os.path.splitext(args.output)
            output_file = f"{base}-{i+1:03d}{ext}"
        elif num_batches > 1 and not args.output:
            output_file = f"sample-{i+1:03d}.svg"
            
        if not process_batch(batch, label_font_pkg, sample_lines, output_file, root_dir, args):
            sys.exit(1)
            
    if args.debug:
        print(f"Total time: {time.time() - total_start:.2f}s", file=sys.stderr)

if __name__ == "__main__":
    main()
