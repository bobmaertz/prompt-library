---
name: harness-status
description: Show a quick summary of the current harness state — features completed vs remaining, recent git commits, last session log entry, and any blockers noted. Use to orient yourself before starting a new session or checking progress.
argument-hint: ""
allowed-tools: Read, Bash
---

Read the harness state files and produce a concise status report.

1. Read `feature_list.json` (if it exists) and count features by status: `passing`, `failing`, `in_progress`, `blocked`.
2. Read the last 20 lines of `claude-progress.txt` (if it exists) to show the most recent session summary.
3. Run `git log --oneline -10` to show recent commits.
4. If `HARNESS_EVAL_REPORT.md` exists, show its **Summary** section only.

Output a compact status block:

```
## Harness Status

Features:  X passing / Y failing / Z in_progress / W blocked  (total: N)
Last session: <date and one-line summary from claude-progress.txt>
Blockers: <any features marked blocked, or "none">

Recent commits:
  <git log --oneline -10 output>
```

Do not read source code files or run tests. Keep this fast.
