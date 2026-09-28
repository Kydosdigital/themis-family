# 23. Privacy and Child Safety

**Status:** Phase 6, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` DEC-52 through DEC-59)
**Depends on:** `19_DATA_MODEL.md`, `22_REPORTING_AND_ANALYTICS.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` (BR-222)

**Amendment note (this round):** the founder's review identified two material gaps in the original Phase 6 draft: (1) the document overstated parental consent as the automatic lawful basis for all processing of the child's personal data, which this specification is not positioned to determine and which UK data-protection law does not treat as a given for a service offered directly to a child; and (2) "no covert monitoring" as a stated principle, without a corresponding product requirement that the child experience actively communicates that controls are active, was insufficient. Both are corrected below (§23.4a and §23.4b). Retention periods in §23.5 are also replaced with specific figures per the founder's direction, superseding the earlier open-ended "while the household exists" framing for routine behavioural history.

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
| Push notification payloads | Latency optimisation for user notifications | Minimal content only; sensitive data excluded per `21_NOTIFICATIONS.md` §21.4; not retained after delivery |

**No data collected beyond the above for V1.** Any future feature proposing a new data category must be checked against this table and, if it touches child data, against §23.4's child-safety principles before being added.

## 23.4 Child-safety principles

**CONFIRMED REQUIREMENT (BR-222, carried forward as the anchor principle of this entire document):** emergency calling and OS-level emergency functionality are never deliberately restricted by Themis Family, regardless of any rule, subscription state, or technical limitation elsewhere in the product. This is the single non-negotiable child-safety floor beneath every other requirement in this specification — no feature, optimisation, or cost-saving measure may compromise it.

- **No covert monitoring.** Every restriction, report, and monitoring capability Themis Family exercises must be visible to the child in age-appropriate terms (per the confirmed "agreement, not punishment" product philosophy, DEC-05-lineage) — this product does not offer a "stealth mode" and must not build one.
- **No behavioural profiling beyond what's needed for the confirmed feature set.** Category A data (§22.2) is used for the reporting surfaces already specified, not for building a child behavioural profile for any other purpose (e.g. no ad targeting, no data sale — restated here as an explicit prohibition, not merely absent from the current feature list).
- **Age-appropriate account model.** Children do not hold an independent Apple ID password Themis Family stores or has access to; authorization runs through the confirmed `.child` FamilyControlsMember model (§27.2), which is Apple's own age-appropriate mechanism, not a Themis-built credential system.
- **Account holder model (distinct from lawful basis — see §23.4a).** The Owner/Guardian, not the child, is the account holder and administers Themis Family on the household's behalf, consistent with the confirmed roles model (`18_ROLES_AND_PERMISSIONS.md`). **This is an account-administration fact, not a legal conclusion.** The original draft of this document stated or implied that the Owner/Guardian's consent is automatically the lawful basis for all processing of the child's personal data — **this is withdrawn, per the founder's explicit correction.** A parent being the account holder does not, by itself, establish the lawful basis under UK GDPR/Data Protection Act 2018 for processing a child's personal data, and this specification does not make that legal determination. See §23.4a.

## 23.4a Lawful basis — not assumed, subject to legal/DPIA review before launch

**CONFIRMED REQUIREMENT, replaces the withdrawn blanket-consent assumption.** Themis Family must identify and document an appropriate lawful basis for each processing purpose as part of a Data Protection Impact Assessment (DPIA) and specialist legal/privacy review **before launch**. Potential lawful bases (e.g. consent, contract necessity, legitimate interests) must not be silently assumed anywhere in this product specification, and this document does not purport to reach that legal conclusion itself.

Where consent is relied upon for an information society service offered directly to a child (which Themis Family, as a child-facing app, plausibly is for at least some processing), UK requirements around the child's age, parental authorisation, and age/consent verification must be specifically assessed — this is a distinct legal question from "the parent is the account holder," and this specification flags it rather than resolves it.

**Required privacy/legal readiness artefact — the Lawful Basis Matrix.** Before launch, a matrix must exist covering, at minimum, each of the following processing purposes: Member profile; Device status; Rules; Tasks; Requests; Temporary grants; Session records; Audit logs; Support access; Product analytics; Push notifications. For each processing purpose, the matrix records: the data involved; the purpose; the proposed lawful basis; necessity (why this processing is required for that purpose); retention (cross-referenced to §23.5); recipient/access (who/what can access this data — cross-referenced to `30_ADMIN_AND_SUPPORT.md` §30.3); child-specific impact; and legal-review status (not started / in review / signed off). **A proposed lawful basis recorded in this matrix is a working position for legal review, not a final legal conclusion**, until that review has signed it off. Producing and populating this matrix is a launch-readiness dependency, tracked in `38_DEFINITION_OF_DONE.md` (Phase 7).

## 23.4b Child transparency is a product requirement, not just a principle

**CONFIRMED REQUIREMENT, new this amendment round.** "No covert monitoring" (§23.4) is necessary but not sufficient on its own — it must be backed by an active, visible product requirement, not left as a principle the UI happens to satisfy incidentally.

- The child/teen experience must contain an accessible, persistent-enough-to-notice indicator — e.g. **"Themis is active"** or an equivalent protection/parental-control indicator — communicating that Themis Family controls are in effect on this device.
- Where parental monitoring/reporting is in use, the child must receive age-appropriate information about it, not merely a technical capability that happens not to be labelled "covert."
- At minimum, the child-facing experience must let the child understand, in age-appropriate language: that parental controls are active; what types of things Themis controls (broad categories, e.g. "apps and websites, on a schedule your parent set"); what information parents can see (Category A reporting data, per `22_REPORTING_AND_ANALYTICS.md`); what parents cannot see (Category B/raw usage detail — Themis structurally cannot access this either, per §23.2); why a specific app/site is currently restricted; and how to ask for an exception (the existing Request flow, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`).
- **Boundary, not contradiction:** this requirement does not extend to exposing implementation or security detail that would materially aid circumvention (e.g. exact enforcement-plan internals, exact staleness thresholds, or clock-tampering detection logic) — transparency about *that controls exist and broadly what they do* is required; a circumvention manual is not.
- This requirement feeds Phase 7's child/teen experience and UX-copy work directly (`15_CHILD_AND_TEEN_EXPERIENCE.md`) and its error/edge-case and test coverage (`26_ERROR_AND_EDGE_CASE_CATALOGUE.md`, `31_TEST_STRATEGY.md`).

## 23.5 Retention and deletion

**CONFIRMED REQUIREMENT, this amendment round — replaces the earlier open-ended "retained while the household exists" framing for routine behavioural history.** "Retained while the household exists" is too broad a default for ongoing child behavioural data; retention is now bounded per category below. All periods remain subject to final DPIA/legal review before launch (§23.4a) and may be tightened, but not loosened, by that review.

- **Active Member profile:** retained while membership is active and necessary for the household to function; not a fixed duration, since the profile is live operational data, not historical.
- **Structured Rule/Task/Request/Grant/completed Session history** (Category A reporting data, `22_REPORTING_AND_ANALYTICS.md`): **12-month rolling retention.** Older routine history is deleted or irreversibly aggregated where appropriate, rather than retained indefinitely for the life of the household.
- **Free-text child/parent content** (request reasons, clarification text, rejection notes — `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`): **90-day rolling retention.** Structured outcome metadata (e.g. that a request was approved/rejected, and when) is kept separately under the 12-month rule above where needed for reporting continuity; only the free-text content itself is subject to the shorter 90-day window.
- **Abandoned EngagementSession partial/checkpoint data** (`19_DATA_MODEL.md`'s `EngagementSession.outcome = Abandoned`, per DEC-49): **90-day maximum**, confirmed this round (supersedes the earlier unconfirmed RECOMMENDATION of the same figure) — retained only as historical/debug information, never surfaced as a completed-session credit.
- **Security/audit logs** (§23.3): **12-month rolling retention**, subject to final legal/security review before launch (confirms the earlier RECOMMENDATION as the working figure, still subject to that review).
- **Household deletion** (BR-101/DEC-45): initiates deletion of child/product records from active systems according to the documented deletion process, cascading to Member, Device, Rule, Task, Request, Grant, and Session records for that household, consistent with `20_STATE_MACHINES.md` §20.1's Household state machine. **Backup deletion periods** (how long deleted data may persist in backups/disaster-recovery copies) are not fixed here and should be defined once the actual infrastructure is selected (Phase 7/implementation).
- **Member removal** (soft-delete per `19_DATA_MODEL.md`): historical Task/Rule records remain attributable to a removed Member (for accountability and the audit trail) but the Member's own profile fields are not further processed once removed, and are subject to the same category-based retention windows above.

## 23.6 End-of-Phase-6 cross-check items addressed here

- **Privacy data with no purpose:** none identified — every field in §23.3 traces to a specific confirmed feature.
- **Support/admin capability exposure:** cross-referenced with `30_ADMIN_AND_SUPPORT.md` §30.4/§30.3 to ensure support tooling does not expose more child data than necessary, and does not extend to altering family rules (`30_ADMIN_AND_SUPPORT.md` §30.6, corrected this round) — see that document for the specific findings.
- **Lawful basis not silently assumed:** confirmed by §23.4a's withdrawal of the blanket parental-consent assumption and the required Lawful Basis Matrix, which this document does not itself complete (that is a Phase 7/launch-readiness legal activity, not invented here).
