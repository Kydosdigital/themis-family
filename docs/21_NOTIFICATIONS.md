# 21. Notifications

**Status:** Phase 7 draft
**Depends on:** `29_API_AND_BACKEND_REQUIREMENTS.md` §29.6, `24_SECURITY_REQUIREMENTS.md` SEC-011, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, DEC-41

## 21.1 Purpose

This document catalogues every confirmed push/local notification in the product, its trigger, recipient, and the constraints already established elsewhere (reminder-interval limits, flooding protection, the role of push as a latency optimisation only).

## 21.2 Governing principles (restated, not re-decided)

- **CONFIRMED, `29_API_AND_BACKEND_REQUIREMENTS.md` §29.6.** Push notifications are a latency optimisation only, never the sole correctness mechanism — every state a notification could report is independently re-derivable by the app on next foreground/sync, so a missed or delayed notification never leaves the user permanently uninformed.
- **CONFIRMED, DEC-41.** The reminder-interval model is fixed: one automatic reminder (at 15 minutes for the relevant context), plus one independent child-triggered nudge; neither resets the other; no further reminders follow once both are used. Applies identically to tasks and requests.
- **CONFIRMED, `24_SECURITY_REQUIREMENTS.md` SEC-011.** A child cannot force unlimited notifications to a parent's device by repeatedly creating/cancelling Requests or Tasks; DEC-41's structural limit is reinforced by API-layer rate limiting.

## 21.3 Notification catalogue

| Trigger | Recipient | Type | Constraint |
|---|---|---|---|
| Task submitted, awaiting approval | Owner/Guardian | Push | Subject to DEC-41's reminder model if unresolved |
| Task approaching Provisional Approval Grace Period expiry | Owner/Guardian | Push (urgent framing, still non-alarming) | One automatic reminder only, per DEC-41 |
| Task approved / rejected | Child/Teen | Push | Neutral, non-punitive copy on rejection (§15.3) |
| Request submitted | Owner/Guardian | Push | Subject to DEC-41 |
| Request clarification asked | Owner/Guardian → Child/Teen (and reverse) | Push | Single bounded exchange, FR-042 — no notification chain beyond the one prompt/one reply |
| Request approved / rejected / expired | Child/Teen | Push | Context-based expiry per FR-043; expiry notification must not imply the child did something wrong |
| Free Pass (Temporary Access Grant) activated | Child/Teen | Push | — |
| Free Pass revoked early | Owner/Guardian (confirmation), Child/Teen (notice) | Push | "Revocation sent" → "Access revoked" pattern, §16.9a |
| Device protection status downgrades to Needs Attention / Protection Unavailable | Owner/Guardian | Push | Server-configurable staleness threshold, OQ-19 — exact timing not fixed pending spike |
| Billing: payment fails, entering Apple Billing Grace Period | Owner/Guardian | Push | Calm, non-alarming; no child-facing equivalent (§25.2) |
| Billing: Protection Expired | Owner/Guardian, and child (age-appropriate) | Push | Clear, not blame-laden; per §25.2/§15 |
| Billing: voluntary cancellation advance notice | Owner/Guardian | Push | Sent ahead of paid-through date ending, per §25.2 |
| Resubscription: "Ready to turn protection back on?" | Owner/Guardian | Push + in-app prompt | Requires explicit confirmation, never auto-actioned by the notification itself, §25.6 |
| Device authorisation externally revoked (detected next foreground check) | Owner/Guardian | Push | Per §27.2's external-revocation finding — reactive, not real-time, since Themis cannot be notified instantly of an external Apple Settings change |
| Guardian invited / joined / removed | Owner (and Guardian, where relevant) | Push | — |
| Focus Session interrupted | Child/Teen | In-app only (not push — this is a same-session, immediate event) | Neutral copy, DEC-42 |
| EngagementSession abandoned (DEC-49) | Child/Teen (on next app open) | In-app only | No completion credit; neutral framing |

## 21.4 What is explicitly NOT notified

**CONFIRMED REQUIREMENT, consistent with data-minimisation and no-covert-monitoring principles.** No notification surfaces Category B (Apple-sandboxed) raw usage data — Themis structurally cannot generate such a notification (§27.5). No notification is sent to a parent containing the free-text content of a child's request/clarification beyond what the ordinary in-app view would show (i.e. push payloads themselves are not used to exfiltrate more detail than the app screen they point to).

## 21.5 Open items

- Exact notification copy per entry is a content-design exercise for implementation, not specified line-by-line here, but must be reviewed against `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4b (child transparency) and the neutral-tone standard for every child-facing entry.
- Device-protection-status notification timing is blocked on OQ-19's real-device spike (staleness threshold), consistent with `16_DEVICE_ENFORCEMENT.md` §16.8.
- Notification delivery reliability itself (does the push actually arrive) is an infrastructure/APNs concern for Phase 7 build sequencing (`37_BUILD_SEQUENCE.md`), not a product-requirements gap.

## 21.6 Cross-check

Every notification above traces to an already-confirmed FR/BR/DEC; no new notification-triggering behaviour is introduced by this document that was not already implied by earlier phases. SEC-011's flooding protection and DEC-41's reminder-interval cap are confirmed to bind every entry in §21.3 that could otherwise repeat.
