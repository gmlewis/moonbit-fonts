#!/bin/bash -ex
moon fmt && moon info
moon run . --target wasm > styled-text.svg