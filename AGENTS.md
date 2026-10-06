# swift-redux Agent Guide

Read `README.md` and `CONTRIBUTING.md` before editing.

## Authority and route

- `Package.swift` owns products, targets and dependencies.
- `Sources/` owns implementation and colocated module DocC catalogs.
- `Tests/` owns behavior checks; `Scripts/check` is the package validation entry point.
- `README.md` owns installation and usage; `CHANGELOG.md` owns release history.
- `.github/release.json` owns release inputs and CI selection.
- Keep machine-specific paths, generated build output and temporary state in
  ignored local output directories. Preserve source and dependency notices.

## Code Review Rules

### Compatibility and versioning

- Flag a change to public API or observable behavior, including a raised
  minimum platform or Swift version, without the change record and version
  bump the [organization versioning standard](https://github.com/swift-library/.github/blob/master/VERSIONING.md) requires. Safe
  path: record the change under the next version with that bump.

### Claims

- Flag README, DocC, or release-note statements that the code and tests do
  not support: capabilities that do not exist, existing behavior described as
  new, or platforms CI does not build. Safe path: describe what the code
  shows.

### Public documentation

- Flag a new public symbol without a documentation comment, and public prose
  that compares the package with other projects or describes internal
  process. Safe path: document the symbol, and describe only this package's
  own behavior.

### Tests

- Flag a behavior change without a test that would fail before the change.
  Safe path: add the test beside the existing suite for that behavior.
