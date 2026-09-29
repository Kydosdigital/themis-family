# Architecture rule

Keep Themis architecture aligned with the approved Phase 5 model.

- Backend is authoritative for shared business state.
- Child device is authoritative for immediate device-enforcement execution.
- Push is a latency optimisation, never the sole correctness mechanism.
- Local Enforcement Plan is device-local derived state.
- Approval and grant races are resolved server-side with atomic/idempotent operations.
- Temporary access expiry must not depend on a server push at expiry time.
- One managed device can have one active Themis household binding at a time.
- Derived protection status must never imply more certainty than the evidence supports.

Do not introduce a second source of truth for the same state.

Prefer explicit state machines and deterministic transitions over loosely coupled flags.

Any architecture change that contradicts `docs/19_DATA_MODEL.md`, `docs/20_STATE_MACHINES.md`, `docs/29_API_AND_BACKEND_REQUIREMENTS.md`, or DEC-60 requires a spec amendment.
