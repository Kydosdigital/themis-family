# 17. Offline and Sync Behaviour

**Status:** Phase 5 draft
**Depends on:** `16_DEVICE_ENFORCEMENT.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `19_DATA_MODEL.md`

## 17.1 Purpose

Defines what happens on every device in the system (child devices and parent/guardian devices) when connectivity is intermittent or absent, and how state reconciles once connectivity returns. This document assumes the on-device Resolved Shield List model from `16_DEVICE_ENFORCEMENT.md` §16.3.

## 17.2 Core principle: fail-safe, never fail-open

**CONFIRMED REQUIREMENT.** When a device cannot reach the backend, it continues enforcing the last successfully synced Resolved Shield List rather than clearing restrictions. This is consistent with the product's existing safety posture (BR-222's hard safety principle, the general "protection status reflects last-confirmed state" principle from DEC-27) and is stated here explicitly as the governing principle for every offline scenario below, so no future document needs to re-derive it per case.

## 17.3 Local (on-device) state vs server-owned state

| State | Owned by | Cached locally on | Notes |
|---|---|---|---|
| Rule definitions (Scheduled Rule, Deadline Lock, Free Pass presets, etc.) | Server | Child device (read-only cache) | Authored on parent/guardian device, pushed to server, pulled by child device |
| Resolved Shield List | Computed locally, derived from server-owned rule/grant state | Child device only | Never stored server-side as its own entity; it is a derived, device-local artifact (§16.3) |
| Task/Request/Approval state | Server | Both child and parent devices (read-through cache) | Server is the single arbiter of "approved" vs "pending" vs "rejected"; see §17.5 for offline submission |
| Household/membership/roles | Server | All devices (read-through cache) | Changes here are rare and always require connectivity to take effect (e.g. inviting a member) |
| Active Engagement/Focus Session in-progress state | **Device-local while running**, reported to server on completion/interruption | Child device | See §17.6 |
| Subscription state | Server (source of truth is the App Store/payment processor via server) | All devices (cached) | Out of scope for enforcement detail here; see `16_DEVICE_ENFORCEMENT.md` §16.10 |

**CONFIRMED REQUIREMENT:** no state in this system is ever "owned" by more than one party. Every entity above has exactly one authoritative owner; every other copy is an explicitly-labelled cache. This single-owner rule is what makes the conflict rules in §17.4 tractable — conflicts only need to be resolved for the narrow set of things that can be *created* offline (task submissions, requests), never for things that are edited in two places at once, because rule/role editing is Owner/Guardian-only, requires connectivity by design (§17.4), and Task/Request creation is a single-writer-per-item operation (only the child submits their own task; only they submit their own request).

## 17.4 Sync conflict rules

- **Rule authoring requires connectivity.** **CONFIRMED REQUIREMENT (new in Phase 5):** the app does not allow an Owner/Guardian to create or edit a Rule while offline; the rule-editing UI is disabled with a clear "You're offline; rule changes require a connection" message. This sidesteps an entire class of conflict (two guardians editing the same rule while both offline, producing divergent versions) by simply not allowing the risky action offline at all, rather than building last-write-wins or merge logic for something safety-relevant. **RECOMMENDATION**, not yet founder-confirmed as final; flagged for founder review since it does constrain a founder-desired capability if guardians expect to be able to queue rule changes offline.
- **Task/Request submission is allowed offline** (a child completing a task or making a request should not be blocked by their own connectivity) **and is queued** (§17.5) with a client-generated idempotency key (§17.5) so it cannot be double-submitted on retry.
- **Approval decisions require connectivity on the approving device** (an Owner/Guardian approving a Task/Request must have connectivity for that decision to be recorded, since it is the safety-relevant state change; there is no valid offline "shadow approval" since the child device would have no way to trust an unsynced local approval was genuine, which would defeat the entire model).
- **Race between two approvers (Owner and Guardian) is resolved server-side**, not by any client conflict rule, per `16_DEVICE_ENFORCEMENT.md` §16.7's atomic `resolution_version` mechanism.

## 17.5 Offline queue and idempotency

**CONFIRMED REQUIREMENT.** Every child-device action that can be performed offline (Task completion submission, Request creation, Free Pass activation where the preset allows it) is written to a local outbox queue with:
- a client-generated UUID (the idempotency key),
- the local device timestamp of creation,
- the action payload.

On reconnection, the app flushes the outbox in creation order. The backend's write endpoint for each of these action types is idempotent on the client-generated UUID: a retried or duplicate submission (e.g. the app crashed after a successful server write but before it could mark the outbox entry as flushed) is detected and ignored server-side rather than creating a duplicate Task-completion or Request record. **This directly answers the founder's requirement to identify backend actions that could race/duplicate:** offline queue replay is the primary identified duplication risk, resolved via idempotency keys rather than client-side "did I already send this" heuristics, which would be unreliable across app restarts/crashes.

The local device timestamp travels with the submission but **is not trusted as authoritative** for time-sensitive logic (e.g. "was this submitted before the Deadline Lock's deadline") — see §17.7.

## 17.6 Active Engagement Session / Focus Session offline behaviour

Per DEC-42/DEC-43 (Phase 4 amendments already confirmed), these sessions have specific backgrounding and termination rules. Restated here in terms of connectivity:

- **CONFIRMED REQUIREMENT:** both session types run and are timed entirely device-locally while in progress; they do not require connectivity to start, run, or (for Focus Sessions) continue through backgrounding. This is necessary since a session's entire purpose (screen-time-free or app-restricted focus) is orthogonal to network connectivity.
- On completion, interruption (Focus Session, DEC-42), or termination requiring persist-and-verify/Resume (Active Engagement Session, DEC-43), the outcome is written to the offline outbox exactly as in §17.5 and flushed on reconnection using the same idempotency mechanism.
- **OPEN QUESTION (new, OQ-34):** if a device never reconnects before the session's associated Task/Rule context expires server-side, what should the eventual late-arriving outcome do — is a very-late "Completed" submission still honoured, or does the context's own expiry (per DEC-39's 4-hour backstop concept, applied here by analogy) take precedence? Not resolved here; flagged for founder review before Phase 6 build sequencing finalises this path.

## 17.7 Time-sensitive offline submissions and the Provisional Approval Grace Period

**CONFIRMED REQUIREMENT.** Because device-local clocks are not trusted as authoritative (a device could have an incorrect or tampered clock, per `16_DEVICE_ENFORCEMENT.md` §16.8's OQ-32), any offline submission bearing on a deadline (a Deadline Lock task completion, in particular, given DEC-40's grace period) is timestamped **twice**: once with the device-local time at creation (informational only) and once with the **server-received time** at the moment it is actually flushed from the outbox (§17.5) — the latter is what the backend uses to evaluate whether the submission fell within the Deadline Lock's window or the subsequent 30-minute Provisional Approval Grace Period (DEC-40).

This has an important, previously undiscussed consequence, flagged here as a **new RISK (RISK-25, to be added to `33_PRODUCT_RISK_REGISTER.md`):** a child who completes a task on time but is offline for longer than the grace period before the submission can flush will have their on-time work recorded as late (or trigger the shield) through no fault of their own, purely due to connectivity, not compliance. **RECOMMENDATION:** the offline outbox entry's device-local creation timestamp should be surfaced to the approving parent/guardian alongside the server-received timestamp, so a human approver can see "child marked this done at 4:52pm, it reached us at 6:10pm" and make an informed manual judgement call, rather than the system silently penalising a connectivity gap as if it were lateness. This does not change BR-207's automated grace-period mechanics (which must still key off the server-received time, since the device-local time cannot be trusted for automatic decisions) but adds a transparency measure for the human-in-the-loop path. **Not yet founder-confirmed; flagged for Phase 5 founder review.**

## 17.8 Sync protocol summary

1. On foreground (and periodically while foregrounded, and on relevant push wake per `16_DEVICE_ENFORCEMENT.md` §16.6), the app:
   a. Flushes the offline outbox (§17.5) in order.
   b. Pulls current rule/grant/task/request/role state for the household, keyed by the last-seen `resolution_version` (§16.7) so only deltas since last sync are transferred where the backend supports it (RECOMMENDATION for efficiency; full-state pull is an acceptable fallback for V1).
   c. Recomputes the Resolved Shield List (§16.3) and reapplies it.
   d. Updates the device's "last synced" timestamp used for staleness detection (§16.8).
2. If the flush in step (a) fails partway (connectivity drops mid-sync), the outbox retains unflushed entries and the next sync attempt resumes from where it left off; no entry is discarded or marked flushed until the server has acknowledged it.

## 17.9 Summary: places offline and server state could disagree (feeds end-of-Phase-5 cross-check)

1. A device's Resolved Shield List can lag the server's true current rule state between syncs — bounded by the foreground-correction pass (`16_DEVICE_ENFORCEMENT.md` §16.4) and accepted as a design trade-off, not eliminated.
2. A Task/Request outcome recorded device-locally (e.g. Focus Session "Completed") can be pending in the outbox for an unbounded time if the device stays offline — resolved on eventual reconnection, but see OQ-34 for the edge case where the surrounding context has already expired server-side by then.
3. Device-local time used for Deadline Lock grace-period eligibility while offline is untrusted; only server-received time is authoritative (§17.7) — this can produce a result that feels unfair to the child even though it is deterministic and documented (RISK-25).
4. Protection-status display (`16_DEVICE_ENFORCEMENT.md` §16.9's authorization-revocation detection) can lag the true on-device Apple authorization state until the next foreground check — same bounded-lag pattern as item 1.
