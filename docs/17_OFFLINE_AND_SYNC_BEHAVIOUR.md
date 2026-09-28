# 17. Offline and Sync Behaviour

**Status:** Phase 5, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` Phase 5 amendment completion note)
**Depends on:** `16_DEVICE_ENFORCEMENT.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `19_DATA_MODEL.md`

## 17.1 Purpose

Defines what happens on every device in the system (child devices and parent/guardian devices) when connectivity is intermittent or absent, and how state reconciles once connectivity returns. This document assumes the on-device **Local Enforcement Plan** model from `16_DEVICE_ENFORCEMENT.md` §16.3 (this document originally referred to a "Resolved Shield List"; that concept was replaced this amendment round by the richer Local Enforcement Plan, which additionally precomputes upcoming transitions and their resulting shield operations, not merely the current state).

## 17.2 Core principle: fail-safe, never fail-open

**CONFIRMED REQUIREMENT.** When a device cannot reach the backend, it continues enforcing the last successfully generated Local Enforcement Plan rather than clearing restrictions. This is consistent with the product's existing safety posture (BR-222's hard safety principle, the general "protection status reflects last-confirmed state" principle from DEC-27) and is stated here explicitly as the governing principle for every offline scenario below, so no future document needs to re-derive it per case.

## 17.3 Local (on-device) state vs server-owned state

| State | Owned by | Cached locally on | Notes |
|---|---|---|---|
| Rule definitions (Scheduled Rule, Deadline Lock, Free Pass presets, etc.) | Server | Child device (read-only cache) | Authored on parent/guardian device, pushed to server, pulled by child device |
| Local Enforcement Plan | Computed locally, derived from server-owned rule/grant state | Child device only | Never stored server-side as its own entity; it is a derived, device-local artifact (`16_DEVICE_ENFORCEMENT.md` §16.3) |
| Task/Request/Approval state | Server | Both child and parent devices (read-through cache) | Server is the single arbiter of "approved" vs "pending" vs "rejected"; see §17.5 for offline submission |
| Household/membership/roles | Server | All devices (read-through cache) | Changes here are rare and always require connectivity to take effect (e.g. inviting a member) |
| Active Engagement/Focus Session in-progress state | **Device-local while running**, reported to server on completion/interruption | Child device | See §17.6 |
| Subscription state | Server (source of truth is the App Store/payment processor via server) | All devices (cached) | Out of scope for enforcement detail here; see `16_DEVICE_ENFORCEMENT.md` §16.10 and Phase 6 |

**CONFIRMED REQUIREMENT:** no state in this system is ever "owned" by more than one party. Every entity above has exactly one authoritative owner; every other copy is an explicitly-labelled cache. This single-owner rule is what makes the conflict rules in §17.4 tractable — conflicts only need to be resolved for the narrow set of things that can be *created* offline (task submissions, requests), never for things that are edited in two places at once, because rule/role editing is Owner/Guardian-only, requires connectivity by design (§17.4), and Task/Request creation is a single-writer-per-item operation (only the child submits their own task; only they submit their own request).

## 17.4 Sync conflict rules

- **Rule authoring requires connectivity.** **CONFIRMED REQUIREMENT:** the app does not allow an Owner/Guardian to create or edit a Rule while offline; the rule-editing UI is disabled with a clear "You're offline; rule changes require a connection" message. This sidesteps an entire class of conflict (two guardians editing the same rule while both offline, producing divergent versions) by simply not allowing the risky action offline at all, rather than building last-write-wins or merge logic for something safety-relevant. **RECOMMENDATION**, not yet founder-confirmed as final; flagged for founder review since it does constrain a founder-desired capability if guardians expect to be able to queue rule changes offline.
- **Task/Request submission is allowed offline** (a child completing a task or making a request should not be blocked by their own connectivity) **and is queued** (§17.5) with a client-generated idempotency key (§17.5) so it cannot be double-submitted on retry.
- **Approval decisions require connectivity on the approving device** (an Owner/Guardian approving a Task/Request must have connectivity for that decision to be recorded, since it is the safety-relevant state change; there is no valid offline "shadow approval" since the child device would have no way to trust an unsynced local approval was genuine, which would defeat the entire model).
- **Race between two approvers (Owner and Guardian) is resolved server-side**, not by any client conflict rule, per `16_DEVICE_ENFORCEMENT.md` §16.7's atomic `resolution_version` mechanism.

## 17.5 Offline queue and idempotency

**CONFIRMED REQUIREMENT.** Every child-device action that can be performed offline (Task completion submission, Request creation, Free Pass activation where the preset allows it) is written to a local outbox queue with:
- a client-generated UUID (the idempotency key),
- the local device timestamp of creation,
- a **trusted-time record** (§17.7) alongside the local timestamp,
- the action payload.

On reconnection, the app flushes the outbox in creation order. The backend's write endpoint for each of these action types is idempotent on the client-generated UUID: a retried or duplicate submission (e.g. the app crashed after a successful server write but before it could mark the outbox entry as flushed) is detected and ignored server-side rather than creating a duplicate Task-completion or Request record. **This directly answers the founder's requirement to identify backend actions that could race/duplicate:** offline queue replay is the primary identified duplication risk, resolved via idempotency keys rather than client-side "did I already send this" heuristics, which would be unreliable across app restarts/crashes.

## 17.6 Active Engagement Session / Focus Session offline behaviour

Per DEC-42/DEC-43 (Phase 4 amendments already confirmed), these sessions have specific backgrounding and termination rules. Restated here in terms of connectivity:

- **CONFIRMED REQUIREMENT:** both session types run and are timed entirely device-locally while in progress; they do not require connectivity to start, run, or (for Focus Sessions) continue through backgrounding. This is necessary since a session's entire purpose (screen-time-free or app-restricted focus) is orthogonal to network connectivity.
- On completion, interruption (Focus Session, DEC-42), or termination requiring persist-and-verify/Resume (Active Engagement Session, DEC-43), the outcome is written to the offline outbox exactly as in §17.5 and flushed on reconnection using the same idempotency mechanism.
- **OQ-34, addressed via the trusted-time model (§17.7a):** if a device never reconnects before the session's associated Task/Rule context expires server-side, the eventual late-arriving outcome is evaluated per §17.7a's reconciliation rule — if trustworthy timing evidence establishes the outcome genuinely occurred within the valid context window, it is reconciled as on-time after reconnect; otherwise it is surfaced to the parent for an explicit manual decision rather than silently auto-credited or silently rejected. This is the same principle §17.7a establishes for Deadline Lock submissions, applied here by direct analogy.
- **OQ-36, CONFIRMED this amendment round (Active Engagement Session `TerminatedPendingResume` abandonment, closes OQ-36; full state detail in `20_STATE_MACHINES.md` §20.8):** a session in `TerminatedPendingResume` remains resumable until the **earlier of** the linked task/context's own expiry, **or 24 hours from the last trustworthy session checkpoint**. If not resumed by then, the session becomes `Abandoned`: no completion credit is awarded, persisted partial time is retained only as historical/debug information per the retention policy (Phase 6, `23_PRIVACY_AND_CHILD_SAFETY.md`), and if the underlying task/context remains valid the child may start a fresh session. There is no indefinite `InSession`/`TerminatedPendingResume` state in V1.

## 17.7a Trusted-time model for offline submissions (replaces the server-received-time-only mechanic; resolves OQ-34/updates RISK-25)

**CONFIRMED REQUIREMENT.** The Phase 5 original design used server-received time as the sole authority for evaluating whether an offline submission fell within a Deadline Lock's window or its subsequent grace period, on the reasoning that device-local wall-clock time cannot be trusted (it is user-editable). The founder's review confirms that reasoning but directs a more precise mechanism than "trust the server-received time alone and treat everything else as simply late," since that alone cannot distinguish a genuinely on-time child who was offline from a child who tampered with their clock, and unfairly treats both as equivalent.

**The trusted-time model works as follows:**

1. **At every successful sync**, the child device records a **trusted-time anchor**: the server-provided authoritative timestamp at that moment, paired with the device's own **monotonic clock** reading at that same instant (a monotonic clock counts elapsed time since boot/an arbitrary reference point and — unlike the wall clock — cannot be changed by the user; it is not tied to a real-world date, only to elapsed duration). The anchor also records the `rule_config_version` and the relevant deadline/context snapshot active at that time.
2. **While offline**, the device estimates elapsed real-world time by measuring the monotonic clock's advance since the last trusted-time anchor, rather than trusting the user-editable wall clock alone. This lets the device derive "how much real time has actually passed since we last had a trusted server timestamp" even with no network, in a way that is resistant (though not necessarily immune — see below) to a manually altered wall clock.
3. **On an offline submission** (a Task completion, in particular one linked to a Deadline Lock), the outbox entry (§17.5) carries: the device-local wall-clock timestamp (informational only, as before), the monotonic-clock-derived elapsed-time-since-last-trusted-anchor estimate, and the last trusted-time anchor itself.
4. **On reconnection and flush**, the backend evaluates the submission using this evidence:
   - **If trustworthy timing can be established** (the monotonic-clock-derived estimate is consistent with the elapsed wall-clock time and with the server's own received-time upper bound, i.e. nothing suggests the wall clock was tampered with), and that estimate places the submission's genuine action time within the Deadline Lock's window or its 30-minute Provisional Approval Grace Period (DEC-40), **the submission may be reconciled as on-time**, even though it physically arrived at the server later.
   - **If trustworthy timing cannot be established** (e.g. the monotonic-clock evidence and wall-clock evidence disagree substantially, suggesting tampering or an unreliable estimate), the system does **not** silently auto-credit the submission as on-time, and does **not** silently treat it as late/accuse the child of missing the deadline either. It is surfaced to the parent/guardian as **"Timing could not be verified"**, with both the device-local claim and the server-received time shown, and the parent makes an explicit resolution (approve, reject, or request clarification) — the same human-in-the-loop pattern already established for ordinary approvals.
5. **This must be validated technically** (real-device spike, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8 Priority 6 covers device clock/timezone tampering generally; the monotonic-clock approach's practical reliability across iOS backgrounding/suspension/reboot is a NEEDS REAL-DEVICE TECHNICAL SPIKE item in its own right, since a monotonic clock's behaviour across a device reboot is itself something to confirm rather than assume — a reboot may reset the monotonic reference point, which would undermine an elapsed-time estimate spanning a reboot). **Device-reboot and clock-change scenarios are added to the spike/test plan accordingly.**

**RISK-25 updated to reflect this model** (see `33_PRODUCT_RISK_REGISTER.md`): the risk of a genuinely on-time child being penalised for a connectivity gap is mitigated, not eliminated, by the trusted-time reconciliation above — a submission with strong trustworthy-timing evidence is reconciled automatically; one without it is not silently penalised either, but instead escalated to the parent, which is the safest available fallback until the underlying mechanism is validated on real devices.

**OQ-32 (device clock/timezone tampering, `16_DEVICE_ENFORCEMENT.md` §16.8) remains open pending the technical spike** — the trusted-time model above is a mitigation for the honest-but-offline case, not a claimed solution to deliberate clock tampering, which is a distinct and harder problem the spike must still characterise.

## 17.8 Sync protocol summary

1. On foreground (and periodically while foregrounded, and on relevant push wake per `16_DEVICE_ENFORCEMENT.md` §16.6), the app:
   a. Flushes the offline outbox (§17.5) in order, applying the trusted-time evaluation (§17.7a) to any time-sensitive entries.
   b. Pulls current rule/grant/task/request/role state for the household, keyed by the last-seen `resolution_version` (§16.7) so only deltas since last sync are transferred where the backend supports it (RECOMMENDATION for efficiency; full-state pull is an acceptable fallback for V1).
   c. Regenerates the Local Enforcement Plan (`16_DEVICE_ENFORCEMENT.md` §16.3) and reapplies the current shield state.
   d. Records a fresh trusted-time anchor (§17.7a) and updates the device's "last synced" timestamp used for staleness detection (§16.8).
2. If the flush in step (a) fails partway (connectivity drops mid-sync), the outbox retains unflushed entries and the next sync attempt resumes from where it left off; no entry is discarded or marked flushed until the server has acknowledged it.

## 17.9 Summary: places offline and server state could disagree (feeds end-of-Phase-5 cross-check)

1. A device's Local Enforcement Plan can lag the server's true current rule state between syncs, or run out of precomputed transitions if offline longer than its look-ahead horizon — bounded by the foreground-correction pass (`16_DEVICE_ENFORCEMENT.md` §16.4) and accepted as a design trade-off, not eliminated.
2. A Task/Request/EngagementSession outcome recorded device-locally can be pending in the outbox for an unbounded time if the device stays offline — resolved on eventual reconnection via the trusted-time reconciliation (§17.7a) for time-sensitive cases, or the `TerminatedPendingResume` → `Abandoned` rule (§17.6) for session-specific cases.
3. Device-local wall-clock time used for Deadline Lock grace-period eligibility while offline is not trusted alone; the monotonic-clock-anchored trusted-time model (§17.7a) is used instead, with an explicit "Timing could not be verified" escalation path when even that cannot establish confidence — this can still surface an unresolved case to the parent, but no longer silently penalises or silently credits an ambiguous one (RISK-25, revised).
4. Protection-status display (`16_DEVICE_ENFORCEMENT.md` §16.9's authorization-revocation detection) can lag the true on-device Apple authorization state until the next foreground check — same bounded-lag pattern as item 1.
5. A remote approval or Free Pass revocation committed on the backend may not yet be applied on the child device — this is a latency window, not a data disagreement, and is addressed via the Approved/Applied UI distinction (`16_DEVICE_ENFORCEMENT.md` §16.6a) rather than a sync conflict rule.
