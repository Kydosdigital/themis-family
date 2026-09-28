# 13. School and Essential Access

**Status:** Phase 3 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md` HLR-010, HLR-011, `35_DECISION_LOG.md` DEC-18, DEC-26

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
- **Happy path:** Parent configures: (a) Always Allowed apps/sites that specifically represent school tools (Google Classroom, Teams, a school portal, etc. — the definitive UK default list is pending research, OQ-07), (b) a school-hours schedule during which entertainment categories are restricted, (c) confirmation that temporary educational access requests are enabled (they are, by default, in V1 — see FR-052).
- **Failure paths:** Parent's child's school uses a platform not in the suggested list → parent manually adds it via the picker; the product does not require every possible school platform to be pre-catalogued to function, only to be convenient.
- **Business rules:** BR-221 (capability-honesty requirement — see below)
- **Release:** V1 / Must
- **Open questions:** OQ-07 (definitive UK school-platform list, still open — research task, does not block this FR's implementation)

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
- **Happy path:** The system either prevents this selection at the picker level (RECOMMENDATION) or allows selection but silently keeps a hard-coded minimum essential set always allowed regardless (a defence-in-depth decision to be made in Phase 5, not here) — either way, a small, non-configurable essential minimum (Phone, Emergency SOS-adjacent functionality) can never be shielded, even by parent choice.
- **Business rules:** BR-222
- **Release:** V1 / Must
- **Open questions:** OQ-28 (exact non-configurable minimum set)

**BR-222.** There exists a small, non-configurable minimum set of essential functionality (at minimum: the Phone app / emergency calling capability) that cannot be added to any restrictive rule's targets, cannot be removed from Always Allowed, and is not subject to parental configuration at all. Beyond this hard minimum, all other "essential" designations (Messages, Maps, school apps, etc.) are configurable via Always Allowed (FR-050), not hard-coded.

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

**OQ-28 [NEW].** What exactly is in the hard-coded, non-configurable minimum essential set (BR-222) — just Phone/Emergency calling, or also something like a default Maps/location-sharing-for-safety capability?
- *Why it matters:* Too narrow a hard-coded minimum relies entirely on parent configuration for basic safety (risk if a parent misconfigures Always Allowed); too broad removes parental choice and could itself be seen as overreach.
- *Recommended default:* Keep the hard-coded minimum to Phone/emergency calling only; treat Messages and Maps as strongly-recommended, pre-selected Always Allowed defaults (configurable, but defaulted on) rather than hard-coded, consistent with the brief's general preference for parent configurability over rigid defaults.
- *Blocks:* `13_SCHOOL_AND_ESSENTIAL_ACCESS.md` itself (this document) is written assuming this recommendation; `24_SECURITY_REQUIREMENTS.md`/`26_ERROR_AND_EDGE_CASE_CATALOGUE.md` (Phase 6/7) should confirm before final.
