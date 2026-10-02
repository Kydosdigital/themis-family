# Claude Code UI-06 Tasks + Deadline Lock Prompt

Implement UI-06 Tasks + Deadline Lock only on `feat/ui-06-tasks-deadline-lock`.

Base SHA: `231a00fd4ee72854df7698c3ad5dcbf47e47f042`

## Source of truth
Read `docs/implementation/CURRENT_STATE.md`, `docs/implementation/MOBILE_UX_BLUEPRINT.md`, `docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md`, `docs/implementation/DESIGN_PASS5_APPROVAL.md`, `docs/10_RULE_ENGINE_SPECIFICATION.md`, `docs/11_TASK_AND_APPROVAL_SPECIFICATION.md`, `docs/18_ROLES_AND_PERMISSIONS.md`, `docs/26_ERROR_AND_EDGE_CASE_CATALOGUE.md`, the approved requirements baseline, and the final Claude Design/System/Engineering Handoff package.

Requirements control behaviour. Final approved design controls visuals and interaction. Do not redesign approved UX or invent missing product behaviour.

UI-01 through UI-05 are merged and are regression authority.

## Scope
Implement UI-06 only:

Child / Teen:
- C-002 Task detail
- C-003 Submit task
- C-004 Submitted on time / waiting approval
- C-005 Provisional Approval Grace
- C-006 Approved / access state
- C-007 Homework overdue
- C-008 Games are paused
- C-009 Submit while restricted
- C-010 Waiting while restricted
- C-011 Multiple restrictions

Parent:
- P-024 Parent receives action
- P-025 Task review
- P-026 Approve task
- P-027 Approved, waiting for device application
- P-028 Applied on device / protection current

Action Centre:
- A-001 task-focused Action Centre state
- A-002 Task review
- A-003 Reject / Needs work

Also include the deterministic presentation models, mock repository/state transitions, navigation, tests, previews/review roots, and Release Simulator capture coverage required to verify these screens.

Stop before UI-07. Do not implement Q-001 through Q-014 or A-004 through A-011 except as existing placeholders or regression destinations. Do not implement Free Pass, Protection, Activity, Settings, Subscription, backend enforcement, or Apple production logic.

## Canonical family and task
Use the approved canonical household:
- Sarah = Owner
- Sam = Child experience
- Maya = Teen experience
- canonical Deadline Lock task = Homework
- deadline = 6:00 PM
- controlled targets = Roblox and Minecraft
- verification = Parent Approval

Owner and Guardian both may approve or reject task completion. Child/Teen may submit only their own task.

## Deadline Lock contract
The approved Provisional Approval Grace model is binding.

Before deadline:
- controlled targets remain available
- if the task is approved before deadline, no Deadline Lock applies

Pre-deadline submission still awaiting approval when 6:00 PM arrives:
- state becomes "Submitted On Time, Awaiting Approval"
- a fixed 30-minute Approval Grace Period begins at the deadline
- controlled targets remain available during grace
- child-facing copy is calm and explicit, e.g. "Submitted on time. Waiting for approval."
- show remaining grace honestly, e.g. "Approval grace ends in 18 min."

During grace:
- approval means no Deadline Lock occurs
- rejection activates the Deadline Lock immediately
- unresolved grace expiry activates the Deadline Lock automatically

After grace expiry:
- the lock remains active until approval
- later approval clears only this Deadline Lock restriction
- effective enforcement must then be recomputed against every other active restriction

Always Allowed and school/essential access remain unaffected throughout.

Do not model the grace period as an indefinite bypass, a reward, or a punishment.

## Task submission contract
For Parent Approval tasks:
- Available or Overdue may be submitted
- successful submission moves to Awaiting Approval
- all eligible approvers are notified in the product model
- the child sees an honest waiting state

Offline submission:
- show a queued/submitting state such as "Submitting..."
- do NOT show Awaiting Approval until the backend-recorded submission is represented as successful
- do not silently discard the action

Homework and other generic real-world tasks use Parent Approval. Do not introduce Automatic Verification for generic Homework.

## Approval and rejection contract
Parent task review must support:
- Approve
- Reject / Needs work

Approve:
- task decision becomes approved/completed on the parent side
- distinguish backend approval from device application
- P-027 must say approval is recorded but the child device has not yet confirmed application
- P-028 is only shown after deterministic device acknowledgement in the mock model

If the child device is offline:
- the approval remains recorded
- do not claim the device has applied the change
- continue to show the honest pending/application state

Reject / Needs work:
- returns the task to Overdue, or Available if still before deadline
- an explanatory note is optional
- UI should encourage a short note without making it mandatory
- this note is one-way only
- do not create an open chat/conversation thread

For a Deadline Lock task:
- rejection during the 30-minute grace activates the lock immediately
- rejection after deadline while already restricted keeps the appropriate restriction in place

## Non-response / reminder contract
Awaiting Approval never auto-approves in V1.

Represent the approved reminder behaviour where the design/state requires it:
- immediate approver notification at submission
- exactly one automatic reminder at 15 minutes if still unresolved
- exactly one child/teen manual "Send a reminder" nudge per pending item
- the manual nudge and automatic 15-minute reminder are independent
- one does not reset, restart, consume, or postpone the other
- after the permitted reminder(s), the task simply remains Awaiting Approval until an adult decides

Provide deterministic waiting variants for nudge available and nudge already used if needed to prove the behaviour.

## Effective-enforcement contract
BR-211 and FR-019 are binding.

There is NO linear rule-type precedence.

A controlled target is available only when every active restriction covering that target has been individually cleared or explicitly overridden.

Clearing the Homework Deadline Lock must never say "Roblox unlocked" or "Games unlocked" if a different active Scheduled Rule or Earn First restriction still covers Roblox.

C-011 must name every active reason that still restricts the target.

Canonical multi-rule example:
- overdue Homework Deadline Lock restricts Roblox
- bedtime Scheduled Rule also restricts Roblox
- Homework is approved
- Deadline Lock clears
- Roblox remains restricted by bedtime
- child sees the change and the remaining reason, e.g. "Homework done. Games are still paused until bedtime ends."

Never display a false global unlock.

Always Allowed is absolute and remains outside restrictive enforcement.

## Approved vs Applied
The UI must preserve the distinction between:
1. adult decision recorded
2. child device applied/acknowledged the resulting enforcement state

Use separate presentation states. Do not collapse these into one optimistic success state.

P-027 is "Approved, waiting for device application".
P-028 is "Applied on device / protection current".

Child-facing C-006 must reflect actual effective state, not merely the parent's approval event.

## Action Centre
A-001 in this slice is task-focused:
- show task items that require adult action
- task rows must make child, task, timing/state, and action need understandable
- support empty/no-task-pending state if already approved in the design
- do not implement request decision flows yet
- if future request rows appear as placeholders, they must not become interactive UI-07 implementations

A-002 may share/reuse the same task review implementation as P-025 if that matches the approved navigation model.

A-003 is the bounded Needs work/rejection flow with optional one-way note.

## Child and Teen treatment
Use the existing shared components and audience system.

Child:
- warm, reassuring, larger targets
- simple and neutral wording
- no punitive language

Teen:
- mature, autonomy-respecting treatment
- same behavioural truth, slightly more restrained information hierarchy

Never use:
- "You failed"
- "You broke the rule"
- "Punishment"
- shame-oriented language

Preferred concepts:
- "Homework was due at 6:00 PM."
- "Submitted on time. Waiting for approval."
- "Waiting for approval. Games are paused until this is reviewed."
- "Games are paused."
- "Need a little longer? Ask for more time." only as a placeholder/destination to UI-07, not an implemented request flow

## Apple/backend boundary
UI-06 is presentation/mock driven.

Do NOT add:
- production Supabase/Neon task persistence
- push notification implementation
- production Family Controls / ManagedSettings enforcement
- real DeviceActivity timing
- fake Apple-owned UI
- unverified Phone/Messages/Maps behaviour

Use deterministic mock states to represent:
- local deadline arrival
- 30-minute grace
- submission status
- approval/rejection
- pending device application
- device acknowledgement
- multiple active restrictions

Preserve all Apple/backend/privacy/legal gates.

## Implementation guidance
Reuse UI-01 design tokens/primitives and the verified UI-02 through UI-05 navigation/status patterns.

Prefer feature-local models and repository interfaces that can later be replaced by production persistence without changing approved presentation semantics.

Use native iOS patterns:
- NavigationStack
- sheets / confirmation sheets
- buttons and status rows
- existing Themis cards/timeline/status primitives

Preserve:
- status icon + word, not colour alone
- single-line status chips where status chips are used
- 44pt+ touch targets
- Dynamic Type
- VoiceOver grouping/order
- keyboard-safe optional note entry
- Reduce Motion
- scrollability at accessibility sizes

## Required deterministic review states
Create explicit review entry points for at least:
- C-002 Homework task detail before deadline
- C-004 submitted on time before deadline
- C-005 Approval Grace with a deterministic remaining time such as 18 min
- C-007 overdue
- C-008 games paused
- C-010 waiting while restricted
- C-011 multiple restrictions
- A-001 task Action Centre
- A-002/P-025 task review
- A-003 Needs work
- P-027 approved / device pending
- P-028 applied on device
- at least one Child accessibility-large state
- at least one Parent accessibility-large state
- existing Parent Home, Child Home, Teen Home, Rules/School Access and onboarding regression roots

Do not wait until the end to add visual-review launch wiring.

## Visual review workflow
Extend the Release Simulator workflow during implementation, before final CI, so the final candidate head captures UI-06 itself.

At minimum capture representative:
- C-002 or C-004 standard
- C-005 grace standard
- C-008/C-010 restricted standard
- C-011 multiple restrictions standard
- A-001 or A-002 parent standard
- P-027/P-028 approved-vs-applied distinction
- one Child accessibility-large state
- one Parent accessibility-large state
- existing regression targets

The visual workflow passing without UI-06 screenshots does NOT count as UI-06 visual verification.

## Tests
At minimum prove:
- generic Homework uses Parent Approval
- only the task owner can submit that task in the presentation model
- offline submission is queued/submitting, not falsely Awaiting Approval
- pre-deadline submission awaiting approval enters a fixed 30-minute grace at deadline
- approval during grace avoids the Deadline Lock
- rejection during grace activates the lock immediately
- unresolved grace expiry activates the lock
- no Awaiting Approval task auto-approves
- one automatic 15-minute reminder and one manual nudge are independent and bounded
- rejection note is optional and one-way
- Owner and Guardian may approve/reject, first valid durable decision wins in the deterministic model
- approval recorded does not equal device applied
- child-device-offline approval remains pending application
- device acknowledgement is required before P-028/applied state
- effective enforcement never reports a false unlock
- multiple-restriction state names every active restriction
- clearing Deadline Lock while bedtime remains does not make Roblox available
- Always Allowed remains available
- existing UI-01 through UI-05 tests remain green

## Verification gate
Before merge:
1. repository/workflow validation
2. real macOS/Xcode build
3. full XCTest
4. Release Simulator visual review that actually includes UI-06 screens
5. manual inspection of UI-06 standard/accessibility captures
6. regression inspection for affected existing screens

Fix defects and rerun affected gates.

Only after all evidence is green:
- mark the PR ready
- merge UI-06
- reconcile CURRENT_STATE, BUILD_LOG and Airtable
- then UI-07 may begin

Do not call UI-06 complete from source code alone or from green CI that lacks UI-06 visual evidence.
