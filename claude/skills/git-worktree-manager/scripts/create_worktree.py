#!/usr/bin/env python3
"""
Create a git worktree in the .worktrees/ directory with a new branch from a base branch.
"""

import subprocess
import sys
import os
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


def create_worktree(branch_name, base_branch="main", repo_path=None):
    """
    Create a new worktree in .worktrees/ with a new branch.
    
    Args:
        branch_name: Name of the new branch (e.g., 'feature/add-auth')
        base_branch: Base branch to create from (default: 'main')
        repo_path: Path to the repository (default: current directory)
    
    Returns:
        Path to the created worktree
    """
    # Get repository root
    repo_root = Path(get_repo_root(repo_path))
    
    # Ensure we're in a git repository
    if not repo_root.exists():
        raise RuntimeError("Not in a git repository")
    
    # Create .worktrees directory if it doesn't exist
    worktrees_dir = repo_root / ".worktrees"
    worktrees_dir.mkdir(exist_ok=True)
    
    # Sanitize branch name for directory (replace / with -)
    dir_name = branch_name.replace("/", "-")
    worktree_path = worktrees_dir / dir_name
    
    # Check if worktree already exists
    if worktree_path.exists():
        raise RuntimeError(f"Worktree directory already exists: {worktree_path}")
    
    # Check if branch already exists
    result = run_git_command(
        ["git", "rev-parse", "--verify", f"refs/heads/{branch_name}"],
        cwd=repo_root,
        check=False
    )
    
    if result.returncode == 0:
        # Branch exists, check it out in worktree
        print(f"Branch '{branch_name}' already exists, checking out in worktree...")
        run_git_command(
            ["git", "worktree", "add", str(worktree_path), branch_name],
            cwd=repo_root
        )
    else:
        # Branch doesn't exist, create it from base branch
        print(f"Creating new branch '{branch_name}' from '{base_branch}'...")
        
        # Verify base branch exists
        result = run_git_command(
            ["git", "rev-parse", "--verify", f"refs/heads/{base_branch}"],
            cwd=repo_root,
            check=False
        )
        
        if result.returncode != 0:
            # Try to fetch base branch from origin
            print(f"Base branch '{base_branch}' not found locally, trying origin...")
            run_git_command(
                ["git", "fetch", "origin", base_branch],
                cwd=repo_root,
                check=False
            )
        
        # Create worktree with new branch
        run_git_command(
            ["git", "worktree", "add", "-b", branch_name, str(worktree_path), base_branch],
            cwd=repo_root
        )
    
    print(f"✅ Worktree created successfully at: {worktree_path}")
    return str(worktree_path)


def main():
    if len(sys.argv) < 2:
        print("Usage: create_worktree.py <branch-name> [base-branch] [repo-path]")
        print("Example: create_worktree.py feature/new-feature main /path/to/repo")
        sys.exit(1)
    
    branch_name = sys.argv[1]
    base_branch = sys.argv[2] if len(sys.argv) > 2 else "main"
    repo_path = sys.argv[3] if len(sys.argv) > 3 else None
    
    try:
        worktree_path = create_worktree(branch_name, base_branch, repo_path)
        print(f"\nWorktree path: {worktree_path}")
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
