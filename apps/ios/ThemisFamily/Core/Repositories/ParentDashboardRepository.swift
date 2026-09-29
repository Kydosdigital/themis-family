import Foundation

protocol ParentDashboardRepository: Sendable {
    func dashboard(for scenario: DemoScenario) async throws -> ParentDashboardData
}
