import XCTest
@testable import ThemisFamily

final class ParentHomeStateTests: XCTestCase {
    func testCanonicalFollowsApprovedPriorityOrder() {
        let state = ParentHomeDemoData.canonical()
        XCTAssertEqual(state.sections, [.attention, .children, .agreements, .quickActions])
    }

    func testCanonicalRepresentsTheApprovedExample() throws {
        let state = ParentHomeDemoData.canonical()
        XCTAssertEqual(state.parentName, "Sarah")
        XCTAssertEqual(state.children.map(\.title), ["Sam · Child", "Maya · Teen"])

        guard case let .needsYou(needsYou) = state.attention else {
            return XCTFail("Canonical Parent Home must lead with Needs You")
        }
        XCTAssertEqual(needsYou.primary.title, "Sam sent homework for review")
        XCTAssertEqual(needsYou.primary.actionTitle, "Review")
        let grace = try XCTUnwrap(needsYou.primary.grace)
        XCTAssertEqual(grace.minutesRemaining, 18)
        XCTAssertEqual(grace.remainingText, "18 min")
        XCTAssertEqual(needsYou.others.map(\.title), ["Maya asked for 15 more min"])
        XCTAssertEqual(needsYou.others.first?.status, .pending)
        XCTAssertEqual(needsYou.count, 2)
        XCTAssertEqual(state.actionCentreCount, 2)

        let sam = try XCTUnwrap(state.children.first { $0.firstName == "Sam" })
        let maya = try XCTUnwrap(state.children.first { $0.firstName == "Maya" })
        XCTAssertEqual(sam.status, .protected)
        XCTAssertEqual(sam.evidenceText, "Verified 2 min ago")
        XCTAssertEqual(maya.status, .syncPending)
        XCTAssertEqual(maya.evidenceText, "Verified 14 min ago")
    }

    func testGraceUsesTheThirtyMinuteWindow() {
        // DEC-40: 30-minute Provisional Approval Grace Period. 18 min left = 40% used.
        let grace = ApprovalGraceWindow(minutesRemaining: 18)
        XCTAssertEqual(grace.totalMinutes, 30)
        XCTAssertEqual(grace.elapsedFraction, 0.4, accuracy: 0.0001)
        XCTAssertEqual(ApprovalGraceWindow(minutesRemaining: -3).elapsedFraction, 1)
        XCTAssertEqual(ApprovalGraceWindow(minutesRemaining: -3).remainingText, "0 min")
        XCTAssertEqual(ApprovalGraceWindow(minutesRemaining: 45).elapsedFraction, 0)
    }

    func testQuickActionsAreAddRuleAndFreePassOnly() {
        for scenario in DemoScenario.allCases {
            let state = ParentHomeDemoData.state(for: scenario)
            XCTAssertEqual(state.quickActions.map(\.title), ["Add rule", "Free Pass"], "\(scenario)")
            XCTAssertEqual(state.sections.last, .quickActions, "\(scenario)")
        }
        XCTAssertTrue(ParentQuickAction.addRule.isPrimary)
        XCTAssertFalse(ParentQuickAction.freePass.isPrimary)
    }

    func testNothingPendingKeepsProtectionAndAgreementsContext() {
        let state = ParentHomeDemoData.nothingPending
        XCTAssertEqual(state.attention, .nothingPending)
        XCTAssertEqual(state.sections, [.attention, .children, .agreements, .quickActions])
        XCTAssertEqual(state.children.count, 2)
        XCTAssertFalse(state.agreements.isEmpty)
        XCTAssertEqual(state.actionCentreCount, 0)
    }

    func testSetupIncompleteDoesNotEraseAnotherChildsProtection() throws {
        let state = ParentHomeDemoData.setupIncomplete
        guard case let .setupIncomplete(card) = state.attention else {
            return XCTFail("Expected the setup-incomplete card")
        }
        XCTAssertEqual(card.title, "Finish setting up Sam")
        XCTAssertEqual(card.actionTitle, "Finish setup")
        XCTAssertEqual(card.status, .notActiveYet)

        let sam = try XCTUnwrap(state.children.first { $0.firstName == "Sam" })
        let maya = try XCTUnwrap(state.children.first { $0.firstName == "Maya" })
        XCTAssertEqual(sam.protection, .notActiveYet)
        XCTAssertNotEqual(sam.status, .protected)
        XCTAssertEqual(sam.evidenceText, "Protection not active yet")
        XCTAssertEqual(maya.status, .protected)
        XCTAssertEqual(maya.evidenceText, "Verified 3 min ago")
    }

    func testProtectionProblemUsesNeedsAttentionNotProtected() throws {
        let state = ParentHomeDemoData.protectionProblem
        guard case let .protectionProblem(card) = state.attention else {
            return XCTFail("Expected the protection-problem card")
        }
        XCTAssertEqual(card.status, .needsAttention)
        XCTAssertEqual(card.actionTitle, "Fix this")

        let sam = try XCTUnwrap(state.children.first { $0.firstName == "Sam" })
        XCTAssertEqual(sam.protection, .protection(.needsAttention))
        XCTAssertEqual(sam.evidenceText, "Noticed 10 min ago")
        XCTAssertEqual(state.actionCentreCount, 1)
    }

    func testDegradedProtectionScenariosNeverShowProtected() throws {
        let expected: [DemoScenario: ProtectionStatus] = [
            .syncPending: .syncPending,
            .deviceOffline: .deviceOffline,
            .protectionUnavailable: .protectionUnavailable
        ]
        for (scenario, status) in expected {
            let sam = try XCTUnwrap(ParentHomeDemoData.state(for: scenario).children.first { $0.firstName == "Sam" })
            XCTAssertEqual(sam.protection, .protection(status), "\(scenario)")
            XCTAssertNotEqual(sam.status.kind, .protected, "\(scenario)")
        }
    }

    func testEveryProtectedChildCarriesVerifiedEvidence() {
        for scenario in DemoScenario.allCases {
            for child in ParentHomeDemoData.state(for: scenario).children where child.status == .protected {
                guard case .verified = child.evidence else {
                    return XCTFail("\(scenario): \(child.firstName) is Protected without Verified evidence")
                }
            }
        }
    }

    func testEvidenceWording() {
        XCTAssertEqual(ProtectionEvidence.verified(minutesAgo: 0).text, "Verified just now")
        XCTAssertEqual(ProtectionEvidence.verified(minutesAgo: 2).text, "Verified 2 min ago")
        XCTAssertEqual(ProtectionEvidence.verified(minutesAgo: 180).text, "Verified 3 hr ago")
        XCTAssertEqual(ProtectionEvidence.noticed(minutesAgo: 10).text, "Noticed 10 min ago")
    }

    func testNoChildrenStillOffersQuickActionsInOrder() {
        let state = ParentHomeDemoData.state(for: .noChildren)
        XCTAssertEqual(state.attention, .noChildren)
        XCTAssertEqual(state.sections, [.attention, .quickActions])
    }

    @MainActor
    func testViewModelLoadsCanonicalStateFromRepository() async {
        let viewModel = ParentHomeViewModel(repository: MockParentDashboardRepository())
        await viewModel.load(scenario: .normal)
        XCTAssertEqual(viewModel.state, ParentHomeDemoData.canonical())
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
