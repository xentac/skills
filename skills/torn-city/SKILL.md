---
name: torn-city
description:
  Reference for Torn City (torn.com), a text-based browser MMO running
  since 2004 — its API, game mechanics, and rules governing third-party
  tools. Use whenever Torn City, torn.com, or the Torn API is mentioned, or
  when writing/debugging code, scripts, or tools that read Torn data.
---

# Torn City

Torn City is a long-running (since Nov 2004), continuously-evolving browser
MMO. Both its game mechanics and its API change over patches, so treat
specific numbers/behaviors as a snapshot in time, not a permanent fact —
this skill records fetch dates and known drift so guidance can be checked
against how current it actually is. Dated raw copies of primary sources are
readable from any install — see Snapshots below. See `research-methods.md`
for how to re-verify anything here.

## Compliance comes first

**Before proposing or writing any script, extension, bot, or automation
that touches Torn**, read `rules-and-compliance.md`. Torn's Scripting Abuse
rule carries a game ban and was recently tightened to explicitly prohibit
tools that watch unfocused pages and generate alerts —a very common pattern
for "helpful" Torn tools (notifiers, background trackers). Flag this risk
proactively any time a design leans toward background polling, scheduled
non-API requests, or cross-window notifications, rather than waiting to be
asked.

**Never drive torn.com with browser automation yourself** (Claude in
Chrome, Playwright, computer-use, etc.) — an agent loading or reading Torn
pages is itself a Scripting Abuse violation against the user's account.
When something can only be learned from the live site, write a console
snippet for the user to run on a page they've loaded themselves and have
them paste the results back — see the AI agents section of
`rules-and-compliance.md`.

## Routing

- **Writing or debugging code against the Torn API** (auth, rate limits,
  v1/v2, error handling) → `api.md`
- **Fetching wiki.torn.com, rules.php, or other torn.com pages for
  research** (most are Cloudflare-gated) → `research-methods.md`
- **Game mechanics questions** — energy/nerve/happy/life, battle stats,
  gym, attacking, cooldowns, crimes, Organized Crime 2.0, factions, warfare
  (ranked war/raid/territory), jail, hospital → `game-mechanics.md`
- **Userscripts, extensions, or injected CSS that depend on page width**
  — the three fixed layouts (976 / 784 / 386px) and the breakpoints between
  them → `page-layout.md`
- **Torn's rules in general**, not just scripting →
  `rules-and-compliance.md`
- **Third-party tool ecosystem** (what's already out there, described
  neutrally — not tied to any particular developer) → `api.md`

## Snapshots

Dated raw copies of primary sources (API docs incl. the full v2 OpenAPI
spec, rules text, wiki pages, layout measurements) live in the `xentac/skills`
repo under `snapshots/torn-city/<YYYY-MM-DD>/`, each with a `README.md`
giving source, fetch method, and observed diffs. **Check these before
re-fetching from torn.com** — look them up in this order:

1. **Local:** `../../snapshots/torn-city/` relative to this skill's base
   directory. Present in the source repo and in Claude Code plugin installs
   (the plugin cache holds the whole repo).
2. **GitHub:** absent in `npx skills add` installs (only this skill folder
   is copied). The repo is public, so read them remotely:
   - list dates: `curl -s https://api.github.com/repos/xentac/skills/contents/snapshots/torn-city | jq -r '.[].name'`
   - list files: same URL with `/<date>` appended
   - fetch: `curl -s https://raw.githubusercontent.com/xentac/skills/main/snapshots/torn-city/<date>/<file>`
3. **Live source** only if no snapshot covers it or it's too stale for the
   question — see `research-methods.md`.

Use the newest date that has the file you need (not every date has every
file), and note its date when
citing it. `api-v2-openapi.json` is ~1.2MB — query it with `jq` (e.g.
`jq '.paths | keys'`, `jq '.paths["/user/basic"]'`) rather than
reading it whole.

Never put snapshots inside `skills/torn-city/`: the `skills add` CLI copies
skill directories recursively with no size filter, so they'd ship to every
consumer. To add one, see "Snapshotting for change-tracking" in
`research-methods.md`.
