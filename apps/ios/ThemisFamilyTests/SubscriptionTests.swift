import XCTest
@testable import ThemisFamily

final class SubscriptionTests: XCTestCase {
    private func run(_ start: SubscriptionPhase, _ events: [SubscriptionEvent]) -> SubscriptionPhase? {
        var phase: SubscriptionPhase? = start
        for event in events { phase = phase?.applying(event) }
        return phase
    }

    private func allContent() -> [SubscriptionContent] {
        [SubscriptionContentFactory.offer] + SubscriptionPhase.allCases.map {
            SubscriptionContentFactory.content(for: SubscriptionDemoData.state(for: $0))
        }
    }

    func testInvoluntaryPathRecoversOrExpires() {
        XCTAssertEqual(run(.active, [.billingFailed]), .billingGrace)
        XCTAssertEqual(run(.active, [.billingFailed, .paymentRecovered]), .active)
        XCTAssertEqual(run(.active, [.billingFailed, .graceExpiredWithoutRecovery]), .protectionExpired)
    }

    func testBillingGraceKeepsFullProtection() {
        XCTAssertEqual(SubscriptionPhase.billingGrace.deviceProtection, .active)
        XCTAssertTrue(SubscriptionPhase.billingGrace.isPaymentActive)
        XCTAssertFalse(SubscriptionPhase.billingGrace.restrictionsCleared)
    }

    func testNoPartialProtectionState() {
        let states = Set(SubscriptionPhase.allCases.map(\.deviceProtection))
        XCTAssertEqual(states.count, 3)
        for phase in SubscriptionPhase.allCases {
            XCTAssertFalse(phase.rawValue.lowercased().contains("partial"))
            XCTAssertFalse(phase.rawValue.lowercased().contains("reduced"))
        }
    }

    func testProtectionExpiredClearsRestrictionsAndRetainsRules() {
        let phase = SubscriptionPhase.protectionExpired
        XCTAssertTrue(phase.restrictionsCleared)
        XCTAssertTrue(phase.rulesRetained)
        XCTAssertFalse(SubscriptionDemoData.state(for: phase).retainedRules.isEmpty)
    }

    func testResubscribingDoesNotReactivateProtection() {
        let phase = run(.protectionExpired, [.resubscribed])
        XCTAssertEqual(phase, .resubscribedAwaitingReview)
        XCTAssertTrue(phase?.isPaymentActive ?? false)
        XCTAssertFalse(phase?.isProtectionActiveOnDevice ?? true)
        XCTAssertNil(SubscriptionPhase.protectionExpired.applying(.deviceAcknowledged))
    }

    func testReactivationRequiresReviewConfirmationSendAndAcknowledgement() {
        XCTAssertNil(run(.resubscribedAwaitingReview, [.parentConfirmedReactivation]))
        XCTAssertNil(run(.reactivationReady, [.deviceAcknowledged]))
        XCTAssertEqual(
            run(.protectionExpired, [.resubscribed, .parentStartedReview, .parentConfirmedReactivation, .deviceAcknowledged]),
            .protectionActive
        )
    }

    func testRecoveryDuringGraceNeedsNoManualReactivation() {
        let recovered = run(.active, [.billingFailed, .paymentRecovered])
        XCTAssertEqual(recovered, .active)
        XCTAssertFalse(recovered?.requiresManualReactivation ?? true)
        XCTAssertNil(SubscriptionPhase.billingGrace.applying(.resubscribed))
    }

    func testCancellationKeepsServiceUntilPaidThrough() {
        let state = SubscriptionDemoData.state(for: .cancelledPaidThrough)
        XCTAssertTrue(state.phase.isProtectionActiveOnDevice)
        XCTAssertNotNil(state.entitlement.paidThroughDate)
        XCTAssertEqual(run(.active, [.parentCancelled, .paidThroughEnded]), .protectionExpired)
        let text = SubscriptionContentFactory.content(for: state).allText.joined(separator: " ")
        XCTAssertTrue(text.contains("Protection stays active until 14 October 2026."))
    }

    func testNoInventedPrice() {
        for text in allContent().flatMap(\.allText) {
            XCTAssertNil(text.range(of: "[£$€]|\\d+\\.\\d{2}|per (month|year)|/(mo|month|yr|year)", options: [.regularExpression, .caseInsensitive]), text)
        }
    }

    func testNoInventedTrialLength() {
        for text in allContent().flatMap(\.allText) {
            XCTAssertNil(text.range(of: "trial|\\d+[- ]day|free for", options: [.regularExpression, .caseInsensitive]), text)
        }
    }

    func testReactivationSentIsNotProtectionActive() {
        let phase = SubscriptionPhase.reactivationSent
        XCTAssertFalse(phase.isProtectionActiveOnDevice)
        XCTAssertEqual(phase.deviceProtection, .awaitingDeviceAcknowledgement)
        let text = SubscriptionContentFactory.content(for: SubscriptionDemoData.state(for: phase)).allText.joined(separator: " ").lowercased()
        XCTAssertTrue(text.contains("reactivation sent"))
        for banned in ["protection active", "protected", "done", "locked again"] {
            XCTAssertFalse(text.contains(banned), banned)
        }
    }

    func testProtectionActiveIsDeviceAcknowledged() {
        XCTAssertEqual(SubscriptionPhase.protectionActive.screenID, .b008)
        XCTAssertTrue(SubscriptionPhase.protectionActive.isProtectionActiveOnDevice)
        XCTAssertEqual(SubscriptionContentFactory.content(for: SubscriptionDemoData.state(for: .protectionActive)).title, "Protection active on device")
    }

    func testRetainedRulesIncludeSamAndMaya() {
        let rules = SubscriptionDemoData.state(for: .reactivationReady).retainedRules
        XCTAssertTrue(rules.contains { $0.childName == "Sam" && $0.title == "Homework Deadline" && $0.detail == "Due 6:00 PM" && $0.appsOrScope == "Roblox + Minecraft" })
        XCTAssertTrue(rules.contains { $0.childName == "Maya" && $0.title == "Social apps" && $0.detail == "10:00 PM–7:00 AM" })
    }

    func testBillingPresentationIsParentOnlyAndNotBlaming() {
        let content = SubscriptionContentFactory.content(for: SubscriptionDemoData.state(for: .billingGrace))
        let text = content.allText.joined(separator: " ").lowercased()
        for banned in ["sam", "maya", "child", "teen", "your fault", "punish"] {
            XCTAssertFalse(text.contains(banned), banned)
        }
    }

    func testDoesNotClaimThemisProcessesPayment() {
        for text in allContent().flatMap(\.allText) {
            XCTAssertNil(text.range(of: "card number|cvv|expiry|themis (charges|processes|bills)", options: [.regularExpression, .caseInsensitive]), text)
        }
        XCTAssertEqual(SubscriptionContentFactory.content(for: SubscriptionDemoData.state(for: .active)).detailLine, "Managed through the App Store")
    }
}
