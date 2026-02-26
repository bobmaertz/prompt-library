---
name: refactor
description: Perform targeted, behavior-preserving refactoring within a defined scope. Runs as an isolated background agent. Updates callers, tests, and docs alongside the code change. Use a dash to separate scope from goal: /refactor src/auth/ — extract JWT into dedicated module.
argument-hint: <scope> — <goal>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
context: fork
---

Invoke the `refactor-agent` skill to perform the following refactor:

$ARGUMENTS
