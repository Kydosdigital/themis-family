# 33. Product Risk Register — Themis Family

**Status:** Phase 1, amended 2026-09-28 — will be extended in later phases as technical, security and privacy detail firms up.

Format: ID | Risk | Likelihood | Impact | Mitigation | Owner | Validation method

---

## RISK-01: Apple Family Controls entitlement rejected or delayed
- **Likelihood:** Medium
- **Impact:** Critical — the entire product depends on this capability
- **Mitigation:** Apply for the entitlement immediately, before any further UI/backend investment. Build the smallest possible technical spike (select app → shield → unlock) in parallel with the application.
- **Owner:** Founder / technical lead
- **Validation method:** Entitlement approval email from Apple; spike running on a real parent/child device pair

## RISK-02: App Store review rejection (Kids Category ambiguity, or Family Controls misuse flag)
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Do not submit to the Kids Category (see `28_...` open question). Prepare a clear reviewer note explaining the parental-control use case. Budget review-cycle time into launch schedule.
- **Owner:** Founder
- **Validation method:** Successful App Store approval on first or second submission

## RISK-03: Screen Time API limitations prevent a promised feature from working as designed
- **Likelihood:** Medium-High
- **Impact:** High (reputational — a promised-but-broken feature is worse than not offering it)
- **Mitigation:** Technical spike before UI build (see `37_BUILD_SEQUENCE.md`, later phase). Do not write marketing or onboarding copy promising behaviour not yet verified on-device.
- **Owner:** Technical lead
- **Validation method:** Spike results checked against every claim in `10_RULE_ENGINE_SPECIFICATION.md` and `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`

## RISK-04: iOS update breaks existing enforcement behaviour
- **Likelihood:** Medium (recurring, ongoing — not a one-off)
- **Impact:** High, recurring
- **Mitigation:** Protection-status system must detect and surface breakage rather than silently failing (see AC4 in the original brief). Monitor Apple developer betas ahead of public iOS releases.
- **Owner:** Technical lead
- **Validation method:** Regression test suite run against each iOS beta

## RISK-05: Child/teen circumvention (device reset, alternate browser, secondary device, sign-out attempts)
- **Likelihood:** High (this is normal teenage behaviour, not a defect)
- **Impact:** Medium — damages perceived reliability if not anticipated in messaging
- **Mitigation:** Do not market as "unhackable." Show honest protection status. Product philosophy (agreement, not punishment) reduces motivation to circumvent, but does not eliminate it.
- **Owner:** Product
- **Validation method:** User testing with real teens; review-monitoring post-launch

## RISK-06: Child/teen resentment or disengagement undermines the "agreement not punishment" positioning
- **Likelihood:** Medium
- **Impact:** High — this is the core differentiator; if it fails, the product is just another blocker
- **Mitigation:** Teen-specific UX testing before launch (not just parent testing). Negotiation/request flow must feel real, not cosmetic.
- **Owner:** Product/Design
- **Validation method:** Qualitative interviews with teens during and after pilot

## RISK-07: Approval delays (parent unavailable) make Deadline Lock feel punitive rather than fair
- **Likelihood:** High
- **Impact:** Medium-High
- **Mitigation:** Explicit policy required for parent-non-response (see `11_TASK_AND_APPROVAL_SPECIFICATION.md`, later phase) — e.g., auto-reminder, defined maximum wait, honest "waiting for approval" state shown to child.
- **Owner:** Product
- **Validation method:** Defined in acceptance criteria; tested with simulated delayed-approval scenarios

## RISK-08: Family Sharing / onboarding abandonment
- **Likelihood:** High (named by competitor "Earn Time" as their whole differentiator)
- **Impact:** High — this is the top-of-funnel drop-off point
- **Mitigation:** Onboarding must be tested for time-to-first-working-rule; consider whether Apple's Family Sharing requirement can be explained better, sequenced better, or (later) whether a "no Family Sharing" mode is viable within Apple's rules.
- **Owner:** Product/Design
- **Validation method:** Onboarding completion-rate tracking; usability testing

## RISK-09: School/education app conflict (App or site is both educational and distracting — e.g. YouTube, Safari, Chrome)
- **Likelihood:** High — this is a certainty, not a possibility
- **Impact:** High — directly damages trust (a child unable to do homework)
- **Mitigation:** School Mode must be designed with explicit handling for ambiguous apps (see `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, later phase); time-boxed temporary educational access requests as a release-blocking feature, not a nice-to-have.
- **Owner:** Product
- **Validation method:** Scenario testing against real UK school platforms (Google Classroom, Teams, SIMS, Satchel/Show My Homework, etc. — TECHNICAL DEPENDENCY: exact list not yet confirmed, see Open Questions)

## RISK-10: Offline/sync failures create unsafe or confusing enforcement states
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Local-first enforcement architecture (already a stated principle in the brief); explicit state machine for every offline scenario (Phase 5).
- **Owner:** Technical lead
- **Validation method:** Offline test scenarios in `31_TEST_STRATEGY.md` (later phase)

## RISK-11: Privacy complaint or regulatory issue (UK ICO Children's Code, COPPA if US expansion occurs)
- **Likelihood:** Low-Medium
- **Impact:** Critical — this is a child-data product
- **Mitigation:** DPIA before launch; specialist legal review; privacy-by-design principles already adopted in brief (no message reading, no browsing diary, minimal retention).
- **Owner:** Founder + legal counsel (external)
- **Validation method:** Completed DPIA; legal sign-off

## RISK-12: Subscription churn after novelty decay
- **Likelihood:** Medium-High (named pattern across chore/habit apps generally)
- **Impact:** Medium
- **Mitigation:** Review-date mechanic and evolving agreements are a partial answer; retention hypothesis should be tested explicitly, not assumed. Not a V1 blocker but should inform V1 analytics (are rules being actively maintained at week 4?).
- **Owner:** Product
- **Validation method:** Cohort retention tracking post-launch

## RISK-13: Competitor copying (taskr, Earn Time, etc. add negotiation/agreement features)
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Reliability and trust are harder to copy than a feature list; lean into that as the durable moat, not the rule catalogue.
- **Owner:** Product/Founder
- **Validation method:** Ongoing competitive monitoring

## RISK-14: Android fragmentation delays or degrades the eventual Android release
- **Likelihood:** High (structural, not a mistake to be avoided)
- **Impact:** Low for V1 (Android explicitly out of scope), Medium-High if Android is promised prematurely
- **Mitigation:** Do not commit publicly to an Android date until iOS is validated. Keep backend/rule model platform-agnostic per brief's own guidance.
- **Owner:** Product/Founder
- **Validation method:** N/A for V1; revisit at Android planning stage

## RISK-15: Support cost exceeds plan due to enforcement/approval edge cases
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Comprehensive error-state catalogue (Phase 7) and honest protection-status UI intended to deflect "is this broken?" contacts.
- **Owner:** Product/Support
- **Validation method:** Support ticket volume and category tracking post-launch

## RISK-16: Two-guardian simultaneous-approval race condition
- **Likelihood:** Low-Medium
- **Impact:** Medium — a mis-handled race could double-grant or silently drop an approval, undermining the "first valid decision wins" rule (DEC-14)
- **Mitigation:** Enforce the rule with an atomic conditional state transition at the data layer (not just in application logic), per OQ-03a in `34_OPEN_QUESTIONS.md`. Must be specified formally in Phase 5's state machines.
- **Owner:** Technical lead
- **Validation method:** Concurrency test simulating both guardians responding within the same second

---

## Register maintenance note

This register must be revisited at the end of every phase per the brief's own process requirement ("after each phase: review your own work, identify contradictions, update the Open Questions document, update the Decision Log"). New risks identified in Phases 2–7 (e.g. specific data-model or state-machine risks) should be appended here with continuing IDs (RISK-16 onward).
