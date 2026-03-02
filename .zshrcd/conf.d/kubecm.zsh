# kubecm - kubeconfig manager
export KUBECM_DISABLE_K8S_MORE_INFO=true

# Completion is loaded after compinit via .zshrc post-compinit hook
_kubecm_setup_completion() {
    if command -v kubecm >/dev/null 2>&1; then
        source <(kubecm completion zsh)
    fi
}
