//===--- DispatchTests.swift ----------------------------------------------===//
//
// This source file is part of the swift-library open source project
//
// Created by Xudong Xu on 3/25/23.
//
// Copyright (c) 2023 Xudong Xu <showxdxu@gmail.com> and the swift-library project authors
//
// See https://swift-library.github.io/LICENSE.txt for license information
// See https://swift-library.github.io/CONTRIBUTORS.txt for the list of swift-library project authors
// See https://github.com/swift-library for the list of swift-library projects
// See https://redux.js.org for redux documentation
//
//===----------------------------------------------------------------------===//

import XCTest
import Redux

final class DispatchTests: XCTestCase {

  func testDispatchRunsReducerAndUpdatesState() {
    let store = Store(state: CounterState(), reducer: counterReducer)

    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.decrement)
    store.dispatch(CounterAction.setLabel("done"))

    XCTAssertEqual(store.state, CounterState(count: 1, label: "done"))
  }

  func testProvidedInitialStateSkipsReducer() {
    var reducerCalls = 0
    let store = Store(state: CounterState(count: 5), reducer: { action, state in
      reducerCalls += 1
      return counterReducer(action, state)
    })

    XCTAssertEqual(reducerCalls, 0)
    XCTAssertEqual(store.state.count, 5)
  }

  func testNilInitialStateComesFromReducer() {
    var received: [(action: ActionType, state: CounterState?)] = []
    let store = Store<CounterState>(state: nil, reducer: { action, state in
      received.append((action, state))
      return state ?? CounterState(count: 10, label: "initial")
    })

    XCTAssertEqual(received.count, 1)
    if case BuiltInAction.initialize? = received.first?.action {} else {
      XCTFail("expected BuiltInAction.initialize, received \(String(describing: received.first?.action))")
    }
    XCTAssertNil(received.first?.state ?? nil)
    XCTAssertEqual(store.state, CounterState(count: 10, label: "initial"))

    store.dispatch(CounterAction.increment)
    XCTAssertEqual(received.count, 2)
    XCTAssertEqual(received.last?.state, CounterState(count: 10, label: "initial"))
  }

  func testMiddlewareRunsInArrayOrderAroundReducer() {
    var log: [String] = []
    func tracing(_ name: String) -> Middleware<CounterState> {
      return { getState in
        { _ in
          { next in
            { action in
              log.append("\(name) before \(getState()?.count ?? -1)")
              next(action)
              log.append("\(name) after \(getState()?.count ?? -1)")
            }
          }
        }
      }
    }
    let store = Store(
      state: CounterState(),
      reducer: { action, state in
        log.append("reducer")
        return counterReducer(action, state)
      },
      middleware: [tracing("first"), tracing("second")])

    store.dispatch(CounterAction.increment)

    XCTAssertEqual(log, [
      "first before 0",
      "second before 0",
      "reducer",
      "second after 1",
      "first after 1",
    ])
  }

  func testMiddlewareCanDropAction() {
    let dropDecrement: Middleware<CounterState> = { _ in
      { _ in
        { next in
          { action in
            if case CounterAction.decrement = action { return }
            next(action)
          }
        }
      }
    }
    let store = Store(state: CounterState(), reducer: counterReducer, middleware: [dropDecrement])

    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.decrement)

    XCTAssertEqual(store.state.count, 1)
  }

  func testMiddlewareDispatchRunsWholeChain() {
    var seen: [String] = []
    let recorder: Middleware<CounterState> = { _ in
      { _ in
        { next in
          { action in
            seen.append("\(action)")
            next(action)
          }
        }
      }
    }
    let labelAfterIncrement: Middleware<CounterState> = { _ in
      { dispatch in
        { next in
          { action in
            next(action)
            if case CounterAction.increment = action {
              dispatch(CounterAction.setLabel("incremented"))
            }
          }
        }
      }
    }
    let store = Store(
      state: CounterState(),
      reducer: counterReducer,
      middleware: [recorder, labelAfterIncrement])

    store.dispatch(CounterAction.increment)

    XCTAssertEqual(store.state, CounterState(count: 1, label: "incremented"))
    XCTAssertEqual(seen, ["increment", "setLabel(\"incremented\")"])
  }

  func testAssigningMiddlewareRebuildsChain() {
    var calls = 0
    let counting: Middleware<CounterState> = { _ in
      { _ in
        { next in
          { action in
            calls += 1
            next(action)
          }
        }
      }
    }
    let store = Store(state: CounterState(), reducer: counterReducer)

    store.dispatch(CounterAction.increment)
    store.middleware = [counting]
    store.dispatch(CounterAction.increment)
    store.middleware = []
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(calls, 1)
    XCTAssertEqual(store.state.count, 3)
  }

  func testStoreReleasedWithMiddleware() {
    let labelAfterIncrement: Middleware<CounterState> = { getState in
      { dispatch in
        { next in
          { action in
            next(action)
            if case CounterAction.increment = action {
              dispatch(CounterAction.setLabel("count \(getState()?.count ?? 0)"))
            }
          }
        }
      }
    }
    weak var released: Store<CounterState>?
    do {
      let store = Store(state: CounterState(), reducer: counterReducer, middleware: [labelAfterIncrement])
      store.dispatch(CounterAction.increment)
      XCTAssertEqual(store.state, CounterState(count: 1, label: "count 1"))
      released = store
    }

    XCTAssertNil(released)
  }
}
