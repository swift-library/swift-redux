//===--- Sink.swift -------------------------------------------------------===//
//
// This source file is part of the swift-library open source project
//
// Created by Xudong Xu on 3/16/23.
//
// Copyright (c) 2023 Xudong Xu <showxdxu@gmail.com> and the swift-library project authors
//
// See https://swift-library.github.io/LICENSE.txt for license information
// See https://swift-library.github.io/CONTRIBUTORS.txt for the list of swift-library project authors
// See https://github.com/swift-library for the list of swift-library projects
// See https://redux.js.org for redux documentation
//
//===----------------------------------------------------------------------===//

/// A subscription that forwards state updates to its observer.
///
/// Each sink is a distinct object: two sinks are equal only when they are the same instance.
public final class Sink<T>: Equatable, Hashable {
  
  public typealias Observer = (T?, T) -> Void
  
  var observer: Observer?
  
  /// Create redux subscription with sink closure
  /// - Parameters:
  ///   - sink: receives the sink's forwarding closure, `(oldState, newState) -> Void`, to forward redux state updates
  ///   - observer: receives the previous state, if any, and the new state
  public init(sink: (@escaping (T?, T) -> Void) -> Void = { _ in }, observer: Observer? = nil) {
    self.observer = observer
    sink(forward)
  }
    
  func forward(_ oldValue: T?, newValue: T) {
    observer?(oldValue, newValue)
  }
  
  /// Stop forwarding state updates and release the observer
  func cancel() {
    observer = nil
  }
  
  public static func == (lhs: Sink<T>, rhs: Sink<T>) -> Bool {
    lhs === rhs
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}
