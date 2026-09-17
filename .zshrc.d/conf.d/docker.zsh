(( $+commands[docker] )) || return 0

export DOCKER_DEFAULT_PLATFORM=linux/amd64
export DOCKER_BUILDKIT=1
