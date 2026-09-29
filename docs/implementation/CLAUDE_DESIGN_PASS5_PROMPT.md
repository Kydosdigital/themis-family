# Claude Design Pass 5 Prompt

Pass 4 is approved, subject only to the final render check already in progress.

Purpose: complete final prototype QA and prepare an implementation-ready SwiftUI handoff. Do not redesign the product, add features, change approved requirements, or write production code.

Read:
- docs/implementation/DESIGN_PASS4_APPROVAL.md
- docs/implementation/DESIGN_PASS4_REVIEW.md
- docs/implementation/DESIGN_PASS3_APPROVAL.md
- docs/implementation/DESIGN_PASS2_DECISION.md
- docs/implementation/MOBILE_UX_BLUEPRINT.md
- docs/implementation/DESIGN_REVIEW_CHECKLIST.md
- docs/32_TRACEABILITY_MATRIX.md
- docs/34_OPEN_QUESTIONS.md
- docs/36_MVP_VS_LATER_FEATURE_MATRIX.md
- docs/38_DEFINITION_OF_DONE.md

## 1. Final render check

Inspect:
- A-002 · Timing
- T-002 · Timing
- B-002 · Cancelled

Confirm no clipping, broken wrapping, unreadable timestamps or large-text failures.

Fix rendering defects only.

## 2. Full prototype QA

Run every critical path from Passes 1–4, including:
- onboarding and Protection Activated
- pairing and recovery
- first Homework Deadline rule
- task submission, grace, overdue, approval
- Approved → Applying → Applied
- multiple restrictions
- request / partial approval / clarification / reminder
- Free Pass grant and revoke
- Active Engagement and Focus Sessions
- Activity and Apple Screen Time boundary
- timing-unverified approval and history
- Billing Grace, Protection Expired, resubscription and explicit reactivation
- Settings, Guardian, privacy, support and safeguarding
- child/device management
- ownership flows
- major error/offline/permission states
- iPad navigation and layouts

Check forward, back, cancel, retry and cross-device handoffs.

## 3. Consistency audit

Check the whole design for:
- UK English
- neutral child/teen tone
- no unsupported Apple claims
- no false Protected state
- no accidental claim that Themis stores raw Apple Screen Time data
- no generic "unlocked" if another rule still applies
- no automatic verification claim for real-world homework
- no final pricing/trial invented
- no final safeguarding procedure invented
- consistent tokens, typography, status components and buttons
- no purple
- Parent/Child/Teen still feel like one product
- native navigation and Apple-owned UI handoffs remain clear

## 4. Accessibility design QA

Test representative screens at default, about 135% and about 170% text size.

Include:
- Parent Home
- Child Home
- Teen Home
- Action Centre
- Activity
- Settings
- subscription warning
- request detail
- Free Pass
- destructive confirmation
- iPad

Check:
- scrolling
- stacked timeline fallback
- inline quick-action fallback
- long names
- long copy
- touch targets
- VoiceOver order
- no colour-only meaning
- Reduced Motion
- keyboard/input states

Label the result:
"Design QA complete — implementation verification still required."

## 5. Engineering Handoff board

Create a dedicated Engineering Handoff board containing:

### Screen inventory
For every approved screen/state:
- screen ID
- name
- audience
- device
- entry point
- key states
- prototype flow

Keep existing IDs.

### Component inventory
Define stable SwiftUI-oriented component names for the reusable system, including:
- buttons
- status
- action container
- child status row
- rule row
- task card
- request row
- protection card
- setup-incomplete card
- Free Pass card
- activity row
- banner
- timeline
- stacked timeline fallback
- navigation
- sheets
- Apple-owned handoff
- empty/loading/error states
- section header
- child selector
- time selection
- segmented choice
- reason field

### Token sheet
Provide exact approved:
- colours
- typography roles
- spacing
- radii
- borders
- shadows
- motion
- touch heights
- Parent / Child / Teen variants

Mark fixed, semantic, adaptive and provisional values.

### SF Symbols map
Map placeholder glyphs to recommended SF Symbols where appropriate.

### Native vs custom controls
For each interaction, mark:
- native SwiftUI
- native/system sheet
- Apple-owned UI
- custom Themis component

### Motion spec
Document trigger, duration, curve, state change and Reduced Motion alternative for approved animations.

### State matrix
Show all visual variants for:
- Protection
- task
- request
- Free Pass
- subscription
- sync/offline
- approval/application
- sessions
- timing integrity

## 6. Screen-to-requirement matrix

Map each screen ID to:
- actual requirement/business-rule references
- shared/backend state
- child-device state
- Apple dependency
- spike dependency
- offline behaviour
- notification dependency
- accessibility special case

Do not invent references. If uncertain, write:
"Traceability check required."

## 7. Spike-dependent design flags

List screens that remain technically provisional for:
- Family Controls production entitlement
- remote approval → applied timing
- Phone/Messages/Maps shield behaviour
- terminated-app scheduled transitions
- shield persistence/removal
- Apple Screen Time parent-device reporting
- trusted-time reliability
- compromised-device timing integrity

For each, state:
- what UX/product behaviour is approved
- what technical behaviour is still unverified
- what copy must remain conservative

Do not resolve spike questions in design.

## 8. Asset register

List:
- Manrope requirement
- temporary wordmark status
- custom artwork if any
- colour/token source
- animation assets if any

Do not invent a final logo.

## 9. Recommended SwiftUI implementation order

Provide an implementation sequence based on component reuse and dependency:

1. design tokens
2. typography
3. reusable primitives
4. status system
5. navigation shell
6. Parent Home
7. Child/Teen Home
8. rule creation
9. task/approval
10. requests
11. Free Pass
12. protection states
13. Activity
14. Settings
15. Subscription
16. edge states
17. iPad adaptations
18. accessibility polish
19. motion polish

Reference the screen IDs each group unlocks.

## 10. Design-to-code acceptance checklist

For each implemented screen, engineering should verify:
- correct screen ID
- semantic tokens
- typography
- native/custom control choice
- normal state
- loading/error/offline state
- large text
- VoiceOver
- Reduced Motion
- iPad where applicable
- screenshot comparison with approved frame
- no unsupported product claim

## 11. Final handoff summary

Create four sections:

### Approved
What is fully ready for implementation.

### Provisional
What is visually approved but still spike-dependent.

### Not final
Include:
- final logo
- final pricing
- final trial length
- safeguarding operational content
- exact Apple spike outcomes
- exact protection staleness threshold
- final legal copy

### Engineering readiness
State whether Claude Code may begin implementing the approved UI.

Only say YES if final QA passes.

## Deliverables

Finish with:
1. final clickable prototype
2. final screen inventory
3. final Design System board
4. Engineering Handoff board
5. screen-to-requirement matrix
6. spike-dependency list
7. asset register
8. SwiftUI implementation order
9. design-to-code acceptance checklist
10. final founder handoff summary

STOP after Pass 5.

Do not write production SwiftUI code.
Wait for founder approval before handing the package to Claude Code.
