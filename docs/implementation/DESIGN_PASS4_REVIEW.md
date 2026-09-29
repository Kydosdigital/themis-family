# Claude Design Pass 4 Review

Status: APPROVED WITH TWO FINAL DESIGN AMENDMENTS BEFORE PASS 5

Pass 4 is strong and can move toward final handoff after the two amendments below.

## Approved

Keep:
- Activity as outcome-based reporting, not surveillance
- Apple Screen Time behind a clearly labelled Apple-owned boundary
- calm billing states
- explicit Protection Expired -> review -> reactivation flow
- grouped Settings architecture
- visible Owner-only restrictions for Guardian
- separate Support and Safeguarding entry points
- privacy-minimal notification examples
- iPad split-view adaptation using the same information architecture
- large-text scrolling fixes
- no-wrap fix for short status labels
- the screen-ID no-wrap fix on iPad boards

The Pass 4 accessibility and self-critique direction is approved.

## Decision 1: "Timing could not be verified"

Do NOT use:
- "Count as on time"
- "Count as after the deadline"

Those choices make the parent certify a timing fact the system could not verify.

The approved trusted-time requirement says that when timing integrity is uncertain, the parent resolves the underlying task through the normal human decision path.

Required screen:

Title:
"Timing could not be verified."

Show:
- the child's device-local claimed submission time
- the server-received time
- a short neutral explanation that Themis could not verify which timing should be trusted

Actions:
- Approve
- Needs more work
- Ask one question, where the bounded clarification exchange is still available

If approved:
- clear the relevant task restriction subject to other active rules
- Activity may say "Approved, timing unverified"
- do NOT silently rewrite the history as "on time"

If rejected:
- use the ordinary Needs more work / rejection behaviour
- do not automatically label the child dishonest or late

If clarification is used:
- preserve the existing one-question / one-reply limit

This is a human resolution of the task, not a parent adjudication of clock truth.

## Decision 2: cancellation notice

Do not hard-code a product-wide lead time yet.

For design examples:
- an example paid-through date is fine
- label it as demo/example data
- show the actual entitlement end date when known

Preferred copy:
"Protection stays active until [paid-through date]."

The exact advance-notice lead time remains an implementation/content decision until separately confirmed.

Do not turn "14 November" into a fixed policy.

## Safeguarding

Approved as placeholder structure only.

Keep:
- separate Safeguarding screen
- explicit indication that operational contact route/procedure/emergency wording requires safeguarding/legal completion before launch

Do not invent final emergency wording, external contacts or procedure in design.

## Apple Screen Time report

Approved.

T-006 and T-006 Unavailable correctly represent the unresolved Priority 8 device capability.

Do not assume the report is available on the parent's iPhone until the real-device spike confirms it.

## iPad accessibility note

The current note that the landscape sidebar folds/collapses at accessibility sizes is acceptable for design.

Engineering should use native adaptive SwiftUI behaviour rather than hard-coding a custom collapse threshold.

## Gate to Pass 5

Pass 5 may start after:
1. the Timing could not be verified screen uses normal task resolution actions rather than "count as on time/after deadline"
2. cancellation dates are clearly example/entitlement-driven, not a fixed notice policy
3. the two amended states are visually checked
4. no new product behaviour is introduced

No other Pass 4 rework is required.
