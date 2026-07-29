# Torn rules (`torn.com/rules.php`) — as of 2026-07-29

Source: pasted directly by the user from the live site (2026-07-29). Could not fetch this
directly — `torn.com/rules.php` is Cloudflare-gated for both live `curl` and every Wayback
snapshot from 2024-11 through the most recent memento checked (2026-04-08); only the
2025-09-15 memento (saved at `../2025-09-15/rules.html`) rendered real content instead of
the challenge page. Treat this file as the most current known text until a fresher primary
source is fetched.

## TORN'S GAME OFFENSES AND PUNISHMENTS

**REAL MONEY TRADING: DELETION**
The exchange of currency or assets on Torn for real-world money or services (including assets
from other games) is strictly prohibited. Real money trading directly affects Torn's economy
and donation levels, while exposing our users to fraudulent activities. Staff proactively seek
out buyers and sellers both on-site and externally, and no warnings are given for the first
offense. Buyers will have their purchased goods removed and be subject to a lengthy game ban,
whereas sellers will be banned permanently without recourse.

**ACCOUNT TRADING: DELETION**
To protect the integrity and fairness of Torn all players must build their own accounts up
from registration. Whoever first registered an account is deemed its true owner, meaning the
original registrant can still use the Account Recovery system to forcefully gain control again,
even after selling the account or giving it away to someone else. Torn staff constantly hunt
for account sellers and monitor websites outside of Torn. Tracing illegally sold / given away
accounts is simple, and any accounts involved will be terminated on the first offense without
warning.

**BUG / EXPLOIT ABUSE: Game ban**
Although every aspect of Torn is tested strenuously before release, unintentional exploits are
sometimes possible. Every action and gain in Torn is logged with timestamps often going back
years in the past, so exploiting a bug / glitch / hack is impossible to get away with. If you
find an abusable exploit, do not share it with others. Report it to the developers immediately,
it may even be eligible for Torn's bug bounty program. Continuing to abuse an exploit without
reporting it will result in account deletion.

**MULTIPLE ACCOUNTS: Game ban**
Users are permitted to own only one Torn account and should never register a duplicate for any
reason whatsoever. Using more than one account can give someone an unfair advantage, so Torn
staff aggressively monitor suspected abuse using a huge array of tools developed over the last
decade. A first-time multiple account offense will result in a game ban or deletion depending
on the severity, with all illegal gains being removed.

**ACCOUNT SHARING: Game ban**
All accounts must be operated exclusively by the original account creator. Sharing your login
details with anyone else or having someone initiate processes on your behalf is strictly
prohibited and can put your account at risk. Staff have a decade of experience in this field
and can easily spot the signs of account sharing. All benefits gained from sharing any account
will be removed and bans start at 7 days, but can vary depending on the severity.

**ABETTING: Game ban**
Knowingly aiding and abetting rule violators within the game. This includes, but is not limited
to, transferring assets between multiple accounts in an attempt to hide illicit gains
(Middlemanning), willingly and knowingly covering up or hiding known serious rule violations
committed by others, or deliberately performing actions that assist others in ongoing rule
violations.

**SCRIPTING ABUSE: Game ban** — *the load-bearing rule for anything this skill helps build*
The use of scripts, extensions, applications, or any other software is permitted only when they
rely on data from our API or from a page that you have manually loaded and are actively
viewing. Such software must not make additional non-API requests to Torn, scrape pages that are
not currently being viewed, attempt to bypass CAPTCHA protections, or extract data from
unfocused pages to send elsewhere, generate alerts, or draw attention to itself or another
window. Any software that makes non-API requests which are not directly and manually initiated
by the user is prohibited and may be tracked. Furthermore, releasing software with malicious or
undisclosed functionality is strictly forbidden, and developers of API-based tools are required
to comply with the acceptable usage terms outlined here.

**SOCIAL VIOLATIONS: Area ban**
This list of social guidelines covers all of our rules for all user-created content (typed,
shared or uploaded) across the entirety of Torn. This includes the forums, private messages,
chat, discord, profiles, events, signatures, newspaper adverts and player names. When an offense
occurs, the offending content (if publicly viewable) will be edited or removed. A verbal
warning, official warning, or ban of the area the content was published in will be issued.
Extreme offenses can result in instant account deletion.

- *Discrimination* — hate speech and derogatory words/slurs re: ethnic origin, religion, gender
  identity, sexual orientation, disability, misogyny, or misandry; support of real-world
  terrorism or Nazism.
- *Harassment* — causing distress using personal info or likeness of a player/family/friends;
  real-world threats; repeated cyberbullying the victim can't avoid via block/ignore.
- *Extreme Flaming* — unfiltered offensive profanity or severe slanderous name-calling with
  real-world connotations.
- *Obscene Content* — pornographic, sexually explicit, or graphically violent material
  unsuitable for minors; bypassing filters with offensive language.
- *Compromising Security* — asking for login info, phishing, scraping private information, or
  giving away your own account details.
- *Ignoring Staff Warnings* — disregarding a staff request/warning even outside the specific
  guidelines above.
- *Impersonation* — pretending to be another person or an authority figure.
- *Enticement* — encouraging someone else to break rules, or using someone else to bypass your
  own restrictions.
- *Flooding / Spamming* — duplicated, irrelevant, or illegible spam across forums, chat, mail,
  or events.
- *Advertising* — promoting non-Torn content/products/services outside the appropriate area;
  buying/selling forum karma.
- *Language* — public content in the forums or chat in any language other than English.

## Known diff vs. 2025-09-15 archived snapshot (`../2025-09-15/rules.html`)

The SCRIPTING ABUSE rule has been tightened since Sept 2025. The archived version only banned:
> "additional non-API requests to Torn, scrape pages that you're not currently viewing, or
> attempt to bypass the captcha"

The current (2026-07-29) version adds an explicit ban on tools that:
> "extract data from unfocused pages to send elsewhere, generate alerts, or draw attention to
> itself or another window"

This closes the loophole of a background tab silently scraping and alerting — e.g. a
"war/attack notifier" extension that watches an unfocused page and pops an alert. That pattern,
which may have been borderline before, now reads as a clear rule violation. Any skill guidance
about building notifier/monitor tools needs to reflect this.
