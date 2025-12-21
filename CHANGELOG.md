# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1/0/).

## [0.18.0] - 2025-12-20

### Added
- New `gmlewis/fonts/geom` package containing core geometric types and utilities.
- `Group::self_transform` for in-place transformation of groups.
- `BoundingBox::is_empty`, `BoundingBox::copy`, `BoundingBox::bounds`, `BoundingBox::dx`,
  `BoundingBox::dy`, `BoundingBox::inset`, `BoundingBox::union`, `BoundingBox::overlaps`,
  `BoundingBox::intersect`.
- `Vec2::add_scalar`, `Vec2::mul_scalar`, `Vec2::is_in`.

### Changed
- **BREAKING**: Moved `Vec2`, `AffineMatrix`, `BoundingBox`, `Transform`, and `Alignment`
  from `draw` package to the new `geom` package.
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
- Updated `canvas` package to support `wasm`, `wasm-gc`, and `js` targets.
- Improved naming consistency in tests.
- Refactored `split_path` and `svg-path` logic for better clarity.

### Removed
- **BREAKING**: `geom.mbt` in the root package (replaced by `geom` package).
- **BREAKING**: `draw/bounding-box_test.mbt` (moved to `geom/bounding-box_test.mbt`).
- **BREAKING**: `pt` and `rect` from the root package (now in `@geom`).

### Fixed
- Improved internal consistency and reduced usage of `ignore()` by updating method
  return types to `Unit` where appropriate for in-place operations.
- Corrected `BoundingBox::overlaps_bounding_box` logic to be more standard.
