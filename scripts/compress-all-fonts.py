#!/usr/bin/env python3
import argparse
import os
import re
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

def resolve_font_repo(font_pkg, root_dir):
    """Returns (module_name, local_path) for a font package, or None."""
    parts = font_pkg.split('/')
    if len(parts) < 3:
        return None

    repo = '/'.join(parts[:2]) # e.g. gmlewis/fonts-a
    repo_suffix = repo.split('-')[-1]
    phys_repo_path = os.path.abspath(os.path.join(root_dir, "..", f"mbt-fonts-{repo_suffix}"))
    return repo, phys_repo_path

def generate_moon_mod(repo, phys_repo_path, root_dir):
    """Generates moon.mod content (versions are ignored for local workspace members,
    but are read from the local repos so a registry fallback stays correct)."""
    imports = "\n".join(
        f'  "{name}@{get_repo_version(path)}",' for name, path in [
            ("gmlewis/fonts", root_dir),
            (repo, phys_repo_path),
        ])
    return (
        'name = "temp-compress"\n'
        '\n'
        'version = "0.1.0"\n'
        '\n'
        f'import {{\n{imports}\n}}\n'
        '\n'
        'preferred_target = "native"\n'
    )

def generate_moon_pkg(font_pkg):
    """Generates moon.pkg content."""
    return (
        'import {\n'
        '  "gmlewis/fonts",\n'
        f'  "{font_pkg}",\n'
        '}\n'
        '\n'
        'pkgtype(kind: "executable")\n'
    )

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
        resolved = resolve_font_repo(font_pkg, root_dir)
        if not resolved:
            return font_pkg, False, f"Skipping {font_pkg}: unexpected format"
        repo, phys_repo_path = resolved

        with open(os.path.join(tmp_dir, "moon.work"), "w") as f:
            f.write(generate_moon_work([".", root_dir, phys_repo_path]))
        with open(os.path.join(tmp_dir, "moon.mod"), "w") as f:
            f.write(generate_moon_mod(repo, phys_repo_path, root_dir))
        with open(os.path.join(tmp_dir, "moon.pkg"), "w") as f:
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