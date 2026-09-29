# 37. Build Sequence

**Status:** Phase 7 draft
**Depends on:** `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8, `32_TRACEABILITY_MATRIX.md`, `36_MVP_VS_LATER_FEATURE_MATRIX.md`, `26_ERROR_AND_EDGE_CASE_CATALOGUE.md`

## 37.1 Purpose

This document sequences implementation work, with the founder's explicit, standing instruction as its single governing constraint: **the real-device technical spike programme must be placed before production enforcement implementation**, not run in parallel with or after it. This is a sequencing document, not a project-management estimate (no dates/durations are proposed — that is a founder/engineering-lead planning activity once a team and timeline exist).

## 37.2 Stage 0 — Entitlement and account setup (blocks everything else)

- Apply for and confirm the Family Controls entitlement (Priority 0 spike, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8). **CONFIRMED REQUIREMENT: no other stage begins meaningfully without this**, since the entire enforcement model depends on entitlement approval.
- Confirm Apple Developer Program / App Store Connect account setup, including Kids Category applicability review (OQ-12, still open).

## 37.3 Stage 1 — Real-device technical spike programme (before production enforcement code)

**CONFIRMED REQUIREMENT, restates the founder's explicit instruction.** Run the full priority list from `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8 against real hardware before writing production enforcement logic beyond what's needed to run the spikes themselves:

1. Priority 0 — entitlement approval (Stage 0, above).
2. Priority 1 — remote-approval → child-device unlock propagation timing (feeds the Approved/Applied-on-device UI requirement and NFR-002).
3. Priority 2 — Phone/Messages/Maps shielding behaviour (OQ-30, safety-critical, feeds BR-222's essential-access floor).
4. Priority 3 — `DeviceActivityMonitor` scheduled-transition reliability while the app is terminated/locked.
5. Priority 4 — exceeded shield-limit (50-item) failure behaviour.
6. Priority 5 — shield persistence across app termination/device reboot/app uninstall.
7. Priority 6 — device clock/timezone tampering resilience (OQ-32), including the monotonic-clock-across-reboot question feeding OQ-34 and the compromised-device resilience question feeding OQ-40/SEC-016.
8. Priority 7 — extension memory behaviour with realistic Local Enforcement Plan sizes.
9. Priority 8 — cross-device `DeviceActivityReport` rendering.

**Spike outputs feed back into the specification before build proceeds**, exactly as the Phase 5 and Phase 6 amendment rounds have already demonstrated twice with documentation-only corrections — a spike finding that contradicts an assumption in this specification is expected to trigger a further amendment round, not a silent implementation workaround.

## 37.4 Stage 2 — Core backend and data model

- `19_DATA_MODEL.md`'s entities, `29_API_AND_BACKEND_REQUIREMENTS.md`'s idempotency/atomic-approval/versioning primitives, and `24_SECURITY_REQUIREMENTS.md`'s SEC-001–SEC-015 controls (SEC-016 excluded — pending Stage 1 Priority 6 findings). This stage can begin in parallel with Stage 1's later-priority spikes (4–8) once Stage 1's Priority 0–3 results are in, since the backend's authoritative-business-state role (§29.1) does not itself depend on device-side enforcement specifics.

## 37.5 Stage 3 — Child-device enforcement (production code)

- Local Enforcement Plan generation and application, foreground correction pass, staleness detection — **gated on Stage 1 Priorities 0, 1, 3, 4, 5, 7** being resolved (or explicitly accepted as open risks with founder sign-off, per §37.7).
- Device pairing/credential flow (DEC-54) and the one-household-binding invariant (DEC-60 / SEC-017), including normal-transfer and recovery-path implementation for device re-pairing across households. This implementation must satisfy the confirmed product requirement (DEC-60) and pass the test scenarios listed in `31_TEST_STRATEGY.md` item 6 (test cases A–J). While the pairing scaffolding is independent of the spike programme, the production transfer/recovery path must include DEC-60/SEC-017 enforcement before this stage is considered complete.

## 37.6 Stage 4 — Parent/child experience, notifications, reporting

- `14_PARENT_EXPERIENCE.md`, `15_CHILD_AND_TEEN_EXPERIENCE.md`, `21_NOTIFICATIONS.md` — largely spike-independent, but the child transparency indicator (DEC-53) and protection-status display (§16.8) should not display specific numeric guarantees (e.g. exact sync timing) until Stage 1 findings are in, to avoid shipping copy that later contradicts measured reality.
- `22_REPORTING_AND_ANALYTICS.md`'s Category B display — **gated on Stage 1 Priority 8**.

## 37.7 Stage 5 — Subscriptions, admin/support tooling

- `25_SUBSCRIPTIONS_AND_BILLING.md`'s Apple Billing Grace Period configuration and reactivation flow, `30_ADMIN_AND_SUPPORT.md`'s scenario-scoped tooling — spike-independent, can proceed in parallel with Stages 1–4.

## 37.8 Stage 6 — Pre-launch readiness gates (non-engineering)

**CONFIRMED REQUIREMENT.** These do not block engineering work in Stages 0–5, but do block public launch, and must be tracked on their own timeline starting as early as possible rather than left until engineering is complete:
- Lawful Basis Matrix + DPIA + specialist legal review (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.4a).
- Safeguarding process approval (`30_ADMIN_AND_SUPPORT.md` §30.5, tracked in `38_DEFINITION_OF_DONE.md`).
- Kids Category / App Store review readiness (OQ-12, RISK-02).
- Accessibility audit (NFR-012).

## 37.9 Explicit sequencing rule

**CONFIRMED, the founder's binding instruction.** If, at any point, Stage 1 (real-device spikes) has not been run for a given capability, that capability's Stage 3/4 production implementation does not proceed on an assumption in its place — it either waits, or proceeds only with an explicit, founder-approved risk acceptance recorded in `35_DECISION_LOG.md`, never silently.

## 37.10 Cross-check

Every real-device spike priority (0–8) is placed in Stage 1, before the corresponding production implementation stage that depends on it (§37.3's mapping to Stages 3/4). No stage below Stage 1 proceeds past its gated dependency without either a resolved spike finding or a founder-approved recorded risk acceptance (§37.9). Non-engineering launch gates (Stage 6) are explicitly called out as running on their own track rather than being silently assumed to complete alongside engineering.
