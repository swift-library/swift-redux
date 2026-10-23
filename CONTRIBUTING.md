# Contributing

External contributions are welcome. Use a Conventional Commit PR title and run
the local validation commands below before submitting changes. Describe the
behavior being changed and include a regression test for a bug fix. Follow the
[shared contribution guide](https://github.com/swift-library/.github/blob/master/CONTRIBUTING.md)
and [release standard](https://github.com/swift-library/.github/blob/master/VERSIONING.md).
Maintainers follow the shared [signing instructions](https://github.com/swift-library/.github/blob/master/MAINTENANCE.md#signing).

Run these commands from the repository root:

```sh
swift build
swift test
swift build -c release
xcrun swift-format lint --strict --configuration .swift-format --recursive Package.swift Sources Tests
```

CI uses the shared workflows declared in `.github/workflows/` and the compiler,
platform and documentation configuration in `.github/swift-package.json`.
The required checks are `policy / policy` and `validate / result`.

By submitting a contribution, you confirm your right to license it under
[Apache-2.0 WITH Swift-exception](LICENSE.txt). Preserve third-party notices.
