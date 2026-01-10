#!/bin/bash -ex
moon install && rm -rf target .mooncakes
moon add --no-update gmlewis/fonts-a
moon fmt && moon info
moon run . > quick-start.svg
