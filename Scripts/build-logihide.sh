#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED="${DERIVED:-$ROOT/build}"
xcodebuild -project "$ROOT/holzBar.xcodeproj" -scheme LogiHide \
    -configuration Release -destination 'platform=macOS' -derivedDataPath "$DERIVED" \
    CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= \
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO build
"$ROOT/Scripts/check-signature.sh" "$DERIVED/Build/Products/Release/LogiHide.app"
echo "Built: $DERIVED/Build/Products/Release/LogiHide.app"
