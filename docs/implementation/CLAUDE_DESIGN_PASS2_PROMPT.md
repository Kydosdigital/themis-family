# Claude Design Pass 2 Prompt: Visual Explorations

Pass 1 architecture is approved.

The final three Pass 1 decisions have been incorporated:
- already-paired child devices cannot self-remove from the old household; Owner/Guardian removal or secure recovery is required
- Parent Home now has a setup-incomplete state for an unfinished child while other protected children remain independently verified
- Child/Teen household wording uses "your parent or carer" / household-neutral language; pending Guardian invitations do not count

You may now begin **Pass 2 only**.

Do NOT redesign the information architecture.
Do NOT add new product features.
Do NOT roll a chosen visual style across the entire app yet.

## Objective

Create **three genuinely distinct high-fidelity visual directions** for only these three anchor screens:

- P-002 Welcome
- P-023 Parent Home
- C-001 Child Home

The information hierarchy and required content must stay consistent with the approved Pass 1 structure.

The purpose is to decide what Themis Family should *feel like* before styling 90+ screens.

## External design references

You may use these as **visual inspiration and pattern references**, not as implementation dependencies:

- shadcn/ui: https://ui.shadcn.com/
- 21st.dev: https://21st.dev/

Important:
- Themis is a native SwiftUI iOS/iPadOS app.
- Do NOT copy React/Tailwind implementation patterns into the mobile interaction model.
- Do NOT turn Parent Home into a web dashboard.
- Do NOT import web-only affordances such as hover states, desktop sidebars, dense data tables, tiny controls or browser-style navigation.
- Translate any useful visual idea into native iOS composition, spacing, sheets, tabs, controls and accessibility behaviour.
- Prefer Apple-native interaction conventions where a web reference conflicts with mobile expectations.
- If a reference is used, borrow the visual principle, not the source code.

For Pass 2, 21st/shadcn can help inspire:
- premium card/surface treatment
- hierarchy
- micro-interaction ideas
- empty states
- soft status treatments
- tasteful motion concepts
- form composition
- visual rhythm

They must NOT dictate:
- navigation architecture
- Apple permission UI
- Screen Time enforcement UI
- component implementation technology
- final brand identity


## Product feel

Themis should feel:
- premium
- calm
- trustworthy
- warm
- modern 2026 consumer app
- native to iOS
- clear for busy parents
- reassuring for children
- dignified and non-childish for teens
- visibly different from generic parental-control/security software

It should NOT feel:
- bland
- enterprise
- clinical
- punitive
- cyber-security themed
- surveillance-heavy
- childish
- like a web dashboard placed inside an iPhone frame

## Approved brand direction

Use:
- lots of white / breathing room
- cobalt #2563EB as primary
- mint #34D399
- soft aqua #7DD3FC
- peach #FFB79E
- light grey #E5E7EB
- soft grey #F6F7F9
- dark navy-toned text
- Manrope typography direction

Do NOT use purple.

The logo is not approved.
Use a tasteful temporary wordmark/placeholder only.

## Exploration A: Calm Editorial

Direction:
- premium editorial spacing
- strong typography hierarchy
- restrained colour
- larger quiet areas
- elegant cards with minimal borders
- sophisticated and trustworthy
- subtle use of aqua/mint/peach as soft highlights
- feels closer to a premium finance/wellbeing app than a utility dashboard

Risks to avoid:
- too sterile
- too adult for children
- excessive serif/editorial styling

## Exploration B: Warm Family System

Direction:
- warmer surfaces
- softer geometry
- more visible use of mint/aqua/peach
- friendly but polished
- subtle illustration/shape language
- comfortable for an 8–12 year-old without becoming childish
- still sophisticated enough for the parent product

Risks to avoid:
- nursery aesthetic
- cartoonish icons
- over-rounded "kids app" design
- clutter

## Exploration C: Confident Minimal

Direction:
- bolder cobalt hierarchy
- strong mobile-native sections
- minimal decoration
- crisp iconography
- expressive status components
- premium startup feel
- clear action hierarchy and thumb-friendly controls
- teen-friendly and contemporary

Risks to avoid:
- generic SaaS
- harsh technical feel
- too much blue
- looking like a banking/admin app

## P-002 Welcome requirements

Must communicate quickly:
- Themis Family
- "Clear digital boundaries without the daily arguments."
- "Set clear digital rules once, and let the phone enforce them."
- homework / bedtime / gaming boundary concept
- primary "Get started"
- secondary "This is my child's iPhone"

This should be the most emotionally memorable screen of the three.

Explore:
- abstract visual motif
- subtle motion concept
- device/family-boundary metaphor
- non-literal illustration

Do not use:
- generic shield hero
- literal family silhouette
- Greek scales/columns
- final logo invention

## P-023 Parent Home requirements

Preserve the approved mobile priority order:
1. needs attention
2. protection health / children
3. current agreements
4. quick actions

Use example content:
Sarah
Sam · Child
Maya · Teen

Show one state with:
- Sam homework waiting for review
- approval grace ends in 18 min
- Maya request pending
- Sam Protected
- Maya Sync Pending
- Add rule
- Free Pass

This must feel like a **mobile family control centre**, not an analytics dashboard.

Avoid:
- too many equal-weight cards
- dense metrics
- desktop-style widgets
- overlong text above the fold

Consider:
- stronger prioritisation of "Needs you"
- compact child status rows
- calm protection indicators
- thumb-reachable quick actions

## C-001 Child Home requirements

Use Sam, Child experience.

Must show:
- "Themis is active"
- Homework due 6:00 PM
- what happens if it is not done
- primary "I've finished my homework"
- secondary "Ask for more time"
- access to "What can my parent or carer see?"
- bottom tabs Home / My Rules / Requests

The Child UI should feel warmer and simpler than Parent Home, but still part of the same design system.

It must NOT:
- look babyish
- use punishment language
- resemble a game reward economy
- look like a school worksheet

Create an optional small supporting variant or annotation showing how the same system would mature for Maya's Teen Home, but do not make Teen Home a fourth full exploration screen unless needed to demonstrate the visual system.

## Mobile quality bar

For all three directions:
- design for real iPhone dimensions and safe areas
- primary actions thumb-friendly
- no tiny text
- no horizontal desktop layouts
- adequate touch targets
- status never colour-only
- Dynamic Type should remain plausible
- content should fit natural mobile scanning
- keep navigation native and predictable

## Distinctness requirement

The three directions must be meaningfully different.

Do not create:
- the same white card UI with slightly different colours
- three minor border-radius variations
- three versions of the same layout

Keep the *information architecture* stable while changing:
- hierarchy
- composition
- surface treatment
- colour usage
- icon/shape language
- typography scale
- emotional tone

## Self-critique

After creating A, B and C, compare them in a single review section.

For each direction score qualitatively:
- mobile clarity
- premium feel
- warmth
- Parent suitability
- Child suitability
- Teen suitability
- brand distinctiveness
- accessibility risk
- risk of feeling generic

Then recommend one direction or, if appropriate, a clearly-defined hybrid such as:
"A's typography + B's warmth + C's status components."

Do not silently merge them before founder review.

## Stop point

STOP after presenting the three directions, comparison, and recommendation.

Do NOT apply any direction to the rest of the app.

The founder will select or amend the visual direction before Pass 3 begins.
