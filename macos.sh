##############################
#        setup macOS         #
##############################

echo "Global Perferences"

# Disable smart dash/period/quote substitutions
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
# Disable automatic capitalization
defaults write -g NSAutomaticCapitalizationEnabled -bool false
# Using expanded "save panel" by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
# Increase window resize speed for Cocoa applications
defaults write -g NSWindowResizeTime -float 0.001
# Save to disk (not to iCloud) by default
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool true
# Jump to the spot that's clicked on the scroll bar
defaults write -g AppleScrollerPagingBehavior -bool true
# Prefer tabs when opening documents
defaults write -g AppleWindowTabbingMode -string always

echo "Dock"

# Set dock to auto-hide, and transparentize icons of hidden apps (⌘H)
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock showhidden -bool true

# Disable to show recents, and light-dot of running apps
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock show-process-indicators -bool false

# --- Unpin all apps
defaults write com.apple.dock persistent-apps -array ""

echo "Finder"

# Allow quitting via ⌘Q
defaults write com.apple.finder QuitMenuItem -bool true

# Disable warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show all files and their extensions
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar, and layout as multi-column
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string clmv

# Search in current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string SCcf

# --- Keep the desktop clean
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# Show directories first
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# New window use the $HOME path
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show metadata info, but not preview in info panel
defaults write com.apple.finder FXInfoPanesExpanded -dict MetaData -bool true Preview -bool false

echo "Trackpad"

# Enable trackpad tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Enable 3-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

echo "Activity Monitor"

# Sort by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string CPUUsage
defaults write com.apple.ActivityMonitor SortDirection -int 0

echo "Launch Services"

# Disable quarantine for downloaded apps
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Safari"

# For better privacy
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Disable auto open downloads
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Enable Develop Menu, Web Inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtras -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo "Universal Access"

# Set the cursor size
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5

echo "Screen Capture"

# --- Set the filename which screencaptures should be written
defaults write com.apple.screencapture name -string screenshot
defaults write com.apple.screencapture include-date -bool false

echo "Desktop Services"

# Avoid creating .DS_Store files on USB or network volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Disk Images"

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

echo "Crash Reporter"

# Disable crash reporter
defaults write com.apple.CrashReporter DialogType -string none

echo "AdLib"

# Disable personalized advertising
defaults com.apple.AdLib forceLimitAdTracking -bool true
defaults com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults com.apple.AdLib allowIdentifierForAdvertising -bool false

echo "Allow 'NOT safe' softwares"

sudo spctl --master-disable

echo "Power Manager"

sudo pmset -a displaysleep 15
sudo pmset -a sleep 20
sudo pmset -a disksleep 30

# Disable wake by network
sudo pmset -a womp 0
# Disable wake when power source (AC/battery) change
sudo pmset -a acwake 0
# Disable wake by other devices using the same iCloud id
sudo pmset -a proximitywake 0

# Disable TCP keepalive on sleeping, this will cause "Find My Mac" to be unavailable
sudo pmset -a tcpkeepalive 0
# Disable auto update, auto backup when sleeping
sudo pmset -a powernap 0

# Enable "full light - half light - off" screen transition, when going to sleep
sudo pmset -a halfdim 1
# Auto switch GPU for apps on battery, use separate GPU on charger
sudo pmset -b gpuswitch 2
sudo pmset -c gpuswitch 1

# Auto hibernate after a period of time of sleeping
sudo pmset -a standby 1
# High power (> `highstandbythreshold`), 2 hours hibernate
sudo pmset -a standbydelayhigh 7200
# Low power (< `highstandbythreshold`), 1 hour hibernate
sudo pmset -a standbydelaylow 3600
# Sync memory data to disk, and stop powering the memory when hibernating
sudo pmset -a hibernatemode 3
# `highstandbythreshold` defaults to 50%

echo "Xcode"

xcode-select --install

# how to reinstall:
# sudo rm -rf /Library/Developer/CommandLineTools
# xcode-select --install
