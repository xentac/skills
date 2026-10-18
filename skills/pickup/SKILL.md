---
name: pickup
description: Pick a parked project back up. Reads its section of the Obsidian Now note, checks what changed since, and says where the user was and what's next. "/pickup all", or a directory with nothing parked, lists every parked project.
argument-hint: "[project | all]"
disable-model-invocation: true
---

# Pickup

Read `$HOME/Documents/Obsidian Vault/004 Now.md`, written by `/park`: one
`## <project>` section per parked project.

## Find the section

- `$ARGUMENTS` names a project: use that section.
- Otherwise use the section whose **Repo** path contains `$PWD`, or that
  `$PWD` sits inside.
- `$ARGUMENTS` is `all`, or nothing matches: list every section as one line
  (project, Next, Parked date), oldest first, ask which to pick up, and stop.

## Check what changed since it was parked

- **VCS:** in the repo, `jj st` and `jj log --limit 5` with a `.jj`
  directory, else `git status --short` and `git log --oneline -5`. Note any
  commits newer than **Parked**.
- **Issue:** `gh issue view <n> --comments`: is it still open, and are there
  comments since **Parked**?
- **Session:** does `~/.claude/projects/*/<id>.jsonl` still exist?
  Transcripts are pruned after about 30 days.

Call out anything that contradicts the note, like a Next step that is
already committed or an issue that has closed.

## Report

Briefly: the Goal as written, where things stand, the Next step and what
changed. Then offer both ways forward without assuming one:

1. **Resume the original session** with `claude --resume <id>`. It restores
   the full conversation; best when recent and not huge. Skip this option
   when it is the current session or the transcript is gone.
2. **Continue here** from the note, the issue and the log.

Don't edit the note; the next `/park` rewrites the section.
