# Themis Family UI-08 — Free Pass Implementation Contract

Status: ACTIVE IMPLEMENTATION BRIEF
Slice: UI-08 Free Pass
Branch: `feat/ui-08-free-pass`
Allowed product scope: F-001 through F-010 only.

## Authority

Use the approved requirements baseline as behaviour truth and the final Claude Design / Design System / Engineering Handoff as visual truth.

Primary sources:
- `docs/12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`
- `docs/16_DEVICE_ENFORCEMENT.md`
- `docs/20_STATE_MACHINES.md`
- `docs/09_ACCEPTANCE_CRITERIA.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md`
- merged UI-01 through UI-07 code and tests

Do not redesign approved Free Pass UX. Do not introduce production backend or Apple enforcement claims.

## Exact screen scope

- F-001 Grant Free Pass
- F-002 Select child
- F-003 Select apps/sites/categories
- F-004 Choose duration
- F-005 Override preview
- F-006 Confirm Free Pass
- F-007 Active Free Pass
- F-008 Revoke Free Pass
- F-009 Revocation sent
- F-010 Access revoked

## Required product invariants

1. Owner and Guardian may grant or revoke an ordinary Free Pass.
2. There is no implicit or silent blanket Free Pass.
3. Every Free Pass requires an explicitly selected child, target/scope and duration.
4. Presets are only a convenience. A preset must still resolve to an explicit target and explicit duration.
5. Before confirmation, show the specific active rule or rules that will be temporarily overridden.
6. Also disclose any known scheduled restriction that begins during the pass. Do not silently treat that future rule as overridden without explaining it.
7. The confirmation screen must state the exact child, scope, duration/end time and override effect.
8. The Free Pass produces a temporary access grant with an explicit expiry.
9. Expiry is device-local by design. The normal effective enforcement state resumes automatically at expiry without a second parent action.
10. Never imply the backend or parent device must be online at expiry for restrictions to resume.
11. Active Free Pass must show exact scope and remaining/end time.
12. Early revoke is allowed.
13. Early revoke preserves the same decision-versus-device-application truth used elsewhere.
14. After the adult revokes, show "Revocation sent" until the child device acknowledges/applies the new resolution.
15. Only after acknowledgement may the UI show "Access revoked".
16. When a pass expires or is revoked, recompute effective enforcement. Do not claim a global lock/unlock if another rule independently applies.
17. Always Allowed remains absolute and is never a target that a Free Pass needs to override.
18. Emergency communication floor remains outside Free Pass scope.
19. The UI may demonstrate deterministic mock/application states, but must not claim real Apple enforcement, production push delivery or measured timing.

## Canonical demo path

Use the existing Sarah/Sam/Maya family.

Recommended canonical Free Pass:
- Sarah selects Maya.
- Scope: Games.
- Duration: 30 minutes.
- Existing Bedtime rule currently restricts Games.
- A known Scheduled Rule begins during the 30-minute pass, and F-005 explicitly discloses it.
- F-006 confirms exactly what will be temporarily overridden.
- F-007 shows the pass active with remaining/end time.
- F-008 confirms early revoke.
- F-009 shows Revocation sent, waiting for Maya's device.
- F-010 shows Access revoked only after deterministic device acknowledgement.

Also include one custom target/duration path to prove there is no dependency on presets.

## Required deterministic review states

At minimum expose launchable review roots for:
- F-001 entry
- F-003 exact scope
- F-004 duration
- F-005 override preview
- F-006 confirmation
- F-007 active
- F-008 revoke confirmation
- F-009 revocation sent
- F-010 access revoked

Add representative accessibility review coverage for setup, active and revocation states.

## Required tests

Tests must prove:
- no Free Pass can be confirmed without explicit child
- no Free Pass can be confirmed without explicit scope
- no Free Pass can be confirmed without explicit duration
- preset resolves to explicit scope + duration
- custom selection works
- override preview names the currently active rule(s)
- scheduled rule beginning during pass is disclosed
- grant has an explicit expiry
- expiry returns to effective enforcement without requiring parent action
- Owner and Guardian may grant/revoke, Child and Teen may not
- Revocation sent and Access revoked are distinct states
- Access revoked cannot be claimed before device acknowledgement
- another remaining restriction prevents a false global availability claim
- Always Allowed is never included as an overridden restrictive target
- emergency communication is never represented as a Free Pass target

## Integration paths

Replace the existing Parent Home F-001 placeholder quick action with the real Free Pass flow.

Do not implement UI-09 Protection, UI-10 Activity, UI-11 Settings, Subscription or later slices.

## Verification

During implementation use narrow checks for local edits.

Before merge, the final exact head must pass:
- repository workflow checks
- real macOS/Xcode build
- full XCTest
- Release Simulator visual review covering required UI-08 standard/accessibility states and existing regressions
- manual screenshot inspection

Do not merge from technical CI alone.
