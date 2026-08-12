---
paths:
  - "SKCSwift/**/*.swift"
---

# Performance

- **Keep the main actor free.** Anything non-trivial — decoding, sorting, grouping, set math, deduping, image
  downsampling, directory sizing — goes on a `@concurrent nonisolated` method. Remember types are main-isolated by
  default here, so *not* annotating is what puts work on the main thread. `RecentlyViewedViewModel` is the reference
  example: every fetch/consolidate step is `@concurrent nonisolated`.
- **Compute once, in `init`, not in a computed property.** `YGOCard` derives `attribute` and `monsterTypeE` during
  decode precisely so view bodies don't recompute them on every re-evaluation. A computed property read from a `body`
  runs on every diff — hoist it into stored state or the initializer.
- **Never allocate a `DateFormatter`/`NumberFormatter`/`JSONEncoder`/`JSONDecoder` per call.** They are expensive to
  construct. Reuse the shared statics: `Date.yyyyMMddLocal.formatter`, `Numbers.decimalNumberFormatter`, and the
  file-private `sharedJSONDecoder`/`sharedJSONEncoder` in `DataTasks.swift`. Add a new shared static rather than a
  local instance.
- **Guard against redundant work at every layer**: `lastRefreshTimestamp` + `isDateInvalidated(_:)` to skip refetches
  on view re-appear, `guard forceRefresh || card == nil` in fetch methods, `Task` cancellation + a 200ms debounce in
  `SearchViewModel`, and `Task.checkCancellation()` around network calls.
- **Preserve the observation split.** Only the `DataTaskStatus` should be observed; payloads and errors are
  `@ObservationIgnored`. Making a payload observable turns one view invalidation into several.
- **Keep views `Equatable` and `.equatable()`.** Leaf views take scalars plus a `retryCB`, never the view model —
  passing a VM into a leaf view silently defeats both the `Equatable` conformance and the diffing skip.
- **Lazy containers for anything list-shaped** (`LazyVStack`/`LazyHStack`), so off-screen rows are never built.

# Memory & initialization

- Request the smallest image that fits: pick the right `ImageSize` and pass `downsampling(size:)` — never load
  `.original` into a thumbnail. Cache budgets are set once in `SKCSwiftApp.init()`; adjust there, not ad hoc.
- Hoist constants out of view bodies into `private static let` (e.g. `CardImageView.CARD_BACK_IMAGE`) so each row
  doesn't re-create them.
- Use `StaticString` for compile-time literal constants such as hosts and endpoint paths (see `APIURLs.swift`) — it
  avoids `String` allocation and heap storage.
- Prefer `Set` over `Array` for membership tests (`cardIDsForSearchResults`, `archetypeSuggestions`) and
  `reduce(into:)` over `reduce` to avoid intermediate copies.
- Deduplicate and `prefix(n)` *before* building view state — `consolidateSuggestions` trims to 8 entries before it
  ever reaches the UI.
- Long-lived shared resources are created once as `static let` (the `URLSession`, the gRPC `GRPCClient`, the SwiftData
  `ModelContainer`, formatters, calendars). Don't construct a second one; extend the existing.
- Bound growth in persisted data: `History.recentlyViewedCards` has a `fetchLimit`, and `History.consolidate` collapses
  duplicate rows.
