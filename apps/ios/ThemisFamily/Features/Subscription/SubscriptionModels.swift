import Foundation

// UI-12 Subscription (B-001 to B-008). Presentation models only: no StoreKit, no receipts,
// no backend. Source of truth: docs/25_SUBSCRIPTIONS_AND_BILLING.md §25.2 and §25.6.

/// Screens of the UI-12 family.
enum SubscriptionScreenID: String, CaseIterable, Sendable {
    case b001 = "B-001"
    case b002 = "B-002"
    case b003 = "B-003"
    case b004 = "B-004"
    case b005 = "B-005"
    case b006 = "B-006"
    case b007 = "B-007"
    case b008 = "B-008"
}

/// What is true on the child device. Kept separate from payment state on purpose.
enum DeviceProtectionState: Equatable, Sendable {
    /// Enforcement operating normally.
    case active
    /// Themis-managed restrictions have been cleared.
    case cleared
    /// Reactivation sent; the child device has not yet acknowledged.
    case awaitingDeviceAcknowledgement
}

/// Subscription lifecycle as presented to a Parent. There is no partial-protection case.
enum SubscriptionPhase: String, CaseIterable, Sendable {
    case active
    /// Apple's own Billing Grace Period. Full protection continues.
    case billingGrace
    /// Voluntarily cancelled; service continues until the paid-through date.
    case cancelledPaidThrough
    case protectionExpired
    /// Subscribed again after expiry. Payment is active; protection is not.
    case resubscribedAwaitingReview
    /// Parent is reviewing retained rules (B-006).
    case reactivationReady
    /// Parent confirmed; device has not acknowledged (B-007).
    case reactivationSent
    /// Device acknowledged (B-008).
    case protectionActive

    var screenID: SubscriptionScreenID {
        switch self {
        case .active, .cancelledPaidThrough: return .b002
        case .billingGrace: return .b003
        case .protectionExpired: return .b004
        case .resubscribedAwaitingReview: return .b005
        case .reactivationReady: return .b006
        case .reactivationSent: return .b007
        case .protectionActive: return .b008
        }
    }

    /// Payment/entitlement is current (Apple's grace period still counts as entitled).
    var isPaymentActive: Bool {
        switch self {
        case .protectionExpired: return false
        default: return true
        }
    }

    var deviceProtection: DeviceProtectionState {
        switch self {
        case .active, .billingGrace, .cancelledPaidThrough, .protectionActive: return .active
        case .protectionExpired, .resubscribedAwaitingReview, .reactivationReady: return .cleared
        case .reactivationSent: return .awaitingDeviceAcknowledgement
        }
    }

    var isProtectionActiveOnDevice: Bool { deviceProtection == .active }

    /// Themis-managed restrictions have been actively cleared.
    var restrictionsCleared: Bool { deviceProtection == .cleared }

    /// Rule definitions are never deleted by expiry (§25.2).
    var rulesRetained: Bool { true }
}

/// Events that move the subscription. Supplied by the future subscription service.
enum SubscriptionEvent: Sendable {
    case billingFailed
    case paymentRecovered
    case graceExpiredWithoutRecovery
    case parentCancelled
    case paidThroughEnded
    case resubscribed
    case parentStartedReview
    case parentConfirmedReactivation
    case deviceAcknowledged
}

extension SubscriptionPhase {
    /// Confirmed transitions only. Anything else returns nil rather than guessing.
    func applying(_ event: SubscriptionEvent) -> SubscriptionPhase? {
        switch (self, event) {
        case (.active, .billingFailed): return .billingGrace
        case (.billingGrace, .paymentRecovered): return .active
        case (.billingGrace, .graceExpiredWithoutRecovery): return .protectionExpired
        case (.active, .parentCancelled): return .cancelledPaidThrough
        case (.cancelledPaidThrough, .paidThroughEnded): return .protectionExpired
        case (.protectionExpired, .resubscribed): return .resubscribedAwaitingReview
        case (.resubscribedAwaitingReview, .parentStartedReview): return .reactivationReady
        case (.reactivationReady, .parentConfirmedReactivation): return .reactivationSent
        case (.reactivationSent, .deviceAcknowledged): return .protectionActive
        default: return nil
        }
    }

    /// Only a household that reached Protection Expired needs the manual reactivation path.
    var requiresManualReactivation: Bool {
        switch self {
        case .protectionExpired, .resubscribedAwaitingReview, .reactivationReady, .reactivationSent:
            return true
        default: return false
        }
    }
}

/// A rule retained from before expiry, shown for review only (not editable here).
struct RetainedRule: Identifiable, Equatable, Sendable {
    let id: String
    let childName: String
    let title: String
    let detail: String
    let appsOrScope: String
}

/// Entitlement information supplied by the future subscription service.
struct SubscriptionEntitlementInfo: Equatable, Sendable {
    /// Paid-through date for a cancelled subscription, if any.
    var paidThroughDate: Date?
    /// End of Apple's Billing Grace Period as reported by Apple. Never computed by Themis.
    var billingGraceEndDate: Date?
    /// True when the dates above are fixed demo values.
    var isExampleData: Bool
}

struct SubscriptionPresentationState: Equatable, Sendable {
    var phase: SubscriptionPhase
    var entitlement: SubscriptionEntitlementInfo
    var retainedRules: [RetainedRule]
}

/// Feature-local presentation repository. Mock only.
protocol SubscriptionRepository: Sendable {
    func state(for phase: SubscriptionPhase) async -> SubscriptionPresentationState
}

struct MockSubscriptionRepository: SubscriptionRepository {
    func state(for phase: SubscriptionPhase) async -> SubscriptionPresentationState {
        SubscriptionDemoData.state(for: phase)
    }
}

enum SubscriptionDemoData {
    static let sam = RetainedRule(
        id: "sam-homework",
        childName: "Sam",
        title: "Homework Deadline",
        detail: "Due 6:00 PM",
        appsOrScope: "Roblox + Minecraft"
    )

    static let maya = RetainedRule(
        id: "maya-social",
        childName: "Maya",
        title: "Social apps",
        detail: "10:00 PM–7:00 AM",
        appsOrScope: "Social apps"
    )

    static let retainedRules: [RetainedRule] = [sam, maya]

    /// Example date for review only (14 October 2026). Not a real entitlement.
    static let exampleDate: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 12)) ?? Date(timeIntervalSince1970: 0)
    }()

    static func state(for phase: SubscriptionPhase) -> SubscriptionPresentationState {
        let entitlement = SubscriptionEntitlementInfo(
            paidThroughDate: phase == .cancelledPaidThrough ? exampleDate : nil,
            billingGraceEndDate: phase == .billingGrace ? exampleDate : nil,
            isExampleData: true
        )
        return SubscriptionPresentationState(phase: phase, entitlement: entitlement, retainedRules: retainedRules)
    }

    static func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
