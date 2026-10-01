import Foundation

/// UI-12 Subscription (B-001…B-008). Presentation-only models for this isolated slice.
///
/// Two things must never be collapsed into one, per `docs/25_SUBSCRIPTIONS_AND_BILLING.md`:
///
/// 1. `SubscriptionLifecycleState` — whether the App Store entitlement/payment is current.
/// 2. `DeviceProtectionState` — whether Themis-managed restrictions are actually
///    enforced on the child's device.
///
/// Payment being active does **not** imply protection is active (§25.6). No StoreKit,
/// receipt validation, backend entitlement service or App Store transaction object is
/// modelled here — a future subscription service supplies the real entitlement state.

/// The subscription entitlement/payment lifecycle (`docs/25_SUBSCRIPTIONS_AND_BILLING.md` §25.2).
enum SubscriptionLifecycleState: String, CaseIterable, Sendable, Equatable {
    /// Entitlement current, enforcement operates normally.
    case active
    /// Apple's own App Store Billing Grace Period. The configured V1 length (16 days)
    /// is an App Store Connect setting, never a Themis-computed countdown — this type
    /// does not store or derive a days-remaining figure.
    case appleBillingGracePeriod
    /// Payment recovered while still inside the Billing Grace Period. Protection simply
    /// continues; no manual reactivation step is required (§25.6).
    case recovered
    /// The parent explicitly cancelled. Service remains fully active until the existing
    /// paid-through date — cancelling does not immediately degrade paid-for service.
    case cancelledPaidThrough
    /// Entitlement has lapsed: the Billing Grace Period expired without recovery, or a
    /// voluntary cancellation's paid-through date passed. Themis-managed restrictions
    /// are actively cleared; rule definitions are retained, never deleted.
    case protectionExpired
    /// The household resubscribed after `protectionExpired`. Payment is active again,
    /// but protection does NOT automatically restart (§25.6) — see `ReactivationReviewStep`.
    case resubscribed

    /// Valid next states for the two confirmed paths (§25.2): involuntary billing
    /// failure (`active → appleBillingGracePeriod → recovered | protectionExpired`) and
    /// voluntary cancellation (`active → cancelledPaidThrough → protectionExpired`),
    /// plus explicit resubscription (`protectionExpired → resubscribed → active`).
    /// Informational for this isolated slice's own review/tests only; the future
    /// subscription service is the real source of truth for transitions.
    var allowedNextStates: Set<SubscriptionLifecycleState> {
        switch self {
        case .active: return [.appleBillingGracePeriod, .cancelledPaidThrough]
        case .appleBillingGracePeriod: return [.recovered, .protectionExpired]
        case .recovered: return [.appleBillingGracePeriod, .cancelledPaidThrough]
        case .cancelledPaidThrough: return [.protectionExpired]
        case .protectionExpired: return [.resubscribed]
        case .resubscribed: return [.active]
        }
    }
}

/// Whether Themis-managed restrictions are actually enforced on the child's device.
/// Deliberately binary plus one transient step — there is no partial/reduced-enforcement
/// subscription tier (§25.2a, closes OQ-39).
enum DeviceProtectionState: String, CaseIterable, Sendable, Equatable {
    /// Full enforcement — identical during `.active` and `.appleBillingGracePeriod`.
    case enforcing
    /// Themis-managed restrictions have been actively cleared from the device.
    case cleared
    /// The parent confirmed reactivation and it has been sent, but the child device has
    /// not yet acknowledged the plan is applied. Never described as "Protection active".
    case reactivationSent
}

/// The explicit resubscription review flow required before protection may resume after
/// `protectionExpired` (§25.6). Never skipped, never silently automatic.
enum ReactivationReviewStep: String, CaseIterable, Sendable, Equatable {
    /// "Ready to turn protection back on?" — B-005.
    case awaitingReview
    /// The parent is reviewing retained rule definitions — B-006.
    case reviewingRetainedRules
    /// The parent confirmed; reactivation has been sent to the device — B-007.
    case sent
    /// The child device acknowledged the plan is applied — B-008.
    case acknowledgedOnDevice
}

/// Pure mapping from lifecycle (+ reactivation step where relevant) to the two states a
/// parent must never confuse. Kept separate from any single view so it can be unit
/// tested directly, independent of presentation copy.
enum SubscriptionStateMachine {
    /// Whether the App Store entitlement is currently considered paid/active.
    static func isPaymentActive(_ lifecycle: SubscriptionLifecycleState) -> Bool {
        switch lifecycle {
        case .active, .appleBillingGracePeriod, .recovered, .cancelledPaidThrough, .resubscribed:
            return true
        case .protectionExpired:
            return false
        }
    }

    /// The device protection state for a given lifecycle state and (only meaningful
    /// after `.resubscribed`) reactivation step.
    static func protectionState(
        for lifecycle: SubscriptionLifecycleState,
        reactivationStep: ReactivationReviewStep? = nil
    ) -> DeviceProtectionState {
        switch lifecycle {
        case .active, .appleBillingGracePeriod, .recovered, .cancelledPaidThrough:
            return .enforcing
        case .protectionExpired:
            return .cleared
        case .resubscribed:
            switch reactivationStep {
            case nil, .awaitingReview, .reviewingRetainedRules:
                return .cleared
            case .sent:
                return .reactivationSent
            case .acknowledgedOnDevice:
                return .enforcing
            }
        }
    }
}

/// B-001 … B-008, one case per screen (B-002 covers both the Active and
/// Cancelled/paid-through presentation via `SubscriptionPresentation.lifecycle`).
enum SubscriptionScreen: String, CaseIterable, Sendable, Identifiable {
    case offer = "B-001"
    case manage = "B-002"
    case billingGraceWarning = "B-003"
    case protectionExpiredNotice = "B-004"
    case readyToReactivate = "B-005"
    case reviewRetainedRules = "B-006"
    case reactivationSent = "B-007"
    case protectionActiveOnDevice = "B-008"

    var id: String { rawValue }
}

/// One retained rule definition shown for parent review (B-006). Definitions are never
/// deleted when protection is cleared — only enforcement pauses.
struct RetainedRule: Identifiable, Sendable, Equatable {
    let id: String
    let childName: String
    let title: String
    let detail: String
}

/// Everything one Subscription screen needs to render, with no App Store transaction
/// object and no production entitlement logic — a future subscription service supplies
/// the equivalent real data.
struct SubscriptionPresentation: Sendable, Equatable {
    let screen: SubscriptionScreen
    let lifecycle: SubscriptionLifecycleState
    let protection: DeviceProtectionState
    let reactivationStep: ReactivationReviewStep?

    /// Paid-through date for the voluntary-cancellation copy ("Protection stays active
    /// until …"). `nil` unless `lifecycle == .cancelledPaidThrough`.
    let paidThroughDate: Date?

    /// An EXAMPLE entitlement/grace date for deterministic UI review only. Never a
    /// Themis-computed countdown; a future subscription service supplies the real date.
    let exampleEntitlementDate: Date?

    /// Rule definitions retained for parent review after `protectionExpired` (§25.6).
    /// Non-empty whenever `lifecycle` is `.protectionExpired` or `.resubscribed`.
    let retainedRules: [RetainedRule]

    /// Whether the parent has explicitly confirmed reactivation in this presentation
    /// (B-006 → B-007 transition gate). Never implied automatically.
    let reactivationAcknowledged: Bool
}
