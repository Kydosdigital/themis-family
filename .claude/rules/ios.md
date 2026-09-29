# iOS rule

Themis is iOS/iPadOS-first.

Apple-dependent production enforcement is gated by `docs/27_APPLE_INTEGRATION_REQUIREMENTS.md` and `docs/37_BUILD_SEQUENCE.md`.

Until the relevant real-device spike passes, do not hard-code assumptions about:
- remote approval to unlock while the child app is backgrounded/terminated
- Phone, Messages or Maps shielding behaviour
- DeviceActivityMonitor transition timing
- exceeded shield-limit behaviour
- shield persistence through termination/reboot/uninstall
- wall-clock or monotonic-clock tamper resistance
- extension memory ceilings
- cross-device DeviceActivityReport rendering

Spike code may test these behaviours. Spike code is not production behaviour.

Keep Family Controls authorisation separate from Themis backend/device authentication.

Never claim a child needs a Themis Apple login merely because Family Controls uses a child Apple Account.

When an Apple behaviour is undocumented, classify it as a spike dependency rather than guessing.
