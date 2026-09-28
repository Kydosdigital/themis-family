# 04. User Journeys

**Status:** Phase 2 draft
**Depends on:** `03_PERSONAS.md`, `35_DECISION_LOG.md`

Each journey states its persona(s), preconditions, steps, and the decisions/requirements it exercises. These are narrative walkthroughs, not acceptance criteria (those come in Phase 4) — but every step here must be traceable to a requirement in `05_HIGH_LEVEL_REQUIREMENTS.md` or a later functional requirement.

---

## 4.1 Journey: First-time setup, single-guardian, single-child household (simplest case)

**Persona:** A Household Owner with one child, no second guardian invited yet. (Addresses OQ-14: the simplest-case household.)

1. Owner downloads Themis Family, creates an account.
2. Onboarding asks: "What are you struggling with?" — Owner selects Homework.
3. Owner is prompted to create the household and add their child (name, age segment inferred or selected: Child or Teen).
4. Owner is guided through Apple Family Sharing / Family Controls authorisation on the child's device, with plain-English explanation at each step.
5. Owner selects apps/sites to control (e.g., Roblox, TikTok) via Apple's picker.
6. Owner is offered a starter pattern: "Homework deadline" — selects it.
7. Owner sets homework deadline (6:00 PM), selects Games as the controlled category, confirms School apps (auto-suggested) stay Always Allowed.
8. Owner sets Verification Type for this rule: Parent Approval (default, shown as recommended for homework).
9. App runs a test shield so the Owner sees the rule actually working before finishing onboarding.
10. Onboarding completes. Owner is not prompted to invite a second guardian at this stage (optional, deferred to Settings).

**Requirements exercised:** DEC-12 (age segment selection), DEC-16 (Verification Type set at rule creation), DEC-18 (School apps auto-suggested as Always Allowed), brief's "test a shield" onboarding step.

**Open point (OQ-15, new):** Does the app infer Child vs. Teen from date of birth, or does the parent explicitly pick the segment? *Recommended default:* Parent explicitly picks the segment label (Child/Teen) rather than the app inferring from DOB, since the brief prioritises data minimisation and this avoids collecting a precise child DOB unnecessarily (see brief's privacy principles). *Blocks:* `19_DATA_MODEL.md` (User entity's date-of-birth-band field).

---

## 4.2 Journey: Deadline Lock cycle with parent approval (the core loop)

**Persona:** Marcus (Teen), Priya (Owner).

1. Homework rule is active: due 6:00 PM, Games controlled, Parent Approval required.
2. 6:00 PM passes. Marcus has not submitted completion.
3. Games lock automatically. Marcus opens a game app and sees: "Games are paused. Homework was due at 6:00 PM. Submit completion for approval. [Submit] [Ask for more time]."
4. Marcus finishes homework at 6:20 PM and taps Submit.
5. Status becomes "Waiting for approval." Marcus's screen clearly shows this state, not a generic locked screen.
6. Priya receives a push notification: "Marcus says homework is finished."
7. Priya opens the app, taps Approve.
8. Backend records the approval; Marcus's device receives the updated state; the shield is removed.
9. Marcus sees: "Done. Games unlocked."

**Requirements exercised:** Core Deadline Lock mechanic, DEC-16 (approval required, since homework is a manual task), the brief's AC2 (parent-approved task unlock flow).

## 4.3 Journey: Deadline Lock cycle, parent slow to respond

**Persona:** Marcus, Priya, Daniel (Guardian).

1. As in 4.2, Marcus submits at 6:20 PM.
2. Priya is in a meeting and doesn't see the notification.
3. At 6:50 PM (30 minutes after submission), a reminder notification re-fires to both Priya and Daniel.
4. Marcus's screen still clearly shows "Waiting for approval," with an elapsed-time indicator, and offers him exactly one "Send a reminder" nudge action, which he uses once at 6:45 PM.
5. Games remain locked throughout. School apps, phone, messages remain available to Marcus the whole time.
6. Daniel sees the reminder, opens the app, and approves at 7:05 PM.
7. Games unlock for Marcus.

**Requirements exercised:** DEC-15 directly (no auto-unlock, reminder at defined interval, one child nudge, honest waiting state), DEC-14 (Guardian can approve independently of the Owner).

## 4.4 Journey: Two guardians respond to the same request (conflict case)

**Persona:** Priya, Daniel, Marcus.

1. Marcus submits an "ask for more time" request: wants 30 extra minutes to finish a group project call.
2. Both Priya and Daniel see the pending request on their devices at the same time.
3. Priya taps "+15 minutes" at 8:00:02pm. Daniel, not having seen Priya's action yet, taps "Decline" at 8:00:03pm.
4. Priya's decision is recorded first and wins. Marcus receives the +15 minutes.
5. Daniel's app shows: "This request has already been resolved (approved by Priya)."

**Requirements exercised:** DEC-14's conflict rule, OQ-03a's atomic-decision requirement (to be formalised in Phase 5).

## 4.5 Journey: School Mode edge case — YouTube used for homework

**Persona:** Marcus.

1. Study Mode rule is active: entertainment apps and sites blocked 4pm–6pm on school days.
2. Marcus needs a specific YouTube video his teacher assigned, but YouTube is categorised under Entertainment and is blocked.
3. Marcus taps "Request temporary access," selects YouTube, states reason: "Teacher assigned this video for homework."
4. Priya receives the request, can see the stated reason, and grants temporary access for 20 minutes.
5. After 20 minutes, YouTube automatically re-locks without Priya needing to remember to re-enable the restriction.
6. At no point does the app claim it identified the video as educational — the resolution is entirely via the parent-approved temporary-access mechanism, not content classification.

**Requirements exercised:** DEC-18 directly. This journey is the canonical test case for the "must not claim content-level classification" constraint.

## 4.6 Journey: Protection status failure and recovery

**Persona:** Priya, Aisha (Child).

1. Aisha's iPad receives a major iOS update overnight.
2. Post-update, the Family Controls authorisation is invalidated (a known class of iOS-update risk — RISK-04).
3. Themis Family detects the loss of authorisation on next sync attempt.
4. Priya's dashboard shows Aisha's status as "Protection Unavailable" with a clear explanation and a "Fix this" action — not a false "Protected" state.
5. Priya taps "Fix this," is walked back through re-authorisation.
6. Status returns to "Protected" once confirmed.

**Requirements exercised:** Brief's AC4 (device enforcement health), DEC-08 (reliability as a brand attribute), RISK-04.

## 4.7 Journey: Aisha (Child) hits a blocked app — simplified UX

**Persona:** Aisha.

1. Aisha's reading-first rule is active: entertainment apps locked until a 15-minute in-app reading timer completes. Verification Type: Automatic Verification (per DEC-16, since this is a system-verifiable timer).
2. Aisha opens a game app, sees a simple, visual screen: "Not yet! Read for 15 minutes to unlock 30 minutes of games," with a big "Start reading" button and no dense text.
3. Aisha completes the 15-minute timer inside the app.
4. Because this is Automatic Verification, the game unlocks immediately — no parent approval step, no waiting screen.
5. Aisha sees: "Done! +30 minutes."

**Requirements exercised:** DEC-16's Automatic Verification path (the one case in the whole spec where no human approval is required), DEC-12's simpler Child UX.

---

## 4.8 Journeys deliberately not covered in V1 (traceability note)

Per `00_PRODUCT_OVERVIEW.md` §1.6, no journey exists for: an adult managing their own personal rules (Personal Mode), a household-wide dinner rule that restricts parents (Household Mode), a child earning a wallet balance across multiple categories, or any Android device. These are correctly absent, not omissions.
