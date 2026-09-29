# Themis Family Engineering Handoff Final Review

**Status:** APPROVED FOR CLAUDE CODE UI IMPLEMENTATION

**Scope of this approval:** native SwiftUI UI implementation, navigation, mock-driven screen states, accessibility behaviour, and visual handoff implementation.

**Not approved by this document:** production Screen Time enforcement, unresolved Apple capability behaviour, final pricing, final safeguarding operations, final legal copy, or any other spike-gated production behaviour.

## 1. Handoff package review

The Pass 5 Engineering Handoff is sufficiently complete to serve as the implementation contract for the approved UI.

It contains:
- final 216-screen/state inventory
- stable screen IDs
- component inventory
- design tokens
- SF Symbols recommendations
- native-vs-custom control decisions
- motion specifications
- visual state matrix
- screen-to-requirement matrix
- Apple/spike dependency flags
- asset register
- recommended SwiftUI implementation order
- per-screen design-to-code acceptance checklist

The package correctly separates:
- approved UX
- technically provisional Apple behaviour
- not-yet-final product/legal/commercial content

## 2. Approved engineering direction

Claude Code may begin implementing the approved UI.

Start with the non-spike foundation:
1. semantic design tokens
2. Manrope typography integration
3. reusable primitives
4. shared status system
5. Parent / Child / Teen navigation shells

Then continue in the approved dependency order from the Engineering Handoff.

The current mock/repository abstraction should remain useful while backend work is deferred.

Do not connect an unrelated Supabase project.

Do not make production Apple enforcement claims merely because a visual state exists.

## 3. Native-vs-custom mapping

The handoff's control mapping is approved.

Prefer native/system behaviour for:
- TabView / adaptive iPad navigation
- NavigationStack / NavigationSplitView
- sheets / confirmation dialogs
- DatePicker
- segmented Picker
- TextField
- Toggle
- Sign in with Apple
- Family Controls authorisation
- FamilyActivityPicker
- StoreKit flows
- Apple Screen Time reporting
- Apple shield surfaces

Use custom Themis components for:
- semantic status presentation
- Needs You
- task/rule/request rows
- protection cards
- Free Pass cards
- agreement timeline
- stacked accessibility timeline
- countdown/progress presentation
- branded banners and empty/error states

Do not reproduce Apple-owned UI as custom Themis screens.

## 4. Accessibility approval

The design-level accessibility contract is approved.

Implementation must verify:
- Dynamic Type
- 44pt+ interactive targets
- Parent/Teen/Child audience sizing
- stacked timeline fallback at accessibility sizes
- inline quick actions when the floating dock would obstruct content
- stacked key/value rows at the largest sizes
- VoiceOver grouping/order
- status not communicated by colour alone
- Reduce Motion
- iPad adaptation
- actual rendered contrast

The design contrast checks are not a substitute for implementation verification.

## 5. Traceability review

Five handoff rows remain marked "Traceability check required." This is acceptable and does not block UI implementation.

### P-001 Launch
This is primarily a presentation/navigation-shell state. It does not need a fabricated standalone functional requirement.

### P-003 Sign in with Apple
The handoff can be tightened during implementation review to reference:
- SEC-014 in `24_SECURITY_REQUIREMENTS.md`
- Parent onboarding in `14_PARENT_EXPERIENCE.md` §14.2

### P-005 What are you struggling with?
This is explicitly part of the approved onboarding journey in `04_USER_JOURNEYS.md`. It may remain a journey/UX-level screen without a standalone FR.

### ST-012 Account
Authentication/session requirements SEC-014/SEC-015 are relevant, but the Account settings container itself is primarily presentation/navigation.

### ST-012 · Sign out
Before production authentication wiring, document the exact sign-out/session-revocation implementation against SEC-015. Do not invent a new product rule simply to remove the traceability marker.

A UX screen does not require a fake FR merely to make every matrix row non-empty.

## 6. Apple/spike gates

The Engineering Handoff correctly keeps these technically provisional:
- Priority 0 Family Controls production entitlement
- Priority 1 remote decision -> applied-on-device propagation
- Priority 2 Phone / Messages / Maps exact shield behaviour
- scheduled transitions while the app is terminated
- shield persistence/removal
- Apple Screen Time report availability on the parent device
- trusted-time / monotonic reliability
- compromised-device timing integrity
- OQ-19 protection staleness threshold

Claude Code may implement their approved visual states and mock transitions.

Production behaviour must remain gated until the relevant spike is complete and recorded.

## 7. One requirements clarification before ST-011 production wiring

There is a specification ambiguity around household deletion and App Store billing.

The current Household state-machine text says deletion cascades to:
"Subscription cancelled."

The approved design copy distinguishes this from the user's App Store auto-renewing subscription and tells the Owner that App Store subscription management may still be required.

These can coexist if "Subscription cancelled" means the **Themis household/internal entitlement relationship** is terminated while Apple remains the source of truth for the **App Store auto-renewing subscription**.

However, that distinction is not explicit enough in the frozen requirements.

### Engineering rule

- ST-011 UI may be implemented.
- Mock behaviour may be implemented.
- Destructive household deletion architecture may be scaffolded.
- Do **not** finalise production billing side-effects of ST-011 until this requirement is explicitly clarified/amended.

Do not silently guess whether Themis can or should cancel App Store auto-renewal.

## 8. Design artifacts still not final

Do not block foundation implementation on these, but do not invent them:
- final logo
- app icon
- final pricing
- final trial length
- safeguarding operational contact/procedure/emergency wording
- final legal copy
- OQ-19 exact staleness threshold
- final results of Apple real-device spikes

Temporary wordmark treatment may remain until brand assets are approved.

## 9. Implementation acceptance rule

A screen is not complete merely because it visually resembles the frame.

For each implemented screen verify:
- correct approved screen ID
- approved semantic tokens only
- approved typography role
- correct native/system/custom control
- normal state
- applicable loading/error/offline states
- Dynamic Type
- VoiceOver
- Reduce Motion
- iPad where applicable
- screenshot comparison with the approved design
- no unsupported product or Apple capability claim

## Final verdict

**UI/UX DESIGN: APPROVED**

**ENGINEERING HANDOFF: APPROVED**

**CLAUDE CODE UI IMPLEMENTATION: APPROVED TO START**

**PRODUCTION APPLE ENFORCEMENT: STILL GATED**

**PUBLIC LAUNCH: NOT APPROVED**
