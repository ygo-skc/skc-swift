---
paths:
  - "SKCSwift/ContentView.swift"
  - "SKCSwift/Views/**/*.swift"
  - "SKCSwift/ViewModels/**/*.swift"
  - "SKCSwift/Util/View.swift"
  - "SKCSwift/Models/YGO.swift"
---

# Navigation

Root is a `TabView` in `ContentView.swift` (Home / Restrictions / Browse / Trending / Search). Each tab owns a
`NavigationStack` whose `path` lives on its view model (`model.path`), so view models can push destinations — see
`HomeViewModel.handleURLClick`, wired up via `.environment(\.openURL, …)` to intercept in-app `/card/…` and `/product/…`
links.

Destinations are typed `…LinkDestinationValue` structs at the bottom of `Models/YGO.swift`, registered once in
`Util/View.swift`'s `ygoNavigationDestination()`. Adding a navigable screen means: new `Hashable` value struct + a case
in `ygoNavigationDestination()`.
