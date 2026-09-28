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
- **Alternative paths:** Child submits before the deadline; task later becomes Overdue while still Awaiting Approval — per BR-207, the shield does not apply while a pre-deadline submission remains pending.
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
- **Alternative paths:** Approver taps Reject ("Needs work") → task returns to Overdue (or Available, if before deadline) with a note to the child explaining what's missing (CONFIRMED, DEC-38 — closes OQ-25: the note is optional, the UI should strongly encourage a short explanation via a prominent open field, but submitting a rejection is never blocked on providing one; no open-ended conversation thread is created by a rejection note — it is one-way, distinct from the bounded clarification exchange in FR-042); child may resubmit.
- **Failure paths:** Two approvers act on the same task within the race window → BR-102 (`18_ROLES_AND_PERMISSIONS.md`) applies: first valid decision wins, the other is told the outcome.
- **Permissions:** Owner, Guardian only (BR-105)
- **Offline behaviour:** The approval decision is recorded by the backend and pushed to the child device; if the child device is offline at the moment of approval, the shield is removed as soon as the device reconnects and syncs — the approval itself is not lost or time-limited by the child device being briefly offline.
- **Notification behaviour:** Child is notified of the outcome (approved/rejected) as soon as their device syncs.
- **Business rules:** BR-102, BR-207
- **Release:** V1 / Must

## FR-032. Non-response handling
- **Actor:** System (automatic), Child/Teen (one nudge)
- **Trigger:** A task remains in Awaiting Approval past a defined interval with no approver decision
- **Preconditions:** Task is in Awaiting Approval state
- **Happy path:** At submission, the "Waiting for approval" state is shown immediately with an elapsed-time indicator. At the defined reminder interval (RECOMMENDATION: 30 minutes, per OQ-04a — not yet fixed by the founder), a reminder notification is sent to all eligible approvers. The child/teen may send exactly one manual "Send a reminder" nudge per pending item, at any time after submission, which re-notifies approvers immediately (in addition to, not instead of, the automatic reminder).
- **Failure paths:** No approver ever responds → the task remains in Awaiting Approval indefinitely; the restriction remains active indefinitely; this is the deliberately-chosen behaviour (DEC-15) rather than a failure state requiring special handling, though it is a real-world scenario worth surfacing to the parent via reporting (e.g. "3 requests are still awaiting your response").
- **Business rules:** BR-212 (no auto-approval, ever, in V1 — restates DEC-15), BR-213 (one nudge only, per pending item, not per session)
- **Notification behaviour:** Immediate on submission; one automatic reminder at the defined interval; one child-triggered nudge, on demand, capped at one per pending item.
- **Release:** V1 / Must
- **Open questions:** OQ-04a (exact interval, 30 minutes proposed but not fixed)

**BR-212.** No task's restriction may be automatically lifted due to elapsed time alone, in V1, under any circumstance. This is an intentional, permanent-for-V1 design choice (DEC-15), not a placeholder pending a future feature — the future "trusted task auto-grace" feature (also DEC-15) is a distinct, opt-in, explicitly-configured mechanism, not a default timeout.

**BR-213.** The child/teen's manual reminder ("nudge") is capped at exactly one use per pending Awaiting Approval item. Once used, the control is disabled (shown, not hidden, so the child understands they've already used it) until the item is resolved.

## FR-033. Automatic Verification completion
- **Actor:** Child/Teen (starts the session), System (verifies completion)
- **Trigger:** Child/Teen starts an in-app session associated with a task whose Verification Type is Automatic Verification
- **Preconditions:** Task is Available; Verification Type = Automatic Verification; the task's Session Type (§11.1a) is set to either Active Engagement Session or Focus Session
- **Happy path:** Session runs to completion, per the backgrounding rule for its Session Type (§11.1a) → system records a completion event → task moves directly to Completed → associated shield is removed immediately, with no approval step and no "Awaiting Approval" state ever entered.
- **Alternative paths:** Backgrounding/locking behaviour during the session is governed entirely by which Session Type the task uses — see §11.1a. This FR does not define a single universal backgrounding rule; DEC-37 confirmed that one rule cannot correctly serve both session kinds.
- **Failure paths:** App is force-quit mid-session → session resets (no partial credit), for both Session Types, since a force-quit is not a state either Session Type's evidence standard can account for.
- **Business rules:** BR-209 (`10_RULE_ENGINE_SPECIFICATION.md` — evidence scope), BR-214, BR-227, BR-228 (§11.1a)
- **Release:** V1 / Must
- **Open questions:** None outstanding — OQ-24 is closed by DEC-37/§11.1a below.

**BR-214.** A parent may reconfigure any specific rule/task from Automatic Verification to Parent Approval at any time (but not the reverse for a condition type that isn't system-verifiable — see FR-016's failure path). Changing this setting applies to future task instances, not retroactively to a task already in progress.

---

## 11.1a Automatic Verification session types (CONFIRMED, DEC-37 — closes OQ-24)

A single "does the timer pause when backgrounded" rule cannot correctly describe every Automatic Verification use case, because two genuinely different things were being conflated under one "timer/focus session" label. V1 formalises exactly two Session Types, and every Automatic Verification task must be configured as one or the other — there is no third, undifferentiated "timer" option.

### Active Engagement Session
- **Purpose:** The child is meant to be actively using a specific in-app experience right now (the canonical example: an in-app reading session).
- **Backgrounding rule (BR-227):** If Themis leaves the foreground, or the device locks, the verified activity timer **pauses**. It resumes only when the required in-app experience returns to the foreground. Backgrounded time is never counted as elapsed.
- **Truthful completion statement:** *"15-minute in-app reading session completed."*
- **What it must NOT claim:** *"Child definitely read for 15 minutes."* The evidence is that the in-app session ran to completion in the foreground, not proof of the underlying real-world activity (this restates DEC-28/BR-209's capability-honesty standard for this specific Session Type).

### Focus Session
- **Purpose:** The child is meant to intentionally stay away from a configured set of distracting apps for a period (e.g. "30 minutes away from games and social apps").
- **Backgrounding rule (BR-228):** A Focus Session **may continue** while Themis itself is backgrounded or the device is locked, because backgrounding Themis is entirely compatible with the intended behaviour — the child isn't meant to be looking at Themis, they're meant to be away from the restricted apps. The session is only invalidated if the child opens one of the specific apps the Focus Session restricts during the session window (a violation, handled per the failure path below), not merely by backgrounding Themis.
- **Truthful completion statement:** *"30-minute focus session completed under the configured restrictions."*
- **What it must NOT claim:** *"30 minutes of homework completed."* The evidence is that the configured restricted apps were not opened during the session window, not proof that any particular productive activity occurred.
- **Failure path:** The child opens a restricted app during an active Focus Session → RECOMMENDATION (not yet founder-confirmed, tracked as OQ-29): the session either resets or pauses-and-flags depending on which is less punitive while still meaningful evidence; to be resolved before Phase 5's state machine for this Session Type.

**Business-rule summary:**

**BR-227.** An Active Engagement Session's timer pauses on backgrounding/device lock and resumes on return to foreground; backgrounded time is never counted.

**BR-228.** A Focus Session continues running while Themis is backgrounded or the device is locked, provided none of that Focus Session's specifically restricted apps are opened during the window; opening a restricted app during the session is a violation (exact handling: OQ-29).

**DEC-37 also updates DEC-28/BR-209's general wording (`10_RULE_ENGINE_SPECIFICATION.md` §10.5):** "deterministic system evidence" now explicitly branches into these two Session Type-specific evidence statements rather than one generic "timer completed" statement — see the cross-reference added there.

---

## 11.2 Open questions surfaced by this document

**OQ-24 [CLOSED — resolved by DEC-37, see §11.1a].** Replaced by the Active Engagement Session / Focus Session distinction rather than a single universal backgrounding rule.

**OQ-25 [CLOSED — resolved by DEC-38].** A rejection note is optional, strongly encouraged via a prominent UI field, never mandatory, and remains one-way (not a conversation thread).

**OQ-29 [NEW].** When a child opens a restricted app during an active Focus Session (a violation of §11.1a's Focus Session conditions), does the session reset entirely or pause-and-flag the violation?
- *Why it matters:* A full reset may feel disproportionately punitive for a brief lapse; a pause-and-flag risks weakening the "meaningful evidence" standard the Focus Session exists to provide (BR-228).
- *Recommended default:* None yet — needs founder judgement on the trade-off between fairness and evidentiary strength, informed by how Focus Session violations are actually detected on-device (a technical input from the Phase 5 spike, not purely a product call).
- *Blocks:* `20_STATE_MACHINES.md` (Phase 5) — the Focus Session sub-state machine.
