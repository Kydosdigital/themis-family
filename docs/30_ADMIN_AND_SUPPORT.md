# 30. Admin and Support

**Status:** Phase 6, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` DEC-52 through DEC-59)
**Depends on:** `18_ROLES_AND_PERMISSIONS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md`, `24_SECURITY_REQUIREMENTS.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`

**Amendment note (this round):** the original draft's examples of admin/support capability ("support-initiated rule fix," "manual subscription adjustment") were too broad for V1 and are withdrawn. The founder's confirmed principle — **support can diagnose Themis; support cannot parent the child** — is now the binding constraint on §30.3/§30.6, with an explicit list of powers support does and does not have (§30.3a). §30.5's safeguarding path is also corrected: it is no longer characterised as a FUTURE FEATURE (see `34_OPEN_QUESTIONS.md` OQ-41).

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

## 30.3a Support cannot parent the child — CONFIRMED SUPPORT PRINCIPLE, new this amendment round

**CONFIRMED REQUIREMENT, replaces the original draft's broader examples ("support-initiated rule fix," "manual subscription adjustment"), which are withdrawn as too broad for V1.** The governing principle: **support can diagnose Themis; support cannot parent the child.**

For V1, ordinary support staff must **NOT** be able to:
- create, edit, or delete family rules;
- approve or reject a child's tasks;
- approve or decline requests;
- grant or revoke Temporary Access Grants (Free Passes);
- manually change child restrictions;
- impersonate a Parent/Guardian; or
- silently alter the household's agreement in any way.

Support **MAY**:
- view scenario-scoped technical diagnostics (per §30.3's least-privilege model);
- inspect protection/sync state;
- inspect rule *metadata* necessary to diagnose a reported failure (without editing it);
- trigger a **safe resync/revalidation operation that does not change rule intent** (e.g. forcing a device to re-pull and reapply its existing, unchanged Local Enforcement Plan, per `16_DEVICE_ENFORCEMENT.md` §16.3–§16.4);
- revoke compromised sessions/devices through an authorised recovery flow (ties to `24_SECURITY_REQUIREMENTS.md` SEC-002/SEC-015);
- assist with account recovery; and
- guide the parent through correcting configuration themselves.

**Any technical repair performed by support must restore the parent's already-intended state (e.g. re-triggering a sync that failed), never create a new parental decision on the parent's behalf.** This distinction — restoring intent vs. making a new decision — is the test applied to any future support-tooling proposal.

## 30.3b Billing support powers — CONFIRMED, narrows the original draft

**CONFIRMED REQUIREMENT.** Ordinary Themis support is **not** described as able to manually rewrite Apple's subscription source-of-truth state. For V1, support may:
- inspect current subscription entitlement (read-only, per SUP-002);
- help the parent restore purchases (a standard App Store mechanism, not a Themis override);
- explain the App Store billing state to the parent in plain terms;
- direct the parent to Apple's own billing/payment controls; and
- diagnose a failed Themis-side entitlement synchronisation (i.e. "the App Store says X but Themis shows Y" — a sync-diagnostic action, not a state-rewriting one).

**No "manual subscription adjustment" control is implemented for V1.** If Themis later introduces courtesy entitlements, promotional access, or internal credits, these are separate, explicit product concepts requiring their own audit/security requirements — they are not smuggled in under ordinary billing support.

## 30.4 Finding: support capability review (end-of-Phase-6 cross-check item)

Reviewing §30.2's table against the least-privilege principle in §30.3, one capability was flagged and narrowed rather than left broad:

- **Original draft assumption (corrected here):** a general "view household" admin tool giving support staff full read access to every entity in `19_DATA_MODEL.md` for any household, to simplify support-tooling engineering. **This is rejected** — it would expose materially more child data than the scenarios in §30.2 actually require (e.g. a billing-dispute ticket has no legitimate need to reveal a child's Task/Request history). **Corrected requirement:** support tooling is built as scenario-scoped views (device-status view, subscription view, rule-diagnostic view) rather than one unrestricted household browser, even though this costs more engineering effort than a single generic admin panel. This is the specific finding the founder's end-of-Phase-6 instruction asked this document to surface.

## 30.5 Safeguarding escalation path — CORRECTED this amendment round, NOT a FUTURE FEATURE

**CONFIRMED LAUNCH-READINESS REQUIREMENT — the original draft's characterisation of the safeguarding process as a FUTURE FEATURE is withdrawn.** A distinct escalation path exists for any report or signal suggesting a child-safety concern beyond ordinary product support (e.g. a report that a household is using Themis Family's restriction capabilities in a way that raises concern, or a direct disclosure from a child or parent). This routes to a designated safeguarding-trained reviewer, not the general support queue.

**This document does not invent the substantive safeguarding policy itself** — the detailed escalation procedure is an operational/legal document requiring appropriate legal/safeguarding expertise, not a technical specification this BA/product-architecture engagement is positioned to author. But a **minimum process must exist before public launch**, not merely be planned for some future release. Before public launch, Themis Family must have:

- a named safeguarding owner / escalation owner;
- a documented escalation procedure;
- staff guidance for child-safety disclosures;
- clear separation between ordinary product support and safeguarding cases (structurally supported by this document's distinction between §30.3a's ordinary support powers and this escalation path);
- minimum-necessary data-access rules for safeguarding reviewers (the same least-privilege principle as §30.3, applied to this more sensitive case);
- emergency/immediate-risk handling guidance, reviewed by appropriate legal/safeguarding expertise;
- documented record-keeping and access controls for safeguarding cases specifically; and
- staff training appropriate to their role.

This is tracked in `38_DEFINITION_OF_DONE.md` (Phase 7) as **"Safeguarding process approved for launch"** — a launch-readiness gate, not a nice-to-have deferred indefinitely.

## 30.6 Admin actions and audit — corrected examples this amendment round

**CONFIRMED REQUIREMENT.** Every admin/support action that modifies household data is logged with the same accountability standard as ordinary user actions (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.3's audit log), attributing the action to the specific staff member who performed it. **The original draft's examples here ("a manual subscription adjustment, a support-initiated rule fix") are withdrawn as inconsistent with §30.3a/§30.3b, which confirm support does not perform either action for V1.** Correct examples of logged admin/support actions consistent with this document's confirmed powers: a triggered safe resync/revalidation; a revoked compromised session/device; a support-assisted account deletion (§30.5a); a restore-purchases assist.

## 30.5a Account deletion through support — CONFIRMED, new this amendment round

**CONFIRMED REQUIREMENT.** Self-service deletion (parent-initiated directly in-app) is the preferred route and remains available per §30.2. A **support-assisted deletion** may exist only after strong account-holder verification, with the following requirements:

- verify the Owner's identity before proceeding;
- clearly explain the irreversibility of the action to the Owner;
- confirm the household scope of the deletion (which household, which records) before executing;
- audit both the request and the staff action performed, per §30.6; and
- **support staff are never required to browse the child's content before deleting it** — deletion is a scoped, identity-verified action, not a content-review gate (consistent with SUP-004's "no browsing" principle).

Exact recovery/deletion test scenarios (e.g. attempted deletion with insufficient verification, mid-deletion failure/retry) are carried into Phase 7's test strategy (`31_TEST_STRATEGY.md`) rather than specified here.

## 30.7 End-of-Phase-6 cross-check items addressed here

- **Support/admin capability exposing more child data than necessary:** identified and corrected in §30.4 — the general "view household" tool is rejected in favour of scenario-scoped views.
- **Metrics that would require prohibited/unavailable child data:** none identified in this document's support scenarios — all diagnostic data needed is Category A (Themis-owned) per `22_REPORTING_AND_ANALYTICS.md`, never Category B (Apple-sandboxed) data, which support tooling could not access even if desired.
- **Support role could alter family restrictions:** identified and corrected this amendment round — §30.3a now explicitly excludes rule/approval/grant-altering powers from ordinary support, narrowing the original draft's broader examples.
