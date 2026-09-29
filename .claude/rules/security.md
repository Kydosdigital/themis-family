# Security and privacy rule

Preserve the confirmed controls in `docs/24_SECURITY_REQUIREMENTS.md` and `docs/23_PRIVACY_AND_CHILD_SAFETY.md`.

Key invariants:
- owner/guardian destructive permissions are enforced server-side
- removed devices and members lose credentials atomically
- one active household binding per managed device
- device re-pairing never silently overwrites a prior binding
- child-device credentials are scoped and revocable
- request/replay/rate-limit protections exist at the API layer
- push payloads contain minimum necessary information
- no message reading, covert monitoring or backend raw Screen Time history
- support access is scenario-scoped and auditable

Do not log secrets, raw authentication tokens, Apple opaque activity tokens, private request text, or sensitive child content unnecessarily.

If timing integrity is uncertain, use the approved secure default: "Timing could not be verified" and require parent resolution rather than granting an enforcement-sensitive advantage.
