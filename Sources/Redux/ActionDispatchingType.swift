//===--- ActionDispatchingType.swift --------------------------------------===//
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

/// Role-specific protocol, a redux store and middleware conforms to this protocol
public protocol ActionDispatchingType {
  
  /// Dispatching an action is the only way to modify the state on a redux store.
  ///
  /// Usage:
  ///   ```
  ///   [store dispatch:action]
  ///   ```
  /// - Parameter action: action to dispatch
  func dispatch(_ action: ActionType)
}

/// DispatchAction is function type corresponding to ActionDispatchingType.
public typealias DispatchAction = (ActionType) -> Void
