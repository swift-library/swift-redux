# ``Redux``

@Metadata {
  @PageImage(purpose: icon, source: "redux-icon", alt: "swift-redux logo")
  @PageColor(purple)
}

Manage application state with actions, reducers, middleware and subscriptions.

## Overview

A store dispatches actions synchronously through its middleware and reducer,
then notifies subscribers. Subscribe to complete state or select a value from
it. Keep reducer functions free of dispatches.

## Topics

### State and actions

- ``Store``
- ``StoreType``
- ``ActionType``
- ``Reducer``

### Middleware and subscriptions

- ``Middleware``
- ``ListenerType``

See the [package usage guide](https://github.com/swift-library/swift-redux/blob/master/README.md)
for installation and complete examples.
