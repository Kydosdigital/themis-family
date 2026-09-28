# 16. Device Enforcement

**Status:** Phase 5 draft
**Depends on:** `27_APPLE_INTEGRATION_REQUIREMENTS.md` (all capability statuses below are as classified there), `10_RULE_ENGINE_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`

## 16.1 Purpose

This document defines how the effective-enforcement model (DEC-32) and the various rule/grant/session types confirmed in Phases 3 and 4 are actually applied to a device's shield state, given the real constraints on Apple's frameworks established in §27. It is the bridge between "what the rules say should happen" (Phase 3) and "what code actually runs on the device" (Phase 6/7).

## 16.2 Enforcement components and their roles

| Component | Responsibility | Runs where |
|---|---|---|
| Main app | Rule authoring, sync with backend, `FamilyActivityPicker` selection, requesting authorization | Foreground/background app process |
| `DeviceActivityMonitor` extension | Receives scheduled interval start/end and threshold callbacks; applies/removes shield | Apple-managed extension process (memory-constrained, per §27.4) |
| `ShieldConfiguration` extension | Supplies the shield's displayed appearance (message, buttons) when the OS presents it | Apple-managed extension process |
| `ShieldAction` extension | Handles the child tapping a shield button (e.g. "Request more time") | Apple-managed extension process |
| App Group shared store | Local cache of "what should currently be shielded," written by the main app on sync, read by all extensions | Shared container, on-device only |
| Backend | Authoritative rule/grant definitions, approval state, cross-device consistency | Server |

**CONFIRMED REQUIREMENT (derived from §27.4):** because extensions run under severe memory constraints and cannot reliably reach the network (NEEDS REAL-DEVICE SPIKE per §27.3/27.4, but the conservative architecture assumes it), all rule evaluation logic that decides "is this target currently restricted" must be pre-computed by the main app whenever it syncs with the backend, and the *result* (a simple resolved shield list, per §16.3) written to the App Group store. Extensions never evaluate business rules themselves; they only read the pre-computed resolution and apply/clear tokens.

## 16.3 The Resolved Shield List

**CONFIRMED REQUIREMENT.** The main app maintains, per managed device, a **Resolved Shield List**: the concrete, already-evaluated set of `ApplicationToken`/`ActivityCategoryToken`/`WebDomainToken` values that should be shielded *right now*, plus the next known transition timestamp (when the list should be recomputed even with no network activity, e.g. a Scheduled Rule's end time or a grant's expiry).

This list is the single artifact that bridges the effective-enforcement model (BR-211: "a target remains restricted while ANY active rule still covers it") into something a memory-constrained extension can apply without reasoning about rules at all:

1. The main app (or, per §16.6, a backend-computed equivalent) evaluates every active Rule, Temporary Access/Free Pass grant, Focus/Active Engagement Session state, and School Mode/Essential Access exemption (BR-222) that currently applies to the device.
2. It unions the restricted targets per BR-211's effective-enforcement logic (a target is shielded if at least one active rule names it and no active override/exemption removes it).
3. It subtracts Essential/Always Allowed targets and BR-222 safety-critical targets unconditionally, regardless of what step 2 produced (this subtraction is the technical implementation of BR-222's hard safety principle, subject to the OQ-30/§27.3 UNKNOWN about whether Phone/emergency calling can even be included in a shield token set in the first place).
4. The result, plus the timestamp of the next required recomputation, is written to the App Group store and to `ManagedSettingsStore.shield`.
5. `DeviceActivityCenter` monitoring schedules are set for exactly that next transition timestamp, so the `DeviceActivityMonitor` extension is woken to reapply/clear the shield with no rule logic of its own — it only ever writes what the main app last resolved for that timestamp.

**OPEN QUESTION (new, raised in Phase 5, carried into §16.8):** whether the extension, when woken for a transition, has network access to fetch a *fresh* resolution if the device has been offline since the main app last computed one (e.g. asleep overnight, missing a Scheduled Rule's start). Current design assumes it does not (per §27.4) and instead always applies the last-synced Resolved Shield List, correcting on next main-app foreground per §16.4 below.

## 16.4 Foreground correction pass

**CONFIRMED REQUIREMENT.** Every time the main app becomes active (foregrounded), it recomputes the Resolved Shield List from current local time and current locally-cached rule/grant state, and reapplies it immediately, regardless of whether a `DeviceActivityMonitor` callback was expected to have already done so. This is the defensive fallback flagged in §27.4 against the UNKNOWN callback-timing-precision item: the app never assumes a background callback fired correctly.

This foreground pass is also when the app pulls fresh state from the backend if connectivity allows (see `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` for the full sync protocol); the shield is reapplied twice if both the pre-sync local recompute and the post-sync recompute produce different results, with the post-sync result winning.

## 16.5 The 50-token constraint and target prioritisation

Per §27.3, the ~50-token-per-property shield limit is unverified as an Apple-documented fact but is treated as a real engineering constraint until a real-device spike proves otherwise (this is itself the corrected framing from the §27.6 correction to `10_RULE_ENGINE_SPECIFICATION.md` FR-010).

**RECOMMENDATION (pending spike confirmation):** the Resolved Shield List should prefer `ActivityCategoryToken` (whole categories, e.g. "Games") over individual `ApplicationToken`s wherever a rule's scope is expressed at category level, since one category token can cover many apps within one of the ~50 available slots. Where a parent has named individual apps exceeding what fits in the remaining budget, the app should surface this as a configuration warning ("You've selected more individual apps than this device can reliably restrict at once; consider using a category instead") rather than silently truncating the list and leaving some named apps unshielded without the parent's knowledge. **This UX behaviour is a Phase 6/7 design item, not resolved here — flagged as FUTURE FEATURE for that phase.**

## 16.6 Where resolution actually runs: device vs backend

**OPEN QUESTION (new, OQ-31):** should Resolved Shield List computation run exclusively on-device (as described in §16.3), or should the backend also compute and push a resolution (e.g. via silent push notification) whenever a relevant change happens server-side (an approval, a new rule, a Guardian's edit from another device)? Arguments for backend-side computation: guarantees consistency across multiple parent/guardian devices editing rules simultaneously (see BR-102 atomicity, §16.7); avoids relying on the child's device being foregrounded to pick up a change. Arguments against: adds a dependency on push delivery reliability for something safety/restriction-relevant, and the DeviceActivityMonitor extension cannot reach the network to fetch a backend-pushed value anyway (§27.4), so a push would still only take effect the next time the main app is foregrounded on the child's device — meaning backend-side computation does not actually close the latency gap the on-device foreground-correction pass (§16.4) doesn't already close. **This document adopts on-device resolution as the primary mechanism (§16.3) with backend-triggered push-to-wake-app as a RECOMMENDATION to reduce (not eliminate) the latency window, not a substitute for it.** This should be confirmed or revised once real-device push/extension behaviour is spiked.

## 16.7 Atomic approval handling (BR-102)

**CONFIRMED REQUIREMENT.** An approval decision (Task approval, Request approval, override grant) must be applied as a single atomic backend transaction that (a) records the decision, (b) updates the affected Rule/Grant's active state, and (c) increments a monotonic `resolution_version` counter for the affected device. The device's Resolved Shield List computation (§16.3) always carries the `resolution_version` it was computed from; if two approvals race (e.g. Owner and Guardian both act on the same request within the sync window), the backend's atomic increment guarantees only one "wins" as the latest state, and the device's next sync fetches the single current state rather than merging two partial updates. This directly answers the founder's end-of-phase requirement to identify backend actions that could race: **approval-vs-approval races on the same Task/Request are the primary identified race condition**, resolved by backend-side atomic compare-and-increment rather than client-side merge logic (see `29_API_AND_BACKEND_REQUIREMENTS.md` §29.4 for the API-level mechanism).

## 16.8 Device clock, timezone, and stale-device handling

- **CONFIRMED REQUIREMENT (extends DEC-36/BR-205):** all schedule evaluation (Scheduled Rules, Deadline Locks, grace period timers) uses the **device's own local clock and timezone**, consistent with DEC-36's confirmation that rules are evaluated device-locally rather than against a fixed household timezone. `DeviceActivitySchedule` is documented as calendar-based (§27.4), which is consistent with this model, though the exact behaviour when a device's timezone changes mid-schedule is NEEDS REAL-DEVICE TECHNICAL SPIKE (not documented).
- **CONFIRMED REQUIREMENT:** a device is considered **stale** if the main app has not successfully synced with the backend within a defined threshold (RECOMMENDATION: 72 hours, to be confirmed with the founder before Phase 6 build). A stale device continues enforcing its last-known Resolved Shield List (fail-safe: restrictions persist) but the parent-facing dashboard must clearly flag the device as "Last synced X ago" rather than implying live status. **This is a new CONFIRMED REQUIREMENT arising from Phase 5 architecture work, not previously specified**, and should be logged as a new Decision Log entry pending founder confirmation of the exact threshold.
- **Device clock tampering (child sets clock back to defeat a Deadline Lock):** **OPEN QUESTION (new, OQ-32):** no Apple documentation was found on whether `DeviceActivitySchedule`/`DeviceActivityMonitor` are resilient to manual device clock changes, or whether Apple's system-level scheduling uses a trusted time source immune to user clock changes. This is a plausible bypass vector and must be included in the real-device spike list.

## 16.9 Device replacement and revoked permissions

- **CONFIRMED REQUIREMENT:** device replacement (child gets a new phone) is modelled as: (1) Guardian/Owner removes the old device (FR-007, triggers `revokeAuthorization`, per §27.2), (2) the old device's Resolved Shield List and monitoring schedules are cleared locally if still reachable, or simply abandoned if not (the entitlement revocation server-side is what actually matters for Family Sharing consistency, not local cleanup), (3) the new device goes through the same onboarding/authorization flow as any new device (FR-005/FR-006). **No data migrates automatically; rules are household/child-scoped, not device-scoped, so a newly added device for the same child inherits that child's current rules from the backend on first sync, with no separate "transfer" step required.**
- **CONFIRMED REQUIREMENT (from §27.2's external-revocation finding):** if `authorizationStatus` changes outside the app's control (child ages into an adult Apple Account, or a parent changes Screen Time status directly in system Settings), the main app must detect this on next foreground check and immediately reflect a "Protection status: Not Active" state to all parent/guardian views for that device, rather than continuing to display a stale "Protected" status. This is the direct architectural resolution of the requirement (HLR-013/DEC-27) that protection status must reflect last-confirmed reality, not assumed continuity.

## 16.10 Subscription state effects on enforcement

**CONFIRMED REQUIREMENT (cross-references `35_DECISION_LOG.md` and Phase 6's subscription document, not yet written):** if a household's subscription lapses, enforcement does not silently continue nor silently stop; **RECOMMENDATION** pending Phase 6 confirmation: existing shields remain in force for a defined grace window (aligning with the general product principle of fail-safe restriction rather than fail-open) after which enforcement is suspended and the parent dashboard clearly states protection is inactive due to billing. The exact grace window and whether any enforcement continues at all is explicitly deferred to Phase 6 (`24_SUBSCRIPTION_AND_BILLING.md`, not yet written) and is not decided here — flagged as **OPEN QUESTION (new, OQ-33)** rather than invented.

## 16.11 Summary of device-enforcement race conditions and disagreement points (feeds end-of-Phase-5 cross-check)

1. Two approvals racing on the same Task/Request — resolved via backend atomic `resolution_version` (§16.7).
2. Two parent/guardian devices editing rules concurrently — same mechanism as above; the backend, not any client, is authoritative.
3. Extension-applied shield vs main-app-resolved shield disagreeing after a missed/delayed callback — resolved via mandatory foreground correction pass (§16.4); until the next foreground event, the two can disagree, which is an accepted, bounded window rather than an eliminated one.
4. Device clock tampering defeating time-based rules — **not resolved, OQ-32, needs spike.**
5. Stale/offline device continuing to enforce outdated rules — accepted by design (fail-safe: keeps last-known restriction rather than failing open) but surfaced to the parent via staleness indicator (§16.8).
