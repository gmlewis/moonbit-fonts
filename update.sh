#!/bin/bash -ex
moon update && moon install && rm -rf target
# moon fmt
moon test --target js --package gmlewis/fonts/fonts
moon test --target js --package gmlewis/fonts/draw
moon test --target js --package gmlewis/fonts/examples
moon test --target js --package gmlewis/fonts/svg

moon run examples/svg-checkerboard > examples/svg-checkerboard/checkerboard.svg
# google-chrome examples/svg-checkerboard/checkerboard.svg