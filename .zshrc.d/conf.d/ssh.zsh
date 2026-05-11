# make prompt print 'ssh' when connected via ssh
settitle() {
  printf "\033k$1\033\\"
}

ssh() {
  settitle "$*"
  command ssh "$@"
  settitle "zsh"
}