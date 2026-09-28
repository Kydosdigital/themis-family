# 34. Open Questions

**Status:** Phase 2 amendments applied, Phase 3 starting. Every question here blocks a specific downstream document until resolved. Questions are not listed in priority order within their category.

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

**OQ-04a. [RESOLVED — see DEC-41].** What is the exact reminder interval, and does it escalate or fire once?
- *Resolution:* Immediate notification on submission; exactly one automatic reminder at 15 minutes if still unresolved (does not repeat); the child/teen may separately send exactly one manual nudge per pending item, independent of the automatic reminder (using it does not reset the automatic schedule); after both have fired, no further reminders are sent for that item. Applies identically to tasks (`11_TASK_AND_APPROVAL_SPECIFICATION.md` BR-213) and requests (`12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` BR-230).
- *Blocks (now unblocked):* `21_NOTIFICATIONS.md` (later phase)

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

---

## Questions raised during Phase 2

**OQ-13. [RESOLVED — see DEC-23]** Should V1's App Store listing target UK only, or a wider English-speaking region from day one?
- *Resolution:* UK-first launch: UK English, GBP, UK-focused onboarding/research/support assumptions. This is a launch/validation decision, not a permanent restriction; architecture must not unnecessarily block later international expansion.
- *Blocks:* None — resolved.

**OQ-14. [CLOSED]** Should a single-child, single-guardian household be documented as its own distinct persona/journey?
- *Resolution:* No additional persona required. The single-child, single-guardian household remains explicitly represented in the onboarding journey (`04_USER_JOURNEYS.md` §4.1). Closed by founder confirmation, 2026-09-28.
- *Blocks:* None.

**OQ-15. [RESOLVED — see DEC-24]** Does the app infer a child's UX segment from a stored date of birth, or does the parent explicitly select it?
- *Resolution:* Parent explicitly selects "Child experience" or "Teen experience" during setup (no precise child DOB is collected for this purpose). Suggested copy: *"Choose the experience that best fits your child. You can change this later."* Bands (Child ~8–12, Teen ~13–15) are guidance only, changeable later without account deletion/recreation.
- *Blocks (now unblocked):* `19_DATA_MODEL.md` (Phase 5) — the User entity does not require a precise DOB field for segment assignment.

**OQ-16. [RESOLVED — see DEC-25]** Should HLR-020 (onboarding demonstrates a working rule) be "Should" or "Must"?
- *Resolution:* Elevated to **Must**, with an explicit two-stage completion model: **Account Creation Complete** (household/members created) is distinct from **Themis Protection Activated** (child-device authorisation valid, a rule target selected, a real test shield applied and successfully removed, and the resulting state verified). The parent sees an incomplete-setup state until Protection Activated is achieved.
- *Blocks (now unblocked):* `05_HIGH_LEVEL_REQUIREMENTS.md` (HLR-020 updated), `38_DEFINITION_OF_DONE.md` (Phase 7 — should still reflect this as release-blocking).

## Questions raised by the Phase 2 amendment round (2026-09-28)

**OQ-17 [NEW].** What exactly is required to support shared-device scenarios (one iPad shared by siblings; parent and child sharing a device; a device signed into a parent's Apple Account; a device signed into one child's account but used by multiple children) — and is any of this feasible under Apple's Family Controls model, which is scoped per child Apple Account?
- *Why it matters:* The original Child persona silently assumed shared-device usage, which may not be technically supportable the way parents expect (e.g. two children sharing one iPad might not get independently enforced rules). This is a real UK household pattern (siblings sharing a tablet is common) and a false assumption here could undermine the reliability positioning as badly as an enforcement bug.
- *Recommended default:* Treat as OUT of V1 entirely. Canonical V1 assumption: each child has their own device signed into their own Child Apple Account within the family's Family Sharing group (DEC-26). Research and technical-spike shared-device scenarios separately, before any commitment, marketing claim, or UI affordance implying support.
- *Blocks:* `03_PERSONAS.md` (already corrected), `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` and `16_DEVICE_ENFORCEMENT.md` (later phases) must state this limitation explicitly wherever device setup is described.

**OQ-18 [NEW].** What is the simplest viable structure for the request-clarification mechanism (DEC-29) that stays clearly bounded and doesn't become messaging?
- *Why it matters:* "Ask a follow-up question" needs a concrete, narrow interaction model before Phase 3's Requests and Exceptions Specification can be written.
- *Recommended default:* A single structured clarification prompt from the approver (free-text, but capped in length, attached only to that specific pending request) and a single structured reply from the child/teen; once a reply is given, the approver must then approve/decline/grant a duration — the thread does not continue indefinitely. To be formalised in `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` (Phase 3).
- *Blocks:* `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`

**OQ-19 [NEW].** What are the exact staleness thresholds before a "Protected" status must downgrade to "Sync Pending" or "Device Offline"?
- *Why it matters:* DEC-27 establishes the principle (no implied real-time state, must show last-verified time, stale state must not display as Protected indefinitely) but not the specific time thresholds.
- *Recommended default:* Defer exact thresholds to `16_DEVICE_ENFORCEMENT.md` (Phase 5), informed by the technical spike's findings on realistic sync frequency. Do not guess a number in Phase 3.
- *Blocks:* `16_DEVICE_ENFORCEMENT.md` (Phase 5)

---

## Questions raised during Phase 3 (2026-09-28)

**OQ-20 [RESOLVED — see DEC-45].** What happens if the Owner wants to leave the household and there is no Guardian to transfer to?
- *Resolution:* V1 supports exactly two paths: invite a Guardian and transfer ownership to them, then leave; or delete the household. No ownerless household, no transfer to a Child/Teen, no simultaneous invite-and-transfer, and no split-custody multi-household support in V1 (`18_ROLES_AND_PERMISSIONS.md` BR-101).
- *Blocks (now unblocked):* `20_STATE_MACHINES.md` (Phase 5) — household lifecycle state machine can now be built against a confirmed model.

**OQ-21 [NEW — from `18_ROLES_AND_PERMISSIONS.md`].** Can a Teen ever be granted any elevated permission (e.g. approving a younger sibling's task) as a trust-building feature, or is that permanently out of scope?
- *Why it matters:* A natural future extension of the "trust increases over time" positioning (review dates, negotiation), not raised in the original brief.
- *Recommended default:* FUTURE FEATURE, explicitly not V1. No architecture decision needs to be made now beyond not hard-coding "only Owner/Guardian can ever approve" at a level that would make this impossible later.
- *Blocks:* None for V1.

**OQ-22 [RESOLVED — see DEC-36].** Should Scheduled Rule times follow the device's current time zone or stay fixed to a home time zone?
- *Resolution:* Follows the child device's current local time zone; V1 does not build home-vs-travel configuration. Phase 5 must define change detection, recalculation, persistence, and a parent-facing indication where material.
- *Blocks (now unblocked):* `19_DATA_MODEL.md`, `20_STATE_MACHINES.md` (Phase 5) — technical implementation detail only remains.

**OQ-23 [RESOLVED — see DEC-32].** Does Scheduled Rule outrank Deadline Lock and Earn First in conflict precedence?
- *Resolution:* Superseded — there is no rule-type precedence in the confirmed effective-enforcement model. No rule type outranks another; a target stays restricted while any active rule still covers it.
- *Blocks:* None — resolved.

**OQ-24 [RESOLVED — see DEC-37].** Does an in-app timer/focus session pause when backgrounded or locked?
- *Resolution:* Split into two Session Types with opposite correct behaviour: Active Engagement Session pauses on backgrounding/lock; Focus Session may continue while backgrounded/locked (see `11_TASK_AND_APPROVAL_SPECIFICATION.md` §11.1a).
- *Blocks (now unblocked):* `20_STATE_MACHINES.md` (Phase 5) — the Task state machine's two Session Type sub-states.

**OQ-25 [RESOLVED — see DEC-38].** Is a rejection note mandatory, optional, or absent?
- *Resolution:* Optional, strongly encouraged via a prominent UI field, never mandatory; remains one-way (not a conversation thread).
- *Blocks:* None — resolved.

**OQ-26 [RESOLVED — see DEC-39].** What is the exact request-expiry window?
- *Resolution:* Context-based: a request expires when its underlying rule/context can no longer be meaningfully affected, with a 4-hour maximum pending lifetime as a backstop only. Every request carries `created_at`, `expires_at`, and a context reference.
- *Blocks (now unblocked):* `20_STATE_MACHINES.md` (Phase 5); Phase 4 acceptance criteria must cover the six expiry scenarios listed in DEC-39.

**OQ-27 [RESOLVED — see DEC-33].** Should a Free Pass default to a pre-selected scope, or require explicit selection every time?
- *Resolution:* Always explicit target/scope and duration selection, via preset or custom choice; no unscoped default. The app states which rule(s) will be overridden before confirmation.
- *Blocks (now unblocked):* `15_CHILD_AND_TEEN_EXPERIENCE.md` / `14_PARENT_EXPERIENCE.md` (later phases).

**OQ-28 [RESOLVED at the product-policy level — see DEC-35; split into OQ-30 for the remaining technical question].** What is in the non-configurable essential minimum set?
- *Resolution:* Product policy confirmed: emergency calling/OS-level emergency functionality is never deliberately restricted (hard safety principle), with Phone, Messages, Maps as the recommended default Always Allowed set where technically supported. The remaining question — exactly what Apple's picker/ManagedSettings actually permit for these apps — is technical, not a product decision, and is tracked separately as OQ-30.
- *Blocks:* `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` — unblocked at the policy level.

**OQ-29 [RESOLVED — see DEC-42].** When a child opens a restricted app during an active Focus Session, does the session reset entirely or pause-and-flag the violation?
- *Resolution:* The attempt is marked Interrupted — ends immediately, no completion credit, no carried-over time; the child may start a fresh attempt immediately with no cooldown. Copy must be neutral and non-punitive ("Focus session interrupted. Start again when you're ready." — never "Failed" or shame-oriented wording). Configurable grace behaviour is a FUTURE FEATURE, not V1.
- *Blocks (now unblocked):* `20_STATE_MACHINES.md` (Phase 5) — the Focus Session sub-state machine can now be built against a confirmed terminal state.

**OQ-30 [NEW — split from OQ-28].** What does Apple's picker and ManagedSettings framework actually expose or permit for Phone, Messages, and Maps specifically?
- *Why it matters:* BR-222's product policy (DEC-35) is confirmed and does not wait on this, but the documentation must not claim a specific technical guarantee until the Apple technical spike verifies it.
- *Recommended default:* None — pure technical-spike output.
- *Blocks:* `27_APPLE_INTEGRATION_REQUIREMENTS.md` (Phase 5); `24_SECURITY_REQUIREMENTS.md` (Phase 6) should confirm final wording of any "cannot be restricted" claim against the spike's findings.

**OQ-18 [RESOLVED — see DEC-34].** What is the simplest viable structure for the request-clarification mechanism?
- *Resolution:* FR-042/BR-218 (one prompt, one reply, then a decision) is approved as final for V1.
- *Blocks:* None — resolved.
