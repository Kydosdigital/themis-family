# Claude Design Pass 4 Approval

Status: APPROVED FOR PASS 5, subject only to the final render sanity check already in progress.

The two founder amendments are accepted:

1. **Timing could not be verified**
   - The screen shows the child-device claimed time and the server-received time.
   - Themis does not ask the parent to certify a clock fact it could not verify.
   - The parent uses the normal task-resolution path: Approve, Needs more work, or one bounded clarification question.
   - Approval flows through the existing Applying state.
   - Activity records "Approved, timing unverified" rather than rewriting the event as definitely on time.

2. **Cancellation**
   - The cancellation state shows the actual paid-through / entitlement end date.
   - Any hard-coded date in design is explicitly labelled as example data.
   - No fixed advance-notice period has been introduced.

The reported safeguarding and iPad large-text notes are also accepted:
- safeguarding operational details remain launch-blocking external/legal work, not invented design content
- iPad large-text adaptation should rely on native adaptive behaviour during implementation

## Pass 4 outcome

- Activity & reporting: APPROVED
- Subscription states: APPROVED
- Settings & household: APPROVED
- Support & safeguarding structure: APPROVED
- Notifications: APPROVED
- Empty/error/edge states: APPROVED
- iPad adaptations: APPROVED
- Pass 4 accessibility additions: APPROVED
- Pass 5 final prototype QA and engineering handoff: READY after the render check confirms the two changed screens

No new product behaviour is introduced by this approval.
