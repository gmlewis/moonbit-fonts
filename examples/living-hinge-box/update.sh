#!/bin/bash -ex
moon fmt && moon info
moon run . --target wasm > living-hinge-box.svg