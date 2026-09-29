# Themis Family Mobile UX Blueprint

**Status:** Implementation/design blueprint. Does not amend approved product requirements.
**Audience:** Founder, Claude Design, Claude Code, iOS implementation.
**Platform:** Native iPhone-first iOS/iPadOS app.
**Design phase goal:** Approve the complete mobile journey and visual system before production UI is built screen-by-screen.

## 1. Design principles

Themis Family is a mobile family product, not a desktop dashboard compressed onto a phone.

The experience must feel:
- calm, premium and modern
- clear enough for a busy parent using one hand
- respectful enough for a 13–15 year-old not to feel patronised
- simple enough for an 8–12 year-old to understand
- transparent rather than surveillance-heavy
- supportive rather than punitive
- native to iOS interaction patterns

Avoid:
- dense admin dashboards
- table-heavy layouts
- desktop sidebars on iPhone
- too many cards on one screen
- giant forms
- red/punitive visual language
- childish Teen UI
- purple
- cyber-security aesthetics
- law-firm / Greek mythology visual language
- fake certainty about Apple enforcement

## 2. Mobile navigation hypothesis

This is the primary navigation direction to prototype and validate.

### Parent app

Bottom tab bar:
1. Home
2. Rules
3. Activity
4. Settings

Global actions:
- notifications/action centre reachable from Home header
- child switching from Home and child-detail screens
- create/add actions presented contextually, usually as a prominent button or toolbar action

### Child / Teen app

Bottom tab bar:
1. Home
2. My Rules
3. Requests

The "Themis is active" transparency detail is reachable from Home and from protection/restriction states.

The Child experience should use simpler copy, larger targets and less density.
The Teen experience should use more autonomy-respecting copy and a slightly more mature information hierarchy.

## 3. Primary end-to-end journey

The design must make this complete journey clickable:

### Parent setup

P-001 Launch
→ P-002 Welcome
→ P-003 Sign in with Apple
→ P-004 Account created, protection not active
→ P-005 "What are you struggling with?"
→ P-006 Add child
→ P-007 Choose Child or Teen experience
→ P-008 Child profile created
→ P-009 Pair child's device
→ P-010 Pairing code / QR
→ P-011 Family Controls explanation
→ P-012 Family Controls authorisation step
→ P-013 Choose first rule starter
→ P-014 Homework Deadline starter
→ P-015 Choose controlled apps/sites
→ P-016 Set homework deadline
→ P-017 Verification type
→ P-018 Always Allowed / school access
→ P-019 Review family agreement
→ P-020 Test protection
→ P-021 Test succeeded and shield removed
→ P-022 Themis Protection Activated
→ P-023 Parent Home

Canonical setup example:
- Parent: Sarah
- Child: Sam, Child experience
- Goal: Homework
- Deadline: 6:00 PM
- Controlled apps: Roblox and Minecraft
- Verification: Parent Approval
- Recommended Always Allowed: Phone, Messages, Maps where technically supported
- School apps remain available

The UI must never show "Protected" before the activation requirements are satisfied.

### Core Deadline Lock loop

P-023 Parent Home
+
C-001 Child Home before deadline
→ C-002 Homework task detail
→ C-003 Submit completion
→ C-004 Submitted on time / waiting approval
→ C-005 Provisional Approval Grace Period
→ P-024 Parent receives action
→ P-025 Task review
→ P-026 Approve task
→ P-027 Approved, waiting for device application
→ P-028 Applied on device / protection current
→ C-006 Approved / access available, subject to any other active restriction

Also prototype overdue path:
C-007 Homework overdue
→ C-008 "Games are paused"
→ C-009 Submit completion
→ C-010 Waiting for approval while restriction remains
→ parent approval flow

If another rule still applies, completion must not falsely say everything is unlocked.

## 4. Full screen inventory

### A. Entry and owner onboarding

| ID | Screen | Core purpose |
|---|---|---|
| P-001 | Launch / splash | Brand entry, lightweight |
| P-002 | Welcome | Explain core promise in one screen |
| P-003 | Sign in with Apple | Owner identity |
| P-004 | Account created, protection not active | Explicit two-stage setup status |
| P-005 | What are you struggling with? | Homework / bedtime / gaming / social / school nights |
| P-006 | Add child | First name only, no DOB for experience segmentation |
| P-007 | Choose experience | Child vs Teen with plain explanation |
| P-008 | Child created | Reassurance, next step |
| P-009 | Pair device intro | Explain one-device-per-child V1 assumption |
| P-010 | Pairing code / QR | One-time pairing flow |
| P-011 | Why Themis needs Apple permission | Plain-English Family Controls explanation |
| P-012 | Apple authorisation handoff | Clearly system-provided step |
| P-013 | Choose starter rule | Homework / bedtime / Earn First |
| P-014 | Homework Deadline starter | Explain expected action, due time, consequence, essential access, exception path |
| P-015 | Choose apps/sites | Represent Apple picker as a system-owned sheet/handoff, not invented app catalogue |
| P-016 | Deadline | Simple native time selection |
| P-017 | Verification type | Parent Approval vs Automatic Verification only where valid |
| P-018 | Always Allowed | School / essential access confirmation |
| P-019 | Review agreement | Human-readable summary before activation |
| P-020 | Test protection | Apply real test shield in future implementation |
| P-021 | Test result | Success / retry / permission issue |
| P-022 | Protection activated | Celebration without overclaiming |
| P-023 | Parent Home | Main parent landing screen |

### B. Parent Home and child management

| ID | Screen | Core purpose |
|---|---|---|
| P-023 | Parent Home | Family status, pending actions, protection health |
| P-029 | Child detail | One child's rules, tasks, status, requests |
| P-030 | Protection detail | Protected / Sync Pending / Offline / Needs Attention / Unavailable |
| P-031 | Fix protection | Guided recovery, no false guarantees |
| P-032 | Add another child | Secondary setup path |
| P-033 | Edit child profile | Name / experience segment |
| P-034 | Child devices | View/remove/replace managed device |

Parent Home should prioritise:
1. anything requiring action
2. protection health
3. each child's current agreement
4. quick actions

Do not build it like an analytics dashboard.

### C. Rules

| ID | Screen | Core purpose |
|---|---|---|
| R-001 | Rules list | Rules grouped by child |
| R-002 | Rule detail | Human-readable agreement and current state |
| R-003 | Create rule | Choose rule type / starter |
| R-004 | Scheduled Rule setup | Bedtime/study schedules |
| R-005 | Deadline Lock setup | Task, deadline, controlled targets |
| R-006 | Earn First setup | Required verified activity then access |
| R-007 | Select child | Target child |
| R-008 | Select apps/sites | Apple picker handoff |
| R-009 | Schedule / deadline | Native mobile time controls |
| R-010 | Verification method | Honest capability boundaries |
| R-011 | Always Allowed conflict | Explain narrowing before applying |
| R-012 | Rule review | Clear consequence preview |
| R-013 | Rule saved | Confirmation |
| R-014 | Edit rule | Change future behaviour only |
| R-015 | Pause/archive rule | Confirm impact |

### D. Parent approvals and requests

| ID | Screen | Core purpose |
|---|---|---|
| A-001 | Action centre | Tasks + requests needing parent action |
| A-002 | Task review | Approve / reject / needs work |
| A-003 | Reject / needs work | Optional note, no open chat |
| A-004 | Request detail | Reason shown only in authenticated app |
| A-005 | Approve request | +5 / +15 / +30 / custom / until time |
| A-006 | Partial approval | Grant less than requested |
| A-007 | Decline request | Clear decision |
| A-008 | Ask clarification | Exactly one parent prompt |
| A-009 | Waiting for child reply | Bounded exchange |
| A-010 | Already resolved | First valid guardian decision wins |
| A-011 | Approved vs Applied | Backend decision vs device effect distinction |

### E. Free Pass / temporary access

| ID | Screen | Core purpose |
|---|---|---|
| F-001 | Grant Free Pass | Entry point |
| F-002 | Select child | Scope |
| F-003 | Select apps/sites/categories | Exact scope, never blanket default |
| F-004 | Choose duration | Presets + custom |
| F-005 | Override preview | Show which active rules are temporarily overridden |
| F-006 | Confirm Free Pass | Explicit confirmation |
| F-007 | Active Free Pass | Remaining time, scope |
| F-008 | Revoke Free Pass | Confirm early revoke |
| F-009 | Revocation sent | Waiting for device |
| F-010 | Access revoked | Device acknowledgement |

### F. School and essential access

| ID | Screen | Core purpose |
|---|---|---|
| S-001 | Always Allowed | Parent-configured essential apps/sites |
| S-002 | School access | Apps/sites/categories needed for school |
| S-003 | Starter suggestions | Optional suggestions, not exhaustive directory |
| S-004 | Temporary educational access | Parent or child request path |
| S-005 | Emergency reassurance | Explain emergency functionality is never deliberately restricted |

### G. Child / Teen main experience

| ID | Screen | Core purpose |
|---|---|---|
| C-001 | Home | Today, active rules, task/request state |
| C-002 | Task detail | What is expected and when |
| C-003 | Submit task | Honest Parent Approval status |
| C-004 | Submitted on time | Waiting approval |
| C-005 | Approval grace | 30-minute grace countdown |
| C-006 | Approved | Access state without false global unlock |
| C-007 | Overdue | Clear neutral state |
| C-008 | Games are paused | Why, what to do, what stays available |
| C-009 | Submit while restricted | Submission |
| C-010 | Waiting while restricted | Honest continued restriction |
| C-011 | Multiple restrictions | Explain each active reason |
| C-012 | Themis is active | Transparency overview |
| C-013 | What can my parent see? | Themis-owned vs Apple Screen Time reporting |
| C-014 | Essential access | Reassurance |
| C-015 | My Rules | All current agreements |
| C-016 | Rule detail | Plain-language rule |
| C-017 | Requests | Request history/status |

### H. Child / Teen requests

| ID | Screen | Core purpose |
|---|---|---|
| Q-001 | Ask for more time/access | Entry |
| Q-002 | Choose target | App/site/context |
| Q-003 | Choose requested duration | Presets/custom |
| Q-004 | Optional reason | Free text in authenticated app only |
| Q-005 | Review request | Submit |
| Q-006 | Request pending | Waiting |
| Q-007 | Send reminder | Exactly one child nudge |
| Q-008 | Clarification prompt | Parent question |
| Q-009 | Reply to clarification | Exactly one reply |
| Q-010 | Approved | Granted scope/time |
| Q-011 | Partially approved | Clear difference from request |
| Q-012 | Declined | Neutral |
| Q-013 | Expired | Context ended, neutral |
| Q-014 | Cancel request | Child cancels pending request |

### I. Earn First / sessions

| ID | Screen | Core purpose |
|---|---|---|
| E-001 | Earn First task | Explain verified condition and reward |
| E-002 | Active Engagement Session | In-app timer, foreground only |
| E-003 | Active session interrupted/resumable | Persist trustworthy elapsed time |
| E-004 | Focus Session | Focus countdown |
| E-005 | Focus interrupted | Neutral reset, no completion credit |
| E-006 | Session complete | Honest language about what was verified |
| E-007 | Session abandoned | No credit, neutral explanation |

### J. Activity and reporting

| ID | Screen | Core purpose |
|---|---|---|
| T-001 | Activity overview | Rules met/missed, tasks, requests, overrides |
| T-002 | Child activity | Category A summary |
| T-003 | Rule history | Outcomes, not surveillance |
| T-004 | Request history | Structured history |
| T-005 | Protection history | Relevant protection state changes |
| T-006 | Apple Screen Time report | System/sandboxed display area, no implication backend stores raw data |

### K. Subscription

| ID | Screen | Core purpose |
|---|---|---|
| B-001 | Trial / subscription offer | Calm consumer subscription |
| B-002 | Manage subscription | App Store ownership |
| B-003 | Billing grace warning | Full protection still active |
| B-004 | Protection expired | Restrictions cleared |
| B-005 | Resubscribed | "Ready to turn protection back on?" |
| B-006 | Review old rules | Avoid surprise re-lock |
| B-007 | Reactivation sent | Device pending |
| B-008 | Protection active | Device acknowledgement |

Pricing/trial details are not final. Do not invent final commercial numbers.

### L. Settings and household

| ID | Screen | Core purpose |
|---|---|---|
| ST-001 | Settings | Main settings |
| ST-002 | Household | Household info |
| ST-003 | Guardian | Invite/remove second carer |
| ST-004 | Invite Guardian | Invitation flow |
| ST-005 | Notifications | Notification settings |
| ST-006 | Privacy & transparency | Parent privacy explanation |
| ST-007 | Support | Ordinary support scope |
| ST-008 | Safeguarding help | Separate safeguarding path |
| ST-009 | Subscription settings | App Store state |
| ST-010 | Transfer ownership | Owner-only |
| ST-011 | Delete household | Irreversible warning |
| ST-012 | Account / sign out | Account controls |

## 5. Required state variants

The design is incomplete unless these state variants exist.

### Protection

- Protected
- Sync Pending
- Device Offline
- Needs Attention
- Protection Unavailable

Every status must use text/iconography as well as colour.

### Parent actions

- no pending items
- one task pending
- multiple pending items
- request pending
- Provisional Approval Grace countdown
- request already resolved by Guardian
- approval recorded but not yet applied on child device

### Child

- no current restriction
- homework due
- submitted before deadline
- in grace
- overdue and restricted
- waiting for approval while restricted
- multiple restrictions still active
- Free Pass active
- request pending
- request declined
- request expired
- device offline / protection status problem

### Subscription

- Active
- Apple Billing Grace Period
- Protection Expired
- resubscribed but protection not reactivated
- Reactivation sent
- Protection active

## 6. Mobile interaction rules

- One primary action per screen where possible.
- Use bottom sheets for short reversible choices and confirmations.
- Use full-screen navigation for multi-step setup and complex choices.
- Keep destructive actions away from primary thumb zones and require clear confirmation.
- Forms should be split into digestible steps rather than desktop-style long forms.
- Use native date/time pickers where possible.
- Design for one-handed iPhone use.
- Support Dynamic Type without clipping.
- Minimum touch targets appropriate to iOS accessibility guidance.
- Never rely on swipe-only hidden actions for essential functionality.
- Keyboard states must leave primary actions reachable.
- Loading, empty, error, offline and permission-denied states must be designed, not left for engineering improvisation.
- Use system sheets/handoffs for Apple-owned UI rather than fabricating Apple permission interfaces.

## 7. Visual direction

- White / generous space
- Primary cobalt: #2563EB
- Mint: #34D399
- Soft aqua: #7DD3FC
- Peach: #FFB79E
- Light grey: #E5E7EB
- Soft grey: #F6F7F9
- Dark navy-toned text
- NO purple
- Typography direction: Manrope
- Premium but warm
- Modern 2026 consumer app
- Family-friendly, not childish
- No generic cyber shield aesthetic
- No surveillance aesthetic
- No literal Greek scales/columns
- Logo is not approved; use a temporary neutral wordmark/placeholder

## 8. Copy rules

Preferred:
- "Games are paused"
- "Homework was due at 6:00 PM."
- "Need a little longer? Ask for more time."
- "Submitted on time. Waiting for approval."
- "Waiting for approval. Games are paused until this is reviewed."
- "Focus session interrupted. Start again when you're ready."
- "Revocation sent"
- "Access revoked"
- "Approved"
- "Applied on device"

Avoid:
- "You failed"
- "You broke the rule"
- "Punishment"
- "Violation" in child-facing copy
- surveillance-style language
- guarantees such as "instant unlock" before measured
- claiming an app is "unblockable" or impossible to restrict without evidence

## 9. Prototype acceptance criteria

Before visual approval, the Claude Design prototype should allow the founder to click through at least:

1. complete Owner onboarding
2. first Homework Deadline rule setup
3. parent Home
4. child Home
5. task submission before deadline
6. Provisional Approval Grace
7. parent approval
8. Approved → Applied on device distinction
9. overdue restriction path
10. multiple restriction explanation
11. extra-time request
12. partial approval
13. one clarification exchange
14. Free Pass grant and revoke
15. protection status problem and recovery
16. subscription grace → expired → resubscribe → explicit reactivation
17. Child/Teen transparency view

## 10. Handoff rule

The approved Claude Design artifact becomes the UI source of truth for implementation.

Each approved screen/state should keep its ID (for example P-023 or C-008).

Implementation tickets should reference screen IDs plus requirement IDs.

Claude Code should not improvise layout or interaction for an approved screen unless an implementation constraint makes the design infeasible. If that occurs, record the discrepancy and return it for design review.
