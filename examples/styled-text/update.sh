#!/bin/bash -ex
moon update && moon install && rm -rf target .mooncakes
moon add gmlewis/fonts-a
moon fmt && moon info
moon run . > alignment-gallery.svg
