#!/bin/bash
# Install the verified build in the location macOS 27's menu-bar allowlist resolves.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="${DERIVED:-$ROOT/build}/Build/Products/Release/LogiHide.app"
DEST=/Applications/LogiHide.app
[ -d "$APP" ] || { echo "Run Scripts/build-logihide.sh first." >&2; exit 1; }
if pgrep -x LogiHide >/dev/null; then
    echo "Quit LogiHide before installing this build." >&2
    exit 1
fi
"$ROOT/Scripts/check-signature.sh" "$APP"
if [ -e "$DEST" ]; then
    ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DEST/Contents/Info.plist")
    [ "$ID" = com.logimox.LogiHide ] || { echo "The destination is another application." >&2; exit 1; }
    BACKUP="$ROOT/build/previous/$(date +%Y%m%d-%H%M%S)/LogiHide.app"
    mkdir -p "$(dirname "$BACKUP")"
    mv "$DEST" "$BACKUP"
fi
ditto "$APP" "$DEST"
codesign --verify --deep --strict "$DEST"
REG=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$REG" -u "$APP" || true
"$REG" -f "$DEST"
open "$DEST"
echo "Installed: $DEST"
