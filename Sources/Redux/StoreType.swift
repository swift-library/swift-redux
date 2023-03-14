//===--- StoreType.swift --------------------------------------------------===//
//
// This source file is part of the swift-library open source project
//
// Created by Xudong Xu on 3/14/23.
//
// Copyright (c) 2023 Xudong Xu <showxdxu@gmail.com> and the swift-library project authors
//
// See https://swift-library.github.io/LICENSE.txt for license information
// See https://swift-library.github.io/CONTRIBUTORS.txt for the list of swift-library project authors
// See https://github.com/swift-library for the list of swift-library projects
// See https://redux.js.org for redux documentation
//
//===----------------------------------------------------------------------===//

public typealias Unsubscribe = () -> Void

/// Role-specific protocol, defines the interface of Stores in Redux system.
/// View, ViewController and Application can have a store that stores current module state.
/// Stores receive actions and use reducers combined with these actions, to calculate state changes.
/// Upon every state update a store informs all of its subscribers.
public protocol StoreType<State>: ActionDispatchingType {
    
  associatedtype State
  
  /// The current state of the store.
  var state: State! { get }
    
  /// Subscribe state update from store.
  /// - Parameter listener: listener will receive state updates from store
  /// - Returns: unsubscribe function
  func subscribe(_ listener: @escaping (State) -> Void) -> Unsubscribe
  
  /// Subscribe state update from store with state selector.
  /// - Parameters:
  ///   - listener: listener need receive state updates from store
  ///   - selector: A closure that receives a simple subscription and can return a transformed subscription.
  ///   Subscriptions can be transformed to only select a subset of the state, or to skip certain state updates.
  /// - Returns: unsubscribe function
  func subscribe<Substate>(_ listener: @escaping (Substate) -> Void, selector: @escaping Selector<State, Substate>) -> Unsubscribe
}

public extension StoreType {
  
  /// Subscribe state update from store.
  /// - Parameter listener: listener will receive state updates from store
  /// - Returns: unsubscribe function
  func subscribe(_ listener: any ListenerType<State>) -> Unsubscribe {
    subscribe(listener.newState)
  }

  /// Subscribe state update from store with state selector.
  /// - Parameters:
  ///   - listener: listener type need receive state updates from store
  ///   - selector: A closure that receives a simple subscription and can return a transformed subscription.
  ///   Subscriptions can be transformed to only select a subset of the state, or to skip certain state updates.
  /// - Returns: unsubscribe function
  func subscribe<Substate>(_ listener: any ListenerType<Substate>, selector: @escaping Selector<State, Substate>) -> Unsubscribe {
    subscribe(listener.newState, selector: selector)
  }
}
