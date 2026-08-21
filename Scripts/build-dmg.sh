#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v create-dmg >/dev/null 2>&1; then
    echo "create-dmg not found. Install with: brew install create-dmg" >&2
    exit 1
fi

APP_NAME="Zwix"
VERSION="${1:-0.1.0}"
APP_BUNDLE="dist/${APP_NAME}.app"
DMG_PATH="dist/${APP_NAME}-${VERSION}.dmg"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Building ${APP_NAME}.app first..."
    ./Scripts/build-app.sh
fi

rm -f "$DMG_PATH"

create-dmg \
    --volname "${APP_NAME}" \
    --window-pos 200 120 \
    --window-size 660 400 \
    --icon-size 128 \
    --icon "${APP_NAME}.app" 180 190 \
    --hide-extension "${APP_NAME}.app" \
    --app-drop-link 480 190 \
    "$DMG_PATH" \
    "$APP_BUNDLE"

echo "Built: $DMG_PATH"
