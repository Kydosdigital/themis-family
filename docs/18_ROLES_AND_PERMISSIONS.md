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

**BR-101. Ownership transfer and Owner exit (CONFIRMED as final for V1 — DEC-45, closes OQ-20).**
Only the current Owner may transfer ownership, and only to the household's existing Guardian (not to a Teen/Child, and not to a newly-invited person in the same action — a transfer target must already hold the Guardian role, invited and accepted as a separate, prior step). A household must never be left with zero Owners; a transfer is a single atomic operation that makes the target the new Owner and demotes the previous Owner to Guardian in the same transaction.

An Owner who wants to leave the household has exactly two V1 paths: **(A)** invite a Guardian if none exists, wait for them to accept, transfer ownership to them, and then leave; or **(B)** delete the household outright (BR-106). V1 explicitly does not support: an ownerless household in any state, even transiently; ownership transfer directly to a Child or Teen; combining an invite and a transfer into one simultaneous action; or multiple households representing a split-custody arrangement (each parent would need their own separate household in V1, with no shared rule set between them — this is a real limitation for separated families, not an oversight, and may be revisited post-V1 if usage shows it is a common, painful scenario).

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

**OQ-20 [CLOSED — resolved by DEC-45].** A household must always have exactly one Owner. If an Owner wants to leave, V1 supports exactly two paths: (A) invite/retain a Guardian, transfer ownership to that Guardian, then leave; or (B) delete the household. V1 explicitly does NOT support: ownerless households, ownership transfer directly to a Child/Teen, simultaneous invite-and-transfer in one action, or multiple households representing split custody. See BR-101 below, confirmed as final for V1.

**OQ-21 [NEW].** Can a Teen ever be granted any elevated permission (e.g. approving a younger sibling's task) as a trust-building feature, or is that permanently out of scope?
- *Why it matters:* Not raised in the brief, but a natural future extension of the "trust increases over time" positioning (review dates, negotiation).
- *Recommended default:* FUTURE FEATURE, explicitly not V1. No architecture decision needs to be made now beyond not hard-coding "only Owner/Guardian can ever approve" at a level that would make this impossible later.
- *Blocks:* None for V1.
