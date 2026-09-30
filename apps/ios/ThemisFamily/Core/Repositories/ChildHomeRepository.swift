import Foundation

protocol ChildHomeRepository: Sendable {
    /// Legacy/later-slice demo data retained for C-002 through C-011 and request/Free Pass scenarios.
    func home(childID: UUID, scenario: DemoScenario) async throws -> ChildHomeData

    /// UI-03 presentation state for the approved C-001/C-012/C-013/C-014 screens.
    func homeState(childID: UUID, scenario: DemoScenario) async throws -> ChildTeenHomeState
}
