# 23. Privacy and Child Safety

**Status:** Phase 6 draft
**Depends on:** `19_DATA_MODEL.md`, `22_REPORTING_AND_ANALYTICS.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` (BR-222)

## 23.1 Purpose

This document specifies what personal and child data Themis Family collects, why, how long it is kept, and the specific child-safety obligations that follow from building a product whose primary users include children under 13 and teens 13–15 (per DEC-12's confirmed age bands).

## 23.2 Data minimisation, restated as a design constraint (not merely a value statement)

**CONFIRMED REQUIREMENT**, directly enforced by Phase 5's technical findings, not just a privacy-policy aspiration:
- Themis Family **cannot** store bundle identifiers, visited domain names, or app display names extracted from Apple's shield tokens — this is a technical impossibility under the `.approved` authorization model (§27.3), not merely a self-imposed rule the product could later relax without an entitlement change.
- Themis Family **cannot** store or retain raw usage-time data (§27.5) — again a technical ceiling, not a policy choice.
- The only human-readable labels Themis stores for a `ControlledTarget` are the parent's own `custom_alias` entries (`19_DATA_MODEL.md`), never anything derived from the picker or the token itself.
- No precise child date of birth is collected (DEC-24); only the parent-selected `experience_segment` (Child/Teen) is stored.

## 23.3 Data collected, by category, and purpose

| Data | Purpose | Retention |
|---|---|---|
| Member profile (display name, role, experience_segment) | Household administration, age-appropriate UX | Retained while the household exists; anonymised or deleted on Member removal per §23.5 |
| Device authorization status | Protection-status accuracy (`16_DEVICE_ENFORCEMENT.md` §16.8) | Retained while the device is enrolled; deleted on device removal |
| Rule/Task/Request/Grant/Session records (Category A reporting data, `22_REPORTING_AND_ANALYTICS.md`) | Core product function, history/reporting | Retained while the household exists; subject to the retention policy in §23.5 for abandoned-session partial data specifically |
| Custom aliases for controlled targets | Parent usability | Retained while the target/rule exists |
| Audit logs (who approved/revoked/changed what) | Accountability, abuse protection (`29_API_AND_BACKEND_REQUIREMENTS.md` §29.8), dispute resolution | Retained for a defined period (RECOMMENDATION: 12 months rolling, not yet founder-confirmed) |

**No data collected beyond the above for V1.** Any future feature proposing a new data category must be checked against this table and, if it touches child data, against §23.4's child-safety principles before being added.

## 23.4 Child-safety principles

**CONFIRMED REQUIREMENT (BR-222, carried forward as the anchor principle of this entire document):** emergency calling and OS-level emergency functionality are never deliberately restricted by Themis Family, regardless of any rule, subscription state, or technical limitation elsewhere in the product. This is the single non-negotiable child-safety floor beneath every other requirement in this specification — no feature, optimisation, or cost-saving measure may compromise it.

- **No covert monitoring.** Every restriction, report, and monitoring capability Themis Family exercises must be visible to the child in age-appropriate terms (per the confirmed "agreement, not punishment" product philosophy, DEC-05-lineage) — this product does not offer a "stealth mode" and must not build one.
- **No behavioural profiling beyond what's needed for the confirmed feature set.** Category A data (§22.2) is used for the reporting surfaces already specified, not for building a child behavioural profile for any other purpose (e.g. no ad targeting, no data sale — restated here as an explicit prohibition, not merely absent from the current feature list).
- **Age-appropriate account model.** Children do not hold an independent Apple ID password Themis Family stores or has access to; authorization runs through the confirmed `.child` FamilyControlsMember model (§27.2), which is Apple's own age-appropriate mechanism, not a Themis-built credential system.
- **Parental consent model.** The Owner/Guardian, not the child, is the account holder and consents to Themis Family's data practices on the household's behalf, consistent with the confirmed roles model (`18_ROLES_AND_PERMISSIONS.md`). This document does not attempt to design a COPPA/UK-GDPR-children's-code compliance programme in full — that is a legal-review activity — but flags the specific mechanisms (data minimisation, no covert monitoring, no profiling, parental consent) that a legal review will need to assess against those frameworks.

## 23.5 Retention and deletion

- **Household deletion** (BR-101/DEC-45): cascades to delete all Member, Device, Rule, Task, Request, Grant, and Session records for that household, consistent with `20_STATE_MACHINES.md` §20.1's Household state machine.
- **Member removal** (soft-delete per `19_DATA_MODEL.md`): historical Task/Rule records remain attributable to a removed Member (for accountability and the audit trail) but the Member's own profile fields are not further processed once removed.
- **Abandoned EngagementSession partial data** (`19_DATA_MODEL.md`'s `EngagementSession.outcome = Abandoned`, per DEC-49): retained only as historical/debug information, not surfaced as a completed-session credit, and subject to the same household-level retention as other records — **RECOMMENDATION, not yet founder-confirmed:** this partial data should be purged after a defined shorter window (e.g. 90 days) than other Category A data, since it has no ongoing reporting value once abandoned. Flagged for founder confirmation rather than assumed.
- **Audit log retention window** (§23.3): RECOMMENDATION of 12 months rolling, not yet founder-confirmed.

## 23.6 End-of-Phase-6 cross-check items addressed here

- **Privacy data with no purpose:** none identified — every field in §23.3 traces to a specific confirmed feature. The one item flagged for shortening (abandoned-session partial data) is a retention-duration question, not a purpose question.
- **Support/admin capability exposure:** cross-referenced with `30_ADMIN_AND_SUPPORT.md` §30.4 to ensure support tooling does not expose more child data than necessary — see that document for the specific finding.
