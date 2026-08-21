#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

swift build -c release

APP_NAME="Zwix"
BIN_PATH=".build/release/${APP_NAME}"
BUNDLE="dist/${APP_NAME}.app"

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"

cp "$BIN_PATH" "$BUNDLE/Contents/MacOS/${APP_NAME}"
cp Info.plist.template "$BUNDLE/Contents/Info.plist"

if [ -f "Sources/${APP_NAME}/Resources/AppIcon.icns" ]; then
    cp "Sources/${APP_NAME}/Resources/AppIcon.icns" "$BUNDLE/Contents/Resources/"
fi

codesign --force --deep --sign - "$BUNDLE"

echo "Built: $BUNDLE"
echo "Run:   open \"$BUNDLE\""
