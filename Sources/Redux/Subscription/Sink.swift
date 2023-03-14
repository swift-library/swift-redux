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

public struct Sink<T>: Equatable, Hashable {
  
  public typealias Observer = (T?, T) -> Void
  
  var observer: Observer?
  
  /// Create redux subscription will sink closure
  /// - Parameter forward: given the caller a sink cloure to forward result
  /// - Discussion: `(State?, State) -> Void)` is observer closure of the sink to forward redux state update
  public init(sink: (@escaping (T?, T) -> Void) -> Void = { _ in }, observer: Observer? = nil) {
    self.observer = observer
    sink(forward)
  }
    
  func forward(_ oldValue: T?, newValue: T) {
    observer?(oldValue, newValue)
  }
  
  private var bitPattern: Int {
    unsafeBitCast(self, to: Int.self)
  }
  
  public static func == (lhs: Sink<T>, rhs: Sink<T>) -> Bool {
    lhs.bitPattern == rhs.bitPattern
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(bitPattern)
  }
}

// reselect state
extension Sink {
  
  typealias State = T
  
  mutating func select<Substate>(_ keyPath: KeyPath<State, Substate>) -> Sink<Substate> {
    return select { $0[keyPath: keyPath] }
  }
  
  mutating func select<Substate>(_ selector: @escaping Selector<State, Substate>) -> Sink<Substate> {
    return .init { sink in
      observer = {
        sink($0.map(selector), selector($1))
      }
    }
  }
}
