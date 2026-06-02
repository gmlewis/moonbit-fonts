#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MOON_MOD="$ROOT_DIR/moon.mod"

if [[ ! -f "$MOON_MOD" ]]; then
  echo "Error: moon.mod not found at $MOON_MOD" >&2
  exit 1
fi

FONTS_VERSION=$(grep '^version = ' "$MOON_MOD" | head -1 | sed 's/version = "\(.*\)"/\1/')

if [[ -z "$FONTS_VERSION" ]]; then
  echo "Error: could not extract version from $MOON_MOD" >&2
  exit 1
fi

OLD_RE='gmlewis/fonts@[0-9][0-9.]*'
NEW_IMPORT="gmlewis/fonts@$FONTS_VERSION"
COUNT=0

while IFS= read -r f; do
  CURRENT=$(grep -o "$OLD_RE" "$f" | head -1 || true)
  if [[ -n "$CURRENT" && "$CURRENT" != "$NEW_IMPORT" ]]; then
    sed -i '' "s|$OLD_RE|$NEW_IMPORT|g" "$f"
    COUNT=$((COUNT + 1))
  fi
done < <(find "$ROOT_DIR" -name moon.mod \
  -not -path '*/.git/*' \
  -not -path '*/_build/*' \
  -not -path '*/.mooncakes/*' \
  -not -name moon.mod.json | sort)

echo "Updated gmlewis/fonts@$FONTS_VERSION in $COUNT moon.mod file(s)."