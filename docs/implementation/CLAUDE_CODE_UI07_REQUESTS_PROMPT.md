# Themis Family UI-07 — Requests Implementation Contract

Status: ACTIVE IMPLEMENTATION BRIEF  
Slice: UI-07 Requests  
Branch: `feat/ui-07-requests`  
Allowed product scope: Q-001 through Q-014 and A-004 through A-011 only.

## Authority

Use the approved requirements baseline as behaviour truth and the final Claude Design / Design System / Engineering Handoff as visual truth.

Primary sources:
- `docs/12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`
- `docs/09_ACCEPTANCE_CRITERIA.md`
- `docs/18_ROLES_AND_PERMISSIONS.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md`
- merged UI-01 through UI-06 code and tests

Do not redesign approved Requests UX and do not introduce production backend or Apple enforcement claims.

## Exact screen scope

Child / Teen:
- Q-001 Ask for more time/access
- Q-002 Choose target
- Q-003 Choose requested duration
- Q-004 Optional reason
- Q-005 Review request
- Q-006 Request pending
- Q-007 Send reminder
- Q-008 Clarification prompt
- Q-009 Reply to clarification
- Q-010 Approved
- Q-011 Partially approved
- Q-012 Declined
- Q-013 Expired
- Q-014 Cancel request

Parent:
- A-004 Request detail
- A-005 Approve request
- A-006 Partial approval
- A-007 Decline request
- A-008 Ask clarification
- A-009 Waiting for child reply
- A-010 Already resolved
- A-011 Approved vs Applied

## Required product invariants

1. Requests are structured exceptions, never chat.
2. Every request references a specific rule, controlled target, deadline or context.
3. The child/teen owns only their own requests.
4. Owner and Guardian may both decide.
5. First valid adult decision wins. Later adult attempts show Already resolved and do not overwrite the first decision.
6. Exactly one automatic reminder may be sent at 15 minutes while unresolved.
7. Exactly one manual child nudge may be sent per pending request, independent of the automatic reminder.
8. Exactly one clarification prompt and exactly one child reply are available. After that, clarification disappears and only approve / partial approve / decline remain.
9. Clarification does not block an adult decision while waiting for a reply.
10. Offline child submission is shown as Sending… until confirmed received. Never show Pending before server receipt.
11. No auto-approval exists.
12. Partial approval must clearly show what was requested and what was actually granted.
13. Expiry is context based, with a maximum 4-hour pending backstop. A request may also expire earlier if its referenced context ends or becomes irrelevant.
14. An approval arriving after expiry does not revive the expired request. A fresh explicit grant is required.
15. Approved and Applied are distinct where a device-side change is involved. Never claim access changed until device acknowledgement exists.
16. Temporary grants have explicit scope and expiry and later enforcement remains governed by the existing effective-enforcement model.
17. Keep Child copy calm and simple; Teen copy mature and restrained.
18. Reasons and clarification text are shown only inside the authenticated app.
19. No unrestricted message thread, DM, inbox, conversation history or message notifications are introduced.

## Canonical demo path

Use the existing family:
- Owner: Sarah
- Child: Sam
- Teen: Maya
- Guardian: where a second adult is needed for concurrency tests

Recommended canonical request:
- Maya requests 15 more minutes for Instagram.
- A-004 shows the authenticated reason.
- Parent can approve +5/+15/+30/custom/until time, partially approve, decline, or use the one clarification round.
- Deterministic conflict state proves the first valid adult decision wins.
- Deterministic A-011 proves Approved versus Applied.

Also include a schoolwork temporary-access example only through the same shared request lifecycle. Do not create a separate School Mode request engine.

## Required deterministic review states

At minimum expose launchable review roots for:
- Q-001 request entry
- Q-006 pending
- Q-008 clarification received
- Q-010 approved
- Q-011 partial approval
- Q-012 declined
- Q-013 expired
- A-004 request detail
- A-008 ask clarification
- A-009 waiting for reply
- A-010 already resolved
- A-011 approved but device application pending

Add accessibility review coverage for representative Child/Teen and Parent states.

## Required tests

Tests must prove:
- offline submission is Sending, not Pending
- request belongs to the submitting child
- all eligible approvers are notified after confirmed receipt
- automatic reminder is capped at one
- manual child nudge is capped at one and does not reset automatic reminder timing
- one clarification prompt only
- one clarification reply only
- adult may decide without a clarification reply
- first valid adult decision wins
- partial approval preserves requested vs granted duration
- expiry prevents stale approval
- cancellation only applies while still pending
- Approved versus Applied remains separate
- no global/unscoped request target
- temporary access reuses the same lifecycle
- no false unlock when another restriction remains active

## Integration paths

Replace the existing Q-001 placeholder from Child/Teen Home with the real request flow.

The Child/Teen Requests tab may now show the UI-07 request history/status root required by the approved design, but do not implement later Activity reporting.

Parent Home / Action Centre request items that already point to A-004 should now open the real request detail flow.

Do not implement UI-08 Free Pass, UI-09 Protection, UI-10 Activity or any later slice.

## Verification

During implementation use fast checks for narrow edits.

Before merge, the final exact head must pass:
- repository workflow checks
- real macOS/Xcode build
- full XCTest
- Release Simulator visual review covering required UI-07 standard/accessibility states and existing regressions
- manual screenshot inspection

Do not merge from green technical CI alone.
