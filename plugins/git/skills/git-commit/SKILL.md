---
name: git-commit
description: Analyzes staged changes and recent commit history to generate a well-formatted commit message that matches the project's existing commit style. Produces the commit command ready to run.
argument-hint: [optional context or scope note]
allowed-tools: Bash, Read, Grep
---

# Git Commit Skill

Generates a commit message that matches the style of this project's existing commits. Always learns from the actual git log before writing — never applies a generic format blindly.

## Process

### Step 1 — Read the Project's Commit Style

```bash
git log --oneline -20
```

Analyze the last 20 commits to detect:

- **Format**: Conventional commits (`feat: ...`), imperative short phrases (`Add ...`), ticket-prefixed (`JIRA-123: ...`), or custom
- **Capitalization**: Sentence case, Title Case, all lowercase
- **Length**: Max characters for subject line (usually 50–72)
- **Body**: Does this project use multi-line commits with body paragraphs?
- **Trailers**: Issue references, Co-authored-by, ticket links

Match whatever style the project uses. Do not impose Conventional Commits if the project doesn't use them.

### Step 2 — Understand the Change

```bash
git diff --cached --stat
git diff --cached
```

Identify:
- What changed (files, modules, layers)
- Why it changed (purpose of the work)
- Whether it's a feature, fix, refactor, test, docs, or config change
- Any breaking changes

If `$ARGUMENTS` provides context about the purpose, use it.

### Step 3 — Draft the Commit Message

Write a commit message following the detected project style:

**Subject line rules (always apply)**:
- Describe the *what and why*, not the *how*
- Imperative mood: "Add", "Fix", "Update", "Remove" (not "Added", "Fixed")
- No trailing period
- Within the project's typical subject line length

**Body** (include if the project uses bodies, or if the change is complex):
- Blank line between subject and body
- Explain motivation and context, not what the diff shows
- Wrap at 72 characters

**Trailers** (match project conventions):
- Issue references: `Closes #123`, `Fixes #456`, `Refs #789`
- Co-authorship, changelog hints, etc.

### Step 4 — Output

Produce the staged diff summary and the ready-to-run commit command:

```markdown
## Staged Changes

<summary from git diff --cached --stat>

## Commit Message

```
<subject line>

<body if needed>

<trailers if needed>
```

## Command

```bash
git commit -m "$(cat <<'EOF'
<subject line>

<body>
EOF
)"
```

Copy and run the command above, or confirm and I'll run it for you.
```

## Customizing Your Style

To lock in a specific format, add a `.commitstyle` file to your repo root:

```
# .commitstyle
format: conventional          # conventional | imperative | ticket-prefix
ticket-prefix: PROJ           # e.g., PROJ-123: subject
max-subject-length: 72
use-body: true
trailers: Closes, Refs
```

When `.commitstyle` exists, it takes precedence over inferred style.

## Examples

### Conventional Commits style
```
feat(auth): add refresh token rotation

Rotate refresh tokens on each use to limit the blast radius of token
theft. Previous tokens are immediately invalidated.

Closes #234
```

### Imperative short-phrase style
```
Add refresh token rotation to auth flow
```

### Ticket-prefixed style
```
AUTH-89: Add refresh token rotation

Rotates tokens on each use and invalidates previous tokens immediately.
```
