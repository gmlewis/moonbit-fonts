#!/bin/bash -ex
moon fmt && moon info
moon run . --target wasm > bio-mechanical-nameplate.svg