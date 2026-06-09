#!/bin/bash
set -euo pipefail

# Configuration - use available CPUs
MAX_JOBS=${MAX_JOBS:-4}

# On macOS, tcc needs the Xcode SDK lib path to find libc/libpthread
if [[ "$(uname -s)" == "Darwin" ]]; then
  export LIBRARY_PATH="$(xcrun --show-sdk-path)/usr/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

# Sync example moon.mod imports with root package version
ROOT_VERSION=$(grep '^version = ' moon.mod | head -1 | sed 's/version = "//;s/"//')
IFS='.' read -r MAJOR MINOR PATCH <<< "$ROOT_VERSION"
COMPANION_PATCH=$((PATCH - 1))
COMPANION_VERSION="${MAJOR}.${MINOR}.${COMPANION_PATCH}"
echo "Root version: ${ROOT_VERSION}, companion version (fonts-a/fonts-b): ${COMPANION_VERSION}"

echo "Updating example moon.mod imports..."
find examples -name moon.mod -print0 | while IFS= read -r -d '' f; do
  sed -i '' \
    -e "s/gmlewis\/fonts@[0-9][0-9.]*/gmlewis\/fonts@${ROOT_VERSION}/g" \
    -e "s/gmlewis\/fonts-a@[0-9][0-9.]*/gmlewis\/fonts-a@${COMPANION_VERSION}/g" \
    -e "s/gmlewis\/fonts-b@[0-9][0-9.]*/gmlewis\/fonts-b@${COMPANION_VERSION}/g" \
    "$f"
done

# Fast update: only update registry once at the start
echo "Updating registry..."
moon update || true

# Clean build artifacts quickly
echo "Cleaning build artifacts..."
find . -type d \( -name .mooncakes -o -name _build \) -not -path './.git/*' -exec rm -rf {} + 2>/dev/null || true

# Root package setup
echo "Setting up root package..."
moon fmt || true
moon work sync || true
moon info || true

# Run root tests
echo "Running root tests..."
moon test -j "$MAX_JOBS" --target all || true

# Generate SVG
moon run examples/svg-checkerboard --target wasm > examples/svg-checkerboard/checkerboard.svg 2>/dev/null || true

# Collect all sub-package update scripts (excluding root)
scripts=()
while IFS= read -r line; do
    scripts+=("$line")
done < <(find . -type d \( -name .mooncakes -o -name _build \) -prune -o -type f -name update.sh -print 2>/dev/null | grep -v '^\./update\.sh$' | sort)

total=${#scripts[@]}
if [[ $total -eq 0 ]]; then
    echo "No sub-package update scripts found."
    exit 0
fi

echo "Processing ${total} sub-packages with ${MAX_JOBS} parallel jobs..."

# Process sub-packages in parallel
pids=()
for script in "${scripts[@]}"; do
    script_dir="${script%/*}"
    pkg_name="${script_dir#./}"
    
    (
        cd "$script_dir"
        if ./update.sh >/dev/null 2>&1; then
            echo "✓ ${pkg_name}"
        else
            echo "✗ ${pkg_name} FAILED" >&2
            exit 1
        fi
    ) &
    pids+=($!)
    
    # Limit concurrent jobs
    while [[ ${#pids[@]} -ge $MAX_JOBS ]]; do
        new_pids=()
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                new_pids+=("$pid")
            else
                wait "$pid" || true
            fi
        done
        pids=("${new_pids[@]}")
        [[ ${#pids[@]} -ge $MAX_JOBS ]] && sleep 0.1
    done
done

# Wait for all remaining jobs
for pid in "${pids[@]}"; do
    wait "$pid" || exit 1
done

echo "Completed ${total} sub-package updates."
