#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path

def run(project, *args):
    try:
        return subprocess.check_output(args, cwd=project, text=True, stderr=subprocess.STDOUT).strip()
    except Exception:
        return "<unavailable>"

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    project = Path(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or ".").resolve()
    state_path = project / "docs" / "implementation" / "CURRENT_STATE.md"
    state = state_path.read_text(encoding="utf-8") if state_path.exists() else "<CURRENT_STATE missing>"

    checkpoint_path = project / ".claude" / "runtime" / "precompact.md"
    checkpoint_note = ""
    if checkpoint_path.exists():
        checkpoint_note = "\nA pre-compaction checkpoint exists at .claude/runtime/precompact.md. Read it if continuation details are needed."

    print(f"""THEMIS SESSION CONTEXT
Requirements baseline: 06327979dfe9cf1c1521a5def1df8095a4b222ed
Implementation authorisation: foundation engineering approved.
Production enforcement: still gated by entitlement and real-device spikes.

Branch: {run(project, 'git', 'branch', '--show-current')}
Last commit: {run(project, 'git', 'log', '-1', '--oneline')}
Working tree:
{run(project, 'git', 'status', '--short') or '<clean>'}

CURRENT_STATE:
{state[:10000]}
{checkpoint_note}
""")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
