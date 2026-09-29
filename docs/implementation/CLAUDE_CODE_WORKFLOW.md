# Claude Code Workflow for Themis Family

This repository includes a committed Claude Code operating layer. Its purpose is to keep long implementation sessions requirement-aware, verifiable and resumable.

## What is committed

- `CLAUDE.md`: always-on project instructions
- `.claude/settings.json`: shared permissions and hooks
- `.claude/rules/`: focused project rules
- `.claude/hooks/`: deterministic lifecycle guardrails
- `.claude/agents/`: specialist project subagents
- `.claude/skills/`: reusable implementation workflows
- `docs/implementation/`: persistent implementation state and evidence

Local-only Claude settings and runtime checkpoints are ignored by Git.

## First local validation

After pulling the repository on the machine where Claude Code will run:

1. Confirm Python 3 is available:
   `python3 --version`
2. Validate the settings JSON:
   `python3 -m json.tool .claude/settings.json >/dev/null`
3. Compile the hook scripts:
   `python3 -m py_compile .claude/hooks/*.py`
4. Start Claude Code from the repository root.
5. Open `/hooks` and review/approve the project hooks if Claude Code requests it.
6. Confirm the SessionStart context includes the requirements baseline and CURRENT_STATE.
7. Use `/status` or the current Claude Code status surface to confirm project settings are loaded.

Do not disable the hooks simply to make a task easier.

## Normal implementation flow

Use the `build-slice` skill for a bounded implementation slice.

The active task must be represented in `docs/implementation/CURRENT_STATE.md`.

The Stop hook prevents a session from quietly ending while CURRENT_STATE is still IN_PROGRESS.

The PreCompact hook writes a local checkpoint to `.claude/runtime/precompact.md`, and SessionStart re-injects current repository/task context after startup, resume or compaction.

## Requirements protection

Approved specification files under `docs/` are frozen in normal implementation sessions.

Implementation records under `docs/implementation/` remain writable.

If a technical spike proves a requirement wrong and the founder explicitly authorises a spec amendment, start that dedicated Claude Code session with:

`THEMIS_SPEC_AMENDMENT=1 claude`

Use that only for an explicitly authorised amendment. After the amendment is committed, return to a normal session.

## Production enforcement gate

Foundation engineering and spike harnesses may proceed.

Do not implement Apple-dependent production enforcement as final behaviour until the relevant entitlement/spike gate in `docs/37_BUILD_SEQUENCE.md` has been satisfied.

## Closing a task

Before a task is closed:

- verify against traced acceptance criteria
- run applicable tests/checks
- review the git diff
- update BUILD_LOG
- record any implementation-only decision
- set CURRENT_STATE to COMPLETE or BLOCKED
- commit verified work if the task requires a commit

A context limit is not a valid completion condition.
