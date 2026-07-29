# Torn API snapshot — 2026-07-29

Raw pulls of Torn's API documentation, taken to have a durable record for diffing against
future snapshots as the API evolves.

## Files

| File | Source | Fetched via | Upstream `Last-Modified` |
|---|---|---|---|
| `api-v1-docs.html` | `https://www.torn.com/api.html` | direct `curl` | Tue, 14 Jul 2026 13:11:56 GMT |
| `api-v2-openapi.json` | `https://www.torn.com/swagger/openapi.json` | direct `curl` | Tue, 28 Jul 2026 15:41:49 GMT |
| `wiki-api-page.html` | `https://wiki.torn.com/wiki/API` | Wayback Machine snapshot `20251129053008` (via `curl web.archive.org`, live page is Cloudflare-gated) | page footer: "last edited 28 August 2025" |

## Access notes (for future fetches)

- `www.torn.com/api.html` (v1 docs) and `www.torn.com/swagger/openapi.json` (v2 OpenAPI spec)
  are both fetchable with a plain `curl` — no Cloudflare challenge. The JSON endpoint in
  particular is a good source for a v2 snapshot: it's the actual machine-readable spec, ~1.2MB,
  and appears to be updated close to live (fetched same day as its `Last-Modified` header
  minus one day).
- `www.torn.com/swagger.php` (the interactive Swagger UI) and `wiki.torn.com` (the wiki, any
  page) are both behind a Cloudflare JS challenge ("Just a moment...") and return HTTP 403 to
  `curl`/WebFetch. There's no network-policy workaround for this — it needs a real browser.
  For the wiki, use the Wayback Machine instead (see below).
- `staticfiles.torn.com` was blocked by sandbox network policy at time of fetch (`no matching
  allow rule`), not by Torn — add it to the allowlist if it turns out to matter.
- Wayback Machine access: the WebFetch tool refuses `archive.org` URLs outright. Use `curl`
  directly instead — `web.archive.org` (not the bare `archive.org` apex) works over HTTPS.
  To find snapshots: `curl https://web.archive.org/web/timemap/link/<url>` lists every
  memento with its timestamp; pick the newest and fetch
  `https://web.archive.org/web/<timestamp>/<url>`.

## Diffs already observed between snapshots

Comparing this wiki snapshot (Aug 2025 edit, fetched via Nov 2025 memento) against an earlier
Jul 2024 memento of the same page:

- Max API keys per user: **10 → 25**.
- Rate-limit wording changed from "per **key**" to "per **user**" (now consistent with the
  official `api.html` docs, which have said "per user, across all keys" throughout).
- "DoctorN" was removed from the wiki's list of safe third-party applications.

## Empirical checks (not from any doc, verified live 2026-07-29)

- A request to `api.torn.com` with a deliberately invalid key returned `HTTP/2 200` with body
  `{"error":{"code":2,"error":"Incorrect key"}}`. Torn's API does **not** use HTTP status codes
  for API-level errors (bad key, rate limit, IP ban, etc.) — every error condition comes back
  as 200 with an `error` object in the body. Tooling must check the body on every response,
  not the status code.
