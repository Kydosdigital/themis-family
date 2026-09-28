# 16. Device Enforcement

**Status:** Phase 5, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` Phase 5 amendment completion note)
**Depends on:** `27_APPLE_INTEGRATION_REQUIREMENTS.md` (all capability statuses below are as classified there), `10_RULE_ENGINE_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`

## 16.1 Purpose

This document defines how the effective-enforcement model (DEC-32) and the various rule/grant/session types confirmed in Phases 3 and 4 are actually applied to a device's shield state, given the real constraints on Apple's frameworks established in §27. It is the bridge between "what the rules say should happen" (Phase 3) and "what code actually runs on the device" (Phase 6/7).

**Amendment note:** this document originally specified a "Resolved Shield List" artifact (a current shield state plus the next transition timestamp). The founder's review identified a real gap in that design — it told the `DeviceActivityMonitor` extension *when* something would next change, but not *what to change it to*, leaving the extension with no way to execute a scheduled transition correctly if the device never reconnects to the main app or backend before that transition arrives. This section replaces that concept with the richer **Local Enforcement Plan** (§16.3) throughout.

## 16.2 Enforcement components and their roles

| Component | Responsibility | Runs where |
|---|---|---|
| Main app | Rule authoring, sync with backend, `FamilyActivityPicker` selection, requesting authorization, generating the Local Enforcement Plan | Foreground/background app process |
| `DeviceActivityMonitor` extension | Receives scheduled interval start/end and threshold callbacks; executes the precomputed transition from the Local Enforcement Plan; applies/removes shield | Apple-managed extension process (memory-constrained, per §27.4) |
| `ShieldConfiguration` extension | Supplies the shield's displayed appearance (message, buttons) when the OS presents it | Apple-managed extension process |
| `ShieldAction` extension | Handles the child tapping a shield button (e.g. "Request more time") | Apple-managed extension process |
| App Group shared store | Holds the current Local Enforcement Plan, written by the main app on every recomputation, read by all extensions | Shared container, on-device only |
| Backend | Authoritative rule/grant definitions, approval state, cross-device consistency | Server |

**CONFIRMED REQUIREMENT (derived from §27.4).** Because extensions run under severe memory constraints and cannot reliably reach the network (NEEDS REAL-DEVICE SPIKE per §27.3/§27.4, but the conservative architecture assumes it), all rule-evaluation logic that decides "what should this device's shield state be, now and at each known upcoming transition" must be pre-computed by the main app whenever it syncs with the backend or its local state changes, and the *result* — the full Local Enforcement Plan (§16.3), not just a single current-state snapshot — written to the App Group store. Extensions never evaluate business rules themselves; they only read the precomputed plan and apply/clear tokens for the transition that has arrived.

## 16.3 The Local Enforcement Plan (replaces the "Resolved Shield List")

**CONFIRMED REQUIREMENT.** The main app maintains, per managed device, a **Local Enforcement Plan**: not merely a snapshot of what is shielded right now, but a self-sufficient local artifact that lets the `DeviceActivityMonitor` extension correctly execute every currently-knowable upcoming transition **without needing the main app open or the network reachable at the moment the transition arrives**.

At minimum, the Local Enforcement Plan contains:

- **Current resolved shield state** — the concrete set of `ApplicationToken`/`ActivityCategoryToken`/`WebDomainToken` values shielded right now.
- **`rule_config_version`** — identifies which snapshot of server-owned rule/grant/approval state (i.e. which `resolution_version`, per §16.7/`19_DATA_MODEL.md`) this plan was generated from.
- **`generated_at`** — when the main app computed this plan.
- **`effective_from`** — when the current resolved shield state became (or becomes) active.
- **Precomputed upcoming transitions** — for every transition the plan can currently foresee (a Scheduled Rule's window closing, a Deadline Lock's deadline or grace-period expiry, a Temporary Access Grant's expiry), a list entry giving: the transition's timestamp or schedule identity, and the **resulting shield operation or resulting shield snapshot** to apply at that moment — not merely the fact that something changes.
- **Local grant expiries** — the specific Temporary Access/Free Pass grants and their expiry timestamps feeding the above.
- **Grace-period expiries** — the specific Deadline-Lock-linked Provisional Approval Grace Period end times (DEC-40) feeding the above.
- **Timezone context** — the device-local timezone the plan's timestamps were computed against, so a subsequent timezone change is detectable (§16.8).
- **`source_resolution_version`** — the backend `resolution_version` (§16.7) this plan reflects, distinct from `rule_config_version` only if the two are tracked separately for schema clarity; functionally the same traceability purpose.

Generation logic (unchanged from the original design's intent, now producing a plan rather than a snapshot):

1. The main app evaluates every active Rule, Temporary Access/Free Pass grant, Focus/Active Engagement Session state, and School Mode/Essential Access exemption (BR-222) that currently applies to the device, **and** every such item's own known future transition points within the plan's look-ahead horizon (RECOMMENDATION: at least 24 hours ahead, to cover an overnight Scheduled Rule transition with no app open in between; to be confirmed against real-device `DeviceActivityMonitor` scheduling limits, §27.8 Priority 3).
2. It unions the restricted targets per BR-211's effective-enforcement logic (a target is shielded if at least one active rule names it and no active override/exemption removes it) — computed both for "now" and for each precomputed future transition point.
3. It subtracts Essential/Always Allowed targets and BR-222 safety-critical targets unconditionally at every point, regardless of what step 2 produced (this subtraction is the technical implementation of BR-222's hard safety principle, subject to the OQ-30/§27.3 UNKNOWN about whether Phone/emergency calling can even be included in a shield token set in the first place).
4. The full plan (current state plus every precomputed transition) is written to the App Group store and the current state's shield operation is applied immediately to `ManagedSettingsStore.shield`.
5. `DeviceActivityCenter` monitoring schedules are set for each transition timestamp in the plan, so the `DeviceActivityMonitor` extension is woken at each one and can **read that exact transition's precomputed resulting shield operation directly from the plan and apply it**, with no rule logic of its own — it only reads, validates the plan's `rule_config_version`/context still looks sane, applies the precomputed shield state, and persists that the transition was handled (so a duplicate wake does not reapply it redundantly).

**Deliberately kept out of the extension's responsibility:** running the business-rule engine, fetching fresh data from the network, or reasoning about anything not already precomputed in the plan. Foreground recomputation (§16.4) remains the defensive reconciliation mechanism for anything the plan's look-ahead horizon did not cover, or that changed after the plan was generated.

**OPEN QUESTION (unchanged in substance, restated for the Local Enforcement Plan): whether the extension, when woken for a transition, has network access to fetch a fresh resolution if the device has been offline since the plan was last generated (e.g. asleep for longer than the look-ahead horizon).** Current design assumes it does not (per §27.4) and instead always applies whatever the plan's last-known transition entries specify, correcting on next main-app foreground per §16.4 below. If the device is offline for longer than the plan's look-ahead horizon, no further precomputed transitions exist to apply, and the device's shield state simply holds at its last-applied state until the next foreground correction — this is the fail-safe behaviour intended by design (§17.2), not a gap.

## 16.4 Foreground correction pass

**CONFIRMED REQUIREMENT.** Every time the main app becomes active (foregrounded), it regenerates the Local Enforcement Plan from current local time and current locally-cached rule/grant state, and reapplies the current shield state immediately, regardless of whether a `DeviceActivityMonitor` callback was expected to have already executed a transition. This is the defensive fallback flagged in §27.4 against the UNKNOWN callback-timing-precision item: the app never assumes a background callback fired correctly.

This foreground pass is also when the app pulls fresh state from the backend if connectivity allows (see `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` for the full sync protocol); the plan is regenerated twice if both the pre-sync local recompute and the post-sync recompute produce different results, with the post-sync result winning.

## 16.5 Shield property limits and target prioritisation (corrected in this amendment round)

Per §27.3 (corrected this round), Apple's documentation confirms exact, independent per-property limits: up to 50 application tokens, separately up to 50 web-domain tokens, separately up to 50 category tokens (with up to 50 exceptions each) for app categories and again for web-domain categories. **These are VERIFIED FROM APPLE DOCUMENTATION figures, not an undocumented community-reported behaviour** — the original Phase 5 draft's framing of this as wholly undocumented was itself incorrect and has been withdrawn (§27.6). What remains unverified is only the *failure behaviour if a limit is exceeded* (NEEDS REAL-DEVICE TECHNICAL SPIKE, §27.8 Priority 4).

**RECOMMENDATION (pending spike confirmation of exceeded-limit behaviour):** the Local Enforcement Plan should prefer `ActivityCategoryToken` (whole categories, e.g. "Games") over individual `ApplicationToken`s wherever a rule's scope is expressed at category level, since one category token can cover many apps within the documented 50-category budget while leaving the separate 50-application budget for individually-named apps. Where a parent has named individual apps exceeding what fits within the documented 50-application limit, the app should surface this as a configuration warning ("You've selected more individual apps than this device can reliably restrict at once; consider using a category instead") rather than silently truncating the list and leaving some named apps unshielded without the parent's knowledge. **This UX behaviour is a Phase 6/7 design item, not resolved here — flagged as FUTURE FEATURE for that phase.**

## 16.6 Where enforcement authority sits: device vs backend — CONFIRMED, closes OQ-31

**CONFIRMED ARCHITECTURAL DIRECTION (founder-confirmed this amendment round, superseding the Phase 5 original's open question).**

- The **backend is authoritative for shared business state**: rules, approvals, requests, grants, membership, subscription. This was already true (§16.7, `29_API_AND_BACKEND_REQUIREMENTS.md`) and is unchanged.
- The **child device is authoritative for immediate device enforcement execution**. The child device generates and maintains its own Local Enforcement Plan (§16.3) from the latest valid business-state snapshot it has synced. The backend does not attempt to become a runtime shield engine — it has no way to apply a shield to a device it does not run on, and (per §27.4) no reliable way to push logic into the memory-constrained, network-isolated `DeviceActivityMonitor` extension in the first place.
- **On a relevant remote change** (an approval, a new/edited rule, a grant revocation, a role change): the backend commits the authoritative change, increments `resolution_version` (§16.7), and sends a wake/sync signal where supported (push notification). The child device then fetches/synchronises the new state, regenerates its Local Enforcement Plan, and applies the new shield state.
- **Push is a latency optimisation, never the sole correctness mechanism.** If push delivery fails, is delayed, or the device is offline, the mandatory foreground correction pass (§16.4) is what ultimately guarantees correctness — push only reduces how long a device might otherwise run on a stale plan before that foreground event happens.

This closes OQ-31 with the model above; the residual uncertainty is not *where* resolution runs (confirmed: on-device) but *how quickly and reliably* a remote change actually reaches and takes effect on the child device, which is precisely why §16.6a below elevates that question to a top-priority real-device spike rather than leaving it as an architectural open question.

## 16.6a Remote approval → child-device unlock propagation (new section, elevated to Priority 1 spike)

**Status: NEEDS REAL-DEVICE TECHNICAL SPIKE — see `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.3a/§27.8 Priority 1 for the full test matrix.**

**CONFIRMED REQUIREMENT (parent-facing UI, applies regardless of the spike's outcome):** until real-device measurement establishes reliable timing, the parent-facing UI must never claim or imply an instant, guaranteed unlock. It must distinguish two states that are not guaranteed to be simultaneous:
- **"Approved"** — the decision has been recorded on the backend (§16.7's atomic transaction has committed).
- **"Applied on [child]'s device"** — the child device has confirmed it received the new state and updated its shield accordingly.

Where these two moments could plausibly be far apart (child device backgrounded, force-terminated, offline, or on a poor connection — the exact scenarios the spike measures), the parent UI shows "Approved — waiting to apply on [child]'s device" rather than a single undifferentiated "Done" state. **This is now a confirmed requirement on copy and UI state modelling, not merely a caveat**, since promising instant effect the architecture cannot yet guarantee would be a reliability-positioning risk (consistent with DEC-08's existing "don't promise unverified behaviour" principle).

## 16.7 Atomic approval handling (BR-102)

**CONFIRMED REQUIREMENT.** An approval decision (Task approval, Request approval, override grant, or grant revocation per §16.9a) must be applied as a single atomic backend transaction that (a) records the decision, (b) updates the affected Rule/Grant's active state, and (c) increments a monotonic `resolution_version` counter for the affected device. The device's Local Enforcement Plan (§16.3) always carries the `source_resolution_version` it was generated from; if two approvals race (e.g. Owner and Guardian both act on the same request within the sync window), the backend's atomic increment guarantees only one "wins" as the latest state, and the device's next sync fetches the single current state rather than merging two partial updates. This directly answers the founder's end-of-phase requirement to identify backend actions that could race: **approval-vs-approval races on the same Task/Request are the primary identified race condition**, resolved by backend-side atomic compare-and-increment rather than client-side merge logic (see `29_API_AND_BACKEND_REQUIREMENTS.md` §29.4 for the API-level mechanism).

## 16.8 Device clock, timezone, and stale-device handling

- **CONFIRMED REQUIREMENT (extends DEC-36/BR-205):** all schedule evaluation (Scheduled Rules, Deadline Locks, grace period timers) uses the **device's own local clock and timezone**, consistent with DEC-36's confirmation that rules are evaluated device-locally rather than against a fixed household timezone. `DeviceActivitySchedule` is documented as calendar-based (§27.4), which is consistent with this model, though the exact behaviour when a device's timezone changes mid-schedule is NEEDS REAL-DEVICE TECHNICAL SPIKE (not documented).
- **Device staleness status model — CONFIRMED, thresholds left open (OQ-19 partially resolved, per founder instruction not to fix a number yet).** The parent-facing protection-status model has five confirmed states (already established in `34_OPEN_QUESTIONS.md` OQ-19/DEC-27's lineage): **Protected**, **Sync Pending**, **Device Offline**, **Needs Attention**, **Protection Unavailable**. A device is considered stale (moving out of "Protected") when the main app has not successfully synced with the backend within a threshold. **The founder has directed that this threshold not be fixed yet** — the 72-hour figure proposed in the original Phase 5 draft is withdrawn as a premature commitment, since the real answer depends on what heartbeat/background-sync behaviour iOS actually permits while the child does not open Themis, which is itself a real-device measurement, not an architectural judgement call. **CONFIRMED ARCHITECTURAL REQUIREMENT:** the threshold(s) driving these five status transitions must be **server-configurable**, not hard-coded into the client, so the actual value can be tuned post-spike (and potentially post-launch, based on real usage data) without an app release. A stale device continues enforcing its last-known Local Enforcement Plan (fail-safe: restrictions persist) regardless of which status is displayed.
- **Device clock tampering (child sets clock back to defeat a Deadline Lock):** **OPEN QUESTION (OQ-32, still open, added to the spike list at Priority 6 per §27.8):** no Apple documentation was found on whether `DeviceActivitySchedule`/`DeviceActivityMonitor` are resilient to manual device clock changes, or whether Apple's system-level scheduling uses a trusted time source immune to user clock changes. This is a plausible bypass vector. See also `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7's trusted-time model, which addresses the related-but-distinct fair-timing problem (a genuinely offline, non-tampering child) without waiting on this spike.

## 16.9 Device replacement and revoked permissions

- **CONFIRMED REQUIREMENT:** device replacement (child gets a new phone) is modelled as: (1) Guardian/Owner removes the old device (FR-007, triggers `revokeAuthorization`, per §27.2), (2) the old device's Local Enforcement Plan and monitoring schedules are cleared locally if still reachable, or simply abandoned if not (the entitlement revocation server-side is what actually matters for Family Sharing consistency, not local cleanup), (3) the new device goes through the same onboarding/authorization flow as any new device (FR-005/FR-006). **No data migrates automatically; rules are household/child-scoped, not device-scoped, so a newly added device for the same child inherits that child's current rules from the backend on first sync, with no separate "transfer" step required.**
- **CONFIRMED REQUIREMENT (from §27.2's external-revocation finding):** if `authorizationStatus` changes outside the app's control (child ages into an adult Apple Account, or a parent changes Screen Time status directly in system Settings), the main app must detect this on next foreground check and immediately reflect a "Protection Unavailable" state (§16.8) to all parent/guardian views for that device, rather than continuing to display a stale "Protected" status. This is the direct architectural resolution of the requirement (HLR-013/DEC-27) that protection status must reflect last-confirmed reality, not assumed continuity.

## 16.9a Early Temporary Access Grant (Free Pass) revocation — CONFIRMED this amendment round, closes OQ-35

**CONFIRMED REQUIREMENT.** An Owner or Guardian may revoke an active Temporary Access Grant (Free Pass) before its natural expiry. Behaviour:

1. The revocation is recorded via the same atomic approval-handling mechanism as any other approval-type action (§16.7): the grant moves to `Revoked` (see `20_STATE_MACHINES.md` §20.7), and the backend increments `resolution_version` for the affected device.
2. The revocation is pushed/synchronised to the child device using the same mechanism as any other remote change (§16.6/§16.6a).
3. The child device recomputes its Local Enforcement Plan; the rule(s) the grant had been overriding resume applying (per the effective-enforcement model, BR-211 — the grant's removal simply means it no longer subtracts from the restricted-target union).
4. **CONFIRMED UI REQUIREMENT (mirrors §16.6a's Approved/Applied distinction):** the parent UI must not claim "Access revoked on device" until the child device has acknowledged/applied the new resolution. It shows **"Revocation sent"** immediately on the Owner/Guardian's action, then **"Access revoked"** once the child device's applied state is confirmed.

This closes OQ-35.

## 16.10 Subscription state effects on enforcement

**Deferred to Phase 6, per founder instruction — not finalised here.** The founder confirms a governing safety principle that Phase 6's `25_SUBSCRIPTIONS_AND_BILLING.md` must design against: **Themis must never leave a child indefinitely locked because a subscription expired and the parent can no longer manage the rules.** Phase 6 must define active paid entitlement, App Store billing retry/grace state, expired entitlement, parent warnings, local expiry behaviour, and eventual clearing of Themis-managed restrictions consistent with this principle — no indefinite post-subscription enforcement. This document (`16_DEVICE_ENFORCEMENT.md`) does not fix a grace-window number or mechanism; `20_STATE_MACHINES.md` §20.10's Subscription state machine remains explicitly incomplete pending Phase 6, per OQ-33.

## 16.11 Summary of device-enforcement race conditions and disagreement points (feeds end-of-Phase-5 cross-check)

1. Two approvals racing on the same Task/Request/Grant-revocation — resolved via backend atomic `resolution_version` (§16.7).
2. Two parent/guardian devices editing rules concurrently — same mechanism as above; the backend, not any client, is authoritative.
3. Extension-applied shield vs main-app-generated Local Enforcement Plan disagreeing after a missed/delayed callback, or after the plan's look-ahead horizon is exceeded while offline — resolved via mandatory foreground correction pass (§16.4); until the next foreground event, the two can disagree, which is an accepted, bounded window rather than an eliminated one.
4. Device clock tampering defeating time-based rules — **not resolved, OQ-32, needs spike (Priority 6, §27.8).**
5. Stale/offline device continuing to enforce outdated rules — accepted by design (fail-safe: keeps last-known restriction rather than failing open) but surfaced to the parent via a server-configurable staleness indicator (§16.8).
6. Remote approval/revocation committed on the backend but not yet applied on the child device — **not a race to "resolve" but a latency window to measure and honestly surface** (§16.6a); Priority 1 real-device spike (§27.8) is required before any timing claim is made.
