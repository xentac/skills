---
name: devcontainer-sandbox-env
description: Detect and adapt to running inside a VS Code / GitHub Codespaces-style devcontainer
---

# Devcontainer Sandbox Environment

## Detection

You are inside a devcontainer (VS Code Dev Containers or GitHub Codespaces) if **any** of these marker files exist:

```bash
ls -d /var/devcontainer/.patchEtc*Marker "$HOME/.devcontainer" 2>/dev/null
```

These come from the devcontainers CLI itself, not from any particular project's config, so they generalize across projects. `$HOME/.devcontainer/` holds one marker file per lifecycle hook that has fired (`.onCreateCommandMarker`, `.postCreateCommandMarker`, `.updateContentCommandMarker`, `.postStartCommandMarker`) — don't assume all four are present, just check for the directory or any one marker.

**Corroborating** (not sufficient alone — confirms the signal above, doesn't replace it):

```bash
cat /tmp/dev-container-features/devcontainer-features.builtin.env 2>/dev/null
# _REMOTE_USER, _CONTAINER_USER, _REMOTE_USER_HOME, _CONTAINER_USER_HOME
```

**Weak signals** — true of any Docker container, not devcontainer-specific: `/.dockerenv` exists; the workspace lives under `/workspaces/<name>`.

**Disambiguation from Docker Sandbox (sbx):** if you're checking "am I sandboxed at all" before narrowing down which kind, check `$IS_SANDBOX` / `$SANDBOX_VM_ID` first — both are unset in a devcontainer. If either is set, this isn't a devcontainer; see the `agent-sandbox-env` skill instead.

## When to consult reference files

- **A network request is blocked, or you need to grant a host new egress access** → read `firewall.md` for the default-deny egress firewall pattern some devcontainers run
