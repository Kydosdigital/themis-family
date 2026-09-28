# Themis Family — Product Documentation

**Repository:** [Kydosdigital/themis-family](https://github.com/Kydosdigital/themis-family)
**Status: PHASE 2 OF 7 COMPLETE AND FOUNDER-APPROVED (amended 2026-09-28); PHASE 3 IN PROGRESS.** This is a discovery/specification exercise. No production code is to be written until the founder explicitly says: **"Requirements approved. Begin implementation."**

---

## What this is

**Themis Family** is a family digital-rules mobile app. This is its complete, traceable specification, so an engineering team can build it without guessing how any important behaviour should work.

Positioning: **"Clear digital boundaries without the daily arguments."**
Core promise: **"Set clear digital rules once, and let the phone enforce them."**

Product name confirmed 2026-09-28 (see `35_DECISION_LOG.md`, DEC-11). Do not rename without an explicit further decision.

## How to read this documentation

Start with `00_PRODUCT_OVERVIEW.md` and `01_PRODUCT_VISION_AND_GOALS.md`. Every other document should trace back to those two. If something in a later document (once written) seems to contradict them, that is a bug in the documentation, not a new decision — flag it in `34_OPEN_QUESTIONS.md`.

## Document status

| Document | Status |
|---|---|
| 00_PRODUCT_OVERVIEW.md | Complete (Phase 1, amended 2026-09-28) |
| 01_PRODUCT_VISION_AND_GOALS.md | Complete (Phase 1, amended 2026-09-28) |
| 02_SCOPE_AND_RELEASE_STRATEGY.md | Complete (Phase 2, amended 2026-09-28 — approved) |
| 03_PERSONAS.md | Complete (Phase 2, amended 2026-09-28 — approved) |
| 04_USER_JOURNEYS.md | Complete (Phase 2, amended 2026-09-28 — approved) |
| 05_HIGH_LEVEL_REQUIREMENTS.md | Complete (Phase 2, amended 2026-09-28 — approved) |
| 33_PRODUCT_RISK_REGISTER.md | Complete (Phase 1+2, amended 2026-09-28) — will grow in later phases |
| 34_OPEN_QUESTIONS.md | Complete (Phase 1+2, amended 2026-09-28) — will grow in later phases |
| 35_DECISION_LOG.md | Complete (Phase 1+2, amended 2026-09-28) — will grow in later phases |
| All other documents (06–32, 36–38) | Phase 3 in progress |

## Phase plan

1. **Phase 1 (complete, amended 2026-09-28):** Product Overview, Vision, Risks, Open Questions, Decision Log.
2. **Phase 2 (complete and founder-approved, amended 2026-09-28):** Personas, User Journeys, Scope and Release Strategy, High-Level Requirements.
3. **Phase 3 (in progress):** Functional Requirements, Business Rules, Rule Engine Specification, Task and Approval Specification, Requests and Exceptions Specification, School and Essential Access, Roles and Permissions.
4. **Phase 4:** User Stories and Acceptance Criteria.
5. **Phase 5:** Data Model, State Machines, Backend/API Requirements, Apple Integration Requirements, Device Enforcement, Offline/Sync Behaviour.
6. **Phase 6:** Privacy and Child Safety, Security, Reporting and Analytics, Subscriptions and Billing, Admin and Support.
7. **Phase 7:** Error/Edge Case Catalogue, Test Strategy, Traceability Matrix, Build Sequence, MVP vs. Later Feature Matrix, Definition of Ready/Done.

After each phase, the Risk Register, Open Questions and Decision Log are revisited and updated — they are living documents, not one-off outputs.

## Phase 2 readiness

All five decisions that were blocking Phase 2 have been resolved by the founder (2026-09-28) and are recorded in `35_DECISION_LOG.md` as DEC-12 through DEC-16:

1. Age band: 8–15 overall, split into Child (~8–12) and Teen (~13–15) UX segments.
2. Household Mode (adult self-rules): fully deferred, zero V1 UI.
3. Second guardian: supported, one additional Guardian per household, full approval permissions, Owner-only for destructive actions.
4. Parent non-response: no auto-unlock; honest "Waiting for approval" state, reminder, one child nudge.
5. Task verification: formalised as a Verification Type field (Parent Approval or Automatic Verification).

Phase 2 was reviewed by the founder and approved subject to nine amendments (DEC-23 through DEC-31): launch region confirmed UK-first; age-segment selection is explicit (no child DOB collected) and changeable later; the onboarding working-rule requirement (HLR-020) is elevated from Should to Must, with a two-stage Account Creation Complete / Themis Protection Activated model; the Child persona's device assumption corrected (no shared-device support in V1); protection status corrected to avoid implying real-time certainty (expanded to five states with a "Last verified" indicator); Automatic Verification narrowed to what the system can actually prove; request "follow-up questions" constrained to a single bounded clarification exchange, not messaging; temporary access must expire locally, independent of backend/network availability; and documentation must not assert unverified Apple platform behaviour as fact. All nine are applied to the affected Phase 2 documents. **Phase 3 is now in progress.**

## Known contradictions / things to watch

See `34_OPEN_QUESTIONS.md` for the full, current list. Resolved as of 2026-09-28: age segmentation, Household Mode scope, second-guardian model, approval-delay policy, verification type, launch region, age-segment selection method, and the onboarding-must-verify-protection requirement. New from the amendment round: OQ-17 (shared-device scenarios — explicitly out of V1, needs separate research), OQ-18 (exact structure of the request-clarification mechanism — for Phase 3), OQ-19 (exact protection-status staleness thresholds — for Phase 5). Still open from earlier: rule conflict precedence (OQ-05), the definitive UK school-platform list (OQ-07), technical feasibility of cross-device usage reporting (OQ-09), the App and Website Usage entitlement decision (OQ-10), final pricing (OQ-11), Kids Category exclusion confirmation (OQ-12). None of these block Phase 3.

## Process note

Per founder instruction (2026-09-28): every major product decision is committed to this repository under `/docs`, not left to live only in conversation history. Each phase's documents are drafted, cross-checked against prior phases, and committed before the next phase begins.
