# Changelog

All notable changes to swift-redux are documented in this file. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

swift-redux has no tagged release yet, so every change below is on the
`master` branch.

## [Unreleased]

### Changed

- `Sink` is a final class instead of a struct, and two sinks are equal only
  when they are the same instance. Its public initializer, `Observer` type
  alias, and `Hashable` conformance are unchanged.
- The `Unsubscribe` closure that `subscribe` returns no longer keeps the store
  alive.

### Fixed

- `dispatch(_:)` no longer stops the program on every action, so a store
  created with a `nil` state builds its initial state from the reducer.
  Dispatching from inside a reducer still stops the program, now with a
  message that names the cause.
- `subscribe` no longer stops the program.
- A listener subscribed with a selector receives the selected state when it
  subscribes and after every action that reaches the reducer.
- After you call `Unsubscribe`, the listener receives no more states, even
  during a notification that is already in progress, and the store releases
  the listener.
- Doc comments no longer mention a nonexistent `ManReducer` or show
  Objective-C usage.

[Unreleased]: https://github.com/swift-library/swift-redux/commits/master
