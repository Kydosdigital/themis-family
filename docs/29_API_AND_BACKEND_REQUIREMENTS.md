# 29. API and Backend Requirements

**Status:** Phase 5 draft
**Depends on:** `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`, `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`

This document specifies backend behaviour requirements at a logical level (what the API must guarantee, not endpoint-by-endpoint wire specifications or a technology choice) since production code/implementation is out of scope for this engagement phase.

## 29.1 Authoritative-source principle

**CONFIRMED REQUIREMENT.** The backend is the single authoritative source of truth for every entity in `19_DATA_MODEL.md` §19.2 except the two explicitly device-local derived values named in §19.4 (Resolved Shield List, live protection-status display). Every client (child device, parent/guardian device, any future web dashboard) is a cache-and-render layer over backend state; no client-side conflict resolution logic should ever be required for entities that only the backend can authoritatively decide, by construction (per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.3's single-owner rule).

## 29.2 Idempotency

**CONFIRMED REQUIREMENT.** Every write endpoint that a client can call while recovering from a dropped connection, app crash, or offline-queue flush (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.5) must accept a client-generated idempotency key and guarantee that repeated calls with the same key produce exactly one effect. This applies at minimum to: Task submission, Request creation, TemporaryAccessGrant creation, EngagementSession outcome reporting. It does not need to apply to read endpoints or to Owner/Guardian actions that require connectivity anyway and are not queued (rule authoring, approvals) — though making those idempotent too is a reasonable, low-cost defensive choice and is a **RECOMMENDATION**, not a strict requirement.

## 29.3 Versioning for staleness and sync efficiency

**CONFIRMED REQUIREMENT.** Every device carries a `ResolutionVersion` (`19_DATA_MODEL.md` §19.2), incremented atomically by the backend on any change affecting that device's enforcement state. Sync requests from a device should be able to pass their last-seen version and receive only the delta since then (RECOMMENDATION for efficiency, full-state fallback acceptable for V1 per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.8).

## 29.4 Atomic approval handling (implements BR-102 / `16_DEVICE_ENFORCEMENT.md` §16.7)

**CONFIRMED REQUIREMENT.** The endpoint(s) that record a Task/Request approval or rejection decision must implement this as a single atomic operation guaranteeing:
1. The decision is recorded exactly once, even under concurrent requests for the same Task/Request (e.g. an Owner and a Guardian both tapping "Approve" within the same second).
2. Exactly one of the concurrent requests is treated as authoritative; the other(s) receive a response indicating the item was already resolved (and by whom), rather than silently succeeding a second time or erroring uninformatively.
3. The affected device's `ResolutionVersion` is incremented as part of the same atomic operation, not as a separate follow-up step that could itself race or be skipped on partial failure.

**This is the direct backend-level specification of the race condition already identified in `16_DEVICE_ENFORCEMENT.md` §16.7 and §20.11** — restated here as an explicit backend contract rather than left purely as an architectural principle, since it is the concrete requirement an implementing engineer must satisfy.

## 29.5 Expiry computation (Requests, Grace Periods, Grants)

**CONFIRMED REQUIREMENT.** Time-based automatic transitions (Request expiry per DEC-39, Task Grace Period entry/exit per DEC-40, TemporaryAccessGrant expiry) must be evaluated **server-side**, not left to client-side timers, since a client-side-only timer would not fire if no client happens to be open at the exact expiry moment and would also be subject to the untrusted-device-clock problem already flagged in `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7. **RECOMMENDATION:** implement via a scheduled backend job (or equivalent durable-timer mechanism) that evaluates due expiries and performs the same atomic state-change-plus-version-increment pattern as §29.4, so a Task's transition into `GracePeriod` or `ExpiredUnresolved` (per `20_STATE_MACHINES.md` §20.4) happens reliably regardless of whether any client is connected at that moment. This is necessary for the shield to actually activate on an unresolved Deadline Lock even if the child's device happens to be the only one that would otherwise notice the deadline passing — the device must be told (or must itself notice on its own local clock as a fallback, per §17.7's caveat about untrusted local time being used only as a stopgap, not primary authority) via the next sync.

## 29.6 Push notification role

**RECOMMENDATION, not a hard requirement given the constraints already established:** the backend should send a silent push to the relevant child device whenever a `ResolutionVersion` change occurs that plausibly changes that device's Resolved Shield List (a new grace-period entry, an approval, a grant expiry), to reduce (not eliminate, per `16_DEVICE_ENFORCEMENT.md` §16.6's analysis) the latency before the device's next foreground-triggered resync. This is explicitly a latency-reduction measure, not a substitute for the mandatory foreground correction pass, since push delivery itself is not guaranteed and the `DeviceActivityMonitor` extension cannot act on a push directly in any case that has been confirmed (§27.4 constraints).

## 29.7 Role-and-permission enforcement at the API layer

**CONFIRMED REQUIREMENT.** Every write endpoint must enforce the role permissions confirmed in `18_ROLES_AND_PERMISSIONS.md` server-side, not merely hide disallowed actions in client UI. This is a standard security requirement restated here explicitly because several Phase 3/4 decisions (e.g. BR-101/DEC-45's Owner-only household deletion, the Owner/Guardian-only rule-authoring restriction from `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.4) are safety- and account-integrity-relevant, not merely cosmetic UX gating.

## 29.8 Rate/abuse considerations (flagged, not fully specified)

**OPEN QUESTION (new, OQ-37):** no Phase 1–4 document addresses whether a child could abuse the Request/Task submission or Free Pass activation endpoints (e.g. rapid repeated Request creation to flood a Guardian's approval queue, or repeatedly triggering the offline-outbox idempotency path to probe for a race). This is a plausible abuse vector for a system explicitly designed to be used by a party (the child) whose incentives are sometimes adversarial to the restriction being enforced. **Not addressed by any confirmed requirement and not invented here** — flagged for Phase 6 (likely `21_SECURITY_REQUIREMENTS.md`, not yet written) rather than silently assumed away.

## 29.9 Backend actions identified as capable of racing (consolidated list, feeds end-of-Phase-5 cross-check)

1. Two approvals on the same Task/Request (§29.4) — resolved via atomic compare-and-increment.
2. Offline outbox replay producing duplicate Task/Request/Grant/Session-outcome records (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.5) — resolved via idempotency keys.
3. Server-side scheduled expiry job vs. a simultaneous manual approval arriving in the same moment a Grace Period is about to lapse (e.g. a Guardian's approval and the automatic `GracePeriod` → `ExpiredUnresolved` transition happening within the same instant) — **newly identified here**: **RECOMMENDATION** that the scheduled expiry job and the manual-approval endpoint both go through the same atomic version-increment primitive described in §29.4, so whichever actually commits first server-side wins deterministically, with the loser's caller informed the item was already resolved, exactly as in the two-human-approvers case. This should be confirmed as an explicit implementation requirement in Phase 6/7, not left implicit.
4. EngagementSession client-side foreground-vs-termination-timer race (`20_STATE_MACHINES.md` §20.11) — a client-local race, not a backend one, but listed here for completeness since it feeds the same end-of-phase cross-check.

No other backend race conditions were identified beyond those already surfaced in `16_DEVICE_ENFORCEMENT.md` and `20_STATE_MACHINES.md`; this document's contribution is converting those architectural observations into explicit backend-contract requirements (idempotency keys, atomic compare-and-increment, server-authoritative expiry evaluation).
