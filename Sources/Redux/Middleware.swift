//===--- Middleware.swift -------------------------------------------------===//
//
// This source file is part of the swift-library open source project
//
// Created by Xudong Xu on 4/5/23.
//
// Copyright (c) 2023 Xudong Xu <showxdxu@gmail.com> and the swift-library project authors
//
// See https://swift-library.github.io/LICENSE.txt for license information
// See https://swift-library.github.io/CONTRIBUTORS.txt for the list of swift-library project authors
// See https://github.com/swift-library for the list of swift-library projects
// See https://redux.js.org for redux documentation
//
//===----------------------------------------------------------------------===//

/// Create redux middleware with given functions and return a middleware dispatch action function
/// - Parameters:
///   - state: `store.state` getter function on store
///   - dispatch: refers to the `dispatch(_ action:)` function on store for middleware to dispatch additional action
///   - nextDispatch: refers to next action dispatching type, reducer or a another middleware
/// - Returns: this middleware dispatch action implementation
/// - Discussion: 
public typealias Middleware<State> = (_ state: @escaping () -> State?) -> (_ dispatch: @escaping DispatchAction) -> (_ nextDispatch: @escaping DispatchAction) -> DispatchAction
