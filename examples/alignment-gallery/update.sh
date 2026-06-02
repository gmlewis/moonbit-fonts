#!/bin/bash -ex
moon fmt && moon info
moon run . --target wasm > alignment-gallery.svg