# Backend rule

The backend owns shared business state, not runtime Screen Time enforcement.

Requirements:
- enforce roles server-side
- use scoped, revocable child-device credentials
- enforce one active household binding per device
- use idempotency for retryable writes
- use atomic conflict handling for approvals/resolutions
- maintain resolution versioning where specified
- treat child-device requests as potentially adversarial at the API boundary
- minimise notification payloads
- never ingest Apple raw Screen Time data that the approved UK V1 architecture cannot receive

Do not create support/admin endpoints that allow staff to make parental decisions such as editing rules, approving tasks or granting Free Passes.
