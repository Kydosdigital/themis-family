# 14. Parent Experience

**Status:** Phase 7 draft
**Depends on:** `03_PERSONAS.md`, `04_USER_JOURNEYS.md`, `08_EPICS_AND_USER_STORIES.md`, `16_DEVICE_ENFORCEMENT.md`, `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4a/§23.4b, `25_SUBSCRIPTIONS_AND_BILLING.md`, `30_ADMIN_AND_SUPPORT.md`

## 14.1 Purpose

This document specifies the Owner/Guardian-facing experience end to end: the screens, states, and copy patterns a parent encounters, tying together confirmed behaviour that is currently scattered across the functional, state-machine, device-enforcement, and subscription documents into one experience-level view. It does not re-derive business rules already confirmed elsewhere; it specifies how those rules surface to a parent.

## 14.2 Onboarding (Owner)

**CONFIRMED REQUIREMENT**, per `04_USER_JOURNEYS.md` §4.1 and DEC-25's two-stage model:

1. **Account Creation Complete** — the Owner has created a Themis account (Sign in with Apple, `24_SECURITY_REQUIREMENTS.md` §24.5) and a Household, but no child is protected yet. The UI must not imply protection is active at this stage.
2. Add a child (`experience_segment`, per DEC-24 — no DOB collected), pair the child's device (`24_SECURITY_REQUIREMENTS.md` §24.5's pairing flow — one-time code/QR, not a child sign-in), and grant Family Controls `.child` authorisation (a separate, on-device Apple flow: the Owner/Guardian completes the Family Controls child authorisation flow on the managed child's enrolled device, per FR-006). V1 does not support parent/child shared devices; the device being enrolled is dedicated to the child for the duration of their profile.
3. Configure at least one working rule (HLR-020, elevated to Must per DEC-25) and confirm the Always Allowed defaults (Phone/Messages/Maps, §13.1).
4. **Themis Protection Activated** — reached only once a device is authorised, at least one rule is active, and the device has completed its first successful sync (FR-008). The UI must not claim this state prematurely.

**Failure paths during onboarding** (feed `26_ERROR_AND_EDGE_CASE_CATALOGUE.md`): child device authorisation declined or later revoked externally (§27.2, detected next foreground check); pairing code expires before use; Guardian invited before onboarding completes.

## 14.3 Home / dashboard

**CONFIRMED REQUIREMENT.** The parent's home screen surfaces, per child/device:
- The five-state protection status (`16_DEVICE_ENFORCEMENT.md` §16.8: Protected / Sync Pending / Device Offline / Needs Attention / Protection Unavailable), shown with both colour and a text label (never colour alone, per `07_NON_FUNCTIONAL_REQUIREMENT.md` NFR-012) and a "Last verified" timestamp.
- Pending items requiring parent action: task approvals, requests, and any Provisional Approval Grace Period countdown (`08_EPICS_AND_USER_STORIES.md`/DEC-40) awaiting a decision before the 30-minute window expires.
- A subscription-state banner when relevant (Billing Grace Period warning, Protection Expired notice, Reactivation prompt — `25_SUBSCRIPTIONS_AND_BILLING.md` §25.2/§25.6), never with child-facing blame language even though this is the parent's own screen.

## 14.4 Rule authoring

**CONFIRMED REQUIREMENT**, per `10_RULE_ENGINE_SPECIFICATION.md` and `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.4 (Owner/Guardian-only authoring): the rule-authoring flow uses Apple's `FamilyActivityPicker` (never a Themis-invented app catalogue, per DEC-52's Phase 6 School Mode confirmation), lets the parent assign a `custom_alias` (never implying the alias came from the picker, per `19_DATA_MODEL.md`), and — when a Deadline Lock or scheduled rule already covers a target being newly marked Always Allowed — explicitly discloses that the rule is being narrowed (BR-220) rather than silently succeeding.

**Approval and grant screens** must use the confirmed **"Approved" vs. "Applied on device"** distinction (`16_DEVICE_ENFORCEMENT.md` §16.6a) and the **"Revocation sent" vs. "Access revoked"** distinction (§16.9a) wherever backend commitment and on-device effect are not guaranteed simultaneous — the parent must never be told an action has taken effect on the child's device before it actually has.

## 14.5 Reporting

**CONFIRMED REQUIREMENT**, per `22_REPORTING_AND_ANALYTICS.md`: the parent-facing reporting surface is built from Category A (Themis-owned: rule/task/request/grant/session outcomes, protection-status history) data only, plus Apple's own embedded, on-device `DeviceActivityReport` view where the UK-available `.approved` authorization supports it (Category B, display-only, never reaching Themis's backend). The UI must not imply Themis stores or can export raw usage-time data it structurally cannot access (§27.5, VERIFIED) — this is a binding constraint on copy, not just architecture.

## 14.6 Subscription and billing screens

**CONFIRMED REQUIREMENT**, per `25_SUBSCRIPTIONS_AND_BILLING.md`: a calm, non-alarming billing-issue warning during the Apple Billing Grace Period; a clear, unambiguous notice at `Protection Expired`; advance notice before a voluntary cancellation's paid-through date ends; and the explicit "Ready to turn protection back on?" reactivation prompt on resubscription (§25.6), never a silent reactivation.

## 14.7 Support access

**CONFIRMED REQUIREMENT**, consistent with `30_ADMIN_AND_SUPPORT.md` §30.3a: the parent-facing help/support entry point must set correct expectations — support can help diagnose sync/billing/account issues but does not create, edit, or approve rules/tasks/requests on the parent's behalf. Where a safeguarding concern is being reported, the flow routes to the distinct safeguarding path (§30.5), not the ordinary support queue.

## 14.8 Owner exit / household lifecycle

**CONFIRMED REQUIREMENT**, per DEC-45: exactly two V1 exit paths are presented to an Owner — transfer ownership to an existing Guardian then leave, or delete the household outright (with the irreversibility and cascade consequences per `23_PRIVACY_AND_CHILD_SAFETY.md` §23.5 clearly explained before confirmation, mirroring the support-assisted deletion verification standard of `30_ADMIN_AND_SUPPORT.md` §30.5a even though this is self-service).

## 14.9 Open items feeding other Phase 7 documents

- Exact reminder/notification cadence and copy for parent-facing alerts: `21_NOTIFICATIONS.md`.
- Full failure-path enumeration (pairing failures, external authorisation revocation, sync failures mid-approval): `26_ERROR_AND_EDGE_CASE_CATALOGUE.md`.
- Acceptance-criterion-level detail for each screen/flow already exists in `09_ACCEPTANCE_CRITERIA.md` and is not duplicated here; this document adds the experience-level narrative connecting those criteria together.
