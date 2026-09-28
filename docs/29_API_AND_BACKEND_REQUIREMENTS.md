# 29. API and Backend Requirements

**Status:** Phase 5, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` Phase 5 amendment completion note)
**Depends on:** `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`, `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`

This document specifies backend behaviour requirements at a logical level (what the API must guarantee, not endpoint-by-endpoint wire specifications or a technology choice) since production code/implementation is out of scope for this engagement phase.

## 29.1 Authoritative-source principle (confirmed this amendment round, closes OQ-31 at the backend-contract level)

**CONFIRMED REQUIREMENT.** The backend is authoritative for **shared business state**: rules, approvals, requests, grants, membership, subscription — every entity in `19_DATA_MODEL.md` §19.2 except the device-local `LocalEnforcementPlan` and the live protection-status display named in §19.4. Every client (child device, parent/guardian device, any future web dashboard) is a cache-and-render layer over this backend state for those entities; no client-side conflict resolution logic should ever be required for them, by construction (per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.3's single-owner rule).

**CONFIRMED ARCHITECTURAL BOUNDARY (per `16_DEVICE_ENFORCEMENT.md` §16.6):** the backend is explicitly **not** the runtime shield engine and must not be designed as one. The child device is authoritative for immediate device-enforcement execution — it generates and maintains its own `LocalEnforcementPlan` from the latest business-state snapshot it has synced. The backend's role on a relevant change is: commit the authoritative change, increment `resolution_version` (§29.3), and send a wake/sync signal where supported (§29.6) — never to compute or push a ready-made shield state the device merely applies verbatim. This boundary is restated here as a binding backend-contract requirement, not left only as an architectural principle in `16_DEVICE_ENFORCEMENT.md`, since it directly shapes what the API surface does and does not need to expose (no "set device shield state" endpoint exists or should exist; only business-state read/write endpoints plus a version/wake mechanism).

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

**CONFIRMED (restated precisely this amendment round, per `16_DEVICE_ENFORCEMENT.md` §16.6/§16.6a):** the backend sends a silent push to the relevant child device whenever a `ResolutionVersion` change occurs that plausibly changes that device's `LocalEnforcementPlan` (a new grace-period entry, an approval, a grant expiry or revocation). **Push is explicitly a latency optimisation, never the sole correctness mechanism** — it is not a substitute for the mandatory foreground correction pass, since push delivery itself is not guaranteed and the `DeviceActivityMonitor` extension cannot act on a push directly in any case that has been confirmed (§27.4 constraints). The exact reliability of this latency reduction is precisely what `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.3a/§27.8's Priority 1 real-device spike measures — this section states the intended role of push, not a claim about its measured performance.

## 29.7 Role-and-permission enforcement at the API layer

**CONFIRMED REQUIREMENT.** Every write endpoint must enforce the role permissions confirmed in `18_ROLES_AND_PERMISSIONS.md` server-side, not merely hide disallowed actions in client UI. This is a standard security requirement restated here explicitly because several Phase 3/4 decisions (e.g. BR-101/DEC-45's Owner-only household deletion, the Owner/Guardian-only rule-authoring restriction from `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.4) are safety- and account-integrity-relevant, not merely cosmetic UX gating.

## 29.8 Rate/abuse considerations — CONFIRMED at the policy level this amendment round, closes OQ-37

**CONFIRMED PRINCIPLE.** The backend must treat the child client as potentially adversarial for enforcement-related endpoints — not because the child is assumed to be malicious as a person, but as **ordinary defensive system design**: this is a system whose whole purpose is to restrict a party whose incentives are sometimes opposed to the restriction, so its API surface should be designed the same way any system is designed when one of its authenticated clients has a plausible incentive to misuse an endpoint (rapid repeated Request creation to flood a Guardian's approval queue, repeatedly triggering the offline-outbox idempotency path to probe for a race, oversized payloads, replaying a captured request).

**Phase 6's `24_SECURITY_REQUIREMENTS.md` must specify, at minimum:**
- Rate limiting on write endpoints, scoped per Member/device.
- Idempotency (already required, §29.2) and duplicate suppression.
- One-active-request-per-context where appropriate (e.g. a Member cannot have unlimited simultaneous pending Requests against the same rule/context).
- Server-side role/ownership validation on every write (already required, §29.7).
- Request-size limits.
- Replay protection.
- Audit logging for suspicious patterns.
- Protection against notification flooding (a child cannot force unlimited push/reminder notifications to a parent's device).

This closes OQ-37 at the product-policy level (yes, the backend must defend against this) with the exact controls specified in Phase 6, consistent with the founder's direction not to frame this as an accusation against the child, but as standard defensive engineering.

## 29.9 Backend actions identified as capable of racing (consolidated list, feeds end-of-Phase-5 cross-check)

1. Two approvals on the same Task/Request/Grant-revocation (§29.4, §16.9a) — resolved via atomic compare-and-increment.
2. Offline outbox replay producing duplicate Task/Request/Grant/Session-outcome records (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.5) — resolved via idempotency keys.
3. Server-side scheduled expiry job vs. a simultaneous manual approval arriving in the same moment a Grace Period is about to lapse (e.g. a Guardian's approval and the automatic `GracePeriod` → `ExpiredUnresolved` transition happening within the same instant) — **newly identified here**: **RECOMMENDATION** that the scheduled expiry job and the manual-approval endpoint both go through the same atomic version-increment primitive described in §29.4, so whichever actually commits first server-side wins deterministically, with the loser's caller informed the item was already resolved, exactly as in the two-human-approvers case. This should be confirmed as an explicit implementation requirement in Phase 6/7, not left implicit.
4. EngagementSession client-side foreground-vs-termination-timer race (`20_STATE_MACHINES.md` §20.11) — a client-local race, not a backend one, but listed here for completeness since it feeds the same end-of-phase cross-check.

No other backend race conditions were identified beyond those already surfaced in `16_DEVICE_ENFORCEMENT.md` and `20_STATE_MACHINES.md`; this document's contribution is converting those architectural observations into explicit backend-contract requirements (idempotency keys, atomic compare-and-increment, server-authoritative expiry evaluation).
