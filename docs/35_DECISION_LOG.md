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

## Founder decisions received 2026-09-28 (Phase 3 review — amendments before Phase 4)

**DEC-32. Rule conflict resolution replaced with an effective-enforcement model — resolves OQ-05, OQ-23.**
- **Status:** Confirmed
- **Decision:** BR-211's linear rule-type precedence (Scheduled Rule > Deadline Lock > Earn First) is withdrawn. Instead: Essential/Always Allowed is evaluated first and absolutely; explicit parent overrides/grants apply only to the scope they explicitly name; after overrides are applied, a target remains restricted if any other active blocking rule still covers it; no rule type inherently outranks another, and completing one rule's condition never implies access returns if a different active rule still restricts the same target. Worked example: a bedtime Scheduled Rule and an overdue-homework Deadline Lock both restrict Roblox; completing homework clears the Deadline Lock restriction but Roblox stays blocked by bedtime; the UI must not say "Games unlocked."
- **Rationale:** Founder decision. The withdrawn linear model would have produced incorrect and potentially unsafe enforcement outcomes (e.g. a completed task appearing to unlock an app still meant to be restricted by a separate rule).
- **Date:** 2026-09-28
- **Supersedes:** `10_RULE_ENGINE_SPECIFICATION.md` BR-211/FR-018 (rewritten); adds FR-019/BR-226 (child-facing multi-rule status communication). Closes OQ-05 and OQ-23.

**DEC-33. Free Pass scope confirmed — resolves OQ-27.**
- **Status:** Confirmed
- **Decision:** A Free Pass has no silent or unscoped blanket default. The parent must always explicitly select target/scope and duration, whether via a one-tap preset (e.g. "Games — 30 minutes," "YouTube — 20 minutes," "All entertainment — 30 minutes") or a custom selection. Before confirmation, the app must state which active rule(s) the Free Pass will temporarily override. Expiry occurs locally and the normal effective enforcement state resumes automatically.
- **Rationale:** Founder decision, confirming the Phase 3 recommendation as final.
- **Date:** 2026-09-28
- **Supersedes:** `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` BR-219 (now Confirmed, with presets and pre-confirmation rule disclosure added). Closes OQ-27.

**DEC-34. Request clarification mechanism approved as final — resolves OQ-18.**
- **Status:** Confirmed
- **Decision:** FR-042/BR-218 is approved exactly as specified: V1 supports exactly one clarification prompt from the parent/guardian and one reply from the child/teen, after which the approver must approve, partially approve, or decline. No open-ended messaging thread; the interaction exists only inside the specific request.
- **Rationale:** Founder decision, confirming the Phase 3 specification as final.
- **Date:** 2026-09-28
- **Supersedes:** Closes OQ-18 (previously specified but not confirmed).

**DEC-35. Essential access hard safety principle confirmed, split from the technical-validation question — resolves OQ-28 at the product-policy level.**
- **Status:** Confirmed
- **Decision:** Themis Family must never intentionally interfere with emergency communication or OS-level emergency functionality — this is a hard, unconditional product policy for V1, confirmed independently of any technical finding. The recommended default Always Allowed set, where technically supported, is Phone, Messages, and Maps; Messages and Maps are strongly recommended and pre-selected but remain parent-configurable. The product must not claim a specific system app is technically impossible to shield until the Apple technical spike verifies that behaviour — an unverified API assumption must not become a stated requirement.
- **Rationale:** Founder decision. Separates a policy commitment (which can be made now) from a technical fact (which cannot be asserted until verified), avoiding both an unsafe policy gap and an overstated technical claim.
- **Date:** 2026-09-28
- **Supersedes:** `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` BR-222 (rewritten). OQ-28 is closed at the product-policy level; the remaining technical question is tracked as new OQ-30.

**DEC-36. Scheduled Rule time zone behaviour confirmed — resolves OQ-22.**
- **Status:** Confirmed
- **Decision:** Scheduled rules follow the child device's current local time zone (not a fixed home-zone offset). A time-zone change must not silently create an ambiguous rule state. V1 does not build home-vs-travel time zone configuration. Phase 5 must define time-zone-change detection, schedule recalculation, local persistence, and a parent-facing indication where the change is material.
- **Rationale:** Founder decision, confirming the Phase 3 recommendation, with explicit Phase 5 technical scope attached.
- **Date:** 2026-09-28
- **Supersedes:** `10_RULE_ENGINE_SPECIFICATION.md` BR-205 (now Confirmed). Closes OQ-22, subject to the named Phase 5 technical implementation detail.

**DEC-37. Automatic Verification split into two Session Types — resolves OQ-24.**
- **Status:** Confirmed
- **Decision:** A single universal backgrounding rule cannot correctly serve every Automatic Verification use case. V1 formalises exactly two Session Types: **Active Engagement Session** (e.g. in-app reading — pauses on backgrounding/device lock, resumes on foreground return, backgrounded time never counted; truthful statement: "15-minute in-app reading session completed," never "child definitely read for 15 minutes") and **Focus Session** (staying away from configured distracting apps — may continue while Themis is backgrounded or the device is locked, since that is compatible with the intended behaviour; invalidated only by opening a specifically-restricted app during the window; truthful statement: "30-minute focus session completed under the configured restrictions," never "30 minutes of homework completed").
- **Rationale:** Founder decision. The two use cases have opposite correct backgrounding behaviour, so one shared rule was structurally wrong, not merely underspecified.
- **Date:** 2026-09-28
- **Supersedes:** `11_TASK_AND_APPROVAL_SPECIFICATION.md` FR-033 (rewritten); adds §11.1a (BR-227, BR-228). Updates the general wording of DEC-28/BR-209 in `10_RULE_ENGINE_SPECIFICATION.md` §10.5 to cross-reference the two Session Type-specific evidence statements. Closes OQ-24. Raises new OQ-29 (Focus Session violation handling).

**DEC-38. Rejection note confirmed optional — resolves OQ-25.**
- **Status:** Confirmed
- **Decision:** When a parent rejects a task completion as "Needs work," a note is optional; the UI should strongly encourage a short explanation via a prominent field, but the note is never mandatory, and it does not create an open-ended conversation thread.
- **Rationale:** Founder decision, confirming the Phase 3 recommendation as final.
- **Date:** 2026-09-28
- **Supersedes:** Closes OQ-25.

**DEC-39. Request expiry replaced with a context-based model — resolves OQ-26.**
- **Status:** Confirmed
- **Decision:** A request does not use one arbitrary expiry duration. It expires when it can no longer meaningfully affect its underlying rule/context, with a maximum pending lifetime of 4 hours as a backstop only (used when the underlying context does not itself end sooner). Every request record carries `created_at`, `expires_at`, and a context/rule reference. If the underlying rule/target is deleted or materially changed while the request is Pending, the request expires immediately if its context reference no longer resolves. Phase 4 acceptance criteria must cover: parent acts before expiry; parent acts exactly around expiry; request expires while devices are offline; late approval attempt; underlying rule deleted/changed; request becomes irrelevant before the 4-hour backstop.
- **Rationale:** Founder decision. A flat expiry window (e.g. always 4 hours) could let an already-irrelevant request linger, or expire a still-relevant one too early; tying expiry to the underlying context avoids both failure modes.
- **Date:** 2026-09-28
- **Supersedes:** `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` FR-043 (rewritten); adds BR-229. Closes OQ-26.

---

## Decisions still required from the founder before Phase 4 begins

None. All items flagged in the Phase 3 completion note above (BR-211, BR-219, FR-042/OQ-18, OQ-24, OQ-28) are now resolved by DEC-32 through DEC-39. Two new, narrower open questions were raised by these same decisions (OQ-29: Focus Session violation handling; OQ-30: technical validation of Apple's picker/ManagedSettings support for Phone/Messages/Maps) — neither blocks Phase 4; both are tracked in `34_OPEN_QUESTIONS.md` against the Phase 5 documents they affect. Phase 4 (Epics and User Stories, Acceptance Criteria) proceeds next.

---

## Phase 4 completion note (2026-09-28)

Phase 4 produced `08_EPICS_AND_USER_STORIES.md` (seven epics, grouping every Phase 3 FR/BR into user stories tracing HLR → FR/BR → User Story) and `09_ACCEPTANCE_CRITERIA.md` (Given/When/Then acceptance criteria per story). No production code was written.

**Documentation approach flagged, not silently decided:** Owner and Guardian share identical permissions for every action except the Owner-only administrative set (§18.2). Rather than duplicating every shared-action story under both role tags, `08_EPICS_AND_USER_STORIES.md` writes them once as US-OWNER-### with an explicit "(Guardian: identical)" note, and gives Guardian its own story ID only where behaviour genuinely differs (e.g. US-GUARDIAN-001, accepting an invitation). This is recorded as a RECOMMENDATION in the document itself, not assumed silently.

**End-of-Phase-4 cross-check (per founder instruction) — findings, full detail in `09_ACCEPTANCE_CRITERIA.md` §9.6:**

- **FRs without a user story:** None, with two explicitly-noted exceptions: FR-001 is folded into US-OWNER-001 rather than duplicated, and pure System-actor infrastructure FRs (e.g. FR-017) are represented by their observable-consequence story rather than a story with no independent human want/benefit.
- **Stories not backed by an FR:** None — every story traces to a specific HLR and FR/BR pairing.
- **Acceptance criteria depending on unresolved questions:** Four identified and explicitly flagged (not silently assumed): US-CHILD-006 AC1 (OQ-04a, reminder interval), US-CHILD-008 AC3 (OQ-29, Focus Session violation handling), US-CHILD-014 AC3 (OQ-30, Apple picker/ManagedSettings validation), US-OWNER-024 AC2 (OQ-20, Owner-exit-with-no-Guardian path). Each AC is written to hold under either resolution of its open question, so none block Phase 5.
- **Missing negative/failure scenarios:** None found beyond one accepted, explicitly-noted exception (US-CHILD-003, Earn First — its failure modes are already covered by the task-approval stories in Epic C rather than needing a duplicate).
- **Contradictions:** None — Phase 4 was built directly on the fully-amended, founder-approved Phase 3 baseline.

No new Open Questions, Risks, or Decisions were required by this cross-check beyond what Phase 3 already tracks (OQ-04a, OQ-20, OQ-29, OQ-30 all pre-exist Phase 4 and are simply cross-referenced here, not newly raised).

**Date:** 2026-09-28
**Supersedes:** N/A — phase-completion record.

---

## Decisions still required from the founder before Phase 5 begins

None outstanding that block Phase 5 (Data Model, State Machines, Backend/API Requirements, Apple Integration Requirements, Device Enforcement, Offline/Sync Behaviour) from starting, once the founder reviews and approves Phase 4. The four AC-level dependencies noted in the Phase 4 completion note above (OQ-04a, OQ-20, OQ-29, OQ-30) should be resolved before the specific Phase 5 documents they affect are finalised, per the "Blocks" column already recorded for each in `34_OPEN_QUESTIONS.md`.

---

## Founder decisions received 2026-09-28 (Phase 4 review — amendments before Phase 5)

**DEC-40. Deadline Lock loophole closed with a Provisional Approval Grace Period — supersedes the original pending-approval behaviour.**
- **Status:** Confirmed
- **Decision:** The original rule (a shield never applies while a pre-deadline submission remains pending) allowed a loophole: a child could tap "Done" immediately before a deadline without genuinely completing the task, and avoid the Deadline Lock indefinitely pending a parent's response. Replaced with: task submitted before the deadline → status "Submitted On Time, Awaiting Approval"; at the deadline, a 30-minute Approval Grace Period begins during which targets remain available; approval within the grace period → no lock ever occurs; rejection within the grace period → lock activates immediately; grace period expires unresolved → lock activates and remains active until subsequently approved (at which point BR-211's effective-enforcement model applies if another rule still restricts the target). Essential/Always Allowed/School access unaffected throughout. Child-facing copy must not frame the grace period as a punishment for submitting on time.
- **Rationale:** Founder decision, closing a genuine correctness/fairness gap identified during Phase 4 review — the original rule's unbounded nature was a real exploitable loophole, not merely a UX nicety.
- **Date:** 2026-09-28
- **Supersedes:** `10_RULE_ENGINE_SPECIFICATION.md` BR-207/FR-014 (rewritten); `11_TASK_AND_APPROVAL_SPECIFICATION.md` FR-030/FR-031 (updated to reference the grace period); `08_EPICS_AND_USER_STORIES.md`/`09_ACCEPTANCE_CRITERIA.md` US-CHILD-002 (rewritten).

**DEC-41. Approval reminder interval confirmed — resolves OQ-04a.**
- **Status:** Confirmed
- **Decision:** Immediate notification on submission (task or request); exactly one automatic reminder at 15 minutes if still unresolved (does not repeat); the child/teen may separately send exactly one manual nudge per pending item, entirely independent of the automatic reminder (using the nudge does not reset or delay the automatic schedule, and vice versa); after both have fired, no further reminder notifications are sent for that item, though it remains visibly pending.
- **Rationale:** Founder decision, confirming a fixed, non-escalating interval and clarifying that the two reminder mechanisms (automatic, manual) are independent rather than one resetting the other.
- **Date:** 2026-09-28
- **Supersedes:** `11_TASK_AND_APPROVAL_SPECIFICATION.md` FR-032/BR-213 (interval fixed at 15 minutes, independence clarified); adds `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` BR-230 (applying the identical policy to requests, since the founder's decision named "task/request" together). Closes OQ-04a.

**DEC-42. Focus Session violation handling confirmed — resolves OQ-29.**
- **Status:** Confirmed
- **Decision:** A Focus Session represents one continuous successful period of avoiding its configured restricted apps. Opening a restricted app during an active session marks that attempt **Interrupted**: the attempt ends immediately, no completion credit is awarded, and accumulated time does not carry over. The child may start a fresh attempt immediately with no cooldown. Child-facing copy must be neutral (e.g. "Focus session interrupted. Start again when you're ready.") and must never use "Failed," "You broke the rule," or other shame-oriented wording. Configurable grace behaviour is explicitly deferred as a FUTURE FEATURE; V1 stays deterministic and simple.
- **Rationale:** Founder decision, prioritising a simple, predictable V1 behaviour and explicit non-punitive framing over a more forgiving but more complex pause-and-flag alternative.
- **Date:** 2026-09-28
- **Supersedes:** `11_TASK_AND_APPROVAL_SPECIFICATION.md` §11.1a/FR-033 (adds BR-231); `08_EPICS_AND_USER_STORIES.md`/`09_ACCEPTANCE_CRITERIA.md` US-CHILD-008 (rewritten). Closes OQ-29.

**DEC-43. Active Engagement Session termination handling replaced with a persist-and-verify model.**
- **Status:** Confirmed
- **Decision:** The original "force-quit resets the session, no partial credit" rule is replaced: a child must not lose legitimate progress solely because iOS terminates the app, the app crashes, memory pressure closes it, or the device restarts. While a session runs, Themis persists the last trustworthy accumulated foreground duration locally. On reopening: if the persisted state's integrity can be verified, the child is offered Resume from that exact duration; if it cannot be verified, the session is marked Interrupted with a clear, non-blaming explanation. No wall-clock time elapsed while the app was not running is ever counted toward completion, under either path. Phase 5 must define the exact local persistence mechanism and integrity-verification model.
- **Rationale:** Founder decision. A flat reset on any termination punishes a child for events entirely outside their control (an OS-initiated termination, a crash, memory pressure), which is inconsistent with the product's "agreement, not punishment" positioning.
- **Date:** 2026-09-28
- **Supersedes:** `11_TASK_AND_APPROVAL_SPECIFICATION.md` §11.1a/FR-033 (adds BR-232); `08_EPICS_AND_USER_STORIES.md`/`09_ACCEPTANCE_CRITERIA.md` US-CHILD-007 (rewritten).

**DEC-44. Emergency story wording corrected to avoid overstating the confirmed requirement.**
- **Status:** Confirmed
- **Decision:** US-CHILD-014's original wording ("Trust that I can always reach emergency help and my parents") overstated what has actually been confirmed. The story is renamed and narrowed to: "As a child or teen, I want Themis never to deliberately prevent emergency communication, so that digital-boundary rules do not interfere with getting urgent help." Phone/Messages/Maps remain the recommended default Always Allowed set where technically supported (BR-222, DEC-35), but a guarantee that every specific route to a parent works under every Apple configuration is not yet confirmed and remains gated by OQ-30.
- **Rationale:** Founder correction. The original wording implied a broader technical guarantee (reaching a parent specifically) than the confirmed product policy (never deliberately restricting emergency functionality) actually supports.
- **Date:** 2026-09-28
- **Supersedes:** `08_EPICS_AND_USER_STORIES.md`/`09_ACCEPTANCE_CRITERIA.md` US-CHILD-014 (renamed and rewritten). OQ-30 remains open, unaffected by this rename.

**DEC-45. Owner exit path confirmed for V1 — resolves OQ-20.**
- **Status:** Confirmed
- **Decision:** A household must always have exactly one Owner. If an Owner wants to leave, V1 supports exactly two paths: (A) invite/retain a Guardian, transfer ownership to them, then leave; or (B) delete the household. V1 explicitly does not support: an ownerless household in any state; ownership transfer directly to a Child/Teen; combining an invite and a transfer into one simultaneous action; or multiple households representing a split-custody arrangement (each parent needs their own separate household, with no shared rule set between them in V1).
- **Rationale:** Founder decision. Confirms the existing recommended default as final, with the four explicit non-support items named so they are not later mistaken for oversights.
- **Date:** 2026-09-28
- **Supersedes:** `18_ROLES_AND_PERMISSIONS.md` BR-101 (rewritten as confirmed/final); `08_EPICS_AND_USER_STORIES.md`/`09_ACCEPTANCE_CRITERIA.md` US-OWNER-024 (rewritten). Closes OQ-20.

---

## Phase 4 amendment completion note (2026-09-28)

Applies DEC-40 through DEC-45 across `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `18_ROLES_AND_PERMISSIONS.md`, `08_EPICS_AND_USER_STORIES.md`, and `09_ACCEPTANCE_CRITERIA.md`. The re-run HLR → FR/BR → Story → Acceptance Criteria cross-check (full detail in `09_ACCEPTANCE_CRITERIA.md` §9.7) found no new orphan FRs, no new unbacked stories, and no new contradictions. Three of the four previously-flagged AC-level dependencies are now resolved (OQ-04a, OQ-29, OQ-20); the fourth (OQ-30, Apple technical validation) remains genuinely open and does not block Phase 5, since the relevant AC (US-CHILD-014 AC3) is written to hold under either eventual resolution.

**Date:** 2026-09-28
**Supersedes:** N/A — phase-completion record.

---

## Decisions still required from the founder before Phase 5 begins (updated)

None. All six items from the founder's Phase 4 review are now Confirmed (DEC-40 through DEC-45). Only OQ-30 (Apple picker/ManagedSettings technical validation) remains genuinely open among items surfaced so far, and it is explicitly a technical-spike output, not a product decision — it does not block Phase 5 from starting, though `27_APPLE_INTEGRATION_REQUIREMENTS.md` must classify it honestly per the founder's Phase 5 four-status capability rule. Phase 5 (Device Enforcement, Offline/Sync Behaviour, Data Model, State Machines, Apple Integration Requirements, API/Backend Requirements) proceeds next.

---

## Phase 5 completion note (2026-09-28)

Phase 5 produced six documents: `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`. `27_APPLE_INTEGRATION_REQUIREMENTS.md` was written first and grounds the rest, since it establishes which Apple platform capabilities may be assumed (VERIFIED), which must wait for a real-device spike (NEEDS REAL-DEVICE TECHNICAL SPIKE), and which remain genuinely unknown (UNKNOWN), per the founder's explicit Phase 5 rule against turning assumptions into architecture.

**Material findings requiring founder attention before this baseline is treated as final:**

1. **Correction to an earlier claim (not yet applied to the source document, pending founder confirmation).** `10_RULE_ENGINE_SPECIFICATION.md` FR-010 currently states the ~50-app/50-domain shield limit is "Apple's documented ManagedSettings limits." Phase 5 research (official Apple documentation plus a developer forum thread cited in `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.3/§27.6) found this limit is **not documented by Apple at all** — it is a community-reported, undocumented behaviour. **Recommended correction:** amend FR-010's wording to "an undocumented behaviour reported by developers (~50 tokens per shield property), to be confirmed via real-device spike," removing the word "documented." This correction is not applied automatically in this round, since editing an already-approved Phase 3 document without explicit founder sign-off would itself breach the standing process; the founder should confirm this correction explicitly, after which it will be applied with its own commit.
2. **OQ-09 materially advanced.** Official Apple documentation confirms cross-device usage reporting is natively supported by `DeviceActivityReport`, but the report extension's sandbox permanently prevents any usage data from reaching Themis Family's own backend. This is a hard architectural ceiling, not a policy choice, and should inform Phase 6's `22_REPORTING_AND_ANALYTICS.md` scope directly.
3. **OQ-30 remains genuinely unresolved** (whether Phone/Messages/Maps can be excluded from a shield at all) and is the single highest-priority item for the eventual real-device technical spike, given its direct bearing on BR-222's hard safety principle.
4. **New open questions raised (OQ-31 through OQ-37, `34_OPEN_QUESTIONS.md`)** cover: on-device vs backend-computed shield resolution; device clock tampering resilience; subscription-lapse enforcement behaviour; late offline-session outcome handling; early Free Pass revocation; abandoned Active Engagement Session resume handling; and API-level abuse protection against the child as a sometimes-adversarial party. None of these block Phase 5 sign-off; each is scoped to the specific later document it affects.
5. **New risk (RISK-25, `33_PRODUCT_RISK_REGISTER.md`):** an offline connectivity gap can cause a genuinely on-time task submission to be recorded as late, since the automated Provisional Approval Grace Period (DEC-40) must key off server-received time, not device-local time (the latter being untrusted per the device-clock-tampering concern, OQ-32). A transparency mitigation (surfacing both timestamps to the human approver) is recommended but not yet founder-confirmed.
6. **State-machine and race-condition cross-check (full detail in `20_STATE_MACHINES.md` §20.11 and `29_API_AND_BACKEND_REQUIREMENTS.md` §29.9):** no confirmed Phase 3/4 requirement was found lacking a state representation. Three transitions were identified as reasonable but not yet backed by any confirmed requirement (Free Pass early revocation, OQ-35; abandoned Active-Engagement-Session resume handling, OQ-36; the Subscription `InGrace` state, OQ-33) and are flagged rather than assumed. The primary backend race condition (concurrent approvals) is resolved via an atomic version-increment mechanism (`16_DEVICE_ENFORCEMENT.md` §16.7, `29_API_AND_BACKEND_REQUIREMENTS.md` §29.4); a second, newly identified race (a scheduled expiry job firing at the same instant as a manual approval) is resolved by the same mechanism (§29.9 item 3).

No Phase 3 or Phase 4 document was edited during Phase 5 beyond the tracking documents (`33_PRODUCT_RISK_REGISTER.md`, `34_OPEN_QUESTIONS.md`, this log, and `README.md`) — the FR-010 correction above is deliberately left pending rather than silently applied.

**Date:** 2026-09-28
**Supersedes:** N/A — phase-completion record.

---

## Decisions still required from the founder before Phase 6 begins

1. Confirm (or reject) the FR-010 correction described above, so it can be applied to `10_RULE_ENGINE_SPECIFICATION.md` with its own commit.
2. Confirm or revise the 72-hour device-staleness threshold proposed in `16_DEVICE_ENFORCEMENT.md` §16.8 (OQ-19).
3. Confirm whether an Owner/Guardian can revoke an active Free Pass early (OQ-35), whether an abandoned Active Engagement Session should fall back to `Pending`/expire (OQ-36), and whether the on-device-resolution-primary approach to shield computation (OQ-31) is acceptable, or whether backend-side computation should be pursued despite its limited latency benefit.
4. Commission the real-device technical spike covering, at minimum and in priority order: (a) whether Phone/Messages/Maps can be excluded from a `ManagedSettingsStore` shield at all (OQ-30); (b) the ~50-token shield limit; (c) shield persistence across force-quit/restart/uninstall; (d) `DeviceActivityMonitor` callback timing precision; (e) device-clock-tampering resilience (OQ-32); (f) extension memory-constraint behaviour under load.

None of the above block Phase 6 from starting on the founder's authority, per the same working-unattended principle applied in earlier phases, but each should be resolved before the Phase 5 architecture they touch is treated as final for build sequencing (Phase 7).

---

## DEC-46 through DEC-50 — Phase 5 founder review round (2026-09-28)

The founder independently re-checked current Apple documentation following the Phase 5 baseline and directed the following corrections and confirmations before Phase 6 begins.

**DEC-46 — FR-010 / 50-item shield limit correction (supersedes the Phase 5 completion note's proposed correction above, item 1).**
- **Status:** Confirmed and applied.
- **Decision:** The Phase 5 completion note's proposed correction (recharacterising the ~50-item limit as wholly undocumented) is itself withdrawn as incorrect. Direct re-verification against Apple's current developer documentation found four separate, exactly-documented per-property limits: `ShieldSettings.applications` (50 application tokens), `ShieldSettings.webDomains` (50 web-domain tokens), `ShieldSettings.applicationCategories` (50 category tokens + 50 exceptions), `ShieldSettings.webDomainCategories` (50 category tokens + 50 exceptions) — each VERIFIED FROM APPLE DOCUMENTATION with direct citation. Only the *failure behaviour when a limit is exceeded* remains NEEDS REAL-DEVICE TECHNICAL SPIKE. `10_RULE_ENGINE_SPECIFICATION.md` FR-010 is corrected accordingly (§10.8 amendment note), and `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.3/§27.6/§27.7 and `16_DEVICE_ENFORCEMENT.md` §16.5 are updated to match.
- **Rationale:** A community forum report's framing ("undocumented") was taken at face value in the original Phase 5 pass without a fresh direct check of Apple's current published API reference; the founder's own re-check found the documentation does exist. This is exactly the kind of correction the standing DEC-31 discipline exists to catch, applied against the documentation itself rather than against a secondary characterisation of it.
- **Date:** 2026-09-28. **Supersedes:** the FR-010 correction proposed in the Phase 5 completion note above (item 1).

**DEC-47 — Shield-resolution authority model, closes OQ-31.**
- **Status:** Confirmed.
- **Decision:** Backend is authoritative for shared business state (rules, approvals, requests, grants, membership, subscription); the child device is authoritative for immediate device-enforcement execution and generates its own Local Enforcement Plan (renamed from "Resolved Shield List," and materially extended — see below) from the latest synced business-state snapshot. The backend never attempts to become a runtime shield engine. Push notifications are a latency optimisation only, never the sole correctness mechanism.
- **Also confirmed, same review:** the "Resolved Shield List" concept is replaced by the richer **Local Enforcement Plan**, which precomputes not just the current shield state but every currently-knowable upcoming transition and its resulting shield operation, so the `DeviceActivityMonitor` extension can execute a scheduled transition correctly without the main app open or the network reachable at that moment. Applied throughout `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`.
- **Also confirmed, same review:** end-to-end remote approval → child-device unlock propagation is elevated to **Priority 1** on the real-device spike list (second only to entitlement approval itself), and the parent-facing UI must distinguish "Approved" (backend-committed) from "Applied on [child]'s device" (confirmed in effect) wherever those are not guaranteed simultaneous — this is now a confirmed UI-copy requirement, not a caveat (`16_DEVICE_ENFORCEMENT.md` §16.6a).
- **Date:** 2026-09-28. **Supersedes:** OQ-31's open status in `34_OPEN_QUESTIONS.md`.

**DEC-48 — Early Temporary Access Grant (Free Pass) revocation, closes OQ-35.**
- **Status:** Confirmed.
- **Decision:** An Owner or Guardian may revoke an active Free Pass/Temporary Access Grant early. The grant moves to `Revoked` via the same atomic approval-handling mechanism as any other approval-type action; the backend increments `resolution_version`; the revocation is pushed/synchronised to the child device; the child device recomputes its Local Enforcement Plan and the original rule state resumes. Parent UI must not claim "Access revoked on device" until the child device has acknowledged/applied the new resolution — it shows "Revocation sent" then "Access revoked" once confirmed.
- **Date:** 2026-09-28. **Supersedes:** OQ-35's open status.

**DEC-49 — Abandoned Active Engagement Session handling, closes OQ-36.**
- **Status:** Confirmed.
- **Decision:** A session in `TerminatedPendingResume` remains resumable until the earlier of the linked task/context's own expiry or 24 hours from the last trustworthy session checkpoint. If not resumed by then, the session becomes `Abandoned`: no completion credit is awarded, persisted partial time is retained only as historical/debug information per Phase 6's retention policy, and the child may start a fresh session if the underlying task/context remains valid. No indefinite `InSession` state exists in V1.
- **Date:** 2026-09-28. **Supersedes:** OQ-36's open status.

**DEC-50 — Child-side API abuse protection, closes OQ-37 at the policy level.**
- **Status:** Confirmed at the product-policy level; exact controls deferred to Phase 6.
- **Decision:** Yes, the backend must treat the child client as potentially adversarial for enforcement-related endpoints — framed as ordinary defensive system design, not an accusation of malicious intent. Phase 6's `24_SECURITY_REQUIREMENTS.md` must specify rate limiting, idempotency/duplicate suppression, one-active-request-per-context limits, server-side role/ownership validation, request-size limits, replay protection, audit logging, and notification-flooding protection.
- **Date:** 2026-09-28. **Supersedes:** OQ-37's open status (policy question); exact controls remain to be specified in Phase 6.

**Also confirmed in this review round, not requiring a standalone numbered decision (each already reflected in the amended documents):**
- The Family Controls "App and Website Usage" capability is identified as `AuthorizationStatus.approvedWithDataAccess`, confirmed EU-device/EU-Apple-Account-only for customer installations, and therefore confirmed **not usable in UK V1** — closes OQ-10 (see `34_OPEN_QUESTIONS.md`).
- The Themis-owned vs. Apple-owned reporting-data separation is restated precisely and made binding on Phase 6's `22_REPORTING_AND_ANALYTICS.md` (`27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.5).
- The device-staleness threshold (OQ-19) is explicitly **not** fixed at this stage — the founder withdrew the originally-proposed 72-hour figure and requires it to be server-configurable, set only after real-device heartbeat/background-sync measurement.
- Subscription-lapse enforcement behaviour (OQ-33) is explicitly carried forward into Phase 6 rather than finalised in Phase 5, subject to the confirmed safety principle that no lapse may leave a child indefinitely locked.
- A trusted-time model (monotonic-clock-anchored, reconciled against server-received time) replaces the original "server-received-time-only" mechanic for evaluating offline, time-sensitive submissions (RISK-25 revised; addresses OQ-34 by analogy) — `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7a.
- The real-device technical spike priority list is revised to: Priority 0 entitlement approval; Priority 1 remote-approval/unlock propagation; Priority 2 Phone/Messages/Maps shielding (OQ-30); Priority 3 `DeviceActivityMonitor` scheduled-transition reliability while terminated/locked; Priority 4 exceeded-limit behaviour for the now-documented 50-item caps; Priority 5 shield persistence across termination/reboot/uninstall; Priority 6 device clock/timezone tampering; Priority 7 extension memory behaviour with realistic Local Enforcement Plan sizes; Priority 8 cross-device `DeviceActivityReport` rendering (`27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8).

## Phase 5 amendment completion note (2026-09-28)

Applies DEC-46 through DEC-50 across `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, `19_DATA_MODEL.md`, `20_STATE_MACHINES.md`, `29_API_AND_BACKEND_REQUIREMENTS.md`, and `10_RULE_ENGINE_SPECIFICATION.md` (FR-010 correction, applied directly per DEC-46, superseding the "flag but don't apply" approach of the original Phase 5 completion note). The re-run architecture/state/data cross-check found: no new orphan requirements; the three previously-flagged unconfirmed state transitions (OQ-31, OQ-35, OQ-36) are now all confirmed; OQ-33 remains explicitly deferred to Phase 6 by founder instruction, not by oversight; OQ-09/OQ-10's reporting-model findings are now precisely restated and bound on Phase 6's reporting document; and RISK-25's mitigation is materially strengthened via the trusted-time model. OQ-19, OQ-30, OQ-32, and OQ-34 (pending spike validation) remain genuinely open and are carried forward with clear ownership (real-device spike, in priority order) rather than left ambiguous.

**Date:** 2026-09-28
**Supersedes:** The original Phase 5 completion note's item 1 (FR-010 correction proposal) and its framing of OQ-31/OQ-35/OQ-36/OQ-10 as unresolved.

---

## Decisions still required from the founder before Phase 6 begins (updated)

None outstanding that block Phase 6 from starting. The founder has confirmed all amendment items from this review round (DEC-46 through DEC-50). Phase 6 (Non-Functional Requirements, Reporting and Analytics, Privacy and Child Safety, Security Requirements, Subscriptions and Billing, Admin and Support) proceeds next, carrying forward: the UK-only App and Website Usage limitation (into `22_REPORTING_AND_ANALYTICS.md`); the never-indefinitely-locked subscription-lapse principle (into `25_SUBSCRIPTIONS_AND_BILLING.md`); and the child-as-potentially-adversarial API design principle (into `24_SECURITY_REQUIREMENTS.md`).

---

## DEC-51 — Subscription-lapse enforcement model, closes OQ-33

- **Status:** Confirmed (Phase 6 draft; grace-window length not yet founder-confirmed, see below).
- **Decision:** A three-state subscription enforcement model is adopted: `Active` (normal enforcement) → `BillingRetry` (enforcement continues unchanged; parent warned) → `Lapsed` (enforcement continues through a defined, communicated grace window) → `RestrictionsCleared` (restrictions actively removed once the grace window expires with no payment). Rule definitions are never deleted by a lapse, so enforcement resumes automatically if payment resumes at any point. This directly implements the founder's confirmed safety principle: a child is never left indefinitely locked because a subscription expired and the parent can no longer manage the rules.
- **Not yet confirmed:** the exact grace-window length (7 days proposed as a RECOMMENDATION only) and whether a partial/reduced-enforcement middle state should exist instead of the binary full-enforcement/then-cleared model. Both are explicitly flagged in `25_SUBSCRIPTIONS_AND_BILLING.md` §25.3 as open, not decided by default.
- **Rationale:** the alternative (indefinite enforcement with a lapsed subscription and no parental control path) was explicitly considered and rejected as worse than a clearly-communicated, bounded protection stop, per the founder's own stated principle.
- **Date:** 2026-09-28. **Supersedes:** OQ-33's "carried forward, not finalised" status — the state model is now finalised; only the numeric grace-window length remains open.

## Phase 6 completion note (2026-09-28)

Phase 6 produced six documents: `07_NON_FUNCTIONAL_REQUIREMENTS.md`, `22_REPORTING_AND_ANALYTICS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md`, `24_SECURITY_REQUIREMENTS.md`, `25_SUBSCRIPTIONS_AND_BILLING.md`, `30_ADMIN_AND_SUPPORT.md`. No production code was written.

**End-of-Phase-6 cross-check findings (per the founder's explicit instructions):**

1. **Privacy data with no purpose:** none identified. Every field specified in `23_PRIVACY_AND_CHILD_SAFETY.md` §23.3 traces to a confirmed Phase 3–5 feature; no speculative data collection was introduced.
2. **Security controls with no threat:** none identified (`24_SECURITY_REQUIREMENTS.md` §24.6). One reverse gap was found instead — a threat without a full identified control: **SEC-016**, the trusted-time model's dependence on an unmanipulated device monotonic clock, which a compromised/jailbroken device could potentially defeat. Recorded as a NEEDS REAL-DEVICE TECHNICAL SPIKE item (related to OQ-32), not papered over with an invented control.
3. **Metrics requiring prohibited/unavailable child data:** the one class identified is anything requiring `approvedWithDataAccess`-level non-tokenised data (raw bundle IDs, visited domains), which is explicitly excluded from V1 scope by `22_REPORTING_AND_ANALYTICS.md` §22.1/§22.4, not silently designed around.
4. **Subscription states that could leave a child unexpectedly locked:** the `RestrictionsCleared` transition (DEC-51) is the direct, confirmed answer — no state in the finalised Subscription machine results in indefinite enforcement without a current subscription.
5. **Support/admin capability exposing more child data than necessary:** identified and corrected. `30_ADMIN_AND_SUPPORT.md` §30.4 rejects a general "view any household's full data" admin tool in favour of scenario-scoped support views, since the original engineering-convenience assumption would have exposed materially more child data than any actual support scenario requires.
6. **NFRs without measurable targets:** `07_NON_FUNCTIONAL_REQUIREMENTS.md` §7.7 lists four — local shield-application latency (NFR-001), remote-unlock propagation time (NFR-002, deliberately unfixed per the founder's own instruction not to claim "instant unlock" before the spike), foreground-correction-pass execution time (NFR-004), and specific availability/capacity numbers (NFR-005/NFR-007, pending Phase 7 infrastructure decisions). None are invented numbers; all are tied to a specific spike or later-phase activity that will make them measurable.

**New open items raised this phase (added to `34_OPEN_QUESTIONS.md`):** OQ-38 (subscription grace-window length), OQ-39 (partial/reduced-enforcement middle state during lapse), OQ-40 (SEC-016, monotonic-clock manipulation resilience), OQ-41 (safeguarding escalation process detail, `30_ADMIN_AND_SUPPORT.md` §30.5, deferred as an operational-policy item outside this technical specification's scope).

**Date:** 2026-09-28
**Supersedes:** N/A — phase-completion record.

---

## Decisions still required from the founder before Phase 7 begins

1. Confirm or revise the proposed 7-day subscription grace-window length (OQ-38), and decide whether a partial/reduced-enforcement middle state is wanted instead of the binary model in `25_SUBSCRIPTIONS_AND_BILLING.md` (OQ-39).
2. Confirm the retention windows flagged as RECOMMENDATIONs in `23_PRIVACY_AND_CHILD_SAFETY.md` §23.5 (audit log retention, abandoned-session partial-data purge).
3. Commission or confirm ownership of the safeguarding escalation process (`30_ADMIN_AND_SUPPORT.md` §30.5), which this specification deliberately does not design in full, being an operational/policy matter rather than a technical one.
4. Continue to own the real-device technical spike commissioning from the Phase 5 amendment round, now also covering SEC-016 (monotonic-clock manipulation resilience, OQ-40) alongside the existing priority list.

None of the above block Phase 7 from starting on the founder's authority, per the same working-unattended principle applied in earlier phases, but each should be resolved before the Phase 6 architecture they touch is treated as final for build sequencing (Phase 7 itself).
