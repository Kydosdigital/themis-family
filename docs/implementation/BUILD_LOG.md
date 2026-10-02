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


## 2026-09-30: UI-03 Child + Teen Home

Status: COMPLETE; verified on macOS CI and reviewed from Release Simulator output against the approved Child/Teen direction.

Source of truth: UI-03 implementation prompt, final Claude Design package, Design System, Engineering Handoff, approved requirements and MOBILE_UX_BLUEPRINT.

Work:
- Replaced the older Child/Teen scaffold with repository-backed presentation states for canonical Sam and Maya homes while retaining later-slice demo scenarios.
- Implemented C-001 Sam Child Home with the warmer Child ground, Themis active status, privacy link, Homework section, due status, 4 PM / 6 PM / 8 PM AgreementTimeline, consequence copy, completion action and more-time action.
- Implemented C-001 Maya Teen Home with the restrained Teen treatment, Themis active status, privacy link, Social apps 10 PM-7 AM schedule, AgreementTimeline, Focus Session and request action.
- Implemented C-012 Themis is active, C-013 Child transparency, C-013 Teen privacy/transparency and C-014 Essential access.
- Reused the shared status system and AgreementTimeline, including the stacked accessibility fallback.
- Kept Child/Teen tabs to Home / My Rules / Requests.
- Added deterministic standard, accessibility and tab-shell previews plus ChildTeenHomeTests.
- Extended the macOS visual-review workflow to capture Parent, Child and Teen canonical homes at standard and approved large-text sizes.

Review corrections before merge:
- Visible C-001 actions now route to the correct owning future-screen placeholders: C-003 for homework submission, Q-001 for more-time requests and E-004 for Focus Session, without implementing those later flows.
- Teen Home was tightened at standard text size so the active state and schedule status remain mature and compact, while accessibility sizes stack safely.
- The Child timeline conditional band uses the readable label "Games pause"; the exact Roblox/Minecraft consequence remains directly below and the accessibility list preserves "From 6 PM · only if it applies".
- Essential-access tests recognise explicit spike-gated Apple availability wording without turning Phone, Messages or Maps into a guarantee.
- First-boot Simulator system banners are given time to clear before screenshot capture so review artifacts contain app UI rather than transient OS chrome.

Verification:
- GitHub macOS CI run 36682980817: real Xcode build passed and the full XCTest run passed on source commit e8b1ed1bad1e88579b143c4b502ab642ecb050e6.
- GitHub visual-review run 36682976607: Release Simulator build and six screenshots passed, covering Parent, Sam and Maya at standard and approved large-text sizes.
- Sam visual review: warm Child surface, dominant homework task/deadline, timeline, calm consequence, clear primary/secondary actions and approved three-tab IA.
- Maya visual review: Parent-adjacent mature surface, schedule-first NOW section, compact status treatment, Focus Session, visible request action and approved three-tab IA.
- Accessibility review: status chips remain single-line and AgreementTimeline changes to the stacked semantic representation at accessibility sizes.
- Parent P-023 was recaptured as a regression check and remains aligned with the UI-02 implementation.

Not changed: frozen requirements, production Supabase, Apple enforcement, OQ-30 capability assumptions, C-002 through C-011 implementation or UI-04.


## 2026-09-30: UI-04 Onboarding

Status: COMPLETE; merged through PR #10 after real Xcode/XCTest and Release Simulator review.

Source of truth: approved onboarding requirements, final clickable prototype, Design System, Engineering Handoff and `docs/implementation/CLAUDE_CODE_UI04_ONBOARDING_PROMPT.md`.

Work:
- Implemented P-001 through P-022 as one coherent onboarding state machine.
- Added the approved five-chapter onboarding structure, native Sign in with Apple, explicit Apple/system-owned permission and picker handoffs, Sarah/Sam canonical setup, Homework Deadline starter, Roblox + Minecraft, 6:00 PM school-days deadline, Parent Approval, Always Allowed guidance, agreement review, protection test and activation.
- Added P-010 pairing variants, including child-device entry, expired code, already-paired and secure-recovery presentation states.
- Added P-021 success, retry and permission-result variants.
- Preserved mock-driven UI boundaries: production Family Controls, backend identity/session wiring and real protection behaviour remain behind their existing gates.
- Added deterministic visual-review launch states and kept Parent, Sam Child and Maya Teen homes as regression captures.

Review corrections:
- Re-aligned the first implementation pass against the final prototype package, including the exact five onboarding chapters, welcome treatment, Child/Teen cards, Apple-owned placeholders and the P-022 activation presentation.
- Native Sign in with Apple only advances after a successful result.
- Account creation never claims protection is active.
- Generic Homework exposes Parent Approval only.
- Essential-access copy keeps Phone, Messages and Maps as where-supported / spike-gated and never deliberately restricts emergency calling.
- Open-ended `AgreementTimeline` bands now stay inside visible bounds, fixing clipped Bedtime on P-002 and Social apps pause on Maya Teen Home without changing rule semantics.
- Deferred pairing setup routes to the existing Parent Home setup-incomplete state rather than pretending protection is complete.

Verification:
- Final verified UI-04 source commit `648e09a607dcecdccac742525c2662d735c20265` passed real macOS/Xcode build and full XCTest in run `36742816233`.
- Final Release Simulator run `36742808418` passed and produced the `ui-visual-review` artifact.
- All 12 captured standard/accessibility screens were reviewed. Parent, Sam and Maya regressions remained intact; P-002, P-010, P-019 and P-022 matched the approved direction; accessibility timelines used the stacked semantic fallback.
- Final documentation head `c038a0d832dca9044b4c11df04d75e788d4d3e03` also passed iOS build/tests and workflow checks before merge.
- PR #10 squash-merged to main as `3573bef823c00a5453e119116dd5a437051de830`.

Not changed: production Supabase, Family Controls entitlement, Apple enforcement assumptions, unresolved OQ-30 behaviour, UI-05 or later slices.


## 2026-10-02: UI-05 Rules & School Access

Status: COMPLETE; merged through PR #11 after exact-head Xcode/XCTest and Release Simulator review.

Work:
- Implemented R-001 through R-015 and S-001 through S-005 presentation for Scheduled Rule, Deadline Lock, Earn First, Always Allowed and School Access.
- Preserved effective-enforcement semantics, the approved 30-minute Deadline Lock grace, absolute Always Allowed precedence, emergency calling floor, platform-agnostic School Access and Apple-owned picker boundaries.
- Added deterministic Rules and School Access review roots without changing the normal Parent Rules-tab path.
- Extended visual review to capture Rules and School Access at standard and accessibility text sizes while retaining Parent, Child, Teen and Onboarding regression captures.

Verification:
- Final exact head `b2ba1c7712c0cc193666c5c104ab1170f07c49a0` passed workflow checks.
- Real macOS/Xcode build and full XCTest passed.
- Release Simulator visual-review run `36968064993` passed and produced the expanded review artifact.
- Rules and School Access standard/accessibility captures were manually inspected and found clean; large-text states remain scrollable and status labels remain readable.
- PR #11 merged to main as `249b029b77b383531c1144241fe1253c87a70818`.

Not changed: production Family Controls enforcement, backend wiring, OQ-30 Phone/Messages/Maps assumptions or later UI slices.
