# Themis Family — Product Documentation

**Repository:** [Kydosdigital/themis-family](https://github.com/Kydosdigital/themis-family)
**Status: PHASE 1 OF 7 COMPLETE (as amended 2026-09-28).** This is a discovery/specification exercise. No production code is to be written until the founder explicitly says: **"Requirements approved. Begin implementation."**

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
| 02_SCOPE_AND_RELEASE_STRATEGY.md | Complete (Phase 2) |
| 03_PERSONAS.md | Complete (Phase 2) |
| 04_USER_JOURNEYS.md | Complete (Phase 2) |
| 05_HIGH_LEVEL_REQUIREMENTS.md | Complete (Phase 2) |
| 33_PRODUCT_RISK_REGISTER.md | Complete (Phase 1, amended 2026-09-28) — will grow in later phases |
| 34_OPEN_QUESTIONS.md | Complete (Phase 1+2, amended 2026-09-28) — will grow in later phases |
| 35_DECISION_LOG.md | Complete (Phase 1+2, amended 2026-09-28) — will grow in later phases |
| All other documents (06–32, 36–38) | Not yet started — awaiting founder review before Phase 3 |

## Phase plan

1. **Phase 1 (complete, amended 2026-09-28):** Product Overview, Vision, Risks, Open Questions, Decision Log.
2. **Phase 2 (complete, awaiting founder review):** Personas, User Journeys, Scope and Release Strategy, High-Level Requirements.
3. **Phase 3:** Functional Requirements, Business Rules, Rule Engine Specification, Roles and Permissions.
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

Phase 2 (Personas, User Journeys, Scope and Release Strategy, High-Level Requirements) is now **complete**. Per the founder's own process instruction, work stops here for review — Phase 3 does not begin automatically.

## Known contradictions / things to watch

See `34_OPEN_QUESTIONS.md` for the full, current list. Resolved as of 2026-09-28: age segmentation, Household Mode scope, second-guardian model, approval-delay policy, and verification type. Still open going into Phase 3: rule conflict precedence (OQ-05), the definitive UK school-platform list (OQ-07), technical feasibility of cross-device usage reporting (OQ-09), the App and Website Usage entitlement decision (OQ-10), final pricing (OQ-11), Kids Category exclusion confirmation (OQ-12), and four new items raised during Phase 2 (OQ-13 through OQ-16 — App Store region, single-guardian household coverage, age-segment selection method, and the priority level of the onboarding-demonstrates-a-working-rule requirement). None of OQ-05 through OQ-16 block Phase 3 from starting, but the founder may want to weigh in first.

## Process note

Per founder instruction (2026-09-28): every major product decision is committed to this repository under `/docs`, not left to live only in conversation history. Each phase's documents are drafted, cross-checked against prior phases, and committed before the next phase begins.
