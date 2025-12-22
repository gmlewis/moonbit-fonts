#!/bin/bash -ex
moon update && moon install && rm -rf target .mooncakes
moon add gmlewis/fonts-b
moon fmt && moon info
moon run . > styled-text.svg
