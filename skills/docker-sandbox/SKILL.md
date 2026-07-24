---
name: docker-sandbox
description: Detect and adapt to running inside a Docker Sandbox (sbx), with graceful handling of blocked network requests
---

# Docker Sandbox Awareness

## Detecting a Docker Sandbox

You are inside a Docker Sandbox if **any** of these are true:

```bash
echo $IS_SANDBOX        # "1" when inside sbx
echo $SANDBOX_VM_ID     # set to the sandbox name (e.g. "claude-skills")
```

The sandbox name (`$SANDBOX_VM_ID`) is also the hostname and is used in host-side `sbx` commands.

## Handling Blocked Network Requests

Docker Sandboxes use a **deny-by-default network proxy**. Blocked HTTP/HTTPS requests return **HTTP 403** — not a connection error — with a structured body:

```
Blocked by network policy: domain <host>
  rule:   "<rule-name>" (domain, deny)
  origin: <origin>
  detail: <explanation>
```

### When a request is blocked

1. **Read the 403 response body** — it tells you exactly why and whether it's fixable.
2. **Check the `origin` field** to determine what to do next:

| `origin` | `detail` | Action |
|---|---|---|
| *(any)* | `no matching allow rule — blocked by default deny policy` | Domain just isn't on the allowlist yet — user can add it |
| `local policy` | explicit deny rule name present | User can override it |
| `corporate policy` or `system policy` | — | **Cannot be overridden** — tell user their org/system policy blocks this domain; they should contact IT |

3. **If the block is overridable**, pause and ask the user:

> I'm running inside a Docker Sandbox (`$SANDBOX_VM_ID`) and the request to `<domain>` was blocked by the network policy.
>
> To allow it, run this on your host:
> ```bash
> sbx policy allow network <domain>
> ```
> Or to allow all traffic not on the denylist:
> ```bash
> sbx policy allow network "**"
> ```
> Let me know when done and I'll retry.

4. **After the user confirms**, retry the request.

### Inspecting network policy from inside the sandbox

```bash
sbx policy log   # recent connections: host, rule, reason, last-seen
sbx policy ls    # active rules and their status
```

> **Important**: `sbx policy allow` must be run on the **host**, not inside the sandbox. You cannot modify network policy from within the sandbox.

## What Runs Where

| Task | Where |
|---|---|
| Agent code, file edits, shell commands | Inside the sandbox |
| `sbx policy allow network <domain>` | Host terminal |
| `sbx ports <name> --publish <port>` | Host terminal |
| `sbx exec -it <name> bash` | Host terminal |

## Environment Facts

- **Workspace path** is identical inside and outside the sandbox (direct mode default).
- **Packages installed** inside (apt, npm, pip, etc.) persist across sandbox stops/restarts, but are lost on `sbx rm`.
- **`/etc/sandbox-persistent.sh`** is sourced before every bash command — append `export VAR=val` here for persistent env vars.
- **Git credentials** are injected transparently by the proxy; `gh auth status` will show "not logged in" even when pushes work.
- **Services** must bind to `0.0.0.0` (not `127.0.0.1`) to be reachable via host port publishing.
- **Docker** is available inside the sandbox with its own isolated daemon.

## Services Bound to the Host

To reach a service on the host machine (not inside the sandbox), use `host.docker.internal` instead of `localhost`:

```bash
curl http://host.docker.internal:3000
```

To expose a sandbox port to the host, the user runs on their host:

```bash
sbx ports $SANDBOX_VM_ID --publish 8080:8080/tcp
```
