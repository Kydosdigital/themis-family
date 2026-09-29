import Foundation

@MainActor
final class AppContainer: ObservableObject {
    enum Perspective: String, CaseIterable, Identifiable {
        case parent = "Parent"
        case child = "Sam · Child"
        case teen = "Maya · Teen"

        var id: String { rawValue }
    }

    let parentRepository: any ParentDashboardRepository
    let childRepository: any ChildHomeRepository

    @Published var scenario: DemoScenario
    @Published var perspective: Perspective

    init(
        parentRepository: any ParentDashboardRepository,
        childRepository: any ChildHomeRepository,
        scenario: DemoScenario = .normal,
        perspective: Perspective = .parent
    ) {
        self.parentRepository = parentRepository
        self.childRepository = childRepository
        self.scenario = scenario
        self.perspective = perspective
    }

    static func preview() -> AppContainer {
        AppContainer(
            parentRepository: MockParentDashboardRepository(),
            childRepository: MockChildHomeRepository()
        )
    }
}
