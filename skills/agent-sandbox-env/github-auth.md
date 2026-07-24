# GitHub Authentication

The sandbox proxy transparently injects GitHub credentials on outbound Git requests. As a result, `gh auth status` always shows "not logged in" inside the sandbox — this is **expected and normal**.

## Recognising an expired token

When the injected token expires, `git push` fails with:

```
fatal: could not read Username for 'https://github.com'
```

## Refreshing the token

Tell the user to run on their **host**:

```bash
# This sandbox only (takes effect immediately):
gh auth token | sbx secret set $SANDBOX_VM_ID github -t -

# Globally for all future sandboxes:
gh auth token | sbx secret set -g github -t -
```

After the user confirms they've run the command, retry the push. Do not ask the user to push from their local terminal — pushing from inside the sandbox is the expected workflow.
