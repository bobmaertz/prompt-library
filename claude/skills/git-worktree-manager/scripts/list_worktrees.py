#!/usr/bin/env python3
"""
List all git worktrees with their current status.
"""

import subprocess
import sys
import json
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


def get_worktree_status(worktree_path):
    """Get status information for a worktree."""
    status = {}
    
    # Check if path exists
    if not Path(worktree_path).exists():
        status["exists"] = False
        status["stale"] = True
        return status
    
    status["exists"] = True
    status["stale"] = False
    
    # Get current branch
    result = run_git_command(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
        cwd=worktree_path,
        check=False
    )
    status["branch"] = result.stdout.strip() if result.returncode == 0 else "unknown"
    
    # Check for uncommitted changes
    result = run_git_command(
        ["git", "status", "--porcelain"],
        cwd=worktree_path,
        check=False
    )
    status["has_changes"] = len(result.stdout.strip()) > 0
    status["changes_count"] = len(result.stdout.strip().split("\n")) if status["has_changes"] else 0
    
    # Get last commit info
    result = run_git_command(
        ["git", "log", "-1", "--format=%h %s"],
        cwd=worktree_path,
        check=False
    )
    status["last_commit"] = result.stdout.strip() if result.returncode == 0 else "none"
    
    return status


def list_worktrees(repo_path=None, json_output=False):
    """
    List all worktrees in the repository.
    
    Args:
        repo_path: Path to the repository (default: current directory)
        json_output: Output as JSON instead of formatted text
    
    Returns:
        List of worktree information dictionaries
    """
    # Get repository root
    repo_root = Path(get_repo_root(repo_path))
    
    # Get worktree list from git
    result = run_git_command(
        ["git", "worktree", "list", "--porcelain"],
        cwd=repo_root
    )
    
    worktrees = []
    current_worktree = {}
    
    for line in result.stdout.strip().split("\n"):
        if not line:
            if current_worktree:
                worktrees.append(current_worktree)
                current_worktree = {}
            continue
        
        if line.startswith("worktree "):
            current_worktree["path"] = line.split(" ", 1)[1]
        elif line.startswith("HEAD "):
            current_worktree["head"] = line.split(" ", 1)[1]
        elif line.startswith("branch "):
            current_worktree["branch"] = line.split(" ", 1)[1].replace("refs/heads/", "")
        elif line == "bare":
            current_worktree["bare"] = True
        elif line == "detached":
            current_worktree["detached"] = True
    
    # Add the last worktree if exists
    if current_worktree:
        worktrees.append(current_worktree)
    
    # Get status for each worktree
    for wt in worktrees:
        wt["status"] = get_worktree_status(wt["path"])
    
    if json_output:
        return worktrees
    
    # Format output
    print(f"\n📁 Worktrees in {repo_root}\n")
    print("=" * 80)
    
    for i, wt in enumerate(worktrees, 1):
        path = wt["path"]
        branch = wt.get("branch", "N/A")
        status = wt["status"]
        
        # Determine if this is the main worktree
        is_main = Path(path) == repo_root
        label = "MAIN" if is_main else f"#{i-1}" if i > 1 else ""
        
        print(f"\n{label} {path}")
        print(f"   Branch: {branch}")
        
        if not status["exists"]:
            print("   ⚠️  STALE (directory doesn't exist)")
        elif status["has_changes"]:
            print(f"   🔧 Uncommitted changes ({status['changes_count']} files)")
        else:
            print("   ✓ Clean")
        
        if status.get("last_commit"):
            print(f"   Last commit: {status['last_commit']}")
    
    print("\n" + "=" * 80)
    print(f"Total worktrees: {len(worktrees)}")
    
    # Count stale worktrees
    stale_count = sum(1 for wt in worktrees if wt["status"].get("stale", False))
    if stale_count > 0:
        print(f"⚠️  Stale worktrees: {stale_count} (run prune_worktrees.py to clean up)")
    
    return worktrees


def main():
    json_output = "--json" in sys.argv
    repo_path = None
    
    for arg in sys.argv[1:]:
        if arg != "--json":
            repo_path = arg
            break
    
    try:
        worktrees = list_worktrees(repo_path, json_output)
        
        if json_output:
            print(json.dumps(worktrees, indent=2))
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
