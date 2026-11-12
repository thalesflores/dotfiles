#!/bin/bash
# macOS system settings (keyboard, trackpad, Dock, Finder), the ones changed from the defaults.
# Safe to re-run. Some of them (dark mode, keyboard) only apply after logging out and in again.
set -euo pipefail

echo "Applying macOS settings"

# Keyboard: fast key repeat with a short delay before it starts
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Dark mode
defaults write -g AppleInterfaceStyle -string Dark

# Trackpad: tap to click, no natural scrolling, a bit faster pointer
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g com.apple.trackpad.scaling -float 1.5

# Dock: auto-hide, small icons with magnification, no recent apps, no launch animation,
# minimize into the app icon and no action on the bottom-right hot corner
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 96
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock wvous-br-corner -int 1

# Finder: list view by default
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv

killall Dock Finder 2>/dev/null || true

echo "macOS settings applied, log out and in again to apply all of them"
