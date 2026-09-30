# Themis Family Build Log

This log records completed implementation work, not requirements history.

## 2026-09-30: Mobile website optimisation

- Improved touch targets, hero hierarchy, form text, family previews and mobile menu dismissal after reviewing the live website.
- Deferred desktop Motion features on touch hardware and removed static-scene scroll updates.
- Fixed narrow walkthrough overflow and Safari modal focus restoration.
- TypeScript, lint, 15 unit/integration tests and production build pass. All 14 new Chromium/WebKit mobile checks pass after fixes; the existing 70 regression tests passed in the broader run.
- Backend collection remains disabled and legal notices remain visible. iOS and frozen specifications are unchanged.

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


## 2026-09-29: Mock-driven SwiftUI frontend foundation

Status: Source implementation complete; local Xcode compile validation pending.

Work:
- Added XcodeGen project definition for an iOS 17+ SwiftUI app and unit-test target.
- Added a semantic Themis design system using the approved cobalt/mint/aqua/peach direction with no purple.
- Kept Manrope as the approved future font while using a documented system-font fallback until the actual font asset is added.
- Added Parent Home and Child/Teen Home screens.
- Added honest five-state protection status UI and child transparency copy.
- Added repository protocols so SwiftUI remains independent of Supabase.
- Added deterministic mock repositories and demo family data for Sarah, Sam and Maya.
- Added Debug-only scenario switching for overdue homework, approval grace, multiple restrictions, offline/sync/protection states, Free Pass, subscription states, no children/rules, and request states.
- Added unit tests around critical demo-state behaviour.
- Added macOS/Xcode build-verification script using XcodeGen.

Verification:
- GitHub Actions run 36529764176 passed for commit 1607c59df58e21df306c0f64d8529dd6361275b0.
- CI is Linux-based and cannot compile SwiftUI.
- Local macOS/Xcode verification remains required before the frontend foundation is marked compile-verified.

## 2026-09-29: Themis Family pre-launch public website

Status: Implemented for draft review; no deployment or app-launch readiness change.

Work:
- Added the isolated Next.js website in apps/web with all requested routes, local MDX examples, licensed photography and claims traceability.
- Added accessible product previews, finite WebGL storytelling and complete static fallbacks.
- Added validated development-only form services; production collection remains unavailable until an approved backend is connected.
- Added consent-gated optional analytics, origin-gated SEO, draft legal content and launch configuration documentation.
- Integrated website checks with repository verification and path-scoped CI.

Verification:
- TypeScript, ESLint, production build and 15 unit/integration tests pass.
- 70 Playwright tests pass, including 48 page accessibility scans, navigation, forms, links, responsive widths and WebGL failure paths.
- Reviewed mobile/desktop page screenshots and image licence records.
- Lighthouse mobile lab performance: 93 Home, 95 Privacy, 91 Waitlist; CLS 0. Home/Waitlist LCP approximately 2.8s remains above the 2.5s target.
- Existing iOS source, frozen requirements and native design progress remain unchanged.

Pending launch work and verification limits are recorded in WEB_STATE.md and apps/web/QA.md.

## 2026-09-29: UI-01 Design System Foundation

Status: Source complete; macOS/Xcode compile, unit-test run and visual comparison pending.

Source of truth: final Claude Design package (Themis Design System, Engineering Handoff token sheet and component inventory, `ThemisScreen` prototype component).

Work:
- Replaced the scaffold tokens with the approved token sheet: brand, ink, grounds and surfaces, status fills and tints, timeline tones, lines, shadows, radii, spacing, touch heights and Parent / Child / Teen variants (`ThemisAudience`, `ThemisGround`).
- Added the typography API (`ThemisTextRole`, `.themisFont`) with every approved role, audience sizes, tracking and Dynamic Type scaling. Manrope is picked up automatically once bundled; system font until then (IMP-UI-001).
- Added the shared status system (`StatusKind`, `StatusTone`, `ThemisStatus`) covering all 36 approved statuses, each with glyph and label, plus `StatusBadge` and `StatusHeader`. `ProtectionStatusBadge` now uses it.
- Added primitives: ThemisButton (primary, secondary, tertiary, destructive, destructive confirm, loading, disabled, audience sizing, press motion and haptic), ThemisCard, ThemisGroupedSection, ThemisRow, AvatarTile, SectionHeader, InlineBanner, ConsequenceNote, KeyValueList (stacks at accessibility sizes), ChecklistList, ReasonField, ChoiceChips, SegmentedChoice, TimeSelection, ChildSelector, StepProgress, CountdownRing, EmptyStateView, LoadingStateView, ErrorStateView and a native confirmation sheet.
- Added `AgreementTimeline` and `StackedTimelineList` on one shared model, with Welcome reveal progress support and Reduce Motion aware motion tokens (`ThemisMotion`).
- Added navigation shells: Parent TabView (Home, Rules, Activity, Settings) with iPad NavigationSplitView, Child/Teen TabView (Home, My Rules, Requests), PageHeader and BellButton. Later-slice tabs show a screen-ID placeholder, not an invented layout.
- Moved the Debug scenario switcher to a `demoControls()` modifier on each tab root.
- Added `DesignSystemTests.swift`: approved status coverage, glyph and label for every status, protection mapping, Approved versus Applied distinction, timeline formatting and stacked rows, audience metrics, touch targets, type scale, Reduce Motion alternatives, a no-purple palette check and tab IA.

Verification:
- Tree-sitter Swift syntax parse: 0 errors across all iOS source and test files.
- `python3 scripts/validate_claude_workflow.py` passed.
- NOT run: Xcode build, XCTest, Simulator screenshots. This session ran on Linux without a Swift toolchain. UI-01 must not be marked complete until these pass on macOS.

Not changed: frozen requirements, product behaviour, Apple enforcement gates, backend wiring.

## 2026-09-29: UI-02 Parent Home

Status: COMPLETE; verified on macOS CI and reviewed against the approved P-023 prototype.

Source of truth: Themis Final Prototype frames P-023, P-023 · Clear, P-023 · Setup incomplete, P-023 · Protection problem; Engineering Handoff component inventory; DEC-40 for the grace period.

Work:
- Replaced the scaffold Parent Home with P-023 in the approved scan order: Needs You, Children, Agreements, quick actions. Header "Good evening" / "Sarah" with the Action Centre bell and count.
- Added `ParentHomeState` and related display models, `ParentDashboardRepository.parentHome(for:)` and deterministic `ParentHomeDemoData` using the exact frame copy.
- Added components: `NeedsYouCard` (elevated card, count pill, primary item, `GraceBar`, Review, further items), `GraceBar`, `ChildStatusRow` (status with last-verified evidence, read together by VoiceOver), `HomeActionCard` / `SetupIncompleteCard`, `QuickActionDock` (floating via `safeAreaInset`; inline at accessibility sizes and on iPad).
- States: canonical Needs You; Nothing pending; Setup incomplete (Sam Not active yet, Maya independently Protected); Protection problem (Sam Needs attention, Noticed 10 min ago). The Sync pending, Device offline and Protection unavailable demo scenarios show the honest status on Sam's row.
- Added demo scenarios Nothing pending, Setup incomplete and Protection problem. Existing scenarios kept.
- Taps open screen-ID placeholders for later-slice destinations.
- Previews: Needs you, Clear, Setup incomplete, Protection problem, Needs you at AX3, Protection unavailable at AX5, and the canonical state inside the Parent tab shell.

Shared UI-01 corrections (see IMP-UI-002):
- `ThemisRow` stacks status/value under the subtitle at accessibility sizes.
- `StatusBadge` remains single-line at all sizes, as approved; `ThemisRow` moves the whole status chip under the subtitle at accessibility sizes so long labels are not squeezed.
- `AvatarTile` gains a 40 pt `.large` size.
- Tokens added from the prototype: `ThemisColor.dockSecondary`, `ThemisRadius.dockButton`, `ThemisSize.avatarLarge`.
- `ShellPlaceholderView` can be pushed with a working Back.

Tests: `ParentHomeTests.swift` covers:
- priority order, the canonical Sam/Maya example and the 18 min / 40% grace
- quick actions are always Add rule and Free Pass, and last
- nothing-pending keeps the Children and Agreements sections
- setup incomplete keeps Maya Protected while Sam is Not active yet
- protection problem is Needs attention, never Protected
- degraded scenarios never show Protected, and every Protected child has Verified evidence
- evidence wording and view-model loading

Verification:
- Web-session tree-sitter Swift syntax parse: 0 errors across all iOS source and test files.
- `python3 scripts/validate_claude_workflow.py` passed.
- GitHub macOS CI: real Xcode build and unit tests passed on source commit `905f13ff94fa575216893bf8212c3f88031fc532`.
- Release Simulator canonical P-023 screenshot captured through the visual-review workflow and compared with the approved final-prototype frame.
- Review correction: status chips remain single-line at accessibility sizes; rows move the chip under text instead. Inline quick actions show the approved `QUICK ACTIONS` section label.
- Full iPad adaptation remains scheduled for UI-14; UI-02 already moves the dock inline at regular horizontal size class.

Not changed: frozen requirements, tab IA, production Supabase, Apple enforcement.
