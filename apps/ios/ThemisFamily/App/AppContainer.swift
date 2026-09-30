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

    static func preview(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppContainer {
        AppContainer(
            parentRepository: MockParentDashboardRepository(),
            childRepository: MockChildHomeRepository(),
            perspective: visualReviewPerspective(from: arguments) ?? .parent
        )
    }

    /// Deterministic review-only launch selection for Release Simulator screenshot CI.
    /// Normal app launches omit the flag and continue to start in the Parent perspective.
    static func visualReviewPerspective(from arguments: [String]) -> Perspective? {
        guard let flagIndex = arguments.firstIndex(of: "--visual-review-perspective") else {
            return nil
        }
        let valueIndex = arguments.index(after: flagIndex)
        guard valueIndex < arguments.endIndex else { return nil }

        switch arguments[valueIndex].lowercased() {
        case "parent": return .parent
        case "child": return .child
        case "teen": return .teen
        default: return nil
        }
    }
}
