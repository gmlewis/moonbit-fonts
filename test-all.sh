#!/bin/bash -ex
moon fmt && moon info

# On macOS, tcc needs the Xcode SDK lib path to find libc/libpthread
if [[ "$(uname -s)" == "Darwin" ]]; then
  export LIBRARY_PATH="$(xcrun --show-sdk-path)/usr/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

moon test --target all

# Ensure that all fonts load without error:
# export MOONBIT_FONTS_DIR="$(dirname "$(readlink -f "$0")")"
# pushd tests/load-all-fonts && moon run . && popd

