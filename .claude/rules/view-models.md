---
paths:
  - "SKCSwift/ViewModels/**/*.swift"
  - "SKCSwift/Util/Result.swift"
---

# MVVM with `@Observable`

One `final class …ViewModel` per screen in `ViewModels/`, held by the view as `@State private var model = …ViewModel()`.
The uniform state shape is a **triple per data source**:

```swift
private(set) var cotdDTS: DataTaskStatus = .pending   // .pending / .done / .error — observed, drives UI
@ObservationIgnored private(set) var cotdNE: NetworkError?  // error detail, read only when DTS == .error
@ObservationIgnored private(set) var cardOfTheDay = …       // the payload
```

Only the `DataTaskStatus` is observed; payload and error are `@ObservationIgnored` so a fetch triggers exactly one view
invalidation. Preserve that split when adding state.

`Util/Result.swift` is what makes this terse — `validate()`, `validate(&dest)`, and `validate(&dest, keyPath:)` turn a
`Result` into the `(NetworkError?, DataTaskStatus)` tuple and assign the payload in one line. The gRPC overloads take an
extra `method:` label used for logging and map `RPCError` → `NetworkError`. Prefer adding an overload there over
hand-rolling `switch` blocks in a view model.

Fetch methods follow: reset to `(nil, .pending)`, await, assign the tuple. Screen-level `fetchData(forceRefresh:)`
fans out via `withTaskGroup` and guards on a `lastRefreshTimestamp` so re-appearing views don't refetch.
