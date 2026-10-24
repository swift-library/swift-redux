# Contributing

External contributions are welcome. Use a Conventional Commit PR title and run
the local validation commands below before submitting changes. Describe the
behavior being changed and include a regression test for a bug fix. Follow the
[shared contribution guide](https://github.com/swift-library/.github/blob/master/CONTRIBUTING.md)
and [release standard](https://github.com/swift-library/.github/blob/master/VERSIONING.md).
Maintainers follow the shared [signing instructions](https://github.com/swift-library/.github/blob/master/MAINTENANCE.md#signing).

The package requires Swift 6.3 or later, with deployment minimums of macOS 15,
iOS 18, tvOS 18 and watchOS 11.

Run these commands from the repository root:

```sh
swift build
swift test
swift build -c release
xcrun swift-format lint --strict --configuration .swift-format --recursive Package.swift Sources Tests
```

CI builds and tests only with the latest stable Xcode available to the shared
workflows: Xcode 26.6 on `macos-26`. The shared workflows are declared in
`.github/workflows/`, with compiler, platform and documentation configuration in
`.github/swift-package.json`. Building against the latest SDK checks API
availability for the supported deployment targets; CI does not run older systems.
The required checks are `policy / policy` and `validate / result`.

By submitting a contribution, you confirm your right to license it under
[Apache-2.0 WITH Swift-exception](LICENSE.txt). Preserve third-party notices.
