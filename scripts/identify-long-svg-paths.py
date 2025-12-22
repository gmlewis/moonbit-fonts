#!/usr/bin/env python3
import glob
import os

# Constant defining the maximum allowed line length
MAX_LINE_LENGTH = 65500

def main():
    """
    Searches all *.mbt files in sibling directories matching '../mbt-fonts-*'
    and prints the path and line number of any line exceeding MAX_LINE_LENGTH.
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
                        for line_num, line in enumerate(f, 1):
                            if len(line) > MAX_LINE_LENGTH:
                                # Print in path:line_number format for external tool consumption
                                print(f"{file_path}:{line_num}")
                except (IOError, UnicodeDecodeError):
                    # Gracefully skip files that cannot be read as text
                    continue

if __name__ == "__main__":
    main()
