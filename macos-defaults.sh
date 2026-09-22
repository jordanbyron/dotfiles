#!/usr/bin/env bash
#
# macOS system preferences worth setting on a new Mac.  Safe to re-run.
#
#   ./macos-defaults.sh
#
# Some settings need a logout (or the restarts at the bottom) to take effect.

set -euo pipefail

echo "Applying macOS defaults…"

# --- Keyboard -------------------------------------------------------------
# Fast key repeat.  KeyRepeat is the repeat rate, InitialKeyRepeat the delay
# before repeating starts; both are in 15ms ticks and go lower than the
# System Settings sliders allow.
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Hold a key to repeat it instead of showing the accent picker (needed for
# vim-style navigation in any app).
defaults write -g ApplePressAndHoldEnabled -bool false

# No autocorrect / smart quotes / smart dashes — they mangle code.
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# --- Trackpad -------------------------------------------------------------
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write -g com.apple.mouse.tapBehavior -int 1

# --- Appearance -----------------------------------------------------------
defaults write -g AppleInterfaceStyle -string "Dark"

# --- Finder ---------------------------------------------------------------
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"   # icon view
# Search the current folder by default rather than the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Don't litter network shares and USB drives with .DS_Store files.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Dock -----------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock show-recents -bool false

# --- Screenshots ----------------------------------------------------------
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Terminal -------------------------------------------------------------
# Import the exported profile (unless it's already there) and make it the
# default.  The default is set through Terminal itself: `defaults write` gets
# overwritten when a running Terminal quits.
TERMINAL_PROFILE="Jordan"
PROFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terminal/$TERMINAL_PROFILE.terminal"
has_profile() {
  osascript -e "tell application \"Terminal\" to exists settings set \"$TERMINAL_PROFILE\"" 2>/dev/null |
    grep -q true
}
if [ -f "$PROFILE" ]; then
  if ! has_profile; then
    open "$PROFILE"  # imports it and opens a window with it
    for _ in 1 2 3 4 5 6 7 8 9 10; do has_profile && break; sleep 1; done
  fi
  osascript -e "tell application \"Terminal\"
    set default settings to settings set \"$TERMINAL_PROFILE\"
    set startup settings to settings set \"$TERMINAL_PROFILE\"
  end tell" >/dev/null || echo "set the $TERMINAL_PROFILE profile as default in Terminal → Settings → Profiles"
fi

echo "Restarting affected apps…"
for app in Dock Finder SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

echo "Done.  Log out and back in for the keyboard settings to fully apply."
