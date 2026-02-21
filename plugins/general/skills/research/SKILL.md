---
name: research
description: Orchestrates deep research across web, codebase, and documentation using parallel sub-agents. Returns a structured report with findings, sources, and recommendations.
argument-hint: <query>
allowed-tools: WebSearch, WebFetch, Grep, Glob, Read, Task
---

# Research Skill

Coordinates parallel research sub-agents to produce thorough, sourced findings on any technical topic.

## When to Use

Invoke this skill when you need information that spans multiple sources or domains:

- "What's the best way to handle X in language Y?"
- "How does our codebase currently handle Z?"
- "What do the official docs say about feature W?"
- "Research approaches to solving problem P"

## Usage

```
/skill:research <query>
```

Or invoke within a task by asking Claude to "research [topic] using the research skill."

## How It Works

The skill spins up specialized sub-agents for each research mode relevant to the query:

### Sub-Agent: Web Researcher
- Uses `WebSearch` and `WebFetch`
- Targets official docs, GitHub, technical blogs, release notes
- Validates source recency and authority
- Returns: findings with URLs and publication dates

### Sub-Agent: Codebase Researcher
- Uses `Grep`, `Glob`, and `Read`
- Maps existing implementations, patterns, and usage
- Identifies dependencies, callers, and conventions
- Returns: file paths, line numbers, and code snippets

### Sub-Agent: Documentation Researcher
- Fetches API references, RFCs, and specifications
- Extracts relevant signatures, constraints, and examples
- Returns: structured documentation excerpts with links

## Output Format

```markdown
## Research Report: <topic>

### Summary
High-level answer to the research question.

### Findings by Source

#### Web Sources
- [Source Title](url): Key finding

#### Codebase
- `path/to/file.ts:42` — description of what's there

#### Documentation
- [Official Docs](url): Relevant excerpt

### Synthesis
Integrated answer drawing from all sources.

### Sources
Complete list of all URLs and file references used.

### Next Steps
Recommended actions based on findings.
```

## Configuration

Sub-agents run in parallel by default. To run sequentially (e.g., when codebase findings should inform web research), specify in your prompt:

```
Research X sequentially: first check the codebase, then search the web for best practices.
```

## Notes

- Always cite sources — never present findings without attribution
- Flag when sources conflict and explain the trade-offs
- Mark findings with their date when recency matters
- For codebase research, always verify findings with `Read` before reporting
