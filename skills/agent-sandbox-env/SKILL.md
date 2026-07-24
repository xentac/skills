---
name: agent-sandbox-env
description: Detect and adapt to running inside a Docker Sandbox (sbx), including blocked network requests and GitHub token refresh
---

# Agent Sandbox Environment

## Detecting You Are in a Sandbox

You are inside a Docker Sandbox if **any** of these are true:

```bash
echo $IS_SANDBOX        # "1" when inside sbx
echo $SANDBOX_VM_ID     # set to the sandbox name (e.g. "claude-skills")
```

The sandbox name (`$SANDBOX_VM_ID`) is also the hostname and is referenced in all host-side `sbx` commands.

## Handling Blocked Network Requests

Docker Sandboxes route all HTTP/HTTPS through a **deny-by-default proxy**. Blocked requests return **HTTP 403** — not a connection error — with a structured body:

```
Blocked by network policy: domain <host>
  rule:   "<rule-name>" (domain, deny)
  origin: <origin>
  detail: <explanation>
```

### When a request returns 403

1. **Read the response body** — it tells you exactly why and whether the user can fix it.
2. **Check the `origin` field:**

| `origin` | `detail` | Action |
|---|---|---|
| *(any)* | `no matching allow rule — blocked by default deny policy` | Not on the allowlist — user can add it |
| `local policy` | explicit deny rule name | User can override it |
| `corporate policy` or `system policy` | — | **Cannot be overridden** — tell the user their org/system policy is blocking this; they should contact IT |

3. **If the block is overridable**, stop and tell the user:

> I'm running inside a Docker Sandbox (`$SANDBOX_VM_ID`) and my request to `<domain>` was blocked by the network policy. To allow it, run this on your **host**:
> ```bash
> sbx policy allow network <domain>
> ```
> Or to allow all traffic not on the explicit denylist:
> ```bash
> sbx policy allow network "**"
> ```
> Let me know once you've run it and I'll retry.

4. **After the user confirms**, retry the request.

### Inspecting network policy (run inside the sandbox)

```bash
sbx policy log   # recent connections: host, rule, reason, last-seen
sbx policy ls    # active rules and their status
```

> **`sbx policy allow` must be run on the host.** You cannot modify network policy from inside the sandbox.

## Handling GitHub Authentication Failures

The sandbox proxy transparently injects GitHub credentials on outbound Git requests — `gh auth status` will always show "not logged in" inside the sandbox even when things work. This is expected and normal.

However, the injected token can **expire**. When it does, `git push` fails with:

```
fatal: could not read Username for 'https://github.com'
```

### Fixing an expired GitHub token

Tell the user to run on their **host**:

```bash
# For this sandbox only (takes effect immediately):
gh auth token | sbx secret set $SANDBOX_VM_ID github -t -

# Or globally for all future sandboxes:
gh auth token | sbx secret set -g github -t -
```

> Do not ask the user to push from their local terminal — Git push should work from inside the sandbox once the token is refreshed.

## What Runs Where

| Task | Where |
|---|---|
| Agent code, file edits, shell commands | Inside the sandbox |
| `sbx policy allow network <domain>` | Host terminal |
| `sbx secret set <name> github -t "..."` | Host terminal |
| `sbx ports <name> --publish <port>` | Host terminal |
| `sbx exec -it <name> bash` | Host terminal |

## Environment Facts

- **Workspace path** is identical inside and outside the sandbox (direct mode default).
- **Installed packages** (apt, npm, pip, etc.) persist across sandbox stops and restarts, but are lost on `sbx rm`.
- **`/etc/sandbox-persistent.sh`** is sourced before every bash command — append `export VAR=val` here for env vars that must persist across shell invocations.
- **Services** must bind to `0.0.0.0` (not `127.0.0.1`) to be reachable via port publishing.
- **Docker** is available inside the sandbox with its own isolated daemon and image cache.

## Reaching the Host

To reach a service on the host machine (not inside the sandbox), use `host.docker.internal` instead of `localhost`:

```bash
curl http://host.docker.internal:3000
```

To expose a sandbox port to the host, the user runs on their host:

```bash
sbx ports $SANDBOX_VM_ID --publish 8080:8080/tcp
```
