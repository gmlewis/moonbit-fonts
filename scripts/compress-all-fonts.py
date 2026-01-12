#!/usr/bin/env python3
import argparse
import os
import sys
import tempfile
import subprocess
import shutil
import concurrent.futures
from pathlib import Path

def get_font_packages():
    """Reads all-fonts.txt and returns a list of package names."""
    if not os.path.exists("all-fonts.txt"):
        print("Error: all-fonts.txt not found.")
        sys.exit(1)

    with open("all-fonts.txt", "r") as f:
        return [line.strip() for line in f if line.strip()]

def generate_moon_mod(font_pkg, root_dir):
    """Generates moon.mod.json content."""
    parts = font_pkg.split('/')
    if len(parts) < 3:
        return None
    
    repo = '/'.join(parts[:2]) # e.g. gmlewis/fonts-a
    repo_suffix = repo.split('-')[-1]
    phys_repo_path = os.path.abspath(os.path.join(root_dir, "..", f"mbt-fonts-{repo_suffix}"))

    import json
    return json.dumps({
        "name": "temp-compress",
        "version": "0.1.0",
        "deps": {
            "gmlewis/fonts": { "path": root_dir },
            repo: { "path": phys_repo_path }
        }
    }, indent=2)

def generate_moon_pkg(font_pkg):
    """Generates moon.pkg.json content."""
    import json
    return json.dumps({
        "is-main": True,
        "import": [
            "gmlewis/fonts",
            font_pkg
        ]
    }, indent=2)

def generate_main_mbt(font_pkg):
    """Generates main.mbt content."""
    alias = font_pkg.split('/')[-1]
    return f"""
fn main {{
  println(@{alias}.font.to_json().stringify())
}}
"""

def compress_font(font_pkg, root_dir, outdir):
    font_name = font_pkg.split('/')[-1]
    output_json = os.path.join(outdir, f"{font_name}.json")
    
    tmp_dir = tempfile.mkdtemp(prefix=f"moon-compress-{font_name}-")
    try:
        moon_mod = generate_moon_mod(font_pkg, root_dir)
        if not moon_mod:
            return font_pkg, False, f"Skipping {font_pkg}: unexpected format"

        with open(os.path.join(tmp_dir, "moon.mod.json"), "w") as f:
            f.write(moon_mod)
        with open(os.path.join(tmp_dir, "moon.pkg.json"), "w") as f:
            f.write(generate_moon_pkg(font_pkg))
        with open(os.path.join(tmp_dir, "main.mbt"), "w") as f:
            f.write(generate_main_mbt(font_pkg))

        result = subprocess.run(["moon", "run", "main.mbt", "--target", "native"], cwd=tmp_dir, capture_output=True, text=True)

        if result.returncode != 0:
            error_msg = f"Error running moon run for {font_name}:\n{result.stderr}"
            return font_pkg, False, error_msg

        stdout = result.stdout.strip()
        start_idx = stdout.find('{')
        end_idx = stdout.rfind('}')
        
        if start_idx == -1 or end_idx == -1 or end_idx < start_idx:
            error_msg = f"Error: Could not find JSON content in moon output for {font_name}.\nSTDOUT: {stdout}\nSTDERR: {result.stderr}"
            return font_pkg, False, error_msg

        json_output = stdout[start_idx:end_idx+1]

        with open(output_json, "w") as f:
            f.write(json_output)
        
        subprocess.run(["gzip", "-f", output_json], check=True)
        return font_pkg, True, None

    except Exception as e:
        return font_pkg, False, f"Exception during {font_name}: {str(e)}"
    finally:
        shutil.rmtree(tmp_dir)

def main():
    parser = argparse.ArgumentParser(description="Compress all fonts to JSON.gz")
    parser.add_argument("--outdir", default="all-fonts", help="Output directory (default: all-fonts)")
    parser.add_argument("--limit", type=int, help="Limit the number of fonts to process")
    parser.add_argument("--workers", type=int, default=20, help="Number of parallel workers (default: 20)")
    parser.add_argument("--force", action="store_true", help="Force re-compression even if output file exists")
    parser.add_argument("fonts", nargs="*", help="Specific font names or packages to process")
    args = parser.parse_args()

    outdir = os.path.abspath(args.outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)

    font_packages = get_font_packages()
    
    if args.fonts:
        filtered = []
        for pkg in font_packages:
            name = pkg.split('/')[-1]
            if name in args.fonts or pkg in args.fonts:
                filtered.append(pkg)
        font_packages = filtered

    if not args.force:
        remaining = []
        for pkg in font_packages:
            font_name = pkg.split('/')[-1]
            if not os.path.exists(os.path.join(outdir, f"{font_name}.json.gz")):
                remaining.append(pkg)
        
        skipped = len(font_packages) - len(remaining)
        if skipped > 0:
            print(f"Skipping {skipped} fonts that are already compressed. Use --force to re-process.")
        font_packages = remaining

    if args.limit:
        font_packages = font_packages[:args.limit]
    
    root_dir = os.path.abspath(os.getcwd())
    total = len(font_packages)
    if total == 0:
        print("No fonts to process.")
        return

    print(f"Processing {total} fonts using {args.workers} workers...")

    success_count = 0
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.workers) as executor:
        future_to_pkg = {executor.submit(compress_font, pkg, root_dir, outdir): pkg for pkg in font_packages}
        
        completed = 0
        for future in concurrent.futures.as_completed(future_to_pkg):
            pkg, success, error_msg = future.result()
            completed += 1
            if success:
                success_count += 1
                print(f"[{completed}/{total}] Success: {pkg}")
            else:
                print(f"[{completed}/{total}] FAILED: {pkg}")
                print(error_msg, file=sys.stderr)
    
    print(f"\nDone. Successfully compressed {success_count}/{total} fonts into {outdir}")

if __name__ == "__main__":
    main()