#!/bin/bash -ex
moon fmt && moon info
moon test --target all

# Ensure that all fonts load without error:
# moon run --target native tests/load-all-fonts
