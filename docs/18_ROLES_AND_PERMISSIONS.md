# 18. Roles and Permissions

**Status:** Phase 3 draft
**Depends on:** `00_PRODUCT_OVERVIEW.md` §1.3, `35_DECISION_LOG.md` DEC-14

---

## 18.1 Roles

| Role | Cardinality per household | Defined by |
|---|---|---|
| Household Owner | Exactly one | DEC-14 |
| Guardian | Zero or one (V1 cap) | DEC-14 |
| Teen | Zero or more | DEC-12 |
| Child | Zero or more | DEC-12 |

A household must have at least one Owner at all times (see BR-101, ownership transfer). Teen and Child are not "roles" in the permission sense so much as UX segments applied to the underlying "household member, minor" role — for permissions purposes they are functionally identical except where explicitly noted (e.g. request wording), since neither can approve, administer, or configure rules.

---

## 18.2 Permissions matrix

Legend: ✅ = can perform unilaterally, 🔶 = can perform, subject to a stated rule, ❌ = cannot perform.

| Action | Owner | Guardian | Teen | Child |
|---|---|---|---|---|
| Create rule | ✅ | ✅ | ❌ | ❌ |
| Modify rule | ✅ | ✅ | ❌ | ❌ |
| Delete rule | ✅ | ✅ | ❌ | ❌ |
| Pause rule | ✅ | ✅ | ❌ | ❌ |
| Grant exception / temporary access | ✅ | ✅ | ❌ | ❌ |
| Approve task completion | 🔶 (first valid decision wins — BR-102) | 🔶 (first valid decision wins — BR-102) | ❌ | ❌ |
| Reject task completion | 🔶 (BR-102) | 🔶 (BR-102) | ❌ | ❌ |
| Add child device | ✅ | ✅ | ❌ | ❌ |
| Remove child device | ✅ | ✅ | ❌ | ❌ |
| Add Guardian (invite) | ✅ | ❌ | ❌ | ❌ |
| Remove Guardian | ✅ | ❌ | ❌ | ❌ |
| View reporting | ✅ | ✅ | ❌ (sees own status/agreement only — see `15_CHILD_AND_TEEN_EXPERIENCE.md`, later phase) | ❌ |
| Change subscription | ✅ | ❌ | ❌ | ❌ |
| Delete household | ✅ | ❌ | ❌ | ❌ |
| Submit task completion | ❌ | ❌ | ✅ (own tasks) | ✅ (own tasks) |
| Submit request (extra time, exception, temporary access) | ❌ | ❌ | ✅ (own) | ✅ (own) |
| Propose a rule change | ❌ | ❌ | ❌ (FUTURE FEATURE — brief §T2, not V1) | ❌ |
| Change school allowlist | ✅ | ✅ | ❌ | ❌ |
| Transfer ownership | ✅ (to the Guardian only — BR-101) | ❌ | ❌ | ❌ |

---

## 18.3 Business rules

**BR-101. Ownership transfer.**
Only the current Owner may transfer ownership, and only to the household's existing Guardian (not to a Teen/Child, and not to a newly-invited person in the same action — a transfer target must already hold the Guardian role). A household must never be left with zero Owners; a transfer is a single atomic operation that makes the target the new Owner and demotes the previous Owner to Guardian in the same transaction.

**BR-102. Approval conflict resolution.**
When both an Owner and a Guardian act on the same pending approvable item (task completion or request) within the window before either action is durably recorded, the first action to be durably recorded (per an atomic conditional state transition — see OQ-03a) wins. The other actor's action is rejected with a "this has already been resolved" response, not silently discarded — they must be told what the resolved outcome was.

**BR-103. Guardian cannot self-invite.**
Only the Owner can invite a Guardian. A Guardian cannot invite a second Guardian (V1 caps Guardians at one, per DEC-14) and cannot remove themselves and re-invite as Owner.

**BR-104. Removing a Guardian.**
Only the Owner may remove the Guardian. On removal, all of the Guardian's pending un-actioned approvals are not automatically voided — they remain pending for the Owner alone to resolve (removing a Guardian must never leave a request in limbo).

**BR-105. Teen/Child accounts cannot self-elevate.**
No client-side setting or request can grant a Teen or Child account any permission in the "Owner/Guardian" column of §18.2. All permission checks are enforced server-side (see `24_SECURITY_REQUIREMENTS.md`, Phase 6) — the app's UI hiding a control is not a substitute for a server-side authorisation check.

**BR-106. Household deletion.**
Only the Owner may delete a household. Deletion is a destructive, confirmable action (not covered further here — full lifecycle and data-retention behaviour belongs in `23_PRIVACY_AND_CHILD_SAFETY.md`/`24_SECURITY_REQUIREMENTS.md`, Phase 6).

---

## 18.4 Open questions surfaced

**OQ-20 [NEW].** BR-101 requires ownership transfer to go only to an existing Guardian. What happens if the Owner wants to leave the household (e.g. divorce, family breakup) and there is no Guardian to transfer to?
- *Why it matters:* A household cannot be left ownerless (BR-101), but the brief does not define a path for an Owner who wants to exit with no successor.
- *Recommended default:* Require the Owner to either invite a Guardian and transfer to them first, or delete the household outright. No "orphaned household" state is supported in V1. Revisit if V1 usage shows this is a common, painful scenario (e.g. separating parents where neither wants to be locked in).
- *Blocks:* `20_STATE_MACHINES.md` (Phase 5) — household lifecycle state machine.

**OQ-21 [NEW].** Can a Teen ever be granted any elevated permission (e.g. approving a younger sibling's task) as a trust-building feature, or is that permanently out of scope?
- *Why it matters:* Not raised in the brief, but a natural future extension of the "trust increases over time" positioning (review dates, negotiation).
- *Recommended default:* FUTURE FEATURE, explicitly not V1. No architecture decision needs to be made now beyond not hard-coding "only Owner/Guardian can ever approve" at a level that would make this impossible later.
- *Blocks:* None for V1.
