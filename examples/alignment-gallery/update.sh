#!/bin/bash -ex
rm -rf _build .mooncakes
moon add --no-update gmlewis/fonts-a
moon fmt && moon info
moon run . > alignment-gallery.svg
