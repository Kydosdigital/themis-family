#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/apps/web"
if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: Node.js 24 and npm are required to verify the website." >&2
  exit 1
fi
npm run verify
