# Themis Family Implementation State

Status: BLOCKED
Mode: UI_IMPLEMENTATION
Current objective: Verify UI-01 Design System Foundation on macOS/Xcode, then continue with UI-02 Parent Home.
Active slice: UI-01 Design System Foundation (source complete; compile and Simulator verification pending)
Allowed scope: semantic design tokens, typography API, reusable primitives, shared status system, Parent/Child/Teen navigation shell, tests and local Xcode verification. Continue later in small slices following the approved handoff order.
Behaviour source of truth: approved requirements baseline.
Visual/interaction source of truth: final Claude Design prototype, final Design System, and Engineering Handoff.
Implementation review: docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md
Implementation prompt: docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md
Last verification: UI-01 source written in a Linux cloud session. All Swift files pass a tree-sitter syntax parse and `scripts/validate_claude_workflow.py` passes. SwiftUI has NOT been compiled: no macOS/Xcode was available.
Blocked on: a macOS/Xcode run of `bash scripts/verify_ios.sh`, the unit tests, and a Simulator screenshot comparison of the component previews against the Design System board.
Next action: On a Mac, run `bash scripts/verify_ios.sh` and the `ThemisFamily` test scheme, fix any compile errors, compare previews with the approved board at default and one accessibility size, then set UI-01 COMPLETE and start UI-02 Parent Home.

## Current readiness

- Specification ready: YES
- Mobile UX architecture: APPROVED
- Visual direction: APPROVED
- Design System: APPROVED
- Final prototype: APPROVED
- Engineering Handoff: APPROVED
- SwiftUI UI implementation: READY
- Production Apple enforcement: NO, spike-gated
- Public launch: NO

## UI-01 progress

Source complete (see BUILD_LOG 2026-09-29 "UI-01 Design System Foundation" and IMP-UI-001):
- semantic colour, spacing, radius, border, shadow, touch-size and audience tokens
- Manrope-ready typography API with a documented system-font fallback
- shared status system covering every approved status, with StatusBadge and StatusHeader
- reusable primitives, AgreementTimeline and StackedTimelineList
- Parent and Child/Teen navigation shells with iPad split view
- unit tests for status mappings, timeline model, tokens and tabs

Pending: macOS/Xcode compile, unit-test run and Simulator visual comparison.

## First implementation slice

UI-01 Design System Foundation:
- tokens
- typography API
- reusable primitives
- status system
- navigation shell
- tests
- local Xcode verification

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
