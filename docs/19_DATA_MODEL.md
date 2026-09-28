# 19. Data Model

**Status:** Phase 5, amended 2026-09-28 (founder review round); Device entity further amended 2026-09-28 (Phase 6 review round, adds `device_credential_*` fields per DEC-52–DEC-59) — see `35_DECISION_LOG.md`
**Depends on:** `06_FUNCTIONAL_REQUIREMENTS.md`, `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `18_ROLES_AND_PERMISSIONS.md`, `27_APPLE_INTEGRATION_REQUIREMENTS.md`

This document defines the logical entities the backend must persist and the fields each carries, derived directly from the confirmed Phase 3/4 business rules. It is a logical model (entities, relationships, key fields, ownership), not a physical schema (no column types/indices) — those are a Phase 6/7 or implementation-time concern. No production code accompanies this document per the standing engagement rule.

**Amendment note (this round):** three fields in the original Phase 5 draft made assumptions the founder's re-check of Apple documentation found unsupported or contradictory to earlier confirmed decisions, and are corrected below: `Member.date_of_birth_or_age_band` (contradicted DEC-24, which confirmed no DOB is collected), `Member.apple_account_link` (assumed an Apple-exposed account identifier this product has no documented API to obtain), and `ControlledTarget.parent_assigned_label` (implied `FamilyActivityPicker` supplies a custom label, which it does not). See §19.2 for the corrected fields.

## 19.1 Modelling constraints inherited from Apple's platform (per `27_APPLE_INTEGRATION_REQUIREMENTS.md`)

- **CONFIRMED REQUIREMENT:** `ControlledTarget` (the entity representing something a rule can restrict) cannot store an Apple-derived app name, bundle ID, or domain string extracted from the shield token itself, because `ApplicationToken`/`ActivityCategoryToken`/`WebDomainToken` are opaque and privacy-preserving by design (§27.3, VERIFIED). The only human-readable label available is whatever the parent typed or selected via the picker UI at authoring time. This is a binding constraint on the schema below, not a stylistic choice.
- **CONFIRMED REQUIREMENT:** raw app/website usage duration data can never be stored by this backend at all (§27.5, VERIFIED — the reporting extension is sandboxed with no network access). The data model below therefore contains **no "UsageEvent" or "AppUsageMinutes" entity** — that category of data structurally cannot reach the backend, and no future schema revision should attempt to add one without first revisiting §27.5.

## 19.2 Core entities

### Household
- `household_id` (PK)
- `name`
- `owner_id` (FK → Member, exactly one, per BR-101/DEC-45)
- `created_at`
- `subscription_state` (see §19.2 Subscription entity; summarised here for quick reference)

### Member
- `member_id` (PK) — a Themis-issued identifier; Themis identifies its own Member and Device records using Themis IDs, not any Apple-exposed identifier (see below).
- `household_id` (FK)
- `role` (Owner | Guardian | Child | Teen — per `18_ROLES_AND_PERMISSIONS.md`)
- `display_name`
- `experience_segment` (Child | Teen — **corrected this amendment round.** The original draft's `date_of_birth_or_age_band` field is removed: it directly contradicted DEC-24, which confirmed the parent explicitly selects "Child experience" or "Teen experience" during setup and no precise child DOB is collected for this purpose. `experience_segment` is the correct, DEC-24-consistent field: an explicit parent choice, not a derived or stored age/DOB value.)
- **`apple_account_link` field removed this amendment round.** The original draft assumed Family Controls exposes an Apple Account identifier suitable for Themis to store as a link between a Member and their Apple Family Sharing identity. No documented Apple API was found providing such an identifier for this purpose (§27.2's `AuthorizationCenter`/`FamilyControlsMember` surface authorization status and prompts, not an account identifier). Themis does not invent an Apple account reference field. Apple authorization state is modelled purely as **device/platform state** (see `Device.platform_authorization_status` below), not as a Themis identity-provider concern. **If a platform-level binding between a Themis Member and a specific Apple Family Sharing identity is technically needed** (e.g. to route the correct `.child` authorization prompt to the correct device), that binding mechanism is classified **NEEDS REAL-DEVICE TECHNICAL SPIKE** rather than architected around an invented field.
- `invited_by`, `invited_at`, `joined_at` (nullable until accepted)
- `removed_at` (nullable; soft-delete, since historical Task/Rule records reference this member and must remain attributable)

### Device
- `device_id` (PK)
- `household_id` (FK)
- `owned_by_member_id` (FK → Member; the child/teen whose device this is)
- `platform_authorization_status` (mirrors Apple's `authorizationStatus`, cached; per §27.2 this can change externally and must be re-checked, never assumed) — **this field remains a Family Controls/platform-level concern only; see `device_credential_*` fields below for the separate, Themis-level identity concept added this Phase 6 amendment round (`24_SECURITY_REQUIREMENTS.md` §24.5). The two are never conflated: a Device may hold one without the other, and each is checked/revoked independently.**
- `device_credential_id` (Themis-issued, scoped device credential; issued at pairing per `16_DEVICE_ENFORCEMENT.md` §16.10a; carries only child-device permissions per `18_ROLES_AND_PERMISSIONS.md`)
- `device_credential_issued_at`, `device_credential_revoked_at` (nullable; revocation is atomic with device removal, per SEC-002)
- `last_synced_at` (drives the staleness detection in `16_DEVICE_ENFORCEMENT.md` §16.8)
- `added_at`, `removed_at` (nullable; soft-delete, per FR-007/device replacement in §16.9)

### ControlledTarget
- `target_id` (PK)
- `household_id` (FK)
- `kind` (Application | ActivityCategory | WebDomain — mirrors Apple's three token types)
- `apple_token_opaque_ref` (stored exactly as returned by the `FamilyActivityPicker`; treated as an opaque blob, never parsed)
- `custom_alias` (nullable; **corrected this amendment round, replaces `parent_assigned_label`.** The original field name and description implied `FamilyActivityPicker` itself supplies a custom, parent-assigned label — it does not. The picker's selection is privacy-preserving and opaque by design (§27.3); the app may render Apple's token using the supported SwiftUI family-activity `Label` view on an authorised device, which displays Apple's own icon/name for the item, not a Themis-stored string. `custom_alias` is an entirely separate, optional field: a human-readable nickname explicitly entered by the parent *inside Themis* (e.g. "The game console app" for a target they want to refer to more simply than its `Label`-rendered name), never claimed to have come from the picker.)
- `is_essential_or_always_allowed` (boolean; drives the unconditional subtraction in `16_DEVICE_ENFORCEMENT.md` §16.3 step 3)

### Rule
- `rule_id` (PK)
- `household_id` (FK)
- `applies_to_member_id` (FK → Member)
- `rule_type` (ScheduledRule | DeadlineLock | other confirmed types per `10_RULE_ENGINE_SPECIFICATION.md`)
- `target_ids` (FK list → ControlledTarget)
- `schedule_definition` (the calendar-based schedule, per §27.4's `DeviceActivitySchedule` model — window start/end, recurrence)
- `override_scope` (nullable; per DEC-32's effective-enforcement model, an override rule names exactly what it removes from restriction, never more)
- `active` (boolean)
- `created_by_member_id`, `created_at`, `last_modified_at`

### Task
- `task_id` (PK)
- `household_id` (FK)
- `assigned_to_member_id` (FK → Member)
- `deadline_at` (nullable; only present for Deadline-Lock-linked tasks)
- `linked_rule_id` (FK → Rule, nullable)
- `session_type` (None | ActiveEngagementSession | FocusSession — per DEC-37/§11.1a)
- `status` (Pending | Submitted | Approved | Rejected | Interrupted | ExpiredUnresolved — the last two added per DEC-42/DEC-40 respectively)
- `submitted_at_device_local`, `submitted_at_server_received`, `trusted_time_anchor_ref` (all retained, per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.7a's trusted-time model — the anchor reference supports reconciling a genuinely on-time offline submission rather than relying on server-received time alone)
- `grace_period_expires_at` (nullable; computed per DEC-40 when a Deadline-Lock-linked task's deadline passes with the task still pending)
- `resolved_by_member_id`, `resolved_at` (nullable until a decision is made)
- `rejection_note` (nullable, per DEC-38's confirmed-optional field)
- `idempotency_key` (client-generated UUID per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.5)

### Request
- `request_id` (PK)
- `household_id` (FK)
- `requested_by_member_id` (FK → Member)
- `request_type` (per `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`)
- `scope`, `duration` (explicit, mandatory per DEC-33/BR-219)
- `created_at`, `expires_at` (per DEC-39's context-based expiry: `expires_at` is computed as the sooner of the linked context's end or a 4-hour backstop from `created_at`)
- `linked_context_ref` (the rule/session/task this request's expiry is tied to, per DEC-39)
- `status` (Pending | Approved | Rejected | Expired)
- `resolved_by_member_id`, `resolved_at`, `rejection_note` (nullable, mirrors Task)
- `idempotency_key`

### TemporaryAccessGrant (Free Pass)
- `grant_id` (PK)
- `household_id` (FK)
- `granted_to_member_id` (FK → Member)
- `preset_id` (references a confirmed Free Pass preset, per Phase 3 amendment)
- `scope` (target_ids affected)
- `starts_at`, `expires_at`
- `granted_by_member_id` (nullable if self-service within an Owner/Guardian-approved preset's bounds — exact self-service bounds were confirmed in Phase 3; this field records whichever party's action actually created the grant)
- `status` (Active | Expired | Revoked — **`Revoked` added this amendment round, closes OQ-35**; see `20_STATE_MACHINES.md` §20.7 and `16_DEVICE_ENFORCEMENT.md` §16.9a for the confirmed early-revocation behaviour)
- `revoked_by_member_id`, `revoked_at` (nullable; populated only when `status = Revoked`)
- `applied_on_device_at` (nullable; the timestamp the child device confirmed it received and applied the revocation — supports the "Revocation sent" → "Access revoked" UI distinction confirmed in `16_DEVICE_ENFORCEMENT.md` §16.9a, and the analogous "Approved"/"Applied on device" distinction in §16.6a for other approval-type actions)

### EngagementSession (Active Engagement Session / Focus Session)
- `session_id` (PK)
- `linked_task_id` (FK → Task, nullable — a session can exist standalone per some confirmed flows, or attached to a Task)
- `session_type` (ActiveEngagementSession | FocusSession)
- `started_at`, `ended_at` (device-local; server-received equivalents per the offline model)
- `outcome` (Completed | Interrupted | TerminatedPendingResume | Abandoned — **`Abandoned` added this amendment round, closes OQ-36**; a `TerminatedPendingResume` session moves to `Abandoned` at the earlier of the linked task/context's expiry or 24 hours from `last_checkpoint_at`, per `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.6 and `20_STATE_MACHINES.md` §20.8)
- `last_checkpoint_at` (the last trustworthy point the session's persisted partial progress was confirmed, per DEC-43's persist-and-verify model; drives the 24-hour abandonment window above)
- `resume_of_session_id` (nullable self-reference, per DEC-43's persist-and-verify/Resume model)

### Subscription
- `subscription_id` (PK)
- `household_id` (FK)
- `state` (Active | Lapsed | InGrace — the grace state is a Phase 5 RECOMMENDATION per `16_DEVICE_ENFORCEMENT.md` §16.10, not yet founder-confirmed)
- `provider_reference` (App Store transaction/subscription reference)
- `current_period_ends_at`

### ResolutionVersion (supporting entity for §16.7/§17.4 atomicity)
- `household_id` (FK, PK component)
- `device_id` (FK, PK component)
- `version` (monotonically increasing integer, incremented atomically by the backend on every state change affecting that device's Local Enforcement Plan: rule change, approval, grant creation/expiry/revocation, session outcome, role change)

### LocalEnforcementPlan (device-local only — not a backend-persisted entity; documented here for completeness per `16_DEVICE_ENFORCEMENT.md` §16.3)
- `current_shield_state` (the concrete token set shielded right now)
- `rule_config_version` / `source_resolution_version` (the `ResolutionVersion.version` this plan was generated from)
- `generated_at`, `effective_from`
- `transitions` (list of: transition timestamp/schedule identity, resulting shield operation or snapshot)
- `grant_expiries`, `grace_period_expiries` (the specific expiry timestamps feeding the transitions above)
- `timezone_context`
- This entity exists only in the App Group shared store on the child device; the backend never stores or receives it directly, only the `ResolutionVersion` and underlying business-state rows it was derived from. It is listed here, not in §19.4 alone, because its field shape is a binding cross-document contract between `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, and `29_API_AND_BACKEND_REQUIREMENTS.md`, not merely an implementation detail.

## 19.3 Relationships summary

- A Household has many Members, Devices, Rules, Tasks, Requests, TemporaryAccessGrants, and one Subscription.
- A Device belongs to exactly one Member (the child/teen) but is visible to all Guardians/Owner in the household per role permissions (`18_ROLES_AND_PERMISSIONS.md`).
- A Rule targets one Member and zero-or-more ControlledTargets.
- A Task optionally links to one Rule (for Deadline-Lock-originated tasks) and optionally to one EngagementSession.
- A Request optionally links to a Rule, Task, or EngagementSession via `linked_context_ref` for DEC-39's expiry computation.
- An EngagementSession optionally self-references a prior session via `resume_of_session_id`.

## 19.4 State fields vs derived/computed values

Per the founder's explicit Phase 5 instruction to define "local versus server-owned state," the following distinction is made explicit and must not be blurred in implementation:

- **Server-owned, persisted:** every entity and field in §19.2 except `LocalEnforcementPlan`.
- **Device-computed, never persisted server-side:** the `LocalEnforcementPlan` (`16_DEVICE_ENFORCEMENT.md` §16.3) and the device's live "protection status" display value — both are derived, at read time or sync time, from the persisted entities above, and are recomputed rather than stored as their own row. This avoids the entire class of bug where a derived value silently drifts from the rules it was derived from.

## 19.5 Requirements-to-entity traceability spot check

Per the end-of-Phase-5 cross-check requirement (identify any requirement with no state/data representation), a review against `06_FUNCTIONAL_REQUIREMENTS.md`, `10_RULE_ENGINE_SPECIFICATION.md`, `11_TASK_AND_APPROVAL_SPECIFICATION.md`, `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`, and `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` found every confirmed FR/BR has a corresponding entity or field above, with one exception flagged here rather than silently patched:

- **BR-222's hard safety principle (Phone/Messages/Maps never deliberately restricted)** is represented only as a boolean flag (`is_essential_or_always_allowed`) on ControlledTarget, which assumes the parent/system can always successfully exclude those targets from a shield selection. Given §27.3's OQ-30 (UNKNOWN whether Phone/emergency calling can even be included in an Apple shield token set at all), this flag may end up being **moot in practice** if the OS itself simply never allows those apps into a `FamilyActivityPicker` selection in the first place. **Not treated as a gap requiring a new field — flagged as depending on the OQ-30 real-device spike outcome before this part of the schema can be considered final.**

No state transition identified in `20_STATE_MACHINES.md` (see that document) was found to lack a backing field here; the two documents were developed together for consistency.
