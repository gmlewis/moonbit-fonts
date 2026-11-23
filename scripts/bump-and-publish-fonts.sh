#!/bin/bash -ex

# bump-and-publish-fonts.sh releases every sibling font module in
# ../mbt-fonts-*: it mirrors each module to the root module's version,
# commits the bump, pushes it, tags the release "vMAJOR.MINOR.PATCH" (the
# same scheme publish-and-tag.sh uses), pushes the tag, and publishes it to
# mooncakes.io.
#
# Run ./publish-and-tag.sh first, so that the gmlewis/fonts version the font
# modules will depend on is already in the registry.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR=$(realpath ${SCRIPT_DIR}/..)
pushd ${REPO_DIR}

update-moonbit-version-readme
# After the root release, the registry cache may still hold the previous
# versions; refresh it so the font modules pin the newly published root.
update-moonbit-deps -refresh
for i in ../mbt-fonts-* ; do
    echo $i && pushd $i
    VERSION=$(sed -n -e 's/^version *= *"\(.*\)"$/\1/p' moon.mod)
    if [ -z "${VERSION}" ]; then
        echo "ERROR: cannot determine version of ${i}" && popd && continue
    fi
    if ! [[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "ERROR: version '${VERSION}' in ${i} is not MAJOR.MINOR.PATCH" && popd && continue
    fi
    ./update.sh
    git add moon.mod */pkg.generated.mbti
    if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
        git commit -sam "Bump version to ${VERSION}"
    else
        echo "No changes to commit in ${i}"
    fi
    git push
    if git rev-parse -q --verify "refs/tags/v${VERSION}" >/dev/null; then
        echo "warning: tag v${VERSION} already exists in ${i}; not retagging"
    else
        git tag "v${VERSION}"
        git push origin "refs/tags/v${VERSION}"
    fi
    # Remove JSON font representations before publishing, then restore.
    # (Only font data JSON files live at depth <= 2: moon.mod and moon.pkg
    # contain no JSON, and .mooncakes/_build files are deeper.)
    find . -maxdepth 2 -name "*.json" -delete
    # Additionally, mbt-fonts-n is too large - remove notosans*condensed* fonts
    rm -rf notosans*condensed*
    moon publish
    git checkout -- .
    popd
done

# Every font module is published now. Refresh the registry cache and advance
# the root repo's pins to the new versions (commit those changes afterwards).
update-moonbit-deps -refresh
