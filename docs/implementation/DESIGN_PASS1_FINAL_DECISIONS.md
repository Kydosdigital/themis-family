# Claude Design Pass 1 Final Decisions

**Status:** Founder-design review decisions. These clarify the amended Pass 1 before Pass 2 and do not alter the approved requirements baseline.

## Q1. Can a child device remove itself from an existing household binding?

**Decision: NO in V1.**

A managed child device may not directly remove itself from its currently bound Themis household.

Normal transfer remains:
1. Owner or Guardian of Household A removes/transfers the device.
2. Existing child-device credential is revoked.
3. The old household binding is cleared.
4. The device may then pair with Household B.

If the old household cannot perform the removal, use the secure recovery path already required by DEC-60.

The child device may explain what is needed, for example:
"This device already belongs to another Themis household. Ask your parent or carer to remove it, or use secure recovery."

Do not add a V1 self-removal action.

Do not treat physical possession of the child device as sufficient authority to clear the old household binding.

## Q2. If pairing is deferred, should Parent Home show a resume-setup card?

**Decision: YES.**

If the parent chooses "Do this later" before the child's device is paired/authorised and protection is activated, Parent Home must surface a prominent incomplete-setup card.

Reuse the P-004 visual/status language:
- neutral, not green
- "Protection not active yet"
- child-specific where relevant
- clear next action such as "Finish setting up Sam"

Examples:

"Sam's protection isn't active yet."
"Finish pairing Sam's iPhone to continue setup."

If the household has no protected children yet, this setup-resume card should be one of the most prominent items on Home.

If some children are protected and another child is incomplete, show the incomplete child clearly without downgrading the verified protection status of the others.

Do not show the incomplete child as Protected.

## Q3. Does a pending Guardian invitation affect child-facing singular/plural copy?

**Decision: NO.**

A Guardian counts for household-aware copy only after the invitation has been accepted and the Guardian is an active household member.

Pending invitations do not change:
- "your parent or carer"
- singular/plural household wording
- permission assumptions
- notification recipients

If dynamic copy is used:
- one active adult role -> singular wording where appropriate
- Owner + accepted Guardian -> plural wording where appropriate
- pending invite -> ignored until accepted

However, prefer household-neutral wording where it reads naturally, such as:
- "your parent or carer"
- "your family"
- "the adults in your household"

Do not use Child vs Teen age segment to decide singular/plural wording.

## Pass 2 gate

With the twelve A-L amendments applied and the three questions above resolved, Pass 1 architecture is approved to move into Pass 2 **provided Claude Design confirms these three final decisions have been incorporated without introducing new structural product behaviour.**

Pass 2 remains limited to 2-3 visual explorations for:
- P-002 Welcome
- P-023 Parent Home
- C-001 Child Home

Do not roll a visual direction across the entire app until one exploration is founder-approved.
