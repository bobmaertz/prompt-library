---
name: harness-init
description: Initialize a long-running build project. Decomposes a high-level goal into a granular feature_list.json, sets up claude-progress.txt, creates an init.sh bootstrap script, and makes an initial git commit. Run once before your first /harness-run session.
argument-hint: <high-level goal or app description>
allowed-tools: Agent
---

Use the Agent tool to invoke the `harness-initializer` agent with the following goal:

$ARGUMENTS
