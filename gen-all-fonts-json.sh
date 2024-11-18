#!/bin/bash -ex
for i in `cat all-fonts.txt`; do
    echo $i
    moon run --target wasm-gc font/$i
done
