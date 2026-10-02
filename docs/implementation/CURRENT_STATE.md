# Themis Family Implementation State

Status: COMPLETE
Mode: UI_IMPLEMENTATION
Current objective: UI-06 Tasks + Deadline Lock is merged and verified. UI-07 Requests is next.
Active slice: UI-07 Requests - NEXT, NOT STARTED
Allowed scope: UI-07 only: Q-001 through Q-014 and A-004 through A-011, plus supporting presentation models, deterministic mocks/tests and visual-review states.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Completed slice prompt: docs/implementation/CLAUDE_CODE_UI06_TASKS_DEADLINE_LOCK_PROMPT.md
Last verification: UI-06 final head 043533dfbe832c87fea6cf59486be945866a0798 passed workflow checks, real Xcode build, full XCTest, and Release Simulator visual review. Exact-head screenshots were manually reviewed, including C-005 standard/accessibility, C-011 after the cleared-status correction, Parent approval/application states, and Parent/Child/Teen/Rules/School Access/Onboarding regressions.
UI-06 review: task submission, fixed 30-minute Approval Grace, overdue/restricted handling, one automatic reminder plus one independent child nudge, Owner/Guardian approval routing, Approved vs Applied, task-owner-only submission, Always Allowed precedence, and multiple-restriction no-false-unlock semantics are represented deterministically without claiming production backend or Apple enforcement.
UI-06 merge: PR #12 squash-merged to main as b7998fd7e193a34d32bbae74c3a0dbb8bf20302c.
UI-07 branch: not created yet at this reconciliation checkpoint.
Next action: Prepare the dedicated UI-07 Requests slice from current main. Before normal iterative UI-07 source pushes, add safe same-branch cancel-in-progress concurrency to the existing expensive iOS CI and visual-review workflows so superseded feature-head macOS runs stop consuming the queue. Then implement Q-001 through Q-014 and A-004 through A-011 only, preserving the approved request semantics and full exact-head verification gates.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS, 6 of 15 slices complete
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

UI-06 Tasks + Deadline Lock:
- C-002 through C-011, P-024 through P-028 and A-001 through A-003
- task submission, waiting, fixed Approval Grace, overdue/restricted, parent review/rejection, approval/application and multiple-restriction presentation
- task-owner-only submission and Owner/Guardian approval routing represented deterministically
- Approved vs Applied remains explicit, with no false unlock while another restriction remains
- exact-head Xcode build and full XCTest passed
- Release Simulator captured UI-06 canonical/accessibility states plus Parent/Child/Teen/Rules/School Access/Onboarding regressions
- merged through PR #12 as b7998fd7e193a34d32bbae74c3a0dbb8bf20302c

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

UI-07 Requests:
- Q-001 through Q-014
- A-004 through A-011
- extra-time/access requests, clarification, adult decision, partial approval, decline, expiry and cancellation
- preserve one automatic 15-minute reminder and one independent child nudge
- preserve exactly one clarification question plus one reply
- preserve first-valid-adult-decision-wins and Approved vs Applied where relevant
- begin with safe same-branch cancel-in-progress concurrency for expensive macOS workflows, without weakening final exact-head verification
- start only from the verified UI-06 merged main
