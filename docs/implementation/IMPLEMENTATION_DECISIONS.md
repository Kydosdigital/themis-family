# Themis Family Implementation Decisions

Use this file for implementation choices that do not alter approved product requirements.

If a choice changes product behaviour, policy, an acceptance criterion, a security invariant, or an Apple capability assumption, it is not an implementation decision. It requires a specification amendment.

## IMP-001: Claude Code operating layer

Date: 2026-09-29
Status: Confirmed implementation-process decision

Decision:
Use committed project-level Claude Code instructions, rules, hooks, specialist agents, skills and persistent implementation-state files before application coding begins.

Rationale:
The product has a large approved specification and multiple Apple/platform gates. The operating layer reduces incomplete long-running tasks, protects approved requirements, preserves context across compaction, and creates deterministic quality checks around destructive commands and task completion.

Product impact:
None. This changes the development workflow only.

## IMP-002: Supabase selected as backend platform

Date: 2026-09-29
Status: Confirmed implementation architecture decision

Decision:
Use Supabase as the backend platform for Themis Family, with PostgreSQL as the durable data store and Supabase-managed platform capabilities used where they fit the approved requirements.

Implementation boundaries:
- Durable schema changes are versioned migrations.
- Row Level Security is required for user-accessible tables before release.
- Privileged server-side transitions remain controlled and auditable.
- Supabase authentication, Themis child-device credentials and Apple Family Controls authorisation remain separate mechanisms.
- Privileged backend credentials are never exposed to the iOS client.
- Raw Apple Screen Time data that the UK V1 architecture cannot access is not introduced into Supabase.
- The coding-agent MCP connection is project-scoped and should target development rather than production for routine work.

Rationale:
Supabase provides the PostgreSQL database, authentication primitives, server-side functions, observability and development tooling needed by the approved architecture while retaining a clear split between shared business state and on-device Apple enforcement.

Product impact:
None to the approved user-facing requirements. This chooses the implementation platform used to satisfy them.
