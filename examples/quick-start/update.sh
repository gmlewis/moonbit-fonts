#!/bin/bash -ex
moon fmt && moon info
moon run . --target wasm > quick-start.svg