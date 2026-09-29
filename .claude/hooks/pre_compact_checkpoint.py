#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

def run(project, *args):
    try:
        return subprocess.check_output(args, cwd=project, text=True, stderr=subprocess.STDOUT).strip()
    except Exception as exc:
        return f"<unavailable: {exc}>"

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    project = Path(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or ".").resolve()
    runtime = project / ".claude" / "runtime"
    runtime.mkdir(parents=True, exist_ok=True)

    state_path = project / "docs" / "implementation" / "CURRENT_STATE.md"
    state = state_path.read_text(encoding="utf-8") if state_path.exists() else "<missing>"

    checkpoint = f"""# Automatic pre-compaction checkpoint

Generated: {datetime.now(timezone.utc).isoformat()}
Trigger: {payload.get('trigger', 'unknown')}
Transcript: {payload.get('transcript_path', 'unknown')}

## Branch
{run(project, 'git', 'branch', '--show-current')}

## Git status
{run(project, 'git', 'status', '--short') or '<clean>'}

## Last commit
{run(project, 'git', 'log', '-1', '--oneline')}

## Implementation state
{state[:12000]}
"""
    (runtime / "precompact.md").write_text(checkpoint, encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
