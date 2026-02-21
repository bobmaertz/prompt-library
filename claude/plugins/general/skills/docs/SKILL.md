---
name: docs
description: Documentation lookup and synthesis skill. Searches local project documentation (README files, docs/, docstrings, JSDoc, type stubs), fetches official external documentation, and synthesizes answers. Also used for generating missing documentation. Loads project best-practices context automatically.
argument-hint: <question, topic, or "generate: <target>">
allowed-tools: Glob, Grep, Read, WebFetch, WebSearch, Bash
---

# Docs Skill

Finds, synthesizes, and generates documentation. Covers local project docs and external references in one pass.

## Modes

### Lookup mode (default)
Answer a question using documentation sources — local first, then external.

```
/docs How does authentication work in this project?
/docs What are the TypeScript config options for moduleResolution?
/docs React useEffect dependency array rules
```

### Generate mode
Write documentation for undocumented code.

```
/docs generate: src/auth/middleware.ts
/docs generate: the payment processing module
/docs generate: README for the scripts/ directory
```

## Lookup Process

### Step 1 — Local Documentation

Search the project's own docs before going external:

**Structured docs**
```bash
find . -type f \( -name "*.md" -o -name "*.mdx" -o -name "*.rst" -o -name "*.txt" \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' | sort
```

Read `README.md`, `docs/`, `CHANGELOG.md`, `CONTRIBUTING.md`, and any topic-specific docs.

**Inline docs** — search for docstrings, JSDoc, and comments:
```bash
# Find JSDoc / TSDoc
grep -r "@param\|@returns\|@example\|@throws" --include="*.ts" --include="*.js" -l

# Find Python docstrings around the topic
grep -r '"""' --include="*.py" -l

# Find Go doc comments
grep -r "^// [A-Z]" --include="*.go" -l
```

**Best practices reference** — always load the project's standards doc if it exists:
```
~/.config/claude/prompts/best-practices.md
```
or locally: `claude/prompts/best-practices.md` / `.claude/prompts/best-practices.md`

### Step 2 — External Documentation

If local docs don't fully answer the question, fetch authoritative external sources.

Prefer in order:
1. Official language/framework documentation
2. Official GitHub repository README or wiki
3. RFC or specification documents
4. Reputable technical references (MDN, docs.rs, pkg.go.dev, etc.)

Use `WebSearch` to locate the right URL, then `WebFetch` to read it.

**Do not** use blog posts, Stack Overflow, or community sites as primary sources — they can be wrong or outdated. Reference them only to understand common patterns or verify understanding.

### Step 3 — Synthesize

Combine local and external findings into a direct, sourced answer:

```markdown
## Documentation: <topic>

### Answer
Direct answer to the question.

### From Project Docs
- `docs/auth.md:L42` — relevant excerpt
- `src/auth/middleware.ts:L15` — JSDoc explaining the signature

### From Official Docs
- [Reference Title](url): key point

### Example
Concrete code example if applicable.

### See Also
Related topics worth knowing.
```

## Generate Mode Process

When asked to generate documentation for undocumented code:

### Step 1 — Read the Target
Read the file or module fully. Understand what it does, not just what it says.

### Step 2 — Load Project Doc Style
Check for existing documentation to match the style:
- Read 2-3 already-documented files in the same codebase
- Note: JSDoc vs TSDoc, Google style vs NumPy style, verbosity level
- Check `best-practices.md` for documentation standards

### Step 3 — Generate

For **functions/methods**, write:
- One-line summary (imperative mood: "Returns...", "Validates...", "Sends...")
- `@param` / parameter descriptions with types
- `@returns` description
- `@throws` / error conditions
- `@example` if the usage is non-obvious

For **modules/files**, write:
- Module-level docstring explaining purpose and responsibility
- High-level overview of exports

For **README files**, write:
- Purpose and what problem this solves
- Quick start (installation + minimal usage)
- API/interface reference
- Configuration options
- Contributing notes

### Step 4 — Output

Present the generated documentation ready to insert:

```markdown
## Generated Documentation

**Target**: `path/to/file.ts` (or module name)
**Style**: JSDoc / Google / NumPy / (detected style)

### Additions

#### `functionName` (line 42)
```typescript
/**
 * Brief description in imperative mood.
 *
 * @param paramName - Description of what this parameter does.
 * @param options - Configuration options.
 * @returns Description of return value.
 * @throws {ErrorType} When this condition occurs.
 *
 * @example
 * const result = functionName('value', { flag: true });
 */
```

#### (next undocumented export)
...

### Notes
Anything ambiguous that needs human clarification before the docs are merged.
```

## Guidelines

- Answer the actual question — don't dump raw documentation at the user
- Local project docs take precedence over external docs for project-specific questions
- Always cite: file path + line number for local, URL for external
- When generating docs, match the existing style precisely — don't introduce a new style
- If the answer is genuinely not in the docs, say so clearly rather than guessing
- The `best-practices.md` prompt in this repo defines the project's documentation standards — always load it when generating docs
