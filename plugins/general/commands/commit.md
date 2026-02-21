---
name: commit
description: Generate a context-aware commit message that matches this project's existing commit style. Reads git history and staged diff to produce a ready-to-run commit command.
argument-hint: [optional context or scope note]
allowed-tools: Bash, Read, Grep
---

Invoke the `git-commit` skill to analyze staged changes and produce a commit message that fits this project's commit style.
