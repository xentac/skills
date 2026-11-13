# torn-city snapshot — 2026-11-13

Taken with `scripts/snapshot.sh torn-city` for the v2 spec. The v1 docs page
was fetched by hand with `curl` (see below) and recorded with `--record`.

## Files

| File                  | Source                                      | Kind | Version | Upstream `Last-Modified`      |
| --------------------- | ------------------------------------------- | ---- | ------- | ----------------------------- |
| `api-v2-openapi.json` | `https://www.torn.com/swagger/openapi.json` | raw  | 6.16.0  | Thu, 12 Nov 2026 18:56:48 GMT |
| `api-v1-docs.html`    | `https://www.torn.com/api.html`             | raw (by hand, browser user agent) | -       | Tue, 10 Nov 2026 12:35:22 GMT |

## Mechanical diff: `api-v2-openapi.json` vs `../2026-10-12/`

Version **6.13.8 → 6.16.0**.

Added paths: `/faction/headlines`, `/torn/halloween`, `/torn/headlines`, `/user/halloween`, `/user/travelinventory`

Removed paths: none.

## Diff narrative

### `api-v2-openapi.json`

New paths:

- `/torn/headlines` (public key) and `/faction/headlines` (minimal key,
  faction API access) return the news ticker headlines.
- `/torn/halloween` lists the Halloween basket upgrades. `/user/halloween`
  returns your treats and the upgrades that you unlocked. The upstream
  `x-stability` value for `/user/halloween` is the typo `Untable`.
- `/user/travelinventory` (limited key) returns your travel inventory
  capacity.

The selection-name enums for `torn`, `user`, and `faction` gain these
selections.

17 paths changed from `Unstable` to `Stable`. 16 of them were new in 6.13.8.
They include `/torn/bank`, `/torn/stats`, `/torn/companies`, `/faction/inventory`,
`/faction/snapshot`, `/market/pointsmarket`, and `/user/networth`.

Behavior changes:

- `/user/log`: `from` and `to` are inclusive and have one-second
  resolution. To page without gaps, send the `_metadata.nanostamp` cursor
  without `to`. The new parameters `ApiFromLog` and `ApiToLog` document
  this.
- `/key/info`: the response adds `sensitive_data` and
  `legacy_permissions`. These match the new Include sensitive data option
  for custom keys in `api-v1-docs.html`.
- `/racing/races`: the `cat` parameter now takes `official`, `custom`, or
  `available`. The `available` category returns races that you can still
  join, and it ignores `from` and `to`.
- Cache times went down: `/faction/inventory` from 1 hour to 5 minutes,
  `/user/inventory` from 1 hour to 15 minutes per category.
- `/user/properties`: other players' properties are cached for one hour.
- `/torn/{ids}/itemdetails` and `/forum/{categoryIds}/threads` change the
  ID list parameter from `style: form` to `style: simple`.

Schema changes:

- `FactionTerritoryWarResultEnum` adds `end_with_dirty_bomb`.
- `JobPositionCasinoEnum` adds `Dealer`.
- `UserGymResponse` adds `unlocked_gyms`.
- `TornCalendarActivity` adds `earliest_start` and `latest_end`.
  `fixed_start_time` is now required.
- `TornCityStatsResponse` adds `wars_ranked`, `wars_territory`, and
  `wars_raid`.
- `ReportStockAnalysis` adds `stock` and `restock_timestamp`.
- `AttackLog` moves its attacker, defender, and item objects into the new
  named schemas `AttackLogAttacker`, `AttackLogDefender`, and
  `AttackLogItem`.
- The schemas `CompanySearchParameter`, `UserSearchParameter`, and
  `Parameters` are gone from `components.schemas`. Their content is now
  inline in the search filter parameters, so requests do not change.

Not changed: error codes stay 0 to 33. `/faction/warfare` is still
deprecated and still says that it will be removed on 1 January 2027.

### `api-v1-docs.html`

The page has a new layout and a new `Last-Modified` date, so it was fetched
again with a browser user agent. The visible text changed in these places:

- Limits: a new "IP limits" part says that services with many keys may be
  limited to 5,000 requests per minute per IP address. Using several
  servers to get around the limit can get the service blocked and its
  owners' accounts terminated.
- Custom keys: the line "Custom keys should be treated as if they are
  full-access keys" is gone. The page now says that each picked selection
  returns the same data as a regular key. A new Include sensitive data
  checkbox decides whether such a key gets Limited Access data. Keys made
  before the option keep their old permissions.
- Error codes 0 to 30 have the same text in a new layout.

The trailing Cloudflare challenge `<script>` changes on each request, so a
byte comparison of two fetches always shows a difference.

### Not stored again

- `wiki-api-page.html`: the Wayback Machine has no copy newer than
  `20251129053008`. Only `last_checked` changed.
