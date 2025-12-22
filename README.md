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

## Status

The code has been updated to support compiler:

```bash
$ moon version --all
moon 0.1.20251222 (3f6c70c 2025-12-22) ~/.moon/bin/moon
moonc v0.6.36+607dbed8f (2025-12-22) ~/.moon/bin/moonc
moonrun 0.1.20251222 (3f6c70c 2025-12-22) ~/.moon/bin/moonrun
moon-pilot 0.0.1-df92511 (2025-12-22) ~/.moon/bin/moon-pilot
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
