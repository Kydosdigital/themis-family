# 11. Task and Approval Specification

**Status:** Phase 3 draft
**Depends on:** `10_RULE_ENGINE_SPECIFICATION.md` §10.5 (Verification Type), `35_DECISION_LOG.md` DEC-15, DEC-16, DEC-25, DEC-28

---

## 11.1 Task lifecycle overview

A Task is an instance of a condition attached to a rule (e.g. "today's homework," generated from a recurring Task Template, or a one-off). Its lifecycle differs by Verification Type:

- **Parent Approval tasks:** Scheduled/Available → (deadline passes, if applicable) → Overdue → Submitted → Awaiting Approval → Approved/Rejected → Completed/Expired
- **Automatic Verification tasks:** Scheduled/Available → In Progress (timer/focus session running) → Completed (system-verified) — no Awaiting Approval state exists in this path.

Formal state machine diagrams are a Phase 5 deliverable (`20_STATE_MACHINES.md`); this document specifies the transitions and rules precisely enough to build that machine without further product decisions.

---

## FR-030. Child/Teen submits task completion
- **Actor:** Child or Teen
- **Trigger:** Child/Teen taps "Submit"/"Done" on a task with Verification Type = Parent Approval
- **Preconditions:** Task is in Available or Overdue state
- **Happy path:** Task moves to Awaiting Approval. Child/Teen sees an honest "Waiting for approval" state (not a generic locked screen). All eligible approvers (Owner, and Guardian if present) are notified.
- **Alternative paths:** Child submits before the deadline; the task's deadline then passes while it is still Awaiting Approval — status becomes "Submitted On Time, Awaiting Approval" and a 30-minute Approval Grace Period begins per BR-207 (`10_RULE_ENGINE_SPECIFICATION.md`, DEC-40); the shield does not apply during the grace period, but does apply automatically if the grace period expires with no decision.
- **Failure paths:** Child device is offline when submitting → submission is queued and shown as "Submitting..." until connectivity returns; it must not be shown as "Awaiting Approval" (a state that hasn't actually been recorded by the backend yet) nor silently fail.
- **Permissions:** Child/Teen may only submit their own tasks.
- **Offline behaviour:** Submission requires eventual connectivity to reach approvers (approval is a cross-device operation); local queuing as above.
- **Data required:** Task ID, submission timestamp, optional child-entered note
- **Notification behaviour:** Immediate notification to all eligible approvers.
- **Business rules:** BR-207 (deadline-vs-pending-approval interaction, defined in `10_RULE_ENGINE_SPECIFICATION.md`)
- **Release:** V1 / Must

## FR-031. Approver reviews and decides
- **Actor:** Owner or Guardian
- **Trigger:** Approver opens a pending Awaiting Approval task
- **Preconditions:** Task is in Awaiting Approval state
- **Happy path:** Approver taps Approve → task moves to Approved/Completed → the rule's associated shield is removed on the child's device → child sees confirmation ("Done. [X] unlocked.").
- **Alternative paths:** Approver taps Reject ("Needs work") → task returns to Overdue (or Available, if before deadline) with a note to the child explaining what's missing (CONFIRMED, DEC-38 — closes OQ-25: the note is optional, the UI should strongly encourage a short explanation via a prominent open field, but submitting a rejection is never blocked on providing one; no open-ended conversation thread is created by a rejection note — it is one-way, distinct from the bounded clarification exchange in FR-042); child may resubmit. For a Deadline Lock task specifically, the timing of the decision relative to the 30-minute Approval Grace Period (BR-207, DEC-40) determines the resulting enforcement state: approval/rejection during the grace period resolves it immediately with no shield ever applying (if approved) or an immediate shield (if rejected); approval after the grace period has already expired and the shield has activated removes the shield at that point (subject to BR-211 if another rule still applies).
- **Failure paths:** Two approvers act on the same task within the race window → BR-102 (`18_ROLES_AND_PERMISSIONS.md`) applies: first valid decision wins, the other is told the outcome.
- **Permissions:** Owner, Guardian only (BR-105)
- **Offline behaviour:** The approval decision is recorded by the backend and pushed to the child device; if the child device is offline at the moment of approval, the shield is removed as soon as the device reconnects and syncs — the approval itself is not lost or time-limited by the child device being briefly offline.
- **Notification behaviour:** Child is notified of the outcome (approved/rejected) as soon as their device syncs.
- **Business rules:** BR-102, BR-207
- **Release:** V1 / Must

## FR-032. Non-response handling
- **Actor:** System (automatic), Child/Teen (one nudge)
- **Trigger:** A task remains in Awaiting Approval past the reminder interval with no approver decision
- **Preconditions:** Task is in Awaiting Approval state
- **Happy path (CONFIRMED — DEC-41, closes OQ-04a):** At submission, an immediate notification is sent to all eligible approvers and the "Waiting for approval" state is shown to the child with an elapsed-time indicator. At **15 minutes** after submission, if still unresolved, exactly **one automatic reminder** is sent to all eligible approvers — this does not repeat. Independently of the automatic reminder's timing, the child/teen may send exactly **one manual "Send a reminder" nudge** per pending item, at any time after submission; sending the nudge does not reset or restart the automatic reminder's own 15-minute schedule — the two are entirely independent. Once both the automatic reminder and the child's one nudge have been used (or the automatic reminder's window has passed even if the child never nudges), Themis sends no further reminder notifications for that pending item — the task remains visibly Awaiting Approval, but silently, until an approver acts.
- **Failure paths:** No approver ever responds → the task remains in Awaiting Approval indefinitely; the restriction remains active indefinitely; this is the deliberately-chosen behaviour (DEC-15) rather than a failure state requiring special handling, though it is a real-world scenario worth surfacing to the parent via reporting (e.g. "3 requests are still awaiting your response").
- **Business rules:** BR-212 (no auto-approval, ever, in V1 — restates DEC-15), BR-213 (one nudge only, per pending item, not per session, independent of the automatic reminder — DEC-41)
- **Notification behaviour:** Immediate on submission; exactly one automatic reminder at 15 minutes if still unresolved; exactly one child-triggered nudge, on demand, capped at one per pending item and independent of the automatic reminder; no further reminders after both have been used.
- **Release:** V1 / Must
- **Open questions:** None outstanding — OQ-04a is closed by DEC-41.

**BR-212.** No task's restriction may be automatically lifted due to elapsed time alone, in V1, under any circumstance. This is an intentional, permanent-for-V1 design choice (DEC-15), not a placeholder pending a future feature — the future "trusted task auto-grace" feature (also DEC-15) is a distinct, opt-in, explicitly-configured mechanism, not a default timeout.

**BR-213 (CONFIRMED — DEC-41).** The child/teen's manual reminder ("nudge") is capped at exactly one use per pending Awaiting Approval item, and operates entirely independently of the automatic 15-minute reminder — using the nudge does not reset or restart the automatic reminder's schedule, and the automatic reminder firing does not consume or reset the child's nudge. Once used, the nudge control is disabled (shown, not hidden, so the child understands they've already used it) until the item is resolved. After both the automatic reminder and the manual nudge have been used, no further reminder notifications are sent for that item.

## FR-033. Automatic Verification completion
- **Actor:** Child/Teen (starts the session), System (verifies completion)
- **Trigger:** Child/Teen starts an in-app session associated with a task whose Verification Type is Automatic Verification
- **Preconditions:** Task is Available; Verification Type = Automatic Verification; the task's Session Type (§11.1a) is set to either Active Engagement Session or Focus Session
- **Happy path:** Session runs to completion, per the backgrounding rule for its Session Type (§11.1a) → system records a completion event → task moves directly to Completed → associated shield is removed immediately, with no approval step and no "Awaiting Approval" state ever entered.
- **Alternative paths:** Backgrounding/locking behaviour during the session is governed entirely by which Session Type the task uses — see §11.1a. This FR does not define a single universal backgrounding rule; DEC-37 confirmed that one rule cannot correctly serve both session kinds.
- **Failure paths:** App is terminated mid-session (force-quit, crash, memory pressure, device restart) → handling differs by Session Type and is no longer a flat reset: for an **Active Engagement Session**, see the persistence/Resume model in §11.1a (BR-232, DEC-43) — legitimate foreground progress is not lost to a termination outside the child's control; for a **Focus Session**, termination of Themis itself does not violate the session (consistent with BR-228, since Themis being closed is compatible with staying away from restricted apps) — only opening a specifically-restricted app is a violation (BR-231).
- **Business rules:** BR-209 (`10_RULE_ENGINE_SPECIFICATION.md` — evidence scope), BR-214, BR-227, BR-228 (§11.1a)
- **Release:** V1 / Must
- **Open questions:** None outstanding — OQ-24 is closed by DEC-37/§11.1a below.

**BR-214.** A parent may reconfigure any specific rule/task from Automatic Verification to Parent Approval at any time (but not the reverse for a condition type that isn't system-verifiable — see FR-016's failure path). Changing this setting applies to future task instances, not retroactively to a task already in progress.

---

## 11.1a Automatic Verification session types (CONFIRMED, DEC-37 — closes OQ-24)

A single "does the timer pause when backgrounded" rule cannot correctly describe every Automatic Verification use case, because two genuinely different things were being conflated under one "timer/focus session" label. V1 formalises exactly two Session Types, and every Automatic Verification task must be configured as one or the other — there is no third, undifferentiated "timer" option.

### Active Engagement Session
- **Purpose:** The child is meant to be actively using a specific in-app experience right now (the canonical example: an in-app reading session).
- **Backgrounding rule (BR-227):** If Themis leaves the foreground, or the device locks, the verified activity timer **pauses**. It resumes only when the required in-app experience returns to the foreground. Backgrounded time is never counted as elapsed. Only foreground active-engagement time counts toward completion at any point.
- **App termination/crash/restart handling (CONFIRMED — DEC-43, replaces the original "force-quit resets with no partial credit" behaviour):** A child must not lose legitimate progress because iOS terminates the app, the app crashes, memory pressure closes it, or the device restarts — none of these are the child's fault and a hard reset in every case would be unfair. Instead: while the session is running, Themis periodically persists the last trustworthy accumulated **foreground** duration locally (exact persistence cadence and mechanism: Phase 5, BR-232). When Themis reopens after any such termination:
  - if the session's integrity can be verified (the persisted state is internally consistent and was not tampered with — exact integrity model: Phase 5, BR-232), the child is offered **Resume** from the persisted elapsed foreground duration; no time that passed while the app was terminated/closed is ever counted towards completion;
  - if integrity cannot be verified, the session is marked **Interrupted** and the child is told clearly why (e.g. "We couldn't confirm your last session, so it's been reset — start again when you're ready"), consistent with the Focus Session's neutral, non-blaming tone (BR-231).
  - Under no circumstances is completion automatically granted based on wall-clock time elapsed while the app was absent — only verified foreground engagement counts.
- **Truthful completion statement:** *"15-minute in-app reading session completed."*
- **What it must NOT claim:** *"Child definitely read for 15 minutes."* The evidence is that the in-app session ran to completion in the foreground, not proof of the underlying real-world activity (this restates DEC-28/BR-209's capability-honesty standard for this specific Session Type).

### Focus Session
- **Purpose:** The child is meant to intentionally stay away from a configured set of distracting apps for a period (e.g. "30 minutes away from games and social apps").
- **Backgrounding rule (BR-228):** A Focus Session **may continue** while Themis itself is backgrounded or the device is locked, because backgrounding Themis is entirely compatible with the intended behaviour — the child isn't meant to be looking at Themis, they're meant to be away from the restricted apps. The session is only invalidated if the child opens one of the specific apps the Focus Session restricts during the session window (a violation, handled per the failure path below), not merely by backgrounding Themis.
- **Truthful completion statement:** *"30-minute focus session completed under the configured restrictions."*
- **What it must NOT claim:** *"30 minutes of homework completed."* The evidence is that the configured restricted apps were not opened during the session window, not proof that any particular productive activity occurred.
- **Failure path (CONFIRMED — DEC-42, closes OQ-29):** A Focus Session represents one continuous successful period of staying away from the configured restricted apps. If the child opens one of the specifically restricted apps during an active Focus Session, the session is marked **Interrupted**: the current attempt ends immediately, no completion credit is awarded, and the accumulated time from that attempt does not carry over or count toward completion in any way. The child may start a fresh Focus Session attempt immediately — there is no cooldown or penalty period before retrying. V1 deliberately keeps this deterministic and simple; configurable grace behaviour (e.g. a one-time warning before interruption) is a FUTURE FEATURE, not V1.
- **Child-facing copy for an interruption (CONFIRMED — DEC-42):** Neutral, non-punitive wording only, e.g. *"Focus session interrupted. Start again when you're ready."* The product must NOT use "Failed," "You broke the rule," or any shame-oriented wording for this state.

**Business-rule summary:**

**BR-227.** An Active Engagement Session's timer pauses on backgrounding/device lock and resumes on return to foreground; backgrounded time is never counted.

**BR-232 (Active Engagement Session termination persistence — CONFIRMED, DEC-43).** Themis must persist the last trustworthy accumulated foreground duration of a running Active Engagement Session locally, such that an app termination, crash, memory-pressure closure, or device restart does not by itself cause the child to lose legitimate, already-earned foreground progress. On reopening, a verifiable persisted state offers Resume from that exact point; an unverifiable one is marked Interrupted with a clear, non-blaming explanation. Wall-clock time elapsed while the app was not running is never counted toward completion, regardless of which path is taken. The exact local persistence mechanism and the integrity-verification model (what makes a persisted state "trustworthy" versus suspect) are Phase 5 deliverables (`19_DATA_MODEL.md`, `20_STATE_MACHINES.md`) — this rule fixes the product behaviour the Phase 5 mechanism must deliver, not the mechanism itself.

**BR-228.** A Focus Session continues running while Themis is backgrounded or the device is locked, provided none of that Focus Session's specifically restricted apps are opened during the window.

**BR-231 (Focus Session violation handling — CONFIRMED, DEC-42; closes OQ-29).** Opening a specifically-restricted app during an active Focus Session immediately marks that attempt Interrupted: the attempt ends, no completion credit is awarded, and no partial/accumulated time is preserved or carried into a subsequent attempt. The child may begin a new Focus Session attempt immediately with no cooldown. All child-facing copy for this state must be neutral and non-punitive (see above) — this is a deterministic, simple V1 behaviour; anything more forgiving (e.g. a grace allowance) is explicitly deferred as a FUTURE FEATURE.

**DEC-37 also updates DEC-28/BR-209's general wording (`10_RULE_ENGINE_SPECIFICATION.md` §10.5):** "deterministic system evidence" now explicitly branches into these two Session Type-specific evidence statements rather than one generic "timer completed" statement — see the cross-reference added there.

---

## 11.2 Open questions surfaced by this document

**OQ-24 [CLOSED — resolved by DEC-37, see §11.1a].** Replaced by the Active Engagement Session / Focus Session distinction rather than a single universal backgrounding rule.

**OQ-25 [CLOSED — resolved by DEC-38].** A rejection note is optional, strongly encouraged via a prominent UI field, never mandatory, and remains one-way (not a conversation thread).

**OQ-29 [CLOSED — resolved by DEC-42, see BR-231].** A Focus Session violation marks the attempt Interrupted (no reset-vs-pause ambiguity — "Interrupted" is its own terminal state for that attempt): the attempt ends, no credit is awarded, no time carries over, and the child may start fresh immediately. Copy must be neutral, never punitive-sounding.
