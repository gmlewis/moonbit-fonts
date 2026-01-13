#!/bin/bash -ex
moon install && rm -rf target .mooncakes
moon add --no-update gmlewis/base64
moon add --no-update gmlewis/flate
moon add --no-update gmlewis/gzip
moon add --no-update gmlewis/io
moon add --no-update moonbitlang/async
moon add --no-update moonbitlang/regexp
moon add --no-update moonbitlang/x
moon update
moon fmt && moon info --target native

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export MOONBIT_FONTS_DIR=$(realpath ${SCRIPT_DIR}/..)
moon test --target native
