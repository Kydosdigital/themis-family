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

## Decisions still required from the founder before Phase 3 begins

Phase 2 (Personas, User Journeys, Scope and Release Strategy, High-Level Requirements) is complete as of this commit. Per the founder's own process instruction, work stops here for review. No decisions are strictly blocking, but the founder may wish to weigh in on the new open questions raised during Phase 2 (OQ-13 through OQ-16 in `34_OPEN_QUESTIONS.md`) before Phase 3 (Functional Requirements, Business Rules, Rule Engine Specification, Roles and Permissions) begins.
