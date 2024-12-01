#!/bin/bash -ex
moon build --target wasm-gc --directory examples/canvas-checkerboard

echo 'Open browser to: http://localhost:8080/examples/canvas-checkerboard'
python3 -m http.server 8080
