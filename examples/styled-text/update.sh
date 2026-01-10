#!/bin/bash -ex
moon install && rm -rf target .mooncakes
moon add --no-update gmlewis/fonts-b
moon fmt && moon info
moon run . > styled-text.svg
