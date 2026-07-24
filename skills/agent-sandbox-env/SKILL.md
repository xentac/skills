---
name: agent-sandbox-env
description: Detect and adapt to running inside a Docker Sandbox (sbx)
---

# Agent Sandbox Environment

## Detection

You are inside a Docker Sandbox if **any** of these are true:

```bash
echo $IS_SANDBOX        # "1" inside sbx
echo $SANDBOX_VM_ID     # set to the sandbox name (e.g. "my-sandbox")
```

`$SANDBOX_VM_ID` is also the hostname and is used in all host-side `sbx` commands.

## When to consult the reference files

These files live alongside this skill and should be read when the relevant situation arises:

- **An HTTP/HTTPS request returns 403** → read `network-policy.md`
- **`git push` fails with an authentication error** → read `github-auth.md`
- **Questions about the environment** (ports, persistence, env vars, reaching the host) → read `environment.md`
