# torn-ffscouter snapshot — 2026-10-12

Taken with `scripts/snapshot.sh torn-ffscouter`. First snapshot, taken when the
`torn-ffscouter` skill was written; everything the skill states as fact about
FF Scouter's API, terms, and FF math is cited from these files.

## Files

| File | Source | Kind | Version | Upstream `Last-Modified` |
|---|---|---|---|---|
| `spec.yaml` | `https://ffscouter.com/openapi/spec.yaml` | raw | 1.14.0 | - |
| `spec.json` | `https://ffscouter.com/openapi/spec.yaml` | yaml-to-json | 1.14.0 | - |
| `guidance.txt` | `https://ffscouter.com/api-docs/guidance` | html-text | - | - |
| `changelog.txt` | `https://ffscouter.com/api-docs/changelog` | html-text | - | - |
| `guide-api-keys.txt` | `https://ffscouter.com/guides/api-keys` | html-text | - | - |
| `guide-fair-fight-explained.txt` | `https://ffscouter.com/guides/fair-fight-explained` | html-text | - | - |
| `guide-battle-stats.txt` | `https://ffscouter.com/guides/battle-stats` | html-text | - | - |
| `guide-bounty-board.txt` | `https://ffscouter.com/guides/bounty-board` | html-text | - | - |
| `faq.txt` | `https://ffscouter.com/faq` | html-text | - | - |
| `ff-scouter-v2.meta.js` | `https://raw.githubusercontent.com/xentac/ffscouter/release-standard/base.user.js` | userscript-header | 3.3 | - |

## Notes

- No upstream `Last-Modified` headers are sent by ffscouter.com, so
  `last_checked` in `../index.tsv` is the only freshness signal.
- `spec.json` is derived from `spec.yaml` (`yq -o=json`), so consumers can
  query it with `jq` without needing `yq`.
- The `*.txt` files are the visible text from each page's `<h1>` to its
  `<footer>`, which strips the site nav and per-deploy asset hashes. The raw
  HTML was byte-stable across two fetches minutes apart, but its hashed
  asset links would change on every deploy.
- `ff-scouter-v2.meta.js` is only the `==UserScript==` header of the
  released `base.user.js`. `@match` is `https://www.torn.com/*`, so the
  per-page coverage lives in the source (`src/features/`), not the header.
- Not snapshotted: the data policies (the home-page "Data Policy" panel at
  `https://ffscouter.com/#data-policy`, and the Bounty Board policy on
  `/claim-bounties`). Tools must link the live versions, and FF Scouter
  says they change.

## Diff narrative

None (first snapshot). Spec version 1.14.0; the newest changelog entry is
2026-10-05.
