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
/// `protectionExpired` (§25.6). Never skipped, never silently automatic. Confirmed
/// sequence: `awaitingReview` (B-005) → `reviewingRetainedRules` (B-006) →
/// `confirming` (B-006 · Confirm) → `sent` (B-007) → `acknowledgedOnDevice` (B-008).
/// `deferred` (B-005 · Not now) is the one alternate branch: it returns to
/// `awaitingReview` without ever touching B-006/B-007/B-008.
enum ReactivationReviewStep: String, CaseIterable, Sendable, Equatable {
    /// "Ready to turn protection back on?" — B-005.
    case awaitingReview
    /// The parent chose "Not now" — B-005 · Not now. Payment stays active, protection
    /// stays cleared, rules stay retained; nothing advances automatically.
    case deferred
    /// The parent is reviewing retained rule definitions — B-006.
    case reviewingRetainedRules
    /// The parent is confirming reactivation before anything is sent — B-006 · Confirm.
    /// Confirming here does NOT mean protection is active yet.
    case confirming
    /// The parent confirmed; reactivation has been sent to the device — B-007. Not
    /// active on the device until it acknowledges.
    case sent
    /// The child device acknowledged the plan is applied — B-008.
    case acknowledgedOnDevice

    /// Valid next steps in the confirmed sequence. Used by this isolated slice's own
    /// tests to prove B-007 (`sent`) can never be reached except via `confirming`.
    var allowedNextSteps: Set<ReactivationReviewStep> {
        switch self {
        case .awaitingReview: return [.reviewingRetainedRules, .deferred]
        case .deferred: return [.awaitingReview]
        case .reviewingRetainedRules: return [.confirming]
        case .confirming: return [.sent]
        case .sent: return [.acknowledgedOnDevice]
        case .acknowledgedOnDevice: return []
        }
    }
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

    /// `nil` (B-001, before any entitlement exists) never implies an active entitlement.
    static func isPaymentActive(_ lifecycle: SubscriptionLifecycleState?) -> Bool {
        guard let lifecycle else { return false }
        return isPaymentActive(lifecycle)
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
            case nil, .awaitingReview, .deferred, .reviewingRetainedRules, .confirming:
                return .cleared
            case .sent:
                return .reactivationSent
            case .acknowledgedOnDevice:
                return .enforcing
            }
        }
    }

    /// Whether advancing from `step` (`nil` meaning no reactivation flow started yet)
    /// to `next` is a valid move in the confirmed B-005 → B-006 → B-006 · Confirm →
    /// B-007 → B-008 sequence. Proves B-007 (`sent`) can only follow `confirming` —
    /// never reachable directly from `reviewingRetainedRules` or `awaitingReview`.
    static func canAdvance(from step: ReactivationReviewStep?, to next: ReactivationReviewStep) -> Bool {
        guard let step else { return next == .awaitingReview }
        return step.allowedNextSteps.contains(next)
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

/// One managed child's protection evidence shown on B-003 (Billing Grace), proving the
/// billing problem has NOT reduced their protection. Deliberately carries no billing
/// detail and no Themis-computed countdown — only the same "Last verified …" evidence
/// style already used elsewhere (e.g. `ChildStatusRow`).
struct ChildProtectionDuringBilling: Identifiable, Sendable, Equatable {
    let id: String
    /// e.g. "Sam · Child" / "Maya · Teen" — matches the existing row title convention.
    let title: String
    let lastVerifiedText: String
}

/// One managed device's acknowledgement shown on B-008, once `reactivationStep ==
/// .acknowledgedOnDevice`. Deterministic UI demo data only — no backend acknowledgement
/// API, no networking, no real device communication is modelled here.
struct DeviceProtectionAcknowledgement: Identifiable, Sendable, Equatable {
    let id: String
    let deviceName: String
    let confirmedAtText: String
}

/// Everything one Subscription screen needs to render, with no App Store transaction
/// object and no production entitlement logic — a future subscription service supplies
/// the equivalent real data.
///
/// `lifecycle` and `protection` are optional because B-001 (the pre-subscription
/// trial/offer screen) has neither an entitlement nor a device protection state yet —
/// `nil` here must never be defaulted to `.active`/`.enforcing`. Every other screen
/// (B-002 onward) always supplies both, since by then a subscription exists.
struct SubscriptionPresentation: Sendable, Equatable {
    let screen: SubscriptionScreen
    let lifecycle: SubscriptionLifecycleState?
    let protection: DeviceProtectionState?
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

    /// Managed children's protection evidence shown on B-003 only, to visually reinforce
    /// that a billing problem never reduces protection. Empty on every other screen.
    let billingProtectedChildren: [ChildProtectionDuringBilling]

    /// Per-device acknowledgement rows shown on B-008 only, once every managed device
    /// has confirmed the reactivated rules are applied. Empty on every other screen.
    let deviceAcknowledgements: [DeviceProtectionAcknowledgement]

    /// Whether the PARENT has explicitly confirmed reactivation (the B-006 · Confirm →
    /// B-007 transition gate). Deliberately not named "acknowledged": that word is
    /// reserved for the separate, later CHILD-DEVICE acknowledgement event
    /// (`protection == .enforcing` after `reactivationStep == .acknowledgedOnDevice`).
    /// True on B-007 even though the device has not acknowledged anything yet.
    let reactivationConfirmedByParent: Bool
}
