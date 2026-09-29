#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path

def run(project: Path, args, check=True):
    return subprocess.run(
        args,
        cwd=project,
        text=True,
        capture_output=True,
        check=check,
    )

def field(text: str, name: str) -> str:
    prefix = name + ":"
    for line in text.splitlines():
        if line.startswith(prefix):
            return line[len(prefix):].strip()
    return ""

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    if payload.get("tool_name") != "Bash":
        return 0

    command = str((payload.get("tool_input") or {}).get("command", ""))
    if "git commit" not in command:
        return 0

    project = Path(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or ".").resolve()
    state_path = project / "docs" / "implementation" / "CURRENT_STATE.md"

    if not state_path.exists():
        print("Commit blocked: docs/implementation/CURRENT_STATE.md is missing.", file=sys.stderr)
        return 2

    state = state_path.read_text(encoding="utf-8")
    status = field(state, "Status").upper()
    verification = field(state, "Last verification")

    if status == "IN_PROGRESS":
        print(
            "Commit blocked: CURRENT_STATE is still IN_PROGRESS. "
            "Finish verification and mark the bounded task COMPLETE, or BLOCKED if it cannot finish.",
            file=sys.stderr,
        )
        return 2

    if status == "COMPLETE" and not verification:
        print(
            "Commit blocked: task is COMPLETE but Last verification is empty.",
            file=sys.stderr,
        )
        return 2

    staged = run(project, ["git", "diff", "--cached", "--name-only"]).stdout.splitlines()
    if not staged:
        print("Commit blocked: no staged files.", file=sys.stderr)
        return 2

    forbidden = []
    for path in staged:
        lower = path.lower()
        name = Path(path).name.lower()
        if name.startswith(".env") and name != ".env.example":
            forbidden.append(path)
        if lower.endswith((".p8", ".p12", ".pem", ".key", ".mobileprovision", ".provisionprofile", ".cer")):
            forbidden.append(path)
        if name == "googleservice-info.plist":
            forbidden.append(path)
        if path == ".claude/settings.local.json" or path.startswith(".claude/runtime/"):
            forbidden.append(path)

    if forbidden:
        print("Commit blocked: sensitive/local files are staged: " + ", ".join(forbidden), file=sys.stderr)
        return 2

    if os.environ.get("THEMIS_SPEC_AMENDMENT") != "1":
        spec_changes = [
            path for path in staged
            if path.startswith("docs/") and not path.startswith("docs/implementation/")
        ]
        if spec_changes:
            print(
                "Commit blocked: approved specification files are staged during a normal implementation session: "
                + ", ".join(spec_changes),
                file=sys.stderr,
            )
            return 2

    verify = run(project, ["bash", "scripts/verify.sh"], check=False)
    if verify.returncode != 0:
        print("Commit blocked: scripts/verify.sh failed.", file=sys.stderr)
        if verify.stdout:
            print(verify.stdout, file=sys.stderr)
        if verify.stderr:
            print(verify.stderr, file=sys.stderr)
        return 2

    print("Pre-commit verification passed.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
