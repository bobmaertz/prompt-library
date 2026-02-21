---
name: explore-repo
description: Map the current repository's architecture, conventions, entry points, and patterns. Runs as a background sub-agent and returns a structured codebase report. Useful before implementing a feature in an unfamiliar codebase or when onboarding to a new project.
argument-hint: [optional: specific area, module, or question]
allowed-tools: Glob, Grep, Read, Bash
context: fork
---

Explore and map the current repository using the repo-explorer skill.

$ARGUMENTS

Produce a complete repository report covering:
- Directory structure and key paths (annotated)
- Architecture pattern and how layers interact
- Entry points (how the app starts, key scripts)
- Conventions (naming, error handling, async patterns, testing)
- Key dependencies and their purposes
- Any notable codebase health observations

If a specific area or question was provided above, include a focused deep-dive on that area in addition to the top-level overview.

Reference the repo-explorer skill for the full analysis process.
