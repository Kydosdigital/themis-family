# 36. MVP vs. Later Feature Matrix

**Status:** Phase 7 draft
**Depends on:** `02_SCOPE_AND_RELEASE_STRATEGY.md`, `32_TRACEABILITY_MATRIX.md` §32.6, `34_OPEN_QUESTIONS.md`

## 36.1 Purpose

This matrix separates confirmed V1/MVP scope from explicitly deferred FUTURE FEATUREs, and — per the founder's explicit Phase 7 instruction — flags every MVP feature that depends on an unverified Apple capability, so "MVP" is not read as "ready to build" where a real-device spike still stands between the requirement and a build decision.

## 36.2 Confirmed V1/MVP scope

| Feature area | V1 scope | Spike-dependent? |
|---|---|---|
| Household/membership (Owner, one Guardian, Children/Teens) | Full | No |
| Device authorisation and pairing | Full | **Yes — Priority 0 (entitlement approval)** |
| Rule engine (Scheduled Rule, Deadline Lock, Earn First) | Full, effective-enforcement conflict model | Partial — Priority 4 (exceeded shield-limit behaviour) |
| Verification Type (Parent Approval, Automatic Verification) | Full | No (Automatic Verification's session-type split is confirmed; underlying enforcement reliability ties to Priority 3) |
| Requests, clarification, Free Passes | Full | No |
| Always Allowed / essential access (Phone/Messages/Maps) | Full, as a hard safety principle | **Yes — Priority 2 (Phone/Messages/Maps shielding, OQ-30 genuinely UNKNOWN)** |
| School Mode | Full, platform-agnostic (OQ-07 closed) | No |
| Protection status (five-state model) | Full | **Yes — staleness threshold, OQ-19, pending heartbeat measurement** |
| Offline-first enforcement, Local Enforcement Plan | Full | **Yes — Priority 3/5/7 (scheduled-transition reliability, shield persistence, extension memory)** |
| Remote approval → device unlock propagation | Full, with "Approved"/"Applied on device" UI distinction | **Yes — Priority 1, no timing claim made until measured** |
| Reporting (Category A Themis-owned; Category B via Apple's own on-device view) | Full for Category A; Category B limited to what Apple's `.approved` model exposes | **Yes — Priority 8 (cross-device `DeviceActivityReport` rendering)** |
| Trusted-time model for offline submissions | Full | **Yes — monotonic-clock-across-reboot reliability (OQ-34); tampering resilience separately open (OQ-32/OQ-40)** |
| Subscription/billing (Apple Billing Grace Period model) | Full | No — this is an App Store configuration and Themis state-machine concern, not an Apple Family Controls capability |
| Privacy/child-safety (data minimisation, transparency indicator, retention) | Full | No (a legal/DPIA dependency, not a technical spike — see §36.4) |
| Security controls (SEC-001–SEC-015) | Full | No |
| Admin/support (scenario-scoped tooling, narrowed powers) | Full | No |

## 36.3 Explicitly deferred — FUTURE FEATURE / out of V1

| Feature | Status | Reference |
|---|---|---|
| Household Mode (adult self-rules) | Deferred, zero V1 UI | DEC-13 |
| Second Guardian beyond one | Deferred | `18_ROLES_AND_PERMISSIONS.md` |
| Teen elevated permissions | FUTURE-leaning, non-blocking | OQ-21 |
| App and Website Usage / `approvedWithDataAccess` reporting | Deferred, EU-market-only, not usable in UK V1 | OQ-10, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.5a |
| Split-custody / separated-parent multi-household support | Explicit V1 limitation, not a bug | DEC-45 |
| Shared-device scenarios (one device, multiple children) | Explicitly out of V1 | HLR-023, OQ-17 |
| Courtesy entitlements / promotional access / internal credits | Deferred as a separate product concept requiring its own security/audit requirements | `30_ADMIN_AND_SUPPORT.md` §30.3b |
| Partial/reduced-enforcement subscription tier | Explicitly rejected for V1, not merely deferred | DEC-56 |
| AI/NFC/QR/location/photo task verification | Excluded from V1 | OQ-06 resolution |
| Detailed safeguarding policy content (beyond the confirmed launch-readiness requirement that a process exist) | Operational/legal task outside this specification's authorship, but **not** deferrable past launch itself | OQ-41, `38_DEFINITION_OF_DONE.md` |
| Android release | Deferred, iOS-only V1 | RISK-14 |

## 36.4 MVP features gated on a non-technical (legal/policy) dependency

**CONFIRMED, distinct from the technical spike dependencies above.** Two MVP-scope items are gated on non-technical readiness work rather than a real-device spike, and must not be conflated with the spike list:
- **Lawful Basis Matrix and DPIA/legal review** (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.4a, DEC-52) — required before launch, owned by founder + external legal counsel, not resolved by engineering work.
- **Safeguarding process approval** (`30_ADMIN_AND_SUPPORT.md` §30.5, OQ-41) — required before public launch, owned by founder + safeguarding/legal expertise, not resolved by engineering work.

## 36.5 Cross-check

Every MVP row in §36.2 tagged spike-dependent traces to a specific Priority item in `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8 or a specific OQ, consistent with `32_TRACEABILITY_MATRIX.md` §32.6. No FUTURE FEATURE in §36.3 is silently included in V1 scope elsewhere in this specification — each was independently confirmed as deferred in its originating phase (cited above) and this document does not reverse any of those decisions. §36.4's two legal/policy gates are the direct input to the GO/NO-GO report's privacy-readiness and safeguarding-readiness assessments (`38_DEFINITION_OF_DONE.md`).
