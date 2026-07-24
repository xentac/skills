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

> I'm running inside a Docker Sandbox (`$SANDBOX_VM_ID`) and my request to `<domain>` was blocked by the network policy. To allow it, run this on your **host**:
> ```bash
> sbx policy allow network <domain>
> ```
> Let me know once you've run it and I'll retry.

Always suggest the specific domain. **Never suggest `sbx policy allow network "**"`** — see warning below.

4. **After the user confirms**, retry the request.

## ⚠ WARNING: Never suggest allowing all traffic

```bash
sbx policy allow network "**"   # NEVER suggest this
```

This disables the network sandbox entirely. It allows the agent to reach **any domain on the internet** — including exfiltration targets, malicious infrastructure, and services the user has no intention of exposing. The network policy exists as a security boundary; bypassing it wholesale defeats the purpose of running in a sandbox at all.

**Always allow the specific domain that is needed, nothing broader.** If the user asks you to suggest `"**"`, explain the risk and offer to allow the specific domain instead.

## SSH and other non-HTTP connections

The proxy only handles HTTP/HTTPS. SSH (and other non-HTTP TCP) connections require **IP-based** policy rules — hostname-based rules do not work for non-HTTP protocols.

To allow SSH to a host:

1. Resolve the IP from inside the sandbox:
   ```bash
   dig +short <hostname>
   ```
2. Tell the user to allow that IP and port on their **host**:
   ```bash
   sbx policy allow network "<ip>:22"
   ```

Note: IPs can change over time. If an SSH connection that previously worked starts failing, re-resolve the IP and re-add the rule.

UDP and ICMP cannot be unblocked at all — they are blocked at the network layer.

## Inspecting the policy

The `sbx` CLI is not available inside the sandbox. Ask the user to run these on their **host**:

```bash
sbx policy log   # recent connections: host, rule, reason, last-seen
sbx policy ls    # active rules and their status
```
