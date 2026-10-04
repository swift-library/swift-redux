//===--- SubscriptionTests.swift ------------------------------------------===//
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

import XCTest
import Redux

final class SubscriptionTests: XCTestCase {

  func testSubscribeDeliversCurrentStateThenEachNewState() {
    let store = Store(state: CounterState(count: 3), reducer: counterReducer)
    var counts: [Int] = []

    let unsubscribe = store.subscribe { counts.append($0.count) }
    XCTAssertEqual(counts, [3])

    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.decrement)
    XCTAssertEqual(counts, [3, 4, 3])
    unsubscribe()
  }

  func testSubscribeAfterNilInitialStateDeliversReducerState() {
    let store = Store<CounterState>(state: nil, reducer: counterReducer)
    var states: [CounterState] = []

    let unsubscribe = store.subscribe { states.append($0) }

    XCTAssertEqual(states, [CounterState()])
    unsubscribe()
  }

  func testEverySubscriberReceivesEachState() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var first: [Int] = []
    var second: [Int] = []

    let unsubscribeFirst = store.subscribe { first.append($0.count) }
    let unsubscribeSecond = store.subscribe { second.append($0.count) }
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(first, [0, 1])
    XCTAssertEqual(second, [0, 1])
    unsubscribeFirst()
    unsubscribeSecond()
  }

  func testSinksAreEqualOnlyToThemselves() {
    let sink = Sink<CounterState>()
    let other = Sink<CounterState>()

    XCTAssertEqual(sink, sink)
    XCTAssertNotEqual(sink, other)
    XCTAssertEqual(Set([sink, other, sink]).count, 2)
  }

  func testListenerObjectReceivesStates() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    let recorder = Recorder<CounterState>()

    let unsubscribe = store.subscribe(recorder)
    store.dispatch(CounterAction.setLabel("a"))

    XCTAssertEqual(recorder.values, [CounterState(), CounterState(label: "a")])
    unsubscribe()
  }

  func testListenerCanDispatch() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var counts: [Int] = []

    let unsubscribe = store.subscribe { state in
      counts.append(state.count)
      if state.count == 1 && state.label.isEmpty {
        store.dispatch(CounterAction.setLabel("one"))
      }
    }
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(store.state, CounterState(count: 1, label: "one"))
    XCTAssertEqual(counts, [0, 1, 1])
    unsubscribe()
  }

  // MARK: - Selectors

  func testSelectorSubscriptionDeliversSelectedStateOnSubscribeAndEveryChange() {
    let store = Store(state: CounterState(count: 2), reducer: counterReducer)
    var counts: [Int] = []

    let unsubscribe = store.subscribe({ counts.append($0) }, selector: { $0.count })
    XCTAssertEqual(counts, [2])

    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.setLabel("unchanged count"))
    XCTAssertEqual(counts, [2, 3, 3])
    unsubscribe()
  }

  func testSelectorSubscriptionAcceptsKeyPath() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var labels: [String] = []

    let unsubscribe = store.subscribe({ labels.append($0) }, selector: \.label)
    store.dispatch(CounterAction.setLabel("a"))
    store.dispatch(CounterAction.setLabel("b"))

    XCTAssertEqual(labels, ["", "a", "b"])
    unsubscribe()
  }

  func testSelectorSubscriptionWithListenerObject() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    let recorder = Recorder<Int>()

    let unsubscribe = store.subscribe(recorder, selector: \.count)
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(recorder.values, [0, 1])
    unsubscribe()
  }

  // MARK: - Unsubscribing

  func testUnsubscribeStopsDelivery() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var stopped: [Int] = []
    var kept: [Int] = []

    let unsubscribeStopped = store.subscribe { stopped.append($0.count) }
    let unsubscribeKept = store.subscribe { kept.append($0.count) }
    store.dispatch(CounterAction.increment)
    unsubscribeStopped()
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(stopped, [0, 1])
    XCTAssertEqual(kept, [0, 1, 2])
    unsubscribeKept()
  }

  func testUnsubscribeStopsSelectorDelivery() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var counts: [Int] = []

    let unsubscribe = store.subscribe({ counts.append($0) }, selector: \.count)
    store.dispatch(CounterAction.increment)
    unsubscribe()
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(counts, [0, 1])
  }

  func testUnsubscribeTwiceIsHarmless() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var counts: [Int] = []
    var otherCounts: [Int] = []

    let unsubscribe = store.subscribe { counts.append($0.count) }
    let unsubscribeOther = store.subscribe { otherCounts.append($0.count) }
    unsubscribe()
    unsubscribe()
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(counts, [0])
    XCTAssertEqual(otherCounts, [0, 1])
    unsubscribeOther()
  }

  func testListenerCanUnsubscribeItselfDuringNotification() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var counts: [Int] = []
    var unsubscribe: Unsubscribe?

    unsubscribe = store.subscribe { state in
      counts.append(state.count)
      if state.count == 1 {
        unsubscribe?()
      }
    }
    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.increment)

    XCTAssertEqual(counts, [0, 1])
  }

  func testUnsubscribeDuringNotificationStopsDeliveryToThatListener() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    var isUnsubscribed = false
    var deliveredAfterUnsubscribe: [Int] = []
    var unsubscribeTarget: Unsubscribe?

    unsubscribeTarget = store.subscribe { state in
      if isUnsubscribed {
        deliveredAfterUnsubscribe.append(state.count)
      }
    }
    let unsubscribeTrigger = store.subscribe { state in
      if state.count == 1 {
        isUnsubscribed = true
        unsubscribeTarget?()
      }
    }
    store.dispatch(CounterAction.increment)
    store.dispatch(CounterAction.increment)

    XCTAssertTrue(isUnsubscribed)
    XCTAssertEqual(deliveredAfterUnsubscribe, [])
    unsubscribeTrigger()
  }

  func testUnsubscribeReleasesListener() {
    let store = Store(state: CounterState(), reducer: counterReducer)
    weak var weakRecorder: Recorder<CounterState>?
    var unsubscribe: Unsubscribe?

    do {
      let recorder = Recorder<CounterState>()
      weakRecorder = recorder
      unsubscribe = store.subscribe(recorder)
    }
    XCTAssertNotNil(weakRecorder)

    unsubscribe?()
    XCTAssertNil(weakRecorder)
  }

  func testUnsubscribeDoesNotKeepStoreAlive() {
    weak var weakStore: Store<CounterState>?
    var unsubscribe: Unsubscribe?

    do {
      let store = Store(state: CounterState(), reducer: counterReducer)
      weakStore = store
      unsubscribe = store.subscribe { _ in }
    }

    XCTAssertNil(weakStore)
    unsubscribe?()
  }
}
