#!/usr/bin/env zsh

# shell function that will git clone a repo url and add it to $SRC_HOME
# based on the domain, username, and repo name, e.g. ~/src/domain.com/username/repo
# usage: git-clone-repo [--cd] <repo_url>
# examples:
#   git-clone-repo git@github.com:adamancini/dotfiles
#   git-clone-repo https://github.com/adamancini/dotfiles.git
#   git-clone-repo --cd git@gitlab.com:username/project.git

# this function is meant to be sourced from your .zshrc
# and aliased to a shorter command, e.g. alias gcr=git-clone-repo

# if $SRC_HOME is not set, it will default to ~/src
# the directory structure will be $SRC_HOME/domain/username/repo

git-clone-repo() {
  setopt local_options BASH_REMATCH
  setopt local_options KSH_ARRAYS
  local change_dir=false
  local repo_url
  local repo_domain
  local repo_username
  local repo_name
  local src_home=${SRC_HOME:-$HOME/src}

  # Parse options
  while [[ $# -gt 0 ]]; do
    case $1 in
      --cd) change_dir=true; shift ;;
      -*) echo "Unknown option: $1"; return 1 ;;
      *) repo_url=$1; shift ;;
    esac
  done

  if [[ -z $repo_url ]]; then
    echo "Usage: git-clone-repo [--cd] <repo_url>"
    return 1
  fi

  # Extract domain, username, and repo name from repo url
  # Support both SSH and HTTPS formats, with or without .git extension
  if [[ $repo_url =~ ^git@([^:]+):([^/]+)/(.+)(\.git)?$ ]]; then
    # SSH format: git@domain:username/repo.git
    repo_domain=${BASH_REMATCH[1]}
    repo_username=${BASH_REMATCH[2]}
    repo_name=${BASH_REMATCH[3]%.git}  # Remove .git if present
  elif [[ $repo_url =~ ^https://([^/]+)/([^/]+)/(.+)(\.git)?/?$ ]]; then
    # HTTPS format: https://domain/username/repo.git
    repo_domain=${BASH_REMATCH[1]}
    repo_username=${BASH_REMATCH[2]}
    repo_name=${BASH_REMATCH[3]%.git}  # Remove .git if present
  else
    echo "Invalid git url: $repo_url"
    echo "Supported formats:"
    echo "  SSH:   git@domain:username/repo.git"
    echo "  HTTPS: https://domain/username/repo.git"
    return 1
  fi

  # Construct the destination path
  local dest_path="$src_home/$repo_domain/$repo_username/$repo_name"

  # Check if destination directory exists
  if [[ -d $dest_path ]]; then
    echo "Directory already exists: $dest_path"
    return 1
  fi

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$dest_path")"

  # Clone the repo and add it to SRC_HOME
  echo "git clone $repo_url $dest_path"
  git clone $repo_url $dest_path || return 1

  if $change_dir; then
    cd "$dest_path"
  fi
}
