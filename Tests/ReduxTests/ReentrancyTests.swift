//===--- ReentrancyTests.swift --------------------------------------------===//
//
// This source file is part of the swift-library open source project
//
// Copyright (c) 2023 Xudong Xu <showxdxu@gmail.com> and the swift-library project authors
//
// See https://swift-library.github.io/LICENSE.txt for license information
// See https://swift-library.github.io/CONTRIBUTORS.txt for the list of swift-library project authors
// See https://github.com/swift-library for the list of swift-library projects
// See https://redux.js.org for redux documentation
//
//===----------------------------------------------------------------------===//

// Exit tests need Swift Testing from Swift 6.2 or later.
#if compiler(>=6.2)
#if canImport(Testing) && (os(macOS) || os(Linux) || os(Windows))
import Testing
import Redux

@Suite struct ReentrancyTests {

  @Test func dispatchFromReducerStopsTheProgram() async {
    let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
      var store: Store<CounterState>?
      store = Store(state: CounterState(), reducer: { action, state in
        if case CounterAction.increment = action {
          store?.dispatch(CounterAction.decrement)
        }
        return counterReducer(action, state)
      })
      store?.dispatch(CounterAction.increment)
    }

    let standardError = String(decoding: result?.standardErrorContent ?? [], as: UTF8.self)
    #expect(standardError.contains("Reducers may not dispatch actions"))
  }
}
#endif
#endif
