# Layout Gallery Example

This example demonstrates the sophisticated layout capabilities of the MoonBit Fonts library using the `row`, `column`, and `grid` utilities.

![Layout Gallery](layout-gallery.svg)

## Features

- **Nested Layouts**: Shows how to combine `column` and `grid` to create complex structures like a dashboard with a header and data cards.
- **Alignment and Spacing**: Demonstrates precise control over item placement and gaps within rows, columns, and grids.
- **Margins and Backgrounds**: Shows the convenience of the `.with_margin()` and `.with_background()` methods for creating polished, "card-like" UI elements.
- **Composition**: Illustrates the power of the `+` operator and layout functions to build high-level graphics from basic primitives and text.

## How to Run

From the root of the repository, execute:

```bash
cd examples/layout-gallery
moon run main.mbt > layout-gallery.svg
```

This will generate a `layout-gallery.svg` file representing a flight dashboard.
