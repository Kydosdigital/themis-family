# 03. Personas

**Status:** Phase 2 draft
**Depends on:** `00_PRODUCT_OVERVIEW.md` §1.3, `35_DECISION_LOG.md` DEC-12, DEC-14

All personas below are ASSUMPTION-level composites built from the brief's own stated research (Ofcom, Pew, GOV.UK) and the founder's decisions, not from primary user interviews. **RECOMMENDATION:** validate with real UK parents and children/teens before Phase 3 requirements are treated as final (see `33_PRODUCT_RISK_REGISTER.md` RISK-06, RISK-08).

---

## 3.1 Household Owner — "Priya, 41" (primary buyer and primary account holder)

- **Role:** Parent/guardian, pays the subscription, has full rule authority.
- **Household:** Two children, ages 10 and 14 (one in each UX segment). Co-parents with a partner who will be invited as the second Guardian.
- **Context:** Works full-time; evenings are the flashpoint for phone arguments, particularly around homework and Roblox/TikTok. Already uses Apple's built-in Screen Time but finds it clunky to adjust and doesn't get told when a child bypasses it.
- **Goals:** Stop the nightly negotiation. Know that a rule she set will actually hold. Be able to grant a one-off exception without permanently loosening the rule.
- **Frustrations:** Existing parental-control apps feel either too weak (Screen Time) or too invasive (Bark-style monitoring). Setup friction (Family Sharing, entitlements) is a known abandonment point.
- **What she needs from Themis Family:** A working rule within minutes of downloading; an honest signal if something stops working; a way to say yes to "5 more minutes" without editing the whole rule.
- **Relevant decisions:** DEC-14 (she is the Owner; can invite her partner as Guardian), DEC-15 (she'll be the one getting reminder notifications), DEC-19 (she's the audience for the reporting screen).

## 3.2 Guardian — "Daniel, 43" (Priya's partner, second guardian)

- **Role:** Second parent, invited into the household, shares approval duties.
- **Context:** Travels for work some weeks; wants to be able to approve a homework completion from his phone while away, and doesn't want to be the only one who can.
- **Goals:** Share the mental load of approvals. Not be blocked from acting just because Priya is unavailable, and vice versa.
- **Frustrations:** Apps that assume one parent = one account. Ambiguity about who "wins" if both parents respond to the same request.
- **What he needs from Themis Family:** Full visibility into pending requests and rule status; clear feedback if he tries to act on something Priya already resolved.
- **Relevant decisions:** DEC-14 directly defines his permissions and the conflict rule that affects him.

## 3.3 Teen — "Marcus, 14"

- **Role:** Teen user, in the 13–15 UX segment.
- **Context:** Has his own phone, uses it for schoolwork (Google Classroom, homework research) as much as gaming and social media. Resents being treated "like a little kid" by screen-time apps with cartoon mascots and no way to explain himself.
- **Goals:** Be trusted by default. Have a legitimate way to ask for more time instead of just being told no. Understand exactly why something is blocked, not guess.
- **Frustrations:** Apps that lock everything and make him beg his parents to unlock it. Being blocked from something for homework because the same app also has games.
- **What he needs from Themis Family:** Deadline Lock (not earn-everything-first), a visible agreement he had a hand in, and a request flow that reads as negotiation, not a punishment ticket.
- **Relevant decisions:** DEC-12 (distinct, more autonomous UX), DEC-16 (school apps and homework timers can auto-verify without waiting on a parent), DEC-18 (School Mode's honest limitation directly affects him — he's the one who'll hit the YouTube-for-homework edge case).

## 3.4 Child — "Aisha, 10"

- **Role:** Child user, in the 8–12 UX segment.
- **Context:** Uses a shared family iPad more than her own device. Motivated by simple, visual rewards; doesn't read long text.
- **Goals:** Know clearly what she needs to do to get her games back. Not be confused or scared by a locked screen.
- **Frustrations:** Not understanding why something suddenly stopped working; forgetting what task was required.
- **What she needs from Themis Family:** Large, simple visuals; a single clear next step; a tone that's encouraging, not punitive.
- **Relevant decisions:** DEC-12 (simpler UX segment), DEC-16 (a reading timer she completes herself, without needing a parent's approval in the moment, if the rule is configured that way).

---

## 3.5 Persona-to-decision cross-check

Every persona above is directly shaped by a confirmed decision, not invented independently:

| Persona | Key decisions shaping them |
|---|---|
| Household Owner | DEC-14 (guardian model), DEC-15 (non-response policy), DEC-19 (reporting), DEC-20 (pricing) |
| Guardian | DEC-14 |
| Teen | DEC-12, DEC-16, DEC-17, DEC-18 |
| Child | DEC-12, DEC-16 |

**OPEN QUESTION (new — OQ-14):** Should a household with only one child (no sibling in the other age segment) be a distinct, simpler persona/journey, or is the two-child household above sufficiently representative for Phase 2 journey-mapping? *Recommended default:* Use the two-child household as the primary journey (it exercises more of the system, including multi-child protection-status views), but ensure `04_USER_JOURNEYS.md` also covers a single-child, single-guardian household as the simplest-case journey, since that is plausibly a large share of the actual customer base. *Blocks:* `04_USER_JOURNEYS.md` (addressed there directly).
