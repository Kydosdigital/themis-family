# 13. School and Essential Access

**Status:** Phase 3, amended 2026-09-28 (Phase 6 founder review round — closes OQ-07, see `35_DECISION_LOG.md` DEC-52 through DEC-59)
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md` HLR-010, HLR-011, `35_DECISION_LOG.md` DEC-18, DEC-26

**Amendment note (this round):** OQ-07 (definitive UK school-platform list) is closed as a non-blocking research item — see the correction to FR-051 below. School Mode was already designed as platform-agnostic in the original draft; this amendment confirms that explicitly as policy rather than leaving it framed as a pending research dependency.

---

## 13.1 Always Allowed apps and websites

## FR-050. Configure Always Allowed items
- **Actor:** Owner or Guardian
- **Trigger:** Parent adds an app or website to the Always Allowed list, during onboarding (auto-suggested — see `04_USER_JOURNEYS.md` §4.1) or later from Settings
- **Preconditions:** None
- **Happy path:** Parent selects apps/sites via Apple's picker (or a domain entry for websites) and marks them Always Allowed. These targets are excluded from every other rule's shielding, unconditionally (BR-202, `10_RULE_ENGINE_SPECIFICATION.md`).
- **Alternative paths:** A sensible default set is auto-suggested at onboarding (Phone, Messages, Maps — brief §"Emergency and always-allowed access"); parent can accept, remove, or add to it.
- **Failure paths:** Parent attempts to add an app that is already targeted by an active restrictive rule → BR-220 (adding to Always Allowed always wins; the app is removed from the restrictive rule's target list automatically, and the parent is told this happened, not left to wonder why the rule "stopped working" for that app).
- **Permissions:** Owner, Guardian only
- **Business rules:** BR-202 (never overridden — `10_RULE_ENGINE_SPECIFICATION.md`), BR-220
- **Release:** V1 / Must

**BR-220.** Marking an app/site as Always Allowed automatically removes it from any rule's Controlled Targets list; the reverse (adding an Always Allowed item to a new rule's Controlled Targets) is blocked at the point of rule creation with a clear message, not silently ignored.

---

## 13.2 School Mode

## FR-051. Configure School Mode
- **Actor:** Owner or Guardian
- **Trigger:** Parent sets up School Mode, typically during onboarding or from Settings
- **Preconditions:** None
- **Happy path:** Parent configures: (a) Always Allowed apps/sites that represent school tools, selected by the parent themselves via Apple's picker — **CONFIRMED this amendment round: School Mode is platform-agnostic and does not depend on Themis maintaining a national school-app directory.** Themis may offer optional suggested starter items based on UK user research (e.g. Google Classroom, Microsoft Teams, Satchel One, Seneca — named here only as research/example items visible through Apple's picker, not a commitment to name-specific support), but the catalogue does not need to be exhaustive and Themis does not guarantee support for every UK school platform by name; (b) a school-hours schedule during which entertainment categories are restricted; (c) confirmation that temporary educational access requests are enabled (they are, by default, in V1 — see FR-052).
- **Failure paths:** Parent's child's school uses a platform not in any suggested list → parent adds it through the normal selection mechanism (the picker), exactly as any other Always Allowed item; this is the ordinary path, not an exception requiring product-level accommodation.
- **Business rules:** BR-221 (capability-honesty requirement — see below)
- **Release:** V1 / Must
- **Open questions:** **OQ-07 [RESOLVED — see `35_DECISION_LOG.md` DEC-52 through DEC-59]. Closed as a non-release-blocking item.** School Mode's core function does not depend on a definitive, exhaustive UK school-platform catalogue; an unknown/new school platform is added through the normal parent-driven selection mechanism. Optional suggested starter items remain a UX-polish opportunity for Phase 7, not a release blocker.

**BR-221 (capability honesty — restates DEC-18 as a binding rule, not just a positioning note).** Nowhere in the product's UI, onboarding copy, help content, or marketing material may School Mode be described as able to distinguish educational from entertainment content *within* the same app or website (the canonical example being YouTube). Every description of School Mode must be limited to: Always Allowed apps/sites, a school access list, a school-hours schedule, and time-boxed temporary educational access requests. This is a release-blocking documentation/copy constraint, not merely a technical footnote — Phase 6's privacy/marketing-facing documents must inherit this constraint directly.

## FR-052. Temporary educational access request
- **Actor:** Child or Teen (requests), Owner or Guardian (approves)
- **Trigger:** Child/teen needs a specific normally-restricted app/site for schoolwork during a restricted period
- **Preconditions:** A restriction is currently active on the target
- **Happy path:** This is a specific application of the general Request/Grant mechanism in `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md` (Request type: Temporary access), with the reason field pre-populated with a School Mode-relevant prompt ("What do you need this for?"). Approval creates a time-boxed grant per FR-044, which expires and re-locks automatically per DEC-30, without the parent needing to remember to manually re-restrict it.
- **Business rules:** Inherits BR-215 through BR-219 from `12_REQUESTS_AND_EXCEPTIONS_SPECIFICATION.md`; adds no new business rules of its own — this FR exists to document the School Mode-specific *framing* of the general mechanism, not a separate code path.
- **Release:** V1 / Must

---

## 13.3 Essential access / safety-critical apps

## FR-053. Essential access cannot be restricted
- **Actor:** System, Owner/Guardian (configuration)
- **Trigger:** Parent attempts to add a designated essential category app (Phone, Messages, Maps/emergency-relevant apps) to a restrictive rule's targets
- **Preconditions:** None
- **Happy path:** The system either prevents this selection at the picker level (RECOMMENDATION) or allows selection but silently keeps the hard safety principle enforced regardless (a defence-in-depth decision to be made in Phase 5, not here) — either way, emergency calling / emergency OS-level functionality can never be deliberately restricted by Themis, even by parent choice.
- **Business rules:** BR-222
- **Release:** V1 / Must
- **Open questions:** OQ-28 is closed at the product-policy level (§13.3, DEC-35); OQ-30 (NEW) tracks the remaining technical-validation question.

**BR-222 (hard safety principle, CONFIRMED — DEC-35; closes OQ-28 at the product-policy level).** Themis Family must never intentionally interfere with emergency communication or OS-level emergency functionality. Emergency calling and emergency OS-level functionality are never deliberately restricted by Themis, for any child, under any rule configuration, with no parental override capable of changing this. This is a product policy decision, confirmed now, and does not depend on the outcome of the technical spike.

Beyond that hard floor, the **recommended default Always Allowed set**, where technically supported, is: **Phone, Messages, Maps**. Messages and Maps are strongly recommended and pre-selected during onboarding (per FR-050's auto-suggested defaults) but remain parent-configurable — they are not hard-coded like the emergency-calling floor itself.

**Themis Family must not claim that a specific system app is technically impossible to shield until the Apple technical spike verifies that behaviour.** The product policy above (the hard safety principle) is confirmed independently of any such claim; what remains open is only the technical question of exactly what Apple's picker and ManagedSettings framework actually expose or permit for these specific system apps — see OQ-30.

---

## 13.4 Shared-device exclusion (carried from DEC-26)

## FR-054. School/essential access documentation must state the single-device-per-child assumption
- **Actor:** N/A (documentation requirement)
- **Trigger:** N/A
- **Happy path:** Wherever School Mode or essential access setup is described (onboarding copy, help content, this specification, later UX-facing documents), it must state the V1 assumption that each child has their own device signed into their own Child Apple Account (DEC-26), and must not imply that a shared device (siblings sharing an iPad, etc.) receives correctly-separated per-child School Mode or essential-access configuration.
- **Business rules:** Restates DEC-26/HLR-023 in this document's specific context.
- **Release:** V1 / Must (as a documentation constraint)
- **Open questions:** OQ-17 (shared-device research, still open, tracked centrally in `34_OPEN_QUESTIONS.md`)

---

## 13.5 Open questions surfaced by this document

**OQ-28 [CLOSED at the product-policy level — resolved by DEC-35/BR-222; split into a remaining technical question, OQ-30].** The founder confirmed the product policy: emergency calling/OS-level emergency functionality is never deliberately restricted (hard safety principle), with Phone, Messages and Maps as the recommended default Always Allowed set where technically supported. What remains open is purely technical — see OQ-30.

**OQ-30 [NEW — split from OQ-28].** What does Apple's picker and ManagedSettings framework actually expose or permit for Phone, Messages, and Maps specifically — can each be technically guaranteed un-shieldable, or does Apple's API only support shielding at a granularity that makes some part of this harder than the product policy assumes?
- *Why it matters:* BR-222's product policy is confirmed and does not wait on this answer, but the documentation must not claim a specific technical guarantee (e.g. "Phone can never be shielded by any configuration") until the Apple technical spike verifies it. An unverified API assumption must not become a stated requirement.
- *Recommended default:* None — this is a pure technical-spike output, not a product judgement call.
- *Blocks:* `27_APPLE_INTEGRATION_REQUIREMENTS.md` (Phase 5); `24_SECURITY_REQUIREMENTS.md` (Phase 6) should confirm the final wording of any "cannot be restricted" claim against the spike's actual findings before release.
