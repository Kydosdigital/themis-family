import Foundation

/// Deterministic UI-12 demo scenarios (B-001…B-008), kept local to this feature so the
/// shared `Mocks/DemoScenario.swift` switcher is untouched by this isolated slice.
enum SubscriptionDemoScenario: String, CaseIterable, Sendable, Identifiable {
    /// B-001 · Trial / subscription offer.
    case offer
    /// B-002 · Manage subscription, Active.
    case manageActive
    /// B-002 · Manage subscription, Cancelled / paid-through.
    case manageCancelledPaidThrough
    /// B-003 · Apple Billing Grace Period.
    case billingGrace
    /// B-003 · Recovered: payment recovered during the Billing Grace Period. Protection
    /// simply continues, no reactivation flow.
    case recoveredDuringGrace
    /// B-004 · Protection Expired.
    case protectionExpired
    /// B-005 · Resubscribed — "Ready to turn protection back on?"
    case readyToReactivate
    /// B-005 · Not now — the parent explicitly deferred reactivation.
    case readyToReactivateNotNow
    /// B-006 · Review existing rules.
    case reviewRetainedRules
    /// B-006 · Confirm — confirm reactivation, after review, before anything is sent.
    case reviewConfirmReactivation
    /// B-007 · Reactivation sent.
    case reactivationSent
    /// B-008 · Protection active on device.
    case protectionActiveOnDevice

    var id: String { rawValue }
}

/// Canonical demo family and retained-rule examples (`docs/implementation/MOBILE_UX_BLUEPRINT.md`,
/// matched against the canonical Sam/Maya examples already used by Child/Teen Home).
/// Demo data only — it never means an App Store transaction, backend entitlement change
/// or device-shield change actually happened.
enum SubscriptionDemoData {
    /// The approved B-006 retained-rule examples. Definitions only — unchanged since
    /// before protection was cleared; only enforcement paused, never the definitions.
    static let retainedRules: [RetainedRule] = [
        RetainedRule(
            id: "sam-homework-deadline",
            childName: "Sam",
            title: "Homework Deadline",
            detail: "Due 6:00 PM"
        ),
        RetainedRule(
            id: "sam-bedtime",
            childName: "Sam",
            title: "Bedtime",
            detail: "8:30 PM–7:00 AM"
        ),
        RetainedRule(
            id: "maya-social-apps",
            childName: "Maya",
            title: "Social apps",
            detail: "10:00 PM–7:00 AM"
        )
    ]

    /// An EXAMPLE entitlement date only, for deterministic preview/review. Never a
    /// Themis-computed value — a future subscription service supplies the real date.
    private static let exampleReferenceDate = DateComponents(
        calendar: .init(identifier: .gregorian), year: 2026, month: 9, day: 14
    ).date!

    static func presentation(for scenario: SubscriptionDemoScenario) -> SubscriptionPresentation {
        switch scenario {
        case .offer:
            // B-001: no entitlement and no device protection state exist yet. `nil`
            // here must never be read as "inactive" standing in for "active" — it
            // means the question doesn't apply yet, before any subscription exists.
            return SubscriptionPresentation(
                screen: .offer,
                lifecycle: nil,
                protection: nil,
                reactivationStep: nil,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: [],
                reactivationConfirmedByParent: false
            )

        case .manageActive:
            return SubscriptionPresentation(
                screen: .manage,
                lifecycle: .active,
                protection: .enforcing,
                reactivationStep: nil,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: [],
                reactivationConfirmedByParent: false
            )

        case .manageCancelledPaidThrough:
            return SubscriptionPresentation(
                screen: .manage,
                lifecycle: .cancelledPaidThrough,
                protection: .enforcing,
                reactivationStep: nil,
                paidThroughDate: exampleReferenceDate,
                exampleEntitlementDate: nil,
                retainedRules: [],
                reactivationConfirmedByParent: false
            )

        case .billingGrace:
            return SubscriptionPresentation(
                screen: .billingGraceWarning,
                lifecycle: .appleBillingGracePeriod,
                protection: .enforcing,
                reactivationStep: nil,
                paidThroughDate: nil,
                exampleEntitlementDate: exampleReferenceDate,
                retainedRules: [],
                reactivationConfirmedByParent: false
            )

        case .recoveredDuringGrace:
            // Recovery during the Billing Grace Period returns straight to the normal
            // Active presentation. There is no B-005/B-006 detour — protection was
            // never cleared, so no manual reactivation step applies (§25.6).
            return SubscriptionPresentation(
                screen: .manage,
                lifecycle: .recovered,
                protection: .enforcing,
                reactivationStep: nil,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: [],
                reactivationConfirmedByParent: false
            )

        case .protectionExpired:
            return SubscriptionPresentation(
                screen: .protectionExpiredNotice,
                lifecycle: .protectionExpired,
                protection: .cleared,
                reactivationStep: nil,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: false
            )

        case .readyToReactivate:
            return SubscriptionPresentation(
                screen: .readyToReactivate,
                lifecycle: .resubscribed,
                protection: .cleared,
                reactivationStep: .awaitingReview,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: false
            )

        case .readyToReactivateNotNow:
            // The parent chose "Not now": payment stays active, protection stays
            // cleared, rules stay retained, and nothing advances to B-006/B-007/B-008.
            return SubscriptionPresentation(
                screen: .readyToReactivate,
                lifecycle: .resubscribed,
                protection: .cleared,
                reactivationStep: .deferred,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: false
            )

        case .reviewRetainedRules:
            return SubscriptionPresentation(
                screen: .reviewRetainedRules,
                lifecycle: .resubscribed,
                protection: .cleared,
                reactivationStep: .reviewingRetainedRules,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: false
            )

        case .reviewConfirmReactivation:
            // B-006 · Confirm sits strictly between review and send. The parent has
            // not yet confirmed here, so protection remains cleared and nothing has
            // been sent to the device.
            return SubscriptionPresentation(
                screen: .reviewRetainedRules,
                lifecycle: .resubscribed,
                protection: .cleared,
                reactivationStep: .confirming,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: false
            )

        case .reactivationSent:
            return SubscriptionPresentation(
                screen: .reactivationSent,
                lifecycle: .resubscribed,
                protection: .reactivationSent,
                reactivationStep: .sent,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: true
            )

        case .protectionActiveOnDevice:
            return SubscriptionPresentation(
                screen: .protectionActiveOnDevice,
                lifecycle: .active,
                protection: .enforcing,
                reactivationStep: .acknowledgedOnDevice,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: retainedRules,
                reactivationConfirmedByParent: true
            )
        }
    }
}
