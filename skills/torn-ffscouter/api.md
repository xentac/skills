# FF Scouter API

Written against spec **1.14.0** (snapshot 2026-10-12). The spec is the
source of truth for parameters, schemas, and error codes — query
`spec.json` with `jq` (see `SKILL.md` for where it lives and the drift
check). This file covers what the spec doesn't say well: the rate-limit
model, caching, premium gating, and how the pieces fit.

## Basics

- **Base URL:** `https://ffscouter.com/api/v1/`. JSON in and out.
- **Auth:** the user's registered Torn key as the `key` query parameter
  (body field for some POSTs). See `developer-terms.md` for registration.
  Keys in query strings end up in access logs and browser history — never
  log full request URLs in your own tool.
- **CORS:** responses carry `access-control-allow-origin: *`, so browser
  SPAs can call the API directly; no proxy needed.
- **Userscripts:** need `@connect ffscouter.com` with `GM_xmlhttpRequest`
  (or Torn PDA's `PDA_httpGet`/`PDA_httpPost`), as FF Scouter V2 does.
- **Errors:** `{"code": int, "error": string}`, plus optional `source`
  (`ffscouter` or `torn` — `torn` means FF Scouter called Torn on the
  user's behalf and Torn failed; see `torn_code`), `retry_after_seconds`,
  and `detail`. Codes are per-endpoint (the same number means different
  things on different routes), so look them up in the operation's
  responses. Common ones:

  | Code | Meaning |
  | --- | --- |
  | 1 / 2 | key missing / malformed |
  | 6 | key not registered with FF Scouter |
  | 19 | premium required (403) |
  | 20 | per-account premium rate limit (429) |
  | 21 | per-IP route rate limit (429) |
  | 4010 / 4011 | key owner / their faction is banned from FF Scouter (403) |

## Rate limits

Two independent budgets:

- **Per IP, per route** (code 21) — e.g. `get-stats` and
  `get-stats-history` 120/min, `get-targets` 25/min, `check-key` 20/min,
  `register` 10/min (plus 3 registrations/min). A backend serving many
  users shares one IP budget across all of them — batch and cache.
- **Per premium account** (code 20) — Flights cost one unit per unique
  target from a 100/min budget shared across all of that user's keys, and
  are exempt from the per-IP throttle. Activity has its own limits (60/min
  player, 10/min faction).

Each operation's 429 response description states its limit.

## Caching and the per-user `fair_fight`

The guidance asks for ~1 hour of caching per player for stat estimates
(FF Scouter V2 caches for one hour in IndexedDB). Two things to get right:

- **`fair_fight` is computed against the key owner's own stats** —
  "calculated FF from your public BSS and theirs" (FF guide). The same
  target has a different `fair_fight` for every requesting user. Never
  serve one user's cached `fair_fight` to another; cache it per key owner,
  or cache `bss_public` and compute FF yourself with the formula in
  `concepts.md` (that needs the viewer's own BSS).
- **A cache shared across users** is also a terms question — serving user
  B from data fetched with user A's key may count as key sharing. See
  "Questionable implementations" in `developer-terms.md`.

## Player Stats

`GET get-stats?key=…&targets=id1,id2,…` — up to **205** player IDs per call,
one result object per target. Key fields:

- `fair_fight` — FF against the key owner (see above); null when unknown.
- `bs_estimate` / `bs_estimate_human` — estimated total battle stats
  (e.g. `2.99b`), a heuristic from `bss_public`; see `concepts.md`.
- `bss_public` — the shared-pool Battle Stat Score estimate.
- `last_updated` — Unix seconds of the estimate; treat estimates older than
  ~28 days with caution (FAQ).
- `source` — which estimate the top-level fields come from (`bss`,
  `premium`, …).
- `available_estimates` — `{bss, premium, spies}`, each null or its own
  estimate with its own `fair_fight`. Lets you show every source
  side by side.
- `premium_insights_available`, `distribution` (stat split percentages),
  `spies` (TornStats spy data shared via faction) — premium enrichments;
  respect the "no premium data to non-premium users" rule if you relay
  them.

Unknown players come back with all estimate fields null rather than an
error.

`GET get-stats-history?key=…&target=id` — one player's estimate history
in 6-hour buckets (`limit` 1–100, optional `from`/`to`/`sort`).

## Targets

`GET get-targets?key=…` — Target Finder candidates for the key owner.
Either a `preset` (`respect` or `level`; only `key` and `limit` may
accompany it) or filters: `minlevel`/`maxlevel` (1–100), `minff`/`maxff`
(≥1), `inactiveonly` (0/1), `factionless` (0/1), repeated
`elimination_teams`. `limit` 1–50 (default 50). **25 requests/min per
IP.** No match is a 404 with code 17, not an empty list. Candidates' FF is
relative to the key owner.

## Flights (premium)

Requires active premium on the key owner (403 code 19 otherwise).

- `GET player-flights?key=…&target=id` — `current` trip (null if not
  traveling) plus `recent_flights`.
- `GET player-flights/batch?key=…&targets=…` — current trip for 1–100
  unique players (duplicates collapsed, results in request order).

Flight leg fields: `takeoff_time`, `status_description` (e.g. "Traveling to
Japan"), `earliest_arrival_time` / `latest_arrival_time` (an arrival
window, not a point), `approx_landing_time`, `travel_method` (e.g.
`Airline`), and `book_likely_being_used`. Times are Unix seconds. Responses
are cached server-side ~60 seconds, so polling faster gains nothing. 503
code 22 means flight data is temporarily unavailable — back off.

**Handling non-premium users:** call `check-key` once at setup and on key
change; if `is_premium` is false, hide or upsell flight features rather
than calling and showing 403s. Re-check near `premium_expires_at`. Never
fill the gap with another user's premium key.

## Bounty Board

Buyers pay for confirmed hospitalizations of a player or faction; sellers
earn by making those hits. Buyers stay anonymous. This moves real in-game
value (paid in Xanax, item 206) — make costs and steps explicit to users.

**Buyer endpoints need no key:**

- `GET bounties/orders/quote?quantity=…&price_per_hit=…` — cost including
  FF Scouter's tiered fee (35% for 1–4 hits, 30% 5–9, 25% 10–99, 20% 100+).
- `POST bounties/orders` — body `target_player_id` *or*
  `target_faction_id` (not both), `price_per_hit`, `quantity`, optional
  `referrer_player_id` (commission; see `developer-terms.md`). Returns
  `payment_instructions`: send the Xanax with the exact message given. The
  bounty goes live once fully funded (partial payments accumulate). Some
  players are excluded from player bounties (code 99).
- `GET bounties/orders/{token}` — order status, the only place seller
  identities appear. The token is the buyer's only credential — show it
  to the buyer and keep it private.

**Seller endpoints need a registered key and Bounty Board policy consent**
(code 86 until `POST bounties/seller/policy/accept` with
`i_have_read_rules_and_data_policy: true` — only after showing the user
the policy at `https://ffscouter.com/claim-bounties`):

- `GET bounties/seller/board` — open bounties per target, plus the
  seller's own claim/payout status.
- `POST bounties/seller/claims` — after hospitalizing a target, opens a
  monitoring session: FF Scouter reads the seller's Torn attack log and
  credits Hospitalized hits from the last 24 hours against eligible
  bounties. Only the finishing hit counts.
- `GET bounties/seller/claims/status` — the seller's pending claims,
  credited hits, and payouts.

## Other tags (index only)

Query `spec.json` for details before using these.

- **Activity** (premium) — time-bucketed online activity for a player or
  faction, from FF Scouter's scanners. Only factions in roughly the top
  1,000 are tracked automatically.
- **Hit Calling** (premium) — faction target claim queue. A "dibs" system
  intended to replace it is in design (not finalized as of 2026-10-12, per
  its author); it will probably ship in Torn War Stuff Enhanced rather than
  FF Scouter. Check the changelog before building on Hit Calling.
- **Losses** — marketplace for buying and selling losses: buyer orders
  (with a 14-character order secret), seller contracts and claims.
- **Notes** — personal, faction, and team notes on players and factions.
  **Render note content as plain text only, never as HTML or links** (the
  spec requires it).
- **TornStats** — store the caller's TornStats key for faction spy sync.
  The key is never returned by the API.
- **Account** — Xanax-funded prepaid balances (deposit by sending Xanax
  with message `deposit` or `factiondeposit`; no withdrawals) and
  transaction history.
- **API Keys** — `register` and `check-key`; see `developer-terms.md`.
