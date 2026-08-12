---
paths:
  - "SKCSwift/Network/**/*.swift"
---

# Network layer (`Network/`)

Two transports, both normalized to `Result<T, …>` so view models are transport-agnostic:

- **JSON/REST** — `DataTasks.swift`. A single shared `URLSession` with a tuned configuration (5s request / 15s resource
  timeout, TLS 1.3 min, gzip, no cookies, multipath handover). `data(url:resType:)` is the only entry point; it
  translates `URLError`/`DecodingError`/status codes into `NetworkError` and logs via `Logger.network`.
- **gRPC** — `GRPC.swift`. One process-wide `GRPCClient` over HTTP/2 to `ygo-service.skc.cards`, with retry policy,
  keepalive, and backoff configured inline. Used for products-released-same-day, restriction timelines, and card scores.

Three backends, all in `APIURLs.swift`, which is the *only* place hosts/paths live. Every URL is built by a small
`…URL()` function; add new endpoints there rather than constructing URLs at call sites.

- `skc-ygo-api.com` — cards, products, browse, search, stats, ban lists
- `suggestions.skc-ygo-api.com` — suggestions, support, similar cards, archetypes, card of the day, trending
- `heart-api.com` — upcoming events, YouTube uploads

`Network/Proto/*.swift` are **generated** (`// DO NOT EDIT`) from protos that live in the backend repo, not here. There
is no codegen script in this project; regenerate upstream and copy the files in.
