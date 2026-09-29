# 31. Test Strategy

**Status:** Phase 7 draft
**Depends on:** `09_ACCEPTANCE_CRITERIA.md`, `26_ERROR_AND_EDGE_CASE_CATALOGUE.md`, `07_NON_FUNCTIONAL_REQUIREMENTS.md`, `24_SECURITY_REQUIREMENTS.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8

## 31.1 Purpose

This document defines how the confirmed requirements in this specification will be verified, organised by test category, and explicitly separates what can be tested in ordinary CI/simulator conditions from what genuinely requires the real-device spike programme. It does not write test cases line-by-line (that is an implementation-time activity); it defines the strategy and coverage obligations `32_TRACEABILITY_MATRIX.md` will check against.

## 31.2 Test categories

1. **Unit/component tests** — rule-conflict resolution logic, idempotency-key handling, atomic version-increment behaviour, Local Enforcement Plan generation logic (§16.3's 5-step process), trusted-time reconciliation logic (§17.7a). Runs in CI, no device dependency.
2. **Scenario/integration tests** — full approval flows including the two-approver race (EC-14), the scheduled-expiry-vs-manual-approval race (EC-15), offline-outbox replay/idempotency (EC-25), subscription state transitions (EC-28–EC-32) simulated against a mocked App Store notification feed. Runs in CI against a test backend.
3. **Concurrency tests** — NFR-009's "exactly one authoritative outcome in 100% of tested concurrent-request scenarios" is verified by deliberately racing concurrent requests against the same item and asserting a single winner, run at implementation time as an automated suite, not a one-off manual check.
4. **Real-device technical spikes** — the nine-item priority list in `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8 (entitlement approval; remote-unlock propagation; Phone/Messages/Maps shielding; scheduled-transition reliability; exceeded shield-limit behaviour; shield persistence; clock/timezone tampering; extension memory behaviour; cross-device reporting). **These are not ordinary QA test cases** — they are exploratory technical research whose findings feed back into the specification (as the Phase 5/6 amendment rounds have already done twice) before the corresponding NFR/EC/OQ can be marked measured/resolved.
5. **Accessibility audit** — against `07_NON_FUNCTIONAL_REQUIREMENTS.md` NFR-012's WCAG 2.2 AA-principles checklist (VoiceOver, Dynamic Type, touch targets, reduced motion, non-colour-only states, accessible child-facing language), using Apple's own accessibility testing tools per the founder's explicit direction.
6. **Security testing** — SEC-004 through SEC-017 each require a specific verification approach: rate-limit/abuse controls (SEC-004–SEC-011) via scripted abuse-simulation tests; encryption in transit/at rest (SEC-012/SEC-013) via configuration audit; authentication/session controls (SEC-014/SEC-015) via the pairing-flow scenario tests in §31.2 item 2 plus a penetration-test pass before launch; one-household-binding invariant (SEC-017, DEC-60) via device-re-pairing scenario tests (A–J listed below, covering normal transfer, concurrent attempts, interrupted transfer, recovery, offline scenarios); SEC-016 is explicitly **not testable** until the real-device spike (item 4) establishes what monotonic-clock behaviour can be trusted at all. **SEC-017 test cases (device re-pairing scenarios):** A. normal Household A → Household B transfer with explicit removal; B. attempted silent re-pairing is blocked; C. previous credential cannot access APIs after transfer; D. concurrent pairing attempts result in exactly one active binding; E. interrupted transfer is recoverable without leaving two active bindings; F. recovery requires authorised-adult verification; G. prior household receives removal/transfer state; H. prior household cannot continue showing verified Protected status after transfer is acknowledged; I. audit record exists for re-pairing/recovery action; J. second household receives a fresh credential, never the reused old credential.
7. **Privacy/data-minimisation verification** — confirms no Category B data (raw usage/bundle IDs/domains) reaches the backend at any layer, by code/schema audit (`19_DATA_MODEL.md` §19.1's confirmed absence of any "UsageEvent" entity) rather than by runtime testing alone, since the constraint is architectural.
8. **Recovery/deletion tests** — self-service and support-assisted account/household deletion (EC-33), including attempted deletion with insufficient identity verification and mid-deletion failure/retry, per `30_ADMIN_AND_SUPPORT.md` §30.5a.
9. **Manual/exploratory QA** — child-facing copy and tone review against the neutral, non-punitive, age-appropriate standard (§15) and the transparency requirement (DEC-53), which automated tests cannot verify for tone.

## 31.3 What cannot be tested before the real-device spike programme

**CONFIRMED, restates the founder's explicit instruction rather than a new decision.** The following are **not** to be resolved through documentation guesswork or simulator-only testing, per `35_DECISION_LOG.md`'s standing direction: OQ-19 (staleness thresholds), OQ-30 (Phone/Messages/Maps shielding), OQ-32 (device clock tampering), OQ-34 (trusted-time monotonic-clock-across-reboot reliability), OQ-40/SEC-016 (compromised-device monotonic-clock resilience). Test plans for these items are written to be **executed against real hardware** once the spike programme runs; a simulator-passing test for any of these five does not constitute resolution.

## 31.4 Acceptance-criteria coverage obligation

**CONFIRMED REQUIREMENT.** Every Given/When/Then acceptance criterion in `09_ACCEPTANCE_CRITERIA.md`, and every edge case in `26_ERROR_AND_EDGE_CASE_CATALOGUE.md` tagged CONFIRMED, must have at least one corresponding test case at implementation time. `32_TRACEABILITY_MATRIX.md` is the mechanism that checks this obligation is met and flags any gap in either direction (an AC with no test, or a test that doesn't trace back to any AC/FR).

## 31.5 Test environment and data

- **CONFIRMED REQUIREMENT.** Test data must never include a real child's data; synthetic households/members are used throughout, consistent with `23_PRIVACY_AND_CHILD_SAFETY.md`'s data-minimisation principle extending to test environments.
- Concurrency and idempotency tests require a backend environment capable of deliberately inducing races (e.g. delayed-commit test hooks) — a Phase 7/implementation infrastructure requirement, not specified further here.

## 31.6 Cross-check

Every NFR in `07_NON_FUNCTIONAL_REQUIREMENTS.md` is mapped to a test category above (NFR-001/002/004 → real-device spike; NFR-003/006/008/009/011 → scenario/integration or concurrency tests; NFR-005/007 → Phase 7 infrastructure sizing, tested once that infrastructure exists; NFR-010 → the spike programme's own process; NFR-012/013 → accessibility audit / manual QA). No NFR lacks a corresponding verification approach, though several remain explicitly gated on the real-device spike programme rather than testable today.
