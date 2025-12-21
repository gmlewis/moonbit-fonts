# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1/0/).

## [0.18.1] - 2025-12-21

### Changed
- **BREAKING**:
  - `assign_fill` => `with_fill`
  - `assign_stroke` => `with_stroke`
  - `assign_style` => `with_style`

## [0.18.0] - 2025-12-21

### Added
- New `gmlewis/fonts/geom` package containing core geometric types and utilities.
- `Graphic` composition using the `+` operator (`op_add`).
- `Graphic::with_style` for fluent style application.
- `Graphic::scale_to_fit` and `Graphic::scale_to_fill` for easier resizing.
- Common color constants as static methods on `Color`: `black()`, `white()`, `red()`, `green()`, `blue()`, `transparent()`.
- `Fill::from_string` to create a fill from a CSS color string.
- `draw.to_graphic` and `draw.text` for rendering text directly to `Graphic`.
- `Group::self_transform` for in-place transformation of groups.
- `BoundingBox::is_empty`, `BoundingBox::copy`, `BoundingBox::bounds`, `BoundingBox::dx`,
  `BoundingBox::dy`, `BoundingBox::inset`, `BoundingBox::union`, `BoundingBox::overlaps`,
  `BoundingBox::intersect`.
- `Vec2::add_scalar`, `Vec2::mul_scalar`, `Vec2::is_in`.
- `examples/quick-start` demonstration.
- Comprehensive docstrings for all public types and functions.

### Changed
- **BREAKING**: Moved `Vec2`, `AffineMatrix`, `BoundingBox`, `Transform`, and `Alignment`
  from `draw` package to the new `geom` package.
- **BREAKING**: Renamed root `Anchor` to `Alignment` (moved to `@geom.Alignment`).
- **BREAKING**: Renamed root `Path` to `SVGPath`.
- **BREAKING**: Replaced `Point` and `Rectangle` in the root package with `@geom.Vec2` and
  `@geom.BoundingBox`.
- **BREAKING**: Refactored many methods to follow a more functional style (returning new
  instances instead of modifying in-place):
  - `AffineMatrix::invert`, `translate`, `rotate`, `scale`, `scale_scalar`, `skew`, `origin`,
    `normalize` now return new instances.
  - `Path::affine_transform`, `Path::affine_transform_without_translation` now return new instances.
  - `Anchor::affine_transform`, `Anchor::affine_transform_without_translation` now return new instances.
  - `Graphic` methods (`assign_fill`, `remove_fill`, `assign_stroke`, `remove_stroke`,
    `assign_style`, `copy_style`, `scale_stroke`) now return a new `Graphic`.
- **BREAKING**: Renamed `Rectangle` methods to match `BoundingBox` conventions
  (e.g., `empty` -> `is_empty`, `extend` -> `expand_to_include_point`).
- Unified `to_graphic` and `text` API in the `draw` package for better consistency.
- Updated `svg` package to directly accept `Graphic` objects.
- Updated `canvas` package to support `wasm`, `wasm-gc`, and `js` targets.
- Improved naming consistency in tests.
- Refactored `split_path` and `svg-path` logic for better clarity.

### Removed
- **BREAKING**: `all-fonts.mbt` and `all-fonts.txt` (font data is now in external packages).
- **BREAKING**: `geom.mbt` in the root package (replaced by `geom` package).
- **BREAKING**: `draw/bounding-box_test.mbt` (moved to `geom/bounding-box_test.mbt`).
- **BREAKING**: `pt` and `rect` from the root package (now in `@geom`).

### Fixed
- Improved internal consistency and reduced usage of `ignore()` by updating method
  return types to `Unit` where appropriate for in-place operations.
- Corrected `BoundingBox::overlaps_bounding_box` logic to be more standard.
