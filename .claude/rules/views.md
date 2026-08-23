---
paths:
  - "SKCSwift/Views/**/*.swift"
  - "SKCSwift/ViewModifiers/**/*.swift"
  - "SKCSwift/Util/View.swift"
  - "SKCSwift/SKCSwiftApp.swift"
---

# Views

- `Views/` is grouped by feature (`Home`, `Card`, `Product`, `Restrictions`) plus `Views/Utility` for shared building
  blocks (`LoadingView`, `NetworkErrorView`, `PlaceholderView`, `SectionView`, charts, `FlowLayout`).
- Views receive plain values + a `retryCB` closure, not the view model — this lets them conform to `Equatable` and be
  wrapped in `.equatable()` to skip diffing. Many views hand-write `static func ==`. Keep new leaf views in this shape.
- Cross-cutting styling lives in `ViewModifiers/` (`parentModifier()`, `sheetParentModifier()`, `cardModifier()`,
  tag/text/icon modifiers). Use these instead of ad-hoc padding/background.
- `Util/View.swift` provides `modify { }` and `if(_:transform:)`. `modify` is the project's idiom for OS-version forks:

  ```swift
  .modify {
      if #available(iOS 26.0, *) { $0.tabBarMinimizeBehavior(.onScrollDown) } else { $0 }
  }
  ```

  Deployment target is iOS 18.0, so any iOS 26 API must go through this pattern.

# Images & caching

Kingfisher, configured in `SKCSwiftApp.init()` alongside `URLCache.shared` (10MB memory / 20MB disk network cache;
30MB memory / 80MB disk image cache). Card art comes from `images.thesupremekingscastle.com/cards/{size}/{id}.jpg` with
`ImageSize` picking the variant — always request the smallest size that fits. The Settings sheet lets users purge both
caches (`SettingsViewModel` + `Util/URL.swift` directory-size helpers).
