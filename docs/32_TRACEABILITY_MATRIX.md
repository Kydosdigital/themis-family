# 32. Traceability Matrix

**Status:** Phase 7 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md`, `06_FUNCTIONAL_REQUIREMENTS.md`, `08_EPICS_AND_USER_STORIES.md`, `09_ACCEPTANCE_CRITERIA.md`, `26_ERROR_AND_EDGE_CASE_CATALOGUE.md`, `31_TEST_STRATEGY.md`

## 32.1 Purpose

This document traces every High-Level Requirement (HLR) through its Functional Requirements (FR), owning specification document(s), acceptance-criteria coverage, and test-category assignment, and separately flags any orphan in either direction — an HLR/FR with no owning document or test category, or a specification section that doesn't trace back to any confirmed requirement. This satisfies the founder's explicit Phase 7 instruction to identify every acceptance criterion with no test and every test with no traced requirement.

## 32.2 HLR → FR → owning document(s) → test category

| HLR | FR(s) | Owning document(s) | AC coverage (`09_ACCEPTANCE_CRITERIA.md`) | Test category (`31_TEST_STRATEGY.md`) |
|---|---|---|---|---|
| HLR-001 Household/membership | FR-001–FR-005 | `06_FUNCTIONAL_REQUIREMENTS.md`, `18_ROLES_AND_PERMISSIONS.md`, `19_DATA_MODEL.md` | Covered | Scenario/integration |
| HLR-002 Role-based permissions | (cross-cutting) | `18_ROLES_AND_PERMISSIONS.md`, `24_SECURITY_REQUIREMENTS.md` SEC-003/SEC-007 | Covered | Security testing (§31.2.6) |
| HLR-003 Device authorisation | FR-006, FR-007 | `16_DEVICE_ENFORCEMENT.md`, `24_SECURITY_REQUIREMENTS.md` §24.5, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.2 | Covered; EC-01–EC-05 (`26_ERROR_AND_EDGE_CASE_CATALOGUE.md`) add pairing edge cases | Scenario/integration; real-device spike (Priority 0, entitlement) |
| HLR-004 Rule creation/targeting | FR-010–FR-012 | `10_RULE_ENGINE_SPECIFICATION.md`, `19_DATA_MODEL.md` | Covered | Unit/component; scenario/integration |
| HLR-005 Rule types | FR-013–FR-015 | `10_RULE_ENGINE_SPECIFICATION.md` | Covered | Unit/component |
| HLR-006 Verification Type | FR-016 | `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md` | Covered | Scenario/integration |
| HLR-007 Approval workflow | FR-030, FR-031 | `11_TASK_AND_APPROVAL_SPECIFICATION.md` | Covered; EC-13–EC-15 | Scenario/integration; concurrency |
| HLR-008 Non-response handling | FR-032 | `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `21_NOTIFICATIONS.md` | Covered; EC-16 | Scenario/integration |
| HLR-009 Requests/negotiation | FR-040–FR-045 | `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` | Covered; EC-21, EC-22 | Scenario/integration |
| HLR-010 Always Allowed/essential | FR-050, FR-053 | `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` | Covered; EC-07 | Scenario/integration; real-device spike (Priority 2, Phone/Messages/Maps, OQ-30) |
| HLR-011 School Mode | FR-051, FR-052, FR-054 | `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` | Covered; OQ-07 closed (no longer blocks) | Manual/exploratory QA (content), scenario/integration |
| HLR-012 Website control | (within FR-010–FR-018) | `10_RULE_ENGINE_SPECIFICATION.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.3 | Covered | Unit/component; real-device spike (Priority 4, exceeded-limit behaviour) |
| HLR-013 Protection status | (device status, not a numbered FR) | `16_DEVICE_ENFORCEMENT.md` §16.8, `14_PARENT_EXPERIENCE.md` §14.3 | Covered | Scenario/integration; real-device spike (staleness threshold, OQ-19) |
| HLR-014 Offline-first enforcement | FR-017 | `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `16_DEVICE_ENFORCEMENT.md` §16.3 | Covered; EC-09, EC-11, EC-23, EC-25–EC-27 | Unit/component; scenario/integration; real-device spike (Priority 3/5/7) |
| HLR-015 Reporting | (Category A/B model, not a numbered FR) | `22_REPORTING_AND_ANALYTICS.md` | Covered | Real-device spike (Priority 8, cross-device rendering); privacy verification |
| HLR-016 Privacy by design | (cross-cutting) | `23_PRIVACY_AND_CHILD_SAFETY.md` | Covered | Privacy/data-minimisation verification (§31.2.7) |
| HLR-017 Subscription management | (Subscription state machine, not a numbered FR) | `25_SUBSCRIPTIONS_AND_BILLING.md`, `20_STATE_MACHINES.md` §20.10 | Covered; EC-28–EC-32 | Scenario/integration |
| HLR-018 No overstated capability | BR-221 (capability honesty) | `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `22_REPORTING_AND_ANALYTICS.md` §22.4 | Covered | Manual/exploratory QA |
| HLR-019 Age-segmented experience | FR-002, FR-003 | `19_DATA_MODEL.md`, `15_CHILD_AND_TEEN_EXPERIENCE.md` §15.4 | Covered | Manual/exploratory QA |
| HLR-020 Onboarding two-stage model | FR-008 | `14_PARENT_EXPERIENCE.md` §14.2 | Covered | Scenario/integration |
| HLR-021 Launch region (UK) | (policy, not a numbered FR) | `02_SCOPE_AND_RELEASE_STRATEGY.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.5a | Covered | Manual/exploratory QA (copy/marketing review) |
| HLR-022 Age-segment selection | FR-002 | `19_DATA_MODEL.md` | Covered | Scenario/integration |
| HLR-023 Shared-device exclusion | (documentation constraint) | `03_PERSONAS.md`, FR-054 | Covered | Manual/exploratory QA |
| HLR-024 No unverified platform claims | (cross-cutting, drives the VERIFIED/NEEDS SPIKE/UNSUPPORTED/UNKNOWN tagging discipline) | `27_APPLE_INTEGRATION_REQUIREMENTS.md` | Covered | Real-device spike programme in full (§27.8) |

## 32.3 Confirmed decisions (DEC-##) with no direct FR — traced via owning document instead

Several confirmed decisions govern cross-cutting behaviour rather than a single FR (e.g. DEC-40's Provisional Approval Grace Period, DEC-53's child-transparency requirement, DEC-55's Billing Grace Period). These are traced above via their owning document/section rather than a dedicated FR row, consistent with how `06_FUNCTIONAL_REQUIREMENTS.md` itself scopes FR numbers to discrete user-facing actions rather than every confirmed business rule.

## 32.4 Acceptance criteria with no test — check result

**None identified.** Every AC in `09_ACCEPTANCE_CRITERIA.md` maps to at least one test category in §32.2 above (the "Covered" column plus the referenced test category). The one AC-level dependency flagged as genuinely open in the Phase 4 review (US-CHILD-014 AC3, on OQ-30) is explicitly carried through to the real-device spike test category, not silently dropped.

## 32.5 Tests/spikes with no traced requirement — check result

**None identified.** Every real-device spike in `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8's priority list maps to a specific OQ, which in turn maps to a specific HLR/FR row above (Priority 0 → HLR-003; Priority 1 → the Approved/Applied-on-device requirement under HLR-007/HLR-009; Priority 2 → HLR-010/OQ-30; Priority 3 → HLR-014; Priority 4 → HLR-012; Priority 5 → HLR-014; Priority 6 → OQ-32, feeds HLR-005's Deadline Lock integrity; Priority 7 → HLR-014; Priority 8 → HLR-015). No spike exists that isn't traceable to a specific product requirement.

## 32.6 MVP dependency flags feeding `36_MVP_VS_LATER_FEATURE_MATRIX.md`

Every row above tagged with a real-device spike dependency (HLR-003, HLR-005 via OQ-32, HLR-010, HLR-012, HLR-013, HLR-014, HLR-015, HLR-024) represents an MVP feature whose readiness is gated on that spike's outcome, not on documentation completeness alone — carried forward explicitly into `36_MVP_VS_LATER_FEATURE_MATRIX.md` and the GO/NO-GO report (§38).

## 32.7 Cross-check summary

- Every HLR (HLR-001 through HLR-024) has at least one owning document and test category. **No orphan HLR.**
- Every numbered FR (FR-001 through FR-054) is accounted for under its HLR row. **No orphan FR.**
- Every AC has a test category. **No untested AC.**
- Every spike/test traces to a requirement. **No untraceable test.**
- Eight of twenty-four HLRs carry a live real-device-spike dependency, meaning **the requirements documentation being complete does not by itself mean those eight areas are build-ready** — this is carried forward explicitly into the Phase 7 GO/NO-GO report rather than glossed over.
