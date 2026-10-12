---
name: torn-ffscouter
description:
  Reference for FF Scouter (ffscouter.com), the Torn City battle-stat
  estimate service — its public API (stat estimates, targets, flights,
  bounty board, and more), its developer terms and key requirements, Fair
  Fight concepts, and the FF Scouter V2 userscript. Use whenever FF Scouter,
  ffscouter.com, Fair Fight / FF estimates, bss_public, or the FF Scouter
  API is mentioned, or when writing code, userscripts, apps, or bots that
  read FF Scouter data.
---

# FF Scouter

FF Scouter (`ffscouter.com`) estimates Torn players' battle stats from the
Fair Fight values in volunteers' attack logs, and serves them through a
website, the FF Scouter V2 userscript, and a public JSON API
(`https://ffscouter.com/api/v1/...`, OpenAPI spec at
`https://ffscouter.com/openapi/spec.yaml`).

## Torn's rules apply first

Anything that touches Torn is governed by Torn's rules before FF Scouter's.
The **`torn-city` skill is authoritative** — load it and read its
`rules-and-compliance.md` before designing any tool. If it isn't installed,
read it from
`https://raw.githubusercontent.com/xentac/skills/main/skills/torn-city/rules-and-compliance.md`.
The floor, in case neither is available (summary; `torn-city` is
authoritative):

- **Never drive torn.com with browser automation yourself** (Claude in
  Chrome, Playwright, computer-use). Hand the user a console snippet to run
  on a page they loaded instead.
- **Scripting Abuse:** software may only use API data or a page the user
  manually loaded and is actively viewing — no extra non-API requests to
  Torn, no scraping pages not being viewed, and no extracting data from
  unfocused pages to send elsewhere, alert on, or draw attention to a window.
  Alerts driven by Torn API data are fine.

Not from `torn-city` (it doesn't cover Torn's API Terms of Service yet):
**API keys belong to the user who entered them.** Torn expects services that
take keys to disclose the access level needed, what is stored, and who can
see it (as summarized in FF Scouter's API key guide; see
`developer-terms.md`). Never send a key anywhere the user didn't agree to.

## FF Scouter's own terms

FF Scouter has developer terms of its own: no key sharing, no showing
premium data to non-premium users, no reselling data, attribution, and a
link to the data policy wherever a key is entered. Read
`developer-terms.md` before building anything that calls the API or stores
keys.

## Routing

- **Developer terms, key registration and required Torn key access, data
  policy links, commissions** → `developer-terms.md`
- **Calling the API** — auth, rate limits, batching/caching, errors, and
  detail on Player Stats, Targets, Flights, and Bounty Board; index of the
  other tags → `api.md`
- **What FF / BSS / bs_estimate mean and how far to trust them** →
  `concepts.md`
- **What the website and the FF Scouter V2 userscript do**, and coexisting
  with the userscript on Torn pages → `functionality.md`

## Snapshots and spec drift

Dated copies of the spec (`spec.yaml`, plus a derived `spec.json` for `jq`),
the API guidance, changelog, and key guides live in the `xentac/skills` repo
under `snapshots/torn-ffscouter/`. Look files up through `index.tsv` there,
which gives each file's `stored_in` directory, `last_checked` date, and
`version`:

1. **Local:** `../../snapshots/torn-ffscouter/index.tsv` relative to this
   skill's base directory (repo checkouts and Claude Code plugin installs),
   then `../../snapshots/torn-ffscouter/<stored_in>/<file>`.
2. **GitHub** (`npx skills add` installs):
   `https://raw.githubusercontent.com/xentac/skills/main/snapshots/torn-ffscouter/index.tsv`,
   then the same base URL with `/<stored_in>/<file>`.

Query the spec with `jq`, e.g. `jq '.paths | keys' spec.json` or
`jq '.paths["/api/v1/get-stats"]' spec.json`, rather than reading it whole.

**When writing or debugging code against the API** (not for conceptual
questions), check for drift first:
`curl -s https://ffscouter.com/openapi/spec.yaml | grep -m1 '^  version:'`.
If it differs from the `version` of `spec.json` in `index.tsv`, read
`https://ffscouter.com/api-docs/changelog` for entries since the snapshot
before trusting it, and prefer the live spec. Have the tool you're building
record the spec version it targets (a constant or test fixture), as FF
Scouter's guidance asks.
