# Themis Family

Themis Family is an iOS/iPadOS-first family digital-boundaries product.

Core promise:

> Clear digital boundaries without the daily arguments.

Parents set clear rules around apps, websites, homework, bedtime and temporary access. The product is designed around visible family agreements, requests and exceptions, reliable enforcement, essential/school access and privacy-respecting reporting rather than covert surveillance.

## Current readiness

- **Specification ready:** YES
- **Foundation engineering ready:** YES
- **Production enforcement ready:** NO
- **Public launch ready:** NO

The approved requirements baseline is commit:

`06327979dfe9cf1c1521a5def1df8095a4b222ed`

Production Apple enforcement is still gated by the Family Controls entitlement evidence and the real-device spike programme defined in `docs/27_APPLE_INTEGRATION_REQUIREMENTS.md` and `docs/37_BUILD_SEQUENCE.md`.

## Repository layout

- `docs/`: approved product, functional, architecture, security and test requirements
- `docs/implementation/`: active implementation state, build log, spike evidence and implementation-only decisions
- `.claude/`: Claude Code project instructions, rules, hooks, agents and reusable skills
- `.mcp.json`: project MCP declaration for Supabase
- `apps/ios/`: iOS/iPadOS application workspace
- `supabase/`: Supabase migrations, functions and local backend workspace
- `scripts/`: stable validation/verification entry points
- `.github/`: CI and implementation/spike templates

## Claude Code

Read `CLAUDE.md` and `docs/implementation/CLAUDE_CODE_WORKFLOW.md`.

Before application coding on a new machine:

```bash
python3 scripts/validate_claude_workflow.py
bash scripts/verify.sh
```

Then start Claude Code from the repository root and review the project hooks.

Approved requirements under `docs/` are frozen during normal implementation. Implementation working records live under `docs/implementation/`.

## Supabase

Supabase is the selected backend platform.

The project MCP connection is intentionally project-scoped through:

`SUPABASE_PROJECT_REF`

Once the Themis Supabase project is provisioned, set that environment variable locally and authenticate the Supabase MCP connection from Claude Code.

Do not commit private database credentials, service-role keys, access tokens or Apple signing material.

All durable schema changes must be represented by migrations in `supabase/migrations/`.

## Verification

The stable verification entry point is:

```bash
bash scripts/verify.sh
```

GitHub Actions also validates the committed Claude Code workflow whenever workflow/configuration files change.

## Build discipline

The implementation sequence is controlled by `docs/37_BUILD_SEQUENCE.md`.

Do not jump directly from complete requirements to full production enforcement. Foundation engineering and technical spikes come first, then verified vertical slices.
