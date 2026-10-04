//===--- Fixtures.swift ---------------------------------------------------===//
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

import Redux

struct CounterState: Equatable {
  var count = 0
  var label = ""
}

enum CounterAction: ActionType {
  case increment
  case decrement
  case setLabel(String)
}

func counterReducer(_ action: ActionType, _ state: CounterState?) -> CounterState {
  var state = state ?? CounterState()
  switch action {
  case CounterAction.increment:
    state.count += 1
  case CounterAction.decrement:
    state.count -= 1
  case CounterAction.setLabel(let label):
    state.label = label
  default:
    break
  }
  return state
}

final class Recorder<Value>: ListenerType {
  private(set) var values: [Value] = []

  func newState(_ state: Value) {
    values.append(state)
  }
}
