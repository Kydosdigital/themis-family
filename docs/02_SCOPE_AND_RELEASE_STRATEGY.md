# 02. Scope and Release Strategy

**Status:** Phase 2, amended 2026-09-28 (UK-first launch confirmed — DEC-23)
**Depends on:** `00_PRODUCT_OVERVIEW.md`, `35_DECISION_LOG.md` (DEC-01, DEC-11 through DEC-31)

---

## 2.1 Purpose

This document turns the scope boundary summarised in `00_PRODUCT_OVERVIEW.md` §1.6 into a release plan: what ships in V1, what is explicitly sequenced for V1.1/V2, and what is deferred indefinitely pending validation of the core hypothesis.

---

## 2.2 V1 release definition

**CONFIRMED** (per Decision Log):

V1 is a Family Mode-only iOS/iPadOS app, for one household with one Owner, up to one Guardian, and one or more children split into Child (~8–12) and Teen (~13–15) UX segments.

### V1 must include

| Area | Scope | Confirming decision |
|---|---|---|
| Rule types | Scheduled Rule, Deadline Lock, Earn First | DEC-01, brief §"Core Rule Types" |
| Targets | Apps, websites, app/website categories | Brief §"Website Control" |
| Verification | Verification Type field: Parent Approval / Automatic Verification | DEC-16 |
| Approval | Single Owner + up to one Guardian, shared ruleset, first-valid-decision-wins | DEC-14 |
| Non-response handling | No auto-unlock; waiting state, reminder, one child nudge | DEC-15 |
| Requests | Extra time, deadline extension, temporary access, exception | Brief §"Request and Negotiation System" |
| Essential access | Always Allowed apps/sites, School Mode, temporary educational access requests | DEC-18 |
| Protection status | Protected / Needs Attention / Protection Unavailable (minimum) | Brief §"Protection Status" |
| Reporting | Rule outcomes, task/request outcomes, overrides, enforcement failures; category usage only if the Apple spike confirms feasibility | DEC-19 |
| Offline behaviour | Local-first enforcement; no unsafe unlock on backend outage | Brief §"Offline-First Enforcement" |
| Age UX | Distinct Child and Teen UI complexity within one engine | DEC-12 |
| Subscription | Family plan, trial, monthly/annual, standard billing states | DEC-20 (number not fixed) |

### V1 must explicitly exclude

Personal Mode, Household Mode (adult rules), Daily Allowance/Wallet economy, Friction Ladder beyond a basic pause, photo/NFC/QR/step/location verification, AI verification, Android, full multi-household/separated-parent support, Live Activities/Siri/AlarmKit integrations, Kids Category submission (pending confirmation — OQ-12).

---

## 2.3 Pre-release technical gate (blocks all UI/backend investment)

**TECHNICAL DEPENDENCY — RECOMMENDATION carried from the brief's own "Build Sequence" instruction:**

Before Phase 2 documentation is acted on by engineering, a technical spike must confirm, on a real parent/child device pair:

1. Family Controls authorisation flow completes end-to-end.
2. An app can be selected and shielded.
3. A website domain can be selected and shielded.
4. A schedule-based restriction activates and lifts on time.
5. A shield is removed within an acceptable latency after a simulated approval.
6. Enforcement continues when the main app is force-quit.
7. Apple's distribution entitlement is confirmed granted for this specific use case.

This is not a Phase 2 deliverable; it is listed here because release sequencing depends on its outcome (see `37_BUILD_SEQUENCE.md`, produced in Phase 7, but flagged here as a scope-gating dependency).

---

## 2.4 Release sequencing (beyond V1)

**RECOMMENDATION**, not yet founder-approved as a roadmap commitment:

- **V1:** As defined in §2.2. Single market: UK (CONFIRMED, DEC-23 — UK English, GBP, UK-focused onboarding/research/support; a launch/validation choice, not a permanent restriction, and the architecture must not unnecessarily block later international expansion).
- **V1.1 (candidate, not committed):** Second-guardian conflict refinements if V1 usage shows the "first valid decision wins" rule causing friction; reminder-cadence tuning based on real approval-delay data; expanded School Mode always-allowed presets based on OQ-07 research.
- **V2 (candidate, not committed):** Personal Mode (only if V1 validates the core hypothesis and there is demonstrated demand); Android; expanded reporting if the Apple usage-entitlement spike (OQ-09/OQ-10) proves feasible and worth the added privacy surface.

No date commitments are made in this document. Sequencing beyond V1 is explicitly NOT to be treated as a roadmap promise to users or investors.

---

## 2.5 Definition of V1 "ready to build" (Definition of Ready reference)

Per the brief's own instruction, no feature is ready for engineering until: requirements exist, UX behaviour is specified, permissions are defined, offline behaviour is specified, errors are specified, acceptance criteria exist, dependencies are known, and unresolved blocking questions are closed. The full checklist is formalised in a later phase (`38_DEFINITION_OF_DONE.md`/Definition of Ready). This document records that Phase 2 output (Personas, Journeys, this scope document, and High-Level Requirements) is a prerequisite for Phase 3, not a substitute for it.

---

## 2.6 Open items this document surfaces

OQ-13 (launch region) was resolved by founder decision — see DEC-23 in `35_DECISION_LOG.md`. No open items remain from this document as of the 2026-09-28 amendment round.
