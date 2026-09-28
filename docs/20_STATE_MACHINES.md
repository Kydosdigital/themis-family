# 20. State Machines

**Status:** Phase 5 draft
**Depends on:** `19_DATA_MODEL.md` (field/entity names below match that document exactly)

Ten state machines are defined below, matching the founder's required minimum list. Each includes states, transitions, triggers, and the guarding business rule where one exists. Transitions with no corresponding requirement, and requirements with no corresponding transition, are flagged inline and summarised in §20.11.

## 20.1 Household

States: `Active` → `Deleted`

- `Active` → `Deleted`: triggered by Owner-initiated deletion (BR-101/DEC-45, one of the two confirmed Owner-exit paths). Cascades: all Devices de-enrolled (`revokeAuthorization` per §27.2), all Members removed, Subscription cancelled.
- No other states exist for Household in V1 — there is no "Suspended" or "Paused" household state. **RECOMMENDATION carried from `16_DEVICE_ENFORCEMENT.md` §16.10:** a lapsed-subscription household is not itself a distinct Household state; it is represented via the Subscription entity's own state machine (§20.10), leaving Household binary (Active/Deleted) deliberately simple.

## 20.2 Device Protection Status

This is a **derived/computed** state (per `19_DATA_MODEL.md` §19.4), not a persisted field, but is specified here as a state machine since it has clear discrete values and transitions the product must display correctly.

States: `NotEnrolled` → `AuthorizationPending` → `Protected` → `NotActive` (terminal-ish, can return to `Protected`) → `Removed` (terminal)

- `NotEnrolled` → `AuthorizationPending`: parent begins device onboarding, `requestAuthorization(for: .child)` called (§27.2).
- `AuthorizationPending` → `Protected`: Apple authorization granted and at least one active Rule resolves successfully to a Resolved Shield List.
- `AuthorizationPending` → `NotEnrolled`: authorization declined or abandoned.
- `Protected` → `NotActive`: `authorizationStatus` changes externally (child ages to adult account, parent changes Settings directly) per §27.2's VERIFIED external-revocation finding, detected on next foreground check (`16_DEVICE_ENFORCEMENT.md` §16.9).
- `NotActive` → `Protected`: re-authorization succeeds (parent re-grants in Settings, or age-out is reversed — the latter is likely not practically reversible, flagged as **UNKNOWN**, not assumed either way).
- `Protected`/`NotActive` → `Removed`: Owner/Guardian removes the device (FR-007) or the device replacement flow (§16.9) is completed.

## 20.3 Rule

States: `Draft` → `Active` → `Inactive`/`Superseded` → `Deleted`

- `Draft` → `Active`: Owner/Guardian completes authoring and confirms (rule creation requires connectivity per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.4).
- `Active` → `Inactive`: rule's own schedule window closes for the current cycle (a Scheduled Rule between windows is Inactive, not Deleted — it reactivates automatically at its next scheduled window without re-authoring). This distinguishes "temporarily not in force" from "removed."
- `Inactive` → `Active`: schedule window reopens (fully automatic, no human action).
- `Active`/`Inactive` → `Deleted`: Owner/Guardian explicitly removes the rule.
- **Override rules (DEC-32) do not have a separate state shape** — they follow the same Draft/Active/Inactive/Deleted machine as any Rule; what differs is only their `override_scope` field and how `16_DEVICE_ENFORCEMENT.md` §16.3 step 2 combines them with other active rules, not their own lifecycle.

## 20.4 Task

States: `Pending` → `Submitted` → `Approved`/`Rejected`; alternate paths: `Pending`/`Submitted` → `GracePeriod` → `Approved`/`Rejected`/`ExpiredUnresolved`; session-linked: `Pending` → `InSession` → `Submitted` (as above)

- `Pending` → `Submitted`: child submits completion (or, for a Deadline-Lock task, submits before or during the deadline).
- `Pending`/`Submitted` (still undecided) at `deadline_at` → `GracePeriod`: automatic transition per DEC-40, lasting 30 minutes.
- `GracePeriod` → `Approved`/`Rejected`: an Owner/Guardian decision arrives within the window (BR-207).
- `GracePeriod` → `ExpiredUnresolved`: window closes with no decision; this is the state that triggers the shield per BR-211's effective-enforcement model (a Task in `ExpiredUnresolved` is treated as an active restriction, not as "approved by default" or "rejected by default" — it is its own distinct state precisely because neither of those would be accurate).
- `ExpiredUnresolved` → `Approved`: a late decision can still arrive and immediately lifts the restriction (explicitly confirmed by BR-207's "activates the shield until subsequently approved" wording).
- `Pending` → `InSession` → `Submitted`: for session-linked tasks (Active Engagement Session/Focus Session), entering the session is itself a sub-transition tracked by the EngagementSession entity (§20.8/§20.9), with the Task's own status reflecting `Submitted`/`Interrupted` based on the session's outcome per DEC-42.
- **No transition exists from `Approved`/`Rejected` back to any other state** — these are terminal per Task, consistent with there being no confirmed "reopen a decided task" requirement anywhere in Phase 3/4. **No gap identified.**

## 20.5 Approval

Modelled as a sub-state of Task/Request rather than a standalone entity (per `19_DATA_MODEL.md`, there is no separate Approval table — approval is `resolved_by_member_id`/`resolved_at`/`status` fields on Task and Request). The state machine is therefore the `Approved`/`Rejected` terminal branch already described in §20.4 (Task) and §20.6 (Request) respectively; this section exists only to confirm no separate machine was omitted by oversight.

## 20.6 Request

States: `Pending` → `Approved`/`Rejected`/`Expired`

- `Pending` → `Approved`/`Rejected`: Owner/Guardian decision (BR-218).
- `Pending` → `Expired`: automatic, at the sooner of the linked context ending or the 4-hour backstop (DEC-39/BR-229).
- All three non-`Pending` states are terminal; no confirmed requirement allows reopening a Request. **No gap identified.**

## 20.7 Temporary Access / Free Pass (TemporaryAccessGrant)

States: `Active` → `Expired`; alternate: `Active` → `Revoked`

- Creation directly enters `Active` (no draft state — a grant is created already in force, per its preset-driven, often self-service nature).
- `Active` → `Expired`: automatic at `expires_at`.
- `Active` → `Revoked`: **OPEN QUESTION (new, OQ-35):** Phase 3/4 documents confirm Free Pass presets and scope/duration rules (DEC-33) but no document explicitly confirms whether an Owner/Guardian can revoke an already-active grant early. This is a plausible and probably expected capability (a parent should likely be able to cancel a Free Pass they or the child activated in error) but is **not a confirmed requirement** — flagged here as a genuine gap rather than assumed. If confirmed by the founder, `Revoked` is a simple terminal transition triggered by Owner/Guardian action; if not confirmed, this state and transition should be removed from the final model.

## 20.8 Active Engagement Session

States: `Running` → `Completed`; alternate: `Running` → `Backgrounded` → `TerminatedPendingResume` → `Resumed`(new session, `Running`)/`Abandoned`

- `Running` → `Completed`: session finishes without backgrounding, per its own confirmed rule (pauses, rather than fails, on backgrounding — DEC-37).
- `Running` → `Backgrounded`: app is backgrounded; per DEC-37 this pauses rather than terminates.
- `Backgrounded` → `Running`: app is re-foregrounded before any termination threshold, session resumes counting.
- `Backgrounded` → `TerminatedPendingResume`: backgrounding persists past whatever threshold triggers termination handling (exact threshold not restated here, confirmed in `11_TASK_AND_APPROVAL_SPECIFICATION.md` §11.1a); per DEC-43's persist-and-verify model, this is not a failure state but a checkpoint — session progress is persisted.
- `TerminatedPendingResume` → `Resumed`: child reopens and continues; modelled as a **new** EngagementSession row with `resume_of_session_id` pointing at the terminated one (per `19_DATA_MODEL.md` §19.2), rather than mutating the original row, preserving a full audit trail of the resume chain.
- `TerminatedPendingResume` → `Abandoned`: **OPEN QUESTION (new, OQ-36):** no confirmed requirement states what happens if a terminated-pending-resume session is never resumed at all (does the linked Task simply remain `InSession` forever, or does it eventually fall back to `Pending`/expire?). Flagged as a genuine gap for founder review, not assumed.

## 20.9 Focus Session

States: `Running` → `Completed`; alternate: `Running` → `Interrupted`

- `Running` → `Completed`: session finishes with no disqualifying violation, continuing through backgrounding as designed (DEC-37 — this is the defining difference from Active Engagement Session).
- `Running` → `Interrupted`: a violation occurs (per DEC-42's confirmed "Interrupted, no credit, neutral copy" handling). This is terminal — per BR-231, an interrupted Focus Session does not resume; if the child wants to try again, a new session is started (modelled as a new EngagementSession row, not a resume chain, since Focus Session's Interrupted state has no confirmed "resume" concept, unlike Active Engagement Session's TerminatedPendingResume).

## 20.10 Subscription

States: `Active` → `Lapsed`; alternate (RECOMMENDATION only): `Lapsed` → `InGrace` → `Active`/`Enforcement Suspended`

- `Active` → `Lapsed`: payment fails or subscription is cancelled, reported by the App Store/payment processor.
- **The `InGrace` state and its transitions are a Phase 5 RECOMMENDATION, not a confirmed requirement** (per `16_DEVICE_ENFORCEMENT.md` §16.10/OQ-33) — Phase 6's subscription document must confirm or reject this before it is treated as final. Shown here only to make explicit that this state machine is intentionally incomplete pending that decision, rather than silently omitted.
- `Lapsed`/`InGrace` → `Active`: payment resumes successfully.

## 20.11 End-of-Phase-5 cross-check: transitions without requirements, requirements without transitions

**Transitions with no backing requirement (flagged as needing founder confirmation before being treated as final, not deleted, since they represent reasonable product behaviour that simply hasn't been explicitly decided):**
- TemporaryAccessGrant `Active` → `Revoked` (§20.7, OQ-35).
- EngagementSession `TerminatedPendingResume` → `Abandoned` (§20.8, OQ-36).
- Subscription `InGrace` state entirely (§20.10, OQ-33, already flagged in `16_DEVICE_ENFORCEMENT.md`).

**Requirements identified in Phase 3/4 with no corresponding state transition above (checked against `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `18_ROLES_AND_PERMISSIONS.md`):**
- **None identified.** Every confirmed FR/BR that describes a state change (approval, expiry, session outcome, device/household lifecycle, rule activation) was traced to a transition in §20.1–20.10 during this document's drafting. This is stated as a positive finding, not assumed by default — the cross-referencing was done document-by-document against the full list of confirmed DEC-##/BR-##/FR-## entries currently in `35_DECISION_LOG.md`.

**Backend actions that could race, beyond those already covered in `16_DEVICE_ENFORCEMENT.md` §16.7/§16.11:**
- EngagementSession `Backgrounded` → `Running` vs `Backgrounded` → `TerminatedPendingResume`, if the app is foregrounded at almost exactly the termination threshold. **New identified race (not previously flagged):** whichever event (foreground detection vs. threshold timer) the client processes first determines the outcome, and both are client-side/local events with no server arbitration needed since the EngagementSession's authoritative outcome is only finalised when reported to the server (per `19_DATA_MODEL.md`). **RECOMMENDATION:** the client should resolve this race by always preferring "Running" if the foreground event and the threshold timer fire within the same event-loop tick, since resuming a session the child is actively looking at is the safer default than terminating one they just reopened. Not yet founder-confirmed; flagged for Phase 5 review.
