import SwiftUI

// MARK: - UI-13 Edge States · View model
//
// Thin, deterministic loader. No retry timers, no background work, no real
// networking — this only exists to mirror the `@StateObject` + repository
// pattern used by the other features (e.g. `ParentHomeViewModel`) so these
// presentations can later be adopted into the real feature view models.

@MainActor
final class EdgeStateViewModel: ObservableObject {
    @Published private(set) var presentation: EdgeStatePresentation?

    private let repository: any EdgeStateRepository

    init(repository: any EdgeStateRepository = DemoEdgeStateRepository()) {
        self.repository = repository
    }

    func load(scenario: EdgeStateScenario) async {
        presentation = await repository.presentation(for: scenario)
    }
}
