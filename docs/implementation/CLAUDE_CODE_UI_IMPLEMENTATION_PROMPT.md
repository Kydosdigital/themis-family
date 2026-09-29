# Claude Code Prompt — Implement the Approved Themis Family SwiftUI UI

The Themis Family mobile UX/UI design process is complete and approved.

Repository:
https://github.com/Kydosdigital/themis-family

You are now implementing the approved native iOS/iPadOS UI in SwiftUI.

## Read before touching code

Read:
- `CLAUDE.md`
- `docs/implementation/CURRENT_STATE.md`
- `docs/implementation/DESIGN_PASS5_APPROVAL.md`
- `docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `docs/implementation/DESIGN_PASS2_DECISION.md`
- `docs/implementation/DESIGN_PASS3_APPROVAL.md`
- `docs/implementation/DESIGN_PASS4_APPROVAL.md`
- `.claude/rules/ios.md`
- `.claude/rules/swiftui.md`
- `.claude/rules/design-system.md`
- `.claude/rules/testing.md`
- `.claude/rules/security.md`

Also use the final Claude Design package handed to this session:
- Themis Final Prototype
- Themis Design System
- Themis Engineering Handoff

The design package is the visual/interaction source of truth.
The repository requirements remain the behaviour source of truth.

If the final design frames/boards are not actually accessible in this Claude Code session, do not invent layouts. You may implement/reconcile foundation tokens and primitives, then report the missing design artifact before screen-by-screen visual work.

## Critical boundaries

This is a native SwiftUI app.

Do not:
- build web-style UI
- embed ordinary app screens in WebViews
- use React/Tailwind patterns
- fabricate Apple-owned UI
- alter approved product behaviour
- change frozen requirement docs
- connect an unrelated Supabase project
- implement unverified production enforcement behind visual assumptions
- claim a spike result that has not been recorded

The current repository contains mock-driven frontend foundation code. Treat it as scaffolding, not the visual authority.

Refactor or replace mock layouts where necessary to match the approved design.

## Backend state

Frontend-first remains the plan.

Use protocols/repositories and mock data for UI implementation.

Do not wire production Supabase until the separate Themis Supabase project is available and backend work is explicitly opened.

Keep screen code independent from mock storage details.

## Apple state

Production Screen Time enforcement remains gated.

You MAY:
- build the approved visual states
- build mock state transitions
- add interfaces/protocols for future Apple integrations
- use Apple frameworks for compile-safe scaffolding where entitlement-independent

You MUST NOT:
- turn spike-dependent behaviour into production truth
- remove the existing entitlement/spike gates
- assume instant remote application
- assume Phone/Messages/Maps shielding behaviour
- assume parent-device DeviceActivityReport support
- invent staleness thresholds

## Existing build setup

The project uses:
- `apps/ios/project.yml`
- XcodeGen
- iOS 17+
- Swift 5.10
- `scripts/verify_ios.sh`

Before substantial implementation:
1. generate/open the project locally
2. compile the current scaffold
3. fix any pre-existing compile issues
4. run the repository verification scripts
5. record verification in CURRENT_STATE / BUILD_LOG as required by the project workflow

Do not claim SwiftUI compilation passed unless it actually ran on macOS/Xcode.

## Implementation order

Follow the approved handoff sequence.

### Stage 1 — Design tokens

Implement the approved semantic system:
- brand colours
- text colours
- backgrounds
- surfaces
- status fills/tints
- timeline colours
- borders
- shadows
- radii
- spacing
- touch sizes
- audience variants

No raw hex values scattered through feature views.

Use named semantic assets/constants.

### Stage 2 — Typography

Integrate Manrope using the approved roles and Dynamic Type strategy.

Implement:
- display
- numeral
- page title
- screen title
- headline
- row title
- body
- secondary
- meta
- section label
- caption
- button

Preserve Parent / Child / Teen variants.

If the Manrope font asset is not yet present locally, do not download or commit an arbitrary font silently. Implement the typography API with a clearly documented temporary system-font fallback and record the asset dependency.

### Stage 3 — Reusable primitives

Implement/refactor the approved reusable components before feature screens.

Use the handoff's stable component concepts, including:
- ThemisButton
- StatusBadge / status presentation
- InlineBanner
- KeyValueList
- ChecklistList
- SectionHeader
- ReasonField
- ChoiceChips
- StepProgress
- ChildSelector
- AgreementTimeline
- StackedTimelineList
- CountdownRing
- EmptyStateView
- LoadingStateView
- ErrorStateView

Use native SwiftUI controls internally where the handoff says native.

### Stage 4 — Status system

Create one shared status model/style system covering the approved variants:
- Protected
- Sync Pending
- Device Offline
- Needs Attention
- Protection Unavailable
- Not active yet
- Unconfirmed
- Due
- Waiting
- Grace
- Overdue
- Approved
- Cleared
- Needs you
- Pending
- Needs your reply
- Partially approved
- Declined
- Expired
- Resolved
- Waiting to send
- Free Pass active
- Overridden
- Sending
- Access revoked
- Active
- Payment
- Cancelled
- Protection ended
- Applying
- Applied on device
- Removing
- Paused
- Completed
- Not finished
- Approved, timing unverified

Every status must include icon/glyph + text. Never colour only.

### Stage 5 — Navigation shell

Implement:
- Parent TabView
- Child/Teen TabView
- NavigationStack
- iPad NavigationSplitView/adaptive behaviour
- PageHeader
- BellButton
- sheets/confirmation architecture

Tabs:

Parent:
- Home
- Rules
- Activity
- Settings

Child/Teen:
- Home
- My Rules
- Requests

Do not add tabs.

### Stage 6 — Parent Home

Implement P-023 and approved states.

Priority:
1. Needs You
2. children/protection
3. current agreements
4. quick actions

Implement:
- NeedsYouCard
- GraceBar
- ChildStatusRow
- QuickActionDock
- setup-incomplete state
- protection-problem state
- nothing-pending state

At accessibility text sizes, quick actions move inline and never cover content.

### Stage 7 — Child and Teen Home

Implement:
- C-001
- C-001 · Teen
- C-012
- C-013
- C-013 · Teen
- C-014

Use the shared system:
- Child = warmer, larger, simpler
- Teen = mature, restrained, closer to Parent
- same privacy facts

Implement AgreementTimeline plus stacked fallback.

### Stage 8 — Onboarding and rule creation

Implement P-001 through P-022, P-010 variants, R-001 through R-015 and S-001 through S-005.

Respect:
- Account Created != Protection Activated
- P-008/P-014/P-021 are lightweight states
- generic homework uses Parent Approval
- Always Allowed wins absolutely
- Apple-owned UI uses real Apple APIs or a clearly isolated mock adapter while unavailable
- protection test is mandatory before actual Activated state
- child device already-paired recovery remains secure and blocking

### Stage 9 — Task/approval

Implement:
- C-002 through C-011
- P-024 through P-028
- A-001 through A-003

Preserve:
- on-time submission
- grace
- overdue
- Approved -> Applying -> Applied
- multiple restrictions
- timing-unverified normal review path

Never say everything is unlocked when another restriction still applies.

### Stage 10 — Requests

Implement Q-001 through Q-014 and A-004 through A-011.

Preserve:
- one automatic 15-minute reminder
- one child nudge
- exactly one clarification question + one reply
- first valid adult decision wins
- partial approval
- Approved vs Applied distinction where relevant

### Stage 11 — Free Pass

Implement F-001 through F-010.

Preserve:
- explicit scope
- duration
- current override preview
- disclosure of a scheduled rule beginning during the pass
- Revocation sent vs Access revoked

### Stage 12 — Protection

Implement P-029/P-030/P-031 families and permission-revoked states.

Use honest states:
- Protected
- Sync Pending
- Device Offline
- Needs Attention
- Protection Unavailable

Always show Last verified where designed.

Do not invent OQ-19 threshold.

### Stage 13 — Activity

Implement T-001 through T-006 and timing variants.

Activity is outcome reporting, not surveillance.

Apple Screen Time report remains Apple-owned and spike-dependent.

Never imply raw Apple Screen Time data is stored by Themis.

### Stage 14 — Settings

Implement ST-001 through ST-012, P-032 through P-034 and support/safeguarding screens.

Respect Owner vs Guardian permissions.

Support cannot act as the parent.

Safeguarding operational content remains placeholder/gated until approved.

### Stage 15 — Subscription

Implement B-001 through B-008 visually/mock-driven.

Do not invent pricing/trial.

Preserve:
- full service during Billing Grace
- Protection Expired clears Themis restrictions
- resubscription after expiry does not silently re-lock
- explicit review/reactivation
- Reactivation sent -> Protection active on device

ST-011 household deletion UI may be implemented, but do not finalise its production App Store billing side-effects until the requirements clarification in ENGINEERING_HANDOFF_FINAL_REVIEW.md is resolved.

### Stage 16 — Edge states

Implement all approved empty/error/offline/permission/timing/session edge states.

Use exact copy:
"Timing could not be verified."

### Stage 17 — iPad

Implement approved adaptive treatments for:
- P-023
- R-001
- A-001
- C-001
- T-001
- ST-001

Use native adaptive navigation.

Do not turn iPad into a desktop dashboard.

### Stage 18 — Accessibility polish

Verify:
- Dynamic Type
- stacked timelines
- inline quick actions
- stacked key/value rows
- VoiceOver order/grouping
- status text
- Reduce Motion
- keyboard behaviour
- long names
- long copy
- iPad accessibility

### Stage 19 — Motion polish

Implement approved motion only:
- Welcome timeline reveal
- Protection Activated
- Approved -> Applying -> Applied
- status changes
- button press
- whole-minute countdown
- session timer
- now marker
- lightweight state auto-advance

Every motion must have the documented Reduce Motion behaviour.

## Screenshot comparison

For each completed visual slice:
- render in Simulator
- compare against the approved Claude Design frame
- test at default Dynamic Type
- test at least one accessibility size
- check iPad where applicable

Do not declare a screen complete without comparison.

## Testing

Add unit/view-model tests for state logic that does not require Apple frameworks.

Keep mock scenarios for:
- normal
- overdue
- waiting approval
- approval grace
- multiple restrictions
- offline
- sync pending
- protection unavailable
- Free Pass
- billing grace
- protection expired
- timing unverified
- no children
- no rules
- request states

Do not delete useful existing mock scenarios merely because the UI changed.

## Git discipline

Use focused commits.

Do not modify frozen requirements.

Update:
- `docs/implementation/CURRENT_STATE.md`
- `docs/implementation/BUILD_LOG.md`
- implementation decisions only when a real new implementation decision is needed

Run repository verification before commit.

Do not leave CURRENT_STATE as IN_PROGRESS when stopping.

## First execution slice

Do NOT try to implement all 216 screens in one context.

Start with:

**Slice UI-01: Design System Foundation**
- tokens
- typography API
- reusable primitives
- status system
- navigation shell
- unit tests for semantic status mappings where appropriate
- local Xcode verification

Then stop, verify, commit, and report:
- files changed
- build/test results
- screenshots/visual comparison where available
- any discrepancy with the approved design

After UI-01 is verified, proceed through small vertical slices using the approved implementation order.

## Final reminder

The design is approved.

Do not redesign it while coding.

If SwiftUI/platform constraints require a change:
1. document the constraint
2. preserve product behaviour
3. propose the smallest design deviation
4. flag it for review rather than silently improvising
