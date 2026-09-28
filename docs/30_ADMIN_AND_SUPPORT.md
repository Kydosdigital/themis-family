# 30. Admin and Support

**Status:** Phase 6 draft
**Depends on:** `18_ROLES_AND_PERMISSIONS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md`, `24_SECURITY_REQUIREMENTS.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`

## 30.1 Purpose

This document specifies the internal (Themis-staff-facing) admin and customer-support tooling required to operate the product, with particular attention to the founder's explicit end-of-Phase-6 instruction: identify any support/admin capability that exposes more child data than necessary.

## 30.2 Support scenarios and required tooling

| Scenario | Support action needed | Data support staff need to see |
|---|---|---|
| Parent can't complete onboarding / authorization fails | Diagnose `authorizationStatus` state, entitlement issue | Device authorization status (`19_DATA_MODEL.md`); **not** the child's rule/task content |
| Parent disputes a billing charge | Look up subscription state, transaction reference | `Subscription` entity fields; **not** any child-behaviour data |
| Parent reports a rule "not working" | Inspect the household's active rules, the device's last-synced state, recent enforcement history | Rule definitions, Local Enforcement Plan generation timestamps, sync history for the affected device; **not** the content of the child's Task/Request submissions beyond what's needed to diagnose the specific rule |
| Parent requests account/data deletion | Execute household deletion per BR-101/DEC-45's cascade | Household-scoped deletion action, no need to review content first |
| Suspected abuse of the platform (e.g. a household using Themis Family in a way that raises child-safety concern) | Escalation path to a defined review process | **CONFIRMED REQUIREMENT, new for Phase 6:** this scenario needs its own escalation path, distinct from ordinary technical support, since it is a safeguarding matter rather than a product issue — see §30.5. |

## 30.3 Least-privilege principle for support tooling

**CONFIRMED REQUIREMENT.** Support staff access to household data is scoped to what a specific ticket requires, not a blanket "view any household's full data" capability. In particular:

- **SUP-001.** Support staff can view a device's authorization/sync status without needing to view that household's rule content.
- **SUP-002.** Support staff resolving a billing query need only `Subscription` and `Household` identity fields, never Task/Request/Rule content.
- **SUP-003.** Any support access to a household's actual rule/task content (needed for the "rule not working" scenario) requires the ticket to be linked to that specific household (auditable — per `24_SECURITY_REQUIREMENTS.md` SEC-010's suspicious-activity logging, extended here to cover **all** staff access to household data, suspicious or not, as an accountability measure) and does not by default expose the free-text content of rejection notes or request-clarification text beyond what's operationally necessary to diagnose the reported issue.
- **SUP-004.** No support tool exposes a child's `experience_segment`, `custom_alias` entries, or any other Category A reporting data (`22_REPORTING_AND_ANALYTICS.md`) as a general "browse this child's activity" feature — access is always scoped to the specific diagnostic need of the open ticket.

## 30.4 Finding: support capability review (end-of-Phase-6 cross-check item)

Reviewing §30.2's table against the least-privilege principle in §30.3, one capability was flagged and narrowed rather than left broad:

- **Original draft assumption (corrected here):** a general "view household" admin tool giving support staff full read access to every entity in `19_DATA_MODEL.md` for any household, to simplify support-tooling engineering. **This is rejected** — it would expose materially more child data than the scenarios in §30.2 actually require (e.g. a billing-dispute ticket has no legitimate need to reveal a child's Task/Request history). **Corrected requirement:** support tooling is built as scenario-scoped views (device-status view, subscription view, rule-diagnostic view) rather than one unrestricted household browser, even though this costs more engineering effort than a single generic admin panel. This is the specific finding the founder's end-of-Phase-6 instruction asked this document to surface.

## 30.5 Safeguarding escalation path

**CONFIRMED REQUIREMENT, new for Phase 6.** A distinct escalation path exists for any report or signal suggesting a child-safety concern beyond ordinary product support (e.g. a report that a household is using Themis Family's restriction capabilities in a way that raises concern, or a direct disclosure from a child or parent). This routes to a designated safeguarding-trained reviewer, not the general support queue, and is explicitly out of scope for this document to design in full (it is a policy/operations function, not a technical specification) — flagged here as a **required capability to build**, with the detailed process itself deferred as a **FUTURE FEATURE / operational policy item**, not invented in this technical specification.

## 30.6 Admin actions and audit

**CONFIRMED REQUIREMENT.** Every admin/support action that modifies household data (a manual subscription adjustment, a support-initiated rule fix, an account deletion performed on a parent's behalf) is logged with the same accountability standard as ordinary user actions (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.3's audit log), attributing the action to the specific staff member who performed it.

## 30.7 End-of-Phase-6 cross-check items addressed here

- **Support/admin capability exposing more child data than necessary:** identified and corrected in §30.4 — the general "view household" tool is rejected in favour of scenario-scoped views.
- **Metrics that would require prohibited/unavailable child data:** none identified in this document's support scenarios — all diagnostic data needed is Category A (Themis-owned) per `22_REPORTING_AND_ANALYTICS.md`, never Category B (Apple-sandboxed) data, which support tooling could not access even if desired.
