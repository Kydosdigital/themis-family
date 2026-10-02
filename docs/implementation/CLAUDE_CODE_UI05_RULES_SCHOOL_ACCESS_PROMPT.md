# Claude Code UI-05 Rules & School Access Prompt

Implement UI-05 Rules & School Access only on `feat/ui-05-rules-school-access`.

## Source of truth
Read `docs/implementation/CURRENT_STATE.md`, `MOBILE_UX_BLUEPRINT.md`, `ENGINEERING_HANDOFF_FINAL_REVIEW.md`, `DESIGN_PASS5_APPROVAL.md`, `CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md`, the approved requirements, Claude rules, and the final Claude Design/System/Engineering Handoff package. In particular use `06_FUNCTIONAL_REQUIREMENTS.md`, `09_ACCEPTANCE_CRITERIA.md`, `10_RULE_ENGINE_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `14_PARENT_EXPERIENCE.md`, `20_STATE_MACHINES.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md` and the traceability/decision records.

Requirements control behaviour. Final design controls visuals and interaction. Do not redesign approved UX.

## Scope
Implement the approved UI-05 family only:
- R-001 through R-015, rule list/create/edit and the approved Scheduled Rule, Deadline Lock and Earn First authoring states
- S-001 through S-005, Always Allowed and School Access states
- deterministic presentation models, mock data, navigation/review states and tests needed for those screens
- Release Simulator review captures for representative rule and school-access screens, accessibility-large states and existing Parent/Child/Teen regression targets

Stop before UI-06. Do not implement C-002 through C-011, P-024 through P-028 or A-001 through A-003 except as existing navigation placeholders/regression targets.

## Rule authoring contract
A rule is composed from the approved WHO / WHEN / CONTROLS / CONDITION / ACTION / EXCEPTIONS structure. V1 rule types are Scheduled Rule, Deadline Lock and Earn First.

Rule creation must let the parent choose the child, rule type, controlled targets, relevant timing/condition, verification type where applicable, and review before saving. Suggested/starter patterns may prefill fields but every field remains editable before confirmation.

Use Apple's `FamilyActivityPicker` semantics for app/site selection. Do not invent a Themis app catalogue or claim Apple metadata Themis does not receive.

Generic real-world tasks such as Homework use Parent Approval. Automatic Verification may only be offered where the approved deterministic in-app timer/focus-session evidence exists. Do not imply that a completed timer proves the underlying real-world activity happened.

Scheduled Rule follows the child device's local time zone. Do not invent a home-vs-travel time-zone configuration.

Deadline Lock must communicate the approved 30-minute Approval Grace Period accurately. A pre-deadline submission awaiting approval is not an indefinite bypass. Approval within grace avoids the lock, rejection activates it immediately, unresolved grace expiry activates it, and later approval clears only that Deadline Lock restriction.

Earn First starts with the configured target restricted and grants the fixed configured reward/access duration only after the approved condition resolves complete. Do not silently renegotiate reward duration per instance.

Multiple restrictions use the effective-enforcement model, not rule-type precedence. Clearing one rule must never claim a target is unlocked if another active restriction still covers it.

Offline/pending presentation must remain honest. A rule saved while the child device is offline is Pending sync, not falsely Active on-device.

## Always Allowed contract
Always Allowed is absolute in the product model and wins over restrictive rules.

If a parent marks a currently restricted target Always Allowed, automatically remove it from restrictive target lists and explicitly tell the parent what changed. Do not silently narrow rules.

If a target is already Always Allowed, block adding it to a new restrictive rule with a clear explanation.

Emergency calling and OS-level emergency functionality are never deliberately restricted and cannot be overridden by a parent.

Phone, Messages and Maps are recommended defaults only where technically supported. Messages and Maps remain parent-configurable. Do not claim exact shield behaviour before OQ-30 is proven.

## School Access contract
School Mode/School Access is platform-agnostic. It consists only of:
- parent-selected Always Allowed school apps/sites
- a school-hours schedule that restricts configured entertainment targets
- temporary educational access requests enabled by default

Do not build or imply a definitive UK school-platform directory. Suggested examples may be shown only as optional research-based starter suggestions if they exist in the approved final design, never as guaranteed named integrations.

Never claim Themis can distinguish educational from entertainment content inside the same app/site.

Temporary school access reuses the general Request/Grant lifecycle. Do not create a separate business-rule path in UI-05.

School/essential-access guidance must preserve the V1 single-device-per-child assumption and must not imply correctly separated per-child configuration on a shared sibling device.

## Apple/backend boundaries
This slice is mock/presentation driven. Do not add production Supabase, Family Controls enforcement, DeviceActivity behaviour or unproven Apple capability. Apple/system-owned authorisation and picker surfaces remain system-owned.

Production Family Controls entitlement, real-device timing/shield spikes and OQ-30 remain unresolved gates. Do not weaken privacy, safeguarding, emergency-access or capability-honesty requirements.

## Implementation
Reuse UI-01 semantic tokens/components and verified UI-02/UI-03/UI-04 patterns. Keep Parent visual hierarchy consistent with P-023 and onboarding. Use native `NavigationStack`, sheets, confirmation dialogs, `DatePicker`, segmented `Picker`, `Toggle` and other approved system controls.

Keep status glyph + word, status chips single-line, 44pt+ touch targets, Dynamic Type, VoiceOver grouping/order, Reduce Motion, long-copy handling and keyboard-safe actions. Keep display state separate from future persistence and Apple/backend services.

Provide deterministic review states for:
- rules list with representative Scheduled Rule, Deadline Lock and Earn First entries
- create/edit flow for each V1 rule type
- Deadline Lock approval-grace explanation/state
- Always Allowed normal state and restrictive-rule conflict disclosure
- School Access configured state
- capability-honest essential-access guidance
- at least one approved accessibility-large rules state
- at least one approved accessibility-large school-access state

## Tests
At minimum verify:
- all three V1 rule types are represented
- starter patterns remain editable
- generic Homework cannot select Automatic Verification
- Deadline Lock uses the 30-minute grace semantics
- Earn First reward duration is fixed at rule configuration
- effective enforcement never reports false unlock when another restriction remains
- offline-created rule presentation is Pending sync
- Always Allowed removes conflicting restrictive targeting with explicit disclosure
- Always Allowed targets cannot be re-added to restrictive rules
- emergency calling floor cannot be configured away
- Phone/Messages/Maps wording remains where-supported/spike-gated
- School Access is platform-agnostic and does not claim within-app content classification
- temporary school access is presented as the existing Request/Grant mechanism
- single-device-per-child assumption is visible where required
- existing UI-01 through UI-04 tests remain green

## Verification
Run repository checks. Real macOS Xcode build and full XCTest must pass in GitHub Actions. Release Simulator captures must be reviewed manually against the approved final design at standard and approved large-text sizes. Preserve Parent, Sam Child, Maya Teen and onboarding regression captures when shared components change.

Fix visual/accessibility defects found, rerun affected verification and merge only when clean.

Update `CURRENT_STATE.md`, `BUILD_LOG.md` and `IMPLEMENTATION_DECISIONS.md` only as justified by real implementation evidence/decisions. Reconcile Airtable only after evidence exists.

STOP after UI-05. Do not begin UI-06 in the same run. Report files changed, states implemented, checks, branch/commit/PR, CI, visual review and any design deviation.
