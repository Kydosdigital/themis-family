import Foundation

/// UI-12 Subscription view model. Presentation-only: no StoreKit, no purchasing, no
/// restore, no network calls. `confirmReactivation()` is an inert, local callback used
/// by B-006's "Turn protection back on" action in previews/review only.
@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published private(set) var presentation: SubscriptionPresentation?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any SubscriptionRepository

    init(repository: any SubscriptionRepository = MockSubscriptionRepository()) {
        self.repository = repository
    }

    func load(scenario: SubscriptionDemoScenario) async {
        isLoading = true
        errorMessage = nil

        do {
            presentation = try await repository.presentation(for: scenario)
        } catch {
            errorMessage = "We couldn't load your subscription right now."
        }

        isLoading = false
    }
}
