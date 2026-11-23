#!/bin/bash
set -euo pipefail

# Usage: ./update.sh [--upgrade]
#
#   --upgrade   Also upgrade every third-party dependency to its latest
#               published version. That step is slow (one `moon add --upgrade`
#               per dependency per module), so it is skipped by default.
UPGRADE=false
for arg in "$@"; do
  case "$arg" in
    --upgrade) UPGRADE=true ;;
    *)
      echo "usage: $0 [--upgrade]" >&2
      exit 2
      ;;
  esac
done

# Configuration - use available CPUs
MAX_JOBS=${MAX_JOBS:-4}

# On macOS, tcc needs the Xcode SDK lib path to find libc/libpthread
if [[ "$(uname -s)" == "Darwin" ]]; then
  export LIBRARY_PATH="$(xcrun --show-sdk-path)/usr/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

# Sync workspace member moon.mod imports with the root package version and
# with the latest *published* companion versions.
#
# `moon check` resolves every `moon.work` member, so one member pinned to an
# unpublished version makes the whole workspace (and `moon publish`) fail.
# `gmlewis/fonts` and `gmlewis/fonts/loader` are workspace members and must
# track ROOT_VERSION; `gmlewis/fonts-a` / `gmlewis/fonts-b` live in sibling
# repos and must track what is actually in the registry. Never pin a member
# to a version that has not been published.
ROOT_VERSION=$(grep '^version = ' moon.mod | head -1 | sed 's/version = "//;s/"//')

latest_published() {
  moon view "$1" --json 2>/dev/null | python3 -c '
import json
import sys
try:
    print(json.load(sys.stdin)["result"]["latest_version"])
except Exception:
    pass'
}

FONTS_A_VERSION=$(latest_published gmlewis/fonts-a || true)
FONTS_B_VERSION=$(latest_published gmlewis/fonts-b || true)
echo "Root version: ${ROOT_VERSION}"
echo "Latest published companions: fonts-a=${FONTS_A_VERSION:-<unknown>}, fonts-b=${FONTS_B_VERSION:-<unknown>}"
if [[ -z "$FONTS_A_VERSION" || -z "$FONTS_B_VERSION" ]]; then
  echo "warning: could not look up the published companion versions; leaving those pins unchanged." >&2
fi

# sync_member_pins FILE rewrites the workspace-member and companion pins.
sync_member_pins() {
  local f="$1" args=()
  args+=(-e "s/gmlewis\/fonts@[0-9][0-9.]*/gmlewis\/fonts@${ROOT_VERSION}/g")
  args+=(-e "s/gmlewis\/fonts\/loader@[0-9][0-9.]*/gmlewis\/fonts\/loader@${ROOT_VERSION}/g")
  if [[ -n "$FONTS_A_VERSION" ]]; then
    args+=(-e "s/gmlewis\/fonts-a@[0-9][0-9.]*/gmlewis\/fonts-a@${FONTS_A_VERSION}/g")
  fi
  if [[ -n "$FONTS_B_VERSION" ]]; then
    args+=(-e "s/gmlewis\/fonts-b@[0-9][0-9.]*/gmlewis\/fonts-b@${FONTS_B_VERSION}/g")
  fi
  sed -i '' "${args[@]}" "$f"
}

echo "Updating workspace member moon.mod imports..."
find . \
  \( -type d \( -name .git -o -name .mooncakes -o -name _build \
     -o -name .moonagent -o -name all-fonts -o -name target \) -prune \) \
  -o -name moon.mod -print0 |
  while IFS= read -r -d '' f; do
    if [[ "$f" == "./moon.mod" ]]; then
      continue
    fi
    sync_member_pins "$f"
  done

# Fast update: only update registry once at the start
echo "Updating registry..."
moon update || true

# Upgrade every third-party dependency to its latest published version.
# The gmlewis/fonts family is intentionally skipped: `fonts` and `fonts/loader`
# are workspace members whose versions track the root package, and `fonts-a` /
# `fonts-b` are companion releases pinned to their latest published versions
# by the sync step above.
upgrade_module_deps() {
  local modfile="$1" dir
  dir="$(dirname "$modfile")"
  # Pull module names out of the `import { ... }` block, stripping any @version.
  awk '/^import \{/,/^\}/' "$modfile" | sed -n 's/.*"\([^"]*\)".*/\1/p' | sed -E 's/@.*//' | while read -r dep; do
    case "$dep" in
      gmlewis/fonts|gmlewis/fonts-a|gmlewis/fonts-b|gmlewis/fonts/loader) continue ;;
    esac
    (cd "$dir" && moon add --upgrade "$dep" >/dev/null 2>&1 || true)
  done
}

# The upgrade itself is slow - one `moon add --upgrade` per dependency per
# module - so it only runs with `./update.sh --upgrade`.
if [[ "$UPGRADE" == true ]]; then
  echo "Upgrading third-party dependencies to latest..."
  while IFS= read -r -d '' f; do
    upgrade_module_deps "$f"
  done < <(find . -path './.mooncakes' -prune -o -path './_build' -prune -o -name moon.mod -print0 | sort -z)
else
  echo "Skipping third-party dependency upgrade (pass --upgrade to enable)."
fi

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
