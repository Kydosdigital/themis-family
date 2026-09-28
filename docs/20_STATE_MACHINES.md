# 20. State Machines

**Status:** Phase 5, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` Phase 5 amendment completion note)
**Depends on:** `19_DATA_MODEL.md` (field/entity names below match that document exactly)

Ten state machines are defined below, matching the founder's required minimum list. Each includes states, transitions, triggers, and the guarding business rule where one exists. Transitions with no corresponding requirement, and requirements with no corresponding transition, are flagged inline and summarised in §20.11.

## 20.1 Household

States: `Active` → `Deleted`

- `Active` → `Deleted`: triggered by Owner-initiated deletion (BR-101/DEC-45, one of the two confirmed Owner-exit paths). Cascades: all Devices de-enrolled (`revokeAuthorization` per §27.2), all Members removed, Subscription cancelled.
- No other states exist for Household in V1 — there is no "Suspended" or "Paused" household state. **RECOMMENDATION carried from `16_DEVICE_ENFORCEMENT.md` §16.10:** a lapsed-subscription household is not itself a distinct Household state; it is represented via the Subscription entity's own state machine (§20.10), leaving Household binary (Active/Deleted) deliberately simple.

## 20.2 Device Protection Status

This is a **derived/computed** state (per `19_DATA_MODEL.md` §19.4), not a persisted field, but is specified here as a state machine since it has clear discrete values and transitions the product must display correctly.

**Amended this round to align with the five-state parent-facing model confirmed in `16_DEVICE_ENFORCEMENT.md` §16.8 (Protected / Sync Pending / Device Offline / Needs Attention / Protection Unavailable), plus the pre-enrollment/removal states this internal machine also needs to track:**

States: `NotEnrolled` → `AuthorizationPending` → `Protected` → {`SyncPending`, `DeviceOffline`, `NeedsAttention`} → `ProtectionUnavailable` (can return to `Protected`) → `Removed` (terminal)

- `NotEnrolled` → `AuthorizationPending`: parent begins device onboarding, `requestAuthorization(for: .child)` called (§27.2).
- `AuthorizationPending` → `Protected`: Apple authorization granted and at least one active Rule resolves successfully to a Local Enforcement Plan (`16_DEVICE_ENFORCEMENT.md` §16.3).
- `AuthorizationPending` → `NotEnrolled`: authorization declined or abandoned.
- `Protected` → `SyncPending`/`DeviceOffline`: the device has not successfully synced within the server-configurable staleness threshold (`16_DEVICE_ENFORCEMENT.md` §16.8); the exact distinction between these two sub-states (e.g. a brief lapse vs. a longer one) is left to the server-configurable thresholds, not fixed here.
- `SyncPending`/`DeviceOffline` → `Protected`: sync succeeds again before any further downgrade.
- `Protected`/`SyncPending`/`DeviceOffline` → `NeedsAttention`: a condition requiring parent action is detected that is not itself a full authorization loss (e.g. a Local Enforcement Plan could not be generated because of a configuration problem).
- Any of the above → `ProtectionUnavailable`: `authorizationStatus` changes externally (child ages to adult account, parent changes Settings directly) per §27.2's VERIFIED external-revocation finding, detected on next foreground check (`16_DEVICE_ENFORCEMENT.md` §16.9), **or** the household's subscription lapses beyond whatever grace behaviour Phase 6 confirms (§20.10).
- `ProtectionUnavailable` → `Protected`: re-authorization succeeds (parent re-grants in Settings, subscription resumes, or age-out is reversed — the latter is likely not practically reversible, flagged as **UNKNOWN**, not assumed either way).
- Any non-`Removed` state → `Removed`: Owner/Guardian removes the device (FR-007) or the device replacement flow (§16.9) is completed.

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

States: `Active` → `Expired`; alternate: `Active` → `Revoked` (sub-states `RevocationSent` → `RevocationConfirmed`, see below)

- Creation directly enters `Active` (no draft state — a grant is created already in force, per its preset-driven, often self-service nature).
- `Active` → `Expired`: automatic at `expires_at`.
- `Active` → `Revoked`: **CONFIRMED this amendment round, closes OQ-35.** An Owner/Guardian may revoke an already-active grant early. Behaviour (full detail in `16_DEVICE_ENFORCEMENT.md` §16.9a): the grant's `status` moves to `Revoked` via the same atomic approval-handling mechanism as any other approval-type action (§16.7); the backend increments `resolution_version`; the revocation is pushed/synchronised to the child device; the child device recomputes its Local Enforcement Plan and the overridden rule(s) resume applying. The transition itself is a single terminal state change (`Active` → `Revoked`), but the **parent-facing UI models two observable sub-states of that transition** — `revoked_at` is set immediately (parent sees "Revocation sent") and `applied_on_device_at` is set once the child device confirms (parent sees "Access revoked") — per `19_DATA_MODEL.md`'s `TemporaryAccessGrant.applied_on_device_at` field.

## 20.8 Active Engagement Session

States: `Running` → `Completed`; alternate: `Running` → `Backgrounded` → `TerminatedPendingResume` → `Resumed`(new session, `Running`)/`Abandoned`

- `Running` → `Completed`: session finishes without backgrounding, per its own confirmed rule (pauses, rather than fails, on backgrounding — DEC-37).
- `Running` → `Backgrounded`: app is backgrounded; per DEC-37 this pauses rather than terminates.
- `Backgrounded` → `Running`: app is re-foregrounded before any termination threshold, session resumes counting.
- `Backgrounded` → `TerminatedPendingResume`: backgrounding persists past whatever threshold triggers termination handling (exact threshold not restated here, confirmed in `11_TASK_AND_APPROVAL_SPECIFICATION.md` §11.1a); per DEC-43's persist-and-verify model, this is not a failure state but a checkpoint — session progress is persisted.
- `TerminatedPendingResume` → `Resumed`: child reopens and continues; modelled as a **new** EngagementSession row with `resume_of_session_id` pointing at the terminated one (per `19_DATA_MODEL.md` §19.2), rather than mutating the original row, preserving a full audit trail of the resume chain.
- `TerminatedPendingResume` → `Abandoned`: **CONFIRMED this amendment round, closes OQ-36.** A session remains resumable until the **earlier of** the linked task/context's own expiry, or **24 hours from `last_checkpoint_at`** (`19_DATA_MODEL.md`). If neither resume nor the context's own natural resolution happens by then, the session moves to `Abandoned`: no completion credit is awarded, the persisted partial time is retained only as historical/debug information per Phase 6's retention policy, and — if the underlying task/context is still valid — the child may start a fresh session (a new EngagementSession row, not a further resume of the abandoned one). There is no indefinite `InSession`/`TerminatedPendingResume` state in V1.

## 20.9 Focus Session

States: `Running` → `Completed`; alternate: `Running` → `Interrupted`

- `Running` → `Completed`: session finishes with no disqualifying violation, continuing through backgrounding as designed (DEC-37 — this is the defining difference from Active Engagement Session).
- `Running` → `Interrupted`: a violation occurs (per DEC-42's confirmed "Interrupted, no credit, neutral copy" handling). This is terminal — per BR-231, an interrupted Focus Session does not resume; if the child wants to try again, a new session is started (modelled as a new EngagementSession row, not a resume chain, since Focus Session's Interrupted state has no confirmed "resume" concept, unlike Active Engagement Session's TerminatedPendingResume).

## 20.10 Subscription — FINALISED this amendment round (`25_SUBSCRIPTIONS_AND_BILLING.md`, DEC-51 as revised by DEC-52–DEC-59, closes OQ-33/OQ-38/OQ-39)

States, involuntary billing failure path: `Active` → `Apple Billing Grace Period` → `Recovered` | `Protection Expired`
States, voluntary cancellation path: `Active` → `Cancelled (paid-through)` → `Protection Expired`
Reactivation: `Protection Expired` → `Active` (explicit parent-confirmed reactivation only, never automatic — §25.6)

- `Active` → `Apple Billing Grace Period`: a renewal payment fails, reported by the App Store. **Apple's own Billing Grace Period mechanism is used** (confirmed at 16 days for V1, `25_SUBSCRIPTIONS_AND_BILLING.md` §25.2) — this replaces the originally-sketched custom `Lapsed`/`InGrace` states, which risked layering a Themis-invented grace window on top of Apple's own billing-retry schedule.
- `Apple Billing Grace Period` → `Recovered`: Apple reports successful payment within the Grace Period; enforcement was never interrupted.
- `Apple Billing Grace Period` → `Protection Expired`: the Grace Period elapses without recovered payment; Themis-managed restrictions are actively cleared, regardless of whether Apple's own billing retries continue afterwards.
- `Active` → `Cancelled (paid-through)`: the parent voluntarily cancels; full service continues until the existing paid-through date, with advance notice given before it ends.
- `Cancelled (paid-through)` → `Protection Expired`: the paid-through date is reached with no active subscription; restrictions are actively cleared, identically to the involuntary-failure outcome. No additional custom grace period follows a voluntary cancellation.
- `Protection Expired` → `Active`: **not automatic.** Confirmed as an explicit, parent-confirmed reactivation flow ("Ready to turn protection back on?" → parent reviews existing rules → parent confirms → child device syncs the new Local Enforcement Plan → "Reactivation sent" → "Protection active on device"), per `25_SUBSCRIPTIONS_AND_BILLING.md` §25.6 — this avoids silently re-locking a device under months-old restrictions the instant a lapsed household's payment resumes.
- **No partial/reduced-enforcement middle state exists** (closes OQ-39, confirmed this amendment round): the model is deliberately binary (entitled-or-in-Grace-Period vs. Protection Expired), not a three-tier model with a reduced-enforcement middle state.

## 20.11 End-of-Phase-5 cross-check: transitions without requirements, requirements without transitions (re-run this amendment round)

**Transitions previously flagged as lacking a backing requirement — now resolved:**
- TemporaryAccessGrant `Active` → `Revoked` (§20.7) — **CONFIRMED, OQ-35 closed.**
- EngagementSession `TerminatedPendingResume` → `Abandoned` (§20.8) — **CONFIRMED, OQ-36 closed.**

**Resolved this amendment round (previously flagged as open):**
- Subscription state machine (§20.10) — **now fully finalised**: Apple Billing Grace Period model (16 days), voluntary-cancellation path, binary no-partial-enforcement model, and explicit parent-confirmed reactivation flow. Closes OQ-33, OQ-38, OQ-39.

**Requirements identified in Phase 3/4 with no corresponding state transition above (checked against `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `18_ROLES_AND_PERMISSIONS.md`):**
- **None identified.** Every confirmed FR/BR that describes a state change (approval, expiry, session outcome, device/household lifecycle, rule activation) was traced to a transition in §20.1–20.10 during this document's drafting. This is stated as a positive finding, not assumed by default — the cross-referencing was done document-by-document against the full list of confirmed DEC-##/BR-##/FR-## entries currently in `35_DECISION_LOG.md`.

**Backend actions that could race, beyond those already covered in `16_DEVICE_ENFORCEMENT.md` §16.7/§16.11:**
- EngagementSession `Backgrounded` → `Running` vs `Backgrounded` → `TerminatedPendingResume`, if the app is foregrounded at almost exactly the termination threshold. **New identified race (not previously flagged):** whichever event (foreground detection vs. threshold timer) the client processes first determines the outcome, and both are client-side/local events with no server arbitration needed since the EngagementSession's authoritative outcome is only finalised when reported to the server (per `19_DATA_MODEL.md`). **RECOMMENDATION:** the client should resolve this race by always preferring "Running" if the foreground event and the threshold timer fire within the same event-loop tick, since resuming a session the child is actively looking at is the safer default than terminating one they just reopened. Not yet founder-confirmed; flagged for Phase 5 review.
