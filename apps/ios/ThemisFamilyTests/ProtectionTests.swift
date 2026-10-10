import XCTest
@testable import ThemisFamily

final class ProtectionTests: XCTestCase {
    func testUnverifiedProtectedDisplayDegradesAndOffersRecovery() {
        for evidence in [ProtectionEvidence.noticed(minutesAgo: 3), .notActiveYet] {
            let presentation = ProtectionPresentation(
                status: .protected,
                evidence: evidence,
                explanation: "Protection was confirmed",
                restrictionsRemainInEffect: true,
                recoveryAvailable: false
            )
            XCTAssertFalse(presentation.isProtected)
            XCTAssertEqual(presentation.displayStatus, .needsAttention)
            XCTAssertEqual(presentation.statusText, ProtectionStatus.needsAttention.title)
            XCTAssertEqual(presentation.displayStatus.symbolName, ProtectionStatus.needsAttention.symbolName)
            XCTAssertEqual(presentation.displayExplanation, "Protection needs your attention before it can be confirmed again.")
            XCTAssertTrue(presentation.displayRecoveryAvailable)
            XCTAssertFalse(presentation.evidenceText.contains("Last verified"))
        }
    }

    func testVerifiedProtectedPreservesConfirmedDisplayWithoutRecovery() {
        let presentation = ProtectionDemoData.protected
        XCTAssertTrue(presentation.isProtected)
        XCTAssertEqual(presentation.displayStatus, .protected)
        XCTAssertEqual(presentation.statusText, ProtectionStatus.protected.title)
        XCTAssertEqual(presentation.displayStatus.symbolName, ProtectionStatus.protected.symbolName)
        XCTAssertEqual(presentation.displayExplanation, presentation.explanation)
        XCTAssertFalse(presentation.displayRecoveryAvailable)
        XCTAssertEqual(presentation.evidenceText, "Last verified: 2 min ago")
    }

    func testProtectedRequiresVerifiedEvidence() {
        let confirmed = ProtectionPresentation(
            status: .protected,
            evidence: .verified(minutesAgo: 2),
            explanation: "Confirmed",
            restrictionsRemainInEffect: true,
            recoveryAvailable: false
        )
        XCTAssertTrue(confirmed.isProtected)

        let merelyNoticed = ProtectionPresentation(
            status: .protected,
            evidence: .noticed(minutesAgo: 2),
            explanation: "Not confirmed",
            restrictionsRemainInEffect: true,
            recoveryAvailable: false
        )
        XCTAssertFalse(merelyNoticed.isProtected)
    }

    func testNonProtectedStatesNeverClaimProtectedEvenWithVerifiedEvidence() {
        for status in [ProtectionStatus.syncPending, .deviceOffline, .needsAttention, .protectionUnavailable] {
            let presentation = ProtectionPresentation(
                status: status,
                evidence: .verified(minutesAgo: 1),
                explanation: "Evidence exists",
                restrictionsRemainInEffect: true,
                recoveryAvailable: status == .needsAttention || status == .protectionUnavailable
            )
            XCTAssertFalse(presentation.isProtected, "\(status) must not claim Protected")
        }
    }

    func testSyncPendingAndOfflineRemainDistinct() {
        XCTAssertEqual(ProtectionDemoData.syncPending.status, .syncPending)
        XCTAssertEqual(ProtectionDemoData.deviceOffline.status, .deviceOffline)
        XCTAssertNotEqual(ProtectionDemoData.syncPending, ProtectionDemoData.deviceOffline)
        XCTAssertTrue(ProtectionDemoData.syncPending.restrictionsRemainInEffect)
        XCTAssertTrue(ProtectionDemoData.deviceOffline.restrictionsRemainInEffect)
    }

    func testNeedsAttentionAndUnavailableExposeRecoveryWithoutClaimingProtection() {
        for presentation in [ProtectionDemoData.needsAttention, ProtectionDemoData.unavailable] {
            XCTAssertTrue(presentation.recoveryAvailable)
            XCTAssertFalse(presentation.isProtected)
        }
    }

    func testPermissionRevokedCannotClaimProtectionOrRestrictionsRemainApplied() {
        let presentation = ProtectionDemoData.permissionRevoked
        XCTAssertEqual(presentation.status, .protectionUnavailable)
        XCTAssertFalse(presentation.isProtected)
        XCTAssertFalse(presentation.restrictionsRemainInEffect)
        XCTAssertTrue(presentation.recoveryAvailable)
    }

    func testRecoveredRequiresFreshConfirmedEvidence() {
        let presentation = ProtectionDemoData.recovered
        XCTAssertEqual(presentation.status, .protected)
        XCTAssertEqual(presentation.evidence, .verified(minutesAgo: 0))
        XCTAssertTrue(presentation.isProtected)
        XCTAssertFalse(presentation.recoveryAvailable)
    }

    func testEvidenceTextPreservesLastVerifiedTruth() {
        XCTAssertEqual(ProtectionDemoData.protected.evidenceText, "Last verified: 2 min ago")
        XCTAssertEqual(ProtectionDemoData.syncPending.evidenceText, "Last verified: 14 min ago")
        XCTAssertEqual(ProtectionDemoData.deviceOffline.evidenceText, "Last verified: 3 hr ago")
    }

    func testProtectionDemoStateMappingCoversFiveCanonicalStates() {
        let states: [ProtectionStatus] = [.protected, .syncPending, .deviceOffline, .needsAttention, .protectionUnavailable]
        for status in states {
            XCTAssertEqual(ProtectionDemoData.state(for: status).status, status)
        }
    }

    func testIssueNoticeIsNotMislabeledAsVerified() {
        XCTAssertEqual(ProtectionDemoData.needsAttention.evidenceText, "Issue noticed: 10 min ago")
        XCTAssertEqual(ProtectionDemoData.permissionRevoked.evidenceText, "Issue noticed: just now")
        XCTAssertFalse(ProtectionDemoData.needsAttention.evidenceText.contains("Last verified"))
    }


    func testMayaProtectionRouteKeepsHerDeviceIdentity() {
        let maya = ParentHomeDemoData.canonical().children.first { $0.firstName == "Maya" }
        XCTAssertEqual(maya?.destination?.childName, "Maya")

        let pending = ProtectionDemoData.forChild(ProtectionDemoData.syncPending, name: "Maya")
        XCTAssertEqual(pending.status, .syncPending)
        XCTAssertEqual(pending.evidence, .verified(minutesAgo: 14))
        XCTAssertFalse(pending.explanation.contains("Sam’s iPhone"))

        let offline = ProtectionDemoData.forChild(ProtectionDemoData.deviceOffline, name: "Maya")
        XCTAssertEqual(offline.status, .deviceOffline)
        XCTAssertTrue(offline.explanation.contains("Maya’s iPhone"))
        XCTAssertFalse(offline.explanation.contains("Sam’s iPhone"))
    }

    func testChildSpecificRecoveryPreservesVerificationEvidence() {
        let recovered = ProtectionDemoData.forChild(ProtectionDemoData.recovered, name: "Maya")
        XCTAssertTrue(recovered.isProtected)
        XCTAssertEqual(recovered.evidence, .verified(minutesAgo: 0))
        XCTAssertTrue(recovered.explanation.contains("Maya’s iPhone"))
    }

    func testNoVerificationEvidenceDoesNotInventLastVerified() {
        let presentation = ProtectionPresentation(
            status: .protectionUnavailable,
            evidence: .notActiveYet,
            explanation: "Not yet active",
            restrictionsRemainInEffect: false,
            recoveryAvailable: true
        )
        XCTAssertEqual(presentation.evidenceText, "Protection not active yet")
    }

    // Every required Protection review root must remain launchable by the
    // deterministic Release Simulator harness, independent of app navigation.
    @MainActor
    func testProtectionReviewLaunchArgumentsCoverAllNineCanonicalStates() {
        let cases: [(String, AppContainer.Perspective)] = [
            ("child-detail", .childDetail),
            ("protection-protected", .protectionProtected),
            ("protection-sync-pending", .protectionSyncPending),
            ("protection-offline", .protectionOffline),
            ("protection-attention", .protectionAttention),
            ("protection-unavailable", .protectionUnavailable),
            ("protection-recovery", .protectionRecovery),
            ("protection-permission-revoked", .protectionPermissionRevoked),
            ("protection-recovered", .protectionRecovered)
        ]
        XCTAssertEqual(cases.count, 9)
        for (flag, expected) in cases {
            let actual = AppContainer.visualReviewPerspective(
                from: ["ThemisFamily", "--visual-review-perspective", flag]
            )
            XCTAssertEqual(actual, expected, "Review launch argument \(flag) must resolve correctly")
        }
        XCTAssertNil(AppContainer.visualReviewPerspective(
            from: ["ThemisFamily", "--visual-review-perspective", "unknown-protection"]
        ))
    }
}
