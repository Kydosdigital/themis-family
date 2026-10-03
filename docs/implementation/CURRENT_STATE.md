# Themis Family Implementation State

Status: IN_PROGRESS
Mode: UI_IMPLEMENTATION
Current objective: UI-08 Free Pass is merged and verified. UI-09 Protection is now the active sequential slice.
Active slice: UI-09 Protection - STARTING
Allowed scope: UI-09 only: P-029 child detail, the P-030 five-state protection family, P-031 recovery, permission-revoked presentation, supporting presentation models, deterministic mocks/tests and visual-review states.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Completed slice prompt: docs/implementation/CLAUDE_CODE_UI08_FREE_PASS_PROMPT.md
Last verification: UI-08 final head 05db4fcc83920b3c57c0a5107aabfec592f8e38e passed real Xcode build, full XCTest and Release Simulator visual review. Artifact 11227053593 contained F-001 through F-010 plus accessibility states and was manually reviewed cleanly.
UI-08 review: explicit child/scope/duration is preserved; active override and scheduled-rule disclosure are clear; expiry remains device-local; Revocation sent is distinct from Access revoked; Always Allowed and emergency communication are not Free Pass targets.
UI-08 merge: PR #16 squash-merged to main as 007f3d867d80aac2475020d5098b92307be7d3e6.
Workflow improvement: expensive iOS CI and visual-review workflows now use same-branch cancel-in-progress concurrency; superseded PR and push macOS runs were observed cancelling successfully during UI-07.
UI-09 branch: to be created from reconciled main.
Next action: Create the dedicated UI-09 Protection branch from reconciled main, implement P-029/P-030/P-031 families and permission-revoked states only, then run exact-head Xcode/XCTest and visual review before merge.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS, 8 of 15 slices complete
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

UI-07 Requests:
- Q-001 through Q-014 and A-004 through A-011
- extra-time/access request creation, offline Sending, Pending, manual reminder, bounded clarification, approve/partial/decline, expiry, cancellation, already-resolved and Approved vs Applied presentation
- request-owner submission, Owner/Guardian routing and first-valid-adult-decision-wins represented deterministically
- exact-head Xcode build and full XCTest passed
- Release Simulator artifact contained all 39 expected UI-07 and regression screenshots; manual review passed after correcting A-009 interpolation/status and A-010 copy
- same-branch macOS workflow cancellation proven for both PR Xcode and push visual-review runs
- merged through PR #13 as d2712f50062732ba82ef689170f05c1ce1093ec8

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

UI-09 Protection:
- P-029 Child detail
- P-030 Protected / Sync Pending / Device Offline / Needs Attention / Protection Unavailable
- P-031 Fix protection recovery
- permission-revoked presentation states
- always show honest status and Last verified where designed
- never show stale state as Protected
- do not invent an OQ-19 staleness threshold
- preserve current production Apple/backend gates
- start only from the verified UI-08 merged main
