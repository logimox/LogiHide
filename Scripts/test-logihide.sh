#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
swift test --package-path "$ROOT"
swift test --package-path "$ROOT/Vendor/DuoStatusKit"
