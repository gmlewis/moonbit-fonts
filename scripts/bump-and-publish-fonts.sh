!#/bin/bash -ex

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR=$(realpath ${SCRIPT_DIR}/..)
pushd ${REPO_DIR}

update-moonbit-deps
for i in ../mbt-fonts-* ; do
    echo $i && pushd $i
    VERSION=$(grep version moon.mod.json | sed -e 's/^.* "//g' -e 's/".*$//')
    git commit -sam "Bump version to ${VERSION}"
    git push
    # Special cases:
    if [[ "$i" == "../mbt-fonts-e" ]] ; then
	rm e*/e*.json
	moon publish
        git checkout -- .
    elif [[ "$i" == "../mbt-fonts-m" ]] ; then
	rm $(find . -depth 2 -name "*.json" -not -name moon.pkg.json)
	moon publish
        git checkout -- .
    elif [[ "$i" == "../mbt-fonts-o" ]] ; then
	rm o*/o*.json
	moon publish
        git checkout -- .
    else  # General case:
	moon publish
    fi
    popd
done
