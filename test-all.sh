#!/bin/bash -ex
moon fmt && moon info
moon test --target all

# Ensure that all fonts load without error:
# export MOONBIT_FONTS_DIR="$(dirname "$(readlink -f "$0")")"
# pushd tests/load-all-fonts && moon run . && popd

