# skills

Personal agent skills for use across AI coding tools (Claude Code, Cursor, Cline, etc.).

## Installing

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
