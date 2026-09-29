import Foundation

struct MockParentDashboardRepository: ParentDashboardRepository {
    func dashboard(for scenario: DemoScenario) async throws -> ParentDashboardData {
        DemoData.dashboard(for: scenario)
    }
}

struct MockChildHomeRepository: ChildHomeRepository {
    func home(childID: UUID, scenario: DemoScenario) async throws -> ChildHomeData {
        DemoData.childHome(childID: childID, scenario: scenario)
    }
}
