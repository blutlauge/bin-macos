#!/usr/bin/env bash

echo -e "\\n\\nMacOS settings ..."

echo "Finder: Show filename extensions."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder: Show hidden files."
defaults write com.apple.Finder AppleShowAllFiles -bool false

echo "Expand save dialog."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

echo "Finder: Ѕhow the ~/Library folder."
chflags nohidden ~/Library

echo "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo "Automatically hide the Dock."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2

echo "Finder: Use current directory as default search scope."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Finder: Show Path bar."
defaults write com.apple.finder ShowPathbar -bool true

echo "Finder: Show Status bar."
defaults write com.apple.finder ShowStatusBar -bool true

echo "Expand print panel by default."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

echo "Set a blazingly fast keyboard repeat rate."
defaults write NSGlobalDomain KeyRepeat -int 2

echo "Set a shorter Delay until key repeat"
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "Disable auto-correction."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Avoid creating .DS_Store files on network volumes."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Empty Trash securely by default."
defaults write com.apple.finder EmptyTrashSecurely -bool true

echo "Enable tap to click (Trackpad)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

echo "Enable Safari’s debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

