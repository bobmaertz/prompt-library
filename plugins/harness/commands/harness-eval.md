---
name: harness-eval
description: Run the evaluator agent to independently assess the current state of the build against feature_list.json. Produces a structured evaluation report with pass/fail per feature and actionable feedback. Use after each /harness-run session or whenever you want a quality gate.
argument-hint: [optional: specific aspect to focus the evaluation on]
allowed-tools: Agent
---

Use the Agent tool to invoke the `harness-evaluator` agent.

$ARGUMENTS
