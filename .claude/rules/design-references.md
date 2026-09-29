# External UI reference rule

Themis Family is a native SwiftUI iOS/iPadOS product.

External UI libraries such as shadcn/ui and 21st.dev are reference libraries, not native app dependencies.

## Allowed use

Use them to study:
- composition
- visual hierarchy
- card/surface treatment
- typography scale
- empty states
- status presentation
- micro-interaction ideas
- motion concepts
- form rhythm
- premium consumer-app polish

## Not allowed

Do not:
- copy React/Tailwind source into the iOS app
- introduce a web runtime or embedded web UI for ordinary product screens
- copy desktop navigation/sidebar patterns
- reproduce hover-dependent interactions
- use tiny web-sized controls
- turn Parent Home into an analytics dashboard because a reference looks attractive
- treat a third-party component's tokens as the Themis design system
- add a component merely because it exists in a registry

## Translation rule

When borrowing an idea:
1. identify the design principle
2. map it to the approved Themis design tokens
3. implement it using native SwiftUI
4. preserve iOS accessibility, Dynamic Type and touch-target requirements
5. keep Themis navigation and product behaviour unchanged

Apple-native interaction conventions take precedence over web references.

## shadcn/ui

Use shadcn/ui as a strong baseline for restrained hierarchy and component composition.

Do not run shadcn CLI inside the iOS app workspace to install React UI.

## 21st.dev

The project may use the 21st MCP as a discovery/search tool for visual inspiration.

Treat 21st components as third-party reference material. Quality varies by author, so review before adapting.

Never paste the 21st API key into source files, prompts, issues, commits or logs. The key must come from the local `API_KEY_21ST` environment variable.
