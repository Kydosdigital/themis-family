# Claude Design Pass 2 Decision

**Status:** APPROVED DIRECTION — Hybrid A + C, with restrained B warmth
**Reviewed screens:** P-002 Welcome, P-023 Parent Home, C-001 Child Home

## Decision

Do not select A, B or C unchanged.

Use a controlled hybrid:

- **A · Calm Editorial** supplies the typography scale, generous spacing, restrained visual rhythm, and timeline/agreement motif.
- **C · Confident Minimal** supplies the mobile structure, priority hierarchy, status components, grouped sections, quick actions and stronger product confidence.
- **B · Warm Family System** contributes warmth selectively to Child-facing surfaces only: softer tinted containers, mint/aqua/peach accents and gentler geometry.

This is one coherent Themis design system, not three styles mixed screen-by-screen.

## Why

### A alone

Strengths:
- strongest premium/editorial typography
- excellent breathing room
- distinctive timeline motif
- calm and trustworthy
- best emotional restraint

Weaknesses:
- can feel too quiet and slightly generic
- Parent Home lacks enough product confidence
- Child Home risks feeling more like an editorial concept than a daily-use app

### B alone

Strengths:
- warmest and most approachable
- excellent Child friendliness
- soft geometry suits younger users
- strongest emotional comfort

Weaknesses:
- risks looking too soft / nursery-like when applied broadly
- Parent Home loses some premium authority
- Teen experience would require substantial maturation
- less suitable as the master system for the entire product

### C alone

Strengths:
- strongest mobile hierarchy
- clearest Parent Home priorities
- best status treatment
- strongest Teen suitability
- feels decisive and contemporary

Weaknesses:
- cobalt-heavy Welcome feels fintech/SaaS-like
- can become visually hard
- risks generic banking/productivity conventions
- needs more warmth and brand personality

## Approved system

### Typography

Use A as the baseline:
- Manrope
- large confident headlines
- generous leading
- strong hierarchy
- no unnecessarily tiny secondary text
- avoid overly dense labels

C's stronger section labels can be used where utility requires them.

### Layout and hierarchy

Use C as the baseline:
- grouped sections
- one dominant action region
- compact protection/status rows
- clear "Needs you" priority
- floating/obvious quick actions
- strong mobile scan path

Do not reproduce C's heavy full-cobalt screen surfaces as the default.

### Surfaces

Parent:
- mostly white / off-white
- restrained tinted sections
- occasional cobalt emphasis
- minimal borders
- soft shadows only where they clarify hierarchy

Child:
- warmer off-white base
- soft aqua/mint/peach panels
- slightly larger radii
- more breathing room
- larger touch targets

Teen:
- closer to Parent structure
- white/off-white with selective cobalt
- fewer soft pastel blocks than Child
- mature typography and status treatment

### Brand motif

Adopt A's **timeline / agreement-line motif** as a recurring brand device.

Use it for:
- Welcome storytelling
- homework deadlines
- bedtime windows
- rule schedules
- request duration
- progress through family agreements

It must remain subtle and functional, not decorative noise.

### Colour

Primary:
- cobalt #2563EB

Support:
- mint #34D399
- aqua #7DD3FC
- peach #FFB79E

Rules:
- cobalt is the primary action/brand colour, not a full-screen default
- mint signals positive/verified states where appropriate
- aqua supports informational/neutral states
- peach supports warnings/attention without punitive red
- no purple
- avoid colour overload

### Status components

Use C's direction:
- icon + text + semantic tint
- never colour-only
- compact enough for Parent Home
- readable enough for Child
- status pills should not look like enterprise admin badges

### Buttons

Use C's confident primary-action treatment with A's restraint:
- strong cobalt primary
- generous height
- clear text
- secondary actions as calm outline/text/surface buttons
- no oversized web-style pills everywhere

### Child experience

Borrow B's warmth, but not B's whole design system.

Allowed:
- warmer background
- soft tinted panels
- larger rounded containers
- friendlier spacing
- slightly more visual reinforcement

Avoid:
- overlapping-circle motif as a global brand device
- nursery feel
- cartoon visual language
- excessive pastel usage

### Welcome screen

Do NOT use C's all-cobalt hero as the final direction.

Preferred:
- A's editorial white-space composition
- A's timeline/agreement motif
- slightly more visual warmth from B
- one strong cobalt CTA
- richer motion/illustration treatment without introducing a generic hero image

Goal:
premium and memorable, not fintech.

### Parent Home

Use C's architecture and hierarchy.

Keep:
- strong Needs You block
- compact child status rows
- clear quick actions
- protected/sync states with icon + label
- clear sectioning

Soften:
- large solid cobalt blocks
- overly utility/dashboard feel

Add:
- A-level spacing and typography
- small warm accent moments
- more refined surface hierarchy

### Child Home

Use:
- C's clear task hierarchy
- A's timeline motif
- B's softer surfaces and warmer palette

The Child Home should feel reassuring, not gamified.

The main task/deadline should dominate, with:
- clear due time
- clear consequence
- one obvious primary action
- simple secondary request action

## Motion direction

Use A's calm sequencing:
- progressive appearance
- 450–800ms range for hero/story transitions
- no bounce-heavy motion
- no decorative perpetual motion

Use B/C micro-interactions for:
- status changes
- button confirmation
- approval/application state changes
- timeline progress

Respect Reduce Motion.

## Do not do

- no full-screen cobalt as a default pattern
- no overlapping Venn circles as the main brand identity
- no generic finance-dashboard look
- no nursery/kids-app aesthetic
- no dense card wall
- no glassmorphism overload
- no purple
- no cyber-security shield language
- no visual divergence that makes Parent/Child/Teen feel like different products

## Pass 3 gate

Pass 3 may now begin using this approved hybrid system.

Before rolling out all screens, Claude Design should first produce a **Design System Foundation board** containing:
- typography
- semantic colours
- surfaces
- radii
- buttons
- inputs
- status components
- cards
- tabs/navigation
- sheets
- banners
- timeline/agreement motif
- Parent / Child / Teen variants
- motion principles
- accessibility notes

Then apply the system to the core Pass 3 journeys.

Screen IDs must remain unchanged.
