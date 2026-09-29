#!/usr/bin/env python3
import json
import os
import py_compile
import sys
from pathlib import Path

def extract_path(tool_input):
    for key in ("file_path", "path", "notebook_path"):
        value = tool_input.get(key)
        if isinstance(value, str):
            return value
    return None

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    raw = extract_path(payload.get("tool_input") or {})
    if not raw:
        return 0

    project = Path(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd") or ".")
    path = Path(raw)
    if not path.is_absolute():
        path = project / path

    if not path.exists() or not path.is_file():
        return 0

    try:
        if path.suffix == ".json":
            json.loads(path.read_text(encoding="utf-8"))
        if path.suffix == ".py" and ".claude/hooks" in path.as_posix():
            py_compile.compile(str(path), doraise=True)
    except Exception as exc:
        print(f"Post-edit validation failed for {path}: {exc}", file=sys.stderr)
        return 2
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
