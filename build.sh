#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Building Elsewhere..."
swift build -c release

APP_DIR="Elsewhere.app/Contents/MacOS"
mkdir -p "$APP_DIR"

cp .build/release/Elsewhere "$APP_DIR/Elsewhere"
cp Resources/Info.plist Elsewhere.app/Contents/Info.plist

echo "Built: $(pwd)/Elsewhere.app"
