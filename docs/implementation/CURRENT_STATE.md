# Themis Family Implementation State

Status: COMPLETE
Mode: UI_IMPLEMENTATION
Current objective: UI-03 Child + Teen Home is merged and verified. UI-04 Onboarding is the next slice, but it has not started.
Active slice: UI-03 Child + Teen Home - COMPLETE
Allowed scope: C-001 Child Home, C-001 Teen Home, C-012 Themis is active, C-013 Child/Teen transparency, C-014 essential access, supporting presentation models/components, previews and tests. UI-03 is closed.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Completed slice prompt: docs/implementation/CLAUDE_CODE_UI03_CHILD_TEEN_HOME_PROMPT.md
Last verification: UI-03 source through commit e8b1ed1bad1e88579b143c4b502ab642ecb050e6 passed a real macOS/Xcode build and XCTest run in GitHub Actions. Release Simulator screenshots for Sam Child Home, Maya Teen Home, Parent Home regression, and their approved large-text review states were captured and reviewed against the approved design direction.
UI-03 review: Sam keeps the warmer, larger Child treatment and homework-first hierarchy. Maya stays mature and closer to Parent, with a compact active row, schedule timeline and visible Focus Session actions. Status chips remain single-line, AgreementTimeline stacks at accessibility sizes, and the Home / My Rules / Requests tab IA is unchanged. C-012/C-013/C-014 use mock-driven UI and honest Apple/privacy wording only.
UI-03 merge: PR #9 squash-merged to main as ee61ed1f2e934f977440e95b6d68a5fc1cffd32a.
Next action: Prepare the dedicated UI-04 Onboarding implementation prompt from the approved requirements and final design package. Start UI-04 only as a new slice/branch and stop before UI-05.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS, 3 of 15 slices complete
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

## Completed implementation slice

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
- Release Simulator visual review

Source and verification status: COMPLETE. See BUILD_LOG "UI-02 Parent Home" and IMP-UI-002.

UI-02 is merged.

## Completed implementation slice

UI-03 Child + Teen Home:
- C-001 Sam Child Home
- C-001 Maya Teen Home
- C-012 Themis is active
- C-013 Child transparency
- C-013 Teen privacy/transparency
- C-014 essential access
- deterministic previews/review states
- presentation/state tests
- GitHub macOS Xcode/XCTest verification
- Release Simulator visual review at standard and approved large-text sizes
- Parent Home visual regression capture

Source and verification status: COMPLETE. See BUILD_LOG "UI-03 Child + Teen Home" and IMP-UI-003.

UI-03 is merged through PR #9.

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

## Next implementation slice

UI-04 Onboarding:
- not started
- prepare a dedicated slice prompt from the approved onboarding frames and requirements
- continue to use the merged UI-01 design system and verified UI-02/UI-03 patterns
- do not bypass backend or Apple production gates
