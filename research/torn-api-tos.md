# Torn API Terms of Service for tools that take keys

Question (issue #3): what do Torn's API Terms of Service (ToS) require from a tool that takes a user's API key? This note covers disclosure, key storage, access levels, data sharing and retention, and automated or AI agent use. It applies the rules to the two planned MCP servers (map issue #1).

An MCP server is a local program that an AI client (for example Claude Code) starts. The client calls the server's tools, and the server calls the API.

## Sources

| Source | URL | Fetched | Method | Notes |
| --- | --- | --- | --- | --- |
| Torn API docs (v1 page, holds the ToS) | https://www.torn.com/api.html | 2026-10-21 | plain `curl` | `Last-Modified: Tue, 14 Jul 2026 13:11:56 GMT`. Text is the same as the repo snapshot `snapshots/torn-city/2026-07-29/api-v1-docs.html`. Only the Cloudflare beacon script differs. |
| API docs script (Custom Key Builder) | https://www.torn.com/api.js | 2026-10-21 | plain `curl` | `Last-Modified: Wed, 06 Aug 2025 09:56:07 GMT` |
| v2 OpenAPI spec | `snapshots/torn-city/2026-10-12/api-v2-openapi.json` (from https://www.torn.com/swagger/openapi.json) | 2026-10-12 | repo snapshot, queried with `jq` | spec version 6.13.8 |
| Official wiki API page | `snapshots/torn-city/2026-07-29/wiki-api-page.html` (from https://wiki.torn.com/wiki/API) | Wayback capture 20251129053008 | repo snapshot | Page last edited 28 August 2025. It has no ToS section. |
| api.html history | https://web.archive.org/web/timemap/link/https://www.torn.com/api.html | 2026-10-21 | `curl` of Wayback `id_` captures | Used to date the ToS section |
| FF Scouter key guide (secondary) | `snapshots/torn-ffscouter/2026-10-12/guide-api-keys.txt` | 2026-10-12 | repo snapshot | Community summary. Not official. |

Not fetched:

- **The key-creation page** (`https://www.torn.com/preferences.php#tab=api`). It needs a login and is behind Cloudflare. An agent must not load it (Scripting Abuse rule). If Torn shows any ToS text or acknowledgement when a user creates a key, a human must copy it by hand. To do that, open Settings, then API Keys, then start a new key, and copy every line of text on that form.
- **Forum announcements about the ToS.** Web search found none. The forums at `www.torn.com/forums.php` are a JavaScript app behind Cloudflare, so `curl` cannot read them. If an announcement thread exists, a human must find it and paste the text. This note does not claim that an announcement exists.

## When the ToS appeared

The ToS section is not in any Wayback capture of api.html up to 2025-04-08. It first appears in the 2025-05-16 capture. So Torn added it between those dates. (Unconfirmed: the exact date.)

Changes since the first version (2025-05-16 capture compared with today):

- The Purpose of Use options changed. "Optimization/Maintenance" and "Analysis" became "Non malicious statistical analysis". "Competitive advantage" and "Personal gain" now need "[Please specify]". "Other [Please specify]" was added.
- The disclosure rule gained the words "in the table format highlighted above". The first version only said the information must be clearly and visibly stated.

## What the ToS says

All quotes are from api.html as fetched on 2026-10-21.

### Scope

> When creating a script, userscript, sheet, extension, API service, bot, 3rd party website or any other API tool (collectively "service"), the end user must be aware of how will their API key be used.

An MCP server is "any other API tool". The ToS applies to it.

### The disclosure table

The ToS defines five columns. Each column has a question and a list of suggested answers.

| Column | Question | Suggested answers |
| --- | --- | --- |
| Data Storage | Will the data be stored for any purpose? | No / Only locally. Temporary - less than a minute. Temporary - less than a day. Persistent - until account deletion. Persistent - forever. |
| Data Sharing | Who can access the data besides the end user? | Nobody. Faction. Friends & faction. General public. Service owners. Service owners & their customers. |
| Purpose of Use | What is the stored data being used for? | Non malicious statistical analysis. Public amusement. Public community tools. Competitive advantage [Please specify]. Personal gain [Please specify]. Other [Please specify]. |
| Key Storage & Sharing | Will the API key be stored securely and who can access it? | Not stored / Not shared. Stored / Used only for automation. Stored / Shared with the faction. Stored / Shared with other services. |
| Key Access Level | What key access level or specific selections are required? | Public. Minimal. Limited. Full. Custom - specify selections. |

The examples at the bottom of the page also use free text. Two examples are "Stored locally / Not shared" and "Not eligible - only end user has access". So the lists are a guide, not a closed set.

### Where and when to disclose

> If the service is not storing or sharing the data or the key anywhere, it's enough to state so, otherwise ToS with the information above needs to be clearly and visibly stated in any place where user is providing their API key in the table format highlighted above.

Examples 1 and 3 on the page cover tools that keep everything in the user's browser. For them, "ToS in the table format is not necessary, but might be useful to end users".

### Integrations with other services

> When integrating your service with another service (opt-in), make sure there's at least a link to ToS of the service you're allowing the user to integrate with.

> When integrating your service with another service (automatically), your ToS need to cover the usage of the service you're integrating with.

### Misuse

> Using keys for purposes other than the ones described in the ToS or deceiving the end user into believing that the key is being used for a purpose other than described is prohibited and is a punishable offense.

> These rules also apply to those who purchase API keys from other players.

> If you're unsure how to describe your service, feel free to contact Torn staff.

> All services must be compliant with Torn's scripting rules.

### Acceptable usage (the section above the ToS)

- Ask only for the API key. Never ask for a name, a user ID or a password. "Torn passwords should never be requested from any users, ever."
- "You must keep keys, and the data obtained from them, securely protected and confidential unless permitted by the key owner." Torn will "permanently ban offending applications from accessing the API at a moment's notice."
- Follow the no-advertising policy. Contact Torn before you advertise, accept donations or charge users.
- Request only the data that you need.
- "Multiple requests using invalid keys may result in a temporary IP ban - you must account for this by removing disabled or invalid keys upon error."
- Torn logs "all details and inputs of requests".
- The limit is 100 requests per minute per user, across all keys.

### Access levels and custom keys

The v2 spec gives each endpoint a minimum key level. Counts of GET endpoints in spec 6.13.8:

| Minimum level | Endpoints |
| --- | --- |
| Public | 168 |
| Minimal | 36 |
| Limited | 29 |
| Full | 1 (`/user/log`) |

Limited covers private data such as battle stats, money, events, messages, attacks, stocks and faction balance. Full adds only the log.

From the Custom Key Builder section of api.html:

> Custom keys should be treated as if they are full-access keys.

> By default, custom keys can access only the default selection, timestamp and lookup selection.

The Custom Key Builder makes a link that opens the key-creation form with fields filled in. The format, from `api.js`:

```
https://www.torn.com/preferences.php#tab=api?step=addNewKey&title=<name>&user=<sel,sel>&faction=<sel,sel>&logIds=<id,id>
```

Other categories (`company`, `property`, `market`, `torn`, `racing`, `forum`) work the same way as `user` and `faction`. The `title` allows only letters, digits, space, `_`, `/` and `-`. A tool can give the user this link to create a key with exactly the selections it needs. (Unconfirmed: whether a preset level can be set by a link parameter. The builder script does not show one.)

### Tools for audit, from the v2 spec

- `GET /key/info` works with any key. It returns the key's access `type` and a numeric `level`. The type is one of `Custom`, `Public Only`, `Minimal Access`, `Limited Access` or `Full Access`. It also returns the allowed selections per category, and faction and company flags.
- `GET /key/log` works with any key. It returns up to the last 250 requests made with the key. If a user suspects misuse, api.html tells them to check this log.
- The `comment` query parameter is "Comment for your tool/service/bot/website to be visible in the logs." The docs page itself uses `comment=TryItPage`.
- Header authentication: the spec's security scheme is `Authorization: ApiKey <key>`. Each `key` query parameter has this note: "It's not required to use this parameter when passing the API key via the Authorization header." (Unconfirmed: not tested live. Unconfirmed for v1 endpoints.) This contradicts the line "no header-based auth" in `skills/torn-city/api.md`.

## Automated and AI agent use

The ToS says nothing about AI agents, LLMs or MCP servers. Neither does the wiki page. A web search found no Torn staff statement either. (Searched 2026-10-21.)

What does apply:

- The Scripting Abuse rule allows software that uses only API data. Scheduled or unattended API calls are fine. See `skills/torn-city/rules-and-compliance.md`. A server that calls only `api.torn.com` meets this rule.
- The ToS rules above apply in full. An AI client is just the place where the user gives the key to the tool.

Other people already publish Torn MCP servers. Two were found on glama.ai, one remote (key sent in a header) and one local (key in `TORN_API_KEY`). Their existence does not show that Torn approves of them.

## Open questions (gray areas)

### 1. Is the user's model provider a "Data Sharing" party?

Every API response that a tool returns goes into the agent's conversation. The AI client sends that conversation to the user's model provider (for example Anthropic). The provider's own terms then govern that data. The client can also save transcripts on disk.

The ToS categories do not fit this well. It is not "Nobody", and it is not "Service owners". The server does not choose the provider. The user's client does.

Two readings:

- **Reading A.** The server stores and shares nothing. The user chose their AI client, so the client is the user's own tool. The server can say "Not stored / Not shared" and stop.
- **Reading B.** The model provider is another service that receives the data. The server only works inside an AI client, so the integration is automatic, not opt-in. The ToS then says "your ToS need to cover the usage of the service you're integrating with". The disclosure should name this and point to the provider's terms.

This note recommends Reading B for the disclosure text, because it costs little and it is honest about where the data goes. Status: **unconfirmed**. Ask Torn staff for a ruling (the route that `rules-and-compliance.md` gives for gray areas).

### 2. The key must never reach the transcript

This is a separate risk. If a tool result, an error message or an echoed request URL contains the key, the key itself goes to the model provider. Then "Not shared" for the key is false. Requirements for the key-configuration design:

- If live tests show that header auth works, send the key in the `Authorization` header, not in the URL.
- Never put the key in tool results, error text or logs. Redact it from any URL or error before the server returns it.

### 3. The FF Scouter server is an automatic integration

The FF Scouter key is the same Torn key. The server sends it to `ffscouter.com`. FF Scouter's data policy says it stores the key until account deletion and the service owners can access it for debugging (see `skills/torn-ffscouter/developer-terms.md`). Under the integration rule, the FF Scouter server's disclosure must cover this. It must also link FF Scouter's data policy, which FF Scouter's own guidance requires.

Suggestion: tell users to create one named key for each server. Then each key's log shows only that server's requests.

## Draft disclosure tables

These are drafts for the spec. Cells marked (gray) depend on open question 1.

### Torn API MCP server

| Data Storage | Data Sharing | Purpose of Use | Key Storage & Sharing | Key Access Level |
| --- | --- | --- | --- | --- |
| No / Only locally. The server keeps no data. Your AI client can keep transcripts. (gray) | Nobody, except your AI model provider, under its own terms. (gray) | Other [answers your own questions in your AI client] | Stored locally in your configuration / Not shared. Sent only to api.torn.com. | Any level works. Tools that need more access tell you so. Recommended: Limited, or a Custom key from the link we give. Full is needed only for logs. |

### FF Scouter MCP server

| Data Storage | Data Sharing | Purpose of Use | Key Storage & Sharing | Key Access Level |
| --- | --- | --- | --- | --- |
| No / Only locally. The server keeps no data. Your AI client can keep transcripts. (gray) | Nobody, except your AI model provider, under its own terms. (gray) | Other [answers your own questions in your AI client] | Stored locally in your configuration / Shared with FF Scouter, which stores it. See https://ffscouter.com/#data-policy | The key must be registered with FF Scouter. FF Scouter accepts Limited, Full, or a Custom key with its listed selections. |

Where to show them: "any place where user is providing their API key". For these servers that means the README install steps and the key-configuration docs. A server can also show the table in its startup message or in a setup tool. (Unconfirmed: whether README placement is enough. Ask staff with question 1.)

## What this means for the servers (summary)

- **Disclose** the table where the user configures the key. Include the model-provider line until staff rule on it.
- **Store** the key only in the user's own configuration. Send it only to the API that needs it. Keep it out of URLs, tool results, errors and logs.
- **Retain** no API data in the server (matches the map's no-cache decision).
- **Access level:** do not demand one tier. Call `/key/info` at startup to learn the tier. When a tool needs more access, report error 16 clearly. Offer a Custom key link built from the tools' selections.
- **Audit:** send a `comment` with every request, for example the server name, so the user can find the server's calls in `key -> log`.
- **Invalid keys:** stop using a key after an invalid-key error, to avoid an IP ban.
- **Do not** advertise or charge without contacting Torn.
