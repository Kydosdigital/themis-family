# 25. Subscriptions and Billing

**Status:** Phase 6 draft
**Depends on:** `16_DEVICE_ENFORCEMENT.md` §16.10, `20_STATE_MACHINES.md` §20.10, `35_DECISION_LOG.md` OQ-11/OQ-33, DEC-20

## 25.1 Purpose and the governing safety principle

This document finalises the Subscription state machine and enforcement-interaction behaviour that `16_DEVICE_ENFORCEMENT.md` §16.10 and `20_STATE_MACHINES.md` §20.10 explicitly deferred here per founder instruction (OQ-33). The single governing principle, confirmed by the founder and binding on everything in this document:

**CONFIRMED REQUIREMENT — the safety floor.** *Themis must never leave a child indefinitely locked because a subscription expired and the parent can no longer manage the rules.* Every state and transition below is designed to satisfy this before any commercial consideration.

## 25.2 Subscription states (finalises `20_STATE_MACHINES.md` §20.10)

States: `Active` → `BillingRetry` → `Lapsed` → `RestrictionsCleared`; `Active`/`BillingRetry` → `Active` (payment resumes)

- **`Active`** — entitlement current, enforcement operates normally per `16_DEVICE_ENFORCEMENT.md`.
- **`BillingRetry`** — the App Store reports a failed payment and is retrying (Apple's own subscription billing-retry mechanism); **CONFIRMED REQUIREMENT:** enforcement continues unchanged during this state — a transient payment failure must not itself interrupt protection, and the parent is shown a clear billing-issue warning ("Your payment didn't go through — update your payment method to avoid losing Themis Family protection") without yet changing enforcement behaviour.
- **`Lapsed`** — the entitlement has definitively expired (retries exhausted, or explicit cancellation with the paid period having ended). **CONFIRMED REQUIREMENT:** enforcement continues for a **defined grace window** (RECOMMENDATION: 7 days, not yet founder-confirmed) during which the parent is repeatedly and clearly warned, consistent with the fail-safe-not-fail-open principle already established (`17_OFFLINE_AND_SYNC_BEHAVIOUR.md` §17.2) — restrictions do not silently vanish the moment billing fails, since an abrupt loss of protection with no warning would itself be a poor outcome for the household.
- **`RestrictionsCleared`** — **CONFIRMED REQUIREMENT, direct implementation of the safety floor:** once the grace window in `Lapsed` expires without payment resuming, Themis-managed restrictions are **actively cleared** (the shield is removed, not merely left to degrade unpredictably), and the parent/guardian and, where age-appropriate, the child are clearly informed that Themis Family protection has stopped due to billing. **This is a deliberate, confirmed design choice: the alternative (leaving restrictions in force indefinitely with a lapsed subscription and no way for the parent to manage them) is explicitly ruled out by the founder's safety principle**, even though it might seem more "restrictive by default" — indefinite enforcement with no parental control path is judged worse than a clearly-communicated protection stop.
- `Lapsed`/`RestrictionsCleared` → `Active`: payment resumes (App Store reports successful renewal or resubscription); enforcement per the household's existing rules resumes automatically, without requiring the parent to re-author anything, since rule definitions are never deleted by a subscription lapse (only enforcement is paused/cleared).

## 25.3 What is NOT decided here (explicitly flagged, not invented)

- **The exact grace-window length** (7 days proposed as a RECOMMENDATION) is not founder-confirmed and should not be treated as final for build sequencing.
- **Whether a partial/reduced enforcement mode exists between `BillingRetry`/early `Lapsed` and full `RestrictionsCleared`** (e.g. Essential/Always-Allowed-only enforcement continuing indefinitely, versus the binary model above) is not specified — the model above is a binary "full enforcement, then a warned grace window, then fully cleared," which is the simplest model satisfying the safety floor, but a more nuanced middle state is a legitimate design alternative not ruled out, only not chosen here without further founder input.
- **Pricing itself** (OQ-11: exact price point, trial length) remains open per DEC-20 and is unaffected by this document, which concerns state/enforcement behaviour, not commercial terms.

## 25.4 Billing mechanics

**CONFIRMED REQUIREMENT:** billing is handled entirely through Apple's App Store in-app subscription mechanism (consistent with the product being an iOS app distributed via the App Store) — Themis Family's backend receives and records subscription state via App Store server notifications, but the App Store/payment processor remains the source of truth for the transaction itself (`19_DATA_MODEL.md`'s `Subscription.provider_reference` field already reflects this).

## 25.5 End-of-Phase-6 cross-check items addressed here

- **Subscription states that could leave a child unexpectedly locked:** the `RestrictionsCleared` transition is the direct answer — no state in this machine results in indefinite enforcement without an active, current subscription. The `Lapsed` grace window is explicitly bounded and communicated, not indefinite.
- **NFRs without measurable targets:** the grace-window length (§25.3) is flagged, consistent with `07_NON_FUNCTIONAL_REQUIREMENTS.md`'s pattern of flagging unconfirmed numeric targets rather than inventing them.
