#!/usr/bin/env python3
"""Validate the committed Claude Code operating layer without external dependencies."""

from __future__ import annotations

import json
import os
import py_compile
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "CLAUDE.md",
    ".mcp.json",
    ".env.example",
    "README.md",
    ".claude/settings.json",
    ".claude/hooks/block_destructive.py",
    ".claude/hooks/protect_requirements.py",
    ".claude/hooks/protect_secrets.py",
    ".claude/hooks/verify_before_commit.py",
    ".claude/hooks/after_edit_check.py",
    ".claude/hooks/pre_compact_checkpoint.py",
    ".claude/hooks/session_start_context.py",
    ".claude/hooks/stop_quality_gate.py",
    ".claude/rules/requirements-first.md",
    ".claude/rules/architecture.md",
    ".claude/rules/ios.md",
    ".claude/rules/swiftui.md",
    ".claude/rules/design-system.md",
    ".claude/rules/backend.md",
    ".claude/rules/database.md",
    ".claude/rules/testing.md",
    ".claude/rules/security.md",
    ".claude/rules/git-workflow.md",
    ".claude/agents/architect.md",
    ".claude/agents/ios-engineer.md",
    ".claude/agents/backend-engineer.md",
    ".claude/agents/code-reviewer.md",
    ".claude/agents/security-reviewer.md",
    ".claude/agents/qa-reviewer.md",
    ".claude/skills/build-slice/SKILL.md",
    ".claude/skills/spike/SKILL.md",
    ".claude/skills/verify/SKILL.md",
    ".claude/skills/review-diff/SKILL.md",
    ".claude/skills/review-feature/SKILL.md",
    ".claude/skills/database-change/SKILL.md",
    ".claude/skills/close-task/SKILL.md",
    "docs/implementation/CURRENT_STATE.md",
    "docs/implementation/BUILD_LOG.md",
    "docs/implementation/SPIKE_RESULTS.md",
    "docs/implementation/IMPLEMENTATION_DECISIONS.md",
    "supabase/README.md",
    "supabase/seed.sql",
    "apps/ios/README.md",
    "scripts/verify.sh",
    "scripts/verify_ios.sh",
]

def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)

def run_hook(relative: str, payload: dict, expected: int, extra_env=None) -> None:
    env = os.environ.copy()
    env["CLAUDE_PROJECT_DIR"] = str(ROOT)
    if extra_env:
        env.update(extra_env)
    proc = subprocess.run(
        [sys.executable, str(ROOT / relative)],
        input=json.dumps(payload),
        text=True,
        capture_output=True,
        env=env,
    )
    if proc.returncode != expected:
        fail(
            f"{relative} returned {proc.returncode}, expected {expected}. "
            f"stdout={proc.stdout!r} stderr={proc.stderr!r}"
        )

def main() -> None:
    missing = [path for path in REQUIRED if not (ROOT / path).exists()]
    if missing:
        fail("Missing required workflow files: " + ", ".join(missing))

    for json_path in [ROOT / ".claude/settings.json", ROOT / ".mcp.json"]:
        try:
            json.loads(json_path.read_text(encoding="utf-8"))
        except Exception as exc:
            fail(f"Invalid JSON {json_path}: {exc}")

    for hook in (ROOT / ".claude/hooks").glob("*.py"):
        try:
            py_compile.compile(str(hook), doraise=True)
        except Exception as exc:
            fail(f"Hook does not compile: {hook}: {exc}")

    baseline = "06327979dfe9cf1c1521a5def1df8095a4b222ed"
    claude_md = (ROOT / "CLAUDE.md").read_text(encoding="utf-8")
    if baseline not in claude_md:
        fail("CLAUDE.md does not reference the approved requirements baseline")

    run_hook(
        ".claude/hooks/block_destructive.py",
        {"tool_name": "Bash", "tool_input": {"command": "git status"}, "cwd": str(ROOT)},
        0,
    )
    run_hook(
        ".claude/hooks/block_destructive.py",
        {"tool_name": "Bash", "tool_input": {"command": "git reset --hard HEAD~1"}, "cwd": str(ROOT)},
        2,
    )

    run_hook(
        ".claude/hooks/protect_requirements.py",
        {"tool_name": "Write", "tool_input": {"file_path": "docs/00_PRODUCT_OVERVIEW.md"}, "cwd": str(ROOT)},
        2,
    )
    run_hook(
        ".claude/hooks/protect_requirements.py",
        {"tool_name": "Write", "tool_input": {"file_path": "docs/implementation/test.md"}, "cwd": str(ROOT)},
        0,
    )
    run_hook(
        ".claude/hooks/protect_requirements.py",
        {"tool_name": "Bash", "tool_input": {"command": "cat docs/00_PRODUCT_OVERVIEW.md > /tmp/themis-doc.txt"}, "cwd": str(ROOT)},
        0,
    )
    run_hook(
        ".claude/hooks/protect_requirements.py",
        {"tool_name": "Bash", "tool_input": {"command": "echo change > docs/00_PRODUCT_OVERVIEW.md"}, "cwd": str(ROOT)},
        2,
    )

    run_hook(
        ".claude/hooks/protect_secrets.py",
        {"tool_name": "Read", "tool_input": {"file_path": ".env.local"}, "cwd": str(ROOT)},
        2,
    )
    run_hook(
        ".claude/hooks/protect_secrets.py",
        {"tool_name": "Read", "tool_input": {"file_path": ".env.example"}, "cwd": str(ROOT)},
        0,
    )
    run_hook(
        ".claude/hooks/protect_secrets.py",
        {"tool_name": "Bash", "tool_input": {"command": "cat AuthKey_ABC123.p8"}, "cwd": str(ROOT)},
        2,
    )

    run_hook(
        ".claude/hooks/stop_quality_gate.py",
        {"hook_event_name": "Stop", "stop_hook_active": False, "cwd": str(ROOT)},
        0,
    )

    mcp = json.loads((ROOT / ".mcp.json").read_text(encoding="utf-8"))
    supabase = mcp.get("mcpServers", {}).get("supabase", {})
    url = supabase.get("url", "")
    if "project_ref=${SUPABASE_PROJECT_REF}" not in url:
        fail("Supabase MCP must remain project-scoped through SUPABASE_PROJECT_REF")
    if "features=" not in url:
        fail("Supabase MCP must explicitly restrict feature groups")

    print("Claude Code workflow validation passed.")

if __name__ == "__main__":
    main()
