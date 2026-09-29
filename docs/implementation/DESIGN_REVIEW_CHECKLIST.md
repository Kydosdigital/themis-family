# Themis Family Design Review Checklist

Use this before approving Claude Design for implementation.

## Gate 1: Mobile architecture

- [ ] Feels native to iPhone, not a responsive website
- [ ] Parent navigation is understandable without explanation
- [ ] Child/Teen navigation is simpler than Parent navigation
- [ ] Primary actions are reachable one-handed
- [ ] Complex forms are progressive rather than long desktop forms
- [ ] Sheets vs full-screen navigation are used consistently
- [ ] Apple-owned UI is represented as system handoff, not fabricated

## Gate 2: Product correctness

- [ ] Account creation is clearly different from Protection Activated
- [ ] Deadline Lock flow matches approved grace behaviour
- [ ] No manual task unlocks merely because child taps Done
- [ ] Multiple active restrictions are explained correctly
- [ ] First guardian decision wins
- [ ] Requests have one clarification prompt + one reply only
- [ ] Automatic reminder behaviour matches DEC-41
- [ ] Free Pass is explicitly scoped
- [ ] Approved vs Applied-on-device distinction exists
- [ ] Revocation sent vs Access revoked distinction exists
- [ ] Subscription expiry clears Themis restrictions
- [ ] Resubscription requires explicit reactivation after Protection Expired
- [ ] Support never acts as a parent
- [ ] Shared-device support is not implied

## Gate 3: Child/Teen dignity

- [ ] Child copy is simple without being babyish
- [ ] Teen UI is clearly more mature
- [ ] No shaming, blame or punitive language
- [ ] Restrictions explain why and what can be done next
- [ ] Themis Active transparency is easy to find
- [ ] What parents can/cannot see is accurately explained
- [ ] Emergency-access reassurance is clear
- [ ] No circumvention-enabling implementation details are exposed

## Gate 4: Visual system

- [ ] No purple
- [ ] Cobalt/mint/aqua/peach palette used consistently
- [ ] White space is generous
- [ ] No generic cyber-security aesthetic
- [ ] No law-firm/Greek visual language
- [ ] No final logo invented
- [ ] Component styles are consistent across flows
- [ ] Parent, Child and Teen all feel like one brand

## Gate 5: Mobile states

- [ ] Protected
- [ ] Sync Pending
- [ ] Device Offline
- [ ] Needs Attention
- [ ] Protection Unavailable
- [ ] no children
- [ ] no rules
- [ ] no pending actions
- [ ] permission denied
- [ ] pairing expired/failed
- [ ] backend unavailable
- [ ] request expired
- [ ] timing could not be verified
- [ ] subscription grace
- [ ] protection expired
- [ ] reactivation pending

## Gate 6: Accessibility

- [ ] Dynamic Type stress test included
- [ ] VoiceOver hierarchy is plausible
- [ ] Touch targets are adequate
- [ ] Status is not colour-only
- [ ] Contrast is readable
- [ ] Reduced-motion alternatives are possible
- [ ] Keyboard never obscures critical actions

## Gate 7: Prototype completeness

The prototype can click through:

- [ ] full Owner onboarding
- [ ] first Homework Deadline rule
- [ ] Parent Home
- [ ] Child Home
- [ ] Teen Home
- [ ] on-time task submission
- [ ] approval grace
- [ ] parent approval
- [ ] Approved → Applied on device
- [ ] overdue restriction
- [ ] multiple restrictions
- [ ] extra-time request
- [ ] partial approval
- [ ] clarification exchange
- [ ] Free Pass grant/revoke
- [ ] protection failure/recovery
- [ ] subscription expiry/reactivation
- [ ] transparency screen

## Approval

Do not resume production screen implementation until the founder is satisfied with:
1. architecture
2. visual direction
3. core prototype
4. state coverage
5. accessibility treatment

Implementation tickets should reference Claude Design frame/screen IDs.
