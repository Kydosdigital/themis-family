# Themis Family Implementation State

Status: IN_PROGRESS
Mode: UI_IMPLEMENTATION
Current objective: Verify and merge UI-01 Design System Foundation before starting UI-02 Parent Home.
Active slice: UI-01 Design System Foundation
Allowed scope: semantic design tokens, typography API, reusable primitives, shared status system, Parent/Child/Teen navigation shell, tests and macOS CI verification. Continue later in small slices following the approved handoff order.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Implementation prompt: docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md
Last verification: Claude Code implemented UI-01 on branch feat/ui-01-design-system-foundation and draft PR #6 is open. A real Xcode build passed in GitHub macOS CI. Unit tests are being rerun after fixing the test-host executable-name mismatch. Production Apple enforcement remains spike-gated.
Next action: Wait for the current macOS CI build/tests, perform visual comparison against the approved Design System, then merge PR #6 before starting UI-02.

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
- visual comparison against approved Design System

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
