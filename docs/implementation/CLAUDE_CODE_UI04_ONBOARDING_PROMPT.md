# Claude Code UI-04 Onboarding Prompt

Implement UI-04 Onboarding only on `feat/ui-04-onboarding`.

## Source of truth
Read CURRENT_STATE.md, MOBILE_UX_BLUEPRINT.md, ENGINEERING_HANDOFF_FINAL_REVIEW.md, DESIGN_PASS5_APPROVAL.md, CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md, DESIGN_PASS1_REVIEW.md, the approved requirements, Claude rules, and the final Claude Design/System/Engineering Handoff package. Requirements control behaviour. Final design controls visuals and interaction. Do not redesign approved UX.

## Scope
Implement the approved parent onboarding journey:
P-001 Launch, P-002 Welcome, P-003 Sign in with Apple, P-004 account created/protection not active, P-005 goal, P-006 add child, P-007 Child vs Teen, P-008 child created, P-009 pair-device intro, P-010 pairing code/QR plus Already paired and Recovery required variants, P-011 Family Controls explanation, P-012 Apple authorisation handoff, P-013 starter rule, P-014 Homework Deadline starter, P-015 controlled apps/sites, P-016 deadline, P-017 verification, P-018 Always Allowed/school access, P-019 agreement review, P-020 protection test, P-021 success/retry/permission-result states, P-022 activation.

Stop before UI-05. Do not change P-023 except as a regression target.

Canonical flow: Sarah, Sam, Child experience, Homework, 6:00 PM, Roblox and Minecraft, Parent Approval, school access preserved, Phone/Messages/Maps recommended or configured where supported.

## Hard boundaries
Never show Protected before activation requirements are satisfied. P-004 must explicitly say protection is not active. P-006 uses first name only, no DOB for segmentation. P-012 is system-owned Apple UI, do not fabricate it. P-015 uses FamilyActivityPicker/system-owned selection semantics, not an invented app catalogue. P-016 should use native time controls. For generic Homework, P-017 must not offer Automatic Verification as an ordinary valid alternative. P-018 must not guarantee Phone, Messages or Maps availability before OQ-30; emergency calling and OS emergency functionality are never deliberately restricted. P-020/P-021 may be mock-driven UI states but must not imply an unproven production enforcement test occurred. No production Supabase or Family Controls enforcement.

## Implementation
Reuse UI-01 semantic tokens/components and verified UI-02/UI-03 patterns. Use native NavigationStack, sheets and controls where approved. Keep status glyph + word and status chips single-line. Support Dynamic Type, VoiceOver, 44pt+ targets, Reduce Motion, long copy and keyboard-safe actions. Keep display state separate from persistence and future Apple/backend services. Provide deterministic end-to-end onboarding demo state and explicit boundaries for system-owned operations.

## Review states
Include deterministic previews/review states for representative early, middle and late onboarding screens, all P-010 variants, P-021 result variants, P-022, and at least one approved large-text state. Extend the existing Release Simulator visual-review harness for representative onboarding captures. Preserve Parent, Child and Teen regression captures when shared components change.

## Tests
Verify flow ordering, protection-not-active at P-004, Sam Child profile without DOB, distinct P-010 variants, system-owned P-012, Parent Approval for canonical generic Homework, conservative essential-access wording, emergency-call boundary, canonical P-019 agreement facts, and activation ordering. Existing UI-01/UI-02/UI-03 tests must remain green.

## Verification
Run repository checks. Real macOS Xcode build and XCTest must pass in GitHub Actions. Release Simulator captures must be reviewed against the approved final design at standard and approved large-text sizes before UI-04 is complete.

Update CURRENT_STATE.md and BUILD_LOG.md, and IMPLEMENTATION_DECISIONS.md only for a real decision. If source is ready but macOS or visual verification remains, mark UI-04 BLOCKED with the exact reason. Do not modify frozen requirements.

STOP after UI-04 and report files changed, states implemented, checks, branch/commit/PR, CI, visual review, and any design deviation.