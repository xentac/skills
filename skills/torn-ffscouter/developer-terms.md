# FF Scouter developer terms and keys

Sources: FF Scouter's API guidance page (`/api-docs/guidance`, snapshot
`guidance.txt`), the spec's `info.description`, the `/api/v1/register` and
`/api/v1/check-key` operations, and the FAQ — all as of 2026-10-12. These
are FF Scouter's rules and sit **on top of** Torn's (see `SKILL.md`).

## What the guidance prohibits

Stated by FF Scouter, in their words where possible:

- **Selling or showing premium data to users who do not have an active
  premium subscription.**
- **Reselling free data.** You may build a tool, sell access to it, and use
  FF Scouter's free data in it, but "the data must not be the sole product".
- **Using a single API key to provide multiple users with data (key
  sharing).** "If premium data is used, you MUST use the API key of the user,
  not a shared one." The spec adds: "Do not use your own API key to share
  information to others, you must always prompt the user to provide their
  own API key".
- **Deliberately maxing out rate limits over time.** Limits are policed
  liberally, but long-term trends are monitored and "significant abuse of
  it will lead to restrictions".

**Questionable implementations** — anything where it's unclear whether a
design counts as key sharing, showing premium data to non-premium users, or
reselling (shared caches across users, bot replies visible to a whole
channel, faction-wide dashboards built from one member's key) — should be
raised with the FF Scouter team in their Discord
(`https://discord.gg/Gzr7Rb3Y5f`) before building. Flag these to the user
rather than deciding either way; record any answer, with its date, here.

## What the guidance asks for

- **Attribution:** tell users FF Scouter is the source of the data.
- **Users' own keys:** wherever possible, ask the user to sign up to FF
  Scouter and use their own key. Encourage premium.
- **Data policy link wherever a user enters a key** — even if you reproduce
  the policy in your tool. The policy changes, so have the user acknowledge
  they've checked the current version on the site, or make that an obvious
  condition of use.
  - Main data policy: `https://ffscouter.com/#data-policy` (the "Data
    Policy" panel on the home page).
  - Bounty Board data policy and rules: `https://ffscouter.com/claim-bounties`.
    Sellers must accept it via `POST /api/v1/bounties/seller/policy/accept`
    (error 86 until they do), and again after a policy version change.
- **Batch and cache:** use batch endpoints rather than one player per
  request (`get-stats` takes up to 205 IDs), and cache estimates for about
  an hour — "lower caches than this are unlikely to bring any benefit". See
  `api.md` for why a cache shared across users needs care.
- **Record the spec version** your tool was built against, so later
  changes are easy to flag.

## Keys

**The FF Scouter key is the user's own 16-character Torn API key**,
registered with FF Scouter — not a separate credential. Every
authenticated endpoint takes it as the `key` query parameter. An
unregistered key gets error **6** ("Please sign up at ffscouter.com"), and
each key a user wants to use must be registered separately.

**Torn key access level for registration** (from the `register` 400
description): a **Limited** or **Full** key, or a **Custom** key with
`basic`, `battlestats`, `attacks`, and `hof` (`personalstats` optional).
Public Only and Minimal keys are rejected. The site's data policy panel
lists a longer Custom selection set added since September 2025 (`profile`,
`cooldowns`, `refills`, faction war selections, `personalstats`) and calls
Limited/Full "works, but not recommended"; it says the same functionality
is provided regardless. Point users at the live policy panel for the
current list rather than hard-coding it.

**Registering from your own tool:** `POST /api/v1/register` with
`{"key", "agree_to_data_policy": true, "signup_source": "<YourTool>"}`.
Only send `agree_to_data_policy: true` after the user has actually been
shown the policy link and agreed. Limited to 3 registrations per minute
(and 10 requests per minute per IP); error 8 means the key is already
registered.

**Checking a key:** `GET /api/v1/check-key` returns `is_registered`,
`is_premium`, `premium_expires_at`, `premium_entitlement_source` (e.g.
`personal`; faction premium has its own `faction_premium_expires_at`),
`policy_version`, and `policy_update_required`. Use it to gate
premium features and to prompt for policy re-acceptance. An unknown key
returns 200 with `is_registered: false`, not an error.

**Other secrets:** losses orders return a 14-character **order secret**
(`OrderSecret` in the spec) used to manage that order; bounty orders return
a status **token**. Treat both like passwords — they're the only
authorization for those orders.

**What FF Scouter does with a registered key** is set out in the data
policy panel (as of 2026-10-12: the key is stored until account deletion
and accessible to the service owners for debugging; the key owner's battle
stats feed a private score that isn't shared). Link to it; don't restate it
as your tool's own claim.

**Your tool's own disclosures** are separate. FF Scouter's API key guide
(snapshot `guide-api-keys.txt`) summarizes Torn's expectation that any
service collecting or storing keys or data discloses whether data is stored,
who can see it, why it's used, how the key is stored, and which access level
or selections are needed. The `torn-city` skill doesn't yet cover Torn's API
Terms of Service in detail — check Torn's API docs for the authoritative
wording.

## Commissions

Orders placed through approved scripts can earn a share of FF Scouter's
service fees, paid at most daily and visible on the FF Scouter dashboard.
Bounty and losses order bodies take an optional `referrer_player_id`;
it's ignored unless that player is on FF Scouter's approved list. To be
added, contact Glasnost [1844049] (FF Scouter's owner).
