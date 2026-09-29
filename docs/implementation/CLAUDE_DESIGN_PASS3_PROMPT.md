# Claude Design Pass 3 Prompt — High-Fidelity Core Journeys

Pass 2 is approved as a **controlled hybrid direction**.

Read first:

- `docs/implementation/DESIGN_PASS2_DECISION.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `docs/implementation/DESIGN_PASS1_REVIEW.md`
- `docs/implementation/DESIGN_PASS1_FINAL_DECISIONS.md`

Do not improvise a fourth visual direction.

## Approved visual formula

Use:

**A · Calm Editorial**
for:
- typography
- generous spacing
- restrained visual rhythm
- timeline/agreement motif

**C · Confident Minimal**
for:
- mobile information hierarchy
- grouped sections
- status components
- Parent Home structure
- quick actions
- Teen maturity

**B · Warm Family System**
only as controlled warmth for Child-facing surfaces:
- soft tinted containers
- gentler geometry
- mint/aqua/peach accents
- slightly warmer background

Do not mix all three arbitrarily.

The final app must feel like one brand.

## Step 1 — Build the design-system foundation first

Before producing the core journey screens, create a dedicated design-system board.

Include:

### Typography
- Manrope hierarchy
- display
- page title
- section heading
- body
- secondary
- caption
- button
- Child variants
- Teen variants
- Dynamic Type notes

### Semantic colours
Use tokens, not scattered raw values.

Include:
- brand primary
- brand secondary
- background
- surface
- surface warm
- text primary
- text secondary
- border
- success / verified
- info
- warning / attention
- unavailable / error
- status backgrounds
- Child support colours

No purple.

### Surfaces
Define:
- Parent base surface
- Child base surface
- Teen base surface
- elevated surface
- grouped section
- selected state
- warning state
- protection state

### Radius scale
Keep coherent:
- small
- medium
- large
- sheet/card
- Child variation if required

### Buttons
- primary
- secondary
- tertiary/text
- destructive
- loading
- disabled
- Child larger-touch variant

### Inputs
- text
- search
- selection row
- segmented control
- time selection
- reason input
- validation/error

### Status system
- Protected
- Sync Pending
- Device Offline
- Needs Attention
- Protection Unavailable
- Pending
- Grace
- Approved
- Applied
- Declined
- Expired
- Partial
- Active Free Pass

Every status:
icon + label + optional semantic tint.

Never colour-only.

### Cards / rows
- action card
- child status row
- rule card
- task card
- request card
- protection card
- setup-incomplete card
- Free Pass card
- activity row

### Navigation
- Parent tabs
- Child/Teen tabs
- top bars
- back actions
- action-centre bell/count
- sheet style

### Timeline/agreement motif
Formalise A's timeline as a reusable brand/product motif.

Use it for:
- deadlines
- bedtime windows
- focus sessions
- request duration
- rule schedules
- onboarding storytelling

Do not overuse it decoratively.

### Motion
- transition durations
- spring usage
- approval/applying/applied transition
- countdown treatment
- reduced-motion fallback

### Parent / Child / Teen relationship
Show side-by-side examples proving they are one system.

Parent:
more restrained.

Child:
warmer and simpler.

Teen:
mature, closer to Parent.

## Step 2 — High-fidelity onboarding

Apply the approved system to:

P-001 through P-023.

Remember:
- P-008, P-014, P-021 are lightweight states
- Account Created is NOT Protection Activated
- Apple-owned UI remains system handoff
- pairing recovery states remain visible
- no unapproved exact pairing-code TTL
- generic homework uses Parent Approval
- protection test is mandatory
- setup incomplete state must exist if pairing is deferred

Keep onboarding feeling achievable.

Do not make 20+ screens feel like 20+ heavy steps.

## Step 3 — Parent core

Design high fidelity:

P-023 Parent Home
P-023 · Setup incomplete
P-029 Child detail
P-030 all five protection states
P-031 Fix this
A-001 Action Centre
A-002 through A-011
F-001 through F-010

Parent Home must preserve:
1. Needs You
2. children/protection
3. agreements
4. quick actions

Use C's hierarchy with A's spacing/typography.

## Step 4 — Child and Teen core

Design:

C-001 through C-017
Q-001 through Q-014
E-001 through E-007

Child:
- warmer surfaces
- larger touch targets
- simpler copy
- no babyish visuals

Teen:
- mature
- less pastel
- more compact
- autonomy-respecting

Same product system.

## Step 5 — Rules and school access

Design:

R-001 through R-015
S-001 through S-005

Do not fabricate Apple pickers.

Use Themis explanation before/after Apple-owned UI.

## Step 6 — Core prototype connections

Make these clickable:

1. complete Owner onboarding
2. create first Homework Deadline rule
3. Parent Home
4. Child Home
5. on-time submission
6. grace period
7. parent approval
8. Approved → Applying → Applied
9. overdue restriction
10. multiple restrictions
11. request +15
12. partial approval
13. one clarification exchange
14. Free Pass grant/revoke
15. setup incomplete → resume setup
16. protection problem → Fix this

## Quality bar

The result must feel:
- premium
- native iOS
- recognisably Themis
- calmer than C alone
- more confident than A alone
- more mature than B alone

Do not:
- make every surface a card
- make every Child surface pastel
- use giant cobalt blocks repeatedly
- add decorative gradients everywhere
- create a generic fintech look
- create a nursery/kids aesthetic

## Accessibility

Check:
- contrast
- Dynamic Type
- touch targets
- VoiceOver hierarchy
- reduced motion
- no colour-only meaning
- long text resilience

Include at least:
- Parent Home large-text stress test
- Child Home large-text stress test

## Stop point

STOP after:
- design-system foundation
- high-fidelity core journeys
- clickable core prototype
- accessibility check
- concise self-critique

Do not move into Pass 4 reporting/subscription/settings/support states until founder review.
