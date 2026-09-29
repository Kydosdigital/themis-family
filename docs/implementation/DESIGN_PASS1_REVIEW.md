# Claude Design Pass 1 Review

**Status:** CONDITIONAL APPROVAL — amend architecture/wireframes before Pass 2
**Reviewed against:** approved requirements baseline, MOBILE_UX_BLUEPRINT.md, and the founder-exported Pass 1 PDF.

## Overall

Pass 1 is structurally strong. The Parent and Child/Teen navigation model is coherent, the critical journeys are represented, Apple-owned UI is generally kept separate, and the Deadline Lock / Approved-vs-Applied / multiple-restriction concepts are handled well.

Do not start Pass 2 visual exploration until the corrections below are applied to Pass 1.

## Founder decisions on Claude Design's six open questions

### 1. Is a passing protection test required before Protection Activated?

**YES. Confirmed.**

P-022 cannot be reached as a genuine Protection Activated state until:
- child Family Controls authorisation is valid
- at least one target exists
- a real test shield is successfully applied
- the test shield is successfully removed
- the resulting state is verified

There is no "activate now, test later" path.

P-020/P-021 may have retry/help/error states, but failed or incomplete testing must leave the household in an incomplete/not-protected setup state.

### 2. Should Free Pass preview show a rule scheduled to start during the pass?

**YES, informationally.**

If a known scheduled restriction will start during the selected Free Pass window for the same target, F-005 should disclose it.

Example:
"Bedtime starts at 8:30 PM. Roblox may pause again then."

Do not silently imply the future rule is overridden.

Do not automatically add the future rule to the override unless a later confirmed product decision explicitly allows that.

The purpose is to prevent a parent believing "30-minute Free Pass" guarantees 30 uninterrupted minutes when a separate scheduled rule is due to begin.

### 3. How much can C-008 appear on Apple's shield screen?

**KEEP PROVISIONAL UNTIL THE APPLE SPIKE.**

Design two conceptual layers:
- Apple shield: minimal placeholder/system-owned state, exact capabilities TBD
- Themis companion screen: full "why this is paused / what to do / what stays available / request" experience

Do not assume custom buttons, navigation or text on the Apple shield beyond what the real-device ShieldConfiguration/ShieldAction spike proves.

### 4. Which Automatic Verification types are valid in V1?

V1 Automatic Verification is limited to deterministic Themis-controlled session types already specified:
- Active Engagement Session
- Focus Session

Do not introduce:
- generic homework auto-verification
- step counts
- location
- NFC
- QR
- photo/AI verification
- automatic real-world chore verification

For the canonical Homework Deadline onboarding flow, P-017 should NOT present Automatic Verification as an ordinary selectable alternative for "homework".

Use Parent Approval.

A small explanatory note may say:
"Automatic verification is available for supported Themis sessions."

### 5. Can a Guardian grant Free Passes and approve requests?

**YES.**

Owner and Guardian share ordinary parenting permissions:
- approve/reject tasks
- approve/decline/partially approve requests
- ask the one clarification question
- grant/revoke Free Pass
- manage ordinary rules
- view protection state

Owner-only remains:
- subscription management
- household deletion
- Guardian invite/removal
- ownership transfer
- other destructive account actions defined in the permissions spec

### 6. Does the child need a second push when approval is Applied on device?

**NO additional push is required in V1.**

Current design:
- child may receive the approved/rejected outcome notification already defined
- the child app reflects local Applied/access state when the device actually applies it
- do not add a second "Applied on your iPhone" push by default

This avoids notification noise.

If later user testing demonstrates a need for a second notification, treat it as a new notification-product decision.

## Required Pass 1 corrections

### A. Do not invent a one-device-per-child cap

Current copy says:
"One iPhone or iPad per child for now."

The approved V1 constraint is about **dedicated child devices / no shared-device scenarios**, not a confirmed commercial/technical cap of exactly one managed device per child.

Replace with wording such as:
"This device should be used by Sam, not shared between child profiles."

Do not hard-code an unapproved device-count limit into the design.

### B. Add the DEC-60 re-pairing recovery state

P-010 needs explicit state variants:
- **P-010 · Already paired**
- **P-010 · Recovery required**

Copy concept:
"This device already belongs to another Themis household."

Normal transfer requires removal from the old household first.

If that is not possible, show a deliberate secure recovery route.

Do not allow silent overwrite.

Do not make physical possession alone sufficient proof.

The exact identity-proof mechanism remains an implementation/security decision.

### C. Pairing-code TTL is not confirmed

"Code works for 10 minutes" is an implementation choice, not a confirmed product requirement.

For Pass 1 use:
"Code expires soon."

Or explicitly label 10 minutes as provisional.

The final TTL should come from security implementation design.

### D. Remove Face ID-specific architecture wording

Current navigation notes say push deep-links after Face ID.

Do not assume Face ID.

Use:
"Push opens the authenticated Themis destination after device/app authentication where required."

Users may use Face ID, Touch ID or passcode depending on hardware/settings.

### E. Correct essential-access certainty

Do not say, as an unconditional platform guarantee:
- "Always works: Phone, Messages..."
- "Always open: Phone, Messages, Maps..."

Confirmed product policy:
- emergency calling / OS emergency functionality is never deliberately restricted
- Phone, Messages and Maps are recommended Always Allowed defaults where technically supported
- exact picker/shield behaviour for these system apps remains OQ-30 / Priority 2 spike

Use language such as:
"Recommended Always Allowed"
and
"Configured to stay available where supported."

Emergency functionality can be stated strongly.

### F. Correct Offline protection wording

Current Device Offline copy says:
"It keeps its last rules..."

That is too absolute.

Use:
"Sam's iPhone hasn't checked in. Its last-synced protection plan may continue while valid, but new changes can't reach it and Themis can't confirm the current state."

Keep:
- last verified timestamp
- honest non-Protected state
- recovery action

### G. Fix Billing Grace copy

Current B-003 says:
"Protection stays on while Apple retries."

This is misleading because Apple's billing retry process can continue beyond Themis's configured Billing Grace Period.

Use:
"Protection stays on during Apple's Billing Grace Period."

Do not tie continued service to the full duration of Apple's retry mechanism.

### H. Make permission-recovery steps platform-safe

P-031 currently assumes:
"Tap Allow when Apple asks."

The exact recovery UI may vary and should not be guaranteed before device validation.

Use:
"Open Themis on Sam's iPhone and follow the Apple permission steps."

Then show:
"Checking Sam's iPhone…"

### I. Tighten child transparency copy

Avoid:
"Everything you search or visit"

because that can imply no website/activity information is ever visible through Apple's own parental reporting.

Use:
"Themis does not give your parent a full list of everything you search or visit."

Preserve the distinction:
- Themis-owned data
- Apple Screen Time information shown through Apple's parental report
- no message contents
- no full browsing/search-history feed
- no minute-by-minute surveillance feed
- no backend raw Apple Screen Time data in UK V1

### J. Do not assume singular/plural parent structure in Teen copy

Current design decision:
- Child says "your parent"
- Teen says "your parents"

This can be wrong in either direction.

Use household-neutral or dynamic copy:
- "your parent or carer"
- "your family"
- or dynamically choose singular/plural based on actual household membership

Do not make plurality a Teen-style distinction.

### K. Reduce mandatory onboarding friction without deleting screen IDs

The first-time setup architecture currently has many consecutive full screens.

Keep the screen IDs for traceability, but do not force every ID to be a separate high-friction stop.

Treat some as lightweight states within the same flow, for example:
- P-008 Child created can be a short success transition
- P-014 starter explanation can expand within P-013 or be a lightweight step
- P-021 can be the result state of P-020 rather than a separate navigation push

Goal:
preserve safety/clarity while making first activation feel achievable on mobile.

Do not merge away:
- Account created vs Protection Activated distinction
- Family Controls explanation
- agreement review
- test protection
- activation confirmation

### L. Homework automatic-verification option

P-017 currently visually presents:
- Parent Approval
- Automatic

For the canonical general homework task, Automatic should not look selectable.

Parent Approval is the valid choice.

Automatic Verification becomes available only when the configured condition is one of the supported deterministic Themis session types.

## Pass 1 elements approved as direction

Keep:
- Parent tabs: Home / Rules / Activity / Settings
- Child/Teen tabs: Home / My Rules / Requests
- Action Centre from Parent Home
- system-handoff treatment for Apple-owned UI
- one primary action per mobile screen
- whole-minute grace countdown
- Approved -> Applying -> Applied pattern
- Revocation sent -> Access revoked pattern
- reuse of rule-creation patterns
- multiple active restrictions explanation
- request flow with one clarification exchange
- neutral, non-punitive child language
- explicit Free Pass scope
- Parent Home hierarchy led by items requiring action
- no price invented in subscription wireframes
- no final logo invented

## Gate to Pass 2

Pass 2 may start only after Claude Design:
1. applies A-L above
2. updates the six founder open questions as resolved/provisional as stated
3. confirms no new structural product decision was introduced
4. preserves existing screen IDs, using state suffixes rather than renumbering where possible

Then Pass 2 should create 2-3 visual explorations for:
- P-002 Welcome
- P-023 Parent Home
- C-001 Child Home

Do not yet apply a visual direction across all 90+ screens until one exploration is approved.
