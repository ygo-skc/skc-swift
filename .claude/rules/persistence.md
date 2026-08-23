---
paths:
  - "SKCSwift/Models/**/*.swift"
---

# Persistence

SwiftData backed by CloudKit (`iCloud.com.skc.app.Archive`), set up in `Models/Archive.swift`. Two models: `Favorite`
and `History`. Because CloudKit requires it, every stored property has a default value. Writes go through
`ArchiveContainer.historyActor` (a `@ModelActor`) — e.g. `CardInfoView` and `ProductView` call
`recordAccess(resource:id:)` on appear. Reads go through `@Query` with the descriptors defined on `History`
(`History.recentlyViewedCards(sortOrder:limit:)`). `History.consolidate` dedupes rows that CloudKit sync can duplicate.
