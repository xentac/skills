# Fair Fight and FF Scouter's estimates

From FF Scouter's "Fair Fight Explained" guide and FAQ (snapshots
`guide-fair-fight-explained.txt`, `faq.txt`, 2026-10-12). For Torn's own
battle mechanics, see the `torn-city` skill's `game-mechanics.md`.

## Battle Stat Score (BSS)

Torn reduces the four battle stats to one number:

```text
BSS = round(√strength + √defense + √dexterity + √speed)
```

Because of the square roots, one stat far above the others is only partly
reflected, and there's no exact way back from BSS to a total stat sum.

## Fair Fight (FF)

FF is a multiplier on respect and war score that rewards attacking
someone close to your own strength:

```text
FF = 1 + (8/3) × (BSS_defender / BSS_attacker)
```

- Equal BSS gives FF ≈ 3.67. A much weaker defender gives FF close to 1,
  and FF is never below 1.
- **Torn displays and logs FF capped at 3.00.** FF Scouter's *calculated*
  FF is not capped and can go well above 3.
- **FF is always relative to the attacker.** The same target has a
  different FF for every viewer, which is why the API's `fair_fight` is
  per key owner (see `api.md`).

FF Scouter's difficulty labels (Target Finder etc.): **≤ 2 easy**, **≤ 3.5
moderately difficult**, **≤ 4.5 difficult**, **> 4.5 may be impossible**.
For ranked wars, factions usually want hits at FF ≥ 2.

## How the estimates are made

Rearranging the formula recovers a defender's BSS from a logged hit:

```text
BSS_defender = (3/8) × (FF − 1) × BSS_attacker
```

Registered users' keys give FF Scouter their own stats (kept private as
`bss_private`) and their attack logs. Each qualifying attack yields an
estimate of the opponent's BSS, which goes into a shared public pool
(`bss_public`) that anyone can query. A hit qualifies only if the logged FF
is strictly between about 1.05 and 3.00 (exact 1.00/3.00 are skipped), and
the attack is recent, completed cleanly, and wasn't interrupted. **Public
estimates never come from anyone's private stats.**

`bs_estimate` (total battle stats) is a heuristic derived from
`bss_public` — "use it for ballpark comparisons only".

## How far to trust it

- Generally very accurate, but more doubtful for **estimates over ~28 days
  old** (`last_updated`) and **brand-new players**.
- A player's estimate only updates when an FF Scouter user attacks them, or
  they attack an FF Scouter user, under the conditions above. Inactive or
  rarely-hit players go stale.
- **The 3.00 display cap blocks learning** from hits on much weaker or much
  stronger targets. Some top players always log FF 3.00, and the model
  generally breaks down **above ~20 billion total stats**. Premium adds
  other sources (`available_estimates.premium`, `.spies`) for those cases.
- **Stat-imbalanced builds** make BSS a rough proxy for total stats.
- **FF ignores everything except the four battle stats** — equipment,
  education, job/faction perks, drugs, and consumables all affect a real
  fight. Treat FF as a range guide, not a predicted outcome.
- Nobody can opt out: every player, including FF Scouter's developer, is
  visible to lookups and Target Finder.
