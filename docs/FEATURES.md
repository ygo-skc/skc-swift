# SKC — UI & Feature Guide

SKC (bundle display name `SKC`) is a SwiftUI iOS app that acts as a reference/browser client
for a Yu-Gi-Oh! trading card database (cards, products, ban lists, trends, and related metadata).
It is a pure client — all data comes from remote backends (`SKCSwift/Network`): most endpoints are
plain JSON/REST, with a gRPC/protobuf service (`SKCSwift/Network/Proto`) used for a handful of
calls (restriction timelines, card scores, products released on a given day). This document
describes the app's screens and the features available on each, for anyone unfamiliar with the
codebase who wants to understand what the app does from a user's perspective.

Konami owns all rights to Yu-Gi-Oh! and card images; the app is not affiliated with Konami
(see the disclosure text on the Home tab).

See [UI_FLOW.md](UI_FLOW.md) for Mermaid diagrams of how the screens described below connect.

## App shell

The root of the UI is `ContentView` (`SKCSwift/ContentView.swift`), a `TabView` with five tabs:

| Tab | Icon | Screen |
|---|---|---|
| Home | `house` | `HomeView` |
| Restrictions | `x.square` | `RestrictedContentView` |
| Browse | `square.grid.2x2` | `BrowseView` |
| Trending | `flame` | `TrendingView` |
| Search | (search role) | `SearchView` |

Each tab owns its own `NavigationStack`, so drilling into a card or product from any tab keeps
its own back-stack. On iOS 26+, the tab bar minimizes on scroll-down and several screens use
`zoom`/`matchedTransitionSource` navigation transitions for a more fluid feel; older iOS versions
fall back to standard presentation.

## Home tab

`HomeView` (`SKCSwift/Views/Home/HomeView.swift`) is a scrollable feed of independently-loading
sections, each with its own loading/error/retry state:

- **Content (DB stats)** (`DBStatsView`) — headline counts of cards, ban lists, and products in
  the database, plus a legal disclosure and the app's version/build number.
- **Today** (`TodayView`) — today's date plus two sub-sections:
  - **Card of the day** (`CardOfTheDayView`) — a featured card with its image, name, and type;
    tapping it navigates into the full card detail screen.
  - **Released on this day** (`ProductsReleasedTodayView`) — products that released on this
    calendar day in a past year, or a "Konami rested" empty state if none did.
- **Upcoming products** (`UpcomingTCGProductsView`) — TCG products Konami has announced, each
  shown with a date badge and notes.
- **YouTube videos** (`YouTubeUploadsView`) — recent uploads from the associated YouTube channel,
  shown as thumbnail + title; tapping opens the video in the system browser/YouTube app.

Pull-to-refresh reloads all of the above. A gear icon in the toolbar opens a **Settings** sheet
with three destructive, confirmation-gated actions:

- Delete network cache (URL cache used to speed up repeat requests).
- Delete file/image cache (Kingfisher on-disk image cache; also clears network cache).
- Delete recently-viewed history (the SwiftData-backed view history used by the Search tab,
  synced across the user's devices).

Each shows its current size in MB and requires confirming via an alert before deleting.

## Restrictions tab

`RestrictedContentView` (`SKCSwift/Views/Restrictions/RestrictedContentView.swift`) shows banned/
limited card lists ("F&L lists") for three formats, switchable via a bottom sheet
(`RestrictedContentNavigatorView`):

- **TCG** and **MD** (Master Duel) — cards are grouped into **Forbidden**, **Limited**, and
  **Semi-Limited** categories. A summary row shows total entries and counts per category, and the
  card list updates to show whichever category is selected. A **Changes** link opens
  `RestrictedContentChangesView`, listing what's newly forbidden/limited/semi-limited and what
  became unlimited compared to the previous list.
- **Genesys** — a point/score format instead of ban categories. Cards are shown with their point
  value, and the summary buckets totals into score ranges (0–30, 31–70, 71+). A toolbar sort menu
  lets the user reorder the list (by score, name, etc., via `Ygo_CardRestrictionSortOrder`).

The navigator sheet also lets the user pick a **date range** — every historical F&L list
effective-date is browsable via a year picker, so past ban list states can be inspected, not just
the current one. If a chosen date range is in the future, the app flags how many days until it
takes effect.

## Browse tab

`BrowseView` (`SKCSwift/Views/BrowseView.swift`) is a segmented (Card / Product) browser with a
filter sheet in the toolbar.

- **Card browse** — filters by attribute, card color, monster type, monster level, monster rank,
  and link rating, each rendered as a toggle grid using the same iconography as elsewhere in the
  app (attribute icons, card color indicators, etc.). Changing any filter re-queries results.
- **Product browse** — a two-stage filter (product type, then product sub-type dependent on the
  chosen types) narrows down products, which are grouped and listed by release year (most recent
  first), each row showing product image, name, and metadata.

Both modes show loading and network-error overlays, and card browse shows a "no cards found"
empty state when filters produce zero results.

## Trending tab

`TrendingView` (`SKCSwift/Views/TrendingView.swift`) shows a segmented (Card / Product) leaderboard
of what's trending, presumably driven by search/view activity on the backend. Each row shows:

- Rank position (`#1`, `#2`, …, gold/silver/bronze colored for the top 3).
- Change vs. the previous period (`+n` in green with an uptrend icon, `-n` in red with a downtrend
  icon, or `±0` in orange for no change).
- Raw hit/occurrence count.

Tapping a row navigates to the card or product detail screen.

## Search tab

`SearchView` (`SKCSwift/Views/SearchView.swift`) has two states depending on whether the search
field has text:

- **Empty state — Recently viewed**: shows AI-suggested related cards ("Suggestions", `sparkles`
  icon), AI-suggested archetypes (labeled **BETA**), and the user's actual recently-viewed card
  history (persisted locally via SwiftData and capped at the last 20 items). If there's no history
  yet, it prompts "Type to search 😉".
- **Typed state — Search results**: a live, debounced search against the card database, grouped
  into sections (e.g. by match type/relevance) with a "no results" empty state and retry-on-error
  handling. A "Loading…" spinner appears if the search takes long enough to be perceptible.

## Card detail screen

`CardInfoView` (`SKCSwift/Views/Card/CardInfoView.swift`) is reached from anywhere a card is
listed. It shows, top to bottom:

1. **Card image + stats** (`YGOCardView`/`CardStatsView`) — artwork, name, attribute, monster
   type/association (Normal/Effect/Fusion/Synchro/Xyz/Link/Pendulum, etc.), ATK/DEF, and effect
   text.
2. **Effect Breakdown** (BETA, `CardMechanicView`) — a server-classified breakdown of the card's
   effect text into summon conditions and a numbered list of effects, each tagged with mechanic
   keywords (and counters, where applicable), rendered as individual cards; a "Card has no effects"
   state covers vanilla/flavor-text cards.
3. **Releases** — a bar chart of the card's rarity distribution across all printings, a button
   listing every product the card was printed in, and "days since debut" / "days since (or until)
   next printing" info cards.
4. **Restrictions** — the card's current competitive-format point score(s) if applicable, plus
   drill-in sheets showing its full TCG and Master Duel F&L (forbidden/limited) history over time.
5. **Suggestions** (AI/heuristic, `sparkles` icon) — horizontally-scrolling carousels for:
   - **Suggested archetypes** (BETA) the card may belong to.
   - **Named Materials** — cards explicitly named as summoning material for this card.
   - **Named References** — cards mentioned in this card's text without being summoning material.
   - **Material For** — Extra Deck cards that can be summoned using this card as material.
   - **Referenced By** — other cards that mention this card (excluding as summon material).
   - **Similar Cards** — cards semantically similar to this one (stats/effects/lore), fetched and
     shown independently of the other suggestion categories.

Recently viewed cards are recorded to local history (and thus synced to the Search tab) whenever
this screen successfully loads a card.

## Product detail screen

`ProductView` (`SKCSwift/Views/Product/ProductView.swift`) shows:

- Product image, release date, ID, type/sub-type tags, and total card count.
- **Metrics** button — opens a sheet with pie charts breaking down the product's contents: rarity
  distribution, Monster/Spell/Trap split, monster color breakdown, and monster attribute
  breakdown.
- **Suggestions** button — opens a sheet with the same "Named Materials / Named References /
  Material For / Referenced By" carousels as the card screen, but aggregated for every card in the
  product.
- A full list of the product's card contents, each tagged with its in-product number and the
  rarities it was printed in.

Like the card screen, viewing a product records it to recently-viewed history.

## Archetype screens

Reached from the "Suggested archetypes" links on the Search tab or a card's detail screen
(`YGOArchetypesView`/`YGOArchetypeView` in `SKCSwift/Views/Card/YGOArchetypesView.swift`):

- Shows every card tied to the archetype, split into three categories: **Inherit Member**
  (archetype appears verbatim in the card's name or text), **Qualified Members** (the card's text
  explicitly denotes it as part of the archetype), and **Excluded Members** (the card's text
  explicitly excludes it despite otherwise qualifying). Large categories (more than 5 cards)
  collapse behind a summary link into a dedicated list screen.
- Because archetype suggestions are AI/heuristic-driven, a "false positive" empty state exists for
  when a suggested archetype turns out not to be real.

## Cross-cutting behaviors

- **Persistence**: recently-viewed cards/products are stored locally via SwiftData
  (`ArchiveContainer`/`History` model) and can be wiped from the Home tab's Settings sheet.
- **Caching**: HTTP responses are cached via `URLCache`; images are cached in memory and on disk
  via Kingfisher, both with size/time limits configured at launch (`SKCSwiftApp.swift`).
- **Consistent loading/error UX**: nearly every data-driven section follows the same pattern —
  a `LoadingView` while pending, a `NetworkErrorView` with a retry button on failure, and a
  `ContentUnavailableView`-style empty state when a request succeeds with no results.
- **Deep navigation**: cards, products, archetypes, and restriction-change screens are all
  reachable via typed navigation destination values (e.g. `CardLinkDestinationValue`,
  `ProductLinkDestinationValue`) so any list (search results, suggestions, trending, browse,
  restrictions) can push directly into the relevant detail screen.
