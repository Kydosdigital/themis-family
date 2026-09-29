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


## IMP-003: Frontend-first repository abstraction and XcodeGen project source

Date: 2026-09-29
Status: Confirmed implementation architecture decision

Decision:
Build the iOS frontend against small repository protocols and deterministic mock implementations before connecting Supabase. Keep the Xcode project structure source-controlled as `apps/ios/project.yml` using XcodeGen rather than hand-maintaining a generated pbxproj in Git.

Rationale:
This allows the Parent/Child experiences and state handling to be implemented and reviewed now without coupling SwiftUI to an unfinished backend. Supabase implementations can later conform to the same repository protocols. XcodeGen keeps project structure reviewable and avoids fragile manual pbxproj edits from remote tooling.

Boundary:
Mock data represents UI states only and must never be described as evidence that Apple enforcement, device sync, approvals or Supabase persistence have occurred.

Product impact:
None. This is an implementation-structure decision that preserves the approved product behaviour.

## IMP-WEB-001: Isolated pre-launch public website

Date: 2026-09-29
Status: Implemented under the user-approved public website brief

The website lives in apps/web as a self-contained Next.js package. It does not share runtime code with the iOS application or change approved requirements. WEB_STATE.md tracks this work separately so CURRENT_STATE.md continues to represent the native design work.

Forms have provider-independent services and a development-only local adapter. Production fails closed until an authorised backend, durable rate limiter, reviewed privacy information and operational contacts are supplied. No connected Supabase project is implicitly selected.

The 3D scene is dynamically imported on capable pointer devices. Touch, reduced-motion and constrained devices receive a complete static illustration by default, with an explicit motion control. Demand rendering stops after transitions and while off-screen. This preserves the required WebGL storytelling without making it a prerequisite to read or use the website.

Legal text and article examples remain clearly labelled drafts. No price, launch date, permanent logo, customer endorsement or verified Apple behaviour is invented. Public app-launch gates remain unchanged.
