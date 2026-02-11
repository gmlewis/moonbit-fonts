#!/bin/bash -ex
rm -rf target .mooncakes
moon add --no-update gmlewis/fonts-a
moon fmt && moon info
moon run . > layout-gallery.svg
