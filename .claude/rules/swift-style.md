---
paths:
  - "SKCSwift/**/*.swift"
---

# Idiomatic Swift (Swift 6, iOS 18+)

- Prefer `guard` for early exit over nested `if` — this repo converted to that deliberately. Guard fetch methods on
  "already loaded / recently refreshed" before doing any work.
- Value types (`struct`) by default; `final class` only for `@Observable` view models and SwiftData `@Model` types.
  Mark every class `final` unless subclassed.
- `private(set)` on all view-model state — mutation happens through methods on the model, never from the view.
- Use `switch` over enums exhaustively rather than `if`-chains on raw strings; add domain vocabulary to
  `Util/Enum.swift` with an `unknown` fallback instead of passing bare `String` around.
- Use the modern stdlib: `map`/`compactMap`/`reduce(into:)`/`prefix`, `async let` and `withTaskGroup` for
  concurrency, `Duration` (`.milliseconds(200)`) over raw `TimeInterval`, typed throws / `Result` over sentinel values.
- Extend existing types rather than adding free helper functions where an extension reads better — see
  `nonisolated extension Date`, `extension Int { var decimal }`, `extension Array where Element == Product`.
- Respect the upcoming-feature flags already enabled: `existential any` (write `any Error`, never bare `Error`),
  member-import visibility, and inferred isolated conformances.

## Logging

`os.Logger` with three categories in `Util/Logger.swift`: `.network`, `.settings`, `.ui`. Interpolations use
`privacy: .public` for non-PII. Use these rather than `print`.
