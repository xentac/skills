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
- **SSH or other non-HTTP connection fails** → read `network-policy.md`
- **`git push` fails with an authentication error** → read `github-auth.md`
- **Questions about the environment** (ports, persistence, env vars, reaching the host) → read `environment.md`

## Looking up sbx documentation and issues

When the user asks how to configure something with `sbx`, or you encounter unexpected behaviour:

**Official docs** — fetch the relevant page directly:
```
https://docs.docker.com/ai/sandboxes/
```
Key sub-pages: `usage/`, `troubleshooting/`, `integrations/`, `customize/`, `architecture/`, `security/`, `governance/`

**Known issues and bug reports** — search the GitHub project:
```
https://github.com/docker/sbx/issues
```
Use `gh` to search issues without leaving the sandbox:
```bash
gh issue list --repo docker/sbx --search "<keywords>" --limit 20
gh issue view <number> --repo docker/sbx
```
