#!/usr/bin/env python3
import json
import re
import sys

def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    if payload.get("tool_name") != "Bash":
        return 0

    command = str((payload.get("tool_input") or {}).get("command", ""))
    dangerous = [
        (r"\bgit\s+reset\s+--hard\b", "git reset --hard can discard work"),
        (r"\bgit\s+clean\s+-[^\n]*(?:f[^\n]*d|d[^\n]*f)", "git clean -fd can delete untracked work"),
        (r"\bgit\s+push\b[^\n]*(?:--force-with-lease|--force|\s-f(?:\s|$))", "force-pushing rewrites shared history"),
        (r"\bgit\s+commit\s+--amend\b", "amending can rewrite a shared commit"),
        (r"\bgit\s+rebase\b", "rebasing can rewrite shared history"),
        (r"\bgit\s+checkout\s+--\s+\.\s*$", "checkout -- . can discard working-tree changes"),
        (r"\bgit\s+restore\s+\.\s*$", "git restore . can discard working-tree changes"),
        (r"\bgh\s+repo\s+delete\b", "repository deletion is not permitted"),
        (r"\brm\s+-rf\s+(?:/|\.|\.\.|\$CLAUDE_PROJECT_DIR)(?:\s|$)", "destructive recursive deletion is not permitted")
    ]

    for pattern, reason in dangerous:
        if re.search(pattern, command, flags=re.IGNORECASE):
            print(f"Blocked destructive command: {reason}. Use a non-destructive alternative.", file=sys.stderr)
            return 2
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
