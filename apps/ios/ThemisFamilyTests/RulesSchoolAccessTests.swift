import XCTest
@testable import ThemisFamily

final class RulesSchoolAccessTests: XCTestCase {
    func testAllV1RuleTypesAreRepresented() {
        XCTAssertEqual(Set(RuleType.allCases), Set([.scheduled, .deadlineLock, .earnFirst]))
    }

    func testGenericDeadlineLockUsesParentApprovalOnly() {
        XCTAssertEqual(RulesSchoolAccessPolicy.allowedVerificationTypes(for: .deadlineLock, isSupportedThemisSession: false), [.parentApproval])
    }

    func testDeadlineLockGraceIsThirtyMinutes() {
        XCTAssertEqual(DeadlineLockConfiguration.approvalGraceMinutes, 30)
    }

    func testEffectiveRestrictionDoesNotFalseUnlock() {
        XCTAssertEqual(RulesSchoolAccessPolicy.effectiveRestriction(activeRestrictionNames: ["School hours"]), .restrictedBy(["School hours"]))
    }

    func testAlwaysAllowedRemovesRestrictiveTargetAndDisclosesChange() {
        let target = RulesSchoolAccessDemoData.roblox
        let result = RulesSchoolAccessPolicy.applyAlwaysAllowed(target: target, to: [RulesSchoolAccessDemoData.deadlineLock], currentAlwaysAllowed: [])
        XCTAssertFalse(result.rules[0].targets.contains(target))
        XCTAssertTrue(result.state.targets.contains(target))
        XCTAssertNotNil(result.state.disclosure)
        XCTAssertFalse(RulesSchoolAccessPolicy.canAddRestrictedTarget(target, alwaysAllowed: result.state.targets))
    }

    func testPendingSyncIsHonest() {
        XCTAssertEqual(RulesSchoolAccessDemoData.pendingSync.syncState, .pendingSync)
    }

    func testSchoolAccessCapabilityCopyIsConservative() {
        XCTAssertTrue(RulesSchoolAccessPolicy.schoolAccessCapabilityMessage.contains("does not classify"))
        XCTAssertTrue(RulesSchoolAccessPolicy.essentialAccessMessage.contains("where supported"))
        XCTAssertTrue(RulesSchoolAccessPolicy.emergencyAccessMessage.contains("never deliberately restricted"))
        XCTAssertTrue(RulesSchoolAccessDemoData.schoolAccess.singleDevicePerChildNote.contains("one managed device per child"))
    }
}
