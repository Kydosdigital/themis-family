# Claude Design Pass 4 Amendment Prompt

Pass 4 is approved except for two final design amendments.

Read:
- docs/implementation/DESIGN_PASS4_REVIEW.md
- docs/17_OFFLINE_AND_SYNC_BEHAVIOUR.md
- docs/11_TASK_AND_APPROVAL_SPECIFICATION.md
- docs/25_SUBSCRIPTIONS_AND_BILLING.md

Do not start Pass 5 yet.

## Amendment 1: Timing could not be verified

Replace any parent choices:
- Count as on time
- Count as after the deadline

with the normal task-resolution actions:

- Approve
- Needs more work
- Ask one question, where clarification is still available

The screen must show:
- child-device claimed submission time
- server-received time
- neutral explanation that Themis could not verify which timing should be trusted

If approved:
- resolve the task normally
- clear only the relevant restriction, subject to other active rules
- Activity may show "Approved, timing unverified"
- do not rewrite the event as definitely on time

If rejected:
- use ordinary Needs more work behaviour
- do not label the child dishonest or late

Clarification remains one question and one reply.

## Amendment 2: cancellation notice

Do not imply a fixed 14-day or other fixed product notice period.

If a date such as 14 November appears, mark it clearly as example/demo data.

Preferred product copy:
"Protection stays active until [paid-through date]."

Use the actual entitlement end date when available.

The exact advance-notice lead time remains undecided.

## Verify

Render-check both amended states.

At the bottom of the Pass 4 file add:
"Pass 4 founder amendments applied"

List:
- timing-resolution update
- cancellation-date clarification

STOP after these two amendments.

Do not start Pass 5 until founder approval.
