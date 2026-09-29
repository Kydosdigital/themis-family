#!/usr/bin/env python3
import json
import os
import re
import sys
from pathlib import Path

WRITE_TOOLS = {"Write", "Edit", "MultiEdit", "NotebookEdit"}

def extract_paths(tool_input):
    paths = []
    for key in ("file_path", "path", "notebook_path"):
        value = tool_input.get(key)
        if isinstance(value, str):
            paths.append(value)
    edits = tool_input.get("edits")
    if isinstance(edits, list):
        for edit in edits:
            if isinstance(edit, dict):
                for key in ("file_path", "path"):
                    value = edit.get(key)
                    if isinstance(value, str):
                        paths.append(value)
    return paths

def normalise(project, raw):
    p = Path(raw)
    if not p.is_absolute():
        p = project / p
    try:
        return p.resolve().relative_to(project.resolve()).as_posix()
    except Exception:
        return p.resolve().as_posix()

def approved_doc_path(rel):
    return rel.startswith("docs/") and not rel.startswith("docs/implementation/")

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    if os.environ.get("THEMIS_SPEC_AMENDMENT") == "1":
        return 0

    project = Path(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or ".")
    tool = payload.get("tool_name")
    tool_input = payload.get("tool_input") or {}

    if tool in WRITE_TOOLS:
        for raw in extract_paths(tool_input):
            rel = normalise(project, raw)
            if approved_doc_path(rel):
                print(
                    "Approved requirements are frozen during implementation. "
                    f"Blocked write to {rel}. For an explicitly authorised specification amendment, "
                    "restart Claude Code with THEMIS_SPEC_AMENDMENT=1.",
                    file=sys.stderr,
                )
                return 2

    if tool == "Bash":
        command = str(tool_input.get("command", ""))
        write_markers = r"(?:>|>>|\btee\b|\bsed\s+-i\b|\bperl\s+-pi\b|\bcp\b|\bmv\b|write_text|writeFile|open\([^\n]*['\"]w)"
        if re.search(r"docs/(?!implementation/)", command) and re.search(write_markers, command, flags=re.IGNORECASE):
            print(
                "Approved requirements are frozen. Blocked a shell command that appears to modify docs/. "
                "Use docs/implementation/ for implementation records, or start an explicitly authorised "
                "spec-amendment session with THEMIS_SPEC_AMENDMENT=1.",
                file=sys.stderr,
            )
            return 2

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
