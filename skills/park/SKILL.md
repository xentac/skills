---
name: park
description: Park the current project for a break. Records its live state (goal, next step, branch, issue, Claude session) in the Obsidian Now note so /pickup can resume it later. "/park done" removes the project instead.
argument-hint: "[done | a note about where your head is]"
disable-model-invocation: true
---

# Park

The user is stepping away, often tired. Record where this project stands so
they, or a later session, can resume without rereading the transcript. Be quick:
write the note first and ask nothing before it is saved.

## The Now note

`$HOME/Documents/Obsidian Vault/004 Now.md` holds one `## <project>` section
per parked project. Create it with a `# Now` heading if it is missing. It is
working memory, not a log: replace this project's section wholesale, never
append history, and leave other sections untouched.

The project name is the repo directory's basename (e.g. `ffscouter`), which
is also what `tmux-project` names its session.

If `$ARGUMENTS` is `done`, delete this project's section, mention any
uncommitted changes, and stop.

## Gather

- **Repo root:** `jj root`, else `git rev-parse --show-toplevel`, else `$PWD`.
- **VCS state:** with a `.jj` directory at the root use `jj st` and
  `jj log --limit 5`; otherwise `git status --short`,
  `git branch --show-current` and `git log --oneline -5`.
- **Issue:** the GitHub issue this work serves, from the conversation, the
  branch name or recent commit messages. Leave it out unless you are sure.
- **Session:** the ID is `${CLAUDE_SESSION_ID}`. Its transcript is
  `~/.claude/projects/*/${CLAUDE_SESSION_ID}.jsonl`; the title is the last
  `custom-title` entry there (set by `/rename`), else the last `ai-title`.

## Write the section

```markdown
## ffscouter

- **Goal:** <what the user set out to do, in their words>
- **Done:** <what this session finished>
- **Next:** <the very next concrete action>
- **Open:** <blockers or undecided questions; drop the line if none>
- **Repo:** `~/coding/torn/ffscouter` · branch `x` · #42
- **Session:** `<id>` "<title>" (`claude --resume <id>`)
- **Parked:** 2026-10-17 14:30
```

- **Goal is in the user's words.** Quote or closely paraphrase what they
  asked for in this conversation. Never use the session's AI title or your
  own summary of the work; those are what they can't interpret later.
- Fold a note passed in `$ARGUMENTS` into Next or Open as they said it.
- Next must be startable without rereading anything.
- Don't state beliefs as facts: if tests weren't run or a deploy wasn't
  checked, say so.
- Point to issues, ADRs, commits and files instead of restating them.
- No secrets. Keep the section to about eight lines.

## Durable progress on the issue

The note is disposable; the issue is not. If there is a linked issue and the
session produced something anyone working on it later would need (decisions,
dead ends, remaining steps), draft a short comment, show it, and post it with
`gh issue comment` only if the user says yes. Never post unprompted. Skip this
when there is nothing durable.

## Report

In a few lines: the section was written, any uncommitted changes (list them;
don't commit), and, if the session has no `custom-title`, suggest
`/rename <name>` (the ID in the note stays valid). Put the issue-comment
question last, so walking away from it loses nothing.
