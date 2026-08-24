#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

./Scripts/build-app.sh

APP_NAME="Zwix"
DEST="/Applications/${APP_NAME}.app"

pkill -f "${DEST}/Contents/MacOS/${APP_NAME}" 2>/dev/null || true

rm -rf "$DEST"
cp -R "dist/${APP_NAME}.app" "$DEST"

open "$DEST"

echo "Installed: $DEST"
