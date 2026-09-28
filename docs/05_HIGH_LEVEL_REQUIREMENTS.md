# 05. High-Level Requirements

**Status:** Phase 2 draft
**Depends on:** `00_PRODUCT_OVERVIEW.md`, `02_SCOPE_AND_RELEASE_STRATEGY.md`, `03_PERSONAS.md`, `04_USER_JOURNEYS.md`

Each requirement has an ID (HLR-###), is traceable to a decision or brief section, and will be decomposed into functional requirements (FR-###) in Phase 3. This is deliberately high-level; implementation detail belongs in later documents.

---

## HLR-001. Household and membership management
The system shall allow a Household Owner to create a household, add one or more children (each assigned a Child or Teen UX segment), and invite up to one additional Guardian.
- **Source:** DEC-12, DEC-14
- **Priority:** Must

## HLR-002. Role-based permissions
The system shall enforce distinct permissions for Owner, Guardian, Teen and Child, with the Owner exclusively able to manage subscription, delete the household, remove the Guardian, and transfer ownership.
- **Source:** DEC-14
- **Priority:** Must

## HLR-003. Device authorisation
The system shall guide a parent/guardian through Apple Family Sharing and Family Controls authorisation for each child device, and shall verify successful authorisation before allowing rule creation for that device.
- **Source:** Brief §"Parent onboarding", TECHNICAL DEPENDENCY (Apple entitlement)
- **Priority:** Must

## HLR-004. Rule creation and targeting
The system shall allow a parent/guardian to create rules targeting specific apps, websites, or categories, using Apple's privacy-preserving selection mechanism.
- **Source:** Brief §"What can be controlled"
- **Priority:** Must

## HLR-005. Rule types
The system shall support, at minimum, Scheduled Rule, Deadline Lock, and Earn First rule types in V1.
- **Source:** DEC-01, brief §"Core Rule Types"
- **Priority:** Must

## HLR-006. Verification Type
The system shall require every task/condition to declare a Verification Type of either Parent Approval or Automatic Verification, and shall only permit Automatic Verification for system-verifiable conditions (timers, focus sessions).
- **Source:** DEC-16
- **Priority:** Must

## HLR-007. Approval workflow
The system shall support task submission by a child, notify all eligible approvers (Owner and Guardian), and apply the decision of whichever eligible approver responds first for a given pending request.
- **Source:** DEC-14, brief §"Approval System"
- **Priority:** Must

## HLR-008. Non-response handling
The system shall never automatically unlock a restriction solely due to elapsed time without an approval decision. The system shall notify approvers, issue one reminder after a defined interval, and permit the child exactly one manual nudge per pending request.
- **Source:** DEC-15
- **Priority:** Must

## HLR-009. Requests and negotiation
The system shall allow a child/teen to submit a request for extra time, a deadline extension, temporary app/website access, or an exception, with a stated reason, and shall allow an approver to approve (with a specific duration), partially approve, decline, or ask a follow-up question.
- **Source:** Brief §"Requests and Negotiation System"
- **Priority:** Must

## HLR-010. Always Allowed / essential access
The system shall allow a parent/guardian to designate apps and websites as Always Allowed, which remain available regardless of any other active restriction.
- **Source:** Brief §"Essential Access", DEC-18
- **Priority:** Must

## HLR-011. School Mode with stated limitation
The system shall provide a School Mode built from Always Allowed apps/sites, a configurable school access list, and time-boxed temporary educational access requests. The system's documentation and in-product copy shall not claim the ability to classify content within an app as educational versus entertainment.
- **Source:** DEC-18
- **Priority:** Must

## HLR-012. Website control
The system shall support blocking specific domains and website categories, in combination with app-level rules, subject to Apple's ManagedSettings capabilities and limits.
- **Source:** Brief §"Website Controls", DEC-04
- **Priority:** Must

## HLR-013. Protection status
The system shall continuously assess and display enforcement health per child device, distinguishing at minimum: Protected, Needs Attention, and Protection Unavailable, and shall never display a reassuring status without a verified basis for it.
- **Source:** Brief AC4, DEC-08
- **Priority:** Must

## HLR-014. Offline-first enforcement
The system shall cache active rules locally on each child device such that enforcement continues during a backend outage, and shall never silently remove a restriction due to loss of connectivity.
- **Source:** Brief §"Local-first enforcement", DEC-15 (analogous safety principle)
- **Priority:** Must

## HLR-015. Reporting
The system shall provide a parent-facing report scoped to: rules met/missed, task and request outcomes, overrides, and enforcement/protection failures. Category-level usage reporting shall be included only if confirmed technically feasible via the Apple integration spike.
- **Source:** DEC-19
- **Priority:** Must (core fields) / Should (category usage, pending spike)

## HLR-016. Privacy by design
The system shall not read message content, record calls, continuously track location by default, or construct a detailed browsing-history diary visible to parents.
- **Source:** DEC-06
- **Priority:** Must

## HLR-017. Subscription management
The system shall support a family subscription with a free trial, monthly and annual billing, and shall never allow a subscription state change to silently create an unsafe or ambiguous enforcement state.
- **Source:** DEC-20, brief §"Subscriptions"
- **Priority:** Must

## HLR-018. No overstated capability
The system's marketing, onboarding copy, and in-product language shall not claim the product is "unhackable" or "impossible to bypass," and shall not claim capabilities not verified via the technical spike.
- **Source:** DEC-05, DEC-17
- **Priority:** Must

## HLR-019. Age-segmented experience
The system shall present a materially simpler, more visual interface to Child-segment users and a more autonomous, negotiation-oriented interface to Teen-segment users, while sharing the same underlying rule engine.
- **Source:** DEC-12
- **Priority:** Must

## HLR-020. Onboarding time-to-value
The system shall demonstrate at least one working, tested rule to the parent before the end of onboarding.
- **Source:** Brief §"Parent onboarding" Screen 10, RISK-08
- **Priority:** Should (strong Should — directly tied to the onboarding-abandonment risk)

---

## Traceability note

This is a high-level list; the full Traceability Matrix (business goal → HLR → FR → user story → acceptance criteria → test scenario) is a Phase 7 deliverable (`32_TRACEABILITY_MATRIX.md`). Each HLR above already cites its originating decision or brief section so that later phases can build the matrix without re-deriving rationale.

## Open items surfaced by this document

**OQ-16 [NEW].** HLR-020 uses "Should" rather than "Must" because it is a UX quality bar, not a hard functional requirement — but the Risk Register (RISK-08) treats onboarding abandonment as a high-likelihood, high-impact risk. *Recommendation:* treat HLR-020 as a release-blocking acceptance criterion in practice (i.e., tested and signed off before launch) even though it is technically a "Should" in this document, since a technically "optional" but launch-blocking requirement should be visible as a Should here and enforced via Definition of Done in Phase 7. No further action needed now; flagged for Phase 7 consistency.
