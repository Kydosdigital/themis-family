# Themis Family iOS app

This directory now contains the frontend-first SwiftUI foundation for Themis Family.

## Current scope

Implemented as mock-driven UI foundation:

- XcodeGen project specification
- UI-01 design-system foundation from the approved Engineering Handoff:
  - semantic tokens (`Core/DesignSystem`): colours, spacing, radii, borders, shadows, touch sizes, motion, and Parent / Child / Teen audience variants
  - typography roles applied with `.themisFont(_:)`, scaled with Dynamic Type
  - shared status system (`Core/Status`): every approved status with glyph and label
  - reusable primitives (`Core/Components`), including AgreementTimeline with its stacked accessibility fallback
  - Parent and Child/Teen navigation shells (`Core/Navigation`), with iPad split view for Parent
- parent/child domain models
- repository protocols that keep the UI independent of Supabase
- deterministic mock repositories
- Parent Home
- Child/Teen Home
- child transparency sheet
- developer scenario switcher
- unit tests for key mock states

Production Family Controls / ManagedSettings / DeviceActivity enforcement is NOT implemented here. Those behaviours remain gated by the entitlement and real-device spike programme.

Supabase is also not wired into the frontend yet. Future Supabase repositories will conform to the same repository protocols used by the mock layer.

## Using the design system

- Colours: `ThemisColor.*` semantic names only. No raw hex in feature views.
- Text: `.themisFont(.body)`, `.themisFont(.pageTitle)` and so on. The audience comes from the environment.
- Audience and ground: set `.themisAudience(.child)` on a subtree and `.themisGround(.warm)` on a screen. Components pick the right surface, radius and heights.
- Status: `StatusBadge(.syncPending)` or `StatusBadge(ThemisStatus(.approved, label: "Completed"))`. Never show status by colour alone.
- Manrope: add the licensed font files to the target and list them under `UIAppFonts`. `.themisFont` switches to Manrope automatically.

## Generate the Xcode project

The project is defined with XcodeGen so the source-of-truth project structure remains reviewable text instead of a hand-edited pbxproj.

On a Mac with Xcode and XcodeGen installed:

```bash
cd apps/ios
xcodegen generate
open ThemisFamily.xcodeproj
```

The generated `.xcodeproj` is intentionally ignored by Git.

## Build check

From the repository root:

```bash
bash scripts/verify_ios.sh
```

The script performs an Xcode build when run on macOS with XcodeGen and Xcode available. GitHub's Linux workflow cannot compile SwiftUI, so a local macOS build remains required before this frontend foundation is considered compile-verified.

## Debug scenarios

In a Debug build, use the top-right slider icon to switch between Parent, Child and Teen perspectives and states such as:

- normal
- homework overdue
- waiting for approval
- approval grace
- multiple restrictions
- device offline
- sync pending
- protection unavailable
- Free Pass active
- subscription grace / expired
- no children / no rules
- request pending / declined

These are UI/demo states only. They do not claim production enforcement has occurred.
