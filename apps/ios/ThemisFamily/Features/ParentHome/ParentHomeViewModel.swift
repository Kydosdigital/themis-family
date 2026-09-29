import Foundation

@MainActor
final class ParentHomeViewModel: ObservableObject {
    @Published private(set) var state: ParentHomeState?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any ParentDashboardRepository

    init(repository: any ParentDashboardRepository) {
        self.repository = repository
    }

    func load(scenario: DemoScenario) async {
        isLoading = true
        errorMessage = nil

        do {
            state = try await repository.parentHome(for: scenario)
        } catch {
            errorMessage = "We couldn’t load your family right now."
        }

        isLoading = false
    }
}
