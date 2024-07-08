#!/bin/bash -ex
GO_FONTS_DIR=${HOME}/go/src/github.com/gmlewis/go-fonts
font2mbt ${GO_FONTS_DIR}-*/fonts/*/*.svg
