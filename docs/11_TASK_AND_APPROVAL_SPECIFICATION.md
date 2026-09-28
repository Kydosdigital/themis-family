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
- **Alternative paths:** Approver taps Reject ("Needs work") → task returns to Overdue (or Available, if before deadline) with an optional note to the child explaining what's missing; child may resubmit.
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
- **Actor:** Child/Teen (starts the timer/session), System (verifies completion)
- **Trigger:** Child/Teen starts an in-app timer or focus session associated with a task whose Verification Type is Automatic Verification
- **Preconditions:** Task is Available; Verification Type = Automatic Verification
- **Happy path:** Timer/session runs to completion within the app → system records a completion event → task moves directly to Completed → associated shield is removed immediately, with no approval step and no "Awaiting Approval" state ever entered.
- **Alternative paths:** Child backgrounds the app or locks the device mid-timer → RECOMMENDATION (not yet founder-confirmed): the timer pauses and does not count backgrounded time as elapsed, to preserve the "deterministic system evidence" standard in BR-209; see OQ-24.
- **Failure paths:** App is force-quit mid-timer → timer resets (no partial credit) per the same reasoning.
- **Business rules:** BR-209 (`10_RULE_ENGINE_SPECIFICATION.md` — evidence scope), BR-214
- **Release:** V1 / Must
- **Open questions:** OQ-24 (backgrounding behaviour)

**BR-214.** A parent may reconfigure any specific rule/task from Automatic Verification to Parent Approval at any time (but not the reverse for a condition type that isn't system-verifiable — see FR-016's failure path). Changing this setting applies to future task instances, not retroactively to a task already in progress.

---

## 11.2 Open questions surfaced by this document

**OQ-24 [NEW].** Does an in-app timer/focus session pause when the app is backgrounded or the device is locked, or does it continue counting?
- *Why it matters:* Directly affects whether Automatic Verification evidence is genuinely deterministic (BR-209). If the timer keeps running while the child does something else entirely, "the timer completed" stops being meaningful evidence of anything.
- *Recommended default:* Pause on background/lock, resume on foreground; do not count backgrounded time. This is the more conservative, defensible interpretation of DEC-28's "deterministic system evidence" standard, but has UX trade-offs (a child who receives a phone call mid-timer loses progress) worth testing.
- *Blocks:* `10_RULE_ENGINE_SPECIFICATION.md`/`20_STATE_MACHINES.md` (Phase 5) — the Task state machine's in-progress-timer sub-states.

**OQ-25 [NEW].** When a Reject ("Needs work") decision is made, is a note from the approver to the child mandatory, optional, or absent in V1?
- *Why it matters:* An unexplained rejection undermines the "agreement, not punishment" positioning (a child who did the homework and gets rejected with no reason feels arbitrarily punished).
- *Recommended default:* Optional but strongly encouraged (UI defaults to an open note field, not required to submit). Do not make it mandatory in V1 to avoid adding friction that discourages parents from rejecting when they should.
- *Blocks:* `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` (the clarification mechanism, DEC-29, is a related but distinct concept — a rejection note is one-way, not a bounded exchange).
