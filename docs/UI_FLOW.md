# SKC — UI Navigation Map

This diagram complements [FEATURES.md](FEATURES.md) with a visual map of how the app's screens,
tabs, and sheets connect. Rather than one large flowchart, the map is split into one diagram per
tab plus a shared diagram for the two hub screens (**Card Detail**, **Product Detail**) that
almost every tab eventually routes into — splitting it this way keeps each diagram readable
instead of one dense graph with long crossing edges.

Rounded/stadium nodes are modal sheets or popovers; rectangular nodes are pushed navigation
destinations; the double-bordered "subroutine" nodes are full screens; dashed nodes are **stubs**
— the same screen shown fully expanded in the [Card & Product Detail](#card--product-detail-hub)
diagram at the bottom.

## App shell

```mermaid
flowchart TD
    Root["App Launch"] --> Tabs{{"Tab Bar"}}
    Tabs --> Home[["Home"]]
    Tabs --> Restrictions[["Restrictions"]]
    Tabs --> Browse[["Browse"]]
    Tabs --> Trending[["Trending"]]
    Tabs --> Search[["Search"]]
```

Each tab owns its own `NavigationStack` — a card/product pushed from one tab doesn't affect the
others' back-stacks.

## Home tab

```mermaid
flowchart TD
    Home[["Home Feed"]]
    Home --> DBStats["DB Stats"]
    Home --> COTD["Card of the Day"]
    Home --> RelToday["Released on this Day"]
    Home --> Upcoming["Upcoming Products"]
    Home --> YT["YouTube Uploads"]
    Home -- "gear icon" --> Settings(("Settings sheet"))
    Settings --> DelNet["Delete network cache"]
    Settings --> DelFile["Delete file cache"]
    Settings --> DelHist["Delete history"]

    COTD --> CardDetail[["Card Detail"]]:::stub
    RelToday --> ProductDetail[["Product Detail"]]:::stub
    YT -. "system browser" .-> External(("YouTube app"))

    classDef stub stroke-dasharray: 5 5
```

## Restrictions tab

```mermaid
flowchart TD
    Restrictions[["Restricted Content<br/>(TCG / MD / Genesys)"]]
    Restrictions -- "bottom sheet" --> Navigator(("Format / Category /<br/>Date range picker"))
    Restrictions -- "Changes link" --> Changes["Changes View<br/>(new + removed)"]
    Restrictions --> CardDetail[["Card Detail"]]:::stub
    Changes --> CardDetail

    classDef stub stroke-dasharray: 5 5
```

## Browse tab

```mermaid
flowchart TD
    Browse[["Browse<br/>(segmented)"]]
    Browse --> BCard["Card Browse"]
    Browse --> BProduct["Product Browse"]
    BCard -- "filter icon" --> CardFilters(("Card Filters sheet"))
    BProduct -- "filter icon" --> ProductFilters(("Product Filters sheet"))

    BCard --> CardDetail[["Card Detail"]]:::stub
    BProduct --> ProductDetail[["Product Detail"]]:::stub

    classDef stub stroke-dasharray: 5 5
```

## Trending tab

```mermaid
flowchart TD
    Trending[["Trending<br/>(segmented)"]]
    Trending --> TCard["Trending Cards"]
    Trending --> TProduct["Trending Products"]

    TCard --> CardDetail[["Card Detail"]]:::stub
    TProduct --> ProductDetail[["Product Detail"]]:::stub

    classDef stub stroke-dasharray: 5 5
```

## Search tab

```mermaid
flowchart TD
    Search[["Search"]]
    Search -- "empty query" --> Recent["Recently Viewed<br/>+ AI Suggestions"]
    Search -- "typed query" --> Results["Search Results"]

    Recent --> CardDetail[["Card Detail"]]:::stub
    Results --> CardDetail
    Recent -- "suggested archetype" --> ArchetypeScreen[["Archetype Screen"]]:::stub

    classDef stub stroke-dasharray: 5 5
```

## Card & Product Detail hub

The two screens nearly every tab above routes into, plus the Archetype screen they both link to.
This is the part of the map worth studying closely — it's where deep-linking and cross-navigation
between cards, products, and archetypes actually happens.

```mermaid
flowchart TD
    CardDetail[["Card Detail"]]
    ProductDetail[["Product Detail"]]
    ArchetypeScreen[["Archetype Screen"]]

    CardDetail -- "Releases button" --> CardReleaseSheet(("Printings sheet"))
    CardReleaseSheet --> ProductDetail
    CardDetail -- "Restrictions button" --> CardBanSheet(("F/L history sheet"))
    CardDetail -- "Suggested archetypes" --> ArchetypeScreen

    ProductDetail -- "Metrics button" --> ProductMetrics(("Metrics sheet<br/>(pie charts)"))
    ProductDetail -- "Suggestions button" --> ProductSuggest(("Suggestions sheet"))
    ProductDetail -- "Contents list" --> CardDetail

    ArchetypeScreen -- "large category" --> ArchCategory["Category Detail<br/>(Inherit Member / Qualified Members /<br/>Excluded Members)"]
    ArchCategory --> CardDetail
```

## Reading the map

- **Stub nodes** (dashed `Card Detail`/`Product Detail`) mark where a tab hands off to one of the
  two hub screens. Their internal navigation isn't redrawn per tab — it's expanded once, in the
  [hub diagram](#card--product-detail-hub) above, since almost every tab (Home, Browse, Trending,
  Search, Restrictions, Archetypes) eventually routes into one or the other.
- **Sheets/popovers** (stadium shapes) are transient overlays — the Settings panel, filter panels,
  the restriction format/date navigator, and the card/product metrics & suggestions panels — that
  return to the screen that presented them rather than pushing a new stack entry.
- Not pictured, to avoid diagram clutter: `Card Detail`'s own "suggestions" carousel can link to
  *other* cards, re-entering the same screen type with a different card ID.
