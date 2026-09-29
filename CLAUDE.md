# Themis Family: Claude Code Operating Instructions

## Mission

Build Themis Family from the approved requirements baseline without silently weakening requirements, inventing Apple platform behaviour, or crossing implementation gates that remain blocked.

Requirements were approved by the founder on 2026-09-29.

Final approved requirements baseline:
`06327979dfe9cf1c1521a5def1df8095a4b222ed`

## Read first

Before implementing a feature, read only the requirement documents relevant to that feature. Start with:

- `docs/37_BUILD_SEQUENCE.md`
- `docs/38_DEFINITION_OF_DONE.md`
- `docs/32_TRACEABILITY_MATRIX.md`
- the owning FR/BR/DEC documents for the task

Do not load every requirements file by default.

## Readiness gates

Current status:

- Specification ready: YES
- Foundation engineering ready: YES
- Production enforcement ready: NO
- Public launch ready: NO

Foundation work may proceed.

Production Apple enforcement must not be implemented as final behaviour until the required entitlement and real-device spikes have been completed and their findings incorporated into the specification.

Never convert an unverified Apple assumption into production architecture.

## Approved specifications are frozen

The approved specification files in `docs/` are read-only during normal implementation.

You may write implementation working documents under `docs/implementation/`.

If implementation or a technical spike contradicts an approved requirement, do not edit the requirement to make the code easier. Record the discrepancy in `docs/implementation/IMPLEMENTATION_DECISIONS.md` and stop the affected production behaviour until a spec amendment is explicitly authorised.

## Default to action

When the user asks for implementation work, implement it rather than only suggesting changes.

Discover missing repository context with tools instead of guessing.

Do not over-engineer. Make the smallest coherent change that satisfies the traced requirements.

## Vertical-slice discipline

For product work:

1. Identify the exact HLR, FR, BR, DEC and acceptance criteria.
2. Define one bounded vertical slice.
3. Update `docs/implementation/CURRENT_STATE.md` to IN_PROGRESS.
4. Implement only that slice.
5. Add or update tests.
6. Run verification.
7. Review the diff against requirements.
8. Update implementation logs.
9. Set CURRENT_STATE to COMPLETE or BLOCKED.
10. Commit only verified work.

Do not take "build the whole app" as permission to implement all features in one change.

## Long-running work and compaction

Claude Code can compact its context. Context pressure is not a reason to stop early.

Before a long task loses context:

1. Update `docs/implementation/CURRENT_STATE.md`.
2. Record the current objective, files changed, verification already run, unresolved failures, and next exact action.
3. Allow compaction.
4. Re-read CURRENT_STATE after compaction.
5. Continue until the requested task is complete or genuinely blocked.

Never use token or context limits as a substitute for finishing the requested task.

## Verification standard

A task is not complete merely because code was written.

Before declaring completion:

- re-read the traced requirements
- inspect `git diff`
- run applicable tests and checks
- do not delete or weaken tests to make them pass
- check negative and failure paths
- check security/privacy implications where relevant
- update CURRENT_STATE and BUILD_LOG
- record any implementation decision not already dictated by the specification
- leave the repository in a comprehensible state

## Git discipline

Use focused commits.

Never force-push, rewrite shared history, hard-reset away work, or discard unrelated changes.

Inspect status and diff before committing.

Do not commit secrets, `.env` files, credentials, signing material, or local Claude settings.

## Specialist agents

Use project subagents when work benefits from isolated review or specialist context.

Use them for architecture, iOS, backend, security and QA. Do not spawn a subagent for trivial single-file work.

Reviewer agents should return findings rather than rewriting implementation unless explicitly asked.

## Security and child safety

This is a child-facing parental-control product.

Treat child-device clients as potentially adversarial at API boundaries without using punitive product language.

Preserve:
- one active household binding per managed device
- server-side role enforcement
- scoped, revocable device credentials
- notification minimum-payload privacy
- no covert monitoring
- no support role that can parent the child
- fail-safe enforcement where specified
- honest "Approved" versus "Applied on device" status

## When blocked

If a task depends on an unresolved entitlement, Apple capability, spike, legal decision or safeguarding gate:

1. do not invent the answer
2. implement only safe foundation/scaffolding work
3. record the blocker in CURRENT_STATE
4. explain exactly what evidence is needed to unblock it
