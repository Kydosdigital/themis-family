# Themis Family Implementation State

Status: COMPLETE
Mode: UI_IMPLEMENTATION
Current objective: UI-01 is verified and ready to merge. Next implementation slice is UI-02 Parent Home.
Active slice: UI-01 Design System Foundation — COMPLETE
Allowed scope: semantic design tokens, typography API, reusable primitives, shared status system, Parent/Child/Teen navigation shell, tests and macOS CI verification. Continue later in small slices following the approved handoff order.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Implementation prompt: docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md
Last verification: UI-01 compiles successfully with Xcode on GitHub macOS CI and its unit tests pass. The implementation was reviewed against the approved token/component/navigation handoff. A true Simulator screenshot comparison is not available from the current web-only workflow, so representative screenshot QA is carried forward into UI-02 where the first complete production screen will be reviewed and any shared-token corrections can be fed back safely. Production Apple enforcement remains spike-gated.
Next action: Merge PR #6, then start UI-02 Parent Home. UI-02 must implement P-023 and approved Parent Home states only, then stop for verification.

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

## First implementation slice

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

Do not attempt all 216 screens in one context.

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
