# 06. Functional Requirements

**Status:** Phase 3 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md`, all Phase 3 specification documents

This document (a) specifies the functional requirements not covered by a dedicated Phase 3 specification document (household/membership management, device authorisation), and (b) serves as the index tying every HLR to the FR(s) that decompose it, across all Phase 3 documents. Detailed rule-engine, task/approval, request, and school-access functional requirements live in their own documents (`10`, `11`, `12`, `13`) rather than being duplicated here.

---

## 6.1 Household and membership functional requirements

## FR-001. Create household
- **Actor:** A new user (becomes Owner)
- **Trigger:** Sign-up completes
- **Preconditions:** None
- **Happy path:** User creates an account, which creates exactly one household with them as Owner. **Account Creation Complete** is reached at this point (DEC-25) — the app does not yet describe anything as protected.
- **Failure paths:** Account creation fails (network, duplicate account, etc.) — standard auth failure handling, detailed in `24_SECURITY_REQUIREMENTS.md` (Phase 6).
- **Permissions:** N/A (this action creates the Owner role)
- **Data required:** Owner's account credentials, household name (optional, defaults to something sensible e.g. "[Owner]'s family")
- **Release:** V1 / Must

## FR-002. Add a child
- **Actor:** Owner or Guardian
- **Trigger:** Parent adds a child during onboarding or later from Settings
- **Preconditions:** Household exists
- **Happy path:** Parent enters the child's name and explicitly selects "Child experience" or "Teen experience" (copy: *"Choose the experience that best fits your child. You can change this later."* — DEC-24). No date of birth is collected for this purpose. Child record is created; device authorisation (FR-006) follows as a distinct next step.
- **Failure paths:** None specific beyond standard form validation.
- **Permissions:** Owner, Guardian only
- **Data required:** Child's name, UX segment selection (Child/Teen)
- **Business rules:** BR-223 (segment is changeable later without deleting/recreating the child record — restates DEC-24/HLR-022)
- **Release:** V1 / Must

## FR-003. Change a child's UX segment later
- **Actor:** Owner or Guardian
- **Trigger:** Parent changes a child's segment from Child to Teen (or vice versa) in Settings
- **Preconditions:** Child record exists
- **Happy path:** Parent selects the new segment; the child's UI presentation updates on next app launch/sync. No data is lost; existing rules continue to apply to the same child record.
- **Business rules:** BR-223
- **Release:** V1 / Must

## FR-004. Invite a Guardian
- **Actor:** Owner only
- **Trigger:** Owner invites a second parent/carer
- **Preconditions:** Household has no existing Guardian (V1 cap of one — DEC-14)
- **Happy path:** Owner sends an invitation (e.g. via a generated link or code); invitee accepts and is added as Guardian, gaining the permissions in `18_ROLES_AND_PERMISSIONS.md` §18.2.
- **Failure paths:** Household already has a Guardian → invite action is unavailable/blocked with a clear message (BR-103, `18_ROLES_AND_PERMISSIONS.md`).
- **Permissions:** Owner only (BR-103)
- **Release:** V1 / Must

## FR-005. Remove a Guardian
- **Actor:** Owner only
- **Trigger:** Owner removes the Guardian
- **Preconditions:** A Guardian exists
- **Happy path:** Guardian is removed from the household; their pending un-actioned approvals remain pending for the Owner alone (BR-104, `18_ROLES_AND_PERMISSIONS.md`).
- **Permissions:** Owner only
- **Business rules:** BR-104
- **Release:** V1 / Must

## FR-006. Add and authorise a child device
- **Actor:** Owner or Guardian
- **Trigger:** Parent sets up a device for a child
- **Preconditions:** Child record exists (FR-002); device is part of the family's Apple Family Sharing group, signed into that child's own Child Apple Account (DEC-26 — see `03_PERSONAS.md` §3.4 and HLR-023; shared-device scenarios are explicitly out of scope — OQ-17)
- **Happy path:** Parent is guided, in plain English, through Apple Family Sharing / Family Controls authorisation on the child's device. The app verifies successful authorisation (not merely that the flow was clicked through) before allowing rule creation for that device.
- **Failure paths:** Authorisation flow is abandoned or fails → device is not usable for rule enforcement; the household shows an incomplete/unprotected state for that child (not a false "Protected" status — see HLR-013).
- **Permissions:** Owner, Guardian only
- **Business rules:** Restates HLR-023/DEC-26 (single-device-per-child assumption)
- **Dependencies:** TECHNICAL DEPENDENCY — Apple's Family Controls distribution entitlement (RISK-01)
- **Release:** V1 / Must

## FR-007. Remove a child device
- **Actor:** Owner or Guardian
- **Trigger:** Parent removes/replaces a device
- **Happy path:** Device is de-authorised; any rules targeting that child are retained (they are attached to the child record, not the device) and will apply again once a new device is authorised for that child.
- **Permissions:** Owner, Guardian only
- **Release:** V1 / Must

## FR-008. Reach "Themis Protection Activated" state
- **Actor:** System (verification), Owner/Guardian (the actions that lead here)
- **Trigger:** Completion of FR-006 plus at least one rule's test shield cycle
- **Preconditions:** Device authorisation valid (FR-006); at least one rule target selected (FR-010, `10_RULE_ENGINE_SPECIFICATION.md`)
- **Happy path:** A real test shield is applied to a selected target, confirmed applied, then successfully removed, and the resulting (unshielded) state is verified by the app. Only once all of this succeeds does the household/child show **Themis Protection Activated**. Before this point, the UI shows an explicit incomplete-setup state, never an implied-protected one (DEC-25, HLR-020).
- **Failure paths:** Test shield fails to apply or fails to remove correctly → protection is not marked Activated; parent is shown specifically what failed, not a generic error.
- **Business rules:** Restates DEC-25/HLR-020 as a functional requirement with concrete pass/fail conditions
- **Release:** V1 / Must (elevated from Should — DEC-25)

---

## 6.2 HLR → FR/specification traceability index

This is the Phase 3 decomposition record. A full formal Traceability Matrix (with acceptance criteria and test scenarios added) is a Phase 7 deliverable (`32_TRACEABILITY_MATRIX.md`); this table is Phase 3's contribution to it.

| HLR | Decomposed into | Status |
|---|---|---|
| HLR-001 (Household/membership) | FR-001 to FR-005 | Decomposed |
| HLR-002 (Role-based permissions) | `18_ROLES_AND_PERMISSIONS.md` §18.2, BR-101 to BR-106 | Decomposed |
| HLR-003 (Device authorisation) | FR-006, FR-007 | Decomposed |
| HLR-004 (Rule creation/targeting) | FR-010 (`10_RULE_ENGINE_SPECIFICATION.md`) | Decomposed |
| HLR-005 (Rule types) | FR-013, FR-014, FR-015 (`10_RULE_ENGINE_SPECIFICATION.md`) | Decomposed |
| HLR-006 (Verification Type) | FR-016 (`10_RULE_ENGINE_SPECIFICATION.md`), FR-030–FR-033 (`11_TASK_AND_APPROVAL_SPECIFICATION.md`) | Decomposed |
| HLR-007 (Approval workflow) | FR-030, FR-031 (`11_TASK_AND_APPROVAL_SPECIFICATION.md`) | Decomposed |
| HLR-008 (Non-response handling) | FR-032 (`11_TASK_AND_APPROVAL_SPECIFICATION.md`) | Decomposed |
| HLR-009 (Requests/negotiation) | FR-040 to FR-043 (`12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`) | Decomposed |
| HLR-010 (Always Allowed/essential) | FR-050, FR-053 (`13_SCHOOL_AND_ESSENTIAL_ACCESS.md`) | Decomposed |
| HLR-011 (School Mode) | FR-051, FR-052 (`13_SCHOOL_AND_ESSENTIAL_ACCESS.md`) | Decomposed |
| HLR-012 (Website control) | Referenced in FR-010 (`10_RULE_ENGINE_SPECIFICATION.md` — Controlled Targets); no dedicated FR yet | **Partial — see §6.3** |
| HLR-013 (Protection status) | Referenced in FR-006, FR-008; full spec deferred | **NOT YET DECOMPOSED — see §6.3** |
| HLR-014 (Offline-first enforcement) | FR-017 (`10_RULE_ENGINE_SPECIFICATION.md`), FR-044 (`12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`) | Decomposed (principle); full state-machine detail is Phase 5 |
| HLR-015 (Reporting) | Not yet decomposed | **Deferred to Phase 6** (`22_REPORTING_AND_ANALYTICS.md`) — correctly out of Phase 3 scope |
| HLR-016 (Privacy by design) | Not yet decomposed | **Deferred to Phase 6** (`23_PRIVACY_AND_CHILD_SAFETY.md`) — correctly out of Phase 3 scope |
| HLR-017 (Subscription management) | Not yet decomposed | **Deferred to Phase 6** (`25_SUBSCRIPTIONS_AND_BILLING.md`) — correctly out of Phase 3 scope |
| HLR-018 (No overstated capability) | BR-221 (`13_SCHOOL_AND_ESSENTIAL_ACCESS.md`), restated generally here in §6.3 | Decomposed (as a cross-cutting documentation constraint) |
| HLR-019 (Age-segmented experience) | Not yet decomposed | **Deferred to Phase 5/6** (`15_CHILD_AND_TEEN_EXPERIENCE.md`, `14_PARENT_EXPERIENCE.md`) — UX-detail documents not in Phase 3's list |
| HLR-020 (Onboarding time-to-value / two-stage model) | FR-008 | Decomposed |
| HLR-021 (Launch region) | No FR needed — a scope/marketing constraint, not a system behaviour (`02_SCOPE_AND_RELEASE_STRATEGY.md`) | Not applicable (correctly not decomposed into a functional requirement) |
| HLR-022 (Age-segment selection) | FR-002, FR-003 | Decomposed |
| HLR-023 (Shared-device exclusion) | FR-006 (precondition), FR-054 (`13_SCHOOL_AND_ESSENTIAL_ACCESS.md`) | Decomposed (as a documentation/scope constraint) |
| HLR-024 (No unverified platform claims) | Restated as a general documentation rule in §6.3; specific instance in `04_USER_JOURNEYS.md` §4.6 | Decomposed (as a cross-cutting documentation constraint) |

---

## 6.3 Cross-cutting business rules (apply across specifications)

**BR-223.** A child's UX segment (Child/Teen) selection is changeable at any time by an Owner or Guardian, does not require deleting or recreating the child's record, and does not retroactively alter any existing rule's configuration (only its presentation).

**BR-224 (restates HLR-018/DEC-05/DEC-17 as a general rule, not just a rule engine or School Mode-specific one).** No functional area's documentation, in-product copy, or notification text may claim or imply a capability that has not been verified via the technical spike, nor describe the product as "unhackable" or "impossible to bypass." This applies to every specification document produced from Phase 3 onward, not only to `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` (where it was first formalised as BR-221).

**BR-225 (restates HLR-024/DEC-31 as a general rule).** No specification, error message, or piece of in-product copy may assert a specific, unverified third-party (Apple/iOS) platform behaviour as fact. Failure/recovery requirements must be phrased in terms of Themis Family's own detection and response (e.g. "if authorisation becomes unavailable...") rather than asserting a cause (e.g. "when an iOS update revokes authorisation..."), unless that exact behaviour is explicitly documented and guaranteed by Apple.

---

## 6.4 Items requiring a dedicated specification document not yet produced

Per §6.2, two HLRs are only partially decomposed by Phase 3's actual document list (which the founder specified as: `06`, `10`, `11`, `12`, `13`, `18`):

- **HLR-012 (Website control)** has no document dedicated solely to it — it is currently folded into `10_RULE_ENGINE_SPECIFICATION.md`'s general Controlled Targets concept. This is likely sufficient (website control is a targeting detail, not a distinct workflow), but is flagged in §7 (cross-check) rather than silently assumed adequate.
- **HLR-013 (Protection status)** has no dedicated specification document in Phase 3's list. The brief's own document plan places full device-enforcement detail in `16_DEVICE_ENFORCEMENT.md`, which is explicitly a Phase 5 deliverable. Phase 3 only references protection status where it intersects with FR-006/FR-008 (device authorisation and the two-stage onboarding model). **This is correctly deferred, not an oversight** — but is called out explicitly here so it isn't mistaken for a completed decomposition.

No orphan FRs were found (every FR above traces to an HLR); see §7 for the full Phase 3 cross-check.
