# 26. Error and Edge Case Catalogue

**Status:** Phase 7 draft
**Depends on:** `16_DEVICE_ENFORCEMENT.md` §16.11, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `20_STATE_MACHINES.md`, `29_API_AND_BACKEND_REQUIREMENTS.md` §29.9, `09_ACCEPTANCE_CRITERIA.md`, `24_SECURITY_REQUIREMENTS.md`

## 26.1 Purpose

This document consolidates every failure path, race condition, and edge case already identified across Phases 3–6 into one catalogue, each tagged with its confirmed resolution (or its open-question/spike dependency if unresolved), so Phase 7's `31_TEST_STRATEGY.md` and `32_TRACEABILITY_MATRIX.md` have a single source to test against. It does not invent new edge cases beyond what is implied by already-confirmed behaviour, except where noted as **[NEW, Phase 7]**.

## 26.2 Onboarding and pairing

| # | Edge case | Resolution status |
|---|---|---|
| EC-01 | Child device authorisation (`.child`) declined at prompt | CONFIRMED — onboarding cannot reach "Themis Protection Activated" (FR-008); parent shown a clear retry path |
| EC-02 | Family Controls authorisation revoked externally after activation (child ages to adult account, parent edits Settings directly) | CONFIRMED — detected next foreground check, not real-time (§27.2 VERIFIED); device moves to `ProtectionUnavailable` (§20.2/§16.8) |
| EC-03 | Pairing code/QR expires before the child device completes enrolment | **[NEW, Phase 7]** RECOMMENDATION: code has a short validity window (implementation detail) and a clear re-generate path; not previously specified since the pairing model itself is new in Phase 6 (DEC-54) |
| EC-04 | Guardian invited before Owner completes their own onboarding | **[NEW, Phase 7]** RECOMMENDATION: invitation is valid but the invited Guardian sees an appropriately incomplete household state, not an error |
| EC-05 | Parent attempts to add a child device that is already paired to a different household | **[RESOLVED — DEC-60, Phase 7]** CONFIRMED — the device cannot be silently re-paired. A blocking state is shown; the parent must perform a secure recovery flow requiring authorised-adult verification. See SEC-017 and the following edge cases (EC-05a–g). |

## 26.3 Rule engine and enforcement

| # | Edge case | Resolution status |
|---|---|---|
| EC-06 | Two rules covering overlapping targets/schedules | CONFIRMED — effective-enforcement model (BR-211/DEC-32): a target stays restricted while any active rule still covers it |
| EC-07 | Marking a target Always Allowed while it's targeted by an active restrictive rule | CONFIRMED — BR-220: automatically removed from the restrictive rule, parent informed |
| EC-08 | Shield property exceeds Apple's documented 50-item limit | NEEDS REAL-DEVICE TECHNICAL SPIKE — exceeded-limit failure behaviour unverified (`10_RULE_ENGINE_SPECIFICATION.md` FR-010, Priority 4 spike) |
| EC-09 | Extension-applied shield state disagrees with the main app's Local Enforcement Plan after a missed/delayed `DeviceActivityMonitor` callback | CONFIRMED, accepted bounded window — resolved on next mandatory foreground correction pass (`16_DEVICE_ENFORCEMENT.md` §16.4/§16.11 item 3) |
| EC-10 | Device clock manually changed to defeat a time-based rule | OPEN — OQ-32, Priority 6 real-device spike |
| EC-11 | Device offline beyond its Local Enforcement Plan's precomputed look-ahead horizon | CONFIRMED fail-safe — last-known restriction is kept, never relaxed, surfaced via the five-state staleness model (§16.8) |
| EC-12 | Child attempts to bypass Phone/Messages/Maps shielding assumptions | OPEN — OQ-30, genuinely UNKNOWN pending spike, Priority 2 |

## 26.4 Tasks, requests, and approvals

| # | Edge case | Resolution status |
|---|---|---|
| EC-13 | Child taps "Done" moments before a Deadline Lock deadline without genuinely finishing | CONFIRMED — 30-minute Provisional Approval Grace Period (DEC-40); shield activates if unresolved at expiry |
| EC-14 | Two approvers (Owner + Guardian) act on the same item simultaneously | CONFIRMED — atomic `resolution_version` compare-and-increment (§16.7/§29.4); loser informed the item was already resolved |
| EC-15 | Scheduled server-side expiry job and a manual approval commit in the same instant | CONFIRMED REQUIREMENT (elevated from RECOMMENDATION this phase, per `29_API_AND_BACKEND_REQUIREMENTS.md` §29.9 item 3) — both paths go through the same atomic version-increment primitive; whichever commits first server-side wins deterministically |
| EC-16 | Parent never responds to a task/request | CONFIRMED — no auto-unlock; honest "Waiting for approval" state, one automatic reminder + one child nudge (DEC-41), then no further reminders |
| EC-17 | Automatic Verification session backgrounded | CONFIRMED, split by Session Type — Active Engagement Session pauses (DEC-37); Focus Session may continue by design |
| EC-18 | Focus Session violation occurs mid-session | CONFIRMED — `Interrupted`, no credit, immediate fresh restart, neutral copy (DEC-42) |
| EC-19 | Active Engagement Session terminated (crash/force-quit/memory pressure/device restart) | CONFIRMED — persisted locally, resumable via `TerminatedPendingResume` (DEC-43) |
| EC-20 | `TerminatedPendingResume` never resumed | CONFIRMED — becomes `Abandoned` after the earlier of context expiry or 24 hours from last checkpoint (DEC-49) |
| EC-21 | Request clarification exchanged more than once | CONFIRMED — bounded to exactly one prompt/one reply, then a decision (FR-042) |
| EC-22 | Free Pass revoked while the child is actively using the granted access | CONFIRMED — "Revocation sent" → "Access revoked" pattern; child device recomputes its Local Enforcement Plan (§16.9a) |
| EC-23 | Outcome submission arrives very late due to an offline gap spanning a deadline/grace window | CONFIRMED — trusted-time model reconciles genuinely on-time evidence automatically; uncertain evidence escalates to "Timing could not be verified" (§17.7a) rather than silently crediting or penalising |
| EC-24 | Monotonic clock manipulated on a compromised device to falsify the above | OPEN, deliberately — OQ-40/SEC-016, secure default is "Timing could not be verified," never an unverified advantage |

## 26.5 Sync, offline, and data integrity

| # | Edge case | Resolution status |
|---|---|---|
| EC-25 | Offline-outbox replay after reconnection | CONFIRMED — idempotency keys prevent duplicate Task/Request/Grant/Session-outcome records (§17.5/§29.2) |
| EC-26 | Backend outage while child device is online | CONFIRMED — child device continues enforcing its last-synced Local Enforcement Plan; parent app shows "Can't reach Themis servers — showing last-known status" (NFR-006) |
| EC-27 | Device never reconnects before a linked Task/Request context expires server-side | ADDRESSED via the trusted-time model by direct analogy (OQ-34); real-device validation of monotonic-clock-across-reboot reliability still needed |

## 26.6 Subscription and billing

| # | Edge case | Resolution status |
|---|---|---|
| EC-28 | Payment fails on renewal | CONFIRMED — enters Apple's 16-day Billing Grace Period; full enforcement/management continues (DEC-55) |
| EC-29 | Apple's Billing Grace Period expires without recovery | CONFIRMED — `Protection Expired`, restrictions actively cleared, parent and child informed (§25.2) |
| EC-30 | Apple's own billing-retry mechanism continues past the Grace Period | CONFIRMED — Themis does not extend full functionality on the strength of Apple's continued retries alone (§25.2) |
| EC-31 | Household resubscribes after `Protection Expired` | CONFIRMED — explicit parent-confirmed reactivation flow, never automatic (DEC-57/§25.6) |
| EC-32 | Voluntary cancellation mid-paid-period | CONFIRMED — full service continues to the paid-through date, with advance notice, then `Protection Expired` identically (§25.2) |

## 26.7 Support and account lifecycle

| # | Edge case | Resolution status |
|---|---|---|
| EC-33 | Parent requests account/data deletion via support rather than self-service | CONFIRMED — permitted only after strong Owner-identity verification, irreversibility explained, no content browsing required (§30.5a) |
| EC-34 | Support attempts an action outside its confirmed scope (e.g. editing a rule) | CONFIRMED as a **prevented** case, not merely a documented one — server-side role/ownership validation (SEC-007) applies to staff tooling exactly as it does to household members, per the corrected §30.3a scope |
| EC-35 | Owner attempts to leave a household with no other Guardian to transfer to | CONFIRMED — not a supported path; the only two V1 exit routes are transfer-then-leave or full household deletion (DEC-45) |
| EC-36 | A removed/de-authorised device or Member attempts continued API access | CONFIRMED — must lose access immediately as part of the same atomic removal operation (SEC-002) |
| EC-05a | Device re-pairing: normal transfer (old household removes device, new household pairs it) | CONFIRMED — atomic credential revocation, old household notified, old household binding cleared, device may then pair with new household (DEC-60, SEC-017) |
| EC-05b | Device re-pairing: old household removes device while new household attempts pairing concurrently | CONFIRMED — only one binding becomes active; race resolved by atomic version-increment mechanism (similar to EC-14/EC-15) |
| EC-05c | Device re-pairing: two households attempt pairing concurrently without prior removal | CONFIRMED — blocking state shown for whichever pairing attempt loses the race; system never permits simultaneous bindings |
| EC-05d | Device re-pairing: transfer interrupted after old credential revocation but before new credential issuance | CONFIRMED — device is unbound but unable to progress to new household; explicit recovery/retry path required; no orphaned state persists indefinitely |
| EC-05e | Device re-pairing: recovery attempted without sufficient authorised-adult verification | CONFIRMED — recovery flow fails; user may retry with correct verification or return to prior household's pairing flow |
| EC-05f | Device re-pairing: recovery completes while old household device/dashboard is offline | CONFIRMED — the old household's device/dashboard detects binding loss on next sync (treated as a device-removal sync event); protection status clears |
| EC-05g | Device re-pairing: new household pairing succeeds but old dashboard has stale "Protected" state | CONFIRMED — the old household's stale state is a manifestation of normal device-offline detection (EC-26), not a re-pairing-specific failure; next sync clears the stale state or the staleness threshold triggers a downgrade from Protected to Sync Pending |

## 26.8 New items surfaced by this cross-check

**OQ-42 [RESOLVED — DEC-60, Phase 7 founder review round, 2026-09-28].** Can a child device already paired to one household be paired to a second household?
- *Resolution:* Confirmed as a binding invariant (DEC-60, SEC-017): a device cannot be silently re-paired. Normal transfer requires explicit removal from the prior household with notification; recovery cases require secure authorised-adult re-pairing without silent reassignment. Device re-pairing is confirmed as a Phase 7 product decision / Phase 7–8 implementation topic, not a Phase 7 blocker.
- *Blocks:* None (resolved).

## 26.9 Cross-check

Every edge case in §26.2–26.7 traces to an already-confirmed DEC/FR/BR/OQ from Phases 3–6, re-tagged here with its current resolution status for test-planning purposes. EC-03, EC-04, EC-05, and its sub-cases (EC-05a–g) are genuinely new observations arising from assembling this catalogue, each flagged as such rather than presented as previously decided. OQ-42 is resolved (DEC-60).
