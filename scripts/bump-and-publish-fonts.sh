#!/bin/bash -ex

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR=$(realpath ${SCRIPT_DIR}/..)
pushd ${REPO_DIR}

update-moonbit-version-readme
update-moonbit-deps
for i in ../mbt-fonts-* ; do
    echo $i && pushd $i
    VERSION=$(sed -n -e 's/^version *= *"\(.*\)"$/\1/p' moon.mod)
    if [ -z "${VERSION}" ]; then
        echo "ERROR: cannot determine version of ${REPO_DIR}" && popd && continue
    fi
    ./update.sh
    git add moon.mod */pkg.generated.mbti
    git commit -sam "Bump version to ${VERSION}"
    git push
    # Remove JSON font representations before publishing, then restore.
    rm $(find . -maxdepth 2 -name "*.json" -not -name moon.pkg.json)
    # Additionally, mbt-fonts-n is too large - remove notosans*condensed* fonts
    rm -rf notosans*condensed*
    moon publish
    git checkout -- .
    popd
done
