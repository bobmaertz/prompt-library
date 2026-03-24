---
name: harness-init
description: Initialize a long-running build project. Decomposes a high-level goal into a granular feature_list.json, sets up claude-progress.txt, creates an init.sh bootstrap script, and makes an initial git commit. Run once before your first /harness-run session.
argument-hint: <high-level goal or app description>
allowed-tools: Read, Write, Bash, Glob, Grep
---

Invoke the `initializer` skill to set up a long-running build harness for the following goal:

$ARGUMENTS
