# kubecm - kubeconfig manager
export KUBECM_DISABLE_K8S_MORE_INFO=true

if command -v kubecm >/dev/null 2>&1; then
    source <(kubecm completion zsh)
fi
