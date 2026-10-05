# Changelog

## Unreleased

## 0.1.0

The first tagged release.

### Changed

- `Store` is safe to use from several threads. A recursive lock serializes
  dispatching, subscribing and unsubscribing, so a dispatch from another thread
  waits instead of stopping the program, and `Store` conforms to `Sendable`.
- The minimum platforms are iOS 15, watchOS 9 and tvOS 15, the oldest targets
  Xcode 27 builds for. macOS 12 is unchanged.
- swift-redux has no dependencies. The `AtomicBool` type alias and the Swift
  Atomics dependency are removed.
- `Sink` is a final class instead of a struct, and two sinks are equal only
  when they are the same instance. Its public initializer, `Observer` type
  alias, and `Hashable` conformance are unchanged.
- The `Unsubscribe` closure that `subscribe` returns no longer keeps the store
  alive.

### Fixed

- A store with middleware that captures `dispatch` is released when its last
  reference goes away. The middleware chain held the store strongly.
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
