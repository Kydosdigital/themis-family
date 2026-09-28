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
- **Business rules:** BR-218 (exactly one clarification round per request in V1 — CONFIRMED, DEC-34)
- **Release:** V1 / Must
- **Open questions:** None outstanding — OQ-18 is closed. This FR is approved as the "simplest viable interaction" OQ-18 asked for, exactly as specified: one clarification prompt, one reply, then approve/partially approve/decline. No open-ended messaging thread; the interaction exists only inside this specific request.

**BR-218.** A request supports at most one clarification round (one prompt, one reply) in V1. The UI must not present clarification as an open thread; after the single exchange, only approve/partially-approve/decline remain available to the approver for that request.

## FR-043. Request expiry (context-based model, CONFIRMED — DEC-39, closes OQ-26)
- **Actor:** System
- **Trigger:** A request can no longer meaningfully affect the underlying rule/context it refers to, OR it reaches a maximum pending lifetime backstop, whichever comes first
- **Preconditions:** Request is Pending
- **Happy path:** Every request record carries three fields beyond its type/reason: `created_at`, `expires_at`, and a `context reference` (the specific rule, deadline, or target the request relates to). `expires_at` is computed from whichever ends the request's relevance first:
  - the underlying context ending on its own (e.g. a Deadline Lock's deadline passes and is handled another way; a Scheduled Rule's restriction window ends; the specific event the request named has passed), OR
  - a maximum pending lifetime backstop of **4 hours** from `created_at`, used only when the underlying context does not itself end sooner.

  When `expires_at` is reached, the request moves to Expired; the child is told it expired and may submit a new one, addressed to the current state of whatever they still need.
- **Alternative paths:** The underlying rule or target is deleted or materially changed while the request is Pending → the request is evaluated against its `context reference`: if the reference no longer resolves to a live rule/target, the request expires immediately regardless of `expires_at`, rather than being left pointing at nothing.
- **Failure paths (the brief's own named edge case):** An approver approves a request AFTER it has already expired. BR-217 governs.
- **Business rules:** BR-217, BR-229 (context-based expiry — see below)
- **Release:** V1 / Must
- **Open questions:** None outstanding — OQ-26 is closed by this model.

**BR-229 (context-based expiry, CONFIRMED — DEC-39).** A request's `expires_at` is not a single arbitrary duration applied uniformly. It is derived from the request's `context reference` (the specific rule/deadline/target it relates to) ending, with a flat 4-hour maximum pending lifetime as a backstop only, not the default expectation. This avoids, for example, a "can I stay up 20 minutes" request during a bedtime rule outliving the bedtime window itself, and avoids a genuinely still-relevant request (e.g. an all-day temporary access ask) expiring arbitrarily early.

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
- **Happy path:** Parent selects "Free Pass." The UI offers quick presets to keep this fast (e.g. "Games — 30 minutes," "YouTube — 20 minutes," "All entertainment — 30 minutes"), or the parent can build a custom target/duration combination — but there is no silent, unscoped default: target/scope and duration are always explicitly selected, whether via a preset tap or manual choice. Before confirmation, the app states which active rule(s) this Free Pass will temporarily override (e.g. "This will pause the bedtime schedule for Games until 9:30 PM"). Parent confirms; grant is created per FR-044, expires locally at the stated time, and the normal effective enforcement state (per BR-211's model) resumes automatically without further parent action.
- **Business rules:** BR-219
- **Release:** V1 / Must
- **Open questions:** None outstanding — OQ-27 is closed by this confirmation.

**BR-219 (Free Pass scope — CONFIRMED, DEC-33; closes OQ-27).** A Free Pass has no silent or unscoped blanket default. The parent must explicitly select both target/scope and duration for every Free Pass, whether via a one-tap preset (e.g. "Games — 30 minutes") or a custom selection — presets are a UI convenience, not an exception to the "always explicit" rule. Before the parent confirms, the app must state which specific active rule(s) the Free Pass will temporarily override. Expiry occurs locally (per BR-210/DEC-30) and the target's normal effective enforcement state, as computed by BR-211, resumes automatically at expiry without requiring any further action from the parent.

---

## 12.3 Open questions surfaced by this document

**OQ-26 [CLOSED — resolved by DEC-39/BR-229].** Request expiry is context-based (tied to the underlying rule/context ending), with a 4-hour maximum pending lifetime as a backstop only, not a flat default.

**OQ-27 [CLOSED — resolved by DEC-33/BR-219].** Free Pass always requires explicit target/scope and duration selection (presets are a UI convenience, not an exception); no unscoped default exists.

**OQ-18 [CLOSED — resolved by DEC-34].** FR-042/BR-218's bounded clarification exchange (one prompt, one reply, then a decision) is approved as final for V1.
