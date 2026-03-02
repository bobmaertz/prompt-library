---
name: implement
description: Execute a single bounded implementation task. Reads MULTI_AGENT_PLAN.md if present, or takes an inline task description. Stays within its assigned file scope and reports when done. Use after /plan for structured multi-task work.
argument-hint: <task description or "task N from MULTI_AGENT_PLAN.md">
allowed-tools: Read, Write, Edit, Bash
---

Invoke the `implementation-worker` skill to implement the following task:

$ARGUMENTS
