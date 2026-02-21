#!/usr/bin/env python3
"""
Remove a git worktree by path or branch name.
"""

import subprocess
import sys
import shutil
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


def find_worktree_by_branch(branch_name, repo_path=None):
    """Find worktree path by branch name."""
    repo_root = get_repo_root(repo_path)
    
    result = run_git_command(
        ["git", "worktree", "list", "--porcelain"],
        cwd=repo_root
    )
    
    current_path = None
    for line in result.stdout.strip().split("\n"):
        if line.startswith("worktree "):
            current_path = line.split(" ", 1)[1]
        elif line.startswith("branch ") and current_path:
            branch = line.split(" ", 1)[1].replace("refs/heads/", "")
            if branch == branch_name:
                return current_path
            current_path = None
    
    return None


def remove_worktree(identifier, force=False, delete_branch=False, repo_path=None):
    """
    Remove a worktree by path or branch name.
    
    Args:
        identifier: Path to worktree or branch name
        force: Force removal even with uncommitted changes
        delete_branch: Also delete the associated branch
        repo_path: Path to the repository (default: current directory)
    
    Returns:
        True if successful
    """
    repo_root = Path(get_repo_root(repo_path))
    
    # Determine if identifier is a path or branch name
    worktree_path = Path(identifier)
    branch_name = None
    
    if not worktree_path.exists():
        # Try to find by branch name
        found_path = find_worktree_by_branch(identifier, repo_path)
        if found_path:
            worktree_path = Path(found_path)
            branch_name = identifier
            print(f"Found worktree for branch '{branch_name}' at: {worktree_path}")
        else:
            raise RuntimeError(f"Worktree not found: {identifier}")
    else:
        # Get branch name from path
        result = run_git_command(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=worktree_path,
            check=False
        )
        if result.returncode == 0:
            branch_name = result.stdout.strip()
    
    # Prevent removal of main worktree
    if worktree_path.resolve() == repo_root.resolve():
        raise RuntimeError("Cannot remove the main worktree")
    
    # Check for uncommitted changes unless force is set
    if not force:
        result = run_git_command(
            ["git", "status", "--porcelain"],
            cwd=worktree_path,
            check=False
        )
        if result.returncode == 0 and result.stdout.strip():
            raise RuntimeError(
                f"Worktree has uncommitted changes. Use --force to remove anyway.\n"
                f"Changed files:\n{result.stdout}"
            )
    
    # Remove worktree using git
    print(f"Removing worktree: {worktree_path}")
    cmd = ["git", "worktree", "remove"]
    if force:
        cmd.append("--force")
    cmd.append(str(worktree_path))
    
    result = run_git_command(cmd, cwd=repo_root, check=False)
    
    # If git worktree remove fails, try manual removal
    if result.returncode != 0:
        print(f"Git worktree remove failed, attempting manual cleanup...")
        if worktree_path.exists():
            shutil.rmtree(worktree_path)
        # Prune the worktree from git's records
        run_git_command(["git", "worktree", "prune"], cwd=repo_root, check=False)
    
    print(f"✅ Worktree removed: {worktree_path}")
    
    # Delete branch if requested
    if delete_branch and branch_name:
        print(f"Deleting branch: {branch_name}")
        result = run_git_command(
            ["git", "branch", "-D", branch_name],
            cwd=repo_root,
            check=False
        )
        if result.returncode == 0:
            print(f"✅ Branch deleted: {branch_name}")
        else:
            print(f"⚠️  Could not delete branch: {result.stderr}")
    
    return True


def main():
    if len(sys.argv) < 2:
        print("Usage: remove_worktree.py <path-or-branch> [--force] [--delete-branch] [repo-path]")
        print("Example: remove_worktree.py feature/new-feature --force --delete-branch")
        print("Example: remove_worktree.py /path/to/worktree")
        sys.exit(1)
    
    identifier = sys.argv[1]
    force = "--force" in sys.argv or "-f" in sys.argv
    delete_branch = "--delete-branch" in sys.argv or "-d" in sys.argv
    
    # Get repo path if provided (last non-flag argument)
    repo_path = None
    for arg in reversed(sys.argv[2:]):
        if not arg.startswith("--") and not arg.startswith("-"):
            repo_path = arg
            break
    
    try:
        remove_worktree(identifier, force, delete_branch, repo_path)
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
