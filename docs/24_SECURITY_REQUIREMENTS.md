# 24. Security Requirements

**Status:** Phase 6 draft
**Depends on:** `29_API_AND_BACKEND_REQUIREMENTS.md` §29.7/§29.8, `18_ROLES_AND_PERMISSIONS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`

## 24.1 Purpose

This document specifies the concrete security controls required at the API layer, expanding `29_API_AND_BACKEND_REQUIREMENTS.md` §29.7 (role enforcement) and §29.8 (child-as-potentially-adversarial abuse protection, confirmed at the policy level in DEC-50) into specific, checkable controls.

## 24.2 Threat model summary

**SEC-001. The child client is a potentially adversarial party for enforcement-related endpoints.** Per DEC-50, this is confirmed as ordinary defensive system design, not an accusation of malicious intent: the product's core function is to restrict a party whose incentives are sometimes opposed to that restriction, so its endpoints must be designed accordingly.

**SEC-002. A removed or de-authorised device/Member must lose access immediately, not eventually.** Ties directly to `16_DEVICE_ENFORCEMENT.md` §16.9's device-removal/revocation model and §27.2's external-authorization-change finding — an API token or session for a removed Member/Device must be invalidated as part of the same atomic operation that performs the removal (§29.4's pattern), not on a delay.

**SEC-003. A Guardian must never be able to perform an Owner-only destructive action.** Direct enforcement of BR-101/DEC-45's confirmed Owner-only actions (household deletion, ownership transfer, Guardian removal) — server-side, per `29_API_AND_BACKEND_REQUIREMENTS.md` §29.7, not merely hidden in client UI.

## 24.3 Rate limiting, idempotency, and abuse controls (implements DEC-50)

Per the founder's explicit list (`29_API_AND_BACKEND_REQUIREMENTS.md` §29.8), the following controls are CONFIRMED REQUIREMENTS for every enforcement-related write endpoint (Task submission, Request creation, TemporaryAccessGrant activation/revocation, approval decisions):

- **SEC-004. Rate limiting**, scoped per Member and per device, tuned to reject clearly abusive request volume (e.g. rapid repeated Request creation) without penalising normal use (a child legitimately submitting several tasks in a session).
- **SEC-005. Idempotency and duplicate suppression** — already specified functionally in `29_API_AND_BACKEND_REQUIREMENTS.md` §29.2; restated here as a security control since it also prevents a deliberate replay-based duplication attempt, not only accidental retries.
- **SEC-006. One-active-request-per-context limits**, where appropriate — e.g. a Member cannot hold unlimited simultaneous pending Requests against the same rule/context, preventing an approval-queue-flooding pattern.
- **SEC-007. Server-side role/ownership validation** on every write — restates §29.7/SEC-003 as a named control.
- **SEC-008. Request-size limits** on all endpoints, particularly free-text fields (rejection notes, request clarification text — `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`).
- **SEC-009. Replay protection** — a captured, valid request (e.g. an approval action) must not be replayable to produce a duplicate or out-of-sequence effect; ties into the idempotency-key mechanism (§29.2) plus a request-freshness check (timestamp/nonce) for actions not already idempotency-keyed.
- **SEC-010. Audit logging for suspicious behaviour** — beyond the ordinary accountability audit log (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.3), rate-limit triggers, repeated failed authorization attempts, and other suspicious patterns are logged separately for review, feeding `30_ADMIN_AND_SUPPORT.md`'s support tooling.
- **SEC-011. Notification-flooding protection** — a child cannot force unlimited push/reminder notifications to a parent's device (e.g. by repeatedly creating and cancelling Requests); ties into the confirmed reminder-interval model (DEC-41: one automatic reminder, one independent nudge, no further reminders after both are used) as the existing structural limit, reinforced by rate limiting at the API layer.

## 24.4 Data-in-transit and data-at-rest

**SEC-012. All API traffic encrypted in transit** (TLS), no exceptions, including internal service-to-service calls if the backend is decomposed into multiple services (Phase 7 infrastructure decision, not fixed here).

**SEC-013. Sensitive fields encrypted at rest** — at minimum, any authentication credential material and the `apple_token_opaque_ref` field (`19_DATA_MODEL.md`), even though the token itself is already Apple-opaque, as defence in depth.

## 24.5 Authentication and session management

**SEC-014. Member authentication** uses the platform's standard secure mechanism (RECOMMENDATION: Sign in with Apple or equivalent, consistent with the `.child`/Family Sharing model already assumed in `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.2) — not a Themis-built password system for child accounts, consistent with `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4's age-appropriate account model principle.

**SEC-015. Session/token expiry and revocation** — sessions must be revocable server-side (supports SEC-002) and expire on a defined schedule (RECOMMENDATION, not yet founder-confirmed: 30-day sliding expiry for parent/guardian sessions, shorter for child-device sessions given the higher adversarial-use assumption per SEC-001).

## 24.6 Security controls with no identified threat (end-of-Phase-6 cross-check)

A review of §24.2–24.5 against the confirmed threat model found no control listed above that lacks a corresponding threat scenario — each control traces to a specific identified risk (child-as-adversarial-client, device/Member removal lag, cross-role privilege escalation, replay/duplication, data exposure in transit/at rest, credential compromise). **No speculative control was added without a named threat.**

One item is flagged as the reverse gap — a threat without full identified controls, carried forward:

- **SEC-016 [OPEN].** The trusted-time model (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7a) itself depends on the device's monotonic clock being difficult to manipulate; if a jailbroken or otherwise compromised device could falsify monotonic-clock readings, the trusted-time reconciliation could be defeated. This is a NEEDS REAL-DEVICE TECHNICAL SPIKE item (related to OQ-32) rather than a control that can be specified without that research, and is recorded here as an open item rather than a control this document invents a false sense of completeness around.

## 24.7 Summary: security controls with no threat vs. threats with no control

- **Controls with no threat:** none identified (§24.6).
- **Threats with no control:** SEC-016 (monotonic-clock manipulation on a compromised device) — genuinely open, pending real-device spike research, not silently left unaddressed.
