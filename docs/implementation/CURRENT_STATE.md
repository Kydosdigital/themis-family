# Themis Family Implementation State

Status: COMPLETE
Mode: UI_IMPLEMENTATION
Current objective: UI-04 Onboarding is merged and verified. UI-05 Rules & School Access is next and has not started.
Active slice: UI-04 Onboarding - COMPLETE
Allowed scope: UI-04 is closed. UI-05 must begin as a new dedicated slice/branch from the approved requirements and final design package.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Completed slice prompt: docs/implementation/CLAUDE_CODE_UI04_ONBOARDING_PROMPT.md
Last verification: UI-04 final source commit 648e09a607dcecdccac742525c2662d735c20265 passed the real macOS/Xcode build and full XCTest suite in GitHub Actions run 36742816233. Release Simulator run 36742808418 passed and produced the final ui-visual-review artifact. All 12 standard/accessibility captures were reviewed. P-002 Bedtime and Maya Teen Home Social apps pause clipping found in the earlier review were corrected through the shared open-ended AgreementTimeline rendering, and the final captures are clean.
UI-04 review: onboarding remains mock-driven and preserves Apple/system-owned boundaries. Generic Homework uses Parent Approval only. Phone, Messages and Maps remain where-supported/spike-gated. Protected is not shown before activation readiness. Parent, Child and Teen regression captures remain visually intact.
UI-04 merge: PR #10 squash-merged to main as 3573bef823c00a5453e119116dd5a437051de830.
Next action: Prepare the dedicated UI-05 Rules & School Access implementation prompt, then implement UI-05 only. Do not begin UI-06 in the same run.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: IN PROGRESS, 4 of 15 slices complete
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

UI-05 Rules & School Access:
- not started
- next active implementation slice
- prepare a dedicated slice prompt from the approved rule, Scheduled Rule, Deadline Lock, Earn First, Always Allowed and school-access frames
- continue to use the merged design system and verified UI-02/UI-03/UI-04 patterns
- do not bypass backend or Apple production gates
