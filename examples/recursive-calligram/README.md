# Recursive Calligram Art

This example uses recursive packing algorithms to create complex typographic art where a large shape is composed of many smaller words.

## Features

- **Recursive Filling**: Words are packed into a silhouette at multiple scales.
- **Dynamic Orientation**: The text can follow the contours of the shape or be oriented for maximum packing efficiency.
- **Bounding Box Precision**: Leverages the `bbox` package to perform fast and accurate intersection tests and fitting.
- **Visual Sophistication**: Creates a "word cloud" effect that forms a coherent larger image.

## How it Works

1. **Silhouette Definition**: A large SVG path is used as the boundary (e.g., a heart or a bird).
2. **Recursive Packing**:
    - Start with a large font size.
    - Attempt to place the word inside the silhouette without hitting edges or other words.
    - If successful, record the transformation.
    - If unsuccessful, slightly reduce the font size and try again.
3. **Randomized Variation**: Introduces slight rotations and offsets for a more organic, handcrafted feel.
4. **Final Assembly**: Combines hundreds of text paths into a single SVG.

## Usage

(Instructions will be added once implementation is complete)
