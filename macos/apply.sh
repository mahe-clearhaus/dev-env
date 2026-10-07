#!/usr/bin/env bash
# Push the tracked macOS settings back onto this machine. Inverse of export.sh.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> App Shortcuts"
./app-shortcuts.sh

echo "==> System keyboard shortcuts"
HOTKEYS="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
if [ -f symbolichotkeys.plist ]; then
  if [ -f "$HOTKEYS" ]; then
    cp "$HOTKEYS" "$HOTKEYS.bak.$(date +%Y%m%d%H%M%S)"
    echo "    backed up existing plist"
  fi
  # Written as binary to match what macOS itself writes.
  plutil -convert binary1 -o "$HOTKEYS" symbolichotkeys.plist
  killall cfprefsd 2>/dev/null || true
  echo "    installed; log out and back in for it to take effect"
fi

echo
echo "Restart affected apps (or log out) to pick up the App Shortcuts."
echo "See README.md for the settings that cannot be scripted."
