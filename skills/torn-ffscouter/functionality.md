# What FF Scouter does: website and userscript

> Maintained by the author of the FF Scouter V2 userscript (xentac): the
> userscript section is first-hand and checked against its source; the
> website section comes from ffscouter.com as of 2026-10-12.

## Website (ffscouter.com)

Free for everyone, with no key needed to browse:

- **Player Viewer / Compare Players** — a player's estimates and history,
  or several players side by side.
- **Target Finder** — candidates filtered by level, FF range, inactivity,
  faction status, and presets for respect or leveling. The same search is
  `get-targets` in the API.
- **Factions** — Faction Profile, Compare Factions, Active Ranked Wars,
  War Room.
- **Leaderboards** — battle-stat estimates, faction rankings, top activity.
- **Marketplaces** — Buy/Sell Losses and Place/Claim Bounties (the Bounty
  Board), paid in Xanax.
- **Calculators** — investment ROI and PI mortgages.
- **Guides** — Fair Fight, battle stats, wars and chaining, API keys and
  account safety, loss selling, the Bounty Board, and more.

**Premium** (per player, or via faction premium) adds the flight tracker,
the activity tracker, stat distribution breakdowns, extra estimate sources
for high-stat players, faction tools such as hit calling, and the premium
API endpoints.

**Volunteer** — users can contribute to FF Scouter's separate data
gathering. That service isn't covered by the main data policy.

## FF Scouter V2 userscript

Source: `github.com/xentac/ffscouter` (TypeScript, built with Vite).
Released builds are on branch `release-standard`, file `base.user.js`
(beta: `release-beta`, `beta.user.js`), synced to Greasy Fork. Its metadata
header is tracked as snapshot `ff-scouter-v2.meta.js` (v3.3 as of
2026-10-12). It runs in Tampermonkey/Violentmonkey and inside Torn PDA, on
`https://www.torn.com/*`, calling only `ffscouter.com`.

Settings live in a panel on **the user's own profile page**, above Medals.
That's also where the API key is entered and premium status is shown.

What it adds, by page (one feature module each under `src/features/`):

| Page | What it shows |
| --- | --- |
| Profiles | FF/estimate info line and gauge marker; flight estimate if the player is flying (premium); link to the player's ffscouter.com history |
| Mini profiles (hover cards) | FF data; flight estimate (premium) |
| Faction member lists and ranked war lists | FF/Est column, sort and filter box (level, FF, stats, and last-action range when TWSE is present) |
| Attack page | FF at top left |
| Item market, Russian Roulette | FF next to players |
| Online-status icons | Turned into quick-attack links |
| Any page | FF target finder button (uses `get-targets`); fallback observer that applies FF wherever player links appear |

How it uses the API: it batches `get-stats` (up to 200 IDs per call),
caches estimates for one hour in IndexedDB, and calls `check-key`,
`player-flights`, and `get-targets`. It sends the user's key as the `key`
query parameter.

### Coexisting with it

If you're writing another Torn userscript, assume many users also run FF
Scouter V2 (and often TornTools and TWSE):

- **Don't duplicate its FF badges.** Detect its markers and step aside or
  integrate. Its DOM hooks include:
  - `.ffscouter-gauge` and `.ffscouter-marker-wrapper` (gauge markers);
  - `.ffscouter-header` (FF column header in faction and war lists);
  - `ff-settings-panel` and `ff-header-line` (profile elements);
  - `data-ffscouter-active-filter` (set while it is sorting a list by FF).
- **It reorders faction and war rows** when sorting by FF, and re-sorts
  whenever Torn mutates the list. Don't fight it with your own row order.
  TornTools' extra rows (`.tt-last-action`, `.tt-stats-estimate`) are moved
  together with their player row.
- **Both scripts share the user's FF Scouter rate limit** when they use the
  same key. Batch your own calls rather than adding a request per row.
- **Torn's CSS-module class hashes** (`sortIcon___*`, etc.) change between
  Torn releases. Match on prefixes, never on full hashed names.
- Its repo's `CONTEXT.md` is a detailed glossary of Torn's page structure
  (war box, white-grad headers, the Torn clock via
  `window.getCurrentTimestamp()`). It's useful reference for any Torn
  userscript.
