# pass (password-store) wrapper: force pinentry-curses (ncurses TUI) for
# interactive shell invocations of `pass`, instead of the pinentry-mac GUI
# dialog. gpg-agent's pinentry-wrapper.sh (see ~/.gnupg/gpg-agent.conf)
# inspects PINENTRY_USER_DATA and dispatches accordingly. This only affects
# `pass` run from an interactive shell -- the passff Firefox extension
# invokes gpg via its own native-messaging host process. Caveat: if this
# wrapper is what auto-starts gpg-agent, the agent keeps
# PINENTRY_USER_DATA=curses as its default for clients that don't send one,
# so passff.py sets PINENTRY_USER_DATA=mac explicitly to override it.

# pinentry-curses needs to know which terminal to draw on; without GPG_TTY
# gpg-agent launches it with no tty and it fails with
# "Screen or window too small".
export GPG_TTY=$TTY

pass() {
    PINENTRY_USER_DATA=curses command pass "$@"
}
