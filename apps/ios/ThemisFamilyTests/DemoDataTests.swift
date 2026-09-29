import XCTest
@testable import ThemisFamily

final class DemoDataTests: XCTestCase {
    func testNoChildrenScenarioHasNoChildren() {
        let dashboard = DemoData.dashboard(for: .noChildren)
        XCTAssertTrue(dashboard.children.isEmpty)
    }

    func testDeviceOfflineScenarioSurfacesOfflineStatus() {
        let dashboard = DemoData.dashboard(for: .deviceOffline)
        let sam = dashboard.children.first(where: { $0.id == DemoData.samID })

        XCTAssertEqual(sam?.protectionStatus, .deviceOffline)
    }

    func testApprovalGraceScenarioShowsEighteenMinutesInDemo() {
        let home = DemoData.childHome(childID: DemoData.samID, scenario: .approvalGrace)

        guard case let .approvalGrace(minutesRemaining)? = home.task?.state else {
            return XCTFail("Expected approval grace state")
        }

        XCTAssertEqual(minutesRemaining, 18)
    }

    func testMultipleRestrictionsRemainVisibleTogether() {
        let home = DemoData.childHome(childID: DemoData.samID, scenario: .multipleRestrictions)

        XCTAssertEqual(home.activeRestrictionReasons.count, 2)
        XCTAssertTrue(home.activeRestrictionReasons.contains("Games are paused for bedtime."))
        XCTAssertTrue(home.activeRestrictionReasons.contains("Homework is also overdue."))
    }
}
