# Themis Family UI-09 — Protection Implementation Contract

Status: ACTIVE IMPLEMENTATION BRIEF
Slice: UI-09 Protection
Branch: `feat/ui-09-protection`
Allowed product scope: P-029, P-030 protection-state family, P-031 recovery, and permission-revoked presentation only.

## Authority

Use the approved requirements baseline as behaviour truth and the final Claude Design / Design System / Engineering Handoff as visual truth.

Primary sources:
- `docs/04_USER_JOURNEYS.md`
- `docs/05_HIGH_LEVEL_REQUIREMENTS.md`
- `docs/14_PARENT_EXPERIENCE.md`
- `docs/16_DEVICE_ENFORCEMENT.md`
- `docs/20_STATE_MACHINES.md`
- `docs/34_OPEN_QUESTIONS.md`
- `docs/35_DECISION_LOG.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md`
- merged UI-01 through UI-08 code and tests

Do not redesign approved Protection UX. Do not introduce production backend, Apple enforcement or heartbeat claims.

## Exact screen scope

- P-029 Child detail
- P-030 Protected
- P-030 Sync Pending
- P-030 Device Offline
- P-030 Needs Attention
- P-030 Protection Unavailable
- P-031 Fix protection / recovery
- permission-revoked presentation and return state

## Required product invariants

1. Protection health is the most recently confirmed enforcement state, not a claim of continuous real-time monitoring.
2. The parent-facing five-state model is exactly: Protected, Sync Pending, Device Offline, Needs Attention, Protection Unavailable.
3. Every protection state must communicate with text/iconography as well as colour.
4. Show `Last verified` where designed. The evidence must match the displayed state and must never create false reassurance.
5. A stale last-known-good state must not remain Protected indefinitely.
6. Do not encode or invent a staleness duration. OQ-19 remains deliberately unresolved pending real-device measurement; future thresholds are server-configurable.
7. Sync Pending and Device Offline are honest degraded confirmation states. Do not silently upgrade them to Protected.
8. Protection Unavailable is appropriate when authorisation is confirmed revoked/invalid or protection cannot currently be relied on.
9. External permission/authorisation revocation detected on the next supported foreground/status check must surface Protection Unavailable, not stale Protected.
10. A stale/offline device continues using its last-known Local Enforcement Plan according to the approved architecture; the UI must not imply that a degraded status automatically cleared restrictions.
11. P-031 recovery must guide the parent towards the approved re-authorisation/recovery path without promising success or fabricating Apple-owned screens.
12. Apple-owned permission UI must remain a real system handoff or clearly isolated deterministic mock representation for review. Do not recreate misleading system UI.
13. Recovery may return to Protected only after deterministic confirmation/acknowledgement in the UI model, with refreshed verification evidence.
14. P-029 Child detail should provide one child's protection status plus the approved concise view of that child's current rules/tasks/requests, without becoming an Activity/surveillance screen.
15. Do not imply raw Apple Screen Time activity is stored by Themis.
16. Do not expose circumvention-enabling technical detail.
17. Phone/Messages/Maps support remains spike-gated; do not turn unknown Apple behaviour into product truth.
18. Emergency calling is never deliberately restricted.
19. Deterministic mocks and review transitions are allowed; they must not be presented as production enforcement evidence.

## Canonical demo path

Use the existing Sarah/Sam/Maya family.

Recommended Protection review path:
- Sarah opens Sam from Parent Home into P-029.
- P-029 shows Sam's current protection status, current agreements/rules, relevant task/request summary and a protection-detail action.
- P-030 Protected shows confirmed healthy protection with recent verification evidence.
- P-030 Sync Pending shows that the latest confirmation has not completed yet, with prior verification evidence and no false reassurance.
- P-030 Device Offline shows the child device is offline/unreachable for confirmation and preserves the distinction from Protection Unavailable.
- P-030 Needs Attention shows an actionable protection problem and a `Fix this` route.
- P-030 Protection Unavailable clearly states protection cannot currently be confirmed/relied on and exposes recovery.
- Permission-revoked review state resolves to Protection Unavailable.
- P-031 guides recovery/re-authorisation.
- After deterministic recovery acknowledgement, return to Protected with refreshed `Last verified` evidence.

Do not create a timer/countdown implying the unresolved OQ-19 threshold.

## Required deterministic review states

At minimum expose launchable review roots for:
- P-029 Child detail
- P-030 Protected
- P-030 Sync Pending
- P-030 Device Offline
- P-030 Needs Attention
- P-030 Protection Unavailable
- P-031 recovery entry
- permission revoked
- recovered / Protected confirmation

Add representative accessibility review coverage for:
- P-029 Child detail
- a degraded P-030 state
- P-031 recovery

Preserve existing Parent, Child, Teen, Rules, School Access, Tasks, Requests and Free Pass regression captures.

## Required tests

Tests must prove:
- the five parent-facing protection states map exactly to the approved status system
- every state has textual/semantic meaning, not colour-only meaning
- Protected requires positive deterministic verification evidence in the presentation model
- stale/degraded scenarios cannot display Protected
- no hard-coded OQ-19 staleness threshold is introduced
- Sync Pending remains distinct from Device Offline
- Needs Attention remains distinct from Protection Unavailable
- permission revoked maps to Protection Unavailable
- recovery cannot display Protected before deterministic confirmation
- confirmed recovery refreshes verification evidence
- P-029 does not fabricate Activity/raw Screen Time detail
- degraded/offline status does not falsely claim restrictions were cleared
- existing Parent Home degraded scenarios continue to route into the correct P-030 state
- accessibility presentation preserves complete status/explanation/verification semantics

## Integration paths

Replace the existing P-029 and P-030/P-031 placeholders from Parent Home with the real UI-09 flow.

Keep the existing five-state shared status system and design primitives where they already match the approved handoff.

Do not implement UI-10 Activity, UI-11 Settings, Subscription or later slices.

## Verification

During implementation use narrow checks for local edits.

Before merge, the final exact head must pass:
- repository workflow checks
- real macOS/Xcode build
- full XCTest
- Release Simulator visual review covering required UI-09 standard/accessibility states and existing regressions
- manual screenshot inspection against the approved design direction

Do not merge from technical CI alone.
