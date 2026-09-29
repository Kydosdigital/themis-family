# Claude Design Pass 3 Review

Status: CONDITIONAL APPROVAL

Pass 3 is strong. The hybrid visual direction is coherent, the design system and core journeys feel like one product, and the major product states are represented correctly.

Pass 4 should wait for the small corrections below.

## Approved direction

Keep:
- Manrope hierarchy
- Parent white/grouped-grey surfaces
- Child warm off-white surface
- restrained Teen surfaces
- cobalt for primary actions and selection
- mint/aqua/peach as support colours
- icon + word + tint status system
- rows as the default pattern, with cards reserved for meaningful action/state
- native navigation patterns
- timeline/agreement motif
- one shared component system for Parent, Child and Teen
- Reduced Motion fallbacks
- Approved -> Applying -> Applied
- multiple-restriction explanation
- request / partial approval / one clarification
- Free Pass grant/revoke
- setup-incomplete resume
- protection recovery

## Amendment 1: R-011 Always Allowed conflict

The parent must not choose an ad-hoc winner between a restrictive rule and Always Allowed.

Always Allowed wins.

Required UX:

Title:
"This app is Always Allowed."

Body:
"Always Allowed apps stay available even when this rule is active."

Actions:
- Keep Always Allowed
- Review Always Allowed settings

If the parent wants the app included in the restrictive rule, they must first change its Always Allowed setting and then return to rule setup.

Do not offer a per-rule override.

## Amendment 2: Dynamic Type

Claude's proposed accessibility fixes are approved.

At accessibility text sizes:
- Parent Home Add rule / Free Pass actions move inline into scroll content
- the floating dock must not cover content
- horizontal timelines switch to a stacked semantic list when labels no longer fit
- meaning-bearing labels must not be truncated

Apply this as reusable component behaviour, not a one-screen exception.

## Amendment 3: Welcome memorability

Keep P-002's layout.

Add a motion study for the timeline/agreement motif:
1. Homework band enters
2. Gaming state settles
3. Bedtime band enters
4. current-time marker settles
5. headline and CTA resolve

The idea should communicate:
chaos -> agreement -> clarity

Reduced Motion uses the static final state.

## Amendment 4: Privacy wording

On P-011, avoid broad wording equivalent to:
"Read messages or browsing"

Use:
"Themis doesn't read your messages or give your parent or carer a full browsing/search-history feed."

This keeps the distinction between Themis data and Apple's own parental reporting clear.

## Amendment 5: Sign in with Apple copy

Avoid:
"Apple handles your password."

Use:
"Sign in securely with Apple."

or:
"Apple handles your sign-in."

## Amendment 6: Contrast status

The colour system is suitable as a design direction, but estimated contrast values are not the final implementation verification.

Label the board:
"Design contrast check: passes target values. Implementation verification required."

## Amendment 7: School-app placeholders

S-002/S-003 may keep example UK school apps for layout purposes.

Add:
"Examples only. Not recommendations or a supported-app directory."

## Founder decisions

R-011:
Always Allowed stays available. To restrict an item, change its Always Allowed setting first.

Largest Dynamic Type:
Use the inline quick-actions and stacked-timeline fallbacks proposed by Claude.

Welcome:
Keep the layout and add the timeline motion study.

Activity and Settings:
May remain inactive in the Pass 3 prototype because they are Pass 4 areas.

School examples:
Allowed only as clearly labelled examples.

## Gate to Pass 4

Pass 4 can begin after these seven changes are applied and Claude confirms no new product behaviour was introduced.
