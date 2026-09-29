# Claude Code Prompt — UI-03 Child + Teen Home

Repository:
https://github.com/Kydosdigital/themis-family

UI-01 Design System Foundation and UI-02 Parent Home are complete and merged.

You are now implementing **UI-03 Child + Teen Home only**.

This is a web session. Do not claim local Xcode, Simulator or screenshot verification unless you actually have that environment. GitHub macOS CI provides the real Xcode build/test gate.

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

Also use the final Claude Design package already available to this project:
- **Themis Final Prototype**
- **Themis Design System**
- **Themis Engineering Handoff**
- `ThemisScreen.dc.html`
- `themis-screens.js`
- `themis-handoff.js`

If the Design MCP cannot authenticate, use the project files already present. Do not invent replacement layouts.

The final Claude Design package is the visual/interaction source of truth.
The approved requirements are the behaviour source of truth.

## Git workflow

Start from the current `main`.

Create/use:
`feat/ui-03-child-teen-home`

Keep the work focused.

Open a draft PR if the environment allows it. Otherwise push and report the compare URL.

## Scope

Implement only:

- **C-001 Child Home · Sam**
- **C-001 · Teen Home · Maya**
- **C-012 Themis is active**
- **C-013 What can my parent or carer see?**
- **C-013 · Teen privacy/transparency**
- **C-014 Essential access / reassurance**

Do not implement UI-04 onboarding.
Do not implement the later task-detail/approval journey C-002 through C-011 in this slice.
Do not implement request flows.
Do not implement production Supabase.
Do not implement production Apple enforcement.

Where C-001 links to a later-slice screen, use the existing screen-ID placeholder/navigation pattern rather than inventing that screen now.

## Existing scaffold

The existing `ChildHomeView`, `ChildHomeData`, `DemoData.childHome` and `TransparencyView` are scaffolding.

They are not the visual authority.

Refactor or replace them as needed to match the approved C-001/C-012/C-013/C-014 designs.

Use the UI-01 shared design system and the navigation shell already merged.

Do not recreate tokens or components locally when a shared primitive exists.

## Audience rule

Child and Teen are **one product system with controlled variants**, not two separate brands.

### Child · Sam
Use the approved warmer Child variant:
- warm/off-white ground
- restrained aqua/mint/peach support surfaces
- larger radii
- more breathing room
- larger touch targets
- simpler language
- one dominant task/action
- reassuring, never babyish
- no gamification
- no reward-economy visual language

### Teen · Maya
Use the approved mature Teen variant:
- closer to Parent structure
- white/off-white base
- restrained cobalt
- fewer pastel surfaces
- slightly denser/more mature hierarchy
- autonomy-respecting wording
- never childish

Both must clearly feel like Themis Family.

## C-001 Child Home · canonical Sam state

Use the approved reference.

Required content/hierarchy:

- **Hi Sam**
- **Themis is active** with the approved Active status treatment
- link/action: **What can my parent or carer see?**
- section label **HOMEWORK**
- status **Due today**
- **Due at 6:00 PM**
- approved AgreementTimeline / deadline timeline around 4 PM / 6 PM / 8 PM
- consequence:
  **If it isn’t done by 6:00 PM, Roblox and Minecraft pause.**
- primary:
  **I’ve finished my homework**
- secondary:
  **Ask for more time**
- bottom tabs:
  Home / My Rules / Requests

The homework/deadline area should dominate the screen.

The child must be able to understand:
1. what is expected
2. when it is due
3. what happens if it is not completed/approved
4. how to say it is finished
5. how to request an exception

Do not use punishment language.

Do not say all access will unlock after approval. Other rules may still apply.

## C-001 · Teen Home · canonical Maya state

Use the approved reference.

Required content/hierarchy:

- **Tuesday**
- **Maya**
- **Themis is active** with Active status
- link/action:
  **What your parent or carer can see**
- section **NOW**
- **Social apps**
- **Pause 10:00 PM–7:00 AM**
- approved Tonight status/treatment
- approved evening timeline around 8 PM / 10 PM / 12 AM
- section **TODAY**
- **Focus Session**
- **30 min away from distracting apps**
- action **Start**
- action **Request more time**
- bottom tabs:
  Home / My Rules / Requests

Keep Maya's layout mature and restrained.

Do not simply recolour Sam's screen.

The interaction model and components should still be shared wherever appropriate.

## C-012 · Themis is active

Build the approved transparency overview.

The screen should explain that family rules are running on this iPhone and provide links/rows for:
- My rules
- essential / configured access
- What can my parent or carer see?

Use approved copy from the final design.

Important technical boundary:

Phone / Messages / Maps behaviour remains spike-dependent under OQ-30.

Do not turn the design's shorthand into a stronger technical promise.

Where the final handoff requires conservative wording, use the approved safe wording such as:
- configured/recommended to stay available **where supported**
- emergency calling is **never deliberately restricted**

Do not claim Phone, Messages or Maps are technically guaranteed to remain available until the Apple spike proves it.

## C-013 · Child transparency

Use the approved Child-facing facts.

### Your parent can see
- Your Themis rules
- If homework was done
- Your requests and answers
- Extra time they gave you
- If Themis is working
- Some Screen Time information Apple makes available where supported

### Themis does not show them
- Your messages or chats
- Everything you search or visit
- A minute-by-minute activity list

Preserve the approved plain, reassuring tone.

Do not broaden parental visibility beyond the approved requirements.

Do not imply Themis stores raw Apple Screen Time data.

## C-013 · Teen privacy/transparency

Use the approved mature Teen presentation.

### Visible to your parent/carer
- Rules and task outcomes
- Requests and decisions
- Temporary access
- Device protection status
- Screen Time reports Apple provides where available

### Not provided by Themis
- Message or chat content
- Full browsing or search history
- Minute-by-minute activity
- Apple raw Screen Time data

Use the exact final-design wording where available, while preserving the approved technical boundary if a prototype shorthand conflicts with the requirements/handoff.

## C-014 · Essential access

Implement the approved Child/Teen reassurance state.

It must communicate:
- essential/school access is deliberately considered
- Always Allowed / school access is parent-configured
- Phone / Messages / Maps are recommended/configured where supported, not technically guaranteed until OQ-30 is resolved
- emergency calling and OS emergency functionality are never deliberately restricted
- no deep content filtering is being claimed

Child copy should be simpler.
Teen copy should be mature but factually identical.

## AgreementTimeline

Reuse the UI-01 `AgreementTimeline` model/component.

Do not draw a separate one-off timeline.

At accessibility Dynamic Type sizes:
- switch to the approved stacked semantic list
- preserve time ranges and consequence meaning
- do not squeeze labels into the graphical timeline

Respect Reduce Motion.

## Status system

Reuse the shared `ThemisStatus` / `StatusBadge` system.

Every status must remain glyph + word.

Status chips stay single-line at all sizes. At accessibility sizes, restructure the surrounding layout rather than allowing the chip itself to wrap.

Do not reintroduce the accessibility mismatch fixed during UI-02.

## Navigation

Keep the approved Child/Teen tabs:

- Home
- My Rules
- Requests

Do not add tabs.

For this slice:
- Home becomes the approved C-001 implementation
- My Rules and Requests remain later-slice placeholders except where a C-012/C-013/C-014 route is explicitly part of this slice

Use native `NavigationStack` pushes/sheets according to the final design.

## Data / architecture

Frontend/mock-first remains in force.

Prefer a clean Child/Teen Home presentation model rather than forcing the final UI into the old scaffold model if it does not fit.

It is acceptable to add deterministic demo models/states for:
- Sam canonical Child Home
- Maya canonical Teen Home
- C-012
- C-013 Child
- C-013 Teen
- C-014 Child/Teen

Keep those display/demo models separate from persistence.

Do not alter product business rules to fit old mock structures.

## Existing later-state scenarios

The repository already contains demo scenarios for:
- homework overdue
- waiting approval
- approval grace
- multiple restrictions
- Free Pass
- request states
- protection states

Do not delete them.

However, do not fully redesign C-004 through C-011 in UI-03. Their production visual implementation belongs to later slices.

If needed, keep them compatible with the repository or map them to a safe placeholder/presentation state until their slice.

## Accessibility

Verify in implementation/previews:

- Dynamic Type
- VoiceOver reading/grouping order
- status glyph + word
- minimum touch targets
- long child/teen names
- long copy
- no clipped status chips
- timeline becomes stacked semantic list at accessibility sizes
- primary/secondary actions remain reachable
- Child buttons use the approved larger Child sizing
- Teen sizing stays mature
- Reduce Motion behaviour remains correct

Do not use fixed-height containers that truncate scaled text.

## Previews / review harness

Add deterministic SwiftUI previews or equivalent review states for at least:

- C-001 Sam · default
- C-001 Sam · accessibility size around the approved ~170% review target
- C-001 Maya Teen · default
- C-001 Maya Teen · accessibility size around the approved review target
- C-012 Child
- C-013 Child
- C-013 Teen
- C-014 Child/Teen representative state
- Child Home inside the Child tab shell
- Teen Home inside the Teen tab shell

Do not claim screenshot comparison from the web session.

## Tests

Add/update tests for display/state logic.

At minimum verify:
- Sam canonical state uses Child audience and the approved homework/deadline facts
- Maya canonical state uses Teen audience and the approved social-app schedule/focus content
- Child and Teen tabs remain Home / My Rules / Requests
- C-013 child and teen transparency facts remain within the approved privacy boundary
- Themis never exposes message/chat content, full browsing history or minute-by-minute activity in its visibility model
- Apple raw Screen Time data is not modelled as Themis-stored data
- essential-access wording does not claim guaranteed Phone/Messages/Maps availability
- emergency calling is described as never deliberately restricted
- timeline semantic data survives the accessibility fallback
- existing UI-01 and UI-02 tests continue to pass

## Visual review

UI-02 added a macOS Simulator screenshot review workflow.

Do not weaken or remove it.

If useful, extend the visual-review harness cleanly to capture the new Child and Teen canonical screens, but do not create brittle production-only launch behaviour just for CI.

The final review must compare the built screens with the approved Claude Design frames before UI-03 is marked complete.

## Verification

In this web session:
- run repository checks available here
- use safe Swift syntax parsing if available
- do not call a parser an Xcode compile
- push the branch

GitHub macOS CI is the source for:
- real Xcode compilation
- unit tests

Simulator artifacts / previews are the source for:
- built visual comparison where available

## Documentation

Update:
- `docs/implementation/CURRENT_STATE.md`
- `docs/implementation/BUILD_LOG.md`
- `docs/implementation/IMPLEMENTATION_DECISIONS.md` only when a real implementation decision is made

Do not modify frozen requirement documents.

When stopping:
- do not leave CURRENT_STATE as IN_PROGRESS
- if source is complete but macOS/visual verification remains, mark UI-03 BLOCKED with the concrete reason

## Stop point

STOP after UI-03 Child + Teen Home.

Do not begin:
- UI-04 onboarding
- UI-05 rules
- C-002 through C-011 task/approval implementation
- request implementation
- Free Pass implementation
- backend wiring
- production Apple enforcement

Report:

1. files changed
2. C-001 Child implementation
3. C-001 Teen implementation
4. C-012/C-013/C-014 implementation
5. shared-component corrections, if any
6. tests/checks run in the web session
7. branch
8. commit SHA(s)
9. draft PR or compare URL
10. what macOS CI still needs to verify
11. what visual comparison remains
12. any deviation from the approved final design

The design is approved. Do not redesign it while coding.
