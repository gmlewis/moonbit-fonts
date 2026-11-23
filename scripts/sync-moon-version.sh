#!/bin/bash
set -euo pipefail

# Usage: scripts/sync-moon-version.sh [VERSION]
#
# Rewrites the version in every workspace-member moon.mod that is nested under
# the root module's name (for example "gmlewis/fonts/loader" and
# "gmlewis/fonts/tests" under "gmlewis/fonts"). Such modules can never be
# published on their own, so their version must always mirror the root
# module's version. Independent members (the examples) keep their own
# versions and are not touched.
#
# Without an argument, the root moon.mod version is used.

cd "$(dirname "$0")/.."

root_module=$(sed -n 's/^name *= *"\([^"]*\)".*/\1/p' moon.mod | head -n 1)
version="${1:-$(sed -n 's/^version *= *"\([^"]*\)".*/\1/p' moon.mod | head -n 1)}"
[[ -n "$root_module" ]] || { echo "error: cannot determine the root module name" >&2; exit 1; }
[[ -n "$version" ]] || { echo "error: cannot determine the root version" >&2; exit 1; }

python3 - "$root_module" "$version" <<'PY'
import os
import re
import sys

root_module, version = sys.argv[1], sys.argv[2]
skip = {".git", ".mooncakes", "_build", ".moonagent", "all-fonts", "target"}
name_re = re.compile(r'(?m)^name[ \t]*=[ \t]*"([^"]+)"[ \t]*$')
version_re = re.compile(r'(?m)^version[ \t]*=[ \t]*"[^"]*"[ \t]*$')

changed = 0
for dirpath, dirnames, filenames in os.walk("."):
    dirnames[:] = [d for d in dirnames if d not in skip]
    if "moon.mod" not in filenames:
        continue
    path = os.path.join(dirpath, "moon.mod")
    if os.path.abspath(path) == os.path.abspath("moon.mod"):
        continue
    with open(path) as f:
        text = f.read()
    m = name_re.search(text)
    if not m or not m.group(1).startswith(root_module + "/"):
        continue
    new_text, n = version_re.subn('version = "%s"' % version, text, count=1)
    if n != 1 or new_text == text:
        continue
    with open(path, "w") as f:
        f.write(new_text)
    print("Synced %s to %s" % (path, version))
    changed += 1

if changed == 0:
    print("Nested workspace member versions already at %s" % version)
PY
