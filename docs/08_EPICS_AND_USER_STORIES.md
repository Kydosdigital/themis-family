# 08. Epics and User Stories

**Status:** Phase 4 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md`, `06_FUNCTIONAL_REQUIREMENTS.md`, `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `18_ROLES_AND_PERMISSIONS.md`

This document translates the Phase 3 functional requirements and business rules into user stories, one layer closer to something a team can build and test against. No production code is written here. Acceptance criteria for each story are in `09_ACCEPTANCE_CRITERIA.md` — this document does not duplicate them.

**ID format:** `US-[ROLE]-###`, where ROLE is one of OWNER, GUARDIAN, TEEN, CHILD.

**RECOMMENDATION on Owner/Guardian story duplication (flagged, not a silent decision):** Per `18_ROLES_AND_PERMISSIONS.md` §18.2, Owner and Guardian share identical permissions for every action except the Owner-only administrative set (subscription, household deletion, Guardian invite/removal, ownership transfer). Writing a fully duplicate US-GUARDIAN-### story for every US-OWNER-### story where the two are identical would roughly double this document's length without adding information. This document therefore writes shared actions once as US-OWNER-### stories, with a note "(Guardian: identical — see §18.2)" where that holds, and writes a distinct US-GUARDIAN-### or US-OWNER-### (Owner-only) story only where behaviour actually differs. Flagged here explicitly so this is a visible documentation choice, not a silently narrowed scope.

Every story traces: **HLR → FR/BR → User Story**. The trace is given inline; a consolidated matrix is a Phase 7 deliverable (`32_TRACEABILITY_MATRIX.md`).

---

## Epic A: Household and Membership Setup

*Traces to: HLR-001, HLR-002, HLR-003, HLR-020, HLR-021, HLR-022, HLR-023; FR-001 through FR-008 (`06_FUNCTIONAL_REQUIREMENTS.md`)*

### US-OWNER-001. Create a household
**Story:** As a new user, I want to create an account that becomes my household, so that I can start setting up digital rules for my family.
**Trace:** HLR-001 → FR-001
**Priority:** Must
**Notes:** Creating the account reaches "Account Creation Complete" (DEC-25) but not "Themis Protection Activated" — see US-OWNER-008.

### US-OWNER-002. Add a child and choose their experience
**Story:** As an Owner or Guardian, I want to add my child to the household and choose whether they get the Child or Teen experience, so that the app feels age-appropriate for them without me having to give their exact birthdate.
**Trace:** HLR-022 → FR-002
**Priority:** Must
**Notes:** (Guardian: identical — see §18.2.) No date of birth is collected. Copy: *"Choose the experience that best fits your child. You can change this later."*

### US-OWNER-003. Change a child's experience later
**Story:** As an Owner or Guardian, I want to switch my child between the Child and Teen experience later, so that the app can grow with them without me having to delete and recreate their profile.
**Trace:** HLR-022 → FR-003
**Priority:** Must
**Notes:** (Guardian: identical.) No data loss; existing rules keep applying to the same child record.

### US-OWNER-004. Invite a second parent/carer (Guardian)
**Story:** As the Owner, I want to invite a second parent or carer to help manage our rules, so that both of us can respond to requests and approvals without me being a single point of failure.
**Trace:** HLR-001 → FR-004, BR-103
**Priority:** Must
**Notes:** Owner-only (BR-103). Blocked if a Guardian already exists (V1 cap of one).

### US-GUARDIAN-001. Accept a Guardian invitation
**Story:** As an invited parent/carer, I want to accept an invitation and join the household as Guardian, so that I can help manage rules, approvals and requests for our children.
**Trace:** HLR-001 → FR-004
**Priority:** Must

### US-OWNER-005. Remove a Guardian
**Story:** As the Owner, I want to remove the Guardian from our household, so that I can adjust who has access if circumstances change.
**Trace:** HLR-001 → FR-005, BR-104
**Priority:** Must
**Notes:** Owner-only. The Guardian's pending unactioned approvals remain pending for the Owner, not silently dropped (BR-104).

### US-OWNER-006. Set up and authorise a child's device
**Story:** As an Owner or Guardian, I want to be guided through authorising my child's device, so that Themis Family can actually enforce rules on it.
**Trace:** HLR-003, HLR-023 → FR-006
**Priority:** Must
**Notes:** (Guardian: identical.) Requires the device to be signed into the child's own Child Apple Account within Family Sharing (DEC-26) — shared-device setups are out of V1 (OQ-17). If authorisation fails or is abandoned, the household must not show a false "Protected" state.

### US-OWNER-007. Remove or replace a child's device
**Story:** As an Owner or Guardian, I want to remove or replace my child's device, so that rules keep working when they get a new phone or tablet without me having to recreate everything.
**Trace:** HLR-003 → FR-007
**Priority:** Must
**Notes:** (Guardian: identical.) Rules are attached to the child record, not the device, so nothing is lost.

### US-OWNER-008. See a clear, honest "protection not yet active" state during setup
**Story:** As an Owner or Guardian, I want the app to clearly tell me when my child's protection isn't fully active yet, so that I never mistakenly believe a rule is being enforced when it isn't.
**Trace:** HLR-020 → FR-008
**Priority:** Must (elevated from Should — DEC-25)
**Notes:** (Guardian: identical.) "Themis Protection Activated" requires a real test shield to be applied and successfully removed, and the resulting state verified — not just that the setup flow was clicked through.

---

## Epic B: Rule Creation and Enforcement

*Traces to: HLR-004, HLR-005, HLR-006, HLR-012, HLR-013, HLR-014; FR-010 through FR-019 (`10_RULE_ENGINE_SPECIFICATION.md`)*

### US-OWNER-009. Create a rule
**Story:** As an Owner or Guardian, I want to create a rule choosing its type, target child, controlled apps/sites, and verification method, so that I can set the specific boundary my family has agreed to.
**Trace:** HLR-004 → FR-010, BR-201, BR-202, BR-203
**Priority:** Must
**Notes:** (Guardian: identical.) Starter patterns (e.g. "Homework deadline") can pre-fill the fields.

### US-OWNER-010. Start from a suggested rule pattern
**Story:** As an Owner or Guardian, I want to pick a pre-built starter pattern instead of configuring a rule from scratch, so that setting up my first rule doesn't feel intimidating.
**Trace:** HLR-004, HLR-020 → FR-010 (alternative path)
**Priority:** Must
**Notes:** (Guardian: identical.) All pre-filled fields remain editable before confirming.

### US-OWNER-011. Modify an existing rule
**Story:** As an Owner or Guardian, I want to edit a rule I've already created, so that I can adjust it as our agreement evolves without starting over.
**Trace:** HLR-004 → FR-011, BR-204
**Priority:** Must
**Notes:** (Guardian: identical.) Editing does not retroactively change an approval already in progress under the old terms.

### US-OWNER-012. Pause, delete or archive a rule
**Story:** As an Owner or Guardian, I want to pause or delete a rule, so that I can temporarily or permanently stop enforcing something that no longer applies.
**Trace:** HLR-004 → FR-012
**Priority:** Must
**Notes:** (Guardian: identical.) Deletion is soft (archived), not destructive to history.

### US-CHILD-001. Have a Scheduled Rule apply automatically at the right time
**Story:** As a child or teen, I want the apps covered by a schedule (like bedtime) to lock and unlock automatically at the agreed times, so that I don't have to rely on a parent remembering to do it manually, and it feels fair and consistent.
**Trace:** HLR-005, HLR-014 → FR-013, BR-205, BR-206
**Priority:** Must
**Notes:** Applies fully offline; follows the device's current local time zone (BR-205, DEC-36); DST does not shift the wall-clock time.

### US-CHILD-002. Get a fair, bounded grace period while my on-time submission is still awaiting a decision
**Story:** As a child or teen who submitted my task before the deadline, I want a bounded grace period where I'm not immediately locked out just because my parent hasn't responded yet, so that I'm not punished for something outside my control — while still knowing the grace period isn't unlimited, so it can't be used as a loophole.
**Trace:** HLR-006 → FR-014, BR-207 (CONFIRMED — DEC-40, Provisional Approval Grace Period model)
**Priority:** Must
**Notes:** The grace period is exactly 30 minutes after the deadline. If it expires with no decision, the restriction activates until the task is approved. The app tells me clearly how much grace time is left ("Approval grace ends in 18 min") and, once it runs out, that the restriction is now active pending review — never framed as a punishment for having submitted on time.

### US-CHILD-003. Complete a condition to earn access under Earn First
**Story:** As a child or teen, I want to unlock a rewarded app by first completing the agreed condition, so that I understand exactly what I need to do to earn my time.
**Trace:** HLR-004 → FR-015, BR-208
**Priority:** Must

### US-OWNER-013. Choose whether a task needs my approval or can verify itself
**Story:** As an Owner or Guardian, I want to set whether a task needs my sign-off or can be automatically verified by the app, so that low-stakes, system-checkable activities don't require me to be constantly available.
**Trace:** HLR-006 → FR-016, BR-209
**Priority:** Must
**Notes:** (Guardian: identical.) The app must not offer Automatic Verification for a condition it cannot actually verify (e.g. "clean your room").

### US-OWNER-014. Trust that rules keep working when the internet is down
**Story:** As an Owner or Guardian, I want my child's rules to keep applying and expiring correctly even if our internet connection or the app's servers are down, so that a temporary outage never becomes a loophole or a false lockout.
**Trace:** HLR-014 → FR-017, BR-210
**Priority:** Must
**Notes:** (Guardian: identical.)

### US-CHILD-004. Understand exactly why something is still restricted, even after I've done my part
**Story:** As a child or teen, I want to be told specifically which restriction(s) are still active on an app after I've completed a task, so that I'm never confused or feel cheated by a locked app that I thought I'd unlocked.
**Trace:** HLR-005 → FR-018, FR-019, BR-211, BR-226
**Priority:** Must
**Notes:** This story exists directly because of the founder's effective-enforcement decision (DEC-32): completing one rule's condition must never be silently overridden by another active rule without an honest explanation. Example: bedtime and an overdue-homework Deadline Lock both restrict Roblox; completing homework clears one restriction, but the child is told "Games are paused for bedtime. Homework is also overdue," not "Games unlocked."

---

## Epic C: Task Completion and Approval

*Traces to: HLR-006, HLR-007, HLR-008; FR-030 through FR-033 (`11_TASK_AND_APPROVAL_SPECIFICATION.md`)*

### US-CHILD-005. Submit a task for approval
**Story:** As a child or teen, I want to mark a task as done and send it for my parent's approval, so that I can unlock my access once they confirm.
**Trace:** HLR-007 → FR-030, BR-207
**Priority:** Must
**Notes:** Applies equally to Teen and Child.

### US-OWNER-015. Approve or reject a submitted task
**Story:** As an Owner or Guardian, I want to review a submitted task and approve or reject it, so that access is only unlocked once I've confirmed it's genuinely done.
**Trace:** HLR-007 → FR-031, BR-102, BR-207
**Priority:** Must
**Notes:** (Guardian: identical, subject to first-valid-decision-wins if both parents act — BR-102.)

### US-CHILD-006. See an honest "waiting for approval" state, with one reminder I can send
**Story:** As a child or teen, I want to see clearly that my task is waiting on my parent, get an automatic nudge sent to them if it's taking a while, and be able to send exactly one reminder of my own whenever I want, so that I'm not left guessing and don't have to nag repeatedly.
**Trace:** HLR-008 → FR-032, BR-212, BR-213 (CONFIRMED interval — DEC-41, closes OQ-04a)
**Priority:** Must
**Notes:** No auto-unlock, ever, if the parent never responds (DEC-15/BR-212) — this is intentional, not a bug to fix later. The automatic reminder fires once, at 15 minutes, if still unresolved. My own manual nudge is entirely separate — I can use it at any time, and using it doesn't reset or delay the automatic one. After both have fired, no more reminders are sent for that item, though it stays visibly pending.

### US-CHILD-007. Complete an Active Engagement Session (e.g. an in-app reading timer)
**Story:** As a child or teen, I want to complete an in-app timed activity like reading, and have it verify itself automatically without needing my parent's approval, so that low-stakes activities don't create unnecessary friction.
**Trace:** HLR-006 → FR-033, BR-209, BR-227, BR-232 (CONFIRMED termination handling — DEC-43)
**Priority:** Must
**Notes:** The session pauses if I background the app or lock my device, and resumes when I come back — it doesn't quietly keep counting while I'm doing something else (DEC-37). If the app crashes, gets closed by my phone, or my phone restarts partway through, I don't lose my legitimate progress — when I reopen Themis, I'm offered Resume from where I was, not forced to start over, unless something about that saved progress can't be trusted, in which case I'm told clearly and can just start again.

### US-CHILD-008. Complete a Focus Session (staying away from distracting apps)
**Story:** As a child or teen, I want to complete a Focus Session by simply staying out of the apps it restricts, without needing to keep Themis open the whole time, so that "focusing" doesn't mean staring at this app instead of actually focusing.
**Trace:** HLR-006 → FR-033, BR-209, BR-228, BR-231 (CONFIRMED violation handling — DEC-42, closes OQ-29)
**Priority:** Must
**Notes:** Unlike an Active Engagement Session, this one is designed to keep running while Themis is backgrounded or the device is locked (DEC-37) — that's the point. If I open one of the restricted apps during a session, the attempt is simply marked "Interrupted" — no credit, no carried-over time, but also no shaming language — and I can start a fresh attempt right away.

### US-OWNER-016. Reconfigure a rule's verification type
**Story:** As an Owner or Guardian, I want to switch a specific rule from automatic verification back to requiring my approval, so that I can regain oversight if I decide I want it.
**Trace:** HLR-006 → BR-214
**Priority:** Must
**Notes:** (Guardian: identical.) Applies to future task instances only, not one already in progress.

### US-OWNER-017. Reject a task with an optional short explanation
**Story:** As an Owner or Guardian, when I reject a task as "needs work," I want the option to add a short note explaining why, so that my child understands what's missing rather than feeling arbitrarily punished — without being forced to write an essay every time.
**Trace:** HLR-007 → FR-031, DEC-38
**Priority:** Must
**Notes:** (Guardian: identical.) The note is optional but the UI strongly encourages it; it's one-way, not a conversation thread.

---

## Epic D: Requests and Exceptions

*Traces to: HLR-009; FR-040 through FR-045 (`12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`)*

### US-CHILD-009. Ask for more time or temporary access
**Story:** As a child or teen, I want to ask my parent for extra time, a deadline extension, temporary access, or a one-off exception, so that I have a fair way to negotiate rather than just being stuck or trying to work around the rule.
**Trace:** HLR-009 → FR-040, BR-215
**Priority:** Must

### US-OWNER-018. Respond to a request
**Story:** As an Owner or Guardian, I want to approve a specific duration, partially approve, decline, or ask for clarification on my child's request, so that I can respond thoughtfully rather than just yes/no.
**Trace:** HLR-009 → FR-041, BR-102, BR-216
**Priority:** Must
**Notes:** (Guardian: identical, subject to BR-102.)

### US-OWNER-019. Ask my child one clarifying question before deciding
**Story:** As an Owner or Guardian, I want to ask my child a single clarifying question about their request before deciding, so that I don't have to guess or just decline when I'm missing one piece of context.
**Trace:** HLR-009 → FR-042, BR-218, DEC-34
**Priority:** Must
**Notes:** (Guardian: identical.) Exactly one prompt, one reply, then a decision — approved as final for V1, not an open thread.

### US-CHILD-010. Reply to my parent's clarifying question
**Story:** As a child or teen, I want to answer my parent's one clarifying question about my request, so that they have what they need to make a fair decision.
**Trace:** HLR-009 → FR-042, BR-218
**Priority:** Must

### US-CHILD-011. Have my request expire fairly, not arbitrarily
**Story:** As a child or teen, I want my pending request to stay valid for as long as it's actually still relevant to my situation, and not linger uselessly once it no longer matters, so that expiry feels sensible rather than like a random cutoff.
**Trace:** HLR-009 → FR-043, BR-229, DEC-39
**Priority:** Must
**Notes:** Expiry is tied to the underlying rule/context ending, with a 4-hour maximum as a backstop only.

### US-CHILD-012. Have a time-bound grant expire and re-lock automatically
**Story:** As a child or teen, I want any extra time or temporary access I'm given to end automatically at the agreed time, so that I always know exactly what to expect and there's no ambiguity about when it runs out.
**Trace:** HLR-014 → FR-044, BR-210
**Priority:** Must
**Notes:** Happens locally, even if the backend, my parent's device, or notifications are unavailable at that moment.

### US-OWNER-020. Give my child a Free Pass without them asking
**Story:** As an Owner or Guardian, I want to proactively grant my child temporary access to something specific, so that I can be spontaneously generous (e.g. a family event, a rainy afternoon) without them having to ask first.
**Trace:** HLR-009 → FR-045, BR-219, DEC-33
**Priority:** Must
**Notes:** (Guardian: identical.) I must explicitly choose the target/scope and duration (via a quick preset or a custom choice) — there's no unscoped "unlock everything" default. Before I confirm, the app tells me exactly which rule(s) this will temporarily override.

---

## Epic E: School Mode and Essential Access

*Traces to: HLR-010, HLR-011; FR-050 through FR-054 (`13_SCHOOL_AND_ESSENTIAL_ACCESS.md`)*

### US-OWNER-021. Configure Always Allowed apps and sites
**Story:** As an Owner or Guardian, I want to mark specific apps or websites as always allowed regardless of any other rule, so that things like emergency contact or agreed exceptions are never accidentally blocked.
**Trace:** HLR-010 → FR-050, BR-202, BR-220
**Priority:** Must
**Notes:** (Guardian: identical.) Adding something to Always Allowed automatically removes it from any restrictive rule; the reverse is blocked with a clear explanation.

### US-OWNER-022. Set up School Mode
**Story:** As an Owner or Guardian, I want to configure school-hours restrictions and a school access list, so that my child has consistent boundaries during school time without me manually managing it every day.
**Trace:** HLR-011 → FR-051, BR-221
**Priority:** Must
**Notes:** (Guardian: identical.) The product is honest that it cannot tell educational from entertainment content within the same app (e.g. YouTube) — School Mode works via Always Allowed apps/sites, a schedule, and temporary access requests, not content classification (BR-221/DEC-18).

### US-CHILD-013. Ask for temporary access to something for schoolwork
**Story:** As a child or teen, I want to request temporary access to a normally-restricted app or site when I genuinely need it for schoolwork, so that School Mode never actually blocks me from doing my homework.
**Trace:** HLR-011 → FR-052
**Priority:** Must
**Notes:** This is the general Request/Grant mechanism (Epic D), framed for School Mode with a schoolwork-relevant prompt.

### US-CHILD-014. Know that Themis will never deliberately block my way to emergency help
**Story:** As a child or teen, I want Themis never to deliberately prevent emergency communication, so that digital-boundary rules do not interfere with getting urgent help.
**Trace:** HLR-010 → FR-053, BR-222, DEC-35
**Priority:** Must
**Notes (RENAMED — DEC-44, corrects overstated wording):** This story previously read "Trust that I can always reach emergency help and my parents," which overstated the confirmed requirement — it read as a guarantee about reaching a parent specifically, which has not been technically verified. What is actually confirmed, as a hard, unconditional product policy, is narrower: Themis must never deliberately interfere with emergency calling or OS-level emergency functionality. Phone, Messages and Maps remain the recommended default Always Allowed set where technically supported (BR-222), but whether every specific route to a parent (e.g. Messages under every Apple configuration) can be technically guaranteed is not yet confirmed — that remains OQ-30, open pending the Apple technical spike. The story and its acceptance criteria must not claim more than the confirmed policy until OQ-30 resolves.

### US-OWNER-023. Understand that School Mode assumes one device per child
**Story:** As an Owner or Guardian, I want the app to be upfront that School Mode and essential access assume each child has their own device, so that I don't set up something (like siblings sharing an iPad) that won't actually work as I expect.
**Trace:** HLR-023 → FR-054, DEC-26
**Priority:** Must (as a documentation/UX constraint)
**Notes:** (Guardian: identical.)

---

## Epic F: Roles, Permissions, and Household Administration

*Traces to: HLR-001, HLR-002; `18_ROLES_AND_PERMISSIONS.md` §18.2, BR-101 through BR-106*

### US-OWNER-024. Transfer ownership of the household, or leave it entirely
**Story:** As the Owner, I want to transfer ownership to our Guardian, so that responsibility for the household can move to them if circumstances require it, and I want a clear path to leave the household altogether if that's what I need to do.
**Trace:** HLR-002 → BR-101 (CONFIRMED as final for V1 — DEC-45, closes OQ-20)
**Priority:** Must
**Notes:** Only possible if a Guardian already exists. If I want to leave and no Guardian exists yet, my two confirmed V1 options are: invite a Guardian and transfer to them first, or delete the household outright. V1 does not support an ownerless household, transferring directly to a Child/Teen, inviting and transferring in one simultaneous action, or separate households for split-custody arrangements — each of these is a deliberate V1 limitation, not an oversight.

### US-OWNER-025. Have approval conflicts resolved fairly when both parents respond
**Story:** As an Owner or Guardian, if my co-parent and I both respond to the same request or task at nearly the same time, I want the system to resolve it predictably and tell me clearly what happened, so that neither of us is confused or double-acts on the same thing.
**Trace:** HLR-002 → BR-102
**Priority:** Must
**Notes:** (Guardian: identical.) First valid decision wins; the other party is told the outcome, not left to wonder.

### US-OWNER-026. Delete the household
**Story:** As the Owner, I want to delete our household entirely, so that I can close our account if we stop using Themis Family.
**Trace:** HLR-002 → BR-106
**Priority:** Must
**Notes:** Owner-only, destructive, confirmable. Full data-retention behaviour is a Phase 6 deliverable.

---

## Epic G: Multi-rule and conflict transparency (cross-cutting)

*This epic collects the child-facing consequences of DEC-32's effective-enforcement model in one place, since they cut across Epic B, C and D rather than belonging to a single rule type.*

### US-CHILD-015. See what changes and what doesn't when I clear one restriction
**Story:** As a child or teen, when I clear one restriction (finish a task, get a grant approved) but another restriction still applies to the same app, I want to be told exactly what changed and what's still in effect, so that I always have an accurate picture and never feel misled by the app.
**Trace:** HLR-005 → FR-019, BR-226, DEC-32
**Priority:** Must
**Notes:** Example: "Homework done — nice work. Games are still paused until bedtime ends."

---

## 8.1 End-of-epic notes for the Phase 4 cross-check

This document's own cross-check (orphan FRs without a story, stories without an FR, etc.) is performed formally in `09_ACCEPTANCE_CRITERIA.md` §9.6, once acceptance criteria make the trace concrete enough to audit properly. A preliminary read: every FR from `06_FUNCTIONAL_REQUIREMENTS.md` has at least one corresponding story above, with the deliberate exception of FR-001 (household creation is folded into US-OWNER-001 as the account-creation moment, not written as a separate story) and purely System-actor FRs that have no independent human-facing story beyond the ones already listed (e.g. FR-017's local caching has no user story of its own — it is invisible infrastructure whose observable consequence is US-OWNER-014).
