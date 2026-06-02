#!/bin/bash -ex
moon fmt && moon info --target native

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export MOONBIT_FONTS_DIR=$(realpath ${SCRIPT_DIR}/..)
moon test -j 12 --target native