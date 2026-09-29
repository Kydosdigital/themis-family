# Themis Family Build Log

This log records completed implementation work, not requirements history.

## 2026-09-29: Implementation operating layer

Status: Prepared in GitHub.

Work:
- Added project-level Claude Code instructions.
- Added project settings and lifecycle hooks.
- Added focused rules for requirements, architecture, iOS, backend, testing, security and Git.
- Added specialist project agents.
- Added reusable implementation, spike, verification, diff-review and task-close skills.
- Added implementation state, build, spike and decision tracking files.
- Added CI validation and implementation/spike issue/PR templates.

Verification:
- GitHub Actions workflow passed repeatedly for the committed workflow baseline.
- Local Claude Code hook execution remains to be validated before application code begins.

Notes:
- Approved requirements remain frozen during normal implementation.
- Production Apple enforcement remains gated by entitlement/spike evidence.

## 2026-09-29: Supabase and stronger implementation guardrails

Status: Repository foundation complete.

Work:
- Confirmed Supabase as the backend platform.
- Added a project-scoped Supabase MCP declaration using SUPABASE_PROJECT_REF.
- Added Supabase/Postgres database rules covering migrations, RLS, privileged operations, credential separation and data minimisation.
- Added Supabase migration/function/seed workspace scaffolding.
- Added SwiftUI and design-system rules for the iOS app.
- Added a dedicated read-only code-reviewer agent.
- Added secret-file protection covering environment files and Apple/signing credentials.
- Added a deterministic pre-commit verifier.
- Added a stable scripts/verify.sh entry point.
- Added a root human-facing README and iOS workspace placeholder.
- Expanded CI path coverage so future Claude/Supabase workflow changes trigger validation.

Verification:
- GitHub Actions run 36528332150 passed on commit 7d27d149df81eee80b396f0c1a9fc9881c511ec6.
- Workflow validation confirms required files, valid JSON/Python hooks, requirements freezing, destructive-command protection, secret protection and project-scoped Supabase MCP configuration.

Pending:
- Local Claude Code first-run validation.
- Dedicated Themis Supabase project provisioning and MCP authentication.
