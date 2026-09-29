# Claude Design Pass 4 Prompt

Pass 3 is approved. Start with a render sanity check of the amended Pass 3 frames listed in DESIGN_PASS3_APPROVAL.md. Fix visual rendering issues only, then continue.

Read:
- docs/implementation/DESIGN_PASS3_APPROVAL.md
- docs/implementation/DESIGN_PASS3_REVIEW.md
- docs/implementation/DESIGN_PASS2_DECISION.md
- docs/implementation/MOBILE_UX_BLUEPRINT.md
- docs/21_NOTIFICATIONS.md
- docs/23_PRIVACY_AND_CHILD_SAFETY.md
- docs/25_SUBSCRIPTIONS_AND_BILLING.md
- docs/26_ERROR_AND_EDGE_CASE_CATALOGUE.md
- docs/30_ADMIN_AND_SUPPORT.md
- docs/36_MVP_VS_LATER_FEATURE_MATRIX.md

Keep the approved visual system unchanged.

## Build these Pass 4 areas

### Activity and reporting
Design T-001 through T-006.
Activity shows Themis-owned outcomes, not a surveillance feed. Keep Apple Screen Time reporting visually and conceptually separate and do not imply Themis stores raw Apple usage data.

### Subscription
Design B-001 through B-008.
Do not invent pricing or trial length. Billing Grace keeps full protection active. Protection Expired clears Themis restrictions while keeping rule definitions. Resubscription after expiry requires explicit parent review and reactivation before rules apply again.

### Settings and household
Design ST-001 through ST-012 plus P-032, P-033 and P-034.
Respect Owner vs Guardian permissions exactly as documented. Keep household ownership and destructive actions clear.

### Support
Design ordinary support and the separate safeguarding-help entry point from the approved requirements. Support may diagnose and guide; it must not act as the parent.

### Notifications
Use docs/21_NOTIFICATIONS.md. Keep push payloads privacy-minimal. Do not expose request reasons or other sensitive free text on the lock screen.

### Empty/error/edge states
Cover the major Parent and Child/Teen empty, offline, permission, pairing, pending-sync, protection, request, session and subscription states from the edge-case catalogue.
Use the exact phrase:
"Timing could not be verified."
when timing integrity is uncertain.

### iPad
Create native iPad adaptations for:
- P-023 Parent Home
- R-001 Rules
- A-001 Action Centre
- C-001 Child Home
- T-001 Activity
- ST-001 Settings

Show portrait plus at least one Parent landscape treatment. Keep the same information architecture and do not turn iPad into a desktop dashboard.

### Accessibility
Extend the accessibility board for Settings, Activity, subscription states and iPad. Preserve the Pass 3 Dynamic Type fallbacks, VoiceOver intent, touch targets, Reduced Motion and no-colour-only rules.

## Prototype

Connect the new Pass 4 areas without breaking the existing Pass 3 flows.

At minimum make clickable:
- Activity -> child/history detail
- Apple Screen Time report boundary
- Settings -> Guardian / Privacy / Support / Subscription
- billing grace -> expiry -> resubscribe -> review -> reactivation
- child/device management
- ownership/destructive settings paths
- protection/support recovery
- iPad navigation demonstration

## Self-critique

Before presenting, check:
- Activity does not feel like surveillance
- subscription copy is calm
- Settings is not too dense
- role restrictions are clear
- Support and safeguarding remain distinct
- iPad feels native
- no error state gives false reassurance
- Child/Teen dignity remains intact

Fix obvious issues.

STOP after Pass 4. Do not begin Pass 5 or engineering handoff until founder review.
