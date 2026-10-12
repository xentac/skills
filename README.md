# skills

Personal agent skills for use across AI coding tools (Claude Code, Cursor, Cline, etc.).

## Installing as Claude Code plugins

This repo is a Claude Code plugin marketplace named `xentac`. Skills are grouped into plugins by layer:

| Plugin | Skills |
|---|---|
| `torn` | torn-city, torn-ffscouter |
| `tooling` | markdown-lint |
| `sandboxes` | agent-sandbox-env, devcontainer-sandbox-env |

Add a layer to a project (writes `.claude/settings.json`, which you commit):

```bash
claude plugin marketplace add xentac/skills --scope project
claude plugin install torn@xentac --scope project
```

Plugin skills are invocable as `/torn-city` or, when that name is taken, `/torn:torn-city`.

Updating: `claude plugin marketplace update xentac`, then `claude plugin update torn@xentac` in each project, or set `"autoUpdate": true` on the marketplace entry in `.claude/settings.json`. The plugin version is the git commit, so changes ship as soon as they are pushed.

## Installing with the skills CLI

```bash
npx skills add xentac/skills
```

Install a specific skill:

```bash
npx skills add xentac/skills --skill <skill-name>
```

## Structure

Skills live in `skills/<name>/SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name
description: What this skill does
---

Skill instructions here.
```

## Adding to a project

```bash
# All skills
npx skills add xentac/skills

# One skill
npx skills add xentac/skills --skill skill-name
```

## Updating

`npx skills update` has a [known bug](https://github.com/vercel-labs/skills/issues/484) where it always reports skills as up to date even when they've changed. Re-run the install command to update:

```bash
npx skills add xentac/skills -y
```
