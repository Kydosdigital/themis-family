# 12. Requests and Exceptions Specification

**Status:** Phase 3 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md` HLR-009, `35_DECISION_LOG.md` DEC-14, DEC-29, DEC-30

---

## 12.1 Request types

| Type | Description |
|---|---|
| Extra time | Child/teen asks for additional time on an already-active grant or before a deadline |
| Deadline extension | Child/teen asks to move a Deadline Lock's deadline later, for this instance only |
| Temporary access | Child/teen asks for time-boxed access to an otherwise-restricted app/site (e.g. School Mode edge case, `04_USER_JOURNEYS.md` §4.5) |
| Exception | A catch-all for a one-off ask not covered above (e.g. "can I skip today's rule, we have a family event") |

All four share the same underlying lifecycle and approver actions; they differ only in what they grant.

---

## FR-040. Submit a request
- **Actor:** Child or Teen
- **Trigger:** Child/teen taps "Ask for more time" / "Request access" / equivalent
- **Preconditions:** None beyond having an account in the household
- **Happy path:** Child/teen selects request type, selects or types a reason (brief §"Requests and Negotiation System" gives example reasons: homework research, talking to friends, event tonight, finished early, custom), submits. Request enters Pending state. All eligible approvers are notified.
- **Failure paths:** Child submits while offline → queued, shown as "Sending..." not "Pending" until confirmed received.
- **Permissions:** Child/Teen, own requests only
- **Data required:** Request type, target rule/app (where applicable), requested duration (where applicable), reason, timestamp
- **Notification behaviour:** Immediate to all eligible approvers
- **Business rules:** BR-215 (a request always references a specific rule or controlled target — it is not a free-standing message; this is what keeps it from becoming a chat feature, per DEC-29)
- **Release:** V1 / Must

## FR-041. Approver responds to a request
- **Actor:** Owner or Guardian
- **Trigger:** Approver opens a pending request
- **Preconditions:** Request is Pending
- **Happy path:** Approver chooses one of: approve a specific duration (preset options +5/+15/+30 minutes, "until a chosen time," or a custom duration), partially approve (a different duration than requested), decline, or request clarification (see FR-042). On approve/partial-approve, the grant is created (see §12.2) and pushed to the child device. On decline, the child is notified with the approver's decision (a decline may optionally include a reason).
- **Failure paths:** Two approvers act on the same request → BR-102 (`18_ROLES_AND_PERMISSIONS.md`) applies.
- **Permissions:** Owner, Guardian only
- **Business rules:** BR-102, BR-216 (a request that has expired — see FR-043 — cannot be approved; see BR-217 for the race between expiry and a late approval)
- **Release:** V1 / Must

## FR-042. Request clarification (bounded, non-messaging exchange)
- **Actor:** Owner or Guardian (initiates), Child or Teen (replies)
- **Trigger:** Approver taps "Ask for clarification" instead of approving/declining outright
- **Preconditions:** Request is Pending
- **Happy path:** Approver sends one structured clarification prompt, attached to that specific request (e.g. a short free-text field, length-capped). Child/teen sees the prompt and sends exactly one reply, similarly attached to that request. The request returns to Pending, now showing the clarification exchange alongside the original reason. The approver must then approve, partially approve, or decline — the exchange does not repeat, and no further back-and-forth is offered within this request (DEC-29). If genuinely more discussion is needed, the family has the conversation outside the app; Themis Family does not become the channel for it.
- **Failure paths:** Child does not reply → request remains Pending with the clarification unanswered; the approver can still approve/decline without a reply if they choose (the clarification does not block a decision, it only informs one).
- **Business rules:** BR-218 (exactly one clarification round per request in V1 — see OQ-18)
- **Release:** V1 / Must
- **Open questions:** OQ-18 (this FR is the "simplest viable interaction" OQ-18 asked for; still worth founder confirmation before Phase 4 acceptance criteria are written)

**BR-218.** A request supports at most one clarification round (one prompt, one reply) in V1. The UI must not present clarification as an open thread; after the single exchange, only approve/partially-approve/decline remain available to the approver for that request.

## FR-043. Request expiry
- **Actor:** System
- **Trigger:** A request remains Pending past a defined maximum age, OR the situation it refers to has clearly passed (e.g. the deadline it would have extended has already been handled another way)
- **Preconditions:** Request is Pending
- **Happy path:** RECOMMENDATION (not yet founder-confirmed — see OQ-26): a request auto-expires after a defined window (e.g. 4 hours) if untouched, moving to Expired state; the child is told it expired and may submit a new one.
- **Failure paths (the brief's own named edge case):** An approver approves a request AFTER it has already expired. BR-217 governs.
- **Business rules:** BR-217
- **Release:** V1 / Must
- **Open questions:** OQ-26 (exact expiry window)

**BR-217.** If an approver's decision arrives after a request has already moved to Expired, the decision is not applied as a live grant. The approver is shown that the request expired and, if they still want to grant something, must do so via a fresh, explicit grant (effectively creating a new temporary access grant), not by "reviving" the expired request. This avoids an ambiguous state where a grant appears to apply retroactively to a situation that has already passed.

---

## 12.2 Grants (the result of an approved request): temporary access, extra time, Free Pass

## FR-044. Grant creation and local expiry
- **Actor:** System
- **Trigger:** A request is approved (FR-041), or an Owner/Guardian issues a Free Pass directly (without a prior request — see FR-045)
- **Preconditions:** None beyond the triggering approval/action
- **Happy path:** The grant (temporary access to a specific target, extra time on an existing session, or a Free Pass) is created with an explicit expiry time and pushed to the child device. The device caches the grant and its expiry locally (per BR-210, `10_RULE_ENGINE_SPECIFICATION.md`). At expiry, the device itself re-applies the underlying restriction, without requiring a further server instruction, even if offline, even if the parent device is offline, even if push notifications fail (DEC-30).
- **Business rules:** BR-210, BR-219 (Free Pass scope)
- **Offline behaviour:** This FR's local-expiry behaviour is the DEC-30 requirement in full; no separate offline-specific FR is needed here since it is definitional, not an edge case.
- **Release:** V1 / Must

## FR-045. Parent-initiated Free Pass (no prior child request)
- **Actor:** Owner or Guardian
- **Trigger:** Parent proactively grants temporary access without the child having asked (brief §"Parent Free Pass")
- **Preconditions:** None
- **Happy path:** Parent selects "Free Pass," chooses scope and duration, confirms. Grant is created per FR-044.
- **Business rules:** BR-219
- **Release:** V1 / Must
- **Open questions:** OQ-27 (exact default scope)

**BR-219 (Free Pass scope — RECOMMENDATION, not yet founder-confirmed).** A Free Pass applies to the specific rule(s) or controlled target(s) the parent explicitly selects when creating it — never to "all non-essential restrictions household-wide" by default, since an unscoped Free Pass is easy to grant by mistake and hard to reason about. The brief itself asks for "the safest and simplest behaviour" to be recommended; this is that recommendation, but it is flagged as OQ-27 pending founder sign-off since "simplest for the parent to configure" (one big toggle) and "safest/most predictable" (scoped) pull in different directions.

---

## 12.3 Open questions surfaced by this document

**OQ-26 [NEW].** What is the exact request-expiry window (FR-043)?
- *Recommended default:* 4 hours from submission, or the end of the current day, whichever is sooner — long enough to allow for a genuinely delayed parent, short enough that an "extra time to finish a call" request doesn't linger meaninglessly into the next day.
- *Blocks:* `20_STATE_MACHINES.md` (Phase 5)

**OQ-27 [NEW].** Should a Free Pass default to a single pre-selected scope (e.g. "all entertainment apps for this child") or require the parent to select scope every time?
- *Recommended default:* See BR-219 — require explicit scope selection, no unscoped default. Flagged for founder confirmation given the safety/simplicity trade-off named above.
- *Blocks:* `15_CHILD_AND_TEEN_EXPERIENCE.md` / `14_PARENT_EXPERIENCE.md` (later phases) — affects the Free Pass UI design directly.
