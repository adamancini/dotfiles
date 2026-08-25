# pass (password-store) wrapper: force pinentry-curses (ncurses TUI) for
# interactive shell invocations of `pass`, instead of the pinentry-mac GUI
# dialog. gpg-agent's pinentry-wrapper.sh (see ~/.gnupg/gpg-agent.conf)
# inspects PINENTRY_USER_DATA and dispatches accordingly. This only affects
# `pass` run from an interactive shell -- the passff Firefox extension
# invokes gpg via its own native-messaging host process and does not
# inherit this shell function or its exported env var, so it still gets
# the GUI pinentry-mac prompt.
pass() {
    PINENTRY_USER_DATA=curses command pass "$@"
}
