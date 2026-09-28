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

## RISK-11: Privacy complaint or regulatory issue (UK ICO Children's Code, COPPA if US expansion occurs) — mitigation sharpened, Phase 6 founder review round, 2026-09-28
- **Likelihood:** Low-Medium
- **Impact:** Critical — this is a child-data product
- **Mitigation, sharpened this round:** the original mitigation's reference to "privacy-by-design principles already adopted" risked implying that data-minimisation design work alone satisfies the lawful-basis question. It does not — data minimisation and lawful basis are separate legal concerns. **Corrected mitigation:** DPIA before launch; specialist legal review; the required **Lawful Basis Matrix** (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.4a, DEC-52), covering every processing purpose with a documented (not assumed) lawful basis, necessity, and retention; specific UK requirements around consent, age, and parental authorisation for an information society service offered directly to a child, assessed as part of that legal review rather than presumed satisfied by the parent being the account holder; privacy-by-design principles (no message reading, no browsing diary, category-specific bounded retention per §23.5/DEC-59) as a complementary, not substitute, mitigation.
- **Owner:** Founder + legal counsel (external)
- **Validation method:** Completed DPIA; legal sign-off on the Lawful Basis Matrix specifically, not merely on the product's data-minimisation design

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

## RISK-17: Shared-device assumption mismatch (siblings/parent sharing one iPad)
- **Likelihood:** Medium (a common UK household pattern, not yet validated against Apple's per-child-account model)
- **Impact:** High — if parents expect shared-device enforcement to work and it doesn't, this directly damages the reliability positioning
- **Mitigation:** V1 canonical assumption is one device per child Apple Account (DEC-26); explicitly exclude shared-device scenarios from V1 marketing and onboarding claims; research/spike separately per OQ-17 before any commitment.
- **Owner:** Product/Technical lead
- **Validation method:** Technical spike against Apple's Family Controls documentation and real multi-child households; App Store review/support ticket monitoring post-launch for shared-device complaints

## RISK-18: Protection status implies more certainty than the system actually has
- **Likelihood:** Medium
- **Impact:** High — directly undermines the reliability/trust brand positioning (DEC-08) if a stale state is shown as "Protected"
- **Mitigation:** DEC-27's expanded status set (Protected / Sync Pending / Device Offline / Needs Attention / Protection Unavailable) plus a "Last verified" timestamp; exact staleness thresholds to be defined in Phase 5 (`16_DEVICE_ENFORCEMENT.md`, tracked as OQ-19).
- **Owner:** Product/Technical lead
- **Validation method:** Explicit test scenarios forcing a device to go quiet and confirming the UI downgrades from Protected within the defined threshold

## RISK-19: Rule conflict precedence order ships unresolved or wrong (BR-211) — RESOLVED 2026-09-28
- **Likelihood:** Medium (as originally assessed)
- **Impact:** High — an incorrect precedence order produces a confusing or unfair enforcement outcome in a visible, recurring scenario (e.g. bedtime vs. an unresolved homework deadline)
- **Resolution:** DEC-32 replaced the linear precedence hierarchy with an effective-enforcement model (no rule type outranks another; a target stays restricted while any active rule still covers it), removing the underlying ambiguity rather than picking an order. Residual risk is now only in correct implementation of the model, tracked as ordinary engineering risk, not a product-decision risk.
- **Owner:** Product/Founder
- **Validation method:** Scenario walkthrough sign-off (complete, DEC-32's worked example); implementation correctness to be verified by Phase 7 test strategy

## RISK-20: Free Pass granted with an unintentionally broad scope — RESOLVED 2026-09-28
- **Likelihood:** Low-Medium (as originally assessed)
- **Impact:** Medium — an unscoped Free Pass could unlock more than the parent intended, undermining trust in a "reliable enforcement" product
- **Resolution:** DEC-33 confirmed BR-219 as final: explicit target/scope and duration are always required (preset or custom), with the specific overridden rule(s) disclosed before confirmation. No unscoped default exists.
- **Owner:** Product
- **Validation method:** UX review of the Free Pass creation flow in Phase 5/6 design work, confirming the confirmation-step disclosure is implemented as specified

## RISK-21: Automatic Verification evidence standard undermined by timer backgrounding behaviour — RESOLVED 2026-09-28
- **Likelihood:** Medium (as originally assessed)
- **Impact:** Medium-High — if a timer counts time while the app is backgrounded or the device is locked, "the timer completed" stops being deterministic evidence of anything (directly weakens DEC-28/BR-209's capability-honesty standard)
- **Resolution:** DEC-37 replaced the single universal rule with two Session Types with opposite, individually-correct backgrounding behaviour (Active Engagement Session pauses; Focus Session may continue). Each has its own truthful completion statement. Residual risk: OQ-29 (Focus Session violation handling) remains open but is a narrower, bounded question, not a capability-honesty risk.
- **Owner:** Technical lead
- **Validation method:** Device testing of both Session Types' backgrounding behaviour in Phase 5

## RISK-22: Non-configurable essential-access minimum set is too narrow or too broad — PARTIALLY RESOLVED 2026-09-28
- **Likelihood:** Low-Medium (as originally assessed)
- **Impact:** Medium — too narrow relies entirely on correct parent configuration for basic safety functionality; too broad removes parental choice and risks an overreach perception
- **Resolution:** DEC-35 confirmed the product policy (hard safety principle: emergency calling/OS-level emergency functionality never deliberately restricted; Phone/Messages/Maps recommended default Always Allowed set). The product-policy dimension of this risk is resolved. A narrower technical risk remains: whether Apple's picker/ManagedSettings actually support this for Phone/Messages/Maps as assumed — tracked as OQ-30, not a product-decision risk.
- **Owner:** Product/Founder (policy — resolved); Technical lead (remaining technical validation — open)
- **Validation method:** Apple technical spike confirming picker/ManagedSettings behaviour for the named apps, before `24_SECURITY_REQUIREMENTS.md` (Phase 6) finalises any "cannot be restricted" wording

## RISK-23: Deadline Lock pending-approval loophole (identified and RESOLVED in the same review, 2026-09-28)
- **Likelihood:** High — this was not a rare edge case but a straightforward, obvious exploit of the original BR-207 wording (tap "Done" moments before the deadline, without genuinely completing the task, and enforcement never activates while a parent hasn't yet responded)
- **Impact:** High — directly undermines the entire Deadline Lock mechanic, which is the product's hero mechanic (DEC-02/DEC-17); if trivially bypassable, it damages the reliability positioning (DEC-08) as badly as an enforcement bug would
- **Resolution:** DEC-40 replaced the original indefinite-pending behaviour with a bounded 30-minute Provisional Approval Grace Period: the shield activates automatically if the grace period expires with no decision, closing the loophole while still giving a genuinely on-time child a fair, bounded window.
- **Owner:** Product/Founder
- **Validation method:** Scenario testing confirming the shield activates exactly at grace-period expiry when no decision has been made, and that a genuinely on-time, promptly-approved submission never triggers a shield

## RISK-24: Split-custody / separated-parent households not supported in V1
- **Likelihood:** Medium (a common enough family structure that it will surface in support requests, though not assessed as a V1 launch blocker)
- **Impact:** Medium — a separated family cannot share one rule set across two households in V1; this is now an explicit, confirmed limitation (DEC-45) rather than an accidental gap, but it may still generate support friction or lost customers if not communicated clearly at signup
- **Mitigation:** DEC-45 confirms this is a stated V1 limitation, not a bug: each parent needs their own separate household with no shared rule set. Onboarding/marketing copy should set this expectation honestly rather than let a separated parent discover the limitation after signing up. Revisit post-V1 if demand is significant.
- **Owner:** Product
- **Validation method:** Review onboarding copy for honesty on this point before launch; monitor support tickets post-launch for split-custody requests

## RISK-25: Offline connectivity gap can cause an on-time task submission to be recorded as late through no fault of the child — mitigation revised (amendment round, 2026-09-28)
- **Likelihood:** Medium — dependent on real-world connectivity patterns (poor signal, airplane mode, school Wi-Fi restrictions) rather than any product defect
- **Impact:** Medium-High — directly undermines fairness in the Deadline Lock mechanic (the product's hero mechanic, DEC-02/DEC-17) in a way that is functionally similar to RISK-23's exploit concern but in the opposite direction — a genuinely compliant child penalised by connectivity rather than a non-compliant child evading enforcement
- **Source:** Identified during Phase 5 offline/sync architecture work: device-local wall-clock time cannot be trusted alone for automatic grace-period decisions (related to, but distinct from, OQ-32's device-clock-tampering concern), so a submission that is genuinely on-time by the device's local clock but delayed in transit past the 30-minute grace window by an offline gap risked being treated as unresolved/late by a purely server-received-time-based automatic system.
- **Mitigation, revised this amendment round (CONFIRMED, supersedes the original "surface both timestamps" recommendation):** `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7a now specifies a **trusted-time model**: at every successful sync the device records a trusted-time anchor (server timestamp paired with the device's monotonic clock, which cannot be altered by the user); while offline, elapsed real-world time is estimated from the monotonic clock's advance rather than the editable wall clock alone. A submission with strong trustworthy-timing evidence placing it genuinely within the deadline/grace window is **reconciled as on-time automatically**, even if it physically arrives late. A submission where trustworthy timing cannot be established is neither silently auto-credited nor silently penalised — it is surfaced to the parent as **"Timing could not be verified"** for an explicit decision. This is a stronger mitigation than the original "just show both timestamps to a human" recommendation, since it can resolve the common honest case automatically while still degrading safely to human judgement for the ambiguous case.
- **Residual risk / spike dependency:** the monotonic-clock approach's reliability across app backgrounding, device suspension, and device reboot is itself unverified (a reboot may reset a monotonic reference point) and is now an explicit real-device spike item (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7a, `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8 Priority 6 covers the related clock/timezone tampering scenarios). Until validated, the escalate-to-parent fallback path is the safety net.
- **Owner:** Product/Founder (mechanism confirmed; real-device validation still required before Phase 6/7 build treats it as final)
- **Validation method:** Scenario testing simulating an offline gap that spans a Deadline Lock's grace period, including a device reboot during the gap, confirming the trusted-time reconciliation behaves as specified and the "Timing could not be verified" escalation fires correctly when it cannot

## RISK-26: Monotonic-clock manipulation on a compromised device could defeat the trusted-time model — NEW, Phase 6, 2026-09-28
- **Likelihood:** Low-Medium — requires a jailbroken or otherwise compromised device, which is a smaller population than ordinary offline-connectivity gaps (RISK-25), but not negligible given the product's core function invites circumvention attempts (RISK-05)
- **Impact:** Medium — if defeatable, a child could falsify timing evidence to have a late submission auto-reconciled as on-time, undermining the same Deadline Lock fairness guarantee that RISK-25's mitigation was designed to protect, though in the opposite direction (false on-time claim rather than unfair late marking)
- **Source:** Identified in `24_SECURITY_REQUIREMENTS.md` §24.6 as SEC-016, a threat without a fully specified control, flagged as the reverse gap in the Phase 6 end-of-phase security cross-check; tracked as OQ-40 in `34_OPEN_QUESTIONS.md`, related to OQ-32 (device clock/timezone tampering, already a Priority 6 real-device spike item per `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.8)
- **Mitigation (not yet specified — this is the open item):** no control can be specified without real-device research into how resistant iOS's monotonic clock (`mach_absolute_time`/`ProcessInfo.systemUptime` or equivalent) actually is to manipulation on a compromised device, and what detection signals (if any) are available to the app. Until that research exists, the trusted-time model's existing degrade-safely behaviour (RISK-25's "Timing could not be verified" escalation to the parent) remains the only backstop — it does not prevent falsification but ensures ambiguous cases still reach human judgement rather than being silently auto-credited.
- **Owner:** Engineering/Security (pending real-device spike; no control owner assigned until findings exist)
- **Validation method:** Real-device spike on a jailbroken/compromised test device attempting to falsify monotonic-clock readings during an offline gap, assessing whether the trusted-time reconciliation can be tricked into crediting a late submission as on-time

---

## Register maintenance note

This register must be revisited at the end of every phase per the brief's own process requirement ("after each phase: review your own work, identify contradictions, update the Open Questions document, update the Decision Log"). New risks identified in Phases 2–7 (e.g. specific data-model or state-machine risks) should be appended here with continuing IDs (RISK-16 onward).
