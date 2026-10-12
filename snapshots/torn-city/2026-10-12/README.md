# Torn API v2 snapshot — 2026-10-12

Re-pull of the v2 OpenAPI spec, to diff against `../2026-07-29/`.

## Files

| File | Source | Fetched via | Upstream `Last-Modified` |
|---|---|---|---|
| `api-v2-openapi.json` | `https://www.torn.com/swagger/openapi.json` | direct `curl` | Wed, 07 Oct 2026 12:50:44 GMT |

## Not re-snapshotted (unchanged)

- `www.torn.com/api.html` (v1 docs): same `Last-Modified` as the 2026-07-29 copy
  (Tue, 14 Jul 2026 13:11:56 GMT). The only byte difference is the per-request
  Cloudflare challenge token in the trailing `<script>`, so it isn't saved again.
- `wiki.torn.com/wiki/API`: no Wayback memento newer than `20251129053008`.

## Diff vs 2026-07-29

Spec version **6.3.1 → 6.13.8**.

New paths:

- `faction`: `crimeexp`, `dirtybombs`, `inventory`, `warfarechains`,
  `warfareraids`, `warfareranked`, `warfareterritory`
- `market`: `pointsmarket`
- `torn`: `bank`, `cards`, `cityshops`, `{shopId}/cityshops`, `companies`,
  `{typeId}/companies`, `gyms`, `pokertables`, `rockpaperscissors`,
  `searchforcash`, `shoplifting`, `stats`, `{ids}/itemstats`
- `user`: `gym`, `networth`, `perks`, `search`, `{id}/medals`

Renamed: `/torn/{id}/itemdetails` → `/torn/{ids}/itemdetails`, which now takes up
to 25 comma-separated item UIDs.

Deprecated: `/faction/warfare` (GET) is replaced by the per-type `warfare*`
selections and `/faction/dirtybombs`. Its description says it **will be removed
on 1 January 2027**.

New error codes: **31** `ErrorCityStatsCronFailed`, **32**
`ErrorEndpointClosedUntilAttackingPeriod`, **33** `ErrorNoCompetitionAvailable`.
Codes 0–30 are unchanged.

26 existing paths and 20 existing schemas changed in other ways (fields,
parameters, descriptions). To see the details, diff a specific path, e.g.
`diff <(jq -S '.paths["/user/log"]' ../2026-07-29/api-v2-openapi.json) <(jq -S '.paths["/user/log"]' api-v2-openapi.json)`.
