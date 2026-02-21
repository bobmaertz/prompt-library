---
name: git-worktree-manager
description: Manage git worktrees for AI agent workflows. Use when creating, listing, removing, or pruning worktrees, especially for ticket-based development where the agent needs to create isolated working directories for feature branches. Supports creating worktrees in .worktrees/ subdirectory, automatic branch creation from base branch (main), and cleanup of stale worktrees.
---

# Git Worktree Manager

Manage git worktrees for AI agent workflows where Claude creates isolated working directories for tickets, features, or bug fixes.

## Overview

This skill provides scripts to:
- **Create** worktrees in `.worktrees/` with branches from a base branch
- **List** all worktrees with their status
- **Remove** specific worktrees by path or branch name
- **Prune** stale worktrees that no longer exist on disk

## Directory Structure

Worktrees are organized in a project-based subdirectory pattern:

```
my-project/
├── .git/
├── src/
├── .worktrees/
│   ├── feature-add-auth/      # Created for feature/add-auth
│   ├── feature-fix-bug-123/   # Created for feature/fix-bug-123
│   └── hotfix-security/       # Created for hotfix/security
└── ...
```

Branch names are sanitized for directory names (e.g., `feature/add-auth` → `feature-add-auth`).

## Typical Agent Workflow

1. **Receive ticket** - Agent is asked to work on a feature or bug
2. **Create worktree** - Create isolated workspace for the ticket
3. **Do work** - Make changes, test, commit
4. **Clean up** - Remove worktree when done or prune stale ones

## Scripts

All scripts are in the `scripts/` directory and should be run with Python 3.

### create_worktree.py

Create a new worktree with a branch from a base branch.

**Usage:**
```bash
python3 scripts/create_worktree.py <branch-name> [base-branch] [repo-path]
```

**Parameters:**
- `branch-name` (required): Name of the branch (e.g., `feature/add-auth`)
- `base-branch` (optional): Base branch to branch from (default: `main`)
- `repo-path` (optional): Path to repository (default: current directory)

**Behavior:**
- Creates `.worktrees/` directory if it doesn't exist
- If branch exists: checks it out in the worktree
- If branch doesn't exist: creates it from base branch and checks out in worktree
- If base branch doesn't exist locally: attempts to fetch from origin
- Sanitizes branch name for directory (replaces `/` with `-`)

**Examples:**
```bash
# Create worktree for feature/add-auth from main
python3 scripts/create_worktree.py feature/add-auth

# Create worktree from develop branch
python3 scripts/create_worktree.py feature/new-ui develop

# Create worktree in specific repo
python3 scripts/create_worktree.py feature/fix-bug main /path/to/repo
```

**Output:**
- Prints status messages during creation
- Returns worktree path on success
- Exits with error code 1 on failure

### list_worktrees.py

List all worktrees with their current status.

**Usage:**
```bash
python3 scripts/list_worktrees.py [--json] [repo-path]
```

**Parameters:**
- `--json` (optional): Output as JSON instead of formatted text
- `repo-path` (optional): Path to repository (default: current directory)

**Output includes:**
- Worktree path
- Branch name
- Status (clean, uncommitted changes, stale)
- Last commit info
- Count of changed files (if any)
- Warning about stale worktrees

**Examples:**
```bash
# List worktrees in current repo
python3 scripts/list_worktrees.py

# List worktrees as JSON
python3 scripts/list_worktrees.py --json

# List worktrees in specific repo
python3 scripts/list_worktrees.py /path/to/repo
```

### remove_worktree.py

Remove a specific worktree by path or branch name.

**Usage:**
```bash
python3 scripts/remove_worktree.py <path-or-branch> [--force] [--delete-branch] [repo-path]
```

**Parameters:**
- `path-or-branch` (required): Worktree path or branch name
- `--force` or `-f` (optional): Force removal even with uncommitted changes
- `--delete-branch` or `-d` (optional): Also delete the associated branch
- `repo-path` (optional): Path to repository (default: current directory)

**Safety features:**
- Prevents removal of main worktree
- Checks for uncommitted changes (unless `--force`)
- Falls back to manual removal if git command fails
- Automatically prunes stale references

**Examples:**
```bash
# Remove by branch name
python3 scripts/remove_worktree.py feature/add-auth

# Remove by path
python3 scripts/remove_worktree.py /path/to/repo/.worktrees/feature-add-auth

# Force remove with uncommitted changes
python3 scripts/remove_worktree.py feature/old-feature --force

# Remove worktree and delete branch
python3 scripts/remove_worktree.py feature/completed --delete-branch

# Combine flags
python3 scripts/remove_worktree.py feature/abandoned --force --delete-branch
```

### prune_worktrees.py

Prune stale worktrees (where directory no longer exists).

**Usage:**
```bash
python3 scripts/prune_worktrees.py [--dry-run] [repo-path]
```

**Parameters:**
- `--dry-run` or `-n` (optional): Show what would be pruned without making changes
- `repo-path` (optional): Path to repository (default: current directory)

**Behavior:**
- Scans all registered worktrees
- Identifies worktrees where directory doesn't exist
- Removes stale worktree references from git's records
- Does not delete branches (only removes worktree references)

**Examples:**
```bash
# Preview stale worktrees
python3 scripts/prune_worktrees.py --dry-run

# Prune stale worktrees
python3 scripts/prune_worktrees.py

# Prune in specific repo
python3 scripts/prune_worktrees.py /path/to/repo
```

## Best Practices for AI Agents

### When to Create a Worktree

Create a worktree when:
- Starting work on a new feature or bug fix
- Need isolated workspace separate from main development
- Working on multiple tickets simultaneously
- Need to preserve uncommitted work while switching contexts

### When to Remove a Worktree

Remove a worktree when:
- Work is complete and merged
- Ticket is closed or abandoned
- Need to free up disk space
- Switching to work on different ticket

### When to Prune

Run prune regularly to:
- Clean up after manual directory deletions
- Maintain accurate worktree listings
- Free up git's internal worktree references
- Keep workspace organized

### Recommended Agent Pattern

```python
# 1. Start work on ticket
worktree_path = create_worktree("feature/ticket-123")

# 2. Do work in worktree
os.chdir(worktree_path)
# ... make changes, commit, etc.

# 3. Clean up when done
remove_worktree("feature/ticket-123", delete_branch=True)

# 4. Periodically prune stale worktrees
prune_worktrees()
```

## Error Handling

All scripts:
- Return exit code 0 on success
- Return exit code 1 on error
- Print error messages to stderr
- Provide descriptive error messages

Common errors:
- Not in a git repository
- Worktree already exists
- Branch already exists (when expected to create new)
- Uncommitted changes (when removing without --force)
- Permission issues

## Integration with Agent Workflows

### Example: Feature Development

```bash
# Agent receives ticket: "Add user authentication"
python3 scripts/create_worktree.py feature/add-auth

# Work in the worktree
cd .worktrees/feature-add-auth
# ... implement feature, test, commit ...

# When done
cd ../..
python3 scripts/remove_worktree.py feature/add-auth --delete-branch
```

### Example: Bug Fix

```bash
# Agent receives bug report: "Fix login crash"
python3 scripts/create_worktree.py feature/fix-login-crash

# Fix the bug
cd .worktrees/feature-fix-login-crash
# ... fix bug, test, commit ...

# Create PR, then cleanup
cd ../..
python3 scripts/remove_worktree.py feature/fix-login-crash
# Keep branch for PR, so don't use --delete-branch
```

### Example: Multiple Tickets

```bash
# List current worktrees to see what's in progress
python3 scripts/list_worktrees.py

# Switch between tickets by changing directory
cd .worktrees/feature-ticket-123
# ... work on ticket 123 ...

cd ../feature-ticket-456
# ... work on ticket 456 ...

# Clean up completed tickets
cd ../..
python3 scripts/remove_worktree.py feature/ticket-123 --delete-branch
```

## Notes

- Worktrees share the same git repository, so fetches and branches are shared
- Each worktree can have uncommitted changes independent of others
- Disk space: each worktree is a full working directory (but shares .git)
- Performance: worktrees are much faster than cloning for multiple workspaces
