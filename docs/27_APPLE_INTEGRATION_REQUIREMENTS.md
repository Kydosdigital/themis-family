# 27. Apple Integration Requirements

**Status:** Phase 5 draft
**Depends on:** `05_HIGH_LEVEL_REQUIREMENTS.md`, `10_RULE_ENGINE_SPECIFICATION.md`, `13_SCHOOL_AND_ESSENTIAL_ACCESS.md`, `35_DECISION_LOG.md` DEC-31 (no unverified platform-behaviour claims)

This document is the single source of truth for what Apple's Screen Time API frameworks (Family Controls, Managed Settings, Device Activity) actually provide, as distinct from what this product assumes or hopes they provide. Per the founder's explicit Phase 5 instruction, every capability below is tagged with exactly one status:

- **VERIFIED FROM APPLE DOCUMENTATION** — confirmed by reading Apple's own developer documentation, cited with the exact page.
- **NEEDS REAL-DEVICE TECHNICAL SPIKE** — plausible or reported (sometimes by credible third-party developers) but not confirmed in Apple's own documentation; must be verified on a real device before any requirement or marketing claim depends on it.
- **UNSUPPORTED / NOT AVAILABLE** — confirmed by Apple's documentation to not be possible.
- **UNKNOWN** — no documentation or credible third-party report found either way.

No requirement anywhere in this specification may assume a capability beyond what is marked VERIFIED, without an explicit RECOMMENDATION flag noting it depends on a NEEDS REAL-DEVICE TECHNICAL SPIKE item.

---

## 27.1 Entitlement acquisition (RISK-01)

**Status: VERIFIED FROM APPLE DOCUMENTATION.**
Source: [Requesting the Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement) (Apple Developer Documentation).

- The Apple Developer Account Holder must explicitly request the `com.apple.developer.family-controls` entitlement via [Family Controls distribution](https://developer.apple.com/contact/request/family-controls-distribution) or the Capability Requests tab in Certificates, Identifiers & Profiles.
- Every Screen Time API app extension the product ships (Device Activity Monitor, Device Activity Report, Shield Action, Shield Configuration) requires the **same request submitted separately** for that extension.
- **Apple reviews the request and approves or declines it** — this is a discretionary review gate, not an automatic grant. There is no documented guaranteed turnaround time or approval criteria beyond "Apple reviews your app."
- This directly substantiates RISK-01 (`33_PRODUCT_RISK_REGISTER.md`): the entire product depends on a discretionary Apple approval that must be requested before any further engineering investment, exactly as RISK-01's mitigation already states.

**Action required before Phase 6/7 build sequencing:** submit the entitlement request (main app + every extension) as the first technical step, not after UI is built.

---

## 27.2 Authorization model (FR-006, HLR-003)

**Status: VERIFIED FROM APPLE DOCUMENTATION.**
Source: [AuthorizationCenter](https://developer.apple.com/documentation/familycontrols/authorizationcenter), [FamilyControlsMember](https://developer.apple.com/documentation/familycontrols/familycontrolsmember) (Apple Developer Documentation).

- Authorization is requested via `AuthorizationCenter.shared.requestAuthorization(for:)`, passing a `FamilyControlsMember` value: **`.child`** (a parent/guardian enters authorization credentials on behalf of a child account) or **`.individual`** (the account holder authorizes themselves via Face ID/Touch ID). **Themis Family's V1 model uses `.child` exclusively** — this matches DEC-26's confirmed "each child has their own Child Apple Account within Family Sharing" model, not the `.individual` self-authorization path.
- On first request for an unauthorized app, the system shows an alert; if the parent/guardian continues, an authentication sheet follows. **Subsequent calls to `requestAuthorization(for:)` after approval do not re-show this UI** — they return the current status directly.
- **Authorization status can change due to external events the app does not control:** Apple's own documentation names two examples explicitly — *"a child graduating to an adult account, or a parent or guardian changing the status in Settings."* The app observes this via the published `authorizationStatus` property, not by polling.
- This is the direct technical substantiation for HLR-013/DEC-27's requirement that protection status must reflect last-confirmed state, not assumed continuity: Apple's own documentation confirms authorization can be revoked by events entirely outside the app's control, at any time.
- `revokeAuthorization(completionHandler:)` exists for the app to voluntarily relinquish authorization (e.g. on household/child deletion) — this is the correct call for FR-007 (device removal) and household deletion (BR-106), not an undocumented workaround.
- **Not verified:** the exact end-user-visible path/wording for "a parent or guardian changing the status in Settings" (i.e., what the child or parent actually sees on-device when this happens) — flagged as **NEEDS REAL-DEVICE TECHNICAL SPIKE**, relevant to `16_DEVICE_ENFORCEMENT.md`'s stale/revoked-device UX.

---

## 27.3 Shielding mechanism (FR-010, FR-050, BR-202, BR-222)

**Status: VERIFIED FROM APPLE DOCUMENTATION (mechanism); NEEDS REAL-DEVICE TECHNICAL SPIKE (specific limits and edge-case behaviour).**
Sources: [Managed Settings](https://developer.apple.com/documentation/managedsettings), [ManagedSettingsStore](https://developer.apple.com/documentation/managedsettings/managedsettingsstore) (Apple Developer Documentation); community sources noted explicitly where used.

- **VERIFIED:** `ManagedSettingsStore` is *"a data store that applies settings to the current user or device."* Shielding targets are expressed as `ApplicationToken`, `ActivityCategoryToken`, and `WebDomainToken` — opaque tokens obtained from a `FamilyActivityPicker` selection, not raw bundle identifiers or domain strings the app can read, log, or export.
- **VERIFIED — critical data-model constraint:** Apple's `Token` documentation states these tokens are *"a representation of an activity, such as an app or website, that doesn't reveal its identity."* A third-party developer account (see below) elaborates that they contain no bundle IDs or app names and can only be rendered via a SwiftUI `Label` at display time. **This means Themis Family's backend cannot store or transmit human-readable app/site names derived from the token itself — only the parent's own chosen label (entered at picker time) is available for that purpose.** This is a direct, binding input to `19_DATA_MODEL.md`'s ControlledTarget entity design, not an optional privacy nicety.
- **NEEDS REAL-DEVICE TECHNICAL SPIKE — the 50-token shield limit:** A developer forum thread ([ManagedSettingsStore 50 Token Limit](https://developer.apple.com/forums/thread/733361)) reports that setting more than 50 application or website tokens on a single `ManagedSettingsStore.shield` property causes the shield to silently fail (the property returns `nil` and nothing is shielded), reproduced across iOS 16 and 17, with **no official Apple documentation or acknowledgement found**. **This corrects a claim already made in `10_RULE_ENGINE_SPECIFICATION.md` FR-010**, which described this as "Apple's documented ManagedSettings limits" — that phrasing overstates the source; it is an undocumented, community-discovered behaviour, not a documented Apple limit. `10_RULE_ENGINE_SPECIFICATION.md` must be corrected to say "an undocumented limit reported by developers (~50 tokens per property), to be confirmed on a real device before Phase 6" rather than presenting it as Apple-documented fact — this is exactly the DEC-31 discipline the founder's own process requires, and the correction is logged in this Phase 5 round's cross-check (§27.6).
- **NEEDS REAL-DEVICE TECHNICAL SPIKE — shield persistence across termination/reboot:** a third-party production account ([FamilyControls in Production: The Edges](https://habitdoom.com/blog/shipping-familycontrols-ios)) states the shield "persists through force-quit, restart, and uninstall by design — it's enforced at the OS level, not app-level code." **No official Apple documentation confirming this exact persistence guarantee was found.** If confirmed true on a real device, this would materially simplify `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`'s design (the OS itself, not Themis's own code, is what keeps a shield in force across a device restart) — but it must not be assumed true for architecture decisions until verified on a real device, per the founder's explicit rule against turning assumptions into architecture.
- **UNKNOWN — Phone/emergency calling shielding behaviour (OQ-30, BR-222):** no Apple documentation was found stating whether the Phone app, emergency calling, or other OS-level emergency functionality can be included in a `ManagedSettingsStore` shield at all, or whether Apple's own OS prevents this regardless of what the app configures. This is the single most safety-critical unresolved technical item in this document and must be the first item validated in any real-device spike, given BR-222's hard safety principle depends on knowing the actual answer, not an assumption in either direction.

---

## 27.4 Monitoring and scheduling (FR-013, FR-014, FR-017, HLR-014)

**Status: VERIFIED FROM APPLE DOCUMENTATION (framework existence and purpose); NEEDS REAL-DEVICE TECHNICAL SPIKE (exact scheduling reliability and callback timing).**
Source: [Device Activity](https://developer.apple.com/documentation/deviceactivity) (Apple Developer Documentation).

- **VERIFIED:** `DeviceActivityCenter` starts monitoring a `DeviceActivitySchedule` (a *"calendar-based schedule for when to monitor a device's activity"*) from the main app; a `DeviceActivityMonitor` app extension receives callbacks (interval start/end, threshold reached) and is where shield changes are actually applied, per Apple's own architecture — this is the mechanism Scheduled Rule (FR-013) and Deadline Lock (FR-014) enforcement must be built on, not a generic background-timer approach.
- **NEEDS REAL-DEVICE TECHNICAL SPIKE — extension reliability under memory pressure:** the same third-party production account cited in §27.3 states DeviceActivityMonitor and Shield extensions run under severe memory restrictions and recommends they "do the absolute minimum... read the shared state out of App Group UserDefaults, decide block-or-unblock, write the shield, and get out." This is architecturally significant for `29_API_AND_BACKEND_REQUIREMENTS.md`/`19_DATA_MODEL.md`: rule/grant data available to the extension must be pre-computed and cached in a lightweight, extension-accessible local store (e.g. an App Group container) rather than requiring the extension itself to run complex logic or reach the network. **This is a recommended architecture pattern informed by a credible community source, not a confirmed Apple guarantee, and must be validated on a real device before Phase 6/7 build sequencing commits to it.**
- **UNKNOWN — exact timing precision for grace-period/expiry callbacks:** whether a `DeviceActivityMonitor` callback fires precisely enough to support the 30-minute Provisional Approval Grace Period (DEC-40) and time-bound grant expiry (BR-210) to the minute, or whether the app needs an additional foreground-check fallback (re-evaluating and correcting the shield state whenever the app becomes active, in case a scheduled callback was delayed or missed), is not confirmed by documentation and must be validated on a real device. `17_OFFLINE_AND_SYNC_BEHAVIOUR.md` assumes a foreground-check fallback is required as a defensive measure regardless of the spike's outcome, since relying solely on a background callback with unconfirmed timing precision would be exactly the kind of unverified assumption the founder's rule prohibits turning into architecture.

---

## 27.5 Reporting and cross-device visibility (OQ-09, OQ-10, HLR-015)

**Status: VERIFIED FROM APPLE DOCUMENTATION — this materially resolves OQ-09's long-standing uncertainty.**
Source: [DeviceActivityReport](https://developer.apple.com/documentation/deviceactivity/deviceactivityreport) (Apple Developer Documentation).

- **VERIFIED, and a significant finding:** `DeviceActivityReport`'s own documentation states *"the system will only provide your extension with device activity data if the user has authorized your app for family controls on their device **or on the device(s) of children in their iCloud family**"* (emphasis added), and its `DeviceActivityFilter` explicitly supports a `users:` parameter that can be scoped to `.children` and a `devices:` parameter scoped to specific device types. **This confirms that a parent's own device, once authorized under the family's Family Controls setup, can render a native `DeviceActivityReport` view showing a child's device activity — cross-device visibility is natively supported by Apple's own architecture**, contrary to this specification's earlier working assumption (DEC-07/DEC-19/OQ-09) that this was unconfirmed and possibly unsupported.
- **VERIFIED — the equally important limitation:** the same documentation states the report extension *"runs in a sandbox. This sandbox prevents your extension from making network requests or moving sensitive content outside the extension's address space."* **This means the underlying usage data itself can never reach Themis Family's own backend, be logged, or be transmitted anywhere — it can only be rendered, natively, inside Apple's own sandboxed report view, on-device.** Themis Family can display this native report to the parent (e.g. embedded as a `DeviceActivityReport` view in its own UI) but cannot extract, store, aggregate across households, or build custom analytics from the underlying figures. This is a hard architectural ceiling, not a policy choice this product is making — DEC-06/DEC-19's "no browsing-history diary" privacy positioning is therefore *also* a technical necessity, not purely a values-driven choice, which strengthens rather than weakens that positioning.
- **Practical consequence for `06_FUNCTIONAL_REQUIREMENTS.md`/Phase 6's reporting scope:** V1 reporting should be built as two clearly separate categories: (a) Themis-native data the backend *does* own and can report on freely — rule outcomes, task/request outcomes, overrides, protection status history (all confirmed technically available since they originate from Themis's own actions, not from Apple's activity-monitoring sandbox); and (b) raw app/category/website usage time, which can only ever be shown via an embedded native `DeviceActivityReport` view, never as Themis-owned data. This distinction should be written explicitly into Phase 6's `22_REPORTING_AND_ANALYTICS.md` so the two are never conflated in either the architecture or the marketing copy.
- **UNKNOWN — the "App and Website Usage" entitlement (OQ-10):** no documentation was found describing a separate, more sensitive entitlement by this name; it is possible this refers to a different or renamed capability, or that DEC-19/OQ-10's original framing was itself imprecise. **Recorded here as UNKNOWN rather than resolved, since the §27.5 finding above already answers the underlying product question (can we show category-level usage) without needing this separate entitlement** — the existing `com.apple.developer.family-controls` entitlement plus `DeviceActivityReport` appears sufficient for the confirmed use case. OQ-10 can likely be closed as moot once this is confirmed on a real device, but is not closed here since that would be inventing a technical conclusion rather than verifying one.

---

## 27.6 Corrections this document makes to earlier specification documents

Per the founder's standing DEC-31 discipline (no unverified platform-behaviour claims), this Phase 5 research surfaced one claim in an earlier, already-approved document that overstated its source and must be corrected:

- **`10_RULE_ENGINE_SPECIFICATION.md` FR-010** currently states: *"Apple's selection limit reached (50 apps / 50 web domains per Apple's documented ManagedSettings limits)."* Per §27.3 above, this limit is **not** documented by Apple — it is a community-reported, undocumented behaviour. The phrase "per Apple's documented ManagedSettings limits" should be corrected to "an undocumented behaviour reported by developers (~50 tokens per shield property), to be confirmed via real-device spike" in the next documentation pass. **Flagged here rather than silently corrected**, since editing an already-approved Phase 3 document without founder sign-off would itself violate the process; the founder should confirm this correction explicitly (see `35_DECISION_LOG.md` Phase 5 completion note).

No other Phase 1–4 documents were found to assert an Apple platform behaviour beyond what this document now confirms or flags as unverified.

---

## 27.7 Summary table of capability status

| Capability | Status | Source |
|---|---|---|
| Family Controls entitlement requires Apple approval | VERIFIED | Apple Developer Documentation |
| `.child` authorization mode requires parent credential entry | VERIFIED | Apple Developer Documentation |
| Authorization can be revoked by external events (child ages out, Settings change) | VERIFIED | Apple Developer Documentation |
| Shield tokens are opaque (no bundle ID/name extractable) | VERIFIED | Apple Developer Documentation |
| ~50-token shield limit per property | NEEDS REAL-DEVICE SPIKE | Developer forum (undocumented) |
| Shield persists across force-quit/restart/uninstall | NEEDS REAL-DEVICE SPIKE | Third-party production account (undocumented) |
| Phone/emergency calling can be excluded from shielding | UNKNOWN | No source found |
| DeviceActivityMonitor extension callback timing precision | UNKNOWN | No source found |
| Extension memory constraints require minimal on-device logic | NEEDS REAL-DEVICE SPIKE | Third-party production account |
| Cross-device DeviceActivityReport (parent viewing child's device) | VERIFIED | Apple Developer Documentation |
| Report extension sandboxed — no network access, data cannot reach our backend | VERIFIED | Apple Developer Documentation |
| Separate "App and Website Usage" entitlement (OQ-10) | UNKNOWN | No source found; likely moot per §27.5 |
| Scheduled Rule time-zone-following behaviour (device-local) | NEEDS REAL-DEVICE SPIKE | Not directly documented; DeviceActivitySchedule is "calendar-based" |

Every item marked NEEDS REAL-DEVICE TECHNICAL SPIKE or UNKNOWN is carried forward into this Phase 5 round's end-of-phase cross-check and must be resolved before the corresponding requirement in `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, or `19_DATA_MODEL.md` is treated as final for build sequencing.

Sources: [Requesting the Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement) · [AuthorizationCenter](https://developer.apple.com/documentation/familycontrols/authorizationcenter) · [FamilyControlsMember](https://developer.apple.com/documentation/familycontrols/familycontrolsmember) · [Managed Settings](https://developer.apple.com/documentation/managedsettings) · [Device Activity](https://developer.apple.com/documentation/deviceactivity) · [DeviceActivityReport](https://developer.apple.com/documentation/deviceactivity/deviceactivityreport) · [ManagedSettingsStore 50 Token Limit (developer forum)](https://developer.apple.com/forums/thread/733361) · [FamilyControls in Production: The Edges (third-party account)](https://habitdoom.com/blog/shipping-familycontrols-ios)
