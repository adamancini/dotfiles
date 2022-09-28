# set up kubectl completion for zsh
kubectl() {
  command kubectl $*
  if [[ -z $KUBECTL_COMPLETE ]]; then
    source <(command kubectl completion zsh)
    KUBECTL_COMPLETE=1
  fi
}