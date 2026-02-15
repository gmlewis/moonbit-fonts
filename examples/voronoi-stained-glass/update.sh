#!/bin/bash -ex
rm -rf _build .mooncakes
moon add --no-update gmlewis/fonts-b
moon fmt && moon info
moon run . > voronoi-stained-glass.svg
