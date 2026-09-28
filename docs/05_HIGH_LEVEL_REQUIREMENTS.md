# 05. High-Level Requirements

**Status:** Phase 2, amended 2026-09-28 per founder review (DEC-25, DEC-27, DEC-28, DEC-29, DEC-30)
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
The system shall require every task/condition to declare a Verification Type of either Parent Approval or Automatic Verification. Automatic Verification means Themis has deterministic system evidence that the configured condition completed (e.g. an in-app timer or in-app focus session successfully completing) — it must never be described or implied as proof that a real-world activity itself occurred (e.g. "15-minute reading timer completed" is verifiable; "the child read for 15 minutes" is not).
- **Source:** DEC-16, narrowed by DEC-28
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
The system shall allow a child/teen to submit a request for extra time, a deadline extension, temporary app/website access, or an exception, with a stated reason, and shall allow an approver to approve (with a specific duration), partially approve, decline, or request clarification. Clarification is a single structured, request-scoped exchange (one clarification prompt from the approver, one reply from the child/teen) and must not become unrestricted or open-ended parent/child messaging.
- **Source:** Brief §"Requests and Negotiation System", constrained by DEC-29
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
The system shall display the most recently confirmed enforcement health per child device and shall never imply real-time or continuous assessment when the device has not recently checked in. Minimum V1 states: **Protected, Sync Pending, Device Offline, Needs Attention, Protection Unavailable**, each shown with a "Last verified: [time]" indicator where appropriate. A stale last-known-good state must not continue to display as Protected indefinitely; exact staleness thresholds are defined in the Device Enforcement specification (Phase 5, tracked as OQ-19). The system shall never display a reassuring status without a verified, sufficiently recent basis for it.
- **Source:** Brief AC4, DEC-08, corrected by DEC-27
- **Priority:** Must

## HLR-014. Offline-first enforcement
The system shall cache active rules and any temporary access grants (temporary access, extra time, Free Pass) locally on each child device, such that both initial enforcement and scheduled expiry/re-locking occur correctly during a backend outage, parent-device offline period, or push-notification failure. Re-locking at expiry must never depend on a second server-sent instruction arriving at the expiry moment. The system shall never silently remove a restriction due to loss of connectivity.
- **Source:** Brief §"Local-first enforcement", DEC-15 (analogous safety principle), extended by DEC-30
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

## HLR-020. Onboarding time-to-value, with a two-stage completion model
The system shall distinguish **Account Creation Complete** (household and member records created) from **Themis Protection Activated** (child-device authorisation is valid, at least one rule target has been selected, a real test shield has been applied, the test shield has been successfully removed, and the resulting state has been verified by the application). The parent shall see an explicit incomplete-setup state until Themis Protection Activated is achieved; the product must never describe protection as active before all five conditions are met.
- **Source:** Brief §"Parent onboarding" Screen 10, RISK-08, elevated and refined by DEC-25
- **Priority:** Must (elevated from Should — see DEC-25 and OQ-16, now resolved)

## HLR-021. Launch region [NEW]
The system shall launch UK-first: UK English, GBP pricing, and UK-focused onboarding, research and support assumptions. This is a launch/validation scope decision; the underlying architecture shall not unnecessarily prevent later international expansion.
- **Source:** DEC-23
- **Priority:** Must

## HLR-022. Age-segment selection [NEW]
The system shall let the parent explicitly select "Child experience" or "Teen experience" for each child during setup, without requiring a precise date of birth for this purpose. The parent shall be able to change this selection later without deleting or recreating the child's account.
- **Source:** DEC-24
- **Priority:** Must

## HLR-023. Shared-device scenarios excluded from V1 [NEW]
The system's V1 scope assumes one device per child, each signed into its own Child Apple Account within the family's Family Sharing group. The system shall not claim or imply support for shared-device scenarios (siblings sharing one iPad, a parent and child sharing a device, or a device signed into a different family member's Apple Account) until such scenarios are separately researched and technically validated.
- **Source:** DEC-26
- **Priority:** Must (as a scope/claims constraint)

## HLR-024. No unverified platform-behaviour claims [NEW]
The system's documentation, in-product copy, and error messaging shall describe Themis Family's own response to a failure or system event (e.g. loss of authorisation, sync failure) without asserting a specific unverified cause (e.g. "an iOS update caused this") unless that exact behaviour is explicitly documented and guaranteed by Apple.
- **Source:** DEC-31
- **Priority:** Must

---

## Traceability note

This is a high-level list; the full Traceability Matrix (business goal → HLR → FR → user story → acceptance criteria → test scenario) is a Phase 7 deliverable (`32_TRACEABILITY_MATRIX.md`). Each HLR above already cites its originating decision or brief section so that later phases can build the matrix without re-deriving rationale.
