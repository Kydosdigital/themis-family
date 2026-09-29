#!/usr/bin/env python3
import json
import os
import re
import sys
from pathlib import Path

TOOLS_WITH_PATHS = {"Read", "Write", "Edit", "MultiEdit", "NotebookEdit"}

SECRET_PATTERNS = [
    re.compile(r"(^|/)\.env(?:\..+)?$", re.IGNORECASE),
    re.compile(r"(^|/)AuthKey_[^/]+\.p8$", re.IGNORECASE),
    re.compile(r"\.(?:p8|p12|pem|key|mobileprovision|provisionprofile|cer)$", re.IGNORECASE),
    re.compile(r"(^|/)GoogleService-Info\.plist$", re.IGNORECASE),
]

ALLOW_PATTERNS = [
    re.compile(r"(^|/)\.env\.example$", re.IGNORECASE),
]

def is_secret_path(raw: str) -> bool:
    normal = raw.replace("\\", "/")
    if any(pattern.search(normal) for pattern in ALLOW_PATTERNS):
        return False
    return any(pattern.search(normal) for pattern in SECRET_PATTERNS)

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

def bash_mentions_secret(command: str) -> bool:
    # Block shell commands that appear to access secret-bearing filenames.
    # .env.example is explicitly allowed.
    sanitised = command.replace(".env.example", "")
    checks = [
        r"(^|[\s'\"/])\.env(?:\.[A-Za-z0-9_.-]+)?(?:[\s'\";|&]|$)",
        r"AuthKey_[^\s'\"]+\.p8",
        r"[^\s'\"]+\.(?:p8|p12|pem|key|mobileprovision|provisionprofile|cer)(?:[\s'\";|&]|$)",
        r"GoogleService-Info\.plist",
    ]
    return any(re.search(pattern, sanitised, flags=re.IGNORECASE) for pattern in checks)

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    tool = payload.get("tool_name")
    tool_input = payload.get("tool_input") or {}

    if tool in TOOLS_WITH_PATHS:
        for path in extract_paths(tool_input):
            if is_secret_path(path):
                print(
                    f"Blocked access to sensitive file: {path}. "
                    "Use documented environment variables, keychain/secret storage, or a redacted example file instead.",
                    file=sys.stderr,
                )
                return 2

    if tool == "Bash":
        command = str(tool_input.get("command", ""))
        if bash_mentions_secret(command):
            print(
                "Blocked shell command that appears to access a secret-bearing file. "
                "Do not read or print local credentials/signing material through Claude Code.",
                file=sys.stderr,
            )
            return 2

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
