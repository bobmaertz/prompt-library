#!/usr/bin/env python3
"""
Prune stale git worktrees (directories that no longer exist).
"""

import subprocess
import sys
from pathlib import Path


def run_git_command(cmd, cwd=None, check=True):
    """Run a git command and return the result."""
    result = subprocess.run(
        cmd,
        cwd=cwd,
        capture_output=True,
        text=True,
        check=False
    )
    
    if check and result.returncode != 0:
        raise RuntimeError(f"Git command failed: {' '.join(cmd)}\n{result.stderr}")
    
    return result


def get_repo_root(path=None):
    """Get the root directory of the git repository."""
    result = run_git_command(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=path
    )
    return result.stdout.strip()


def find_stale_worktrees(repo_path=None):
    """Find all stale worktrees (where directory doesn't exist)."""
    repo_root = get_repo_root(repo_path)
    
    result = run_git_command(
        ["git", "worktree", "list", "--porcelain"],
        cwd=repo_root
    )
    
    stale_worktrees = []
    current_worktree = {}
    
    for line in result.stdout.strip().split("\n"):
        if not line:
            if current_worktree:
                path = current_worktree.get("path")
                if path and not Path(path).exists():
                    stale_worktrees.append(current_worktree)
                current_worktree = {}
            continue
        
        if line.startswith("worktree "):
            current_worktree["path"] = line.split(" ", 1)[1]
        elif line.startswith("HEAD "):
            current_worktree["head"] = line.split(" ", 1)[1]
        elif line.startswith("branch "):
            current_worktree["branch"] = line.split(" ", 1)[1].replace("refs/heads/", "")
    
    # Check last worktree
    if current_worktree:
        path = current_worktree.get("path")
        if path and not Path(path).exists():
            stale_worktrees.append(current_worktree)
    
    return stale_worktrees


def prune_worktrees(dry_run=False, repo_path=None):
    """
    Prune stale worktrees.
    
    Args:
        dry_run: If True, only show what would be pruned
        repo_path: Path to the repository (default: current directory)
    
    Returns:
        Number of worktrees pruned
    """
    repo_root = get_repo_root(repo_path)
    
    # Find stale worktrees
    stale = find_stale_worktrees(repo_path)
    
    if not stale:
        print("✅ No stale worktrees found")
        return 0
    
    print(f"\n📋 Found {len(stale)} stale worktree(s):\n")
    
    for wt in stale:
        path = wt.get("path", "unknown")
        branch = wt.get("branch", "unknown")
        print(f"   • {path}")
        print(f"     Branch: {branch}")
    
    if dry_run:
        print("\n🔍 Dry run - no changes made")
        print("Run without --dry-run to actually prune these worktrees")
        return len(stale)
    
    print("\n🧹 Pruning stale worktrees...")
    
    result = run_git_command(
        ["git", "worktree", "prune", "--verbose"],
        cwd=repo_root
    )
    
    if result.stdout:
        print(result.stdout)
    
    print(f"✅ Pruned {len(stale)} stale worktree(s)")
    
    return len(stale)


def main():
    dry_run = "--dry-run" in sys.argv or "-n" in sys.argv
    
    # Get repo path if provided (last non-flag argument)
    repo_path = None
    for arg in sys.argv[1:]:
        if not arg.startswith("--") and not arg.startswith("-"):
            repo_path = arg
            break
    
    try:
        count = prune_worktrees(dry_run, repo_path)
        
        if dry_run and count > 0:
            sys.exit(0)
        elif count == 0:
            sys.exit(0)
        else:
            sys.exit(0)
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
