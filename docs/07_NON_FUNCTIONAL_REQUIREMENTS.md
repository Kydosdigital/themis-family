# 07. Non-Functional Requirements

**Status:** Phase 6, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` DEC-52 through DEC-59)
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md`, `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`

**Amendment note (this round):** NFR-007 originally described household/device scale as "unbounded-in-principle," which the founder correctly identified as unnecessary framing — the actual requirement is that plan limits be server-configurable, not that they be limitless. NFR-012's accessibility target is also made more specific per the founder's detailed list. Both are corrected below.

This document specifies quality attributes (performance, reliability, availability, scalability, maintainability, observability) as measurable targets, using `NFR-###` identifiers. Per the founder's end-of-Phase-6 instruction, every NFR below either carries a measurable target or is explicitly flagged as **NOT YET MEASURABLE** with the reason and the real-device spike or Phase 7 activity that will make it measurable.

## 7.1 Enforcement latency and reliability

**NFR-001. Local shield application latency.** Once the child device's Local Enforcement Plan (`16_DEVICE_ENFORCEMENT.md` §16.3) has been generated with a transition due "now," the resulting shield state must be applied to `ManagedSettingsStore` within a target of **under 2 seconds** of the triggering event (app foreground, or `DeviceActivityMonitor` callback). **Status: NOT YET MEASURABLE** — depends on real-device `DeviceActivityMonitor` callback latency (`27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8 Priority 3); target to be confirmed or revised after that spike.

**NFR-002. Remote approval → child-device unlock propagation time.** Directly tied to the Priority 1 real-device spike (`27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.3a). **No target is fixed here** — the founder's own direction is that no timing claim (let alone "instant unlock") is made until this is measured. **Status: NOT YET MEASURABLE.** Once measured, this NFR should record: median and p95 propagation time for each of the eight scenario conditions in the spike's test matrix (foregrounded/backgrounded/terminated/locked child app; different networks; temporarily offline; delayed push; delayed reconnection).

**NFR-003. Offline enforcement continuity.** A device that loses connectivity must continue enforcing its last-known Local Enforcement Plan with **zero unintended relaxation of restrictions** for as long as the plan's precomputed transitions remain valid (per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.2's fail-safe principle). **Status: MEASURABLE, target confirmed** — this is a correctness property (restrictions never silently lapse while offline), verified by scenario testing rather than a numeric SLA.

**NFR-004. Foreground correction pass execution time.** The mandatory foreground correction pass (`16_DEVICE_ENFORCEMENT.md` §16.4) must complete (local recompute, before any network sync) within a target of **under 1 second** on a representative device, so it does not create a visible delay every time the app opens. **Status: RECOMMENDATION, not yet spike-validated.**

## 7.2 Availability

**NFR-005. Backend availability.** The backend API must target **99.9% monthly availability** for write endpoints affecting enforcement-relevant state (approvals, rule changes, grant actions), consistent with the product's reliability positioning (DEC-08). **Status: MEASURABLE target set; achievability depends on Phase 7 infrastructure choices, not addressed here.**

**NFR-006. Graceful degradation under backend outage.** During a backend outage, child devices must continue enforcing their last-synced Local Enforcement Plan (per NFR-003), and parent/guardian apps must clearly indicate "Can't reach Themis servers — showing last-known status" rather than a misleading live view. **Status: CONFIRMED REQUIREMENT, measurable via outage-simulation testing.**

## 7.3 Scalability

**NFR-007. Household/device scale — corrected this amendment round.** The original "unbounded-in-principle" framing is withdrawn as unnecessary and imprecise. **CONFIRMED REQUIREMENT:** household/member/device plan limits must be **server-configurable** and must not be hard-coded throughout the application (schema, API contracts, or client logic). This allows future commercial plans (e.g. up to N children, up to N managed devices, different family tiers) without a schema redesign, while not committing the architecture to literally unbounded scale. **The specific commercial limit itself is not chosen here** — that is a Phase 7/commercial decision — only the architectural requirement that whatever limit is chosen must be configurable, not baked into the code. **Status: CONFIRMED as an architectural constraint; specific capacity targets (requests/second, concurrent devices) remain a Phase 7 infrastructure-sizing exercise.**

## 7.4 Data integrity and consistency

**NFR-008. No duplicate enforcement-relevant records.** Given the idempotency requirements in `29_API_AND_BACKEND_REQUIREMENTS.md` §29.2, the system must guarantee **zero duplicate Task/Request/Grant/Session-outcome records** from offline-outbox replay under any tested crash/retry scenario. **Status: MEASURABLE, verified via the idempotency test suite (Phase 7 test strategy).**

**NFR-009. Approval race correctness.** Given the atomic compare-and-increment mechanism (`16_DEVICE_ENFORCEMENT.md` §16.7, `29_API_AND_BACKEND_REQUIREMENTS.md` §29.4), concurrent approval attempts on the same item must resolve to **exactly one** authoritative outcome in 100% of tested concurrent-request scenarios. **Status: MEASURABLE, verified via concurrency testing (Phase 7).**

## 7.5 Observability

**NFR-010. Spike-result traceability.** Every real-device technical spike result (`27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8) must record measured behaviour, OS version, device model, and test conditions, per the founder's explicit instruction — this is itself an NFR on the spike programme's own process, not the product, but is recorded here since it governs whether any other NFR in this document can later be confirmed as measured.

**NFR-011. Audit logging for enforcement-relevant actions.** Every approval, revocation, rule change, and role change must be attributable (who, when, what) in backend logs, supporting both the abuse-protection requirements of `29_API_AND_BACKEND_REQUIREMENTS.md` §29.8 and ordinary support/debugging needs (see `30_ADMIN_AND_SUPPORT.md`). **Status: CONFIRMED REQUIREMENT.**

## 7.6 Accessibility and localisation

**NFR-012. Accessibility — target updated this amendment round.** Parent- and child-facing UI must meet, at minimum, **WCAG 2.2 AA principles where applicable to native mobile UI** (updated from WCAG 2.1 AA per founder direction), specifically including: VoiceOver support; Dynamic Type support; adequate touch-target sizing; reduced-motion support where applicable; non-colour-only state indication (directly binding on the multi-state protection-status model in `16_DEVICE_ENFORCEMENT.md` §16.8, which must not rely on colour alone for its Protected/Offline/Needs Attention states); accessible, age-appropriate child-facing language (ties to `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4b's transparency requirement, which must itself be delivered in accessible language); and use of Apple's platform accessibility APIs and testing tools rather than a custom accessibility layer. **Status: CONFIRMED REQUIREMENT; specific audit is a Phase 7 activity (`design:accessibility-review`-equivalent pass against this target).**

**NFR-013. Localisation scope for V1.** UK English only for V1 (DEC-23); the data model and UI copy must not hard-code assumptions that would block later localisation (e.g. date/currency formatting is not hard-coded to a specific locale string where avoidable). **Status: CONFIRMED as an architectural constraint, not a V1 deliverable beyond UK English.**

## 7.7 Summary: NFRs without measurable targets (feeds end-of-Phase-6 cross-check)

- NFR-001 (local shield latency) — pending Priority 3 spike.
- NFR-002 (remote unlock propagation) — pending Priority 1 spike, deliberately unfixed per founder instruction.
- NFR-004 (foreground correction pass time) — RECOMMENDATION only, not spike-validated.
- NFR-005/NFR-007 (specific availability/capacity numbers) — depend on Phase 7 infrastructure decisions not yet made.

These are not gaps to be silently filled with invented numbers; they are correctly left open pending the real-device spike programme and Phase 7 infrastructure planning, consistent with the standing rule against turning assumptions into architecture.
