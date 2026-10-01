import SwiftUI

@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published private(set) var state: SubscriptionPresentationState?
    private let repository: any SubscriptionRepository

    init(repository: any SubscriptionRepository = MockSubscriptionRepository()) {
        self.repository = repository
    }

    func load(phase: SubscriptionPhase) async {
        state = await repository.state(for: phase)
    }

    /// Applies a confirmed transition; ignores events that are not valid for the phase.
    func send(_ event: SubscriptionEvent) {
        guard var current = state, let next = current.phase.applying(event) else { return }
        current.phase = next
        state = current
    }
}
