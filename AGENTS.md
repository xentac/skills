# Agent Guide: xentac/skills

This repo is a personal agent skills library distributed via:

```bash
npx skills add xentac/skills
```

## Structure

```
skills/
└── <skill-name>/
    ├── SKILL.md        ← required: frontmatter (name, description) + skill content
    └── *.md            ← optional reference files, installed alongside SKILL.md
```

Skills are discovered and installed by the `skills` CLI. Reference files in the skill directory are installed alongside `SKILL.md` and can be read by agents when needed.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter:
   ```markdown
   ---
   name: skill-name
   description: What this skill does
   ---

   Skill content here.
   ```
2. Add any reference files alongside it if the content warrants splitting.
3. Commit and push — skills.sh auto-indexes from the public GitHub repo.

## Version control

This repo uses [JJ (Jujutsu)](https://github.com/jj-vcs/jj) colocated with git. Use `jj` commands, not `git` directly.

Common workflow:

```bash
jj describe -m "commit message"   # describe the current working copy commit
jj new                            # start a new working copy on top
jj bookmark set main -r @-        # advance main to the described commit
jj git push --remote origin       # push to GitHub
```

## Git / SSH

The repo remote is SSH (`git@github.com:xentac/skills.git`). SSH routes through GitHub's port-443 endpoint via the sandbox HTTP proxy. The config in `~/.ssh/config` handles this:

```
Host github.com
  HostName ssh.github.com
  Port 443
  ProxyCommand socat - PROXY:gateway.docker.internal:%h:%p,proxyport=3128
```

If `git push` fails with an authentication error, the GitHub token needs refreshing — see the `agent-sandbox-env` skill.

## Conventions

- Keep `SKILL.md` concise: detection/trigger conditions and routing to reference files.
- Put detailed how-to content in named reference files (`network-policy.md`, not `details.md`).
- When updating reference files, also make a minor touch to `SKILL.md` — the `skills` CLI hashes the whole skill folder, but `npx skills update` has a known bug (#484) where it may not detect changes; consumers should re-run `npx skills add xentac/skills -y` to update.
