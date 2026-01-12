# gmlewis/moonbit-fonts
[![check](https://github.com/gmlewis/moonbit-fonts/actions/workflows/check.yml/badge.svg)](https://github.com/gmlewis/moonbit-fonts/actions/workflows/check.yml)

This is an experimental package to manipulate open source fonts with [MoonBit].

All fonts are open source and their licenses can all be found in their corresponding
repos which are organized by the first letter of the name of the font:

`mbt-fonts-*` packages contain hardcoded font data using `Map[String, @fonts.Glyph]`.

To add a font dependency, use the MoonBit package name (which follows the `gmlewis/fonts-<letter>/<fontname>` pattern).
For example, to add the `baloo` font, run:
```bash
moon add gmlewis/fonts-b/baloo
```

The corresponding GitHub repositories are:

* font: https://github.com/gmlewis/mbt-fonts-a/tree/master/aaarghnormal
* license: https://github.com/gmlewis/go-fonts-a/tree/master/fonts/aaarghnormal
* ...
* font: https://github.com/gmlewis/mbt-fonts-b/tree/master/baloo
* license: https://github.com/gmlewis/go-fonts-b/tree/master/fonts/baloo
* ...
* font: https://github.com/gmlewis/mbt-fonts-z/tree/master/znikomitno24
* license: https://github.com/gmlewis/go-fonts-z/tree/master/fonts/znikomitno24

[MoonBit]: https://www.moonbitlang.com/

## Quick Start

See the [examples/quick-start](examples/quick-start) directory for a valid example
of how to use this package.

## Gallery

* [Alignment Gallery](examples/alignment-gallery): Visual reference for text alignment.
* [Styled Text](examples/styled-text): Demonstration of fills, strokes, and CSS colors.
* [SVG Checkerboard](examples/svg-checkerboard): Basic graphic rendering.
* [Quick Start](examples/quick-start): Simple text rendering.

## Examples

### checkerboard

`checkerboard` is a simple example to create a `draw.Graphic` using the `@draw` API.

### canvas-checkerboard

`canvas-checkerboard` renders the `checkerboard` Graphic to an HTML5 canvas.
Type `./run-canvas-checkerboard.sh` in a terminal then open your browser to
http://localhost:8080/examples/canvas-checkerboard to view it.

### svg-checkerboard

`svg-checkerboard` "renders" the `checkerboard` Graphic to an SVG file.
Type `moon run examples/svg-checkerboard > examples/svg-checkerboard/checkerboard.svg`
in a terminal then open this file in your browser to view it.
For example, `google-chrome examples/svg-checkerboard/checkerboard.svg`.

## Scripts

A few utility scripts are available in the `scripts/` directory to help with common tasks.

### `render-to-svg.py`

Quickly render text to an SVG file using any available font. This script handles creating a temporary MoonBit project, importing the necessary font packages, and running the code to generate the SVG. It supports multi-line text and custom alignment.

**Examples:**

```bash
# Render "Hello World" using the default font (aaarghnormal)
./scripts/render-to-svg.py "Hello World" -o hello.svg

# Render multi-line text with horizontal centering
./scripts/render-to-svg.py "Line 1\nLine 2 Centered" -a center -o centered.svg

# Render text using a specific font (e.g. baloo)
./scripts/render-to-svg.py "Custom Font" -f baloo -o custom.svg

# List all available font families
./scripts/render-to-svg.py --list-fonts

# Use Markdown-style markers for bold/italic if the font family supports them
./scripts/render-to-svg.py "**Bold Text** and *Italic Text*" -f aileron -o styled.svg
```

### `render-to-json.py`

Similar to `render-to-svg.py`, but outputs a serialized JSON representation of the `draw.Graphic` object instead of an SVG. This is useful for passing graphic data to other tools like ray tracers. It defaults to `y-up` coordinates.

**Examples:**

```bash
# Render text to JSON (defaults to y-up)
./scripts/render-to-json.py "Data Graphic" -f abeezee -o graphic.json

# Render multi-line text with right-alignment and y-down coordinates
./scripts/render-to-json.py "Line 1\nLine 2" -a right --y-down -o down.json
```

### `sample-all-fonts.py`

Generates one or more SVG files showing a sample of text rendered in every available font. This is useful for visual font selection.

**Examples:**

```bash
# Generate sample SVGs for all fonts (in batches of 221)
./scripts/sample-all-fonts.py -o all-fonts.svg "The quick brown fox"

# Use a specific label font
./scripts/sample-all-fonts.py -o samples.svg --label-font aileron_bold
```

## Status

The code has been updated to support compiler:

```bash
$ moon version --all
moon 0.1.20260110 (0e584ac 2026-01-10) ~/.moon/bin/moon
moonc v0.7.1+adb125543 (2026-01-10) ~/.moon/bin/moonc
moonrun 0.1.20260110 (0e584ac 2026-01-10) ~/.moon/bin/moonrun
moon-pilot 0.0.1-df92511 (2026-01-10) ~/.moon/bin/moon-pilot
```

----------------------------------------------------------------------

Enjoy!

----------------------------------------------------------------------

# License

Please note that all fonts have their own licenses which are included
in their respective original directories (see above).

Copyright 2019-2024 Glenn M. Lewis. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

----------------------------------------------------------------------
