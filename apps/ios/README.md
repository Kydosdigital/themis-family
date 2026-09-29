# Themis Family iOS app

This directory now contains the frontend-first SwiftUI foundation for Themis Family.

## Current scope

Implemented as mock-driven UI foundation:

- XcodeGen project specification
- semantic design tokens
- reusable cards, buttons, section headers and protection-status badge
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
