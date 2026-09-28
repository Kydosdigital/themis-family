# 09. Acceptance Criteria

**Status:** Phase 4 draft
**Depends on:** `08_EPICS_AND_USER_STORIES.md`

Acceptance criteria are given as Given/When/Then scenarios per story. Every story from `08_EPICS_AND_USER_STORIES.md` has at least one positive (happy-path) scenario and, wherever the underlying FR/BR names a failure or alternative path, at least one negative/failure scenario as well — no story is left with only its happy path. §9.6 is the mandatory end-of-Phase-4 cross-check.

---

## Epic A: Household and Membership Setup

### US-OWNER-001. Create a household
- **AC1 (happy path):** Given a new user with no existing account, when they complete sign-up, then a household is created with them as Owner and the app shows "Account Creation Complete" — not "Protected" or any state implying enforcement is active.
- **AC2 (failure):** Given sign-up fails (network error, duplicate account), when the user retries, then no partial/orphaned household is created, and the error is specific enough to act on (not a generic "something went wrong").

### US-OWNER-002. Add a child and choose their experience
- **AC1 (happy path):** Given an Owner/Guardian in Settings or onboarding, when they add a child, enter a name, and select "Child experience" or "Teen experience," then a child record is created with that segment and no date of birth field is shown or required.
- **AC2 (validation):** Given the parent has not yet selected a segment, when they attempt to confirm, then confirmation is blocked until a segment is chosen (no silent default).

### US-OWNER-003. Change a child's experience later
- **AC1 (happy path):** Given an existing child record set to "Child experience," when an Owner/Guardian changes it to "Teen experience" in Settings, then the child's UI updates on next launch/sync, all existing rules continue to apply unchanged, and no data is lost.
- **AC2 (idempotency):** Given the segment is changed and then changed back, when the child next opens the app, then their rules and history are identical to before either change.

### US-OWNER-004. Invite a second parent/carer (Guardian)
- **AC1 (happy path):** Given a household with no Guardian, when the Owner sends an invitation and the invitee accepts, then the invitee becomes Guardian with the permissions in `18_ROLES_AND_PERMISSIONS.md` §18.2.
- **AC2 (failure — cap reached):** Given a household already has a Guardian, when the Owner attempts to invite a second one, then the invite action is unavailable/blocked with a message explaining the V1 one-Guardian cap.
- **AC3 (permission failure):** Given a Guardian (not Owner) attempts to invite another Guardian, when they try, then the action is not available to them (BR-103).

### US-GUARDIAN-001. Accept a Guardian invitation
- **AC1 (happy path):** Given a valid, unexpired invitation, when the invitee accepts it, then they immediately gain Guardian permissions and appear in the household's member list.
- **AC2 (failure — expired/invalid):** Given an expired or already-used invitation link, when the invitee attempts to accept it, then they see a clear message that the invitation is no longer valid, not a generic error.

### US-OWNER-005. Remove a Guardian
- **AC1 (happy path):** Given a household with a Guardian, when the Owner removes them, then the Guardian loses access immediately and any of their pending unactioned approvals remain pending for the Owner alone to resolve (BR-104).
- **AC2 (permission failure):** Given a Guardian attempts to remove themselves or the Owner, when they try, then the action is not available to them.

### US-OWNER-006. Set up and authorise a child's device
- **AC1 (happy path):** Given a child record exists and their device is signed into their own Child Apple Account within Family Sharing, when the parent completes the guided authorisation flow, then the app verifies successful authorisation (not merely that the flow was clicked through) before allowing rule creation for that device.
- **AC2 (failure — authorisation abandoned):** Given the parent abandons or fails the authorisation flow, when they return later, then the household shows an explicit incomplete/unprotected state for that child, never a false "Protected" state.
- **AC3 (failure — wrong account configuration):** Given a device is not signed into the child's own Child Apple Account (e.g. a shared or parent-owned device), when authorisation is attempted, then the app does not silently proceed as if the V1-supported configuration were in place; this scenario is out of scope for V1 support (OQ-17) and should surface as an unsupported-configuration state, not a false success.

### US-OWNER-007. Remove or replace a child's device
- **AC1 (happy path):** Given a child has an authorised device, when the parent removes it and later authorises a new one for the same child, then all existing rules for that child apply to the new device without being recreated.
- **AC2 (interim state):** Given a device has been removed and no replacement is yet authorised, when the parent checks the child's status, then the app shows an honest "no authorised device" state, not "Protected."

### US-OWNER-008. See a clear, honest "protection not yet active" state during setup
- **AC1 (happy path):** Given device authorisation is valid and at least one rule target is selected, when a real test shield is applied, confirmed, then successfully removed and the resulting unshielded state verified, then the household/child shows "Themis Protection Activated."
- **AC2 (failure — test shield fails to apply):** Given the test shield fails to apply, when the parent checks status, then they are shown specifically that the test shield failed to apply (not a generic error), and "Themis Protection Activated" is not shown.
- **AC3 (failure — test shield fails to remove):** Given the test shield applies but fails to remove correctly, when the parent checks status, then they are told specifically that removal failed, and "Themis Protection Activated" is not shown until this is resolved.

---

## Epic B: Rule Creation and Enforcement

### US-OWNER-009. Create a rule
- **AC1 (happy path):** Given a household with an authorised child device, when the parent selects rule type, target child, controlled targets, verification type, and confirms, then the rule is saved as Active and synced to the device.
- **AC2 (failure — device authorisation invalid):** Given the target device's authorisation is currently invalid, when the parent saves the rule anyway, then the rule saves as Active but the parent is told at save time (not left to discover later) that protection status will not reach "Protected" until authorisation is restored.
- **AC3 (failure — Always Allowed conflict):** Given the parent attempts to target an app/site that is currently marked Always Allowed, when they try to add it to a restrictive rule, then the action is blocked with a clear explanation (BR-202).
- **AC4 (offline):** Given the device is offline at creation time, when the parent confirms the rule, then it is shown as "Pending sync," never falsely "Active," until connectivity returns.

### US-OWNER-010. Start from a suggested rule pattern
- **AC1 (happy path):** Given a parent selects a starter pattern (e.g. "Homework deadline"), when the pre-filled fields appear, then every field remains editable before the parent confirms, and confirming creates the rule exactly as for a manually-built one (US-OWNER-009 AC1–AC4 apply identically).

### US-OWNER-011. Modify an existing rule
- **AC1 (happy path):** Given an Active rule with no pending approval, when the parent edits a field and confirms, then the change syncs to the device and takes effect for future evaluations.
- **AC2 (in-flight approval protection):** Given a rule has a task currently awaiting approval, when the parent edits the rule's terms, then the in-progress approval's terms are not retroactively changed (BR-204) — the edit applies from the next task instance onward.

### US-OWNER-012. Pause, delete or archive a rule
- **AC1 (happy path — pause):** Given an Active rule, when the parent pauses it, then enforcement stops immediately once the device is reachable, and the rule's configuration is retained for later reactivation.
- **AC2 (happy path — delete):** Given a rule, when the parent deletes it, then it is soft-deleted/archived (not hard-deleted) for audit purposes.
- **AC3 (offline latency):** Given the device is unreachable when a pause/delete is issued, when the parent checks status, then the app honestly shows "Pending sync" rather than implying the pause/delete has already taken effect on-device.

### US-CHILD-001. Have a Scheduled Rule apply automatically at the right time
- **AC1 (happy path):** Given a Scheduled Rule with a configured window, when the device's local clock enters the window, then controlled targets are shielded without requiring a network round-trip at that moment.
- **AC2 (offline):** Given the device has no connectivity at the scheduled trigger time, when the window starts/ends, then the shield still applies/lifts correctly, using the locally cached schedule.
- **AC3 (time zone travel):** Given the family travels and the device's time zone changes, when the next scheduled trigger time arrives, then it applies according to the device's new current local time zone (BR-205/DEC-36), and the transition does not produce an ambiguous double-trigger or missed-trigger state.
- **AC4 (DST):** Given a Daylight Saving Time transition occurs, when the schedule's configured wall-clock time next arrives, then it applies at that same local wall-clock time, not shifted by the DST change.

### US-CHILD-002. Not be shielded while my approved deadline task is still awaiting a decision
- **AC1 (happy path):** Given a task was submitted before the Deadline Lock's deadline and is still Awaiting Approval when the deadline passes, when the deadline passes, then the shield does not apply while the submission remains pending.
- **AC2 (rejection after deadline):** Given the above state, when the approver later rejects the submission, then the shield applies from the moment of rejection, not backdated to the original deadline.

### US-CHILD-003. Complete a condition to earn access under Earn First
- **AC1 (happy path):** Given an Earn First rule with the target shielded by default, when the associated condition resolves to complete (manually approved or automatically verified), then the reward access period begins for the fixed duration set at rule creation.
- **AC2 (no renegotiation without a request):** Given a reward period is running, when the child wants more time, then the fixed duration is not silently extended — a request must be submitted (Epic D) to change it.

### US-OWNER-013. Choose whether a task needs my approval or can verify itself
- **AC1 (happy path):** Given a manual real-world task (e.g. "clean your room"), when the parent configures it, then only Parent Approval is offered — Automatic Verification is not selectable for this condition type.
- **AC2 (happy path — system-verifiable):** Given a system-verifiable condition (an in-app timer/focus session), when the parent configures it, then both Parent Approval and Automatic Verification are offered, and either the Active Engagement Session or Focus Session type must be specified (§11.1a).
- **AC3 (validation failure):** Given a parent attempts to set Automatic Verification on a non-system-verifiable condition, when they try, then the UI does not present this combination as a selectable option at all (form-level prevention, not a runtime error).

### US-OWNER-014. Trust that rules keep working when the internet is down
- **AC1 (happy path):** Given a valid Active rule cached locally on the child's device, when the backend, the parent's device, and push notifications are all simultaneously unreachable, then the rule's schedule/deadline/expiry transitions still occur correctly using the local cache and the device's own clock.
- **AC2 (grant expiry under total outage):** Given a temporary access grant with a cached expiry time, when that time is reached during a total outage, then the device re-applies the restriction locally without waiting for any server-sent instruction (BR-210/DEC-30).

### US-CHILD-004 / US-CHILD-015. Understand exactly why something is still restricted (effective-enforcement model, DEC-32)
- **AC1 (happy path — partial clearance):** Given both a bedtime Scheduled Rule and an overdue-homework Deadline Lock restrict the same app, when the homework task is approved while bedtime is still active, then the Deadline Lock restriction clears, the app remains shielded because bedtime is still active, and the child sees a message naming both facts (e.g. "Homework done — nice work. Games are still paused until bedtime ends."), never "Games unlocked."
- **AC2 (full clearance):** Given the same two restrictions, when bedtime's window also ends after the homework task is already approved, then the app becomes accessible, and the child sees confirmation that reflects both restrictions having cleared, not just the most recent one.
- **AC3 (scoped override does not clear unrelated restrictions):** Given a parent grants a Free Pass scoped only to "YouTube — 20 minutes," when the grant is applied, then only YouTube is affected; any other active restriction on a different app is completely unaffected and is not mentioned as cleared.
- **AC4 (no false unlock on any single-restriction clearance):** Given any target under more than one active restriction, when fewer than all of them clear, then the target's displayed state is never "unlocked" and always names every restriction still in force (BR-226).

---

## Epic C: Task Completion and Approval

### US-CHILD-005. Submit a task for approval
- **AC1 (happy path):** Given a task in Available or Overdue state, when the child taps Submit, then the task moves to Awaiting Approval and all eligible approvers are notified immediately.
- **AC2 (offline submission):** Given the child's device is offline when they submit, when they tap Submit, then the app shows "Submitting..." (not "Awaiting Approval") until connectivity confirms the submission was recorded, and never silently fails.

### US-OWNER-015. Approve or reject a submitted task
- **AC1 (happy path — approve):** Given a task Awaiting Approval, when the approver taps Approve, then the task moves to Completed, the associated shield is removed on the child's device (subject to Epic B's effective-enforcement model if other restrictions still apply), and the child sees confirmation.
- **AC2 (happy path — reject):** Given a task Awaiting Approval, when the approver taps Reject, then the task returns to Overdue/Available, optionally with a note (DEC-38), and the child may resubmit.
- **AC3 (conflict — two approvers act at once):** Given both Owner and Guardian act on the same task within the race window, when both actions are processed, then the first action durably recorded wins (BR-102), and the other actor is shown the resolved outcome, not a silent overwrite or an error with no explanation.
- **AC4 (offline approval):** Given the child's device is offline at the moment of approval, when connectivity returns, then the shield is removed as soon as the device syncs — the approval itself is not lost or time-limited by the brief offline period.

### US-CHILD-006. See an honest "waiting for approval" state, with one reminder I can send
- **AC1 (happy path):** Given a task is Awaiting Approval, when time passes with no approver action, then the child sees an elapsed-time indicator and, after the defined reminder interval, an automatic reminder is sent to approvers (OQ-04a — exact interval still pending, does not block this AC's structure).
- **AC2 (child-triggered nudge):** Given a task is Awaiting Approval and the child has not yet used their nudge, when they tap "Send a reminder," then approvers are re-notified immediately and the control becomes visibly disabled (shown, not hidden) for that item.
- **AC3 (nudge already used):** Given the child has already used their one nudge for this item, when they view the item again, then the nudge control is shown but disabled, not offered again.
- **AC4 (no response, ever — intentional behaviour, not a bug):** Given no approver ever responds, when any amount of time passes, then the restriction remains active indefinitely and no automatic unlock occurs (BR-212/DEC-15) — this must be verified as a passing test, not flagged as a defect.

### US-CHILD-007. Complete an Active Engagement Session
- **AC1 (happy path):** Given an Active Engagement Session task (e.g. a 15-minute in-app reading timer), when the child runs it to completion in the foreground, then the task moves to Completed and the app states "15-minute in-app reading session completed" — never "child definitely read for 15 minutes."
- **AC2 (pause on backgrounding):** Given the session is running, when the child backgrounds Themis or locks the device, then the timer pauses and backgrounded time is not counted.
- **AC3 (resume on foreground):** Given the session was paused by backgrounding, when the child returns Themis to the foreground, then the timer resumes from where it paused.
- **AC4 (force-quit failure):** Given the session is running, when the app is force-quit, then the session resets with no partial credit.

### US-CHILD-008. Complete a Focus Session
- **AC1 (happy path):** Given a Focus Session task restricting a specific set of apps, when the child avoids opening those apps for the configured duration — including while Themis itself is backgrounded or the device is locked — then the task completes and the app states "30-minute focus session completed under the configured restrictions" — never "30 minutes of homework completed."
- **AC2 (continues while backgrounded):** Given the session is running and Themis is backgrounded or the device is locked, when no restricted app is opened, then the session continues counting (unlike an Active Engagement Session).
- **AC3 (violation):** Given the session is running, when the child opens one of the specifically restricted apps, then the session is treated as violated; the exact handling (reset vs. pause-and-flag) is OQ-29 and is not yet fixed — this AC records that a violation must be detected and must not be silently ignored, pending that decision.

### US-OWNER-016. Reconfigure a rule's verification type
- **AC1 (happy path):** Given an existing rule set to Automatic Verification, when the parent switches it to Parent Approval, then future task instances require approval; the task instance currently in progress (if any) is unaffected (BR-214).
- **AC2 (reverse direction blocked where invalid):** Given a rule's condition is not system-verifiable, when the parent attempts to switch it to Automatic Verification, then the option is not offered (consistent with US-OWNER-013 AC3).

### US-OWNER-017. Reject a task with an optional short explanation
- **AC1 (happy path — with note):** Given the parent rejects a task, when they add a short note before confirming, then the child sees the note alongside the rejection.
- **AC2 (happy path — without note):** Given the parent rejects a task, when they confirm without adding a note, then the rejection completes successfully (the note is never mandatory, DEC-38) and the child sees the rejection without a note.
- **AC3 (no thread created):** Given a rejection note was given, when the child views it, then there is no reply/thread mechanism attached to it — it is one-way, distinct from FR-042's bounded clarification exchange.

---

## Epic D: Requests and Exceptions

### US-CHILD-009. Ask for more time or temporary access
- **AC1 (happy path):** Given the child wants extra time, a deadline extension, temporary access, or an exception, when they submit a request with a type, target, and reason, then it enters Pending state and all eligible approvers are notified immediately.
- **AC2 (offline submission):** Given the child is offline, when they submit a request, then it is queued and shown as "Sending..." not "Pending," until confirmed received.

### US-OWNER-018. Respond to a request
- **AC1 (happy path — approve a duration):** Given a Pending request, when the approver selects a preset or custom duration and confirms, then a grant is created (FR-044) and pushed to the child's device.
- **AC2 (happy path — partial approval):** Given a Pending request for 30 minutes, when the approver grants 15 minutes instead, then the child is notified of the actual granted duration, not the originally requested one.
- **AC3 (happy path — decline):** Given a Pending request, when the approver declines, then the child is notified of the decision, optionally with a reason.
- **AC4 (conflict):** Given both Owner and Guardian act on the same request, when both actions are processed, then BR-102's first-valid-decision-wins rule applies identically to US-OWNER-015 AC3.
- **AC5 (post-expiry approval attempt):** Given a request has already moved to Expired, when an approver attempts to approve it, then the decision is not applied as a live grant; the approver is shown that it expired and, if they still want to grant something, must create a fresh, explicit grant (BR-217).

### US-OWNER-019. Ask my child one clarifying question before deciding
- **AC1 (happy path):** Given a Pending request, when the approver sends one clarification prompt, then the request stays Pending, the prompt is attached to it, and the child is notified.
- **AC2 (single round enforced):** Given a clarification prompt has already been sent and answered, when the approver attempts to send a second clarification prompt on the same request, then the option is not available — only approve/partially approve/decline remain (BR-218).
- **AC3 (decision without a reply):** Given the child has not replied to the clarification prompt, when the approver decides to approve or decline anyway, then the decision proceeds — the clarification never blocks a decision, only informs one.

### US-CHILD-010. Reply to my parent's clarifying question
- **AC1 (happy path):** Given a clarification prompt is attached to my pending request, when I send my one reply, then it is attached to the request and visible to the approver alongside my original reason.
- **AC2 (single reply enforced):** Given I have already sent my one reply, when I attempt to send a second one, then the option is not available for this request.

### US-CHILD-011. Have my request expire fairly, not arbitrarily
- **AC1 (context ends before 4-hour backstop):** Given a request references a Deadline Lock whose deadline is handled another way after 1 hour, when that context ends, then the request expires at that point, not at the full 4-hour backstop.
- **AC2 (4-hour backstop applies when context is open-ended):** Given a request's underlying context does not itself end within 4 hours, when 4 hours elapse from `created_at` with no approver action, then the request expires via the backstop.
- **AC3 (underlying rule deleted mid-request):** Given the request's context reference points to a rule that is deleted or materially changed while the request is Pending, when the rule change is detected, then the request expires immediately, regardless of `expires_at`, rather than remaining Pending against a rule that no longer exists.
- **AC4 (parent acts exactly around expiry):** Given a request's `expires_at` is reached at the same moment an approver submits a decision, when the system processes both events, then exactly one deterministic outcome results — either the decision is honoured (if durably recorded before expiry) or the request is expired and BR-217 applies (if not) — never an ambiguous or duplicated state.
- **AC5 (expires while devices are offline):** Given the child's and/or parent's device is offline when `expires_at` is reached, when connectivity is restored, then the request is shown as Expired based on the locally/server-computed `expires_at`, not left Pending indefinitely due to the outage.
- **AC6 (becomes irrelevant before the backstop):** Given the situation the request was about is resolved another way (e.g. the child completed the task another route) before either the context ends or 4 hours pass, when this is detected, then the request expires at that point rather than remaining Pending and confusing to act on.

### US-CHILD-012. Have a time-bound grant expire and re-lock automatically
- **AC1 (happy path):** Given a grant with a cached expiry time, when that time is reached, then the device re-applies the restriction using its own local clock, without waiting for a second server-sent instruction.
- **AC2 (total outage at expiry):** Given the backend, the parent's device, and push notifications are all unavailable at the exact expiry moment, when the expiry time passes, then re-locking still occurs (BR-210/DEC-30).

### US-OWNER-020. Give my child a Free Pass without them asking
- **AC1 (happy path — preset):** Given the parent selects the "Games — 30 minutes" preset, when they confirm, then the app first states which active rule(s) this will temporarily override (e.g. the bedtime schedule for Games), and only after confirmation is the grant created.
- **AC2 (happy path — custom):** Given the parent builds a custom target/duration combination instead of a preset, when they confirm, then the same explicit disclosure and grant-creation behaviour applies as AC1.
- **AC3 (no unscoped default exists):** Given the parent opens the Free Pass flow, when no target/scope has yet been selected, then there is no way to confirm a Free Pass without first choosing a scope — the flow cannot be completed with an implicit "everything" scope.
- **AC4 (automatic resumption):** Given a Free Pass grant's duration ends, when the expiry time is reached, then the target's normal effective enforcement state (per BR-211) resumes automatically without any further parent action.

---

## Epic E: School Mode and Essential Access

### US-OWNER-021. Configure Always Allowed apps and sites
- **AC1 (happy path):** Given the parent selects an app/site via the picker, when they mark it Always Allowed, then it is excluded from every other rule's shielding unconditionally.
- **AC2 (auto-removal from restrictive rules):** Given an app is currently targeted by an active restrictive rule, when the parent marks it Always Allowed, then it is automatically removed from that rule's targets, and the parent is explicitly told this happened.
- **AC3 (reverse direction blocked):** Given an app is currently Always Allowed, when the parent attempts to add it to a new rule's restrictive targets, then the action is blocked at rule-creation time with a clear message (consistent with US-OWNER-009 AC3).

### US-OWNER-022. Set up School Mode
- **AC1 (happy path):** Given the parent configures school-relevant Always Allowed apps/sites and a school-hours schedule, when they confirm, then School Mode is Active and temporary educational access requests are enabled by default.
- **AC2 (unlisted school platform):** Given the child's school uses a platform not in the suggested default list, when the parent manually adds it via the picker, then it is added successfully — the feature does not require every possible school platform to be pre-catalogued.
- **AC3 (capability-honesty check):** Given any in-product copy, help content, or onboarding screen describes School Mode, when it is reviewed, then it never claims or implies School Mode can distinguish educational from entertainment content within the same app (BR-221) — this is a content-review AC, not a runtime behaviour, and must be checked wherever School Mode is described.

### US-CHILD-013. Ask for temporary access to something for schoolwork
- **AC1 (happy path):** Given a restriction is active on a target the child needs for schoolwork, when they submit a Temporary Access request with the School Mode-relevant prompt, then it follows the identical Request/Grant lifecycle as Epic D (US-CHILD-009 through US-CHILD-012), with no separate code path or business rules.

### US-CHILD-014. Trust that I can always reach emergency help and my parents
- **AC1 (happy path):** Given any rule configuration a parent has set up, when the child attempts to use Phone/emergency calling functionality, then it is never blocked by Themis, regardless of any active restrictive rule.
- **AC2 (parent cannot override the floor):** Given a parent attempts to add emergency calling/OS-level emergency functionality to a restrictive rule's targets, when they try, then the system prevents this at the picker level or, if selected, silently keeps the hard safety principle enforced regardless (FR-053) — there is no configuration path that results in emergency calling being restricted.
- **AC3 (documentation honesty — no unverified technical claim):** Given any documentation or in-product copy states that a specific app (e.g. Phone) is "technically impossible to shield," when this claim is reviewed, then it is only made once the Apple technical spike (OQ-30) has actually verified that behaviour — until then, copy states the product policy (never deliberately restricted) without asserting an unverified technical guarantee.

### US-OWNER-023. Understand that School Mode assumes one device per child
- **AC1 (happy path):** Given the parent views School Mode or essential access setup screens or help content, when they read the setup guidance, then it states the one-device-per-child assumption and does not imply that a shared device (e.g. siblings sharing an iPad) receives correctly-separated per-child configuration.

---

## Epic F: Roles, Permissions, and Household Administration

### US-OWNER-024. Transfer ownership of the household
- **AC1 (happy path):** Given a household with an existing Guardian, when the Owner transfers ownership to them, then the transfer is a single atomic operation making the Guardian the new Owner and demoting the previous Owner to Guardian, with no moment where the household has zero Owners.
- **AC2 (failure — no Guardian exists):** Given no Guardian exists, when the Owner attempts to transfer ownership, then the action is unavailable (BR-101) — the Owner must invite a Guardian first (or delete the household; OQ-20 tracks whether a further exit path is needed).
- **AC3 (failure — invalid target):** Given the Owner attempts to transfer ownership to a Teen/Child or a newly-invited person in the same action, when they try, then the action is blocked — the target must already hold the Guardian role.

### US-OWNER-025. Have approval conflicts resolved fairly when both parents respond
- **AC1 (happy path):** Given both Owner and Guardian act on the same pending item within the race window, when the system processes both, then the first action durably recorded (via an atomic conditional state transition) wins, and the other actor receives a clear "already resolved" response naming the outcome — not a silent discard and not an unexplained error.

### US-OWNER-026. Delete the household
- **AC1 (happy path):** Given the Owner initiates household deletion, when they confirm the destructive action, then the household and its data are deleted per the retention policy defined in Phase 6 (`23_PRIVACY_AND_CHILD_SAFETY.md`/`24_SECURITY_REQUIREMENTS.md`).
- **AC2 (permission failure):** Given a Guardian attempts to delete the household, when they try, then the action is not available to them (BR-106).

---

## 9.6 End-of-Phase-4 cross-check

Per the founder's explicit Phase 4 instructions, this section identifies: FRs without a user story, stories not backed by an FR, acceptance criteria that depend on unresolved questions, and missing negative/failure scenarios.

### FRs without a user story
None found. Every FR in `06_FUNCTIONAL_REQUIREMENTS.md` (FR-001 through FR-054, plus FR-019 added by the Phase 3 amendment round) is covered by at least one story in `08_EPICS_AND_USER_STORIES.md`, with two explicitly-noted exceptions already flagged in that document's §8.1: FR-001 is folded into US-OWNER-001 rather than given a separate story, and purely System-actor infrastructure FRs (e.g. FR-017's local caching) are represented by their observable consequence story (US-OWNER-014) rather than a story of their own, since a user story requires a human-facing want/benefit and "the system caches data locally" has none independent of the outcomes already covered.

### Stories not backed by an FR
None found. Every story traces to a specific HLR and FR/BR pairing, shown inline in `08_EPICS_AND_USER_STORIES.md`.

### Acceptance criteria that depend on unresolved questions
These ACs are written to the best currently-available specification but their exact pass condition depends on an item still open in `34_OPEN_QUESTIONS.md`, and must be revisited once that item resolves:

- **US-CHILD-006 AC1** depends on OQ-04a (exact reminder interval, 30 minutes proposed but not fixed).
- **US-CHILD-008 AC3** depends on OQ-29 (Focus Session violation handling — reset vs. pause-and-flag not yet decided); the AC is deliberately written to only require that a violation is detected and not silently ignored, without asserting which handling is correct.
- **US-CHILD-014 AC3** depends on OQ-30 (Apple picker/ManagedSettings technical validation for Phone/Messages/Maps); the AC is written to require honest, policy-only copy until that validation completes, rather than asserting a specific technical guarantee now.
- **US-OWNER-024 AC2** depends on OQ-20 (whether a further Owner-exit path is needed when no Guardian exists); the current AC reflects the V1 "invite a Guardian or delete the household" behaviour only, per the existing recommended default.

None of these four dependencies block Phase 5 from starting, since each AC is written to be correct under either resolution of its open question; they are flagged so the eventual resolution is checked against the AC rather than silently assumed compatible.

### Missing negative/failure scenarios
On review, no story was found with only a happy-path AC and no corresponding failure/alternative scenario, with one accepted exception: **US-CHILD-003** (Earn First condition completion) has only a happy path and a scope-boundary AC (no silent renegotiation), because Earn First's own failure modes (a rejected/incomplete condition) are already fully covered under Epic C's task-approval stories (US-CHILD-005/US-OWNER-015) rather than needing a duplicate failure AC here — flagged explicitly rather than silently omitted.

### Contradictions found
None. This is the first pass through Phase 4, built directly on the founder-approved, fully-amended Phase 3 baseline (`35_DECISION_LOG.md` DEC-32 through DEC-39), so no conflicting requirements were introduced.
