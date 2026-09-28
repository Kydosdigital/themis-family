# 22. Reporting and Analytics

**Status:** Phase 6 draft
**Depends on:** `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.5/§27.5a, `19_DATA_MODEL.md`, `35_DECISION_LOG.md` DEC-19

## 22.1 Purpose and the binding architectural constraint

This document specifies what Themis Family reports to parents/guardians and how. It is **bound**, not merely informed, by two Phase 5 findings that must never be violated by a future feature request without first revisiting `27_APPLE_INTEGRATION_REQUIREMENTS.md`:

1. **The reporting-extension sandbox is a hard ceiling, not a policy choice** (§27.5, VERIFIED): raw app/website usage data can never reach or be stored by Themis Family's backend. It can only be displayed live, on-device, inside Apple's own `DeviceActivityReport` view.
2. **The "App and Website Usage" capability (`approvedWithDataAccess`) is confirmed unavailable to UK V1 customers** (§27.5a, VERIFIED — EU-device/EU-Apple-Account-only). No V1 feature, dashboard, or marketing claim may assume access to non-tokenised bundle identifiers, visited domains, or historical usage figures.

## 22.2 The two-category reporting model (restated as binding for this document)

**CONFIRMED REQUIREMENT**, carried forward verbatim from `27_APPLE_INTEGRATION_REQUIREMENTS.md` §27.5:

### Category A: Themis-owned report data (backend-stored, freely reportable)
- Rule outcomes (which rules were active, when, and what they restricted)
- Task submissions and outcomes (on-time, late, approved, rejected, interrupted)
- Approval outcomes and who resolved them
- Requests and their outcomes
- Overrides and Temporary Access Grants (including early revocations, DEC-48)
- Protection status/history (Protected / Sync Pending / Device Offline / Needs Attention / Protection Unavailable transitions, per `16_DEVICE_ENFORCEMENT.md` §16.8)
- Any other Themis-generated event

This data may be aggregated, charted over time, exported, and retained per Phase 6's privacy/retention policy (`23_PRIVACY_AND_CHILD_SAFETY.md`).

### Category B: Apple-owned Screen Time activity data (never backend-stored)
- Raw app/website usage time, displayed **only** through an embedded `DeviceActivityReport` view
- May include child/family device activity where Apple's cross-device authorization model permits (§27.5's VERIFIED finding)
- Remains inside Apple's report-extension sandbox at all times
- **Must not be modelled anywhere in this product's backend or data model as Themis-owned raw usage data**
- **Must not be used to promise server-side historical app-usage analytics** (e.g. "see how screen time changed over the last 6 months" is not a deliverable V1 claim, since the backend never receives or retains the underlying figures)

**FUTURE FEATURE, not V1:** if Themis Family expands into the EU market, `approvedWithDataAccess` could in principle unlock non-tokenised Category-B-equivalent data for EU households only — this must never be implied for UK V1.

## 22.3 V1 reporting surfaces

**FR/BR reference:** this section operationalises the DEC-19 field list (Phase 1) using the two-category model above.

| Surface | Category | Data shown | Notes |
|---|---|---|---|
| Household activity feed (approvals, requests, rule changes) | A | Chronological log of Themis-generated events | Core V1 surface; fully backend-owned |
| Protection status dashboard | A | Current + historical Protected/Sync Pending/Device Offline/Needs Attention/Protection Unavailable per device | Derived/computed per `16_DEVICE_ENFORCEMENT.md` §16.8, not stored as raw events but as status-transition history |
| Task/Request completion trends | A | Counts and timing of on-time vs. late vs. rejected over a period, per child | Themis-owned; safe to chart, export |
| "See what they've been doing" screen (if built) | B | Embedded native `DeviceActivityReport` view, filtered to the relevant child/device | **Must render Apple's own view component**, not a Themis-built chart from extracted data — there is no extracted data to chart |

**CONFIRMED REQUIREMENT:** the UI must never place Category A and Category B data in the same visual container in a way that implies a single unified Themis data source (e.g. a chart that appears to combine "tasks completed" with "hours on TikTok" from a single backend query) — Category B content must be visually and architecturally distinct (Apple's own report view, clearly bounded), so the two-category separation is legible to the parent, not just to the engineering team.

## 22.4 What Themis Family must not claim (marketing/product-copy constraint)

Per §27.5a's finding, the following claims are **confirmed prohibited** for UK V1 copy, onboarding, or support material:
- Any claim of server-side historical usage analytics ("track screen time trends over months," "compare your child's usage week over week" as a backend-computed feature).
- Any claim that Themis stores or has access to bundle identifiers, visited domain names, or app display names outside of the parent's own `custom_alias` entries (`19_DATA_MODEL.md`).
- Any claim of an EU-only capability being available to UK customers.

## 22.5 End-of-Phase-6 cross-check items addressed here

- **Privacy data with no purpose:** none identified in this document — every Category A field traces directly to a Phase 3/4 confirmed requirement or Phase 5 architectural finding; no speculative analytics field is introduced.
- **Metrics that would require prohibited/unavailable child data:** the one class identified is anything requiring `approvedWithDataAccess`-level non-tokenised data (raw bundle IDs, visited domains) — explicitly excluded from V1 scope by §22.1/§22.2, not silently designed around.
