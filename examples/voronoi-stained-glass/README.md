# Typographic Voronoi Stained Glass

This example showcases the use of computational geometry (specifically Voronoi diagrams) to create a stunning typographic stained-glass effect.

## Features

- **Integrated Typography**: Instead of just placing text on top of a pattern, the pattern *is* the text. The Voronoi cells are seeded using points sampled directly from the outlines of the glyphs.
- **Organic Fragments**: Creates a natural, handcrafted look where the "lead" lines follow the flow of the letters.
- **Generative Palettes**: Colors are assigned using algorithmically generated palettes (e.g., analogous, triadic, or based on specific themes like "Ocean" or "Autumn").
- **Resolution Independence**: Being a pure SVG, the design can be scaled to any size without losing the sharpness of the "lead" lines.

## How it Works

1. **Path Sampling**: The font paths are converted into a series of discrete points.
2. **Voronoi Generation**: A Voronoi diagram is computed using these points as seeds, along with a set of boundary points for the window frame.
3. **Cell Styling**: Each Voronoi cell is rendered as an SVG `<path>` with slightly inset borders to represent the lead and the glass.
4. **Color Logic**: Cells that are "inside" the glyph boundaries are colored differently from those in the "background" to ensure legibility.

## Usage

(Instructions will be added once implementation is complete)
