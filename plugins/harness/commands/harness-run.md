---
name: harness-run
description: Run one coding session of the long-running harness. Reads claude-progress.txt and feature_list.json to pick up exactly where the last session left off, implements the next batch of features, commits progress, and updates the log. Safe to invoke repeatedly across fresh context windows.
argument-hint: [optional: focus area or specific feature to prioritize]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

Invoke the `coding-agent` skill to continue the build session.

$ARGUMENTS
