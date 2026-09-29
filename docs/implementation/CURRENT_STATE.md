# Themis Family Implementation State

Status: READY
Mode: UI_IMPLEMENTATION
Current objective: Implement UI-03 Child + Teen Home from the approved C-001/C-012/C-013/C-014 designs.
Active slice: UI-03 Child + Teen Home — READY
Allowed scope: C-001 Child Home, C-001 Teen Home, C-012 Themis is active, C-013 Child/Teen transparency, C-014 essential access, supporting presentation models/components, previews and tests. Do not begin UI-04.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Implementation prompt: docs/implementation/CLAUDE_CODE_UI03_CHILD_TEEN_HOME_PROMPT.md
Last verification: UI-01 Design System Foundation merged through PR #6. The SwiftUI app compiled successfully with Xcode on GitHub macOS CI and unit tests passed. Representative screenshot QA is carried into UI-02 because the implementation session is web-only. Production Apple enforcement remains spike-gated.
UI-02 verification: the SwiftUI source through commit 905f13ff94fa575216893bf8212c3f88031fc532 passed a real macOS/Xcode build and unit-test run, including ParentHomeTests. Claude workflow checks passed. A release Simulator screenshot of canonical P-023 was captured and compared with the approved final prototype. The hierarchy, grouped grey ground, elevated Needs You card, child status rows, Agreements and floating quick-action dock match the approved direction. During review, StatusBadge was corrected to keep chips single-line at accessibility sizes, and inline quick actions gained the approved QUICK ACTIONS label.
Next action: Give Claude Code docs/implementation/CLAUDE_CODE_UI03_CHILD_TEEN_HOME_PROMPT.md, implement UI-03 on feat/ui-03-child-teen-home, then stop for review before UI-04.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS
- Production Apple enforcement: NO, spike-gated
- Public launch: NO

## Completed implementation slice

UI-01 Design System Foundation:
- tokens
- typography API
- reusable primitives
- status system
- navigation shell
- tests
- macOS GitHub Actions build/test verification
- structural/design-spec review against approved Design System
- representative Simulator screenshot QA carried into UI-02

UI-01 is merged. Do not attempt all 216 screens in one context.

## Current implementation slice

UI-02 Parent Home:
- P-023 canonical needs-attention state
- nothing-pending state
- setup-incomplete state
- protection-problem state
- NeedsYouCard
- GraceBar
- ChildStatusRow
- QuickActionDock
- deterministic previews/review states
- Parent Home presentation/state tests
- GitHub macOS CI verification

Source and verification status: COMPLETE. See BUILD_LOG "UI-02 Parent Home" and IMP-UI-002.

Stop after UI-02.

## Production gates

Remain unresolved:
- Family Controls production entitlement
- Priority 1 remote decision -> applied timing
- Priority 2 Phone / Messages / Maps shield behaviour
- terminated-app scheduled transitions
- shield persistence/removal
- Apple Screen Time report availability on parent device
- OQ-19 staleness threshold
- OQ-34 trusted-time reliability
- OQ-40 compromised-device timing integrity

## Required clarification before ST-011 production billing wiring

Household deletion UI may be implemented, but production billing side-effects must not be finalised until the requirements explicitly distinguish:
1. Themis household/internal entitlement termination
2. App Store subscription auto-renewal management

## Progress tracking

Human-readable progress and cross-chat handoff live in Airtable:
- Base: Themis Family Product Tracker
- Interface: Themis Control Centre
- Tracker guide: docs/implementation/AIRTABLE_TRACKER.md

Airtable is not a replacement for the approved requirements or GitHub implementation state.

## Current implementation slice

UI-03 Child + Teen Home:
- C-001 Sam Child Home
- C-001 Maya Teen Home
- C-012 Themis is active
- C-013 Child transparency
- C-013 Teen privacy/transparency
- C-014 essential access
- deterministic previews/review states
- presentation/state tests
- GitHub macOS CI verification
- Simulator visual review

Stop after UI-03.
