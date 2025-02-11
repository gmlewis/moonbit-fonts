#!/bin/bash -ex
moon update && moon install && rm -rf target
moon add moonbitlang/x
moon add yj-qin/regexp
moon fmt && moon info
moon test --target js

moon run examples/svg-checkerboard > examples/svg-checkerboard/checkerboard.svg
# google-chrome examples/svg-checkerboard/checkerboard.svg
