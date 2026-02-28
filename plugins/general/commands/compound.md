---
name: compound
description: Document a recently solved problem to compound team knowledge. Captures root cause, solution, and prevention strategies in docs/solutions/ while context is fresh.
argument-hint: "[optional: brief context about the problem just solved]"
allowed-tools: Glob, Grep, Read, Write, Bash, Task
context: fork
---

# /compound

> Inspired by [Every.co's compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin). Adapted for the general plugin.

Coordinate multiple subagents in parallel to document a recently solved problem.

## Purpose

Captures problem solutions while context is fresh, creating structured documentation in `docs/solutions/` with YAML frontmatter for searchability and future reference.

**Why "compound"?** Each documented solution compounds your team's knowledge. The first time you solve a problem takes research. Document it, and the next occurrence takes minutes. Knowledge compounds.

---

## Critical Constraint

**Only ONE file gets written — the final documentation.**

Phase 1 subagents return text data to the orchestrator. They must NOT write any files. Only the orchestrator (Phase 2) writes the single final file.

---

## Execution: Two-Phase Orchestration

### Phase 1 — Parallel Research

Launch the following subagents IN PARALLEL. Each returns text only.

#### 1. Context Analyzer
- Review the current conversation and recent git history (`git log --oneline -10`, `git diff HEAD~1`)
- Identify: problem type, affected component(s), observed symptoms, error messages
- Return: YAML frontmatter skeleton (title, date, category, tags, affected-components)

#### 2. Solution Extractor
- Analyze all investigation steps taken: what was tried, what failed, what worked
- Identify the root cause with a technical explanation
- Extract the working solution with code examples, commands, or config changes
- Return: root-cause paragraph + solution content block with code snippets

#### 3. Related Docs Finder
- Search `docs/solutions/` for related previously documented issues
- Run `grep -r` for relevant keywords across the codebase and existing docs
- Return: list of related docs (with paths) and suggested cross-reference links

#### 4. Prevention Strategist
- Based on root cause, develop 2-5 concrete prevention strategies
- Suggest tests, linting rules, or process changes that would catch this earlier
- Return: prevention strategies list + any suggested test cases

#### 5. Category Classifier
- Determine the appropriate `docs/solutions/` subfolder from the taxonomy below
- Generate a kebab-case filename derived from the problem (e.g., `missing-env-var-on-startup.md`)
- Return: full target path — `docs/solutions/[category]/[filename].md`

**Category taxonomy:**
- `build-errors/`
- `test-failures/`
- `runtime-errors/`
- `performance-issues/`
- `database-issues/`
- `security-issues/`
- `integration-issues/`
- `configuration-issues/`
- `logic-errors/`

---

### Phase 2 — Assembly and Write

**Wait for all Phase 1 subagents to complete before proceeding.**

1. Collect all text output from Phase 1 subagents
2. Assemble the complete markdown document (see schema below)
3. Validate the YAML frontmatter
4. Create the directory if needed
5. Write the single final file: `docs/solutions/[category]/[filename].md`

---

## Documentation Schema

```markdown
---
title: "<concise problem title>"
date: "YYYY-MM-DD"
category: "<category-folder-name>"
tags: [tag1, tag2, tag3]
affected-components: [component1, component2]
severity: low | medium | high | critical
time-to-resolve: "<e.g., 2 hours>"
---

## Problem

### Symptom
What was observable: error messages, unexpected behavior, failure mode.

### Context
When/where this occurred: environment, triggering conditions, affected systems.

## Investigation

What was tried during diagnosis, in order. Include dead ends — they are valuable.

1. First thing tried — result
2. Second thing tried — result
3. What finally revealed the root cause

## Root Cause

Technical explanation of why this happened.

## Solution

Step-by-step fix with code examples, commands, or config changes.

```language
// Code example here
```

## Prevention

How to avoid this in the future:

1. Strategy one
2. Strategy two
3. ...

### Suggested Tests
Any test cases that would catch this regression.

## Related

- [Related doc title](../path/to/doc.md)
- [Related issue or PR](#link)
```

---

## Success Output

After writing the file, summarize results:

```
✓ Documentation complete

Phase 1 Results:
  ✓ Context Analyzer: [identified problem type and component]
  ✓ Solution Extractor: [N code examples extracted]
  ✓ Related Docs Finder: [N related docs found]
  ✓ Prevention Strategist: [N prevention strategies]
  ✓ Category Classifier: [category/filename.md]

File created:
  docs/solutions/[category]/[filename].md

This solution is now searchable for future reference.
What's next?
1. Run /peer-review to review the documentation quality
2. Link from related docs
3. Continue with current work
```

---

## The Compounding Philosophy

```
First occurrence:  Research + Fix          → 30–120 min
Document it:       /compound               →   5 min
Next occurrence:   Lookup + Apply          →   2 min
```

Each documented solution makes future engineering faster. The feedback loop:

```
Encounter Issue → Research → Fix → /compound → docs/solutions/
                                                      ↓
                               Future issue ← Quick lookup
```

**Each unit of work should make subsequent units easier — not harder.**

---

## When to Invoke

Run `/compound` immediately after resolving any non-trivial problem:

- A bug that took more than 30 minutes to diagnose
- An environment or configuration issue that wasn't obvious
- An integration failure with an external service
- A performance problem that required investigation
- Any problem you'd dread encountering again without notes

If context is provided via `$ARGUMENTS`, use it as an additional hint for the Context Analyzer and Category Classifier.
