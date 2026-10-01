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
    /// B-003 recovered during grace: protection simply continues, no reactivation flow.
    case recoveredDuringGrace
    /// B-004 · Protection Expired.
    case protectionExpired
    /// B-005 · Resubscribed — "Ready to turn protection back on?"
    case readyToReactivate
    /// B-006 · Review existing rules.
    case reviewRetainedRules
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
    /// Retained rule definitions, unchanged since before protection was cleared — only
    /// enforcement paused, never the definitions themselves.
    static let retainedRules: [RetainedRule] = [
        RetainedRule(
            id: "sam-homework-deadline",
            childName: "Sam",
            title: "Homework Deadline",
            detail: "Due 6:00 PM · Roblox + Minecraft pause if not done"
        ),
        RetainedRule(
            id: "maya-social-apps",
            childName: "Maya",
            title: "Social apps",
            detail: "Pause 10:00 PM–7:00 AM"
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
            return SubscriptionPresentation(
                screen: .offer,
                lifecycle: .active,
                protection: .enforcing,
                reactivationStep: nil,
                paidThroughDate: nil,
                exampleEntitlementDate: nil,
                retainedRules: [],
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: false
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
                reactivationAcknowledged: true
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
                reactivationAcknowledged: true
            )
        }
    }
}
