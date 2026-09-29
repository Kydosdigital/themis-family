# Claude Design Pass 1 Amendment Prompt

Pass 1 has been reviewed against the approved Themis Family requirements.

The architecture is **conditionally approved**. Do NOT start Pass 2 yet.

Read:
- `docs/implementation/DESIGN_PASS1_REVIEW.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- the existing Pass 1 design

Apply every correction in DESIGN_PASS1_REVIEW.md.

## Important

Preserve existing screen IDs.

Where a new state is required, prefer a state suffix instead of renumbering. For example:
- P-010 · Already paired
- P-010 · Recovery required

Do not redesign unrelated approved flows while applying these changes.

## Resolve Claude Design's six open questions exactly as recorded

1. Passing test before Protection Activated: YES, hard requirement.
2. Free Pass preview: show known scheduled restrictions that begin during the pass, but do not silently override them.
3. Apple shield UI: provisional/minimal until real-device spike.
4. Automatic Verification V1: Active Engagement Session and Focus Session only; general homework uses Parent Approval.
5. Guardian ordinary approval/Free Pass authority: YES, same as Owner for ordinary parenting actions.
6. Separate child "Applied on device" push: NO by default; use defined approval notification plus in-app/local state.

## Structural fixes required before Pass 2

- remove unapproved one-device-per-child cap wording
- add DEC-60 already-paired/recovery state
- remove unconfirmed 10-minute pairing-code TTL
- remove Face ID-specific architecture wording
- soften Phone/Messages/Maps technical guarantees while preserving emergency-access policy
- correct Device Offline wording so it does not imply indefinite verified enforcement
- change billing-grace copy from "while Apple retries" to "during Apple's Billing Grace Period"
- make permission recovery platform-safe
- tighten browsing/search-history transparency copy
- remove singular-vs-plural parent wording as a Child/Teen style distinction
- reduce onboarding friction by turning some IDs into lightweight states rather than mandatory full-screen stops
- make Automatic Verification unavailable for generic homework

## Output

Update the Pass 1 artifact.

At the bottom add:
"Founder review amendments applied"

Then list:
- each correction applied
- any item that could not be represented without changing product behaviour
- any genuinely new question discovered

STOP again after the amended Pass 1.

Do not start visual exploration / Pass 2 until the amended structure is reviewed.
