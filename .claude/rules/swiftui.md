# SwiftUI implementation rule

Use SwiftUI for the iOS/iPadOS product experience unless a specific Apple framework forces UIKit interop.

## Structure

- Keep business/enforcement logic out of Views.
- Views render state and send intents/actions.
- Prefer small reusable components over giant screens.
- Make ownership of observable state explicit.
- Avoid multiple competing sources of truth for the same screen state.
- Keep platform adapters behind narrow interfaces so spike-driven Apple behaviour can change without rewriting product UI.

## Concurrency

- Use Swift structured concurrency.
- Make UI mutations MainActor-safe.
- Avoid detached tasks unless there is a clear reason.
- Handle cancellation and view lifecycle intentionally.
- Do not turn background execution assumptions into product guarantees.

## Accessibility

Every screen must support:
- Dynamic Type
- VoiceOver labels/hints where needed
- sufficient touch targets
- non-colour-only status communication
- reduced motion where applicable

Protected / Sync Pending / Device Offline / Needs Attention / Protection Unavailable must always include textual or semantic state, not only colour.

## Child and teen UX

Use the appropriate `experience_segment`.

Do not make Teen UI childish.

Use calm, explanatory language:
- "Games are paused"
- "Waiting for approval"
- "Focus session interrupted. Start again when you're ready."

Avoid blame, shame and punitive visual treatment.
