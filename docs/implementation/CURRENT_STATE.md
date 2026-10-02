# Themis Family Implementation State

Status: COMPLETE
Mode: UI_IMPLEMENTATION
Current objective: UI-05 Rules & School Access is merged and verified. UI-06 Tasks + Deadline Lock is next.
Active slice: UI-06 Tasks + Deadline Lock - NEXT, NOT STARTED
Allowed scope: UI-06 only: C-002 through C-011, P-024 through P-028 and A-001 through A-003, plus supporting presentation models, deterministic mocks/tests and visual-review states.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Completed slice prompt: docs/implementation/CLAUDE_CODE_UI05_RULES_SCHOOL_ACCESS_PROMPT.md
Last verification: UI-05 final head b2ba1c7712c0cc193666c5c104ab1170f07c49a0 passed workflow checks, real Xcode build, full XCTest, and Release Simulator visual review. Rules and School Access were captured at standard and accessibility text sizes, with Parent/Child/Teen/Onboarding regressions preserved.
UI-05 review: Rules and School Access remain mock/presentation-driven, preserve effective-enforcement semantics, 30-minute Deadline Lock grace, absolute Always Allowed, emergency calling floor, platform-agnostic School Access, Apple-owned picker boundaries and OQ-30 capability gates.
UI-05 merge: PR #11 merged to main as 249b029b77b383531c1144241fe1253c87a70818.
UI-06 branch: not created yet at this reconciliation checkpoint.
Next action: Create the dedicated UI-06 Tasks + Deadline Lock branch from current main, prepare the implementation prompt from approved requirements/design, implement only UI-06, and verify with real Xcode/XCTest plus Release Simulator review.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS, 5 of 15 slices complete
- Production Apple enforcement: NO, spike-gated
- Public launch: NO

## Completed implementation slices

UI-01 Design System Foundation:
- tokens, typography API, reusable primitives, status system and navigation shell
- tests and real macOS/Xcode verification
- merged through PR #6

UI-02 Parent Home:
- P-023 canonical Parent Home and approved states
- deterministic previews/review states and tests
- real macOS/Xcode/XCTest and Release Simulator visual review
- merged through PR #7

UI-03 Child + Teen Home:
- C-001 Sam Child Home and Maya Teen Home
- C-012, C-013 Child/Teen and C-014
- deterministic previews/review states and tests
- real macOS/Xcode/XCTest and Release Simulator visual review
- merged through PR #9

UI-04 Onboarding:
- P-001 through P-022
- P-010 pairing code, already-paired and recovery-required presentation variants
- P-021 success, retry and permission-result variants
- canonical Sarah/Sam Homework setup through activation
- Apple/system-owned handoff boundaries preserved
- deterministic onboarding tests and Simulator capture states
- final real macOS/Xcode/XCTest verification passed
- final 12-image Release Simulator review passed after correcting open-ended timeline label clipping
- merged through PR #10 as 3573bef823c00a5453e119116dd5a437051de830

UI-05 Rules & School Access:
- R-001 through R-015 and S-001 through S-005
- Scheduled Rule, Deadline Lock, Earn First, Always Allowed and School Access presentation
- deterministic review roots for Rules and School Access
- exact-head Xcode build and full XCTest passed
- Release Simulator captured Rules and School Access at standard/accessibility sizes plus regression targets
- merged through PR #11 as 249b029b77b383531c1144241fe1253c87a70818

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

UI-06 Tasks + Deadline Lock:
- C-002 through C-011
- P-024 through P-028
- A-001 through A-003
- task submission, parent approval/rejection, Deadline Lock grace/overdue/application and multiple-restriction handling
- preserve effective-enforcement semantics and never false-unlock while another restriction applies
- start from the verified UI-05 merged main
