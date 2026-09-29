# Claude Code Prompt — UI-02 Parent Home

Repository:
https://github.com/Kydosdigital/themis-family

The approved Themis Family design process is complete. UI-01 Design System Foundation has been implemented and merged.

You are now implementing **UI-02 Parent Home only**.

This is a web session. Do not claim local Xcode, Simulator, or screenshot verification unless you actually have that environment. The repository now has macOS GitHub Actions for real Xcode build/test verification.

## Read before touching code

Read:
- `CLAUDE.md`
- `docs/implementation/CURRENT_STATE.md`
- `docs/implementation/CLAUDE_CODE_UI_IMPLEMENTATION_PROMPT.md`
- `docs/implementation/ENGINEERING_HANDOFF_FINAL_REVIEW.md`
- `docs/implementation/DESIGN_PASS5_APPROVAL.md`
- `docs/implementation/MOBILE_UX_BLUEPRINT.md`
- `docs/implementation/DESIGN_PASS2_DECISION.md`
- `docs/implementation/DESIGN_PASS3_APPROVAL.md`
- `docs/implementation/DESIGN_PASS4_APPROVAL.md`
- `docs/implementation/AIRTABLE_TRACKER.md`
- `.claude/rules/ios.md`
- `.claude/rules/swiftui.md`
- `.claude/rules/design-system.md`
- `.claude/rules/testing.md`
- `.claude/rules/security.md`

Also use the final Claude Design package available to this session:
- **Themis Final Prototype**
- **Themis Design System**
- **Themis Engineering Handoff**
- `ThemisScreen.dc.html`
- `themis-screens.js`
- `themis-handoff.js`

If the Design MCP cannot authenticate, use the project files already provided. Do not invent a replacement layout.

The approved design package is the visual/interaction source of truth.
The approved requirements are the behaviour source of truth.

## Git workflow

Start from the current `main`.

Create/use a focused branch:
`feat/ui-02-parent-home`

Do not continue into UI-03.

Open a draft PR if this environment allows it. If it cannot, push the branch and report the compare/PR URL.

## Scope

Implement **P-023 Parent Home and its approved Parent Home states only**.

Use the UI-01 design-system foundation already in the app. Do not rebuild the design system from scratch.

The existing `ParentHomeView` is scaffold/prototype code, not visual authority. Refactor or replace it as necessary to match the approved P-023 design.

## Approved Parent Home priority

The mobile scan order is fixed:

1. **Needs You**
2. **children / protection health**
3. **current agreements**
4. **quick actions**

Do not turn this into an analytics dashboard.

Do not prioritise metrics such as active-rule counts above real family actions and protection state.

## Canonical P-023 review state

Build a canonical Parent Home state using the approved example:

- Parent: **Sarah**
- Child: **Sam · Child**
- Teen: **Maya · Teen**
- Sam has homework waiting for review
- approval grace ends in **18 min**
- Maya has a request pending
- Sam is **Protected**
- Maya is **Sync Pending**
- quick actions include **Add rule** and **Free Pass**

Use the exact final-design wording/layout where the design artifacts specify it.

Do not silently invent additional product copy when the approved frame already defines it.

## Required Parent Home states

Implement the approved P-023 family needed for this slice:

### 1. Canonical / needs-attention state
Show the approved hierarchy with Sam's homework review and Maya's pending request.

### 2. Nothing-pending state
The parent should be able to see that nothing requires a decision without the screen becoming empty or losing protection/agreements context.

### 3. Setup-incomplete state
If one child has incomplete setup/pairing:
- show the setup action clearly
- do not imply that another protected child is unprotected
- do not say the entire household is protected if one child is incomplete
- keep child-level truth separate

### 4. Protection-problem state
Represent an approved protection problem honestly using the shared protection statuses:
- Sync Pending
- Device Offline
- Needs Attention
- Protection Unavailable

Where the design requires it, include **Last verified**.

Never leave a stale green Protected state when current protection cannot be confirmed.

## Components expected in this slice

Use or implement the approved Parent Home components, including:

- `NeedsYouCard`
- `GraceBar`
- `ChildStatusRow`
- `QuickActionDock`

Use the existing UI-01 shared components underneath them where appropriate:
- `ThemisCard`
- `StatusBadge`
- `InlineBanner`
- `SectionHeader`
- `ThemisButton`
- shared typography/tokens/navigation

Add a small Parent Home-specific component only when the final handoff clearly needs one.

Do not create one-off raw colours, fonts, radii or spacing values in feature code when an approved semantic token exists.

## Visual direction

Follow the approved hybrid:

### A · Calm Editorial
Use for:
- typography hierarchy
- generous spacing
- breathing room
- refined visual rhythm
- subtle agreement/timeline motif where the final P-023 design uses it

### C · Confident Minimal
Use for:
- Parent Home architecture
- clear priority hierarchy
- compact protection/status rows
- grouped sections
- quick actions
- decisive mobile structure

### B · Warm Family System
Do **not** broadly apply this to Parent Home.
B warmth is primarily for Child-facing surfaces.

Parent Home should be:
- mostly white/off-white
- restrained tinted sections
- occasional cobalt emphasis
- minimal borders
- soft shadows only where hierarchy requires them
- premium, calm and mobile-native

Do not use:
- full-screen cobalt as the default
- purple
- a dense card wall
- generic SaaS dashboard styling
- fintech-heavy metrics
- cyber-security visuals
- surveillance language
- desktop-style widgets

## Quick actions

The approved actions are:
- Add rule
- Free Pass

At standard Dynamic Type, match the approved placement.

At accessibility text sizes:
- move quick actions inline
- never let a floating dock cover content
- preserve minimum touch targets

Do not add extra global actions in this slice.

## Navigation

Keep the already-approved Parent tab shell:

- Home
- Rules
- Activity
- Settings

Do not change the tab IA.

The Home tab should now render the real approved P-023 implementation.

Other tabs remain later-slice placeholders.

Keep the Action Centre / notification affordance exactly as the approved Parent Home design specifies.

## Data and architecture

Frontend-first remains in force.

Use the repository/view-model/mock pattern.

Do not connect production Supabase.

Do not add production FamilyControls/ManagedSettings/DeviceActivity behaviour.

You may extend mock/display models as needed to represent the approved P-023 states.

The current demo model only represents some states independently. For the canonical Parent Home, it is acceptable to add a dedicated Parent Home demo state or a clean display model so these can coexist:
- Sam homework awaiting review / grace 18 min
- Maya pending request
- Sam Protected
- Maya Sync Pending

Do not distort core business rules merely to fit the old mock structure.

Keep mock state separate from production persistence.

## Behaviour boundaries

Parent Home may display:
- Themis task/request state
- child-level protection health
- approved current-agreement summaries
- quick actions

It must not:
- imply backend approval has already applied on the child device
- claim Apple Screen Time data that is not available
- fabricate a staleness threshold for OQ-19
- claim Apple enforcement capabilities that remain spike-gated

## Accessibility

Verify in code and previews:

- Dynamic Type
- VoiceOver grouping/order
- icon + text for status
- no colour-only meaning
- minimum touch targets
- long child names
- long status labels
- no clipped status chip at accessibility sizes
- quick actions become inline at accessibility sizes
- no fixed-height containers that truncate copy

Pay particular attention to long statuses such as:
- Protection unavailable
- Approved, timing unverified

If a shared UI-01 component needs a small accessibility correction revealed by P-023, fix the shared component rather than hacking around it locally. Record the correction.

## Previews / review harness

Add focused SwiftUI previews or an equivalent debug review surface for at least:

- P-023 canonical
- P-023 nothing pending
- P-023 setup incomplete
- P-023 protection problem
- P-023 canonical at one accessibility Dynamic Type size

Keep previews deterministic.

Do not claim screenshot comparison if the web session cannot render them.

## Testing

Add/update tests for Parent Home presentation/state logic where useful.

At minimum verify:
- canonical priority ordering
- canonical Sam/Maya states are represented correctly
- setup-incomplete does not erase another child's Protected state
- protection problem uses the correct shared status, not Protected
- nothing-pending remains a valid Parent Home
- quick actions remain Add rule / Free Pass
- existing UI-01 status/timeline/navigation tests continue to pass

Do not delete useful existing demo scenarios.

## Verification

In the web session:
- run repository verification available there
- syntax-check safely if available
- do not call a parser a SwiftUI compile
- push the branch

GitHub macOS CI is the source for:
- real Xcode compile
- unit tests

Simulator screenshot comparison remains a separate review step unless this session truly has a rendered Simulator.

## Documentation

Update:
- `docs/implementation/CURRENT_STATE.md`
- `docs/implementation/BUILD_LOG.md`
- `docs/implementation/IMPLEMENTATION_DECISIONS.md` only for a real implementation decision

Do not modify frozen requirement documents.

When the web session stops, do not leave `CURRENT_STATE.md` as IN_PROGRESS.

If source implementation is complete but external macOS/visual verification remains, mark the slice **BLOCKED** with the concrete verification reason. Do not mark it COMPLETE prematurely.

## Stop point

STOP after **UI-02 Parent Home**.

Do not begin:
- UI-03 Child + Teen Home
- onboarding
- rules
- requests
- Free Pass
- backend integration
- production Apple enforcement

Report:

1. files changed
2. P-023 states implemented
3. any shared UI-01 corrections
4. tests/checks run in the web session
5. branch name
6. commit SHA(s)
7. draft PR or compare URL
8. what GitHub macOS CI still needs to verify
9. what visual comparison still needs review
10. any discrepancy from the approved final design

The design is approved. Do not redesign it while coding.
