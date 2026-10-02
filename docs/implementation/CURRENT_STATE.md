# Themis Family Implementation State

Status: COMPLETE
Mode: UI_IMPLEMENTATION
Current objective: UI-07 Requests is merged and verified. UI-08 Free Pass is next.
Active slice: UI-08 Free Pass - NEXT, NOT STARTED
Allowed scope: UI-08 only: F-001 through F-010, plus supporting presentation models, deterministic mocks/tests and visual-review states.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Completed slice prompt: docs/implementation/CLAUDE_CODE_UI07_REQUESTS_PROMPT.md
Last verification: UI-07 final head dac2edf6e38c56c7e9d232725d7facb6dd2f4c45 passed workflow checks, real Xcode build, full XCTest, and Release Simulator visual review. Exact-head artifact 11217770039 contained all 39 expected screenshots and was manually reviewed, including corrected A-009 parent waiting state, A-010 already-resolved copy, A-011 Approved vs Applying, partial approval, request entry and accessibility states plus existing regressions.
UI-07 review: structured requests preserve specific target/context, offline Sending truth, one automatic 15-minute reminder, one independent child nudge, exactly one clarification question plus one reply, first-valid-adult-decision-wins, partial approval, context-based expiry, cancellation while pending, Approved vs Applied and no false availability while another restriction remains.
UI-07 merge: PR #13 squash-merged to main as d2712f50062732ba82ef689170f05c1ce1093ec8.
Workflow improvement: expensive iOS CI and visual-review workflows now use same-branch cancel-in-progress concurrency; superseded PR and push macOS runs were observed cancelling successfully during UI-07.
UI-08 branch: not created yet at this reconciliation checkpoint.
Next action: Prepare the dedicated UI-08 Free Pass slice from current main and implement F-001 through F-010 only. Preserve explicit scope, duration, current override preview, disclosure of a scheduled rule beginning during the pass, and Revocation sent vs Access revoked. Keep final exact-head Xcode/XCTest and visual-review gates.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS, 7 of 15 slices complete
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

UI-08 Free Pass:
- F-001 through F-010
- explicit child/target scope, never an implicit blanket default
- explicit duration and local expiry
- current override preview before confirmation
- disclose any scheduled rule that begins during the pass
- preserve sending/application truth
- distinguish Revocation sent from Access revoked
- preserve effective-enforcement semantics when a pass ends or another rule still applies
- start only from the verified UI-07 merged main
