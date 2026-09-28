# 10. Rule Engine Specification

**Status:** Phase 3 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md` (HLR-004, HLR-005, HLR-006, HLR-012, HLR-013, HLR-014), `35_DECISION_LOG.md`

This document decomposes the rule-related HLRs into functional requirements (FR-010 through FR-029) and formal business rules (BR-2xx). Data model and state-machine detail (exact schema, transition diagrams) are Phase 5 deliverables (`19_DATA_MODEL.md`, `20_STATE_MACHINES.md`); this document defines behaviour precisely enough that those can be built without further product judgement calls.

---

## 10.1 Rule structure

Every rule is composed of the fields defined in `00_PRODUCT_OVERVIEW.md` §1.5: WHO, WHEN, CONTROLS, CONDITION, ACTION, EXCEPTIONS. This document adds the fields needed to make that structure implementable:

| Field | Description |
|---|---|
| Rule Type | Scheduled Rule / Deadline Lock / Earn First (V1) |
| Target Member | The child/teen the rule applies to (one per rule; a rule cannot target multiple children in V1 — see BR-201) |
| Controlled Targets | Apps, websites, or categories, selected via Apple's picker |
| Verification Type | Parent Approval / Automatic Verification (per task/condition — see §10.4) |
| Always Allowed override | Whether this rule can override an Always Allowed designation (answer: never — BR-202) |
| Review Date | Optional date at which the parent is prompted to re-confirm or adjust the rule (brief §"Rule Agreements") |
| Status | Active / Paused / Archived |

---

## FR-010. Create a rule
- **Actor:** Owner or Guardian
- **Trigger:** Parent taps "Create rule" or selects a starter pattern during onboarding or from Settings
- **Preconditions:** Household exists; target child's device has valid Family Controls authorisation (HLR-003); at least one controlled target is selectable
- **Happy path:** Parent selects rule type → selects target child → selects controlled apps/sites/categories via Apple's picker → configures the type-specific fields (§10.2–10.4) → sets Verification Type → optionally sets a review date → confirms → rule is saved as Active.
- **Alternative paths:** Parent selects a starter pattern (e.g. "Homework deadline"), which pre-fills rule type, suggested controlled targets, and Verification Type, all of which remain editable before confirming.
- **Failure paths:** Device authorisation invalid at save time → rule is saved as Active but the device's protection status will not reach "Protected" until authorisation is restored (see `05_HIGH_LEVEL_REQUIREMENTS.md` HLR-013); parent is told this at save time, not left to discover it later. Apple's selection limit reached (50 apps / 50 web domains per Apple's documented ManagedSettings limits) → parent is shown a clear message and must use a category instead of individual selections.
- **Permissions:** Owner, Guardian only (BR-105)
- **Offline behaviour:** Rule creation requires connectivity to reach the backend (rules are authored centrally, then synced to device — see §10.6); if offline, the app queues the creation and confirms it is "Pending sync," not falsely "Active."
- **Data required:** Rule Type, Target Member, Controlled Targets, type-specific fields, Verification Type
- **Notification behaviour:** None on creation (no notification needed; the parent is the one creating it)
- **Business rules:** BR-201, BR-202, BR-203
- **Dependencies:** HLR-003 (device authorisation), Apple FamilyControls picker
- **Edge cases:** Parent attempts to create a rule targeting an Always Allowed app (BR-202 blocks this — see §13, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`)
- **Release:** V1 / Must
- **Open questions:** None outstanding

## FR-011. Modify a rule
- **Actor:** Owner or Guardian
- **Trigger:** Parent edits an existing rule
- **Preconditions:** Rule exists and is not Archived
- **Happy path:** Parent opens rule, changes a field, confirms → rule updates, change is synced to the child device.
- **Alternative/failure paths:** Editing a rule that currently has a pending, unresolved approval in progress (see FR-032) does not retroactively change the in-progress approval's terms — see BR-204.
- **Permissions:** Owner, Guardian only
- **Offline behaviour:** As FR-010 — queued if offline, honestly shown as pending sync
- **Notification behaviour:** None to the parent; the affected child is notified only if the modification changes something currently visible to them (e.g. a deadline time change) — exact notification triggers to be enumerated in `21_NOTIFICATIONS.md` (Phase 6)
- **Business rules:** BR-204
- **Release:** V1 / Must
- **Open questions:** None outstanding

## FR-012. Delete / pause / archive a rule
- **Actor:** Owner or Guardian
- **Trigger:** Parent deletes or pauses a rule
- **Happy path:** Pausing keeps the rule's configuration but stops enforcement immediately; deleting removes the rule from active use (soft-deleted/archived for audit purposes, not hard-deleted — see `24_SECURITY_REQUIREMENTS.md`, Phase 6, for retention).
- **Permissions:** Owner, Guardian only
- **Offline behaviour:** A pause/delete must apply locally as soon as it reaches the device, and — critically — must not depend on the device being online at the moment of pausing if the pause was queued while the device was reachable; if the device is unreachable, the shield remains until sync succeeds (this is a known, accepted latency, not a silent failure — the parent sees "Pending sync").
- **Release:** V1 / Must

---

## 10.2 Rule Type: Scheduled Rule

## FR-013. Scheduled Rule enforcement
- **Actor:** System (automatic)
- **Trigger:** Wall-clock time enters/exits the configured schedule window on the child's device
- **Preconditions:** Rule is Active; device has a valid, synced schedule
- **Happy path:** At the schedule's start time, the device shields the controlled targets locally, without needing a network round-trip at that exact moment (the schedule is cached locally — see §10.6). At the end time, the shield is lifted, likewise locally.
- **Failure paths:** Device clock is wrong / manipulated — out of scope for V1 to defend against exhaustively (see RISK-05, circumvention); device time zone changes (e.g. travel) — see BR-205.
- **Offline behaviour:** Fully local; does not require connectivity at trigger time.
- **Business rules:** BR-205 (time zone), BR-206 (DST)
- **Release:** V1 / Must
- **Open questions:** None outstanding for V1 scope; technical implementation detail deferred to Phase 5 (see BR-205).

**BR-205 (CONFIRMED, DEC-36 — closes OQ-22).** A Scheduled Rule's times are interpreted in the child device's current local time zone; if the family travels, the schedule follows the device's local clock, not a fixed UTC offset or a "home" time zone. A time-zone change must not silently create an ambiguous rule state (e.g. a schedule appearing to apply twice, or not at all, during the transition). V1 does not build separate home-time-zone-vs-travel-time-zone configuration — device-local time zone is the only V1 behaviour. `20_STATE_MACHINES.md` (Phase 5) must define: time-zone-change detection, schedule recalculation on change, local persistence of the recalculated schedule, and a parent-facing indication where the change is material (e.g. a schedule's next occurrence shifting by more than an hour).

**BR-206.** On a Daylight Saving Time transition, a schedule's start/end times are defined in local wall-clock time and are not shifted by the DST change (a 6:00 PM deadline is 6:00 PM local time before and after the clock change).

---

## 10.3 Rule Type: Deadline Lock

## FR-014. Deadline Lock enforcement
- **Actor:** System (automatic), Child/Teen (submission), Owner/Guardian (approval)
- **Trigger:** The configured deadline time passes
- **Preconditions:** Rule is Active
- **Happy path:** Before the deadline, controlled targets remain available as normal. At the deadline, if the associated task has not been submitted and approved (or auto-verified — see §10.4), controlled targets are shielded. This continues until the task is completed and, if required, approved (see `11_TASK_AND_APPROVAL_SPECIFICATION.md`).
- **Alternative paths:** Task is submitted and approved before the deadline → no shield ever applies. Task is submitted before the deadline but not yet approved when the deadline passes → BR-207 governs (the shield does NOT apply while approval is still pending from a pre-deadline submission — this avoids punishing a child who acted in time but the parent hasn't yet responded).
- **Failure paths:** See `11_TASK_AND_APPROVAL_SPECIFICATION.md` for non-response handling.
- **Offline behaviour:** The deadline and current lock/unlock state are cached locally; the shield applies at the deadline even if the device is offline at that moment.
- **Business rules:** BR-207
- **Release:** V1 / Must

**BR-207.** If a child submits a task for a Deadline Lock rule before the deadline passes, and the submission is still awaiting approval when the deadline arrives, the shield does not apply while that submission remains pending. If the submission is later rejected, the shield applies retroactively from the moment of rejection (not backdated to the original deadline).

---

## 10.4 Rule Type: Earn First

## FR-015. Earn First enforcement
- **Actor:** System (automatic), Child/Teen
- **Trigger:** Child attempts to open a controlled target while the associated condition is not yet met
- **Happy path:** Controlled targets are shielded by default. Child completes the associated condition (timer, focus session, or a manually-submitted task). Once Verification Type resolves to "complete" (automatically or via approval), the reward access period begins.
- **Business rules:** BR-208 (reward duration is fixed at rule-creation time, not renegotiable per-instance without an explicit request — see `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`)
- **Release:** V1 / Must

---

## 10.5 Verification Type (cross-cutting — applies to all rule types)

## FR-016. Verification Type assignment and enforcement
- **Actor:** Owner or Guardian (assignment), System (enforcement)
- **Trigger:** Rule/task creation
- **Preconditions:** None
- **Happy path:** Every task/condition attached to a rule has exactly one Verification Type: **Parent Approval** or **Automatic Verification**. Parent Approval is the default and only option for manual real-world tasks (homework, chores, cleaning, packing a bag). Automatic Verification is permitted only where the system has deterministic evidence of completion — in V1, this means an in-app timer or in-app focus session running to completion, and nothing else (DEC-28). The parent may configure any specific rule to require Parent Approval even for a timer/focus-session condition.
- **Failure paths:** A parent attempts to set Automatic Verification on a non-system-verifiable condition (e.g. "clean your room") → the UI must not offer this combination at all (this is a form-validation requirement, not a runtime error).
- **Business rules:** BR-209
- **Dependencies:** `11_TASK_AND_APPROVAL_SPECIFICATION.md` (task submission/approval lifecycle)
- **Release:** V1 / Must

**BR-209.** Automatic Verification evidence is scoped strictly to "the configured in-app session ran to completion, as measured by the device," and the exact evidence statement depends on which of the two Session Types (Active Engagement Session or Focus Session) the task uses — see `11_TASK_AND_APPROVAL_SPECIFICATION.md` §11.1a (DEC-37) for the two truthful completion statements and their respective backgrounding rules (BR-227, BR-228). No in-product copy, notification, or report may describe either Session Type's completion as evidence that the underlying real-world activity (e.g. reading, or homework) occurred — see DEC-28 and the wording contrast in `04_USER_JOURNEYS.md` §4.7.

---

## 10.6 Local-first enforcement and rule conflicts

## FR-017. Local rule caching
- **Actor:** System
- **Trigger:** Rule created, modified, or synced
- **Happy path:** Every Active rule affecting a given child device is cached locally on that device in a signed/verifiable form (exact mechanism is a Phase 5 backend/API decision). Enforcement (shielding/unshielding) is evaluated locally against this cache, not against a live server call, for every schedule transition, deadline, and temporary-access expiry.
- **Business rules:** BR-210 (temporary access, extra time and Free Pass must expire locally per DEC-30 — this generalises the same local-caching principle to expiry, not just initial lock)
- **Offline behaviour:** This FR *is* the offline behaviour requirement; see HLR-014.
- **Release:** V1 / Must

**BR-210 (restates DEC-30 as a rule engine business rule).** Any time-bounded grant (temporary access, extra time, Free Pass) must be cached locally with its exact expiry time at the moment it is granted. Re-locking at expiry is triggered by the device's own local clock against this cached expiry, never solely by a second server-sent instruction. If the backend, the parent's device, or push notifications are unavailable at the expiry moment, re-locking must still occur.

## FR-018. Rule conflict resolution
- **Actor:** System
- **Trigger:** More than one active rule, override, or exception applies to the same controlled target at the same moment
- **Happy path:** The system resolves each controlled target's enforcement state using the **effective-enforcement model** in BR-211 (DEC-32), not a linear rule-type precedence. A target is unrestricted only when every active restriction that applies to it has been cleared or explicitly overridden; clearing one restriction never implies the target is now accessible if another active restriction still covers it.
- **Alternative paths:** A restriction clears (e.g. a Deadline Lock task is approved) while another restriction on the same target remains active (e.g. a Scheduled Rule bedtime window) → the target remains shielded; the child sees which restriction(s) still apply, not a generic "still locked" message (see FR-019).
- **Business rules:** BR-211
- **Release:** V1 / Must
- **Open questions:** OQ-05 is now closed by this model — see below.

**BR-211 (effective-enforcement model — CONFIRMED, DEC-32; supersedes the linear precedence hierarchy originally proposed).**

Rule conflict resolution is not a rank-ordered list of rule *types*. Instead, every controlled target's enforcement state is computed as follows, each time it needs to be evaluated (on a schedule transition, a task/request outcome, a grant's creation or expiry, or app-launch attempt):

1. **Essential/Always Allowed is evaluated first and absolutely.** If a target is Essential or Always Allowed, it is never restricted by anything below, full stop (BR-202, BR-222).
2. **Explicit parent overrides and temporary grants apply only to the scope they explicitly name.** A Free Pass, extra-time grant, or temporary-access grant lifts restriction only for the specific target(s)/rule(s) it was scoped to (BR-210, BR-219) — it does not implicitly clear any other active restriction on the same or a different target.
3. **After all currently-applicable overrides/grants are applied, the target remains restricted if any other active blocking rule still covers it.** Scheduled Rule, Deadline Lock and Earn First restrictions are evaluated independently and are all still-in-force unless each one has individually been satisfied, approved, or overridden. None of the three rule types inherently outranks or clears another by virtue of its type.
4. **Completing or satisfying one rule's condition never implies access returns** if a different active rule still restricts the same target. The system must not report or imply "unlocked" for a target that remains shielded by another rule.

**Worked example (from the founder's own brief):** A bedtime Scheduled Rule and an overdue-homework Deadline Lock both restrict Roblox. The child completes the homework task and it is approved. Result: the Deadline Lock restriction on Roblox clears, but Roblox remains blocked because the bedtime Scheduled Rule is still active. The child is not told "Games unlocked" — they are told which restriction(s) still apply (see FR-019, BR-226).

**This closes OQ-05 and OQ-23.** The previous linear-precedence proposal (Scheduled Rule > Deadline Lock > Earn First) is withdrawn; it is no longer a candidate model, not merely deprioritised.

## FR-019. Multi-rule status communication to the child/teen
- **Actor:** System
- **Trigger:** A target the child is attempting to access, or checking the status of, has more than one active restriction, or a restriction has just partially cleared
- **Preconditions:** BR-211's effective-enforcement model determines the target remains restricted after at least one, but not all, applicable restrictions have cleared
- **Happy path:** The child/teen sees an honest, specific statement naming every restriction still in force on that target, not a single generic "locked" message and not a false "unlocked" message when a different restriction still applies. Example copy: *"Games are paused for bedtime. Homework is also overdue."* When a restriction clears while another remains, the UI communicates the change (e.g. "Homework done — nice work. Games are still paused until bedtime ends.") rather than staying silent or implying nothing changed.
- **Business rules:** BR-226 (no false "unlocked" state; every still-active restriction on a target must be named, not just the most recently evaluated one)
- **Dependencies:** `15_CHILD_AND_TEEN_EXPERIENCE.md` (Phase 5/6) — the exact copy library and visual treatment for multi-restriction states is a UX-detail document not yet written; this FR defines the underlying behavioural requirement it must satisfy.
- **Release:** V1 / Must

**BR-226 (restates DEC-32's child-experience consequence as a binding rule).** Wherever the product communicates a target's lock state to a child/teen, it must name every currently-active restriction on that target, and must never state or imply a target is unlocked/available while any restriction from BR-211's evaluation still applies to it.

---

## 10.7 Open questions surfaced by this document

**OQ-05 [CLOSED — resolved by DEC-32/BR-211].** The founder replaced the linear rule-type precedence question with the effective-enforcement model: no rule type inherently outranks another; a target stays restricted while any active rule still covers it. There is no longer a "precedence order" to confirm.

**OQ-22 [CLOSED — resolved by DEC-36/BR-205].** Scheduled Rule times follow the child device's current local time zone. V1 does not build home-vs-travel time zone configuration. Phase 5 technical detail (change detection, recalculation, persistence, parent-facing indication) remains to be specified in `20_STATE_MACHINES.md`, tracked as a Phase 5 implementation task, not a further open product question.

**OQ-23 [CLOSED — resolved by DEC-32].** Superseded by the effective-enforcement model: the question "should Scheduled Rule outrank Deadline Lock" no longer applies, since neither outranks the other — both remain independently in force until each is individually satisfied.
