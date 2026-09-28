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

**Status: VERIFIED FROM APPLE DOCUMENTATION (mechanism, and — corrected in this amendment round — the specific numeric limits); NEEDS REAL-DEVICE TECHNICAL SPIKE (behaviour when a limit is exceeded, and other edge-case behaviour).**
Sources: [Managed Settings](https://developer.apple.com/documentation/managedsettings), [ManagedSettingsStore](https://developer.apple.com/documentation/managedsettings/managedsettingsstore), [ShieldSettings](https://developer.apple.com/documentation/managedsettings/shieldsettings), [ShieldSettings.applications](https://developer.apple.com/documentation/managedsettings/shieldsettings/applications-swift.property), [ShieldSettings.webDomains](https://developer.apple.com/documentation/managedsettings/shieldsettings/webdomains-swift.property), [ShieldSettings.applicationCategories](https://developer.apple.com/documentation/managedsettings/shieldsettings/applicationcategories-swift.property), [ShieldSettings.webDomainCategories](https://developer.apple.com/documentation/managedsettings/shieldsettings/webdomaincategories-swift.property) (Apple Developer Documentation); community sources noted explicitly where used.

- **VERIFIED:** `ManagedSettingsStore` is *"a data store that applies settings to the current user or device."* Shielding targets are expressed as `ApplicationToken`, `ActivityCategoryToken`, and `WebDomainToken` — opaque tokens obtained from a `FamilyActivityPicker` selection, not raw bundle identifiers or domain strings the app can read, log, or export (unless the app holds `approvedWithDataAccess`, per §27.5a below).
- **VERIFIED — critical data-model constraint:** Apple's `Token` documentation states these tokens are *"a representation of an activity, such as an app or website, that doesn't reveal its identity."* Under the standard `.approved` authorization status (the one this product's V1 UK architecture uses — see §27.5a), tokens contain no bundle IDs or app names and can only be rendered via a SwiftUI `Label` at display time. **This means Themis Family's backend cannot store or transmit human-readable app/site names derived from the token itself — only the parent's own chosen alias (entered inside Themis, not supplied by the picker) is available for that purpose.** This is a direct, binding input to `19_DATA_MODEL.md`'s ControlledTarget entity design.

- **CORRECTED IN THIS AMENDMENT ROUND — the 50-item limits are, in fact, individually documented by Apple, per-property, not an undocumented behaviour.** The Phase 5 original draft of this document generalised a community forum report into a single undocumented "~50-token" claim and proposed correcting `10_RULE_ENGINE_SPECIFICATION.md` FR-010 to describe the limit as wholly undocumented. **That proposed correction was itself incorrect and is withdrawn.** Re-checking Apple's current documentation directly (fetched from developer.apple.com, quoted verbatim below) found each relevant `ShieldSettings` property explicitly documents its own 50-item cap:
  - `ShieldSettings.applications`: *"Your app can shield up to 50 application tokens at once."* — **VERIFIED FROM APPLE DOCUMENTATION.**
  - `ShieldSettings.webDomains`: *"Your app can shield up to 50 web domain tokens at once."* — **VERIFIED FROM APPLE DOCUMENTATION.**
  - `ShieldSettings.applicationCategories`: *"Your app can shield up to 50 category tokens and specify up to 50 application tokens exceptions at once."* — **VERIFIED FROM APPLE DOCUMENTATION.**
  - `ShieldSettings.webDomainCategories`: *"Your app can shield up to 50 category tokens and specify up to 50 web domain tokens exceptions at once."* — **VERIFIED FROM APPLE DOCUMENTATION.**
  These four limits are independent per-property caps (50 apps, separately 50 domains, separately 50 categories with up to 50 exceptions each), not one shared 50-item budget across the whole shield as the earlier draft implied. `16_DEVICE_ENFORCEMENT.md`'s target-prioritisation guidance (§16.5) is corrected accordingly.
  - **What remains genuinely NEEDS REAL-DEVICE TECHNICAL SPIKE:** Apple's documentation states the permitted maximum but does not document the *failure mode* if an app attempts to set more than 50 (does the extra item get silently dropped, does the whole property return `nil` as the community forum thread claimed, does it throw?). The community-reported "silent nil, shield fails entirely" behaviour ([developer forum thread](https://developer.apple.com/forums/thread/733361)) remains a plausible but **unverified failure mode**, not a documented one, and must be confirmed on a real device before the app relies on any particular graceful-degradation behaviour when a parent's selection exceeds a limit. **This is the corrected, precise scope of the NEEDS SPIKE classification** — the *existence and size* of the limits is VERIFIED; the *exceeded-limit behaviour* is NEEDS REAL-DEVICE TECHNICAL SPIKE.
  - **`10_RULE_ENGINE_SPECIFICATION.md` FR-010 correction (superseding the Phase 5 original proposal):** FR-010 should state the exact documented limits above (50 apps / 50 domains / 50 categories with up to 50 exceptions each, as independent caps) as **VERIFIED FROM APPLE DOCUMENTATION**, and separately flag the exceeded-limit failure behaviour as **NEEDS REAL-DEVICE TECHNICAL SPIKE**. This is applied to FR-010 directly in this amendment round (§27.6).

- **NEEDS REAL-DEVICE TECHNICAL SPIKE — shield persistence across termination/reboot:** a third-party production account ([FamilyControls in Production: The Edges](https://habitdoom.com/blog/shipping-familycontrols-ios)) states the shield "persists through force-quit, restart, and uninstall by design — it's enforced at the OS level, not app-level code." **No official Apple documentation confirming this exact persistence guarantee was found.** If confirmed true on a real device, this would materially simplify `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`'s design — but it must not be assumed true for architecture decisions until verified on a real device.
- **UNKNOWN — Phone/emergency calling shielding behaviour (OQ-30, BR-222):** no Apple documentation was found stating whether the Phone app, emergency calling, or other OS-level emergency functionality can be included in a `ManagedSettingsStore` shield at all, or whether Apple's own OS prevents this regardless of what the app configures. This is the single most safety-critical unresolved technical item in this document and must be the first item validated in any real-device spike (Priority 2, §27.8), given BR-222's hard safety principle depends on knowing the actual answer, not an assumption in either direction.

---

## 27.3a Remote approval and cross-device unlock propagation (new in this amendment round)

**Status: NEEDS REAL-DEVICE TECHNICAL SPIKE — Priority 1, the highest-priority item on the spike list after entitlement approval itself (§27.8).**

No Apple documentation was found (in this round's re-check or the original Phase 5 pass) directly describing end-to-end timing or reliability for the scenario at the heart of this product's core value proposition: a parent approves something on their device, and that decision needs to reach and take effect on the child's device. This was implicit in the original Phase 5 architecture (`16_DEVICE_ENFORCEMENT.md`'s Resolved Shield List / now Local Enforcement Plan model, §16.3) but not called out as its own named, top-priority validation item. It is elevated to that status now.

The spike must specifically measure the scenario matrix in §27.8 Priority 1 (child app foregrounded / backgrounded / force-terminated / device locked; parent and child on different networks; child temporarily offline; push delivery delayed; child regains connectivity later) and produce, at minimum: time from parent approval to backend commit; time to child device receiving the state change; time to shield removal; whether shield removal is possible without the child foregrounding Themis at all; and what UI state the parent should honestly be shown before the child's device has acknowledged the change. **Until this spike is run, the product must not market or specify "instant unlock" — the parent-facing UI must distinguish "Approved" (recorded on the backend) from "Applied on child's device" (confirmed in effect) wherever those two moments are not guaranteed to be simultaneous.** This is now a confirmed requirement on the parent-facing UI copy, not merely a caveat (see `16_DEVICE_ENFORCEMENT.md` §16.6a).

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
- **CONFIRMED REPORTING MODEL (restated precisely in this amendment round, binding on `22_REPORTING_AND_ANALYTICS.md`, Phase 6):** V1 reporting is built as two permanently separate categories, never conflated in architecture, backend schema, or marketing copy:
  - **Themis-owned report data** — the backend may store and report on: rule outcomes, task submissions, approval outcomes, requests, overrides, protection status/history, and any other Themis-generated event. These originate from Themis's own actions, not from Apple's activity-monitoring sandbox, and are ordinary backend-owned data with no platform restriction.
  - **Apple-owned Screen Time activity data** — for UK V1, this is displayed only through an embedded `DeviceActivityReport` view, may include child/family device activity where Apple's authorization model permits (per the cross-device finding above), remains inside Apple's report-extension sandbox at all times, **must not be modelled anywhere in this product's backend or data model as Themis-owned raw usage data**, and **must not be used to promise server-side historical app-usage analytics** (a "usage over the last 6 months" chart, for example, is not a V1-deliverable claim, since the backend never receives or retains the underlying figures).
  This is not a new architectural decision — it restates and sharpens the Phase 5 original finding into the exact two-category language Phase 6 must carry forward without drift.
## 27.5a The Family Controls "App and Website Usage" entitlement / `approvedWithDataAccess` — resolved this amendment round, closes OQ-10

**Status: VERIFIED FROM APPLE DOCUMENTATION.**
Sources: [`AuthorizationStatus`](https://developer.apple.com/documentation/familycontrols/authorizationstatus), [`AuthorizationStatus.approvedWithDataAccess`](https://developer.apple.com/documentation/familycontrols/authorizationstatus/approvedwithdataaccess), [`FamilyActivityData`](https://developer.apple.com/documentation/familycontrols/familyactivitydata) (Apple Developer Documentation; the UNKNOWN classification given to this item in the original Phase 5 draft is withdrawn — the capability exists and is documented under a name this document had not yet located).

- **VERIFIED:** a separate `AuthorizationStatus` case, `.approvedWithDataAccess`, exists beyond the standard `.approved` status this product's V1 architecture assumes throughout §27.2–§27.4. It grants everything `.approved` does, **plus** access to a `FamilyActivityData` class exposing **non-tokenised** data: actual bundle identifiers of installed applications (`installedApplications`), actual domain names of visited websites (`visitedWebDomains`), and display names of activity categories — directly contradicting the privacy-preserving opacity this document otherwise relies on for `.approved`-level tokens (§27.3).
- **VERIFIED — the decisive regional restriction, quoted verbatim from Apple's documentation:** *"You may develop and test an app that achieves this status on devices in all regions by using an Apple-provided provisioning profile. Customer installations of your app can only achieve this status on devices located in the EU that are signed in with an Apple Account with an EU country or region. On devices outside the EU, `authorizationStatus` never returns `approvedWithDataAccess`, and any attempt to access `FamilyActivityData` properties fails with `FamilyControlsError.unavailable`."* The identical restriction is repeated on `FamilyActivityData`'s own page: *"Customer installations of your app can only use the class on devices located in the EU that are signed in with an Apple Account with an EU country or region."*
- **VERIFIED — separate entitlement required:** this capability requires its own distinct entitlement, `com.apple.developer.family-controls.app-and-website-usage`, in addition to (not instead of) the base `com.apple.developer.family-controls` entitlement covered in §27.1 — a second, separate Apple approval process this product has not applied for and, per the finding below, has no V1 reason to.
- **CONFIRMED PLATFORM LIMITATION, closes OQ-10:** since Themis Family V1 is UK-first (DEC-23) and the UK is not in the EU, **normal customer installations of Themis Family cannot obtain `approvedWithDataAccess` at all, regardless of any entitlement application outcome.** This capability must not be part of the UK V1 architecture, must not be assumed in any V1 data model, and must not be relied upon for any V1 reporting claim. `19_DATA_MODEL.md`'s `ControlledTarget.apple_token_opaque_ref` field and the standard `.approved`-only authorization model throughout §27.2–§27.3 remain correct and unaffected — this section documents a capability the product deliberately does not use in V1, not a correction to the rest of this document.
- **RECOMMENDATION, not a V1 requirement:** document this as a possible **FUTURE FEATURE** for an eventual EU-market expansion, where a household located in the EU with an EU Apple Account could, in principle, unlock non-tokenised usage data reporting — but this must never be implied or promised in UK V1 marketing, onboarding copy, or architecture, since it is unavailable to essentially the entire V1 target market.

This finding does not alter §27.5's core conclusion above (standard `DeviceActivityReport`, under ordinary `.approved` authorization, remains the correct and sufficient V1 reporting path); it resolves the previously-unknown identity of the "App and Website Usage" capability and confirms it is architecturally irrelevant to UK V1, not silently unavailable for an unknown reason.

---

## 27.6 Corrections this document makes to earlier specification documents (revised in this amendment round)

Per the founder's standing DEC-31 discipline (no unverified platform-behaviour claims), this document has now gone through two research passes and two corrections:

- **Original Phase 5 finding (now itself superseded):** `10_RULE_ENGINE_SPECIFICATION.md` FR-010 stated the ~50-item limit was "Apple's documented ManagedSettings limits," and the original Phase 5 draft of this document proposed correcting that to "wholly undocumented, community-reported only." **That proposed correction was wrong and is withdrawn** — a direct re-check of Apple's current documentation (§27.3) found the limits genuinely are documented, per-property, with exact figures.
- **Corrected finding, applied to `10_RULE_ENGINE_SPECIFICATION.md` FR-010 in this amendment round:** FR-010 now states the four documented per-property limits (50 application tokens; 50 web domain tokens; 50 category tokens plus up to 50 application-token exceptions; 50 category tokens plus up to 50 web-domain-token exceptions) as **VERIFIED FROM APPLE DOCUMENTATION** with direct citations, and separately flags the *undocumented failure behaviour when a limit is exceeded* as **NEEDS REAL-DEVICE TECHNICAL SPIKE**. This correction is applied directly to FR-010's text in this amendment round's commit (not merely flagged for later confirmation, since the founder has now explicitly directed it).
- **General lesson applied going forward:** a community report describing behaviour "undocumented" should prompt a direct, current check of Apple's own documentation before that characterisation is written into a specification — as happened here, the community forum thread's framing (implying no Apple documentation exists at all) was outdated or incomplete relative to Apple's current published API reference. Future NEEDS-SPIKE classifications in this document have been re-verified against current documentation rather than taken from secondary characterisation alone.

No other Phase 1–4 documents were found to assert an Apple platform behaviour beyond what this document now confirms or flags as unverified.

---

## 27.7 Summary table of capability status (revised in this amendment round)

| Capability | Status | Source |
|---|---|---|
| Family Controls entitlement requires Apple approval | VERIFIED | Apple Developer Documentation |
| `.child` authorization mode requires parent credential entry | VERIFIED | Apple Developer Documentation |
| Authorization can be revoked by external events (child ages out, Settings change) | VERIFIED | Apple Developer Documentation |
| Shield tokens are opaque (no bundle ID/name extractable) under `.approved` status | VERIFIED | Apple Developer Documentation |
| 50-application-token shield limit | VERIFIED (exact figure) | Apple Developer Documentation — `ShieldSettings.applications` |
| 50-web-domain-token shield limit | VERIFIED (exact figure) | Apple Developer Documentation — `ShieldSettings.webDomains` |
| 50-category-token limit (+50 exceptions) for app categories | VERIFIED (exact figure) | Apple Developer Documentation — `ShieldSettings.applicationCategories` |
| 50-category-token limit (+50 exceptions) for web-domain categories | VERIFIED (exact figure) | Apple Developer Documentation — `ShieldSettings.webDomainCategories` |
| Behaviour when a shield property's limit is exceeded | NEEDS REAL-DEVICE SPIKE | Developer forum claims silent `nil`/failure; not documented by Apple |
| `approvedWithDataAccess` / non-tokenised `FamilyActivityData` exists | VERIFIED | Apple Developer Documentation |
| `approvedWithDataAccess` restricted to EU devices + EU Apple Account for customer installs | VERIFIED | Apple Developer Documentation (verbatim quote, §27.5a) |
| Separate `com.apple.developer.family-controls.app-and-website-usage` entitlement required for the above | VERIFIED | Apple Developer Documentation |
| Shield persists across force-quit/restart/uninstall | NEEDS REAL-DEVICE SPIKE | Third-party production account (undocumented) |
| Phone/emergency calling can be excluded from shielding | UNKNOWN | No source found |
| End-to-end remote approval → child-device unlock timing/reliability | NEEDS REAL-DEVICE SPIKE | No source found; new Priority 1 spike item (§27.3a/§27.8) |
| DeviceActivityMonitor extension callback timing precision | UNKNOWN | No source found |
| Extension memory constraints require minimal on-device logic | NEEDS REAL-DEVICE SPIKE | Third-party production account |
| Cross-device DeviceActivityReport (parent viewing child's device) | VERIFIED | Apple Developer Documentation |
| Report extension sandboxed — no network access, data cannot reach our backend | VERIFIED | Apple Developer Documentation |
| Scheduled Rule time-zone-following behaviour (device-local) | NEEDS REAL-DEVICE SPIKE | Not directly documented; DeviceActivitySchedule is "calendar-based" |
| Device clock/timezone manual tampering resilience | UNKNOWN | No source found |

Every item marked NEEDS REAL-DEVICE TECHNICAL SPIKE or UNKNOWN is carried forward into this Phase 5 round's end-of-phase cross-check and must be resolved before the corresponding requirement in `16_DEVICE_ENFORCEMENT.md`, `17_OFFLINE_AND_SYNC_BEHAVIOUR.md`, or `19_DATA_MODEL.md` is treated as final for build sequencing.

## 27.8 Real-device technical spike — priority order (revised in this amendment round)

Per the founder's explicit re-prioritisation, the spike programme (to be commissioned in Phase 6/7, before build sequencing treats any NEEDS-SPIKE item as resolved) runs in this order:

- **Priority 0:** Family Controls distribution entitlement approval (§27.1) — nothing else can be validated on a real customer-facing build without it.
- **Priority 1:** End-to-end parent-approval → child-unlock propagation when the child app is not foregrounded (§27.3a). Test matrix: child app foregrounded / backgrounded / force-terminated / device locked; parent and child on different networks; child temporarily has no network; push delivery delayed; child device regains connectivity later. Measure: time from parent approval to backend commit; time to child device receiving the state change; time to shield removal; whether shield removal is possible without foregrounding Themis; what UI state the parent should display before child acknowledgement.
- **Priority 2:** Phone / emergency calling / Messages / Maps behaviour under `ManagedSettingsStore` shielding (OQ-30, §27.3) — the top safety-critical unresolved item.
- **Priority 3:** `DeviceActivityMonitor` scheduled-transition reliability while the main app is terminated and the device is locked (§27.4; feeds the Local Enforcement Plan design in `16_DEVICE_ENFORCEMENT.md`).
- **Priority 4:** Exact behaviour when a `ShieldSettings` property's documented 50-item limit is exceeded, for every property Themis actually intends to use (§27.3).
- **Priority 5:** Shield persistence through app termination, reboot, and app uninstall, where applicable (§27.3).
- **Priority 6:** Manual device clock and timezone tampering resilience (§27.4/OQ-32).
- **Priority 7:** Extension memory behaviour with realistic Local Enforcement Plan sizes (§27.4).
- **Priority 8:** Cross-device `DeviceActivityReport` rendering on a real parent/child Family Sharing pair (§27.5).

Every spike result must record the measured behaviour, OS version, device model, and test conditions, so a result is traceable and reproducible rather than a one-off anecdote.

Sources: [Requesting the Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement) · [AuthorizationCenter](https://developer.apple.com/documentation/familycontrols/authorizationcenter) · [FamilyControlsMember](https://developer.apple.com/documentation/familycontrols/familycontrolsmember) · [Managed Settings](https://developer.apple.com/documentation/managedsettings) · [ShieldSettings](https://developer.apple.com/documentation/managedsettings/shieldsettings) · [ShieldSettings.applications](https://developer.apple.com/documentation/managedsettings/shieldsettings/applications-swift.property) · [ShieldSettings.webDomains](https://developer.apple.com/documentation/managedsettings/shieldsettings/webdomains-swift.property) · [ShieldSettings.applicationCategories](https://developer.apple.com/documentation/managedsettings/shieldsettings/applicationcategories-swift.property) · [ShieldSettings.webDomainCategories](https://developer.apple.com/documentation/managedsettings/shieldsettings/webdomaincategories-swift.property) · [Device Activity](https://developer.apple.com/documentation/deviceactivity) · [DeviceActivityReport](https://developer.apple.com/documentation/deviceactivity/deviceactivityreport) · [AuthorizationStatus](https://developer.apple.com/documentation/familycontrols/authorizationstatus) · [AuthorizationStatus.approvedWithDataAccess](https://developer.apple.com/documentation/familycontrols/authorizationstatus/approvedwithdataaccess) · [FamilyActivityData](https://developer.apple.com/documentation/familycontrols/familyactivitydata) · [ManagedSettingsStore 50 Token Limit (developer forum)](https://developer.apple.com/forums/thread/733361) · [FamilyControls in Production: The Edges (third-party account)](https://habitdoom.com/blog/shipping-familycontrols-ios)
