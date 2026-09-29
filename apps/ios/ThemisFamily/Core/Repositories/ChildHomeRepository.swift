import Foundation

protocol ChildHomeRepository: Sendable {
    func home(childID: UUID, scenario: DemoScenario) async throws -> ChildHomeData
}
