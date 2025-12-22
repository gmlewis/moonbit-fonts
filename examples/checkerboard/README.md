# Checkerboard Example

This example demonstrates how to create a complex graphic by composing basic primitives like squares and circles.

## Features

- **Geometric Composition**: Shows how to use `@draw.unit_square()` and `@draw.unit_circle()` to build more complex shapes.
- **Transformations**: Demonstrates the use of `.translate()`, `.scale()`, and `.transform()` to position and size elements within a grid.
- **Styling**: Shows how to apply fills using `rgba` colors.
- **Grouping**: Illustrates how to combine multiple `Graphic` elements into a single `Group` for easier manipulation.

The core logic is contained in `checkerboard.mbt`, which generates an 8x8 checkers board with red and black pieces.
