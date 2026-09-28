# 01. Product Vision and Goals — Themis Family

**Status:** Phase 1, amended 2026-09-28

---

## 2.1 Vision statement

**RECOMMENDATION** (synthesised from brief + prior discussion, not yet founder-approved verbatim):

> Families argue about phones because the rules are implicit, inconsistently enforced, and negotiated in the heat of the moment. This product makes the rules explicit, agreed in advance, and enforced automatically — so the daily negotiation disappears and the relationship between parent and child is about the agreement, not the argument.

---

## 2.2 Primary hypothesis (the thing V1 exists to test)

**CONFIRMED** (this is the founder's own stated framing, carried from the discovery conversation):

> Families will agree rules in advance and let the phone enforce the consequence automatically, and doing so measurably reduces screen-time arguments, compared to ad hoc parental controls or chore-reward apps.

Every V1 feature must be justifiable against this hypothesis. A feature that doesn't help test it is a FUTURE FEATURE regardless of how technically easy it is.

---

## 2.3 Goals for V1

1. **Prove the core loop works reliably on a real device.** Parent creates rule → deadline passes → app locks → child completes task → parent approves → app unlocks. If this loop is not rock-solid, nothing else matters (see NFR targets in `07_NON_FUNCTIONAL_REQUIREMENTS.md`, to be produced Phase 5).
2. **Prove parents will set up the product without abandoning onboarding.** Apple Family Sharing + Family Controls authorisation is a known friction point (competitor evidence: "Earn Time" markets "no Family Sharing" as a differentiator). Time-to-first-working-rule is a goal metric.
3. **Prove the negotiation/request mechanic is used and valued**, not just the block/unlock mechanic. This is the stated differentiator; if teens and parents don't use "ask for more time," the differentiation claim is unproven.
4. **Prove School Mode doesn't generate support/trust-destroying failures.** A single instance of a child unable to submit homework because the app blocked a school-required site is disproportionately damaging to trust.
5. **Establish reliability as a brand attribute**, not a launch afterthought — measured via protection-status accuracy and approval-to-unlock latency.

## 2.4 Explicit non-goals for V1

- Not trying to prove the Wallet/allowance economy.
- Not trying to prove Personal/adult use.
- Not trying to maximise number of rule types or recipes.
- Not trying to build a general parental-control/monitoring suite competitive with Qustodio or Bark on breadth.

## 2.5 Success signals to watch (qualitative, pre-metrics-program)

**RECOMMENDATION**, to be refined once analytics are specified (Phase 6):

- Parents who complete onboarding and activate at least one rule within the same session.
- Rules that reach one full cycle (lock → complete → approve → unlock) without a support contact.
- Requests-for-more-time submitted per active household per week (a non-zero number indicates the negotiation feature is actually being used).
- Parents who report (via lightweight survey, not built-in telemetry) a reduction in daily arguing.

## 2.6 What "done" looks like for the discovery/spec phase (this engagement)

Per the brief: a complete specification set under `/docs` such that another engineering team could build without guessing, followed by an explicit founder instruction — **"Requirements approved. Begin implementation."** — before any code is written. This document set is not that instruction; it is Phase 1 of 7.
