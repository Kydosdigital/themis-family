# 15. Child and Teen Experience

**Status:** Phase 7 draft
**Depends on:** `03_PERSONAS.md`, `04_USER_JOURNEYS.md`, `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4b (DEC-53), `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `16_DEVICE_ENFORCEMENT.md`

## 15.1 Purpose

This document specifies the Child and Teen (`experience_segment`) facing experience, with particular attention to delivering the **child-transparency product requirement confirmed in DEC-53** ("Themis is active," `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4b) concretely, and to the "agreement, not punishment" product philosophy that has governed copy tone since Phase 1.

## 15.2 The "Themis is active" indicator — CONFIRMED, implements DEC-53

**CONFIRMED REQUIREMENT.** The child/teen device experience must surface a persistent-enough-to-notice indicator (e.g. a small badge or status line, exact placement a Phase-7-adjacent design decision, not fixed here) confirming Themis Family controls are in effect. From this indicator, or directly reachable from it, the child must be able to see, in age-appropriate language for their `experience_segment`:

- **That controls are active** — plainly stated, not buried.
- **What types of things Themis controls** — broad categories ("apps and websites, on a schedule your parent set"), not an exhaustive technical list.
- **What information parents can see** — two categories: (1) Themis-owned information in plain terms ("your parent can see which Themis rules you have, which tasks you've completed, your requests for extra time or access, temporary access I granted you, and your device protection status"), and (2) Screen Time activity information that Apple makes available through its parental reporting interface, where enabled/supported ("some activity data that Apple shares with your parent through Screen Time reports").
- **What parents cannot see** — stated as a genuine reassurance, not marketing copy: "Themis doesn't let your parent read your messages, see your full search history, or get a minute-by-minute feed of what you do. Themis also doesn't give your parent the raw app and website activity data that Apple has — your parent can only see activity information through Apple's own parental reports, not through Themis." (Category B is structurally inaccessible to Themis at all per `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.5, so these are true statements, not policy promises that could later be broken by a technical change.)
- **Why a specific app/site is currently restricted** — shown at the point of restriction (the shield screen itself, `16_DEVICE_ENFORCEMENT.md`), naming the rule in plain terms ("This app is limited during school hours" rather than a raw rule ID).
- **How to ask for an exception** — a direct link into the existing Request flow (`12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`), not a separate mechanism.

**Boundary (also CONFIRMED, per the founder's explicit instruction):** this requirement does not extend to exposing enforcement internals, exact staleness thresholds, Local Enforcement Plan structure, or trusted-time/clock-tampering detection logic — anything that would materially aid circumvention. Transparency about *that* controls exist and broadly *what* they do is required; a technical manual for defeating them is not, and the line is drawn at that distinction, not at a specific list of forbidden phrases.

## 15.3 Task and request flows (child-facing)

**CONFIRMED, restates existing confirmed behaviour from the child's viewpoint, not new decisions:**
- Task submission (FR-030) shows the confirmed Verification Type distinction honestly: a Parent Approval task shows "Waiting for [parent]'s approval," never implying instant credit; an Automatic Verification task (a reading/focus timer) shows real-time progress consistent with its Session Type (Active Engagement Session pauses on backgrounding per DEC-37; Focus Session may continue).
- A Deadline Lock approaching its deadline shows the confirmed Provisional Approval Grace Period countdown (DEC-40) honestly — "Submitted, waiting for approval — you're protected until [time]" — never implying the child is already fully clear before the parent decides.
- A Focus Session violation shows the confirmed **Interrupted** outcome with strictly neutral, non-punitive copy (DEC-42): no blame language, immediate option to start fresh.
- Request clarification (FR-042) is presented as the confirmed single bounded exchange (one prompt, one reply, then a decision) — the UI must not imply an open-ended chat with the parent.
- Free Pass / Temporary Access Grant expiry and early revocation (§16.9/§16.9a) are shown honestly: a revoked grant shows "Revocation sent" then "Access revoked" (mirrors the parent-facing pattern, `16_DEVICE_ENFORCEMENT.md` §16.9a) rather than an unexplained sudden restriction.

## 15.4 Age-appropriate segmentation

**CONFIRMED**, per DEC-24: copy, information density, and interaction patterns differ between the Child and Teen `experience_segment` (e.g. simpler language and larger touch targets for Child; more autonomy-respecting framing for Teen — exact copy differences are a content-design exercise, not specified line-by-line here), but the *substance* of what is disclosed under §15.2 does not differ by segment — a Child is not told less about what Themis controls or what parents can see, only told it in simpler language.

## 15.5 Essential access reassurance

**CONFIRMED, restates BR-222 from the child's viewpoint:** the child-facing experience must make clear, at an appropriate moment (e.g. first-run or via the "Themis is active" indicator's detail view), that emergency calling and OS-level emergency functionality are never restricted by Themis, regardless of any other rule or state — this is not merely a technical fact but a stated reassurance the child can rely on.

## 15.6 Error and edge-case handling (child-facing)

Detailed failure-path enumeration (e.g. device offline during a task submission, a request expiring unresolved, a session abandoned per DEC-49) is carried into `26_ERROR_AND_EDGE_CASE_CATALOGUE.md` rather than duplicated here; this document's role is to confirm that whatever those failure paths turn out to require, the child-facing copy for each must remain consistent with §15.2's transparency requirement and the neutral, non-punitive tone established since Phase 3.

## 15.7 Cross-check

Reviewed against `23_PRIVACY_AND_CHILD_SAFETY.md` §23.4b: every element of DEC-53's confirmed requirement (active-controls indicator; what's controlled; what parents can/cannot see; why restricted; how to request an exception) is addressed in §15.2 above, with no gap. No implementation/security detail beyond the confirmed boundary is exposed anywhere in this document's specified copy.
