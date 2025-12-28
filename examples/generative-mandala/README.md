# Generative Mandala Nameplate

This example demonstrates how to combine typography with complex, procedurally generated geometric patterns to create a beautiful, symmetric "Mandala" nameplate.

## Features

- **Personalized Geometry**: The number of radial segments, the types of "petals" (circular, triangular, or gothic arches), and the overall complexity are all derived from the input string (the name).
- **Multi-Layered SVG**: Uses gradients and layering to create a "stained glass" or "layered wood" effect in the browser.
- **Laser-Cutting Ready**: Generates a clean, stroke-based path that can be sent directly to a laser cutter or CNC machine.
- **Symmetry & Precision**: Leverages the `geom` package's `AffineMatrix` to perfectly rotate and repeat geometric motifs around a central axis.

## How it Works

1. **Text Extraction**: The central name is converted into geometric paths using `moonbit-fonts`.
2. **Seed Generation**: A hash is generated from the name, which acts as the "DNA" for the mandala.
3. **Recursive Petals**: Several layers of patterns are generated at increasing radii. Each layer can have a different symmetry (e.g., 6-fold, 12-fold, or 18-fold).
4. **Boolean-ish Composition**: Paths are carefully calculated to ensure they either overlap beautifully or provide structural support for the central text.

## Usage

(Instructions will be added once implementation is complete)
