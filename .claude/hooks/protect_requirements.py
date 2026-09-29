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

def shell_looks_like_spec_write(command):
    patterns = [
        r"(?:>|>>)\s*docs/(?!implementation/)",
        r"\btee\b[^\n]*\sdocs/(?!implementation/)",
        r"\bsed\s+-i\b[^\n]*docs/(?!implementation/)",
        r"\bperl\s+-pi\b[^\n]*docs/(?!implementation/)",
        r"\b(?:cp|mv)\b[^\n]*\sdocs/(?!implementation/)",
        r"write_text\([^\n]*docs/(?!implementation/)",
        r"writeFile[^\n]*docs/(?!implementation/)"
    ]
    return any(re.search(pattern, command, flags=re.IGNORECASE) for pattern in patterns)

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
        if shell_looks_like_spec_write(command):
            print(
                "Approved requirements are frozen. Blocked a shell command that appears to write into docs/. "
                "Use docs/implementation/ for implementation records, or start an explicitly authorised "
                "spec-amendment session with THEMIS_SPEC_AMENDMENT=1.",
                file=sys.stderr,
            )
            return 2

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
