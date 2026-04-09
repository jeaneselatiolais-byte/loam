#!/bin/bash

# Script to increment build number automatically on each build
# This script should be run as a Build Phase in Xcode

set -e

# Get build counter from plist
BUILD_COUNTER="${SRCROOT}/BuildCounter.plist"

# Create or read build counter
if [ ! -f "$BUILD_COUNTER" ]; then
    # Create new plist with initial build number
    defaults write "$BUILD_COUNTER" CFBundleVersion -int 1
    CURRENT_BUILD=1
else
    # Read current build number
    CURRENT_BUILD=$(defaults read "$BUILD_COUNTER" CFBundleVersion 2>/dev/null || echo "0")
fi

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

# Write new build number to BuildCounter.plist
defaults write "$BUILD_COUNTER" CFBundleVersion -int "$NEW_BUILD"

# Now update Xcode's build settings (if we have access to it)
# This updates the version in the actual build
if [ -n "$INFOPLIST_FILE" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$SRCROOT/$INFOPLIST_FILE" 2>/dev/null || true
fi

echo "✅ Build number incremented: $CURRENT_BUILD → $NEW_BUILD"
