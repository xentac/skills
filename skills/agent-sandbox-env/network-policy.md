# Network Policy

Docker Sandboxes route all HTTP/HTTPS through a **deny-by-default proxy**. Blocked requests return **HTTP 403** — not a connection error — with a structured body:

```
Blocked by network policy: domain <host>
  rule:   "<rule-name>" (domain, deny)
  origin: <origin>
  detail: <explanation>
```

## When a request returns 403

1. **Read the response body** — it tells you exactly why and whether the user can fix it.
2. **Check the `origin` field:**

| `origin` | `detail` | Action |
|---|---|---|
| *(any)* | `no matching allow rule — blocked by default deny policy` | Not on the allowlist — user can add it |
| `local policy` | explicit deny rule name | User can override it |
| `corporate policy` or `system policy` | — | **Cannot be overridden** — tell the user their org/system policy is blocking this; they should contact IT |

3. **If the block is overridable**, stop and tell the user:

> I'm running inside a Docker Sandbox (`$SANDBOX_VM_ID`) and my request to `<domain>` was blocked by the network policy. To allow it for this sandbox only, run on your **host**:
> ```bash
> sbx policy allow network --sandbox $SANDBOX_VM_ID <domain>
> ```
> To allow it across all sandboxes instead:
> ```bash
> sbx policy allow network <domain>
> ```
> Let me know once you've run it and I'll retry.

Default to suggesting the **per-sandbox** form (`--sandbox <name>`). Only suggest the global form if the user explicitly wants it applied everywhere. **Never suggest `sbx policy allow network "**"`** — see warning below.

4. **After the user confirms**, retry the request.

## Subagents: passing blocked requests to the parent

Subagents cannot surface messages to the user directly. When a subagent hits a blocked request, it must signal the parent agent so the parent can pause, ask the user, and re-invoke the subagent after the domain is allowed.

**If you are a subagent** and a request is blocked by an overridable policy, do not fail silently or retry indefinitely. Instead, abort the task and return a response in this form:

```
SANDBOX_NETWORK_BLOCKED
domain: <domain>
sandbox: <value of $SANDBOX_VM_ID>
attempted: <brief description of what you were trying to do>
command: sbx policy allow network --sandbox <$SANDBOX_VM_ID> <domain>
```

**If you are the parent agent** and a subagent returns a `SANDBOX_NETWORK_BLOCKED` response, treat it as a pause — not a failure. Surface the blocked domain and the exact `sbx policy allow` command to the user, wait for confirmation that they've run it, then re-invoke the subagent to continue from where it left off.

## ⚠ WARNING: Never suggest allowing all traffic

```bash
sbx policy allow network "**"   # NEVER suggest this
```

This disables the network sandbox entirely. It allows the agent to reach **any domain on the internet** — including exfiltration targets, malicious infrastructure, and services the user has no intention of exposing. The network policy exists as a security boundary; bypassing it wholesale defeats the purpose of running in a sandbox at all.

**Always allow the specific domain that is needed, nothing broader.** If the user asks you to suggest `"**"`, explain the risk and offer to allow the specific domain instead.

## SSH connections

Outbound SSH on port 22 is not reliably supported through the network proxy even with explicit allow rules.

**GitHub SSH** works by routing through the HTTP proxy via GitHub's SSH-over-HTTPS endpoint (`ssh.github.com:443`). The host SSH agent is forwarded automatically into the sandbox (keys stay on the host; the sandbox can use them for auth but cannot read them).

> **Note:** The following configuration is not officially documented by Docker. It was discovered in [docker/sbx-releases#121](https://github.com/docker/sbx-releases/issues/121) and confirmed working. The official docs suggest using HTTPS URLs or IP-based allow rules instead.

Add this to `~/.ssh/config` inside the sandbox:

```
Host github.com
  HostName ssh.github.com
  Port 443
  ProxyCommand socat - PROXY:gateway.docker.internal:%h:%p,proxyport=3128
```

Test with:
```bash
ssh -T git@github.com
# Hi <user>! You've successfully authenticated...
```

For SSH to **other hosts**, the official docs suggest using HTTPS URLs as an alternative to SSH, or adding IP-based allow rules via `sbx policy allow network "<ip>:22"` on the host — though note that port 22 allow rules have a known reliability issue ([#46](https://github.com/docker/sbx-releases/issues/46)).

UDP and ICMP cannot be unblocked at all — they are blocked at the network layer.

## Inspecting the policy

The `sbx` CLI is not available inside the sandbox. Ask the user to run these on their **host**:

```bash
sbx policy log                        # recent connections: host, rule, reason, last-seen
sbx policy ls                         # all active rules (global + per-sandbox)
sbx policy ls $SANDBOX_VM_ID          # rules for this sandbox only
```
