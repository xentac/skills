# Torn page layout measurements — 2026-09-28

Console measurements of torn.com's page layout at six window widths, taken to have a durable
record for diffing if Torn changes its responsive breakpoints.

## Files

| File | Source | Fetched via |
|---|---|---|
| `page-layout-measurements.json` | `https://www.torn.com/factions.php` (logged in, Chrome, dark mode) | Read-only console snippets run by the user on a page they had loaded and were viewing; output pasted back by hand |

The file is an array of six results in the order they were taken. Each has a `snippet` field
added here to say which snippet produced it; every other field is as pasted.

- `breakpoint-census` (one run, 1536px): counts style rules inside each width media query
  across the page's readable stylesheets, and walks the largest-child chain down from `body`.
- `layout` (five runs, 920 / 767 / 613 / 459 / 454px): measures `#mainContainer` and its
  children and reports which of the four main breakpoints match. This snippet is reproduced
  in `skills/torn-city/page-layout.md`.

## Access notes (for future measurements)

- **No browser automation was used, and none may be.** Agent-driven browsing of torn.com is
  prohibited by Torn's Scripting Abuse rule — see `skills/torn-city/rules-and-compliance.md`.
  The snippets only read the DOM and CSSOM of the current page and make no requests.
- One stylesheet was unreadable from the console (cross-origin): the Google Fonts `Inter`
  sheet. It holds font faces, so the breakpoint counts are not affected.
- Nothing narrower than 454px was measured, so the `max-width: 386px` breakpoint's effect on
  layout is unverified.

## Diffs already observed between snapshots

None — this is the first layout snapshot.
