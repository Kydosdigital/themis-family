# Themis Family Airtable Product Tracker

Airtable is the human-readable progress tracker and cross-chat handoff layer for Themis Family.

## Base

**Name:** Themis Family Product Tracker  
**Base ID:** `apphnRnqOSGUJahLq`  
**Interface:** Themis Control Centre  
**Interface ID:** `pbdyz6Lpxs4WELFIt`

Open the Overview page:
https://airtable.com/apphnRnqOSGUJahLq/pag6CtJjDkfuHmCLO

## Tables / pages

### Roadmap
Tracks the major workstreams:
- Product requirements
- Mobile UX/UI design
- Engineering handoff
- iOS/iPad implementation
- Apple enforcement
- Supabase backend
- Public website
- Launch readiness
- Android future work

Each record includes status, progress, current state, next action, blocker and GitHub link.

### iOS Build Slices
Tracks the approved implementation order:
- UI-01 Design System Foundation
- UI-02 Parent Home
- UI-03 Child + Teen Home
- UI-04 Onboarding
- UI-05 Rules & School Access
- UI-06 Tasks + Deadline Lock
- UI-07 Requests
- UI-08 Free Pass
- UI-09 Protection
- UI-10 Activity
- UI-11 Settings
- UI-12 Subscription
- UI-13 Edge States
- UI-14 iPad Adaptations
- UI-15 Accessibility + Motion Polish

### Technical Gates
Tracks production blockers and spike-dependent behaviour, including:
- Family Controls production entitlement
- remote decision → applied-on-device timing
- Phone / Messages / Maps shield behaviour
- terminated-app scheduling
- Apple Screen Time reporting
- trusted-time reliability
- OQ-19 staleness threshold
- dedicated Themis Supabase project
- ST-011 billing clarification
- safeguarding
- legal/privacy launch review

### Decisions & Risks
Tracks resolved decisions, open product questions, blockers and risks that must survive across chats/agents.

### Chat Handoff
Contains the canonical cross-chat state snapshot.

When starting a new ChatGPT conversation, use this instruction:

> Open the Airtable base **Themis Family Product Tracker**. Read the latest record in **Chat Handoff**, then review **Roadmap**, **iOS Build Slices**, **Technical Gates**, and **Decisions & Risks**. Also check `docs/implementation/CURRENT_STATE.md` and the latest open GitHub PR/CI status. Continue from the current slice without redesigning approved UX or bypassing Apple/backend gates.

## Source-of-truth hierarchy

Airtable is the progress and handoff tracker, not the product specification.

Use:
1. approved requirement documents for product behaviour
2. final Claude Design prototype / Design System / Engineering Handoff for visual and interaction design
3. GitHub code + `CURRENT_STATE.md` for actual implementation state
4. Airtable for progress visibility, blockers and cross-chat continuity

If Airtable and GitHub disagree about current implementation state, verify GitHub and update Airtable.
