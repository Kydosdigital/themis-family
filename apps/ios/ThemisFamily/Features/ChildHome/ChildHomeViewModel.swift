import Foundation

@MainActor
final class ChildHomeViewModel: ObservableObject {
    @Published private(set) var home: ChildHomeData?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any ChildHomeRepository

    init(repository: any ChildHomeRepository) {
        self.repository = repository
    }

    func load(childID: UUID, scenario: DemoScenario) async {
        isLoading = true
        errorMessage = nil

        do {
            home = try await repository.home(childID: childID, scenario: scenario)
        } catch {
            errorMessage = "We couldn’t load Themis right now."
        }

        isLoading = false
    }
}
