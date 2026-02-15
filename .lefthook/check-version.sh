#!/bin/bash
# Check if local Flutter version matches project requirements

set -e

VERSION_FILE=".flutter-version"

if [ ! -f "$VERSION_FILE" ]; then
    echo "⚠️  .flutter-version file not found"
    exit 0
fi

REQUIRED_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
CURRENT_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')

if [ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]; then
    echo "⚠️  Flutter version mismatch!"
    echo "   Required: $REQUIRED_VERSION"
    echo "   Current:  $CURRENT_VERSION"
    echo "💡 Run: flutter version $REQUIRED_VERSION"
    exit 1
fi

exit 0
