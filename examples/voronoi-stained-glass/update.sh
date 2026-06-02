#!/bin/bash -ex
moon fmt && moon info
moon run . --target wasm > voronoi-stained-glass.svg