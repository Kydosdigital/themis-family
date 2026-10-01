import Foundation


/// Approved copy and structure for each B-screen. Pure data so it can be tested.
/// No prices, trial lengths or payment details appear anywhere in this file.
struct SubscriptionContent: Equatable, Sendable {
    enum Banner: Equatable, Sendable {
        case success(String)
        case info(String)
        case warning(String)
    }

    let screenID: SubscriptionScreenID
    let title: String
    let message: String
    let points: [String]
    let statusKind: StatusKind?
    let statusLabel: String?
    let banner: Banner?
    let detailLine: String?
    let showsRules: Bool
    let primaryAction: String?
    let secondaryAction: String?

    /// Every string shown, used by copy-safety tests.
    var allText: [String] {
        var text = [title, message] + points
        if let statusLabel { text.append(statusLabel) }
        if let detailLine { text.append(detailLine) }
        switch banner {
        case .success(let value), .info(let value), .warning(let value): text.append(value)
        case nil: break
        }
        if let primaryAction { text.append(primaryAction) }
        if let secondaryAction { text.append(secondaryAction) }
        return text
    }
}

enum SubscriptionContentFactory {
    static let managedByAppStore = "Managed through the App Store"

    /// B-001 offer. No price or trial length until commercial terms are confirmed.
    static let offer = SubscriptionContent(
        screenID: .b001,
        title: "Themis Family",
        message: "Calm, clear family rules that you stay in charge of.",
        points: [
            "Clear family rules for each child",
            "Exceptions that only you can approve",
            "See whether protection is applied on each device",
            "A respectful experience for Child and Teen"
        ],
        statusKind: nil,
        statusLabel: nil,
        banner: .info("Subscription details will be shown here once confirmed."),
        detailLine: managedByAppStore,
        showsRules: false,
        primaryAction: "Continue",
        secondaryAction: nil
    )

    static func content(for state: SubscriptionPresentationState) -> SubscriptionContent {
        switch state.phase {
        case .active:
            return SubscriptionContent(
                screenID: .b002, title: "Subscription",
                message: "Your Themis Family subscription is active.",
                points: ["Billing and cancellation are handled by Apple."],
                statusKind: .active, statusLabel: "Active", banner: nil,
                detailLine: managedByAppStore, showsRules: false,
                primaryAction: "Manage in App Store", secondaryAction: nil)
        case .cancelledPaidThrough:
            let date = state.entitlement.paidThroughDate.map(SubscriptionDemoData.formatted)
            return SubscriptionContent(
                screenID: .b002, title: "Subscription",
                message: date.map { "Protection stays active until \($0)." } ?? "Protection stays active until your paid period ends.",
                points: ["Cancellation is handled by Apple. Everything keeps working until the paid-through date."],
                statusKind: .grace, statusLabel: "Cancelled",
                banner: nil,
                detailLine: date.map { "Cancelled · active until \($0)" },
                showsRules: false,
                primaryAction: "Manage in App Store", secondaryAction: nil)
        case .billingGrace:
            return SubscriptionContent(
                screenID: .b003, title: "Billing issue",
                message: "Your payment didn’t go through.",
                points: [
                    "Protection is still active while Apple retries payment.",
                    "You can keep managing rules as normal.",
                    "Update your payment method to keep protection active."
                ],
                statusKind: .grace, statusLabel: "Billing issue",
                banner: .info("Protection is fully active."),
                detailLine: state.entitlement.billingGraceEndDate.map { "Apple’s grace period ends \(SubscriptionDemoData.formatted($0))" },
                showsRules: false,
                primaryAction: "Update payment method", secondaryAction: "Not now")
        case .protectionExpired:
            return SubscriptionContent(
                screenID: .b004, title: "Protection has ended",
                message: "Themis Family protection is no longer active.",
                points: [
                    "Themis-managed restrictions have been cleared.",
                    "Your rules are saved. They are not being applied.",
                    "You can subscribe again whenever you’re ready."
                ],
                statusKind: .expired, statusLabel: "Expired", banner: nil,
                detailLine: nil, showsRules: false,
                primaryAction: "View subscription", secondaryAction: nil)
        case .resubscribedAwaitingReview:
            return SubscriptionContent(
                screenID: .b005, title: "Ready to turn protection back on?",
                message: "Your subscription is active again. Nothing has been applied to your family’s devices yet.",
                points: ["Your earlier rules are still saved.", "Review them first, then choose when to turn protection back on."],
                statusKind: .active, statusLabel: "Subscription active", banner: nil,
                detailLine: nil, showsRules: false,
                primaryAction: "Review rules", secondaryAction: nil)
        case .reactivationReady:
            return SubscriptionContent(
                screenID: .b006, title: "Review your rules",
                message: "These rules will apply again once you turn protection back on.",
                points: [],
                statusKind: nil, statusLabel: nil,
                banner: .info("Nothing changes until you confirm."),
                detailLine: nil, showsRules: true,
                primaryAction: "Turn protection back on", secondaryAction: "Not yet")
        case .reactivationSent:
            return SubscriptionContent(
                screenID: .b007, title: "Reactivation sent",
                message: "Waiting for your family’s devices to confirm.",
                points: ["We’ll show when protection is active on each device."],
                statusKind: .syncPending, statusLabel: "Reactivation sent", banner: nil,
                detailLine: nil, showsRules: false,
                primaryAction: nil, secondaryAction: nil)
        case .protectionActive:
            return SubscriptionContent(
                screenID: .b008, title: "Protection active on device",
                message: "The device has confirmed your rules are applied.",
                points: [],
                statusKind: .applied, statusLabel: "Active on device",
                banner: .success("Your earlier rules are in place again."),
                detailLine: nil, showsRules: false,
                primaryAction: "Done", secondaryAction: nil)
        }
    }
}
