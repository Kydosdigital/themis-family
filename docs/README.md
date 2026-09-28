# Themis Family — Product Documentation

**Repository:** [Kydosdigital/themis-family](https://github.com/Kydosdigital/themis-family)
**Status: PHASE 4 OF 7 COMPLETE AND FOUNDER-APPROVED (amended 2026-09-28); PHASE 5 IN PROGRESS.** This is a discovery/specification exercise. No production code is to be written until the founder explicitly says: **"Requirements approved. Begin implementation."**

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
| 06_FUNCTIONAL_REQUIREMENTS.md | Complete (Phase 3, amended 2026-09-28 — approved) |
| 10_RULE_ENGINE_SPECIFICATION.md | Complete (Phase 3, amended 2026-09-28 — approved; BR-211 rewritten to an effective-enforcement model) |
| 11_TASK_AND_APPROVAL_SPECIFICATION.md | Complete (Phase 3, amended 2026-09-28 — approved; Automatic Verification split into two Session Types) |
| 12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md | Complete (Phase 3, amended 2026-09-28 — approved) |
| 13_SCHOOL_AND_ESSENTIAL_ACCESS.md | Complete (Phase 3, amended 2026-09-28 — approved; essential-access hard safety principle confirmed) |
| 18_ROLES_AND_PERMISSIONS.md | Complete (Phase 3, 2026-09-28 — approved, no amendments required) |
| 33_PRODUCT_RISK_REGISTER.md | Complete (Phase 1–3, amended 2026-09-28) — will grow in later phases |
| 34_OPEN_QUESTIONS.md | Complete (Phase 1–3, amended 2026-09-28) — will grow in later phases |
| 35_DECISION_LOG.md | Complete (Phase 1–3, amended 2026-09-28) — will grow in later phases |
| 08_EPICS_AND_USER_STORIES.md | Complete (Phase 4, amended 2026-09-28 — approved) |
| 09_ACCEPTANCE_CRITERIA.md | Complete (Phase 4, amended 2026-09-28 — approved) |
| All other documents (07, 14–17, 19–32, 36–38) | Not yet started |

## Phase plan

1. **Phase 1 (complete, amended 2026-09-28):** Product Overview, Vision, Risks, Open Questions, Decision Log.
2. **Phase 2 (complete and founder-approved, amended 2026-09-28):** Personas, User Journeys, Scope and Release Strategy, High-Level Requirements.
3. **Phase 3 (complete and founder-approved, amended 2026-09-28):** Functional Requirements, Business Rules, Rule Engine Specification, Task and Approval Specification, Requests and Exceptions Specification, School and Essential Access, Roles and Permissions.
4. **Phase 4 (complete and founder-approved, amended 2026-09-28):** Epics and User Stories, Acceptance Criteria.
5. **Phase 5 (in progress):** Data Model, State Machines, Backend/API Requirements, Apple Integration Requirements, Device Enforcement, Offline/Sync Behaviour.
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

Phase 2 was reviewed by the founder and approved subject to nine amendments (DEC-23 through DEC-31): launch region confirmed UK-first; age-segment selection is explicit (no child DOB collected) and changeable later; the onboarding working-rule requirement (HLR-020) is elevated from Should to Must, with a two-stage Account Creation Complete / Themis Protection Activated model; the Child persona's device assumption corrected (no shared-device support in V1); protection status corrected to avoid implying real-time certainty (expanded to five states with a "Last verified" indicator); Automatic Verification narrowed to what the system can actually prove; request "follow-up questions" constrained to a single bounded clarification exchange, not messaging; temporary access must expire locally, independent of backend/network availability; and documentation must not assert unverified Apple platform behaviour as fact. All nine are applied to the affected Phase 2 documents.

## Phase 3 status

Phase 3 is complete and founder-approved as of 2026-09-28. It produced six documents: `06_FUNCTIONAL_REQUIREMENTS.md` (the FR index, tying every FR back to its HLR, plus the household/device FRs not covered elsewhere), `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, and `18_ROLES_AND_PERMISSIONS.md`. No user stories and no production code were written, per the founder's explicit instruction.

The founder's review round amended four of the six documents (DEC-32 through DEC-39, `35_DECISION_LOG.md`):

- **Rule conflict resolution (BR-211)** replaced the withdrawn linear rule-type precedence with an **effective-enforcement model**: no rule type outranks another; a target stays restricted while any active rule still covers it; completing one rule's condition never implies access returns if another still applies. A new FR-019/BR-226 requires the child-facing UI to name every still-active restriction rather than imply a false unlock.
- **Free Pass scope (BR-219)** confirmed as always explicit (target/scope and duration, via preset or custom choice), with the overridden rule(s) disclosed before confirmation.
- **Request clarification (FR-042/BR-218)** approved as final: one prompt, one reply, then a decision.
- **Automatic Verification** split into two Session Types with opposite backgrounding rules: Active Engagement Session (pauses when backgrounded) and Focus Session (may continue when backgrounded, since that matches its purpose).
- **Rejection notes** confirmed optional but strongly encouraged.
- **Essential access (BR-222)** confirmed as a hard safety principle (emergency calling/OS functionality never deliberately restricted) with Phone/Messages/Maps as the recommended default, split from the still-open technical question of what Apple's APIs actually permit.
- **Scheduled Rule time zones (BR-205)** confirmed to follow the device's current local time zone.
- **Request expiry (FR-043/BR-229)** replaced a flat window with a context-based model (expires when the underlying rule/context ends, or after a 4-hour backstop, whichever comes first).

The end-of-Phase-3 cross-check (re-run after amendments; full detail in `35_DECISION_LOG.md`) found no orphan FRs, no unresolved contradictions, and confirmed all five previously-flagged pending items are now resolved. Two narrower, Phase-5-appropriate technical questions were raised by the amendments themselves (OQ-29: Focus Session violation handling; OQ-30: Apple picker/ManagedSettings validation for Phone/Messages/Maps) — neither blocks Phase 4.

## Phase 4 status

Phase 4 is complete and founder-approved as of 2026-09-28. It produced `08_EPICS_AND_USER_STORIES.md` (seven epics covering every Phase 3 requirement, with each story tracing HLR → FR/BR → User Story) and `09_ACCEPTANCE_CRITERIA.md` (Given/When/Then criteria per story, including the multi-rule status scenarios and the six request-expiry edge cases the founder specifically asked for). No production code was written.

The founder's review amended six areas (DEC-40 through DEC-45, `35_DECISION_LOG.md`), closing a real correctness gap and three open questions:

- **Deadline Lock loophole closed (DEC-40):** the original rule let a child tap "Done" moments before a deadline without genuinely finishing, and avoid enforcement indefinitely pending a parent's response. Replaced with a bounded **30-minute Provisional Approval Grace Period**: approve/reject within the window resolves it immediately; if it expires unresolved, the shield activates until subsequently approved.
- **Reminder interval confirmed (DEC-41, closes OQ-04a):** one automatic reminder at 15 minutes, plus one independent child-triggered nudge — neither resets the other, and no further reminders follow once both are used. Applied identically to tasks and requests.
- **Focus Session violation handling confirmed (DEC-42, closes OQ-29):** a violating attempt is marked Interrupted — no credit, no carried-over time, immediate fresh restart, and strictly neutral, non-punitive copy.
- **Active Engagement Session termination handling replaced (DEC-43):** a crash, force-quit, memory pressure, or device restart no longer flatly resets progress — legitimate foreground time is persisted locally and offered back via Resume where verifiable, with Phase 5 to define the exact persistence/integrity mechanism.
- **Emergency story wording corrected (DEC-44):** narrowed to the actually-confirmed policy (Themis never deliberately interferes with emergency communication), removing an overstated "I can always reach my parents" claim that OQ-30's still-pending technical validation doesn't yet support.
- **Owner exit path confirmed (DEC-45, closes OQ-20):** exactly two V1 paths (transfer to an existing Guardian then leave, or delete the household), with ownerless households, direct-to-Child/Teen transfer, simultaneous invite-and-transfer, and split-custody multi-households all explicitly out of V1.

The re-run cross-check (full detail in `35_DECISION_LOG.md` and `09_ACCEPTANCE_CRITERIA.md` §9.7) found no new orphan FRs, no new unbacked stories, and no new contradictions. Only one AC-level dependency remains genuinely open: US-CHILD-014 AC3 on OQ-30 (Apple technical validation), which does not block Phase 5.

## Known contradictions / things to watch

See `34_OPEN_QUESTIONS.md` for the full, current list. Resolved as of 2026-09-28: age segmentation, Household Mode scope, second-guardian model, approval-delay policy, verification type, launch region, age-segment selection method, the onboarding-must-verify-protection requirement; from the Phase 3 founder review — OQ-05, OQ-18, OQ-22 through OQ-28 (rule conflict precedence, request clarification, time zones, Automatic Verification backgrounding, rejection notes, request expiry, Free Pass scope, essential-access policy); and from the Phase 4 founder review — OQ-04a (reminder interval), OQ-20 (Owner exit path), OQ-29 (Focus Session violation handling). From the Phase 2 amendment round, still open: OQ-17 (shared-device scenarios — explicitly out of V1, needs separate research), OQ-19 (exact protection-status staleness thresholds — for Phase 5). Still open from Phase 3: OQ-21 (Teen elevated permissions — FUTURE-leaning, non-blocking), OQ-30 (Apple picker/ManagedSettings validation for Phone/Messages/Maps — genuinely open, gates only the strength of the emergency-access claim, not Phase 5's start). Still open from earlier phases: the definitive UK school-platform list (OQ-07), technical feasibility of cross-device usage reporting (OQ-09), the App and Website Usage entitlement decision (OQ-10), final pricing (OQ-11), Kids Category exclusion confirmation (OQ-12). None of these block Phase 5.

## Process note

Per founder instruction (2026-09-28): every major product decision is committed to this repository under `/docs`, not left to live only in conversation history. Each phase's documents are drafted, cross-checked against prior phases, and committed before the next phase begins.
