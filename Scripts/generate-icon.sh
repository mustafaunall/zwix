#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TMP_DIR=$(mktemp -d)
ICONSET="$TMP_DIR/AppIcon.iconset"
mkdir -p "$ICONSET"

swift Scripts/render-icon.swift "$TMP_DIR/base.png"

declare -a sizes=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png"
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

for entry in "${sizes[@]}"; do
    px="${entry%%:*}"
    name="${entry##*:}"
    sips -z "$px" "$px" "$TMP_DIR/base.png" --out "$ICONSET/$name" >/dev/null
done

mkdir -p Sources/Zwix/Resources
iconutil -c icns "$ICONSET" -o Sources/Zwix/Resources/AppIcon.icns

rm -rf "$TMP_DIR"
echo "Wrote Sources/Zwix/Resources/AppIcon.icns"
