#!/bin/bash
set -euxo pipefail

moon update
rm -rf ./{_build,.mooncakes} \
    examples/*/{_build,.mooncakes} \
    loader/{_build,.mooncakes} \
    tests/{_build,.mooncakes} \
    tests/*/{_build,.mooncakes}
moon add moonbitlang/regexp
moon fmt && moon info
moon test -j 12 --target all

moon run examples/svg-checkerboard > examples/svg-checkerboard/checkerboard.svg
# google-chrome examples/svg-checkerboard/checkerboard.svg

completed=0
total=0

find_update_scripts() {
    find . -type d \( -name .mooncakes -o -name _build \) -prune -o -type f -name update.sh -print | sort
}

while IFS= read -r script; do
    if [[ "$script" == "./update.sh" ]]; then
        continue
    fi

    total=$((total + 1))
    script_dir="${script%/*}"
    echo "Running ${script}"

    if (
        cd "$script_dir"
        ./update.sh
    ); then
        completed=$((completed + 1))
    else
        echo "Failed while running ${script} (${completed}/${total} completed)" >&2
        exit 1
    fi
done < <(find_update_scripts)

echo "Completed ${completed}/${total} child update scripts."
