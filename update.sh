#!/bin/bash -ex
moon update && moon install && rm -rf target .mooncakes
moon add moonbitlang/regexp
moon fmt && moon info
moon test --target all

moon run examples/svg-checkerboard > examples/svg-checkerboard/checkerboard.svg
# google-chrome examples/svg-checkerboard/checkerboard.svg

pushd examples/alignment-gallery && ./update.sh && popd
pushd examples/styled-text && ./update.sh && popd
