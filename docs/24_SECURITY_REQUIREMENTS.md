# 24. Security Requirements

**Status:** Phase 6, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` DEC-52 through DEC-59)
**Depends on:** `29_API_AND_BACKEND_REQUIREMENTS.md` §29.7/§29.8, `18_ROLES_AND_PERMISSIONS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`, `19_DATA_MODEL.md`

**Amendment note (this round):** SEC-014 originally risked conflating Apple's Family Controls `.child` authorisation (a separate, platform-level concern) with Themis's own backend authentication. §24.5 is rewritten below to separate these explicitly and confirm a device-pairing model for the child device that does not require a child-held Apple ID sign-in to Themis's backend.

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

**SEC-014. Member authentication — CONFIRMED V1 ARCHITECTURE, rewritten this amendment round to separate two distinct concerns that the original draft risked conflating: Apple's Family Controls `.child` authorisation (§27.2, a platform-level, per-device concern) and Themis's own backend identity/authentication (a Themis concern). These are not the same mechanism and must not be modelled as one.**

- **Owner/Guardian authentication.** The Owner and Guardian authenticate to Themis's backend using a normal secure consumer identity flow. **Preferred V1 option: Sign in with Apple**, consistent with the product being an iOS app; the exact final identity provider may remain an implementation decision if necessary, but is not a Themis-built password system.
- **Child/Teen device authentication — does not require the child to sign in with Apple or hold a separate Themis account.** The child does not need an independent Apple ID sign-in or a Themis account simply to operate the managed child experience. Instead, confirmed V1 flow:
  1. The parent creates the child's Member profile in Themis.
  2. The parent initiates device pairing for that Member.
  3. The child's device receives a one-time pairing code, QR code, or equivalent secure enrolment flow (exact mechanism is an implementation decision, not fixed here).
  4. The backend issues a **scoped device credential** tied to the household, the specific child Member record, and the specific enrolled device.
  5. That device credential carries **only child-device permissions** (per `18_ROLES_AND_PERMISSIONS.md`) — it is not a general-purpose account credential.
  6. The device credential is **revocable server-side** (supports SEC-002).
  7. Removing the device revokes its credential **atomically** as part of the same operation, consistent with SEC-002's immediate-loss-of-access requirement.
- **Family Controls `.child` authorisation is separate and unaffected.** Apple's `.child`/Family Sharing authorisation (§27.2) still occurs through Apple's own framework, on-device, independent of the above. **The device credential described above is never derived from, or treated as equivalent to, Family Controls authorisation** — one is Themis's backend identity for the device, the other is Apple's platform permission for Family Controls APIs; a device can hold one without the other, and confusing them would misattribute a platform-level authorisation change as a Themis identity event or vice versa.
- Affected documents updated for consistency this round: `19_DATA_MODEL.md` (Device entity's credential fields, distinct from `platform_authorization_status`), `29_API_AND_BACKEND_REQUIREMENTS.md` (device-credential issuance/revocation as its own concern, not layered on Family Controls state), and relevant device-onboarding requirements (`16_DEVICE_ENFORCEMENT.md` pairing flow references).

**SEC-015. Session/token expiry and revocation** — sessions must be revocable server-side (supports SEC-002) and expire on a defined schedule (RECOMMENDATION, not yet founder-confirmed: 30-day sliding expiry for parent/guardian sessions, shorter for child-device sessions given the higher adversarial-use assumption per SEC-001).

**SEC-017. One-active-household-binding invariant, closes OQ-42 (DEC-60).**
- **Server-side enforcement:** the backend must never permit a child device to have two or more simultaneously active Themis household bindings. This is an invariant, not a UI-level recommendation. **Normal transfer (device moving households):** an existing Owner/Guardian removes the device from its current household (triggering atomic credential revocation), the current household records the removal, notifies that household's Owner/Guardian, clears the old household binding, and only then permits the device to begin pairing with a new household. The new household issues a fresh scoped device credential (never reuses the old credential). The old household's enforcement state immediately reflects the device as no longer Protected. **Recovery path (prior household unreachable):** the system shows a blocking state ("Device already belongs to another Themis household") instead of silently overwriting the binding. A deliberate secure recovery/reset flow is provided, requiring authorised-adult verification (mere physical possession is not sufficient). Any previous device credential is invalidated before a new household binding becomes active. The prior household's state is updated to reflect the device as no longer under their protection once transfer/recovery is confirmed.
- Covered by SEC-017: server-side enforcement of the invariant, atomic credential revocation, no silent reassignment, authenticated recovery, audit trail, previous-household state invalidation, replay/race handling during simultaneous pairing attempts.

## 24.6 Security controls with no identified threat (end-of-Phase-6 cross-check, amended Phase 7)

A review of §24.2–24.5 against the confirmed threat model found no control listed above that lacks a corresponding threat scenario — each control traces to a specific identified risk (child-as-adversarial-client, device/Member removal lag, cross-role privilege escalation, replay/duplication, data exposure in transit/at rest, credential compromise, one-household-binding invariant). **No speculative control was added without a named threat.**

One item is flagged as the reverse gap — a threat without full identified controls, carried forward:

- **SEC-016 [OPEN, kept open this amendment round per explicit founder instruction — do not invent a control before the spike].** The trusted-time model (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7a) itself depends on the device's monotonic clock being difficult to manipulate; if a jailbroken or otherwise compromised device could falsify monotonic-clock readings, the trusted-time reconciliation could be defeated. This is a NEEDS REAL-DEVICE TECHNICAL SPIKE item (tracked as **OQ-40**, related to OQ-32) rather than a control that can be specified without that research, and is recorded here as an open item rather than a control this document invents a false sense of completeness around. **Confirmed secure default in the meantime:** where the trusted-time model's integrity evidence is uncertain, it must fail to the **"Timing could not be verified"** escalation (§17.7a) rather than granting an enforcement-sensitive advantage (i.e. crediting a submission as on-time) on unverified evidence. Degrading to human judgement on uncertain evidence, never defaulting to the more permissive outcome, is the standing behaviour until the spike resolves what can actually be trusted.

## 24.7 Summary: security controls with no threat vs. threats with no control

- **Controls with no threat:** none identified (§24.6).
- **Threats with no control:** SEC-016 (monotonic-clock manipulation on a compromised device) — genuinely open, pending real-device spike research, not silently left unaddressed.
