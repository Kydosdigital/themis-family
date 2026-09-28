# Themis Family — Product Documentation

**Repository:** [Kydosdigital/themis-family](https://github.com/Kydosdigital/themis-family)
**Status: PHASE 6 OF 7 COMPLETE, AWAITING FOUNDER REVIEW (2026-09-28).** This is a discovery/specification exercise. No production code is to be written until the founder explicitly says: **"Requirements approved. Begin implementation."**

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
| 10_RULE_ENGINE_SPECIFICATION.md | Complete (Phase 3, amended 2026-09-28 — approved; BR-211 rewritten to an effective-enforcement model; FR-010 corrected in Phase 5 amendment round, DEC-46) |
| 11_TASK_AND_APPROVAL_SPECIFICATION.md | Complete (Phase 3, amended 2026-09-28 — approved; Automatic Verification split into two Session Types) |
| 12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md | Complete (Phase 3, amended 2026-09-28 — approved) |
| 13_SCHOOL_AND_ESSENTIAL_ACCESS.md | Complete (Phase 3, amended 2026-09-28 — approved; essential-access hard safety principle confirmed) |
| 18_ROLES_AND_PERMISSIONS.md | Complete (Phase 3, 2026-09-28 — approved, no amendments required) |
| 33_PRODUCT_RISK_REGISTER.md | Complete (Phase 1–3, amended 2026-09-28) — will grow in later phases |
| 34_OPEN_QUESTIONS.md | Complete (Phase 1–3, amended 2026-09-28) — will grow in later phases |
| 35_DECISION_LOG.md | Complete (Phase 1–3, amended 2026-09-28) — will grow in later phases |
| 08_EPICS_AND_USER_STORIES.md | Complete (Phase 4, amended 2026-09-28 — approved) |
| 09_ACCEPTANCE_CRITERIA.md | Complete (Phase 4, amended 2026-09-28 — approved) |
| 27_APPLE_INTEGRATION_REQUIREMENTS.md | Complete (Phase 5, amended 2026-09-28 — approved; 50-item shield limits corrected to VERIFIED, App and Website Usage/EU finding added) |
| 16_DEVICE_ENFORCEMENT.md | Complete (Phase 5, amended 2026-09-28 — approved; Local Enforcement Plan model replaces Resolved Shield List) |
| 17_OFFLINE_AND_SYNC_BEHAVIOUR.md | Complete (Phase 5, amended 2026-09-28 — approved; trusted-time model added) |
| 19_DATA_MODEL.md | Complete (Phase 5, amended 2026-09-28 — approved; DOB/Apple-account-ID/picker-label fields corrected) |
| 20_STATE_MACHINES.md | Complete (Phase 5, amended 2026-09-28 — approved; OQ-35/OQ-36 closed) |
| 29_API_AND_BACKEND_REQUIREMENTS.md | Complete (Phase 5, amended 2026-09-28 — approved; OQ-37 confirmed at policy level) |
| 07_NON_FUNCTIONAL_REQUIREMENTS.md | Complete (Phase 6, 2026-09-28 — awaiting founder review) |
| 22_REPORTING_AND_ANALYTICS.md | Complete (Phase 6, 2026-09-28 — awaiting founder review; binds the Category A/Category B reporting-data split) |
| 23_PRIVACY_AND_CHILD_SAFETY.md | Complete (Phase 6, 2026-09-28 — awaiting founder review) |
| 24_SECURITY_REQUIREMENTS.md | Complete (Phase 6, 2026-09-28 — awaiting founder review; SEC-016 flagged as an open threat without a full control) |
| 25_SUBSCRIPTIONS_AND_BILLING.md | Complete (Phase 6, 2026-09-28 — awaiting founder review; closes OQ-33 via DEC-51) |
| 30_ADMIN_AND_SUPPORT.md | Complete (Phase 6, 2026-09-28 — awaiting founder review; rejects a general "view household" admin tool in favour of scenario-scoped views) |
| All other documents (14–15, 21, 26, 28, 31–32, 36–38) | Not yet started |

## Phase plan

1. **Phase 1 (complete, amended 2026-09-28):** Product Overview, Vision, Risks, Open Questions, Decision Log.
2. **Phase 2 (complete and founder-approved, amended 2026-09-28):** Personas, User Journeys, Scope and Release Strategy, High-Level Requirements.
3. **Phase 3 (complete and founder-approved, amended 2026-09-28):** Functional Requirements, Business Rules, Rule Engine Specification, Task and Approval Specification, Requests and Exceptions Specification, School and Essential Access, Roles and Permissions.
4. **Phase 4 (complete and founder-approved, amended 2026-09-28):** Epics and User Stories, Acceptance Criteria.
5. **Phase 5 (complete and founder-approved, amended 2026-09-28):** Data Model, State Machines, Backend/API Requirements, Apple Integration Requirements, Device Enforcement, Offline/Sync Behaviour.
6. **Phase 6 (complete, awaiting founder review, 2026-09-28):** Non-Functional Requirements, Reporting and Analytics, Privacy and Child Safety, Security Requirements, Subscriptions and Billing, Admin and Support.
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

## Phase 5 status

Phase 5 is complete and founder-approved as of 2026-09-28 (amended). It produced six documents, researched and written in this order so later documents could rely on the first: `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`. No production code was written.

Per the founder's explicit instruction, every Apple/platform capability referenced anywhere in this phase is classified into exactly one of four statuses — VERIFIED FROM APPLE DOCUMENTATION, NEEDS REAL-DEVICE TECHNICAL SPIKE, UNSUPPORTED/NOT AVAILABLE, or UNKNOWN — with citations for every VERIFIED claim, in `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.7's summary table.

The founder's review round independently re-checked Apple's current documentation and directed fourteen amendment items (DEC-46 through DEC-50, `35_DECISION_LOG.md`), the most consequential being:

- **The original 50-item shield limit correction was itself wrong and has been withdrawn.** The Phase 5 baseline proposed recharacterising the limit as wholly undocumented; a direct re-check of Apple's documentation found four separate, exactly-documented per-property limits (50 application tokens, 50 web-domain tokens, 50 category tokens with up to 50 exceptions each, for both app and web-domain categories) — now stated as VERIFIED FROM APPLE DOCUMENTATION in `10_RULE_ENGINE_SPECIFICATION.md` FR-010 and `27_APPLE_INTEGRATION_REQUIREMENTS.md`. Only the exceeded-limit failure behaviour remains NEEDS REAL-DEVICE TECHNICAL SPIKE.
- **The Family Controls "App and Website Usage" capability is identified** as `AuthorizationStatus.approvedWithDataAccess`, confirmed by Apple's documentation to be restricted to EU devices with an EU Apple Account for customer installations — and therefore confirmed **not usable in UK V1**, closing OQ-10.
- **The "Resolved Shield List" concept is replaced by the richer Local Enforcement Plan**, which precomputes upcoming transitions and their resulting shield operations so the enforcement extension can execute a scheduled change correctly without the app open or network reachable at that moment.
- **Remote approval → child-device unlock propagation is elevated to the second-highest real-device spike priority**, with a confirmed requirement that the parent UI distinguish "Approved" from "Applied on device" until that propagation is measured.
- **Three data-model fields were corrected**: a child date-of-birth/age-band field (contradicted DEC-24's no-DOB confirmation) is replaced with an explicit `experience_segment`; an assumed Apple account identifier field is removed (no documented API supports it); and a field implying `FamilyActivityPicker` supplies a custom label is replaced with an explicitly Themis-entered `custom_alias`.
- **OQ-35 (early Free Pass revocation) and OQ-36 (abandoned session handling) are now confirmed**, and **OQ-37 (child-side API abuse protection) is confirmed at the policy level**, with exact controls deferred to Phase 6.
- **A trusted-time model replaces the original server-received-time-only mechanic** for offline, time-sensitive submissions (RISK-25 revised), and **OQ-19's staleness threshold is deliberately left unfixed**, pending real-device heartbeat measurement, with the requirement that it be server-configurable.
- **OQ-33 (subscription lapse) is explicitly carried into Phase 6**, not finalised here, subject to a confirmed safety principle: no lapse may leave a child indefinitely locked.

Full detail, including the revised real-device spike priority list (entitlement approval; remote-unlock propagation; Phone/Messages/Maps shielding; scheduled-transition reliability; exceeded shield-limit behaviour; shield persistence; clock/timezone tampering; extension memory behaviour; cross-device reporting), is in `35_DECISION_LOG.md`'s Phase 5 amendment completion note.

## Phase 6 status

Phase 6 is complete and awaiting founder review as of 2026-09-28. It produced six documents: `07_NON_FUNCTIONAL_REQUIREMENTS.md`, `22_REPORTING_AND_ANALYTICS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md`, `24_SECURITY_REQUIREMENTS.md`, `25_SUBSCRIPTIONS_AND_BILLING.md`, `30_ADMIN_AND_SUPPORT.md`. No production code was written.

The founder's Phase 6 instruction asked for six specific end-of-phase cross-check findings; all six were addressed explicitly within the documents themselves rather than deferred:

- **Privacy data with no purpose:** `23_PRIVACY_AND_CHILD_SAFETY.md` §23.3's data-collected table ties every collected field to a stated purpose; nothing is collected speculatively.
- **Security controls with no threat:** `24_SECURITY_REQUIREMENTS.md` §24.6 found none — every SEC control traces to a named threat. The reverse gap was found instead: **SEC-016**, the trusted-time model's dependency on a tamper-resistant monotonic clock, is a threat without a fully specified control, pending real-device research (tracked as new **OQ-40** and new **RISK-26**).
- **Metrics requiring prohibited/unavailable child data:** `22_REPORTING_AND_ANALYTICS.md` binds all V1 reporting to Category A (Themis-owned) data; no metric depends on Category B (Apple-sandboxed, display-only) data or on the EU-only App and Website Usage capability ruled out in Phase 5.
- **Subscription states that could leave a child unexpectedly locked:** `25_SUBSCRIPTIONS_AND_BILLING.md` §25.2 finalises the `Active → BillingRetry → Lapsed → RestrictionsCleared` model (**DEC-51, closes OQ-33**) specifically to satisfy the founder's safety-floor principle — no state results in indefinite lockout. The exact grace-window length (new **OQ-38**) and whether a partial-enforcement middle state should exist instead of the binary model (new **OQ-39**) remain open, but the safety principle itself does not depend on either being resolved.
- **Support/admin capability exposing more child data than necessary:** `30_ADMIN_AND_SUPPORT.md` §30.4 explicitly rejects a general "view any household's full data" admin tool in favour of scenario-scoped views (device-status, subscription, rule-diagnostic), the specific finding the founder's instruction asked this document to surface.
- **NFRs without measurable targets:** `07_NON_FUNCTIONAL_REQUIREMENTS.md` §7.7 flags the ones deliberately left unfixed pending real-device measurement (local shield latency, remote unlock propagation, foreground pass time, availability/capacity numbers) rather than inventing numbers.

Four new open questions were raised and added to `34_OPEN_QUESTIONS.md`: **OQ-38** (subscription grace-window length), **OQ-39** (partial-enforcement middle state during lapse), **OQ-40** (SEC-016 monotonic-clock manipulation resilience), **OQ-41** (safeguarding escalation process detail — an operational/policy item explicitly out of this technical specification's scope). One new risk was added to `33_PRODUCT_RISK_REGISTER.md`: **RISK-26** (monotonic-clock manipulation on a compromised device could defeat the trusted-time model), directly tied to SEC-016/OQ-40.

## Known contradictions / things to watch

See `34_OPEN_QUESTIONS.md` for the full, current list. Resolved as of 2026-09-28: age segmentation, Household Mode scope, second-guardian model, approval-delay policy, verification type, launch region, age-segment selection method, the onboarding-must-verify-protection requirement; from the Phase 3 founder review — OQ-05, OQ-18, OQ-22 through OQ-28; from the Phase 4 founder review — OQ-04a, OQ-20, OQ-29; from the Phase 5 founder review — **OQ-10** (App and Website Usage entitlement, confirmed EU-only and irrelevant to UK V1), **OQ-31** (shield-resolution authority: backend for business state, device for enforcement execution), **OQ-35** (early Free Pass revocation confirmed), **OQ-36** (abandoned session handling confirmed), **OQ-37** (child-side API abuse protection confirmed at policy level); and from Phase 6 — **OQ-33** (subscription lapse model finalised via DEC-51 — no state leaves a child indefinitely locked). From the Phase 2 amendment round: OQ-17 (shared-device scenarios — explicitly out of V1). Still genuinely open: **OQ-19** (staleness threshold — deliberately left unfixed pending real-device measurement, must be server-configurable), **OQ-21** (Teen elevated permissions — FUTURE-leaning, non-blocking), **OQ-30** (Phone/Messages/Maps shielding — top real-device-spike priority after entitlement/unlock-propagation), **OQ-32** (device clock tampering — spike item), **OQ-34** (addressed via the trusted-time model, pending spike validation of the monotonic-clock approach), **OQ-38** (subscription grace-window length, new this phase), **OQ-39** (partial-enforcement middle state during lapse, new this phase), **OQ-40** (SEC-016 monotonic-clock manipulation resilience, new this phase, related to OQ-32), **OQ-41** (safeguarding escalation process detail, new this phase, deferred as operational policy). Still open from earlier phases: the definitive UK school-platform list (OQ-07), final pricing (OQ-11), Kids Category exclusion confirmation (OQ-12). None of these block Phase 7.

## Process note

Per founder instruction (2026-09-28): every major product decision is committed to this repository under `/docs`, not left to live only in conversation history. Each phase's documents are drafted, cross-checked against prior phases, and committed before the next phase begins.
