//===--- Store.swift ------------------------------------------------------===//
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

/// This class is the default implementation of the `StoreType` protocol. You will use this store in most
/// of your applications. You shouldn't need to implement your own store.
/// You initialize the store with a reducer and an initial application state. If your app has multiple
/// reducers you can combine them by initializing a `ManReducer` with all of your reducers as an
/// argument.
open class Store<State>: StoreType {
  
  public var middleware: [Middleware<State>] {
    didSet {
      _underlyingDispatch = underlyingDispatch()
    }
  }
  
  private var reducer: Reducer<State>

  public private(set) var state: State! {
    didSet {
      sinks.forEach {
        $0.forward(oldValue, newValue: state)
      }
    }
  }
  
  private lazy var _underlyingDispatch: DispatchAction = underlyingDispatch()

  private var sinks: Set<Sink<State>> = []
  
  private var idle = AtomicBool(false)
    
  /// Create store with reducer, initial state and middlewares.
  ///
  /// - Parameters:
  ///   - state: Initial state, if any. If `nil` is set, state will be generated by reducer function.
  ///   - reducer: a pure fucntion to modify state with action.
  ///   - middleware: list of middleware to process side effect logic, dispatched before reducer.
  public required init(
    state: State?, reducer:
    @escaping Reducer<State>,
    middleware: [Middleware<State>] = []
  ) {
    self.reducer = reducer
    self.middleware = middleware
    
    if let state = state {
      self.state = state
    } else {
      dispatch(BuiltInAction.initialize)
    }
  }
  
  /// Dispatch action to middlewares, reducer and update state
  /// - Parameter action: action to dispatch
  open func dispatch(_ action: ActionType) {
    _underlyingDispatch(action)
  }
  
  /// Dispatch action to reducer and update state
  /// - Parameter action: action to dispatch
  open func _dispatch(_ action: ActionType) {
    guard idle.load(ordering: .relaxed) else {
      fatalError(
        """
        Due to state consistency, swift redux can not dispatch action concurrently, dispatch: \(action) on flying."
        """)
    }
    
    idle.store(false, ordering: .relaxed)
    let newState = reducer(action, state)
    idle.store(true, ordering: .relaxed)
    
    state = newState
  }
    
  public func subscribe(_ listener: @escaping (State) -> Void) -> Unsubscribe {
    let sink = Sink(observer: {
      listener($1)
    })
    return subscribe(sink)
  }
  
  public func subscribe<Substate>(
    _ listener: @escaping (Substate) -> Void,
    selector: @escaping Selector<State, Substate>) -> Unsubscribe
  {
    var sink = Sink<State>()
    var select = sink.select(selector)
    select.observer = {
      listener($1)
    }
    return subscribe(sink)
  }
  
  private func subscribe(_ sink: Sink<State>) -> Unsubscribe {
    state.flatMap {
      sink.forward(nil, newValue: $0)
    }
    sinks.update(with: sink)
    
    return {
      self.sinks.remove(sink)
    }
  }
  
  /// Create dispatch action chain for middlewares and reducer
  ///
  /// - Returns: an dispatch action chain with closure type
  private func underlyingDispatch() -> DispatchAction {
    return middleware
      .reversed()
      .reduce({ [unowned self] action in
        self._dispatch(action)
      }, { [weak self] nextDispatch, middleware in
        middleware({ self?.state })(self?.dispatch ?? { _ in })(nextDispatch)
      })
  }
}