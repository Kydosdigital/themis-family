import XCTest
@testable import ThemisFamily

final class FreePassTests: XCTestCase {
    func testCannotConfirmWithoutExplicitChild() {
        var draft = FreePassDraft()
        draft.apply(.games30)
        XCTAssertFalse(draft.canConfirm(role: .owner))
    }

    func testCannotConfirmWithoutExplicitScope() {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.durationMinutes = 30
        XCTAssertFalse(draft.canConfirm(role: .owner))
    }

    func testCannotConfirmWithoutExplicitDuration() {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.targets = [FreePassTargets.games]
        XCTAssertFalse(draft.canConfirm(role: .owner))
    }

    func testPresetResolvesToExplicitScopeAndDuration() {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.apply(.games30)

        XCTAssertEqual(draft.targets, [FreePassTargets.games])
        XCTAssertEqual(draft.durationMinutes, 30)
        XCTAssertTrue(draft.hasExplicitScope)
        XCTAssertTrue(draft.hasExplicitDuration)
    }

    func testCustomSelectionBuildsGrant() {
        let grant = FreePassDemoData.customDraft.makeGrant(
            role: .guardian,
            startsAt: FreePassDemoData.start,
            endLabel: "9:00 PM",
            overriddenRules: [FreePassDemoData.bedtime],
            scheduledRules: []
        )

        XCTAssertEqual(grant?.scopeText, "Roblox")
        XCTAssertEqual(grant?.durationMinutes, 45)
    }

    func testOverridePreviewNamesCurrentlyActiveRules() {
        let active = FreePassDemoData.active
        XCTAssertTrue(active.overriddenRules.contains(where: {
            $0.ruleName == "Bedtime" && $0.isActiveNow
        }))
    }

    func testScheduledRuleBeginningDuringPassIsDisclosed() {
        let active = FreePassDemoData.active
        XCTAssertTrue(active.hasScheduledRuleBeginningDuringPass)
        XCTAssertTrue(active.scheduledRules.contains(where: {
            $0.ruleName == "Study wind-down" && $0.beginsDuringPass
        }))
    }

    func testGrantHasExplicitThirtyMinuteExpiry() {
        let active = FreePassDemoData.active
        XCTAssertEqual(active.expiresAt.timeIntervalSince(active.startsAt), 30 * 60, accuracy: 0.001)
    }

    func testExpiryIsLocalAndNeedsNoSecondParentAction() {
        XCTAssertTrue(FreePassPolicy.expiryIsLocal)
        XCTAssertFalse(FreePassPolicy.expiryRequiresNetwork)
        XCTAssertFalse(FreePassPolicy.expiryRequiresSecondParentAction)

        let expired = FreePassDemoData.active.expiring(
            at: FreePassDemoData.active.expiresAt.addingTimeInterval(1)
        )
        XCTAssertEqual(expired.lifecycle, .expired)
        XCTAssertEqual(expired.deviceApplication, .expired)
    }

    func testOwnerAndGuardianMayGrantButChildAndTeenMayNot() {
        let draft = FreePassDemoData.canonicalDraft
        XCTAssertTrue(draft.canConfirm(role: .owner))
        XCTAssertTrue(draft.canConfirm(role: .guardian))
        XCTAssertFalse(draft.canConfirm(role: .child))
        XCTAssertFalse(draft.canConfirm(role: .teen))
    }

    func testRevocationSentAndAccessRevokedRemainDistinct() {
        let sent = FreePassDemoData.active.revoking(by: .owner, deviceAcknowledged: false)
        XCTAssertEqual(sent.lifecycle, .revocationSent)
        XCTAssertEqual(sent.deviceApplication, .revocationPending)
        XCTAssertEqual(sent.status.label, "Revocation sent")
        XCTAssertNotEqual(sent.status.label, "Access revoked")

        let acknowledged = sent.acknowledgingRevocation()
        XCTAssertEqual(acknowledged.lifecycle, .revoked)
        XCTAssertEqual(acknowledged.deviceApplication, .revoked)
        XCTAssertEqual(acknowledged.status.label, "Access revoked")
    }

    func testAccessRevokedCannotBeClaimedBeforeDeviceAcknowledgement() {
        let sent = FreePassDemoData.revocationSent
        XCTAssertEqual(sent.status.label, "Revocation sent")
        XCTAssertTrue(sent.message.localizedCaseInsensitiveContains("waiting"))
        XCTAssertFalse(sent.lifecycle == .revoked)
    }

    func testChildAndTeenCannotRevoke() {
        XCTAssertEqual(
            FreePassDemoData.active.revoking(by: .child, deviceAcknowledged: false),
            FreePassDemoData.active
        )
        XCTAssertEqual(
            FreePassDemoData.active.revoking(by: .teen, deviceAcknowledged: true),
            FreePassDemoData.active
        )
    }

    func testAnotherRestrictionPreventsFalseAvailabilityClaim() {
        XCTAssertTrue(FreePassDemoData.active.mayClaimSelectedTargetsAvailable)
        XCTAssertFalse(FreePassDemoData.activeWithAnotherRestriction.mayClaimSelectedTargetsAvailable)
    }

    func testAlwaysAllowedTargetCannotEnterFreePassScope() {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.chooseCustom(targets: [FreePassTargets.phone], durationMinutes: 30)

        XCTAssertFalse(draft.hasExplicitScope)
        XCTAssertNil(draft.makeGrant(
            role: .owner,
            startsAt: FreePassDemoData.start,
            endLabel: "8:45 PM",
            overriddenRules: [],
            scheduledRules: []
        ))
    }

    func testEmergencyCommunicationCannotEnterFreePassScope() {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.chooseCustom(targets: [FreePassTargets.messages], durationMinutes: 30)

        XCTAssertTrue(FreePassTargets.messages.isEmergencyCommunication)
        XCTAssertFalse(draft.canConfirm(role: .owner))
    }
}
