import SwiftUI

/// UI-12 Subscription container (B-001…B-008). Routes to the screen named by the loaded
/// presentation. Production call sites embed this view directly — it does not assume a
/// nested `NavigationStack`; one is only added for the standalone previews below.
struct SubscriptionView: View {
    @StateObject private var viewModel: SubscriptionViewModel
    private let scenario: SubscriptionDemoScenario

    init(
        scenario: SubscriptionDemoScenario = .offer,
        repository: any SubscriptionRepository = MockSubscriptionRepository()
    ) {
        self.scenario = scenario
        _viewModel = StateObject(wrappedValue: SubscriptionViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if let presentation = viewModel.presentation {
                content(for: presentation)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(title: "Couldn't load subscription", message: errorMessage) {
                    Task { await viewModel.load(scenario: scenario) }
                }
                .padding(ThemisSpacing.screen)
            } else {
                LoadingStateView(label: "Loading subscription")
            }
        }
        .themisAudience(.parent)
        .themisGround(.plain)
        .task(id: scenario) {
            await viewModel.load(scenario: scenario)
        }
    }

    @ViewBuilder
    private func content(for presentation: SubscriptionPresentation) -> some View {
        switch presentation.screen {
        case .offer:
            SubscriptionOfferView(onContinue: {})
        case .manage:
            SubscriptionManageView(presentation: presentation, onManageInAppStore: {})
        case .billingGraceWarning:
            SubscriptionBillingGraceView(onUpdatePaymentMethod: {})
        case .protectionExpiredNotice:
            SubscriptionProtectionExpiredView(onContinue: {})
        case .readyToReactivate:
            SubscriptionReadyToReactivateView(
                isDeferred: presentation.reactivationStep == .deferred,
                onReviewRules: {},
                onNotNow: {}
            )
        case .reviewRetainedRules:
            if presentation.reactivationStep == .confirming {
                SubscriptionReviewConfirmView(onConfirm: {}, onCancel: {})
            } else {
                SubscriptionReviewRulesView(rules: presentation.retainedRules, onTurnProtectionBackOn: {})
            }
        case .reactivationSent:
            SubscriptionReactivationSentView()
        case .protectionActiveOnDevice:
            SubscriptionProtectionActiveView()
        }
    }
}

#Preview("B-001 · Subscription offer") {
    NavigationStack {
        SubscriptionView(scenario: .offer)
    }
}

#Preview("B-002 · Active subscription") {
    NavigationStack {
        SubscriptionView(scenario: .manageActive)
    }
}

#Preview("B-002 · Cancelled, paid-through") {
    NavigationStack {
        SubscriptionView(scenario: .manageCancelledPaidThrough)
    }
}

#Preview("B-003 · Apple Billing Grace Period") {
    NavigationStack {
        SubscriptionView(scenario: .billingGrace)
    }
}

#Preview("B-003 · Billing Grace, accessibility3") {
    NavigationStack {
        SubscriptionView(scenario: .billingGrace)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("B-004 · Protection Expired") {
    NavigationStack {
        SubscriptionView(scenario: .protectionExpired)
    }
}

#Preview("B-004 · Protection Expired, accessibility3") {
    NavigationStack {
        SubscriptionView(scenario: .protectionExpired)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("B-005 · Resubscribed") {
    NavigationStack {
        SubscriptionView(scenario: .readyToReactivate)
    }
}

#Preview("B-005 · Not now") {
    NavigationStack {
        SubscriptionView(scenario: .readyToReactivateNotNow)
    }
}

#Preview("B-005 · Not now, accessibility3") {
    NavigationStack {
        SubscriptionView(scenario: .readyToReactivateNotNow)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("B-006 · Review rules") {
    NavigationStack {
        SubscriptionView(scenario: .reviewRetainedRules)
    }
}

#Preview("B-006 · Review rules, accessibility3") {
    NavigationStack {
        SubscriptionView(scenario: .reviewRetainedRules)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("B-006 · Confirm") {
    NavigationStack {
        SubscriptionView(scenario: .reviewConfirmReactivation)
    }
}

#Preview("B-006 · Confirm, accessibility3") {
    NavigationStack {
        SubscriptionView(scenario: .reviewConfirmReactivation)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("B-007 · Reactivation sent") {
    NavigationStack {
        SubscriptionView(scenario: .reactivationSent)
    }
}

#Preview("B-008 · Protection active on device") {
    NavigationStack {
        SubscriptionView(scenario: .protectionActiveOnDevice)
    }
}
