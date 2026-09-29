# Master Prompt for Claude Design: Themis Family Mobile App

Use the **Mobile app design** template.

The GitHub codebase `Kydosdigital/themis-family` is connected. Read it as product/design context, especially:
- `docs/00_PRODUCT_OVERVIEW.md`
- `docs/04_USER_JOURNEYS.md`
- `docs/14_PARENT_EXPERIENCE.md`
- `docs/15_CHILD_AND_TEEN_EXPERIENCE.md`
- `docs/21_NOTIFICATIONS.md`
- `docs/23_PRIVACY_AND_CHILD_SAFETY.md`
- `docs/26_ERROR_AND_EDGE_CASE_CATALOGUE.md`
- `docs/36_MVP_VS_LATER_FEATURE_MATRIX.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `.claude/rules/design-system.md`
- `.claude/rules/swiftui.md`

Do not treat the current SwiftUI prototype as the design authority. It is a disposable frontend foundation/mock. The approved requirements and MOBILE_UX_BLUEPRINT are the source of truth.

## Build the design in passes, not one giant generation

This is one design project, but do not attempt to render every screen/state in one generation.

Work in this order and keep the same screen IDs/components throughout:

**Pass 1 — Architecture and low-fi**
- information architecture
- navigation
- complete screen map
- first-time setup flow
- Deadline Lock core loop
- requests/Free Pass/protection/subscription journey maps
- low-fidelity wireframes for all primary screens

STOP and present the architecture/wireframes for review before polishing everything.

**Pass 2 — Visual direction**
- create 2–3 visual explorations for P-002, P-023 and C-001
- compare them
- recommend one direction
- apply founder feedback
- lock the design system

**Pass 3 — High-fidelity core journeys**
- onboarding
- Parent Home
- Child and Teen Home
- rules
- tasks
- approvals
- requests
- Free Pass
- school/essential access

**Pass 4 — States and supporting areas**
- protection states and recovery
- reporting
- subscription
- settings
- loading/error/offline/empty states
- iPad adaptations
- accessibility stress tests

**Pass 5 — Prototype QA and handoff**
- connect all critical prototype paths
- run your UX/accessibility critique
- fix inconsistencies
- prepare handoff to Claude Code

Do not renumber frames between passes.


## Your role

Act as a senior iOS product designer, UX architect, interaction designer and design-system lead.

Your job is to design the complete V1 mobile product experience for **Themis Family** before production UI implementation continues.

Do not only create a few hero screens.

Create:
1. the mobile information architecture
2. the complete screen map
3. the key parent and child/teen user journeys
4. low-fidelity interaction structure
5. a cohesive high-fidelity mobile design system
6. the important state variants
7. a clickable prototype covering the critical end-to-end flows
8. design rationale and identified UX risks

The result must be detailed enough that Claude Code can later implement approved screens without inventing layouts as it goes.

## Product

Name: **Themis Family**

Tagline:
**Clear digital boundaries without the daily arguments.**

Core promise:
**Set clear digital rules once, and let the phone enforce them.**

Themis helps families agree digital boundaries around homework, bedtime, gaming, social apps and school access.

The product is NOT positioned as spyware or punishment.

Its differentiators are:
- visible family agreements
- clear consequences
- negotiation/request flows
- reliable enforcement
- respectful Teen UX
- school/essential access by design
- privacy-first controls

Primary market for V1:
UK families using iPhone/iPad.

Primary child range:
approximately 8–15.

Two UX segments:
- Child: roughly 8–12
- Teen: roughly 13–15

The parent chooses Child or Teen experience explicitly. Do NOT ask for exact DOB merely to choose the interface.

## Critical product philosophy

This product should feel like:
"the family agreed this boundary and the phone is consistently applying it"

not:
"your parent is spying on/punishing you."

Use logical-consequence framing.

Canonical example:
Homework due at 6:00 PM.
If it is not completed/approved as required, gaming pauses.
School/essential access remains available.
The child can request more time or an exception.

## Native mobile requirement

THIS IS A NATIVE MOBILE APP.

Design iPhone-first.

Do not create:
- a desktop dashboard shrunk into a phone
- dense card grids
- tiny analytics widgets
- side navigation on iPhone
- multi-column desktop forms
- excessive information above the fold

Use native iOS mental models:
- navigation stacks
- bottom tab bars
- sheets
- confirmation dialogs
- toolbar actions
- native time/date selection patterns
- thumb-friendly primary actions
- progressive disclosure
- safe-area awareness
- proper keyboard behaviour

Also show how core screens adapt to iPad without redesigning the product from scratch.

## Proposed navigation

Use this as the primary architecture unless your UX analysis discovers a clear problem. If you believe a different architecture is materially better, show the alternative separately and explain why. Do not silently change it.

Parent bottom tabs:
1. Home
2. Rules
3. Activity
4. Settings

Child/Teen bottom tabs:
1. Home
2. My Rules
3. Requests

Action Centre / notifications is reachable from Parent Home.

## Visual direction

Build a coherent design system first and apply it consistently.

Approved direction:
- lots of white and breathing space
- primary cobalt #2563EB
- mint #34D399
- soft aqua #7DD3FC
- peach #FFB79E
- light grey #E5E7EB
- soft grey #F6F7F9
- dark navy-toned text
- NO PURPLE
- typography direction: Manrope
- premium
- calm
- modern
- polished 2026 consumer product
- warm and family-friendly
- clean rather than playful-chaotic

Avoid:
- cyber-security visuals
- generic shield-heavy aesthetics
- surveillance visuals
- red-heavy punishment states
- literal family silhouettes
- Greek columns
- legal scales
- mythology-heavy styling
- childish illustrations for Teen
- generic "AI app" gradients

The logo is NOT approved.

Do not invent a final logo.
Use a tasteful temporary wordmark or neutral placeholder.

## Design system deliverable

Create reusable design components/tokens for:
- typography hierarchy
- semantic colour roles
- spacing scale
- corner radii
- button variants
- inputs
- segmented controls
- cards
- status badges
- child selector/avatar
- rule cards
- request cards
- task cards
- protection state
- banners
- empty states
- bottom sheets
- confirmation dialogs
- tab bars
- progress/timer presentation
- loading/skeleton patterns
- error/offline states

Do not use colour alone for statuses.

Design with Dynamic Type and VoiceOver in mind.

## Parent onboarding journey

Design the entire clickable flow:

P-001 Launch
P-002 Welcome
P-003 Sign in with Apple
P-004 Account created but protection not active
P-005 "What are you struggling with?"
P-006 Add child
P-007 Choose Child or Teen experience
P-008 Child created
P-009 Pair child's device
P-010 Pairing code / QR
P-011 Explain Family Controls permission
P-012 Apple permission handoff
P-013 Choose first rule starter
P-014 Homework Deadline starter
P-015 Choose controlled apps/sites
P-016 Set deadline
P-017 Verification method
P-018 Always Allowed / School Access
P-019 Review family agreement
P-020 Test protection
P-021 Test result
P-022 Themis Protection Activated
P-023 Parent Home

Use canonical demo content:
Parent: Sarah
Child: Sam
Experience: Child
Goal: Homework
Deadline: 6:00 PM
Controlled: Roblox + Minecraft
Verification: Parent Approval

The onboarding should feel achievable and confidence-building.

Do not put all configuration into one giant form.

Use progressive disclosure.

CRITICAL:
"Account created" must NOT visually imply protection is active.
"Themis Protection Activated" is a later state and must feel meaningfully different.

## Apple-owned UI

When the flow reaches:
- Family Controls authorization
- FamilyActivityPicker / app/site selection
- App Store subscription system UI

do NOT fabricate misleading exact Apple system screens.

Instead:
- clearly indicate a native/system handoff
- design the Themis explanation before it
- design the return state after it
- use a neutral system-sheet representation if needed for prototype continuity

## Parent Home

Design P-023 as a mobile control centre, not an analytics dashboard.

Priority order:
1. urgent/pending actions
2. protection health
3. children
4. current agreement/rules
5. useful quick actions

Show:
- Sarah greeting
- Sam and Maya as example children
- clear protection status with text + icon
- "Last verified" where appropriate
- pending approval/request
- concise rule summary
- quick actions such as Add rule and Free Pass

Protection statuses:
- Protected
- Sync Pending
- Device Offline
- Needs Attention
- Protection Unavailable

Create state variants for each.

Do not show stale state as Protected.

## Child / Teen Home

Design two related but distinct experiences.

### Child example: Sam, 10

Simple language.
Larger targets.
Less density.
Warm but not babyish.

### Teen example: Maya, 14

More mature hierarchy.
More autonomy-respecting language.
No childish illustrations or patronising language.

Both must include:
- "Themis is active"
- what is expected today
- active restriction reasons
- request path
- access to "What can my parent see?"
- access to My Rules

The substance of transparency must be the same between Child and Teen; only presentation/language complexity differs.

## Child transparency

Design a clear screen explaining:

Parents may see:
- Themis rules
- task outcomes
- access requests
- temporary access
- device protection status
- some Screen Time activity Apple makes available through parental reporting

Themis does NOT provide:
- message contents
- private conversation contents
- a full browsing/search-history feed
- a minute-by-minute surveillance feed
- backend access to Apple's raw Screen Time activity data under the UK V1 model

Use age-appropriate language.

Do not expose circumvention-enabling technical detail.

## Deadline Lock core loop

Design the complete parent + child flow.

Before deadline:
"Homework due at 6:00 PM"

If child submits before deadline:
"Submitted on time. Waiting for approval."

At the deadline, if submitted on time:
30-minute Provisional Approval Grace Period begins.

During grace:
targets stay available.

Example:
"Submitted on time. Approval grace ends in 18 min."

If parent approves during grace:
no lock.

If rejected during grace:
lock immediately.

If unresolved when grace expires:
games pause until approved.

After grace:
"Waiting for approval. Games are paused until this is reviewed."

If task was not submitted by deadline:
games pause at deadline.

Do not present this as punishment.

## Multiple active restrictions

This is very important.

If Homework and Bedtime both restrict Roblox:
approving Homework only clears the Homework restriction.

Roblox must remain restricted because Bedtime still applies.

The child UI should explain both active reasons.

Never show:
"Games unlocked"

if another restriction still applies.

Design:
C-011 Multiple restrictions.

## Requests / negotiation

Design the full child request and parent response flow.

Child:
- ask for more time/access
- choose target
- + duration / until time
- optional reason
- review
- submit
- pending
- exactly one "Send reminder" nudge
- clarification question
- exactly one clarification reply
- outcome

Parent:
- request detail
- approve +5
- +15
- +30
- custom
- until selected time
- partial approval
- decline
- ask one clarification

Statuses:
- Pending
- Approved
- Partially Approved
- Declined
- Expired
- Cancelled

There is NO open-ended chat.

First valid guardian decision wins.

Design "already resolved" state for the second guardian.

## Notifications

Design notification examples and in-app destinations but respect lock-screen privacy.

GOOD push:
"Sam sent an access request."

Do not expose:
- free-text request reason
- clarification text
- rejection notes
- sensitive task descriptions
- household diagnostics

Those appear only after authenticated app opening.

Reminder model:
- immediate notification
- exactly one automatic reminder after 15 minutes if unresolved
- child can send exactly one independent nudge
- no repeated notification spam

Do NOT add a separate automatic "grace period about to expire" notification.

## Free Pass

Design:
- entry
- choose child
- choose exact apps/sites/categories
- choose duration
- show which active rules will be temporarily overridden
- confirm
- active state
- revoke
- "Revocation sent"
- "Access revoked"

There is NO unscoped blanket Free Pass default.

The parent explicitly chooses scope.

## School / essential access

Design:
- Always Allowed
- School Access
- optional starter suggestions
- temporary educational access

Do not create a fake national school-app directory.

Parent chooses through Apple-supported app/site selection.

Do not claim Themis can understand whether a specific YouTube video is educational.

Canonical case:
YouTube is restricted during study time.
Child needs a teacher-assigned video.
Child requests temporary YouTube access.
Parent grants 20 minutes.
It automatically expires.

## Emergency access

The product policy is:
Themis never deliberately prevents emergency calling / OS emergency functionality.

Phone, Messages and Maps are recommended Always Allowed defaults where technically supported.

Do NOT make technical claims about which Apple system apps are impossible to shield because that remains a real-device spike question.

## Tasks and approval

Design:
- task detail
- submit
- waiting
- approval grace
- approved
- rejected / needs work
- optional parent note

Rejection note is optional, not mandatory.

No open-ended chat.

## Active Engagement Session

Design an in-app session such as:
"15-minute reading session"

The UI can say:
"15-minute in-app reading session completed."

Do NOT claim the child definitely read every second.

If app backgrounds/locks:
verified timer pauses.

If app terminates:
trustworthy accumulated foreground time is retained where integrity can be verified.

Show interrupted/resumable state without making this technical.

## Focus Session

Design:
"30-minute focus session"

The intended behaviour is staying away from configured distracting apps.

If restricted distracting app is opened:
the attempt is Interrupted.
No completion credit.
The current attempt ends.
Child may restart immediately.

Copy:
"Focus session interrupted. Start again when you're ready."

Never:
"Failed."
"You broke the rule."

## Parent approval UX

Design the distinction between:

"Approved"

and:

"Applied on Sam's device"

Remote approval may not be immediately applied.

Do NOT market or visually imply instant unlock.

Use a pending device-state transition elegantly.

Similarly for early Free Pass revocation:
"Revocation sent"
then
"Access revoked"

## Protection health

Design:
Protected
Sync Pending
Device Offline
Needs Attention
Protection Unavailable

Every state needs:
- clear title
- short explanation
- last verified where relevant
- next useful parent action
- no false reassurance

Create the "Fix this" recovery journey.

## Activity / reporting

Parent reporting should feel useful and restrained.

Category A:
- rules met/missed
- tasks submitted/approved/rejected
- requests/outcomes
- overrides
- protection-state events
- sessions/outcomes

Do NOT design a surveillance feed.

Do NOT imply Themis backend stores raw Apple Screen Time data.

For Apple Screen Time / DeviceActivityReport:
show an embedded/system-owned reporting area conceptually and label the privacy boundary.

## Subscription

Pricing is not final.

Do not invent a final price.

Design the STATE UX:

Active
→ Apple Billing Grace Period
→ Recovered OR Protection Expired

During Apple Billing Grace Period:
full protection remains active.
Parent sees calm warning.

If grace expires:
Themis restrictions are actively cleared.

Do not leave a child indefinitely locked because the parent can no longer manage rules.

If the parent later resubscribes AFTER Protection Expired:
DO NOT silently reactivate old rules.

Show:
"Ready to turn protection back on?"

Then:
- review existing rules
- explicit confirm
- "Reactivation sent"
- "Protection active on device"

## Settings

Design:
- Household
- children/devices
- Guardian
- notifications
- privacy
- support
- subscription
- transfer ownership
- delete household
- account/sign out

Only Owner may:
- manage subscription
- delete household
- remove Guardian
- transfer ownership
- perform destructive account actions

Guardian can manage ordinary family rules/tasks/requests.

Support messaging must make clear:
support can diagnose Themis.
support cannot parent the child.

## Owner exit

Exactly two Owner exit paths:
1. transfer ownership to existing Guardian, then leave
2. delete household

Do not show a path that leaves a household ownerless.

Do not offer direct ownership transfer to a child.

## Accessibility

Design to WCAG 2.2 AA principles where applicable to native mobile.

Include:
- VoiceOver-aware hierarchy
- Dynamic Type
- adequate touch targets
- reduced-motion-friendly interactions
- no colour-only statuses
- readable contrast
- simple child-facing language

Show at least one large-text stress test for Parent Home and Child Home.

## Loading, error and empty states

Do not leave these to engineering.

Design:
- first load
- pull to refresh
- no children
- no rules
- no pending actions
- offline parent app
- child device offline
- permission declined
- permission revoked
- pairing code expired
- pairing failed
- request expired
- task timing could not be verified
- backend unavailable / last-known status

For timing integrity uncertainty use:
"Timing could not be verified."

Do not silently mark it late or automatically credit it.

## Mobile form behaviour

Avoid long all-in-one forms.

Rule creation should be a mobile step flow with visible progress and back navigation.

Keep primary actions reachable.

Do not hide essential actions behind swipe gestures.

Use bottom sheets for short choices.

Use full screens for consequential or multi-step tasks.

## iPad

After the iPhone design is coherent:
show responsive iPad treatments for at least:
- Parent Home
- Rules
- Action Centre
- Child Home

Use more available space, but keep the same information architecture.

Do not invent a separate desktop product.

## Prototype content

Use realistic names/data:
Owner: Sarah
Child: Sam, 10, Child experience
Teen: Maya, 14, Teen experience

Examples:
Sam:
- Homework due 6:00 PM
- Roblox + Minecraft
- Parent Approval

Maya:
- Social apps paused 10:00 PM–7:00 AM
- 30-minute Focus Session
- Instagram +15 minute request

## Screen IDs

Preserve the IDs in:
`docs/implementation/MOBILE_UX_BLUEPRINT.md`

Label screens/frames using those IDs.

This is important for engineering handoff.

For example:
P-023 Parent Home
C-008 Games are paused
A-004 Request detail
F-007 Active Free Pass

## Deliverables

Create:

### 1. Information architecture
A clear visual map of Parent and Child/Teen navigation.

### 2. Journey map
Show:
- first-time setup
- Deadline Lock core loop
- request/exception loop
- Free Pass
- protection recovery
- subscription expiry/reactivation

### 3. Design system page
Tokens, typography, colours, spacing, components and states.

### 4. Low-fidelity screens
Complete enough to validate structure and flows before polishing.

### 5. High-fidelity mobile screens
Polish the approved architecture into a cohesive Themis visual experience.

### 6. Clickable prototype
At minimum support:
- complete setup
- first rule
- Parent Home
- Child Home
- on-time submission + grace
- parent approval
- approved vs applied
- overdue lock
- multiple restriction explanation
- extra-time request
- partial approval
- one clarification exchange
- Free Pass grant/revoke
- protection problem/recovery
- subscription grace/expired/reactivation
- transparency screen

### 7. State library
Show the important variants rather than only happy paths.

### 8. Accessibility review
Identify issues in your own design and correct them.

### 9. UX critique
After generating the first complete version, review it yourself for:
- mobile usability
- excessive taps
- cognitive load
- confusing states
- parent/child tone
- Teen dignity
- accessibility
- consistency
- trust/transparency
- accidental surveillance feel
- accidental desktop patterns

Then apply your own corrections before presenting the final design.

## Exploration requirement

Before locking the high-fidelity design, create 2–3 visual explorations for these three screens only:
- P-002 Welcome
- P-023 Parent Home
- C-001 Child Home

Keep the information architecture the same.

Vary visual hierarchy, card treatment and use of colour.

Select the strongest direction based on:
- calmness
- mobile clarity
- premium feel
- family friendliness
- differentiation from generic parental-control apps

Then apply the chosen direction consistently to the complete prototype.

## What NOT to do

Do not:
- redesign the product requirements
- add new product features simply because they look useful
- create Android screens
- create adult Personal Mode
- create Household Mode
- create detailed browsing-history screens
- create location-tracking screens
- create message-reading views
- add a second Guardian beyond V1
- invent automatic YouTube/content classification
- invent a final logo
- invent final subscription pricing
- claim "instant unlock"
- claim a system app is impossible to block
- make Parent UI look like enterprise admin software
- make Teen UI childish

## Final handoff

When the design is coherent:

1. Keep screen IDs on every frame.
2. Keep component names consistent.
3. Provide a short design rationale.
4. Provide a list of components Claude Code should implement first.
5. Provide any design decisions that are not directly dictated by the requirements.
6. Highlight anything you could not confidently resolve from the requirements instead of inventing it.
7. Prepare the artifact for handoff to Claude Code.

Do NOT write production app code in this design project.

The founder will review and approve the design before implementation continues.
