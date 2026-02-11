#!/bin/bash -ex
rm -rf target .mooncakes
moon add --no-update gmlewis/fonts-b
moon fmt && moon info
moon run . > styled-text.svg
