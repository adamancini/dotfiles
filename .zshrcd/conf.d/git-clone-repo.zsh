#!/usr/bin/env zsh

# shell function that will git clone a repo url and add it to $SRC_HOME
# based on the repo username and repo name, e.g. ~/src/github.com/username/repo
# usage: git-clone-repo <repo_url>
# example: git-clone-repo git@github.com:adamancini/dotfiles

# this function is meant to be sourced from your .bashrc or .bash_profile
# and aliased to a shorter command, e.g. alias gcr=git-clone-repo

# if $SRC_HOME is not set, it will default to ~/src/github.com
# if SRC_HOME does not exist, it will be created

git-clone-repo() {
  setopt local_options BASH_REMATCH
  setopt local_options KSH_ARRAYS
  local repo_url=$1
  local repo_username
  local repo_name
  local src_home=${SRC_HOME:-$HOME/src/github.com}

  # Check if SRC_HOME exists, create it if not
  if [[ ! -d $src_home ]]; then
    mkdir -p "$src_home"
  fi

  # Extract repo username and repo name from repo url
  # Support both SSH and HTTPS formats, with or without .git extension
  if [[ $repo_url =~ ^git@github.com:([^/]+)/(.+)(\.git)?$ ]]; then
    repo_username=${BASH_REMATCH[1]}
    repo_name=${BASH_REMATCH[2]%.git}  # Remove .git if present
    # echo "$repo_username/$repo_name"
  elif [[ $repo_url =~ ^https://github.com/([^/]+)/(.+)(\.git)?/?$ ]]; then
    repo_username=${BASH_REMATCH[1]}
    repo_name=${BASH_REMATCH[2]%.git}  # Remove .git if present
    # echo "$repo_username/$repo_name"
  else
    echo "Invalid git url: $repo_url"
    return 1
  fi

  # Clone the repo and add it to SRC_HOME
  echo "git clone $repo_url $src_home/$repo_username/$repo_name"
  git clone $repo_url $src_home/$repo_username/$repo_name
}
