!#/bin/bash -ex

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR=$(realpath ${SCRIPT_DIR}/..)
pushd ${REPO_DIR}

update-moonbit-deps
for i in ../mbt-fonts-* ; do
    echo $i && pushd $i
    VERSION=$(grep version moon.mod.json | sed -e 's/^.* "//g' -e 's/".*$//')
    ./update.sh
    update-moonbit-version-readme
    git commit -sam "Bump version to ${VERSION}"
    git push
    # Remove JSON font representations before publishing, then restore.
    rm $(find . -depth 2 -name "*.json" -not -name moon.pkg.json)
    # Additionally, mbt-fonts-n is too large - remove notosans*condensed* fonts
    rm -rf notosans*condensed*
    moon publish
    git checkout -- .
    popd
done
