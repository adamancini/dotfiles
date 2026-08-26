#!/bin/bash
# Dispatches to pinentry-curses when PINENTRY_USER_DATA=curses (set by the
# `pass` zsh wrapper for interactive shell invocations), otherwise falls
# back to pinentry-mac (GUI dialog) for callers like the passff Firefox
# extension that don't set/inherit that env var.
if [ "$PINENTRY_USER_DATA" = "curses" ]; then
    exec /opt/homebrew/bin/pinentry-curses "$@"
else
    exec /opt/homebrew/bin/pinentry-mac "$@"
fi
