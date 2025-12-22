#!/usr/bin/env python3
import glob
import os

# Constant defining the maximum allowed number of lines
MAX_NUM_LINES = 65500

def main():
    """
    Searches all *.mbt files in sibling directories matching '../mbt-fonts-*'
    and prints the path of any file exceeding MAX_NUM_LINES.
    It skips 'target' and '.mooncakes' directories.
    """
    # Find sibling directories matching the pattern
    sibling_pattern = os.path.join("..", "mbt-fonts-*")
    base_dirs = glob.glob(sibling_pattern)

    for base_dir in base_dirs:
        if not os.path.isdir(base_dir):
            continue
        
        for root, dirs, files in os.walk(base_dir):
            # Ignore and skip "target" and ".mooncakes" directories
            dirs[:] = [d for d in dirs if d not in ("target", ".mooncakes")]
            
            for file in files:
                if not file.endswith(".mbt"):
                    continue
                
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        line_count = sum(1 for _ in f)
                        if line_count > MAX_NUM_LINES:
                            # Print the relative path
                            print(file_path)
                except (IOError, UnicodeDecodeError):
                    # Gracefully skip files that cannot be accessed or read
                    continue

if __name__ == "__main__":
    main()
