#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Claude workflow =="
python3 scripts/validate_claude_workflow.py

# Future application scaffolds add their checks here.
# Keep this command stable so the pre-commit hook has one verification entry point.

if [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
  if node -e 'const p=require("./package.json"); process.exit(p.scripts?.test ? 0 : 1)' 2>/dev/null; then
    echo "== npm test =="
    npm test
  fi
fi

echo "Verification passed."
