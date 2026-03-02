---
name: gen-tests
description: Generate unit tests, integration tests, and regression tests for existing or new code. Detects the project's test framework and conventions automatically. Runs as an isolated background agent. Invoke after implementation to ensure new code has coverage.
argument-hint: [file paths or scope description]
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
context: fork
---

Invoke the `test-generator` skill to generate tests for:

$ARGUMENTS

If no scope is specified, the skill will check recent git changes and generate tests for any new or modified source files lacking coverage.
