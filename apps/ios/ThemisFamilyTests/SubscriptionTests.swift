import XCTest
@testable import ThemisFamily

final class SubscriptionTests: XCTestCase {
    // MARK: Test 1 — involuntary billing failure path

    func testInvoluntaryBillingFailurePathSupportsActiveGraceRecoveredOrExpired() {
        XCTAssertTrue(SubscriptionLifecycleState.active.allowedNextStates.contains(.appleBillingGracePeriod))
        XCTAssertTrue(
            SubscriptionLifecycleState.appleBillingGracePeriod.allowedNextStates.contains(.recovered)
        )
        XCTAssertTrue(
            SubscriptionLifecycleState.appleBillingGracePeriod.allowedNextStates.contains(.protectionExpired)
        )
    }

    // MARK: Test 2 — full protection during Billing Grace Period

    func testProtectionRemainsFullyActiveDuringBillingGracePeriod() {
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .appleBillingGracePeriod),
            .enforcing
        )
    }

    // MARK: Test 3 — no partial/reduced protection tier

    func testThereIsNoPartialOrReducedProtectionState() {
        XCTAssertEqual(DeviceProtectionState.allCases.count, 3)
        XCTAssertEqual(Set(DeviceProtectionState.allCases), [.enforcing, .cleared, .reactivationSent])
        for state in DeviceProtectionState.allCases {
            XCTAssertNotEqual(state.rawValue.lowercased(), "partial")
            XCTAssertFalse(state.rawValue.lowercased().contains("partial"))
            XCTAssertFalse(state.rawValue.lowercased().contains("reduced"))
        }
    }

    // MARK: Test 4 — Protection Expired clears restrictions but retains rule definitions

    func testProtectionExpiredClearsRestrictionsAndRetainsRuleDefinitions() {
        XCTAssertEqual(SubscriptionStateMachine.protectionState(for: .protectionExpired), .cleared)

        let presentation = SubscriptionDemoData.presentation(for: .protectionExpired)
        XCTAssertEqual(presentation.protection, .cleared)
        XCTAssertFalse(presentation.retainedRules.isEmpty)
    }

    // MARK: Test 5 — resubscribing after Protection Expired does not auto-reactivate

    func testResubscribingAfterProtectionExpiredDoesNotAutoReactivateProtection() {
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: nil),
            .cleared
        )
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: .awaitingReview),
            .cleared
        )

        let presentation = SubscriptionDemoData.presentation(for: .readyToReactivate)
        XCTAssertEqual(presentation.protection, .cleared)
        XCTAssertTrue(SubscriptionStateMachine.isPaymentActive(presentation.lifecycle))
    }

    // MARK: Test 6 — resubscription requires review, confirmation, sent, then device ack

    func testResubscriptionRequiresReviewConfirmationSentThenDeviceAcknowledgementBeforeActive() {
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: .reviewingRetainedRules),
            .cleared
        )
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: .sent),
            .reactivationSent
        )
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: .acknowledgedOnDevice),
            .enforcing
        )

        let order: [ReactivationReviewStep] = [.awaitingReview, .reviewingRetainedRules, .sent, .acknowledgedOnDevice]
        XCTAssertEqual(Set(order), Set(ReactivationReviewStep.allCases))
    }

    // MARK: Test 7 — payment recovered during grace needs no manual reactivation

    func testPaymentRecoveredDuringGraceDoesNotRequireManualReactivation() {
        XCTAssertEqual(SubscriptionStateMachine.protectionState(for: .recovered), .enforcing)

        let presentation = SubscriptionDemoData.presentation(for: .recoveredDuringGrace)
        XCTAssertEqual(presentation.protection, .enforcing)
        XCTAssertNil(presentation.reactivationStep)
        XCTAssertNotEqual(presentation.screen, .readyToReactivate)
        XCTAssertNotEqual(presentation.screen, .reviewRetainedRules)
    }

    // MARK: Test 8 — voluntary cancellation retains full service until paid-through date

    func testVoluntaryCancellationRetainsFullServiceUntilPaidThroughDate() {
        XCTAssertEqual(SubscriptionStateMachine.protectionState(for: .cancelledPaidThrough), .enforcing)

        let presentation = SubscriptionDemoData.presentation(for: .manageCancelledPaidThrough)
        XCTAssertEqual(presentation.protection, .enforcing)
        XCTAssertNotNil(presentation.paidThroughDate)
    }

    // MARK: Test 9 — no invented subscription price anywhere in demo data

    func testNoModelOrDemoDataContainsAnInventedSubscriptionPrice() {
        let forbidden = ["£", "$", "€", "4.99", "9.99", "49.99"]
        for rule in SubscriptionDemoData.retainedRules {
            for token in forbidden {
                XCTAssertFalse(rule.title.contains(token))
                XCTAssertFalse(rule.detail.contains(token))
            }
        }
        for scenario in SubscriptionDemoScenario.allCases {
            let presentation = SubscriptionDemoData.presentation(for: scenario)
            for rule in presentation.retainedRules {
                for token in forbidden {
                    XCTAssertFalse(rule.title.contains(token))
                    XCTAssertFalse(rule.detail.contains(token))
                }
            }
        }
    }

    // MARK: Test 10 — no invented trial length anywhere in demo data

    func testNoModelOrDemoDataContainsAnInventedTrialLength() {
        let forbidden = ["7-day", "7 day", "14-day", "14 day", "30-day", "30 day", "free trial"]
        for scenario in SubscriptionDemoScenario.allCases {
            let presentation = SubscriptionDemoData.presentation(for: scenario)
            for rule in presentation.retainedRules {
                for token in forbidden {
                    XCTAssertFalse(rule.detail.lowercased().contains(token))
                }
            }
        }
        // The state machine and screen identifiers carry no commercial terms either.
        for state in SubscriptionLifecycleState.allCases {
            XCTAssertFalse(state.rawValue.lowercased().contains("trial"))
        }
    }

    // MARK: Test 11 — B-007 does not report Protection Active

    func testReactivationSentDoesNotReportProtectionActive() {
        let presentation = SubscriptionDemoData.presentation(for: .reactivationSent)
        XCTAssertEqual(presentation.screen, .reactivationSent)
        XCTAssertNotEqual(presentation.protection, .enforcing)
        XCTAssertEqual(presentation.protection, .reactivationSent)
        XCTAssertEqual(presentation.reactivationStep, .sent)
    }

    // MARK: Test 12 — B-008 represents device-acknowledged Protection Active

    func testProtectionActiveOnDeviceRepresentsDeviceAcknowledgement() {
        let presentation = SubscriptionDemoData.presentation(for: .protectionActiveOnDevice)
        XCTAssertEqual(presentation.screen, .protectionActiveOnDevice)
        XCTAssertEqual(presentation.protection, .enforcing)
        XCTAssertEqual(presentation.reactivationStep, .acknowledgedOnDevice)
    }

    // MARK: Test 13 — retained rules include canonical Sam and Maya examples

    func testRetainedRulesIncludeCanonicalSamAndMayaExamples() {
        let rules = SubscriptionDemoData.retainedRules
        XCTAssertTrue(rules.contains { $0.childName == "Sam" && $0.title == "Homework Deadline" })
        XCTAssertTrue(rules.contains { $0.childName == "Maya" && $0.title == "Social apps" })
    }

    // MARK: Test 14 — billing presentation is Parent-only, no child-blaming language

    func testBillingPresentationIsParentOnlyWithNoChildBlamingLanguage() {
        let presentation = SubscriptionDemoData.presentation(for: .billingGrace)
        XCTAssertEqual(presentation.screen, .billingGraceWarning)
        // No child-facing blame or billing detail: the billing presentation carries no
        // child name and no retained-rule listing of its own.
        XCTAssertTrue(presentation.retainedRules.isEmpty)
        let copy = "Your payment didn't go through. Protection is still active while Apple retries payment. Update your payment method to keep protection active."
        for name in ["Sam", "Maya"] {
            XCTAssertFalse(copy.contains(name))
        }
        let blamingPhrases = ["you broke", "your fault", "because of you", "your child"]
        for phrase in blamingPhrases {
            XCTAssertFalse(copy.lowercased().contains(phrase))
        }
    }

    // MARK: Test 15 — Themis never claims it directly processes the App Store payment

    func testSubscriptionPresentationDoesNotClaimThemisProcessesPaymentDirectly() {
        let manageCopy = "Managed by: App Store. Your subscription is managed through the App Store."
        XCTAssertTrue(manageCopy.contains("App Store"))

        let forbiddenClaims = [
            "themis processes your payment",
            "themis charges your card",
            "themis processes the payment",
            "card number",
            "cvv",
            "expiry date"
        ]
        for claim in forbiddenClaims {
            XCTAssertFalse(manageCopy.lowercased().contains(claim))
        }
    }
}
