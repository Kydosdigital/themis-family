import XCTest
@testable import ThemisFamily

final class ProtectionTests: XCTestCase {
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
}
