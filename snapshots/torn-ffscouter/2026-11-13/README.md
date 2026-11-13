# torn-ffscouter snapshot — 2026-11-13

Taken with `scripts/snapshot.sh torn-ffscouter`.

## Files

| File                             | Source                                                                             | Kind              | Version | Upstream `Last-Modified` |
| -------------------------------- | ---------------------------------------------------------------------------------- | ----------------- | ------- | ------------------------ |
| `spec.yaml`                      | `https://ffscouter.com/openapi/spec.yaml`                                          | raw               | 1.22.0  | -                        |
| `spec.json`                      | `https://ffscouter.com/openapi/spec.yaml`                                          | yaml-to-json      | 1.22.0  | -                        |
| `changelog.txt`                  | `https://ffscouter.com/api-docs/changelog`                                         | html-text         | -       | -                        |
| `guide-fair-fight-explained.txt` | `https://ffscouter.com/guides/fair-fight-explained`                                | html-text         | -       | -                        |
| `ff-scouter-v2.meta.js`          | `https://raw.githubusercontent.com/xentac/ffscouter/release-standard/base.user.js` | userscript-header | 3.4     | -                        |

## Checked and unchanged

- `guidance.txt` — still the copy in `../2026-10-12/`
- `guide-api-keys.txt` — still the copy in `../2026-10-12/`
- `guide-battle-stats.txt` — still the copy in `../2026-10-12/`
- `guide-bounty-board.txt` — still the copy in `../2026-10-12/`
- `faq.txt` — still the copy in `../2026-10-12/`

## Mechanical diff: `spec.yaml` vs `../2026-10-12/`

Version **1.14.0 → 1.22.0**.

Added paths: `/api/v1/bounties/orders/{token}/cancel`, `/api/v1/bounties/orders/{token}/pause`, `/api/v1/bounties/orders/{token}/resume`, `/api/v1/od-insurance/history`, `/api/v1/od-insurance/plans`, `/api/v1/od-insurance/status`, `/api/v1/script-metrics`

Removed paths: none.

## Mechanical diff: `spec.json` vs `../2026-10-12/`

Version **1.14.0 → 1.22.0**.

Added paths: `/api/v1/bounties/orders/{token}/cancel`, `/api/v1/bounties/orders/{token}/pause`, `/api/v1/bounties/orders/{token}/resume`, `/api/v1/od-insurance/history`, `/api/v1/od-insurance/plans`, `/api/v1/od-insurance/status`, `/api/v1/script-metrics`

Removed paths: none.

## Diff narrative

Spec version 1.14.0 to 1.22.0. No paths were removed. The changelog
entries from 2026-10-29 to 2026-11-13 explain each version:

- 1.15.0 (2026-10-29): `GET /api/v1/bounties/seller/board` adds a cached
  Torn `status` and `status_last_checked` for each target. The values
  refresh every minute.
- 1.16.0 (2026-10-30): the new OD Insurance tag adds
  `/api/v1/od-insurance/plans` (public), `/status`, and `/history` (both
  need a registered key). The same day, the seller board stopped showing
  unclaimable targets: players in Federal jail, and players abroad and
  inactive for more than 7 days. `POST /api/v1/bounties/seller/claims`
  returns code 91 for such targets.
- 1.17.0 (2026-11-01): `POST /api/v1/bounties/orders/{token}/cancel` lets a
  buyer cancel an order. The order object adds cancellation fields.
- 1.18.0 (2026-11-02): `/pause` and `/resume` for bounty orders. The order
  object adds pause fields and an event `history`. `state` adds `pausing`
  and `paused`.
- 1.19.0 (2026-11-02): OD Insurance plans add `max_multiplier`.
- 1.20.0 (2026-11-02): the new Script Metrics tag adds `POST /api/v1/script-metrics`
  for self-reported script telemetry.
- 1.21.0 and 1.22.0 (2026-11-13): OD Insurance plans, status, and history
  add `covered_item`. From 1.22.0, status and history return the values
  from the time of purchase.

Other files:

- `guide-fair-fight-explained.txt`: the rule for which attacks feed the
  estimator changed. It was "strictly between about 1.05 and 3.00". It is
  now "at least 1.10 and below 3.00".
- `ff-scouter-v2.meta.js`: `@version` 3.3 to 3.4. No other header lines
  changed.
