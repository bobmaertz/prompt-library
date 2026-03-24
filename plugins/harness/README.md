# harness

Long-running application development harness for Claude Code, based on [Anthropic's harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps).

## The Problem

Complex builds take more context than a single Claude session can hold. Without structure, a fresh session has no memory of prior work — it starts over, repeats decisions, and misses progress already made.

## The Solution

This plugin implements a two-agent harness with a generator-evaluator loop:

1. **Initializer** — runs once, decomposes the goal into a granular feature list, sets up progress tracking artifacts, and makes the first git commit.
2. **Coding Agent** — runs each session, reads the progress log and feature list to orient itself, implements the next batch of features one at a time, verifies each, and leaves clean artifacts for the next session.
3. **Evaluator** — runs independently after coding sessions to catch over-optimistic self-assessments, producing a structured quality report with prioritized rework items.

The primary handoff artifact is `claude-progress.txt` — a human-readable log that every fresh agent reads first to understand what was done and what comes next. Git history provides the secondary record.

## Commands

| Command | Description |
|---------|-------------|
| `/harness-init <goal>` | Initialize the harness for a new build project |
| `/harness-run [focus]` | Run one coding session, picking up from the last |
| `/harness-eval [focus]` | Run the evaluator to independently assess build quality |
| `/harness-status` | Quick summary of features done, remaining, and blockers |

## Workflow

```
/harness-init "build a task management web app with React and a REST API"
    └─► feature_list.json (200 features, all failing)
        claude-progress.txt (session 0)
        init.sh
        git commit

/harness-run          # session 1 — implements F001–F012, commits each
/harness-eval         # evaluates F001–F012, writes HARNESS_EVAL_REPORT.md
/harness-run          # session 2 — fixes regressions, implements F013–F025
/harness-run          # session 3 — ...
```

Repeat `/harness-run` and `/harness-eval` until all features are passing.

## Artifacts

| File | Purpose |
|------|---------|
| `feature_list.json` | Ground truth of project health — every feature with status and notes |
| `claude-progress.txt` | Session log — each agent's primary memory across context resets |
| `init.sh` | Environment bootstrap — run to restore dependencies from scratch |
| `HARNESS_EVAL_REPORT.md` | Latest evaluator report — prioritized rework list |

## Key Design Principles

- **Context resets are safe** — each session is self-contained; `claude-progress.txt` + git history carry all necessary state
- **One feature per commit** — granular commits make regression bisection easy
- **Independent evaluation** — the evaluator is deliberately separate from the coding agent to prevent self-serving assessment
- **Features are the unit of progress** — `feature_list.json` is the source of truth, not lines of code or time spent
