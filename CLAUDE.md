# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SKCSwift is the iOS/iPadOS app for the SKC (Supreme King's Castle) Yu-Gi-Oh! card database — search, browse, card
suggestions, ban list / restriction tracking, and trending content. Pure SwiftUI, no storyboards. It is a client only;
all data comes from three remote backends.

## Where the rest of the guidance lives

Topic rules live in `.claude/rules/` and load automatically when a matching file is read — they are *not* in context
during non-code sessions, so read the relevant one before editing:

| Rule                    | Loads when touching                                                   |
| ----------------------- | --------------------------------------------------------------------- |
| `swift-style.md`        | any `.swift` file — language idioms, logging                          |
| `performance.md`        | any `.swift` file — main-thread, allocation, caching discipline       |
| `view-models.md`        | `ViewModels/`, `Util/Result.swift`                                    |
| `views.md`              | `Views/`, `ViewModifiers/`, `Util/View.swift`, `SKCSwiftApp.swift`    |
| `navigation.md`         | `ContentView.swift`, `Views/`, `ViewModels/`, `Models/YGO.swift`      |
| `networking.md`         | `Network/`                                                            |
| `persistence.md`        | `Models/`                                                             |

## Build & test

`DEVELOPER_DIR` is set for you in `.claude/settings.json` — this machine's `xcode-select` points at Command Line Tools,
which cannot build the app ("requires Xcode"). Do not run `sudo xcode-select`.

```sh
# Build
xcodebuild build -scheme SKCSwift -destination 'generic/platform=iOS Simulator' -configuration Debug

# All tests
xcodebuild test -scheme SKCSwift -destination 'platform=iOS Simulator,name=iPhone 16'

# A single test
xcodebuild test -scheme SKCSwift -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:SKCSwiftTests/SKCSwiftTests/testExample
```

The scheme is `SKCSwift` (targets: `SKCSwift`, `SKCSwiftTests`, `SKCSwiftUITests`). The test targets are currently
Xcode-template stubs — there is no meaningful test suite yet.

Clean builds are slow (grpc-swift-2, swift-nio, SwiftProtobuf, Kingfisher and their transitive deps). Run builds in the
background and grep the log for `** BUILD SUCCEEDED **`, `: error:`, `: warning:`.

**A real build is the only reliable validation here.** Per-file SourceKit/LSP diagnostics in this repo are almost always
false "Cannot find type X" noise caused by cross-file symbols and unexpanded macros (`@Model`, `@ModelActor`,
`@Observable`). Do not act on those without a build.

## Concurrency model (read this before touching any type)

All app targets set `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`, and
`SWIFT_STRICT_CONCURRENCY = complete` (Swift 6 mode). This inverts the usual reading of the code:

- Every type in the module is `@MainActor` **by default**. View models are main-isolated even with no annotation — a
  missing `@MainActor` on a VM is not a bug. The explicit `@MainActor` on a few VMs is redundant, not a signal.
- `nonisolated` and `@concurrent` are the deliberate opt-*outs*. `@concurrent nonisolated` on helpers (`data(...)`, the
  gRPC wrappers, `RecentlyViewedViewModel`'s fetch/consolidate methods) exists to push work off the main actor. A
  main-thread perf problem looks like a heavy method that is main-isolated by default and was *not* marked `@concurrent`.
- Model/DTO types in `Models/` and `Network/` are explicitly `nonisolated struct` so they cross actor boundaries freely.
- `withTaskGroup { addTask { @Sendable in await self.fetchX() } }` is safe: `fetchX()` is main-isolated, so the `await`
  hops back to main before mutating observable state.

## Code priorities

This is a client app whose whole job is rendering remote data on a battery-powered device. In order of precedence:
**idiomatic Swift → main-thread responsiveness → memory footprint / allocation count → brevity.** When two of these
conflict, prefer the earlier one, and say in your summary which tradeoff you made.

The git history is the clearest statement of these priorities — "Shared encoders", "Removed redundant formatter",
"Removed redundant iterations", "Minimizing computation on computed props", "Adding lazy impl.", "Moved logic off main
thread", "Making color map immutable". Match that standard; do not regress it.

## Conventions

- Default branch is `release` (not `master`). Bump `MARKETING_VERSION` in the project when shipping.
- Enums for domain vocabulary (`Attribute`, `MonsterType`, `CardRestrictionFormat`, `ImageSize`, …) live in
  `Util/Enum.swift`; raw values match the API strings exactly and each has an `unknown` fallback case.
- Commit messages are short and imperative, and name the *intent* ("Moved logic off main thread", "Utilizing guard
  pattern") rather than the file changed.
