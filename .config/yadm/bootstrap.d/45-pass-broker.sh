#!/bin/bash
#
# Phase 45: pass-broker LaunchAgent (macOS only)
# Installs and (re)loads the launchd agent that runs ~/bin/pass-broker,
# which gives Claude per-entry, dialog-approved access to the password store.
#

set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || { echo "[INFO] pass-broker: not macOS, skipping"; exit 0; }

label="net.annarchy.pass-broker"
plist="$HOME/Library/LaunchAgents/$label.plist"
state="$HOME/.local/state/pass-broker"

mkdir -p "$HOME/Library/LaunchAgents"
mkdir -m 700 -p "$state"
chmod 755 "$HOME/bin/pass-broker" "$HOME/bin/pass-exec"

cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$label</string>
    <key>ProgramArguments</key>
    <array><string>$HOME/bin/pass-broker</string></array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>ProcessType</key><string>Interactive</string>
    <key>StandardErrorPath</key><string>$state/broker.err</string>
</dict>
</plist>
EOF

domain="gui/$(id -u)"
launchctl bootout "$domain/$label" 2>/dev/null || true
launchctl bootstrap "$domain" "$plist"
echo "[✓] pass-broker LaunchAgent loaded ($label)"
