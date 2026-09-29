# Claude Design Pass 5 Review

Status: DESIGN APPROVED; ENGINEERING HANDOFF REVIEW PENDING

## Approved from the uploaded Pass 5 exports

### Final prototype
Approved.

Evidence reported in the final prototype:
- 216 screens and states
- 28 critical paths
- 0 broken links
- 0 unreachable screens
- branch states wired through Other states
- forward/back/cancel/retry paths checked
- cross-device handoffs checked
- Pass 4 timing/cancellation states render-checked at default, ~135% and ~170%
- UK English/copy consistency check passed
- no false Protected states
- Apple Screen Time boundary remains honest
- no real-world homework Automatic Verification claim
- accessibility design QA completed with implementation verification still required

### Design System
Approved.

The final system preserves:
- A-derived typography/spacing/timeline motif
- C-derived hierarchy/structure/status
- restrained B warmth for Child only
- semantic colour tokens
- no purple
- Parent/Child/Teen variants within one system
- native navigation
- accessibility-size quick-action and timeline fallbacks
- Reduce Motion alternatives
- design-level contrast checks with implementation verification still required

## One requirement inconsistency to carry into engineering review

The final prototype's household-deletion screen says the App Store subscription is not cancelled automatically.

The approved requirements currently also contain a Household state-machine line saying household deletion cascades to "Subscription cancelled."

These may be reconcilable as:
- Themis household/internal entitlement is terminated on household deletion
- the user's App Store auto-renewing subscription may still require App Store management

But the approved requirements do not state that distinction clearly enough.

Do not silently resolve this in SwiftUI/backend implementation.

Before implementing ST-011 / deletion billing behaviour, record a requirements clarification or specification amendment that distinguishes:
1. Themis household deletion / entitlement state
2. App Store subscription auto-renewal state

The current design copy may remain provisional until that is confirmed.

## Engineering Handoff board still required for final approval

The user reports that Themis Engineering Handoff.dc.html contains:
- screen inventory
- component inventory
- token sheet
- SF Symbols map
- native-vs-custom control map
- motion spec
- state matrix
- screen-to-requirement matrix
- spike flags
- asset register
- SwiftUI implementation order
- acceptance checklist
- readiness verdict

That board was not included in the uploaded review files available for this review.

Therefore:
- final UI/UX design: APPROVED
- final prototype: APPROVED
- Design System: APPROVED
- engineering handoff package: NOT YET REVIEWED
- production UI implementation: do not start until the Engineering Handoff board is reviewed

## Traceability notes

Do not invent references merely to eliminate "Traceability check required."

Known mappings that can be tightened during handoff review:
- P-003 Sign in with Apple -> SEC-014 and Parent Experience §14.2
- P-005 What are you struggling with? -> approved onboarding journey in docs/04_USER_JOURNEYS.md; no standalone FR is required if this remains a UX starter-selection screen
- P-001 Launch -> presentation/navigation shell; may legitimately have no standalone functional requirement
- ST-012 Account/sign out -> SEC-014/SEC-015 are relevant to authentication/session management, but verify the exact screen behaviour before claiming full traceability
- the fifth edge state must be identified from the Engineering Handoff board before resolving its traceability

A screen may be a UX/presentation state without its own FR. Marking that explicitly is better than fabricating a requirement ID.
