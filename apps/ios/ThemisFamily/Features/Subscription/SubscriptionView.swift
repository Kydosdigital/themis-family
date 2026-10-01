import SwiftUI

/// UI-12 entry view. Embeddable: no NavigationStack of its own.
struct SubscriptionView: View {
    let initialPhase: SubscriptionPhase
    @StateObject private var viewModel: SubscriptionViewModel

    init(phase: SubscriptionPhase = .active, repository: any SubscriptionRepository = MockSubscriptionRepository()) {
        initialPhase = phase
        _viewModel = StateObject(wrappedValue: SubscriptionViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if let state = viewModel.state {
                SubscriptionStateView(
                    content: SubscriptionContentFactory.content(for: state),
                    rules: state.retainedRules,
                    primaryAction: { handlePrimary(state.phase) }
                )
            } else {
                LoadingStateView(label: "Loading subscription")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .themisGround(.plain)
            }
        }
        .task(id: initialPhase) { await viewModel.load(phase: initialPhase) }
    }

    private func handlePrimary(_ phase: SubscriptionPhase) {
        switch phase {
        case .resubscribedAwaitingReview: viewModel.send(.parentStartedReview)
        case .reactivationReady: viewModel.send(.parentConfirmedReactivation)
        default: break // Payment and App Store management are inert in this slice.
        }
    }
}
