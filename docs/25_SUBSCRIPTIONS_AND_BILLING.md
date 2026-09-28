# 25. Subscriptions and Billing

**Status:** Phase 6, amended 2026-09-28 (founder review round — see `35_DECISION_LOG.md` DEC-52 through DEC-59)
**Depends on:** `16_DEVICE_ENFORCEMENT.md` §16.10, `20_STATE_MACHINES.md` §20.10, `35_DECISION_LOG.md` OQ-11/OQ-33, DEC-20

**Amendment note (this round):** the original draft's custom `Lapsed` grace window (a Themis-invented 7-day figure) is withdrawn and replaced with Apple's own **Billing Grace Period** mechanism, confirmed at 16 days for V1 (§25.2). This is a materially different and more robust model: Apple's own billing-retry mechanism can run for longer than a service should continue on lapsed payment, so relying on a custom Themis grace window layered on top of Apple's retries risked either granting free service for too long or (if the two windows were misaligned) confusing which system's clock actually governed. §25.3's "not decided" items (OQ-38, OQ-39) are both closed this round. §25.6 (new) adds the resubscription-after-clearance flow the original draft did not address.

## 25.1 Purpose and the governing safety principle

This document finalises the Subscription state machine and enforcement-interaction behaviour that `16_DEVICE_ENFORCEMENT.md` §16.10 and `20_STATE_MACHINES.md` §20.10 explicitly deferred here per founder instruction (OQ-33). The single governing principle, confirmed by the founder and binding on everything in this document:

**CONFIRMED REQUIREMENT — the safety floor.** *Themis must never leave a child indefinitely locked because a subscription expired and the parent can no longer manage the rules.* Every state and transition below is designed to satisfy this before any commercial consideration.

## 25.2 Subscription states (finalises `20_STATE_MACHINES.md` §20.10) — CONFIRMED V1 COMMERCIAL POLICY, revised this amendment round

States: `Active` → `Apple Billing Grace Period` → `Recovered` | `Protection Expired` (involuntary billing failure path); `Active` → `Cancelled (paid-through)` → `Protection Expired` (voluntary cancellation path); either expired path → `Active` via explicit reactivation (§25.6).

**Involuntary billing failure (payment fails or a renewal cannot be charged):**

- **`Active`** — entitlement current, enforcement operates normally per `16_DEVICE_ENFORCEMENT.md`.
- **`Apple Billing Grace Period`** — **replaces the original draft's custom `BillingRetry`/`Lapsed` states.** Themis Family enables **Apple's own App Store Billing Grace Period**, confirmed at **16 days** for both monthly and annual subscriptions for V1 (subject to final App Store configuration validation — the exact figure is an App Store Connect setting, not Themis application logic, and must be checked against Apple's current configuration options at implementation time). During this period: all Themis features remain available; enforcement remains fully active; parents may fully manage rules as normal; a prominent but calm billing warning is shown ("Your payment didn't go through — update your payment method to keep Themis Family protection active"); and **no child-facing blame or billing detail is shown** (consistent with the age-appropriate, non-punitive product philosophy). **CONFIRMED REQUIREMENT: Themis does not continue full paid functionality merely because Apple's own billing-retry mechanism continues after the Billing Grace Period ends** — the Grace Period, not Apple's underlying retry schedule, is the governing window for Themis's own enforcement behaviour.
  - If Apple recovers payment during the Grace Period → `Recovered`: service continues without interruption, no action required from the parent beyond the payment method already having been fixed.
  - If Apple's Billing Grace Period **expires without recovery** → `Protection Expired` (see below). This transition happens regardless of whether Apple's own billing-retry attempts continue past that point.
- **`Protection Expired`** — **CONFIRMED REQUIREMENT, direct implementation of the safety floor:** Themis-managed restrictions are **actively cleared** (the shield is removed, not merely left to degrade unpredictably); the parent/guardian and, where age-appropriate, the child are clearly informed, in age-appropriate terms, that Themis Family protection is no longer active due to billing. **This is a deliberate, confirmed design choice: the alternative (leaving restrictions in force indefinitely with a lapsed subscription and no way for the parent to manage them) is explicitly ruled out by the founder's safety principle**, even though it might seem more "restrictive by default" — indefinite enforcement with no parental control path is judged worse than a clearly-communicated protection stop.

**Voluntary cancellation (the parent explicitly cancels):**

- Service remains **fully active until the existing paid-through date** — cancelling does not immediately degrade service the household has already paid for.
- The parent receives **advance notice before protection ends** (exact lead time is a Phase 7/implementation UX-copy decision, not fixed here).
- At paid-entitlement expiry, Themis-managed restrictions are **actively cleared**, identically to the involuntary-failure `Protection Expired` outcome above. **No additional custom grace period is required after a voluntary cancellation's paid period ends** — the parent has already had clear advance notice, unlike an involuntary billing failure where the Apple Billing Grace Period itself serves as the warning window.

Rule definitions are **never deleted** by either path (only enforcement is paused/cleared), so reactivation (§25.6) never requires the parent to re-author anything.

## 25.3 What is NOT decided here (explicitly flagged, not invented)

- **Pricing itself** (OQ-11: exact price point, trial length) remains open per DEC-20 and is unaffected by this document, which concerns state/enforcement behaviour, not commercial terms.
- **OQ-38 (grace-window length) and OQ-39 (partial-enforcement middle state) are both CLOSED this amendment round** — see §25.2 (16-day Apple Billing Grace Period, replacing the custom figure) and §25.2a below (binary model confirmed, no partial-enforcement tier). Neither is an open item any longer.

## 25.2a No partial/reduced-enforcement subscription tier — CONFIRMED, closes OQ-39

**CONFIRMED REQUIREMENT, this amendment round.** Themis Family does not create a reduced or partial-enforcement subscription tier after expiry. The model remains deliberately binary:

- **Entitled, or within the Apple Billing Grace Period:** full protection and full parental management.
- **Not entitled, after the Grace Period (or after voluntary cancellation's paid period ends):** Themis-managed restrictions are cleared.

Essential OS-level safety behaviour (emergency calling, per BR-222) remains governed by Apple/the device regardless of subscription state, as it always has been (`23_PRIVACY_AND_CHILD_SAFETY.md` §23.4) — but Themis does not continue a special, reduced parental-control service indefinitely for an unpaid household. A more nuanced middle state was considered in the original draft and is explicitly rejected here in favour of the simpler binary model, consistent with the founder's direction to keep the subscription-enforcement model conceptually simple.

## 25.4 Billing mechanics

**CONFIRMED REQUIREMENT:** billing is handled entirely through Apple's App Store in-app subscription mechanism (consistent with the product being an iOS app distributed via the App Store) — Themis Family's backend receives and records subscription state via App Store server notifications, but the App Store/payment processor remains the source of truth for the transaction itself (`19_DATA_MODEL.md`'s `Subscription.provider_reference` field already reflects this). This now explicitly includes configuring and relying on Apple's **Billing Grace Period** feature (§25.2) as the mechanism of record for the involuntary-failure path, rather than a Themis-computed grace window.

## 25.5 End-of-Phase-6 cross-check items addressed here

- **Subscription states that could leave a child unexpectedly locked:** the `Protection Expired` transition is the direct answer — no state in this machine results in indefinite enforcement without an active, current subscription (or a household within Apple's own Billing Grace Period). Both the involuntary-failure and voluntary-cancellation paths are explicitly bounded and communicated, never indefinite.
- **NFRs without measurable targets:** none remain in this document — the grace-window length is now Apple's own confirmed 16-day Billing Grace Period configuration, not a Themis-invented figure pending confirmation.

## 25.6 Resubscription after Protection Expired — CONFIRMED, new this amendment round

**CONFIRMED REQUIREMENT.** Themis Family does not automatically re-lock a child's device merely because a previously expired household purchases Themis again. Two distinct cases:

- **Payment recovered while still within the Apple Billing Grace Period:** protection simply continues (`Recovered`, §25.2) — no separate reactivation step, since enforcement was never cleared.
- **Household had already reached `Protection Expired`:** when the household resubscribes, restrictions are **not** silently reinstated the moment payment succeeds. Instead:
  1. The subscription becomes active (App Store confirms payment).
  2. Existing rule definitions may still exist (never deleted per §25.2).
  3. The parent is shown an explicit prompt: **"Ready to turn protection back on?"**
  4. The parent reviews the current rules (which may be stale — the child may be older, circumstances may have changed since protection lapsed).
  5. The parent **explicitly confirms reactivation.**
  6. The child device syncs the newly active Local Enforcement Plan (`16_DEVICE_ENFORCEMENT.md` §16.3).
  7. The parent sees the confirmed **"Reactivation sent" → "Protection active on device"** UI pattern, consistent with the existing Approved/Applied-on-device distinction elsewhere in this specification (`16_DEVICE_ENFORCEMENT.md` §16.6a).

This avoids the poor outcome of a child's device unexpectedly re-locking under months-old restrictions the moment a lapsed household's payment resumes, without the parent having had a chance to review whether those restrictions still make sense.
