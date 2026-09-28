# 34. Open Questions

**Status:** Phase 1 draft. Every question here blocks a specific downstream document until resolved. Questions are not listed in priority order within their category; Section 5 gives the priority list for Phase 2 readiness.

Format: ID | Question | Why it matters | Recommended default | Blocks

**Resolution note (2026-09-28):** OQ-01, OQ-02, OQ-03, OQ-04 and OQ-06 were resolved by founder decision on this date. See `35_DECISION_LOG.md` DEC-12 through DEC-16 for the binding text. They are kept below, marked RESOLVED, for traceability; new questions raised by those same decisions are appended at the end of each relevant section.

---

## Scope and audience

**OQ-01. [RESOLVED — see DEC-12]** Is the 8–15 age range final, or should V1 target a narrower band, or split child/teen into two distinct product surfaces?
- *Resolution:* Two UX segments within one product: Child (~8–12) and Teen (~13–15), sharing one rule engine. Teen UX must feel more autonomous. Exact boundaries remain subject to user testing, and are a product/UX distinction only, not a scientific or legal claim.
- *Blocks (now unblocked):* `03_PERSONAS.md`, `15_CHILD_AND_TEEN_EXPERIENCE.md`

**OQ-02. [RESOLVED — see DEC-13]** Is Household Mode (rules for parents themselves) truly deferred?
- *Resolution:* Yes, fully deferred. No V1 UI, requirements or engineering effort. Architecture must not be deliberately designed to block adding it later, but nothing is built toward it now.
- *Blocks (now unblocked):* `19_DATA_MODEL.md`, `03_PERSONAS.md`

**OQ-03. [RESOLVED — see DEC-14]** Multiple guardians — what level of support in V1?
- *Resolution:* One Household Owner + up to one additional Guardian, sharing a single household rule set. Both can approve/reject/grant exceptions; only the Owner manages subscription, deletion, guardian removal and ownership transfer. Conflict rule: first valid decision on a pending request wins.
- *Blocks (now unblocked):* `18_ROLES_AND_PERMISSIONS.md`, `19_DATA_MODEL.md`, state machines (Phase 5)

**OQ-03a. [NEW]** What exactly constitutes "first valid decision" when both guardians act within a very short window (race condition at the database/API level, not just the UX level)?
- *Why it matters:* DEC-14 specifies the product rule ("first valid decision wins") but not the technical enforcement (e.g. optimistic locking, single-writer queue per request). Left unspecified, this is a correctness bug waiting to happen.
- *Recommended default:* The Request/Approval record uses an atomic conditional update (e.g. "update status to Approved only if current status is Pending"); the losing write receives a defined "already resolved" response rather than silently overwriting. To be formalised in `20_STATE_MACHINES.md` and `19_DATA_MODEL.md` (Phase 5).
- *Blocks:* `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`

## Rule engine

**OQ-04. [RESOLVED — see DEC-15]** Parent-response-delay policy for Deadline Lock approvals?
- *Resolution:* No auto-approval, ever, in V1. Restriction remains active; Essential/School Mode apps stay available; parent(s) notified immediately plus a reminder after a defined interval; child may send exactly one reminder/nudge; UI must clearly show "Waiting for approval." Configurable trusted-task auto-grace is a FUTURE FEATURE.
- *Blocks (now unblocked):* `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, Approval state machine (Phase 5)

**OQ-04a. [NEW]** What is the exact reminder interval, and does it escalate (e.g. re-notify every 30 minutes) or fire once?
- *Why it matters:* DEC-15 confirms a reminder exists "after a defined interval" but doesn't fix the number or whether it repeats.
- *Recommended default:* Single reminder at 30 minutes after submission, not a repeating escalation (to avoid notification fatigue); re-evaluate based on Phase 2/3 usability input.
- *Blocks:* `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `21_NOTIFICATIONS.md` (later phase)

**OQ-05.** Rule conflict precedence — does the brief's proposed order (Safety > Emergency override > Hard schedule > Deadline restriction > Temporary exception > Earned access > Advisory) hold up, particularly the relative position of a parent's real-time Free Pass versus an already-pending Deadline Lock?
- *Why it matters:* Every enforcement state must be deterministic; an unresolved conflict is a correctness bug, not a UX nitpick.
- *Recommended default:* Adopt the brief's proposed order as a starting hypothesis, but this must be formally specified and tested in `10_RULE_ENGINE_SPECIFICATION.md`, not adopted uncritically as the brief itself warns.
- *Blocks:* `10_RULE_ENGINE_SPECIFICATION.md`

**OQ-06. [RESOLVED — see DEC-16]** Does completing a task ever unlock access without parent approval?
- *Resolution:* Formalised as a **Verification Type** field on every task: **Parent Approval** (default for manual real-world tasks — homework, clean room, chores, packing a school bag) or **Automatic Verification** (permitted only for system-verifiable activities the app can deterministically confirm, e.g. a 20-minute reading timer or 30-minute focus timer; parent can still opt a specific rule back into requiring approval). AI, NFC, QR, location and photo verification remain excluded from V1.
- *Blocks (now unblocked):* `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`

## School Mode

**OQ-07.** What is the definitive list of UK school platforms/apps that Always-Allowed and School Mode must support out of the box (Google Classroom, Microsoft Teams, SIMS, Satchel/Show My Homework, Century, Seneca, specific exam-board portals, etc.)?
- *Why it matters:* This is a release-blocking research task, not a design decision — the product cannot claim "School Mode" without knowing which real apps/sites it protects.
- *Recommended default:* None yet — this requires primary research (parent/teacher interviews or a UK schools app-usage survey) before `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` can be finalised.
- *Blocks:* `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`

**OQ-08. [RESOLVED — see DEC-18]** How should the product handle an app/site that is legitimately both educational and entertainment-distracting (YouTube, Safari, Chrome), given Apple's shielding operates at app/domain level, not content level?
- *Resolution:* Do not attempt content-level classification in V1. Rely on parent-configured Always Allowed apps/sites, a school access list, and time-boxed parent-approved temporary educational access requests. The product must explicitly state this limitation wherever School Mode is described — it must never imply it can tell educational from entertainment content within the same app.
- *Blocks (now unblocked):* `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `26_ERROR_AND_EDGE_CASE_CATALOGUE.md`

## Reporting and privacy

**OQ-09. [Scope confirmed by DEC-19; technical feasibility still open]** What level of usage reporting is Apple's current API actually capable of delivering to a parent's separate device (cross-device), versus only on-device?
- *Why it matters:* The brief and prior discussion both flag that Apple's cross-device reporting capability is uncertain/limited. DEC-19 confirms the V1 reporting *field list* (rule outcomes, task/request outcomes, overrides, protection failures, category usage "only where technically supported") but does NOT resolve whether category-level usage is achievable at all — that remains a technical spike output.
- *Recommended default:* Treat cross-device detailed usage reporting as TECHNICAL DEPENDENCY requiring a spike; ship V1 reporting scoped to the DEC-19 field list, dropping category-level usage from the first release if the spike doesn't confirm it in time.
- *Blocks:* `22_REPORTING_AND_ANALYTICS.md` (later phase), `27_APPLE_INTEGRATION_REQUIREMENTS.md`

**OQ-10.** Should the product pursue the Apple Family Controls "App and Website Usage" entitlement (a separate, more sensitive entitlement than the core Family Controls one) given it exposes app identifiers and visited domains?
- *Why it matters:* This is a second entitlement application with its own approval risk and privacy trade-off; the brief's own privacy principles caution against becoming a browsing-history product.
- *Recommended default:* Do not apply for this entitlement in V1. Revisit only if category-level (non-domain-level) reporting proves technically impossible without it.
- *Blocks:* `27_APPLE_INTEGRATION_REQUIREMENTS.md`

## Commercial

**OQ-11. [Process confirmed by DEC-20; number still open]** Final V1 pricing — is this to be tested with real parents before being fixed, and what is the trial length?
- *Why it matters:* Pricing affects subscription state machine and churn/grace-period design (Phase 6). DEC-20 confirms pricing stays unlocked and must not block Phase 2, but no number or trial length is fixed.
- *Recommended default:* Treat as a testable hypothesis (£6.99/month, a possibly higher family tier, and an annual equivalent, per DEC-20); specify the subscription state machine generically enough to absorb a different number later. Trial length still undecided — recommend 7 days as a starting hypothesis, to be tested.
- *Blocks:* `25_SUBSCRIPTIONS_AND_BILLING.md` (later phase) — does not block Phase 2

**OQ-12.** App Store category: is Kids Category being explicitly ruled out, given its additional parental-gate/advertising/analytics restrictions and the product's actual target user (the parent, not the child)?
- *Why it matters:* Named as an open product question in the brief itself.
- *Recommended default:* Do not submit to Kids Category; position as a Productivity/Utilities family app aimed at the parent as primary account holder. Needs App Store review strategy/legal confirmation before submission, not before spec completion.
- *Blocks:* `28_...` (Privacy and store policy doc, later phase)

---

## Priority order for Phase 2 readiness

**Status as of 2026-09-28: all five Phase-2 blockers are resolved** (OQ-01, OQ-02, OQ-03, OQ-04, OQ-06 — see `35_DECISION_LOG.md` DEC-12 through DEC-16). Phase 2 may proceed.

Remaining open items and their status:

- **OQ-03a, OQ-04a [NEW]** — technical/parameter detail spun off from the resolved decisions above; do not block Phase 2, must close before Phase 5 state machines and Phase 3 approval spec respectively.
- **OQ-07** (definitive UK school platform list) — research task, must close before `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` is finalised. Does not block Phase 2.
- **OQ-08** — RESOLVED (DEC-18).
- **OQ-09** (technical feasibility of category-level/cross-device reporting) — technical spike, must close before `22_REPORTING_AND_ANALYTICS.md` and `27_APPLE_INTEGRATION_REQUIREMENTS.md`. Does not block Phase 2.
- **OQ-10** (App and Website Usage entitlement) — deferred decision, must close before `27_APPLE_INTEGRATION_REQUIREMENTS.md`. Does not block Phase 2.
- **OQ-05** (rule conflict precedence) — must close before `10_RULE_ENGINE_SPECIFICATION.md` in Phase 3. Does not block Phase 2.
- **OQ-11** (exact pricing number/trial length) — explicitly must NOT block Phase 2 per DEC-20; needed before `25_SUBSCRIPTIONS_AND_BILLING.md` in Phase 6.
- **OQ-12** (Kids Category exclusion — legal/App Store confirmation) — can be resolved during Phase 3–6 without blocking Phase 2.
