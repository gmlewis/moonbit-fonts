#!/bin/bash -ex
moon update && moon install && rm -rf target
# moon fmt
moon test --target js --package gmlewis/fonts/fonts
moon test --target js --package gmlewis/fonts/vec2
