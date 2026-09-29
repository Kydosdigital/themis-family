#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT/apps/ios"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS compile check skipped: macOS/Xcode required."
  exit 0
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "ERROR: XcodeGen is required. Install it before validating the iOS project." >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: Xcode command-line tools are required." >&2
  exit 1
fi

pushd "$IOS_DIR" >/dev/null
xcodegen generate
xcodebuild   -project ThemisFamily.xcodeproj   -scheme ThemisFamily   -sdk iphonesimulator   -configuration Debug   CODE_SIGNING_ALLOWED=NO   build
popd >/dev/null

echo "iOS build verification passed."
