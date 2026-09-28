# 00. Product Overview — Themis Family

**Status:** Phase 1, amended 2026-09-28 following founder decision round
**Date:** 28 September 2026
**Author:** Product/Business Analysis (Claude), for Stephen Owojori (Kydos)
**Product name:** Themis Family (confirmed — see `35_DECISION_LOG.md`, DEC-11). Positioning: *"Clear digital boundaries without the daily arguments."*

---

## 1.1 What this document is

This is the top-level statement of what the product is, who it is for, and what it explicitly is not. Every later document (requirements, data model, rule engine, privacy) must trace back to this one. Where this document conflicts with the original brief, the conflict is flagged, not silently resolved (see Section 6 and `34_OPEN_QUESTIONS.md`).

---

## 1.2 Product in one sentence

**CONFIRMED REQUIREMENT** (stated directly in the brief):

> A family digital boundaries application. Parents and guardians set clear, agreed rules about apps, websites and time. If a rule is missed, the phone enforces a pre-agreed consequence automatically. The child always understands why access changed, what is needed to restore it, and how to ask for an exception.

Working promise: **"Set clear digital rules once, and let the phone enforce them."**

---

## 1.3 Who this is for

| Role | Definition | Status |
|---|---|---|
| Household Owner (parent/guardian who pays) | Creates the household, invites members, has full rule authority, plus exclusive control of subscription, household deletion, guardian removal and ownership transfer | CONFIRMED |
| Guardian (up to one additional, per household) | Shares the household's single rule set; can receive requests, approve/reject task completions, approve/decline extra-time requests, grant temporary access, and see rule/protection status — but cannot perform Owner-only destructive actions | CONFIRMED (DEC-14). If both Owner and Guardian act on the same pending request, first valid decision wins; the later responder sees it already resolved. |
| Teen (~13–15) | Distinct UX segment: has visibility into agreements, can negotiate, can request exceptions; UX must feel autonomous, not childish | CONFIRMED (DEC-12) |
| Child (~8–12) | Distinct UX segment: simpler UI, fewer negotiation features, same core visibility principle | CONFIRMED (DEC-12) |

**CONFIRMED (DEC-12):** The 8–15 age band is retained for V1, split into two UX segments (Child ~8–12, Teen ~13–15). This is a product/UX distinction only — not a scientific or legal claim about age boundaries — and the exact commercial range remains subject to user testing.

---

## 1.4 What the product is NOT

Stated explicitly in the brief and preserved here as binding constraints, not preferences:

- **Not spyware.** No message content reading, no call recording, no continuous location tracking, no full browsing-history diary for parents.
- **Not a chore-chart app.** Chores are one task type among several, not the core loop.
- **Not a screen-time-reward-only app.** Earn-First exists but is not the dominant philosophy; Deadline Lock is the hero mechanic (see `10_RULE_ENGINE_SPECIFICATION.md`).
- **Not an internet-security/content-filtering company.** Website control is scoped to the rules the parent sets, not general-purpose safe browsing or malware filtering.
- **Not (for V1) an adult self-control product.** Personal Mode is explicitly out of the first release (see Section 5).
- **Not positioned as "unhackable" or "impossible to bypass."** Apple's own model allows a parent/guardian to ultimately revoke authorisation; the product must never claim otherwise.

---

## 1.5 Core mechanic

**CONFIRMED REQUIREMENT:**

```
WHO        - which household member the rule applies to
WHEN       - schedule or deadline
CONTROLS   - which apps, websites or categories
CONDITION  - what removes the restriction
ACTION     - what happens when the condition is unmet
EXCEPTIONS - what is always available regardless of rule state
```

Worked example (from the brief, preserved verbatim in intent):

> Homework due 6:00 PM. If overdue, selected games lock. School apps, phone, messages stay available. Child can request more time. Parent can approve, decline, or extend. Rule has a review date.

---

## 1.6 Release scope boundary (summary — full detail in `02_SCOPE_AND_RELEASE_STRATEGY.md`)

**IN for V1 (CONFIRMED — founder decision round, 2026-09-28):**
- Family Mode only (no Personal Mode, no Household/adult rules)
- Two UX segments: Child (~8–12) and Teen (~13–15), sharing one rule engine (DEC-12)
- iOS/iPadOS only, via Apple FamilyControls, ManagedSettings, DeviceActivity
- Rule types: Scheduled Rule, Deadline Lock, Earn First
- Requests/negotiation (extra time, exception)
- Parent approval workflow, with a formal **Verification Type** per task: Parent Approval (default for manual real-world tasks) or Automatic Verification (system-verifiable timers/focus sessions only) (DEC-16)
- One Household Owner plus up to one additional Guardian, sharing a single household rule set; Owner-only for subscription, deletion, guardian removal and ownership transfer; first-valid-decision-wins on simultaneous approvals (DEC-14)
- No automatic unlock on parent non-response; honest "Waiting for approval" state, a reminder, and one child nudge (DEC-15)
- Always-Allowed / School Mode essential access, with an explicit, stated limitation that the product cannot classify content within an app as educational vs. entertainment (DEC-18)
- Website blocking (domains/categories) alongside app blocking
- Protection status (Protected / Needs Attention / Unavailable)
- Lightweight, privacy-preserving usage report scoped to: rules met/missed, task and request outcomes, overrides, and protection/enforcement failures, plus category-level usage only where technically confirmed feasible (DEC-19)

**OUT for V1 (deferred, not deleted):**
- Personal Mode (adult self-control) (DEC-13)
- Household Mode (rules that apply to parents themselves) (DEC-13)
- Daily Allowance / Wallet economy, category wallets, weighted consumption
- Friction Ladder levels beyond a simple pause (no intent-capture, no five-strike rule)
- Photo proof, NFC, QR, step-count, location conditions, AI verification (DEC-16 explicitly excludes these from V1's Verification Type options)
- Android (any device)
- Full separated-household / conflicting-ruleset support beyond the single-shared-ruleset, two-guardian model above (DEC-14)
- Live Activities, Siri/App Intents, AlarmKit integrations

This scope boundary was a RECOMMENDATION as of Phase 1 (recorded as DEC-01) and is now CONFIRMED, refined by the founder decisions above (DEC-11 through DEC-20), which supersede DEC-01 where they add detail.

---

## 1.7 Primary market

**CONFIRMED (stated in brief):** UK primary launch market, iOS first, Android later.

**TECHNICAL DEPENDENCY:** The entire plan depends on Apple granting the Family Controls distribution entitlement. This is flagged as the single highest-risk external dependency in `33_PRODUCT_RISK_REGISTER.md` (RISK-01).

---

## 1.8 Relationship to prior discovery work

This document supersedes the earlier "Project Rulebook" blueprint's framing (the product's working title before it was confirmed as **Themis Family** — DEC-11) in one important way: the blueprint treated Personal Mode, Household Mode and a large rule/recipe catalogue as core to V1. Discovery conversation with the founder (recorded in the attached excerpt and confirmed in the Phase-1 brief itself) narrowed this to a single hypothesis:

> Can we reduce screen-time arguments between parents and children by letting families agree rules in advance and having the phone enforce the consequence automatically?

All scope decisions in this document are judged against that hypothesis. Anything that doesn't help test it is deferred (see `36_MVP_VS_LATER_FEATURE_MATRIX.md`, to be produced in a later phase).
