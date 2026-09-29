import Foundation

protocol ParentDashboardRepository: Sendable {
    func dashboard(for scenario: DemoScenario) async throws -> ParentDashboardData

    /// P-023 Parent Home presentation state.
    func parentHome(for scenario: DemoScenario) async throws -> ParentHomeState
}
