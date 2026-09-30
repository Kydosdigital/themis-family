import Foundation

struct MockParentDashboardRepository: ParentDashboardRepository {
    func dashboard(for scenario: DemoScenario) async throws -> ParentDashboardData {
        DemoData.dashboard(for: scenario)
    }

    func parentHome(for scenario: DemoScenario) async throws -> ParentHomeState {
        ParentHomeDemoData.state(for: scenario)
    }
}

struct MockChildHomeRepository: ChildHomeRepository {
    func home(childID: UUID, scenario: DemoScenario) async throws -> ChildHomeData {
        DemoData.childHome(childID: childID, scenario: scenario)
    }

    func homeState(childID: UUID, scenario: DemoScenario) async throws -> ChildTeenHomeState {
        ChildTeenHomeDemoData.state(childID: childID, scenario: scenario)
    }
}
