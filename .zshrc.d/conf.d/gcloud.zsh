export USE_GKE_GCLOUD_AUTH_PLUGIN=True
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  source "$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
fi
