#!/usr/bin/env zsh

# Create and manage git worktrees in .worktrees/ subdirectory of the repo root.
# Keeps worktrees colocated with the repo for easy navigation and Claude Code invocation.
#
# Usage:
#   gwt <branch-name>        Create a worktree for <branch-name> at .worktrees/<branch-name>
#   gwt -l                   List worktrees
#   gwt -d <branch-name>     Remove a worktree and optionally delete the branch
#
# Examples:
#   gwt feat-new-api         Creates .worktrees/feat-new-api with a new branch
#   gwt -d feat-new-api      Removes the worktree and prompts to delete the branch
#   cd .worktrees/feat-*<TAB> Tab-complete into worktrees

gwt() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "error: not inside a git repository" >&2
    return 1
  fi

  local worktree_dir="$repo_root/.worktrees"

  # Handle flags
  case "$1" in
    -l|--list)
      git -C "$repo_root" worktree list
      return $?
      ;;
    -d|--delete)
      if [[ -z "$2" ]]; then
        echo "usage: gwt -d <branch-name>" >&2
        return 1
      fi
      local target="$worktree_dir/$2"
      if [[ ! -d "$target" ]]; then
        echo "error: worktree not found: $target" >&2
        return 1
      fi
      git -C "$repo_root" worktree remove "$target"
      if [[ $? -eq 0 ]]; then
        echo "removed worktree: $target"
        echo -n "delete branch '$2'? [y/N] "
        read -r reply
        if [[ "$reply" =~ ^[Yy]$ ]]; then
          git -C "$repo_root" branch -d "$2" 2>/dev/null || \
            git -C "$repo_root" branch -D "$2"
        fi
      fi
      return $?
      ;;
    -h|--help)
      echo "usage: gwt <branch-name>       create worktree"
      echo "       gwt -l                  list worktrees"
      echo "       gwt -d <branch-name>    remove worktree"
      return 0
      ;;
  esac

  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: gwt <branch-name>" >&2
    echo "       gwt -l | -d <branch> | -h" >&2
    return 1
  fi

  local wt_path="$worktree_dir/$branch"

  # Ensure .worktrees is gitignored
  local gitignore="$repo_root/.gitignore"
  if [[ ! -f "$gitignore" ]] || ! grep -qxF '.worktrees' "$gitignore"; then
    echo '.worktrees' >> "$gitignore"
    echo "added .worktrees to $gitignore"
  fi

  # Create the worktree directory
  mkdir -p "$worktree_dir"

  # Check if branch already exists locally or on remote
  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    # Branch exists locally, check it out as a worktree
    git -C "$repo_root" worktree add "$wt_path" "$branch"
  elif git -C "$repo_root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    # Branch exists on remote, track it
    git -C "$repo_root" worktree add --track -b "$branch" "$wt_path" "origin/$branch"
  else
    # New branch, create from current HEAD
    git -C "$repo_root" worktree add -b "$branch" "$wt_path"
  fi

  if [[ $? -ne 0 ]]; then
    echo "error: failed to create worktree" >&2
    return 1
  fi

  echo ""
  echo "worktree ready: $wt_path"
  echo "  cd $wt_path"
}
