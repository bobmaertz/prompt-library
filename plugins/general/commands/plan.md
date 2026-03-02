---
name: plan
description: Decompose a feature request into a structured implementation plan with clear task boundaries and file ownership. Writes MULTI_AGENT_PLAN.md for use by implementation agents. Run this before /implement on anything non-trivial.
argument-hint: <feature or problem description>
allowed-tools: Read, Glob, Grep, Bash, Write
---

Invoke the `architect-planner` skill to analyze the codebase and produce an implementation plan for:

$ARGUMENTS
