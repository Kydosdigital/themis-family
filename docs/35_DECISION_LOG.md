# 35. Decision Log

**Status:** Phase 1 draft. Decisions marked "Proposed" require explicit founder confirmation before downstream documents treat them as fixed. Decisions marked "Confirmed" are taken directly from the founder's own stated position in this conversation or the brief.

Format: ID | Decision | Status | Rationale | Date | Supersedes

---

**DEC-01.** V1 scope excludes Personal Mode and Household Mode entirely; Family Mode only.
- **Status:** Confirmed (founder's own stated conclusion in prior discussion: "strip the parent helping themselves side")
- **Rationale:** Two audiences at launch doubles onboarding, messaging and trust surface area for no validated benefit; Family Mode is the less crowded, better-monetising, more enforceable segment.
- **Date:** 2026-09-28
- **Supersedes:** Original blueprint's three-mode (Personal/Family/Household) V1 scope.

**DEC-02.** Deadline Lock, not Earn-First, is the hero mechanic.
- **Status:** Confirmed (founder-reviewed external advice, adopted into the brief's own Core Rule Types section)
- **Rationale:** Earn-first-for-everything is the crowded, more punitive-feeling part of the market (taskr, Earn Time, ScreenEarn, Chore Champ, Carrots&Cake all compete here). Deadline Lock preserves default trust. Note: taskr already implements a deadline-lock mechanic, so the real differentiation must come from the negotiation/agreement framing and reliability, not from the mechanic being unique — this caveat is carried into `00_PRODUCT_OVERVIEW.md` and should not be lost in later marketing copy.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-03.** Initial platform is iOS/iPadOS only; Android is explicitly deferred.
- **Status:** Confirmed (stated in brief, Section "Initial Platform Strategy")
- **Rationale:** Android has no single equivalent to Apple's Screen Time shield; validating product-market fit on iOS first avoids building two enforcement architectures before proving demand for one.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-04.** Website blocking is in scope for V1, but only as part of app/website rules the parent sets — not as a general content-filtering/safe-browsing product.
- **Status:** Confirmed
- **Rationale:** Apple's ManagedSettings supports shielded web domains and categories natively; going further (e.g., replicating Qustodio-style deep content filtering) competes on ground where established players are stronger and shifts the product away from its "agreement" positioning toward a "monitoring" positioning.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-05.** The product will not be marketed or engineered as "unhackable" or "impossible to bypass."
- **Status:** Confirmed
- **Rationale:** Technically inaccurate (Apple's model allows ultimate parent/guardian revocation and does not guarantee no circumvention), and this framing is explicitly listed in the brief as positioning to avoid.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-06.** The product will not read message content, record calls, track continuous location by default, or build a full browsing-history diary for parents.
- **Status:** Confirmed
- **Rationale:** Stated privacy principle in the brief; also a commercial differentiation point ("privacy-first parental control") versus Qustodio/Bark.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-07.** Detailed cross-device usage reporting (a Qustodio-style activity feed) will not be promised until Apple's API capability is technically verified.
- **Status:** Confirmed (founder's own caution, echoed in prior discussion: "I would not promise a Qustodio-style remote activity feed until we prove exactly what Apple's supported architecture allows")
- **Rationale:** Avoids shipping a broken or misleading headline feature; avoids applying for a more sensitive entitlement (App and Website Usage) before it's proven necessary.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-08.** Reliability (accurate protection status, honest enforcement-health signalling, no false "protected" state) is treated as a core brand attribute and a release-blocking quality bar, not a nice-to-have.
- **Status:** Confirmed
- **Rationale:** Directly stated in the brief (AC4) and independently arrived at in prior discussion as the hardest-to-copy differentiator versus competitors who have visible reliability complaints in their own App Store release notes.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-09.** V1 will not submit to Apple's Kids Category.
- **Status:** Proposed — flagged as needing App Store review strategy/legal confirmation, not yet a closed decision.
- **Rationale:** The product's primary account holder and decision-maker is the parent, not the child; Kids Category imposes additional constraints (parental gates, third-party analytics/advertising restrictions) suited to child-directed entertainment apps rather than a family-utility product.
- **Date:** 2026-09-28
- **Supersedes:** N/A

**DEC-10.** The 8–15 age range is provisional and must be validated, not treated as fixed segmentation.
- **Status:** Confirmed as a process rule (brief explicitly instructs this); the range itself is Proposed, not Confirmed.
- **Rationale:** No user research has yet validated this specific band; brief instructs it be recorded as a decision requiring validation.
- **Date:** 2026-09-28
- **Supersedes:** N/A

---

## Founder decisions received 2026-09-28 (post Phase-1 review)

**DEC-11. Product name.**
- **Status:** Confirmed
- **Decision:** The product is named **Themis Family**. Working positioning line: *"Clear digital boundaries without the daily arguments."* Do not rename without an explicit further decision.
- **Rationale:** Founder decision, given directly.
- **Date:** 2026-09-28
- **Supersedes:** Prior placeholder working title "Rulebook" used in the original blueprint and in `00_PRODUCT_OVERVIEW.md`/README's "not finalised" note.

**DEC-12. Age segmentation — resolves OQ-01.**
- **Status:** Confirmed
- **Decision:** V1 audience remains families with children approximately 8–15, but this is split into two distinct UX segments: Child (approx. 8–12) and Teen (approx. 13–15). This is a product/UX distinction only, not a claim that these boundaries are scientifically or legally definitive. The teen experience must feel more autonomous and less childish than the child experience. The exact commercial age range remains subject to user testing.
- **Rationale:** Founder decision; matches the brief's own instruction not to treat the age range as fixed while still giving engineering/design something concrete to build against.
- **Date:** 2026-09-28
- **Supersedes:** Provisional single 8–15 band in `00_PRODUCT_OVERVIEW.md` §1.3.

**DEC-13. Personal Mode / Household Mode — resolves OQ-02.**
- **Status:** Confirmed
- **Decision:** Both fully OUT of V1. No V1 UI, requirements, or engineering effort spent on either. The architecture must not be deliberately designed to prevent adding Personal Mode later, but nothing is to be built toward it now.
- **Rationale:** Founder decision, consistent with DEC-01.
- **Date:** 2026-09-28
- **Supersedes:** Confirms and sharpens DEC-01 (removes any ambiguity about "architecture should support it later" being read as "build some of it now").

**DEC-14. Second guardian — resolves OQ-03.**
- **Status:** Confirmed
- **Decision:** V1 supports exactly one Household Owner plus up to one additional Guardian, sharing ONE household rule set (no separated-household or split-ruleset support in V1). Multiple children may belong to the household. Both Owner and Guardian may: receive child requests, approve/reject task completions, approve/decline extra-time requests, grant temporary access, see child rule status and protection status. Only the Owner may: manage the subscription, delete the household, remove the other guardian, transfer ownership, and perform other destructive account-level actions. Conflict rule: if both guardians respond to the same pending request, **first valid decision wins**; the later response is shown that the request has already been resolved.
- **Rationale:** Founder decision. Balances real UK household needs (two parents) against the brief's own caution not to build full separated-parent/conflicting-household logic in V1.
- **Date:** 2026-09-28
- **Supersedes:** OQ-03's "Proposed" recommendation of full permissions for a second guardian is now Confirmed with the specific permission split and conflict rule above.

**DEC-15. Parent non-response policy — resolves OQ-04.**
- **Status:** Confirmed
- **Decision:** No automatic entertainment unlock when a parent/guardian fails to respond. On submission: status becomes "Waiting for Approval"; the restriction remains active; Essential and School Mode apps/sites remain available throughout; the parent(s) get an immediate notification and a reminder after a defined interval; the child may send exactly one reminder/nudge; the UI must clearly state it is waiting for parent approval. Parent-configurable trusted-task auto-grace policies are a FUTURE FEATURE, explicitly not V1.
- **Rationale:** Founder decision. Matches the brief's own instruction that tapping "Done" must not itself restore access, and closes the exploitable-loophole risk of auto-unlock.
- **Date:** 2026-09-28
- **Supersedes:** OQ-04's recommended default (which proposed a configurable reminder interval and no auto-approval) — the "no auto-approval" part is now Confirmed rather than Recommended; the reminder-interval default (30 minutes) remains a RECOMMENDATION pending Phase 3 specification, and the child single-nudge capability is a new Confirmed requirement not previously specified.

**DEC-16. Verification type (approval vs. automatic) — resolves OQ-06.**
- **Status:** Confirmed
- **Decision:** The rule/task model formalises a **Verification Type** field with two values: **Parent Approval** (default for manual real-world tasks: homework, clean room, chores, pack school bag — child tapping "Done" does NOT itself restore access) and **Automatic Verification** (permitted only for system-verifiable activities the app can deterministically confirm, e.g. a 20-minute in-app reading timer or a 30-minute focus timer — no parent approval required unless the parent explicitly configures that specific rule to require it). AI, NFC, QR, location and photo verification are explicitly excluded from V1.
- **Rationale:** Founder decision, formalising OQ-06's recommended default into a named data-model field.
- **Date:** 2026-09-28
- **Supersedes:** OQ-06's informal recommendation is now a Confirmed, named model concept (Verification Type) to be carried into `10_RULE_ENGINE_SPECIFICATION.md` and `19_DATA_MODEL.md`.

**DEC-17. Hero mechanic framing.**
- **Status:** Confirmed
- **Decision:** Deadline Lock remains the primary/hero mechanic, but it must NOT be marketed or documented as unique — competitors already implement variants of it (see DEC-02's rationale note re: taskr). The differentiation claim rests on: visible family agreements, child/teen negotiation, requests and exceptions, respectful teen UX, reliable enforcement, school/essential access protection, and privacy-first design.
- **Rationale:** Founder decision, directly reinforcing the caveat already recorded in DEC-02.
- **Date:** 2026-09-28
- **Supersedes:** Tightens DEC-02; no longer just a rationale note but an explicit constraint on future marketing/documentation copy.

**DEC-18. School Mode — capability honesty requirement.**
- **Status:** Confirmed
- **Decision:** School Mode is a first-class V1 requirement, built from parent-configured Always Allowed apps, Always Allowed websites, a school access list, and temporary educational access requests. The product must NOT claim it can automatically determine whether content inside an app (e.g. YouTube) is educational or entertainment — this technical limitation must be stated explicitly wherever School Mode is described.
- **Rationale:** Founder decision, directly resolving OQ-08's recommended default into a binding documentation requirement.
- **Date:** 2026-09-28
- **Supersedes:** OQ-08's "Recommended default" is now Confirmed.

**DEC-19. Reporting scope.**
- **Status:** Confirmed
- **Decision:** V1 reporting is lightweight and privacy-first: rules met/missed, tasks submitted/approved/rejected, extra-time requests and outcomes, overrides, enforcement/protection failures, and high-level category usage ONLY where technically supported. No detailed browsing-history surveillance. No assumption that detailed child-device app usage can be remotely displayed on the parent's device until the Apple technical spike proves it.
- **Rationale:** Founder decision, directly confirming DEC-07 and OQ-09's cautious default.
- **Date:** 2026-09-28
- **Supersedes:** Confirms DEC-07 and closes OQ-09 with a bounded, explicit V1 reporting field list.

**DEC-20. Pricing.**
- **Status:** Confirmed as a process rule (pricing itself remains an open product-validation item, not fixed)
- **Decision:** Final pricing is not locked. Hypotheses to test: £6.99/month, a possibly higher family price pending research, and an annual equivalent. Pricing uncertainty must not block Phase 2 requirements work.
- **Rationale:** Founder decision.
- **Date:** 2026-09-28
- **Supersedes:** Reaffirms OQ-11's existing "treat as testable hypothesis" framing; no number is newly fixed.

**DEC-21. Repository.**
- **Status:** Confirmed
- **Decision:** The project's GitHub repository is `Kydosdigital/themis-family`. All specification documents live under `/docs` in that repository. The Phase 1 baseline (as amended by DEC-11 through DEC-20) is committed before Phase 2 work begins.
- **Rationale:** Founder decision/instruction.
- **Date:** 2026-09-28
- **Supersedes:** N/A

---

## Decisions still required from the founder before Phase 2 begins

None outstanding from the original priority list — OQ-01 through OQ-04 and OQ-06 are resolved above (DEC-12 through DEC-16). Remaining open items (OQ-05, OQ-07, OQ-09, OQ-10, OQ-12) are research/technical-spike or Phase-3-appropriate items and do not block Phase 2 per `34_OPEN_QUESTIONS.md`.

---

## DEC-22. Process decision: all major product decisions committed to GitHub, not just conversation history.
- **Status:** Confirmed
- **Decision:** From 2026-09-28 onward, every major product decision is committed to the `Kydosdigital/themis-family` repository under `/docs`, in addition to (not instead of) being discussed with the founder. The repository is the durable source of truth; conversation history is not relied upon as the record.
- **Rationale:** Founder instruction, given directly.
- **Date:** 2026-09-28
- **Supersedes:** N/A — reinforces DEC-21.

---

## Founder decisions received 2026-09-28 (Phase 2 review — amendments before Phase 3)

**DEC-23. Launch region — resolves OQ-13.**
- **Status:** Confirmed
- **Decision:** V1 launches UK-first: UK English, GBP, UK-focused onboarding/research/support assumptions. This is a launch/validation decision, not a permanent geographic restriction — the architecture must not unnecessarily prevent later international expansion.
- **Rationale:** Founder decision.
- **Date:** 2026-09-28
- **Supersedes:** OQ-13's "Recommended default" is now Confirmed, with the explicit instruction that this is a launch choice, not an architectural constraint.

**DEC-24. Child vs. Teen assignment method — resolves OQ-15.**
- **Status:** Confirmed
- **Decision:** The app does NOT collect a precise child date of birth to determine UX segment. During child setup, the parent explicitly selects "Child experience" or "Teen experience," with copy along the lines of: *"Choose the experience that best fits your child. You can change this later."* The approximate bands (Child ~8–12, Teen ~13–15) remain guidance, not enforced legal or scientific classifications. The parent can change the segment later without account deletion/recreation.
- **Rationale:** Founder decision; matches data-minimisation privacy principle already adopted.
- **Date:** 2026-09-28
- **Supersedes:** Confirms OQ-15's recommended default; formalises the "changeable later" property and the exact suggested copy.

**DEC-25. Onboarding working-rule requirement elevated to Must, with a two-stage completion model — resolves OQ-16.**
- **Status:** Confirmed
- **Decision:** HLR-020 is changed from "Should" to "Must." The product must distinguish **Account Creation Complete** (household and members created) from **Themis Protection Activated** (child-device authorisation valid, at least one rule target selected, a real test shield applied, the test shield successfully removed, and the resulting state verified by the app). The parent sees an explicit incomplete-setup state until Protection Activated is achieved — the product must never imply protection is active before all five conditions are met.
- **Rationale:** Founder decision. If working-rule verification is genuinely release-blocking (per RISK-08), it must not be documented as optional.
- **Date:** 2026-09-28
- **Supersedes:** HLR-020 in `05_HIGH_LEVEL_REQUIREMENTS.md` (Should → Must); closes OQ-16.

**DEC-26. Canonical Child persona device assumption corrected — shared-device support out of V1 without validation.**
- **Status:** Confirmed
- **Decision:** The Child persona (Aisha) is corrected from "uses a shared family iPad" to "uses an iPad signed into her own Child Apple Account within the family's Family Sharing group." Shared-device scenarios (one iPad shared by siblings; parent and child sharing one iPad; a device signed into a parent's Apple Account; a device signed into one child's account but used by multiple children) are NOT established as V1 requirements and require separate technical research/spike before any commitment. Per-child enforcement on a shared Apple Account/device must not be promised until proven possible.
- **Rationale:** Founder correction — the original persona silently assumed device-sharing behaviour that has not been technically validated against Apple's Family Controls model, which is scoped per child Apple Account.
- **Date:** 2026-09-28
- **Supersedes:** `03_PERSONAS.md` §3.4 (Aisha's device description).

**DEC-27. Protection status must reflect confirmation recency, not implied real-time state.**
- **Status:** Confirmed
- **Decision:** HLR-013 is corrected: the system does not "continuously assess" enforcement health in a real-time sense; it reports the most recently confirmed state and must never imply real-time protection when the device has not recently checked in. Minimum V1 states are expanded to: **Protected, Sync Pending, Device Offline, Needs Attention, Protection Unavailable**, with a "Last verified: [time]" indicator shown where appropriate. A stale last-known-good state must not continue to display as Protected indefinitely. Exact staleness thresholds are deferred to the Device Enforcement specification (Phase 5).
- **Rationale:** Founder decision. Central to the reliability positioning (DEC-08); an implied-real-time status that is actually stale would directly contradict that positioning.
- **Date:** 2026-09-28
- **Supersedes:** HLR-013 in `05_HIGH_LEVEL_REQUIREMENTS.md`; extends the status set first described in the Phase 1 brief and `00_PRODUCT_OVERVIEW.md`.

**DEC-28. Automatic Verification narrowed to deterministic system evidence only.**
- **Status:** Confirmed
- **Decision:** Automatic Verification is redefined as: *"Themis has deterministic system evidence that the configured condition completed"* — e.g. an in-app timer or in-app focus session successfully completing. It must not be described or implied to prove a real-world activity occurred (e.g. "a 15-minute reading timer completed" is verifiable; "the child read for 15 minutes" is not). This distinction carries into Phase 3's rule engine and task/approval specifications.
- **Rationale:** Founder correction — the original wording risked overstating what the system actually knows.
- **Date:** 2026-09-28
- **Supersedes:** Narrows DEC-16's definition of Automatic Verification; affects HLR-006 and the wording of `04_USER_JOURNEYS.md` §4.7.

**DEC-29. Request "ask a follow-up question" constrained — not a messaging feature.**
- **Status:** Confirmed
- **Decision:** HLR-009's approver action "ask a follow-up question" is constrained to a lightweight, request-scoped clarification mechanism (attached to the specific pending request), not unrestricted parent/child messaging or a chat system. Phase 3 must define the simplest viable interaction (e.g. a single structured clarification prompt and a single structured reply, not a free-form open-ended thread).
- **Rationale:** Founder decision, forestalling scope creep into a messaging feature the brief explicitly does not want (privacy principles rule out building message-content features).
- **Date:** 2026-09-28
- **Supersedes:** Narrows HLR-009's phrasing in `05_HIGH_LEVEL_REQUIREMENTS.md`.

**DEC-30. Temporary access must expire locally, independent of backend/network availability.**
- **Status:** Confirmed
- **Decision:** All temporary access grants (temporary access, extra time, Free Pass) must expire on the child device using locally cached expiry data and automatically reapply the appropriate restriction, even if the backend is unavailable, the parent device is offline, or push notifications fail. Re-locking must never depend on a second server-sent instruction arriving at expiry time.
- **Rationale:** Founder decision, extending the existing local-first enforcement principle (brief §"Local-first enforcement") to explicitly cover the expiry direction, not just the initial-lock direction.
- **Date:** 2026-09-28
- **Supersedes:** Extends HLR-014 in `05_HIGH_LEVEL_REQUIREMENTS.md`.

**DEC-31. Documentation language must not assert unverified Apple platform behaviour as fact.**
- **Status:** Confirmed
- **Decision:** Wherever a document describes a specific Apple/iOS behaviour as if it were confirmed fact (e.g. "an iOS update invalidated Family Controls authorisation"), it must instead be phrased as a scenario the product responds to (e.g. "if authorisation becomes unavailable following an OS update or other system event..."), unless Apple's own documentation explicitly guarantees that exact behaviour. Requirements describe Themis Family's response to a failure state, without asserting an unverified cause.
- **Rationale:** Founder correction — avoids the documentation quietly overstating certainty about third-party platform behaviour that has not been verified via the technical spike.
- **Date:** 2026-09-28
- **Supersedes:** Corrects wording in `04_USER_JOURNEYS.md` §4.6 and any similarly-phrased passages found elsewhere.

---

## Decisions still required from the founder before Phase 3 begins

None. Phase 2 is approved subject to the amendments above (DEC-23 through DEC-31), which are being applied to the affected documents in this same commit round. Phase 3 (Functional Requirements, Rule Engine Specification, Task and Approval Specification, Requests and Exceptions Specification, School and Essential Access, Roles and Permissions) proceeds next.

---

## Phase 3 completion note (2026-09-28)

Phase 3 produced `06_FUNCTIONAL_REQUIREMENTS.md`, `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, and `18_ROLES_AND_PERMISSIONS.md`. No user stories and no production code were written, per the founder's explicit Phase 3 instruction.

**End-of-Phase-3 cross-check (per founder instruction) — findings:**

- **FR → HLR traceability:** Every FR defined in Phase 3 (FR-001 through FR-054) traces to a specific HLR. No orphan FRs were found. Full index in `06_FUNCTIONAL_REQUIREMENTS.md` §6.2.
- **HLRs not yet decomposed into FRs:** HLR-012 (Website control) is only partially decomposed (folded into Rule Engine's Controlled Targets concept, no dedicated FR). HLR-013 (Protection status) has no dedicated FR beyond its role as a precondition in FR-006/FR-008 — full specification is correctly deferred to `16_DEVICE_ENFORCEMENT.md` (Phase 5), as the founder's own Phase 3 document list did not include a device-enforcement document. HLR-015 (Reporting), HLR-016 (Privacy), HLR-017 (Subscriptions), and HLR-019 (Age-segmented experience) are correctly deferred to Phase 5/6 documents also absent from the Phase 3 list — this is scope-as-planned, not a gap. See `06_FUNCTIONAL_REQUIREMENTS.md` §6.2/§6.4 for the full breakdown.
- **Contradictions found across the five new documents:** None identified that required rework. One internal tension is flagged rather than silently resolved: BR-211 (`10_RULE_ENGINE_SPECIFICATION.md`) proposes Scheduled Rule outranking Deadline Lock and Earn First in conflict precedence; this is explicitly marked as an unapproved, weakest-justified hypothesis (see OQ-23) rather than a settled rule, and must not be treated as final by Phase 5.
- **Cross-cutting rules formalised:** Two business rules already established in single documents (BR-221's capability-honesty requirement, DEC-31's platform-honesty requirement) are restated in `06_FUNCTIONAL_REQUIREMENTS.md` §6.3 as BR-224/BR-225 — general rules applying to all documentation from Phase 3 onward, not confined to the document that first introduced them.

**Items requiring founder sign-off before Phase 4/5 treat them as final (not decided unilaterally in Phase 3):**

- **BR-211 (rule conflict precedence order)** — `10_RULE_ENGINE_SPECIFICATION.md`. Positions 4–6 (Scheduled Rule vs. Deadline Lock vs. Earn First) are the weakest-justified part of the proposal (OQ-05, OQ-23).
- **BR-219 (Free Pass default scope)** — `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`. Recommends mandatory explicit scope selection, no unscoped default (OQ-27).
- **OQ-18's resolution via FR-042** — the bounded clarification mechanism (one prompt, one reply) is fully specified but not yet founder-confirmed as final before Phase 4 acceptance criteria are written.
- **OQ-24 (Automatic Verification timer backgrounding behaviour)** — recommends pause-on-background, not yet confirmed.
- **OQ-28 (exact essential-access minimum set)** — recommends Phone/emergency calling only as the hard-coded floor, not yet confirmed.

None of the above block Phase 4 from starting (they are all flagged, bounded RECOMMENDATIONs, not silent decisions), but they should be confirmed or amended by the founder before Phase 5's state machines and data model treat them as fixed.

**Date:** 2026-09-28
**Supersedes:** N/A — this is a phase-completion record, not a decision reversal.

---

## Decisions still required from the founder before Phase 4 begins

None outstanding that block starting Phase 4 (User Stories and Acceptance Criteria). The five items listed in the Phase 3 completion note above should be confirmed before Phase 5 (Data Model, State Machines) treats them as final, but Phase 4 may proceed against the Phase 3 documents as written.
