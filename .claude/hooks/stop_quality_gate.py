#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path

def git_dirty(project):
    try:
        out = subprocess.check_output(["git", "status", "--porcelain"], cwd=project, text=True)
        return bool(out.strip())
    except Exception:
        return False

def field(text, name):
    prefix = name + ":"
    for line in text.splitlines():
        if line.startswith(prefix):
            return line[len(prefix):].strip()
    return ""

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    if payload.get("stop_hook_active"):
        return 0

    project = Path(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or ".").resolve()
    state_path = project / "docs" / "implementation" / "CURRENT_STATE.md"
    if not state_path.exists():
        return 0

    state = state_path.read_text(encoding="utf-8")
    status = field(state, "Status").upper()
    commit_required = field(state, "Commit required").upper() == "YES"
    verification = field(state, "Last verification")

    if status == "IN_PROGRESS":
        print(
            "The active implementation task is still marked IN_PROGRESS. "
            "Do not stop yet. Re-read docs/implementation/CURRENT_STATE.md, continue the next recorded action, "
            "run verification, then mark the task COMPLETE or BLOCKED with a concrete reason.",
            file=sys.stderr,
        )
        return 2

    if status == "COMPLETE" and not verification:
        print(
            "The task is marked COMPLETE but Last verification is empty. "
            "Run the applicable checks and record the result in CURRENT_STATE.md before stopping.",
            file=sys.stderr,
        )
        return 2

    if status == "COMPLETE" and commit_required and git_dirty(project):
        print(
            "The task is marked COMPLETE and requires a commit, but the working tree is still dirty. "
            "Review the diff, commit the verified task, update CURRENT_STATE.md with the commit, then stop.",
            file=sys.stderr,
        )
        return 2

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
