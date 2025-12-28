#!/usr/bin/env python3
import glob
import os

def main():
    # The pattern is ../mbt-fonts-*/*/moon.pkg.json
    # We want to find all moon.pkg.json files in the sibling directories.
    pattern = "../mbt-fonts-*/*/moon.pkg.json"
    paths = glob.glob(pattern)
    paths.sort()
    
    font_packages = []
    for path in paths:
        # Example path: ../mbt-fonts-a/airstream/moon.pkg.json
        # Normalize path to handle separators consistently.
        parts = path.replace('\\', '/').split('/')
        
        # We expect: [.., "mbt-fonts-x", "fontname", "moon.pkg.json"]
        if len(parts) >= 3:
            repo_dir = parts[-3]
            font_dir = parts[-2]
            
            # Remove 'mbt-' prefix from the repo directory name
            if repo_dir.startswith("mbt-"):
                repo_name = repo_dir[4:] # skip 'mbt-'
            else:
                repo_name = repo_dir
                
            package_name = f"gmlewis/{repo_name}/{font_dir}"
            font_packages.append(package_name)
            
    # Write all these strings to the file "all-fonts.txt" in the root of the repo.
    # Since the script is intended to be run from the root, we use "all-fonts.txt".
    with open("all-fonts.txt", "w") as f:
        for pkg in font_packages:
            f.write(pkg + "\n")

if __name__ == "__main__":
    main()
