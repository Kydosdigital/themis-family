import XCTest
@testable import ThemisFamily

final class ChildTeenHomeStateTests: XCTestCase {
    func testSamCanonicalStateUsesChildAudienceAndApprovedHomeworkFacts() throws {
        let state = ChildTeenHomeDemoData.sam
        XCTAssertEqual(state.screenID, "C-001")
        XCTAssertEqual(state.audience, .child)
        XCTAssertEqual(state.firstName, "Sam")
        XCTAssertEqual(state.transparencyLinkTitle, "What can my parent or carer see?")
        XCTAssertEqual(state.activeStatus, .active)

        guard case let .childHomework(homework) = state.content else {
            return XCTFail("Sam canonical state must use the Child homework presentation")
        }

        XCTAssertEqual(homework.sectionTitle, "Homework")
        XCTAssertEqual(homework.status, .due)
        XCTAssertEqual(homework.dueText, "Due at 6:00 PM")
        XCTAssertEqual(homework.consequence, "If it isn’t done by 6:00 PM, Roblox and Minecraft pause.")
        XCTAssertEqual(homework.primaryActionTitle, "I’ve finished my homework")
        XCTAssertEqual(homework.secondaryActionTitle, "Ask for more time")
        XCTAssertEqual(homework.timeline.ticks, ["4 PM", "6", "8 PM"])
    }

    func testMayaCanonicalStateUsesTeenAudienceAndApprovedScheduleAndFocusContent() throws {
        let state = ChildTeenHomeDemoData.maya
        XCTAssertEqual(state.screenID, "C-001 · Teen")
        XCTAssertEqual(state.audience, .teen)
        XCTAssertEqual(state.dayLabel, "Tuesday")
        XCTAssertEqual(state.firstName, "Maya")
        XCTAssertEqual(state.transparencyLinkTitle, "What your parent or carer can see")
        XCTAssertEqual(state.activeStatus, .active)

        guard case let .teen(teen) = state.content else {
            return XCTFail("Maya canonical state must use the Teen presentation")
        }

        XCTAssertEqual(teen.nowSectionTitle, "Now")
        XCTAssertEqual(teen.scheduleTitle, "Social apps")
        XCTAssertEqual(teen.scheduleSummary, "Pause 10:00 PM–7:00 AM")
        XCTAssertEqual(teen.scheduleStatus.label, "Tonight")
        XCTAssertEqual(teen.todaySectionTitle, "Today")
        XCTAssertEqual(teen.focusTitle, "Focus Session")
        XCTAssertEqual(teen.focusSummary, "30 min away from distracting apps")
        XCTAssertEqual(teen.startActionTitle, "Start")
        XCTAssertEqual(teen.requestActionTitle, "Request more time")
        XCTAssertEqual(teen.eveningTimeline.ticks, ["8 PM", "10", "12 AM"])
    }

    func testChildAndTeenTabsRemainTheApprovedThreeTabs() {
        XCTAssertEqual(ChildTab.allCases.map(\.title), ["Home", "My Rules", "Requests"])
        XCTAssertEqual(ChildTab.allCases.count, 3)
    }

    func testChildTransparencyStaysInsideApprovedPrivacyBoundary() {
        let state = ChildTeenHomeDemoData.childTransparency
        XCTAssertEqual(state.screenID, "C-013")
        XCTAssertEqual(
            state.visibleFacts,
            [
                "Your Themis rules",
                "If homework was done",
                "Your requests and answers",
                "Extra time they gave you",
                "If Themis is working",
                "Some Screen Time information Apple makes available where supported"
            ]
        )
        XCTAssertTrue(state.privateFacts.contains("Your messages or chats"))
        XCTAssertTrue(state.privateFacts.contains("Everything you search or visit"))
        XCTAssertTrue(state.privateFacts.contains("A minute-by-minute activity list"))
        XCTAssertFalse(state.exposesMessageContent)
        XCTAssertFalse(state.exposesFullBrowsingHistory)
        XCTAssertFalse(state.exposesMinuteByMinuteActivity)
        XCTAssertFalse(state.modelsRawScreenTimeAsStoredByThemis)
    }

    func testTeenTransparencyStaysInsideApprovedPrivacyBoundary() {
        let state = ChildTeenHomeDemoData.teenTransparency
        XCTAssertEqual(state.screenID, "C-013 · Teen")
        XCTAssertEqual(
            state.visibleFacts,
            [
                "Rules and task outcomes",
                "Requests and decisions",
                "Temporary access",
                "Device protection status",
                "Screen Time reports Apple provides where available"
            ]
        )
        XCTAssertTrue(state.privateFacts.contains("Message or chat content"))
        XCTAssertTrue(state.privateFacts.contains("Full browsing or search history"))
        XCTAssertTrue(state.privateFacts.contains("Minute-by-minute activity"))
        XCTAssertTrue(state.privateFacts.contains("Apple raw Screen Time data"))
        XCTAssertFalse(state.exposesMessageContent)
        XCTAssertFalse(state.exposesFullBrowsingHistory)
        XCTAssertFalse(state.exposesMinuteByMinuteActivity)
        XCTAssertFalse(state.modelsRawScreenTimeAsStoredByThemis)
    }

    func testEssentialAccessCopyDoesNotGuaranteeAppleDependentApps() {
        for state in [
            ChildTeenHomeDemoData.childEssentialAccess,
            ChildTeenHomeDemoData.teenEssentialAccess
        ] {
            XCTAssertFalse(state.guaranteesPhoneMessagesOrMaps, state.screenID)
            XCTAssertTrue(state.saysEmergencyCallingIsNeverDeliberatelyRestricted, state.screenID)
            XCTAssertTrue(state.facts.joined(separator: " ").localizedCaseInsensitiveContains("where supported"), state.screenID)
        }
    }

    func testTimelineSemanticDataSurvivesAccessibilityFallback() throws {
        guard case let .childHomework(homework) = ChildTeenHomeDemoData.sam.content else {
            return XCTFail("Expected Sam homework state")
        }
        XCTAssertEqual(
            homework.timeline.stackedRows.map(\.title),
            ["Now", "Homework", "Games pause if not approved"]
        )
        XCTAssertEqual(homework.timeline.stackedRows[1].detail, "4 PM – 6 PM")
        XCTAssertEqual(homework.timeline.stackedRows[2].detail, "From 6 PM · only if it applies")

        guard case let .teen(teen) = ChildTeenHomeDemoData.maya.content else {
            return XCTFail("Expected Maya Teen state")
        }
        XCTAssertEqual(teen.eveningTimeline.stackedRows.map(\.title), ["Now", "Social apps pause"])
        XCTAssertEqual(teen.eveningTimeline.stackedRows[1].detail, "From 10 PM")
    }

    func testLegacyLaterSliceScenariosRemainAvailable() {
        let overdue = DemoData.childHome(childID: DemoData.samID, scenario: .homeworkOverdue)
        let freePass = DemoData.childHome(childID: DemoData.samID, scenario: .freePassActive)
        let request = DemoData.childHome(childID: DemoData.samID, scenario: .requestDeclined)

        XCTAssertEqual(overdue.task?.state, .overdueRestricted)
        XCTAssertNotNil(freePass.freePassSummary)
        XCTAssertNotNil(request.requestStatusSummary)
    }

    @MainActor
    func testViewModelLoadsCanonicalChildAndTeenStates() async {
        let repository = MockChildHomeRepository()

        let samViewModel = ChildHomeViewModel(repository: repository)
        await samViewModel.load(childID: DemoData.samID, scenario: .normal)
        XCTAssertEqual(samViewModel.state, ChildTeenHomeDemoData.sam)
        XCTAssertNil(samViewModel.errorMessage)

        let mayaViewModel = ChildHomeViewModel(repository: repository)
        await mayaViewModel.load(childID: DemoData.mayaID, scenario: .normal)
        XCTAssertEqual(mayaViewModel.state, ChildTeenHomeDemoData.maya)
        XCTAssertNil(mayaViewModel.errorMessage)
    }
}
