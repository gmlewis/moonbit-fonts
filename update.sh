#!/bin/bash -ex
moon update && moon install && rm -rf target
moon fmt
moon test --target js

moon run examples/svg-checkerboard > examples/svg-checkerboard/checkerboard.svg
# google-chrome examples/svg-checkerboard/checkerboard.svg
