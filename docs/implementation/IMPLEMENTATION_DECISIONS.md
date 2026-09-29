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

## IMP-UI-001: UI-01 design-system foundation implementation choices

Date: 2026-09-29
Status: Implemented; awaiting local Xcode verification and design review

Source: final Claude Design Engineering Handoff (token sheet, component inventory, SF Symbols map, motion spec, state matrix) and the `ThemisScreen` prototype component.

Decisions made where the handoff leaves an implementation choice:

1. **Typography fallback.** Manrope font files are not in the repository (asset register: "Required · licence check (SIL OFL)"). `ThemisTextRole` implements every approved role at its exact Parent / Child / Teen size, weight and tracking, scaled with `@ScaledMetric(relativeTo:)` against the documented text style. Until the font files are bundled and listed under `UIAppFonts`, the system font renders those metrics. When `Manrope-Bold` becomes available at runtime it is used automatically with no call-site change. No other brand font is substituted.
2. **Status labels in sentence case.** The prototype and state matrix use "Sync pending", "Device offline" and so on. `ProtectionStatus.title` now delegates to the shared status system, replacing the scaffold's title-case labels. Shield-shaped glyphs were replaced by the handoff SF Symbols map (no generic shield motif).
3. **Status label overrides.** The state matrix reuses a kind's glyph and tone under another label (for example "Unconfirmed" uses Device offline; "Approved, timing unverified" uses Approved). These are modelled as `ThemisStatus(kind, label:)` presets, so a label can never drift to a different colour meaning.
4. **Page header in content.** Tab-root frames set a small subtitle above the large page title with the bell beside it. The native large title cannot do this, so `PageHeader` is drawn in content and tab roots hide the navigation bar. Pushed screens keep the native navigation bar.
5. **Bell glyph.** The frame shows a plain bell with a cobalt count pill. `bell` is used in both states; `bell.badge` plus a count would double-badge.
6. **iPad split view on iOS 17.** The deployment target is iOS 17, so `TabView(.sidebarAdaptable)` is unavailable. `ParentTabShell` uses `NavigationSplitView` when the horizontal size class is regular and falls back to `TabView` at compact width or at accessibility text sizes. This follows the system size class; there is no custom width threshold, as the Pass 4 review asked.
7. **Timeline fallback trigger.** `AgreementTimeline` switches to `StackedTimelineList` when `dynamicTypeSize.isAccessibilitySize`, as specified by `variant.accessibilitySizes`. The same trigger stacks `KeyValueList` rows.
8. **Legacy aliases.** The pre-handoff Parent Home and Child Home views keep compiling through documented aliases (`ThemisColor.actionPrimary`, `ThemisSpacing.md`, `ThemisTypography.body` and similar). They are removed when UI-02 and UI-03 rebuild those screens against the approved frames.
9. **Shell placeholders.** Tabs whose screens belong to later slices show `ShellPlaceholderView` with the screen ID, rather than an invented layout.

Product impact: none. No product behaviour, copy rule or requirement changed.

## IMP-UI-002: UI-02 Parent Home implementation choices

Date: 2026-09-29
Status: Verified and approved for merge

Source: Themis Final Prototype frames P-023, P-023 · Clear, P-023 · Setup incomplete and P-023 · Protection problem (`themis-screens.js`), rendered by `ThemisScreen.dc.html`.

1. **Display model.** `ParentHomeState` is a presentation model produced by `ParentDashboardRepository.parentHome(for:)`. The canonical state (Sam's homework in review, Maya's request pending, Sam Protected, Maya Sync Pending) cannot be expressed by the older `ParentDashboardData`, which is kept unchanged for its existing tests.
2. **Grace fill.** The `GraceBar` fill is the share of the 30-minute Provisional Approval Grace Period already used (DEC-40, BR-207). 18 min remaining = 40%, matching the frame.
3. **Protection evidence.** Every child row carries `ProtectionEvidence` ("Verified 2 min ago", "Noticed 10 min ago", "Protection not active yet"). The repository chooses the status; no staleness threshold (OQ-19) is encoded in the UI.
4. **Degraded protection scenarios.** The design draws a Home card only for Needs Attention (P-023 · Protection problem). For the Sync pending, Device offline and Protection unavailable demo scenarios, Parent Home shows the honest status and evidence on the child row and keeps the canonical Needs You card. No Home card copy was invented for them.
5. **Dock placement.** The floating dock uses `safeAreaInset(edge: .bottom)`, so scroll content always ends above it and is never covered. It moves inline (after Agreements) at accessibility text sizes and at regular horizontal size class (iPad), per the component inventory ("inline at accessibility sizes and on iPad"). The inline variant shows the approved `QUICK ACTIONS` section label.
6. **Debug navigation bar.** The page header replaces the navigation bar on this tab root. Debug builds keep the bar so the demo scenario control is reachable. Visual review uses the deterministic `#Preview`s, which hide the bar as Release does.
7. **Type-role mapping.** Two prototype sizes sit between approved roles: the grace value (22 pt heavy) uses `headline` + heavy, and card body copy (14 pt) uses `secondary` (15 pt). Card titles (17 pt bold) use the `button` role, which has exactly those metrics.
8. **No children.** Not a drawn P-023 state. It shows an empty state with the scaffold's existing copy until onboarding (P-004 onwards) is built.
9. **Later-slice destinations.** Taps push `ShellPlaceholderView` for the target screen ID (A-001, A-002, A-004, P-009, P-029, P-030 · *, R-001, R-002, R-003, F-001).

Shared UI-01 corrections made for P-023 (recorded in BUILD_LOG):
- `ThemisRow` moves its status or value under the subtitle at accessibility sizes, so long statuses are not squeezed or clipped.
- `StatusBadge` keeps labels on one line at every size, matching the approved accessibility rule. `ThemisRow` moves the whole chip below the text at accessibility sizes so long labels remain intact without squeezing the row.
- `AvatarTile` gains a 40 pt `.large` size for card heads (prototype 2.5em).
- New tokens from the prototype: `ThemisColor.dockSecondary` (#F0F2F5), `ThemisRadius.dockButton` (16 pt), `ThemisSize.avatarLarge` (40 pt).
- `ShellPlaceholderView` supports being pushed (keeps the navigation bar and Back).

Product impact: none. No requirement, business rule or approved copy changed.
