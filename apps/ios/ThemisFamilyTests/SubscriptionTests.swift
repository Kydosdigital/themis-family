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
            XCTAssertFalse(state.rawValue.lowercased().contains("partial"))
            XCTAssertFalse(state.rawValue.lowercased().contains("reduced"))
        }
    }

    // MARK: Test 4 — Protection Expired clears restrictions but retains rule definitions,
    // and NEVER describes the clearing as happening on "this device" (the Parent is
    // viewing B-004 on their own phone; the cleared devices are Sam's and Maya's).

    func testProtectionExpiredClearsRestrictionsAndRetainsRuleDefinitions() {
        XCTAssertEqual(SubscriptionStateMachine.protectionState(for: .protectionExpired), .cleared)

        let presentation = SubscriptionDemoData.presentation(for: .protectionExpired)
        XCTAssertEqual(presentation.protection, .cleared)
        XCTAssertFalse(presentation.retainedRules.isEmpty)
    }

    func testProtectionExpiredCopyDoesNotSayThisDeviceAndNamesTheChildrensDevices() {
        XCTAssertFalse(SubscriptionCopy.protectionExpiredRestrictionsCleared.lowercased().contains("this device"))
        XCTAssertTrue(SubscriptionCopy.protectionExpiredRestrictionsCleared.contains("Sam"))
        XCTAssertTrue(SubscriptionCopy.protectionExpiredRestrictionsCleared.contains("Maya"))
        XCTAssertTrue(SubscriptionCopy.protectionExpiredRestrictionsCleared.contains("devices"))
        XCTAssertEqual(SubscriptionCopy.protectionExpiredRulesSaved, "Your rules are saved.")
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

    // MARK: Test (B-005 · Not now) — payment active, protection cleared, rules retained,
    // no automatic transition into the B-006/B-007/B-008 reactivation flow.

    func testReadyToReactivateNotNowKeepsPaymentActiveAndProtectionClearedWithoutAdvancing() {
        let presentation = SubscriptionDemoData.presentation(for: .readyToReactivateNotNow)

        XCTAssertEqual(presentation.screen, .readyToReactivate)
        XCTAssertEqual(presentation.reactivationStep, .deferred)
        XCTAssertTrue(SubscriptionStateMachine.isPaymentActive(presentation.lifecycle))
        XCTAssertEqual(presentation.protection, .cleared)
        XCTAssertFalse(presentation.retainedRules.isEmpty)
        XCTAssertFalse(presentation.reactivationConfirmedByParent)

        // "Not now" only ever returns to the ask; it never advances into review/confirm/send.
        XCTAssertEqual(ReactivationReviewStep.deferred.allowedNextSteps, [.awaitingReview])
        XCTAssertFalse(ReactivationReviewStep.deferred.allowedNextSteps.contains(.reviewingRetainedRules))
        XCTAssertFalse(ReactivationReviewStep.deferred.allowedNextSteps.contains(.confirming))
        XCTAssertFalse(ReactivationReviewStep.deferred.allowedNextSteps.contains(.sent))
    }

    // MARK: Test 6 — the full confirmed sequence, including the new B-006 · Confirm step

    func testResubscriptionRequiresReviewConfirmationSentThenDeviceAcknowledgementBeforeActive() {
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: .reviewingRetainedRules),
            .cleared
        )
        XCTAssertEqual(
            SubscriptionStateMachine.protectionState(for: .resubscribed, reactivationStep: .confirming),
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

        let order: [ReactivationReviewStep] = [
            .awaitingReview, .deferred, .reviewingRetainedRules, .confirming, .sent, .acknowledgedOnDevice
        ]
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
        // True on B-007 even though the device has not acknowledged anything — this is
        // exactly why the field is named for PARENT confirmation, not acknowledgement.
        XCTAssertTrue(presentation.reactivationConfirmedByParent)
    }

    // MARK: Test 12 — B-008 represents device-acknowledged Protection Active

    func testProtectionActiveOnDeviceRepresentsDeviceAcknowledgement() {
        let presentation = SubscriptionDemoData.presentation(for: .protectionActiveOnDevice)
        XCTAssertEqual(presentation.screen, .protectionActiveOnDevice)
        XCTAssertEqual(presentation.protection, .enforcing)
        XCTAssertEqual(presentation.reactivationStep, .acknowledgedOnDevice)
    }

    // MARK: Test 13 — retained rules include all three canonical approved examples

    func testRetainedRulesIncludeAllThreeCanonicalExamples() {
        let rules = SubscriptionDemoData.retainedRules
        XCTAssertEqual(rules.count, 3)
        XCTAssertTrue(rules.contains {
            $0.childName == "Sam" && $0.title == "Homework Deadline" && $0.detail == "Due 6:00 PM"
        })
        XCTAssertTrue(rules.contains {
            $0.childName == "Sam" && $0.title == "Bedtime" && $0.detail == "8:30 PM–7:00 AM"
        })
        XCTAssertTrue(rules.contains {
            $0.childName == "Maya" && $0.title == "Social apps" && $0.detail == "10:00 PM–7:00 AM"
        })
    }

    // MARK: Test — B-006 review is not a rule editor: `RetainedRule` carries no
    // activation-toggle or enabled field, only the four read-only display properties.

    func testRetainedRuleHasNoActivationToggleFieldsAndIsReviewOnly() {
        let rule = SubscriptionDemoData.retainedRules[0]
        let mirror = Mirror(reflecting: rule)
        let fieldNames = Set(mirror.children.compactMap(\.label))
        XCTAssertEqual(fieldNames, ["id", "childName", "title", "detail"])
        XCTAssertFalse(fieldNames.contains("isEnabled"))
        XCTAssertFalse(fieldNames.contains("isActive"))
        XCTAssertFalse(fieldNames.contains("isSelected"))

        XCTAssertFalse(SubscriptionCopy.reviewRulesSupportingCopy.lowercased().contains("toggle"))
        XCTAssertEqual(SubscriptionCopy.reviewRulesSupportingCopy, "Edit any rule before turning protection on.")
        XCTAssertEqual(SubscriptionCopy.reviewRulesPrimaryAction, "Turn protection back on")
    }

    // MARK: Test — B-006 · Confirm exists as its own deterministic state, distinct from
    // plain review, and still does not mean protection is active.

    func testReviewConfirmExistsAsSeparateStateBeforeSending() {
        let presentation = SubscriptionDemoData.presentation(for: .reviewConfirmReactivation)

        XCTAssertEqual(presentation.reactivationStep, .confirming)
        XCTAssertNotEqual(presentation.reactivationStep, .reviewingRetainedRules)
        XCTAssertEqual(presentation.protection, .cleared)
        XCTAssertFalse(presentation.reactivationConfirmedByParent)
        XCTAssertTrue(SubscriptionStateMachine.isPaymentActive(presentation.lifecycle))

        XCTAssertEqual(SubscriptionCopy.confirmTitle, "Turn protection back on?")
        XCTAssertEqual(SubscriptionCopy.confirmPrimaryAction, "Turn protection back on")
        XCTAssertEqual(SubscriptionCopy.confirmSecondaryAction, "Cancel")
    }

    // MARK: Test — Parent confirmation transitions to B-007 (sent), never directly to
    // B-008 (acknowledgedOnDevice/enforcing); B-007 is reachable only via `confirming`.

    func testParentConfirmationTransitionsOnlyToReactivationSentNotDirectlyToActive() {
        XCTAssertTrue(SubscriptionStateMachine.canAdvance(from: .confirming, to: .sent))
        XCTAssertFalse(SubscriptionStateMachine.canAdvance(from: .confirming, to: .acknowledgedOnDevice))
        XCTAssertFalse(SubscriptionStateMachine.canAdvance(from: .reviewingRetainedRules, to: .sent))
        XCTAssertFalse(SubscriptionStateMachine.canAdvance(from: .awaitingReview, to: .sent))
        XCTAssertFalse(SubscriptionStateMachine.canAdvance(from: nil, to: .sent))
        XCTAssertTrue(SubscriptionStateMachine.canAdvance(from: .sent, to: .acknowledgedOnDevice))
    }

    // MARK: Test — billing presentation is Parent-only, no child-blaming language

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

    // MARK: Test — Themis never claims it directly processes the App Store payment

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

    // MARK: Test — B-001 does not imply an active entitlement or active device protection

    func testOfferPresentationDoesNotImplyActiveEntitlementOrActiveProtection() {
        let presentation = SubscriptionDemoData.presentation(for: .offer)

        XCTAssertEqual(presentation.screen, .offer)
        XCTAssertNil(presentation.lifecycle)
        XCTAssertNil(presentation.protection)
        XCTAssertNotEqual(presentation.lifecycle, .active)
        XCTAssertNotEqual(presentation.protection, .enforcing)
        XCTAssertFalse(SubscriptionStateMachine.isPaymentActive(presentation.lifecycle))
        XCTAssertTrue(presentation.retainedRules.isEmpty)
        XCTAssertFalse(presentation.reactivationConfirmedByParent)
    }

    // MARK: Test — the parent-confirmation field is not ambiguously named as device
    // acknowledgement: confirmed by name, and by behaviour (true pre-device-ack on B-007).

    func testParentConfirmationFieldIsNotAmbiguouslyNamedAsDeviceAcknowledgement() {
        let fieldNames = Set(Mirror(reflecting: SubscriptionDemoData.presentation(for: .reactivationSent)).children.compactMap(\.label))
        XCTAssertTrue(fieldNames.contains("reactivationConfirmedByParent"))
        XCTAssertFalse(fieldNames.contains("reactivationAcknowledged"))

        // On B-007 the parent has confirmed, but the device has not acknowledged yet —
        // these must never read as the same thing.
        let sent = SubscriptionDemoData.presentation(for: .reactivationSent)
        XCTAssertTrue(sent.reactivationConfirmedByParent)
        XCTAssertNotEqual(sent.protection, .enforcing)

        let active = SubscriptionDemoData.presentation(for: .protectionActiveOnDevice)
        XCTAssertTrue(active.reactivationConfirmedByParent)
        XCTAssertEqual(active.protection, .enforcing)
    }

    // MARK: Test — B-003 canonical presentation contains both children, both Protected

    func testBillingGraceCanonicalPresentationContainsSamChildAndMayaTeenProtected() {
        let presentation = SubscriptionDemoData.presentation(for: .billingGrace)
        let children = presentation.billingProtectedChildren
        XCTAssertEqual(children.count, 2)
        XCTAssertTrue(children.contains { $0.title == "Sam · Child" })
        XCTAssertTrue(children.contains { $0.title == "Maya · Teen" })
        // Both rows render with the shared `.protected` status preset — never a reduced
        // or partial tier.
        XCTAssertEqual(StatusKind.protected.rawValue, "protected")
    }

    // MARK: Test — B-003 does not imply reduced protection (no countdown, no grace days,
    // no custom Themis timer figure anywhere in the canonical copy).

    func testBillingGraceDoesNotImplyReducedProtectionOrACountdown() {
        XCTAssertEqual(SubscriptionStateMachine.protectionState(for: .appleBillingGracePeriod), .enforcing)
        let forbidden = ["day", "days", "countdown", "16-day", "remaining"]
        let copy = [
            SubscriptionCopy.billingGraceStatusLabel,
            SubscriptionCopy.billingGraceExplanation,
            SubscriptionCopy.billingGraceReassurance,
            SubscriptionCopy.billingGraceCallToAction,
            SubscriptionCopy.billingGraceAction
        ].joined(separator: " ").lowercased()
        for token in forbidden {
            XCTAssertFalse(copy.contains(token))
        }
    }

    // MARK: Test — B-004 primary action is Resubscribe, and the supporting copy makes
    // clear the App Store subscription sheet is the system-owned hand-off.

    func testProtectionExpiredPrimaryActionIsResubscribeViaAppStoreHandoff() {
        XCTAssertEqual(SubscriptionCopy.protectionExpiredPrimaryAction, "Resubscribe")
        XCTAssertEqual(SubscriptionCopy.protectionExpiredResubscribeExplanation, "Opens the App Store subscription sheet.")
        XCTAssertTrue(SubscriptionCopy.protectionExpiredResubscribeExplanation.contains("App Store"))
    }

    // MARK: Test — B-005 contains the approved status, title, supporting copy and actions

    func testReadyToReactivateContainsApprovedCanonicalCopy() {
        XCTAssertEqual(SubscriptionCopy.readyToReactivateStatusLabel, "Subscription active")
        XCTAssertEqual(SubscriptionCopy.readyToReactivateTitle, "Ready to turn protection back on?")
        XCTAssertEqual(SubscriptionCopy.readyToReactivateExplanation, "Nothing is restricted until you confirm.")
        XCTAssertEqual(SubscriptionCopy.readyToReactivatePrimaryAction, "Review rules first")
        XCTAssertEqual(SubscriptionCopy.readyToReactivateSecondaryAction, "Not now")
    }

    // MARK: Test — B-006 exact retained-rule visible hierarchy: child name + rule name
    // together as the title, with the detail beneath as the subtitle.

    func testReviewRulesVisibleHierarchyIsChildAndRuleNameTogetherWithDetailBeneath() {
        let rules = SubscriptionDemoData.retainedRules

        func rowTitle(_ rule: RetainedRule) -> String { "\(rule.childName) · \(rule.title)" }

        XCTAssertTrue(rules.contains { rowTitle($0) == "Sam · Homework Deadline" && $0.detail == "Due 6:00 PM" })
        XCTAssertTrue(rules.contains { rowTitle($0) == "Sam · Bedtime" && $0.detail == "8:30 PM–7:00 AM" })
        XCTAssertTrue(rules.contains { rowTitle($0) == "Maya · Social apps" && $0.detail == "10:00 PM–7:00 AM" })
        XCTAssertEqual(SubscriptionCopy.reviewRulesTitle, "Review rules")
    }

    // MARK: Test — B-007 exact semantic content: "Reactivation sent", "Waiting for Sam's
    // and Maya's devices", and a "Sending" status — never "Protected"/"Protection active".

    func testReactivationSentExactSemanticContent() {
        XCTAssertEqual(SubscriptionCopy.reactivationSentStatusLabel, "Reactivation sent")
        XCTAssertEqual(SubscriptionCopy.reactivationSentExplanation, "Waiting for Sam's and Maya's devices.")
        XCTAssertEqual(SubscriptionCopy.reactivationSentBadgeLabel, "Sending")
        XCTAssertTrue(SubscriptionCopy.reactivationSentExplanation.contains("Sam"))
        XCTAssertTrue(SubscriptionCopy.reactivationSentExplanation.contains("Maya"))
    }

    // MARK: Test — B-007 contains no Protected / Protection active claim anywhere in its copy.

    func testReactivationSentContainsNoProtectedOrProtectionActiveClaim() {
        let copy = [
            SubscriptionCopy.reactivationSentStatusLabel,
            SubscriptionCopy.reactivationSentBadgeLabel,
            SubscriptionCopy.reactivationSentExplanation,
            SubscriptionCopy.reactivationSentDetail
        ].joined(separator: " ").lowercased()
        XCTAssertFalse(copy.contains("protected"))
        XCTAssertFalse(copy.contains("protection active"))
        XCTAssertFalse(copy.contains("protection is active"))
        XCTAssertFalse(copy.contains("done"))
        XCTAssertFalse(copy.contains("applied"))
    }

    // MARK: Test — B-008 contains both canonical device acknowledgement rows, Protected.

    func testProtectionActiveOnDeviceContainsBothCanonicalDeviceRows() {
        let presentation = SubscriptionDemoData.presentation(for: .protectionActiveOnDevice)
        let devices = presentation.deviceAcknowledgements
        XCTAssertEqual(devices.count, 2)
        XCTAssertTrue(devices.contains { $0.deviceName == "Sam's iPhone" && $0.confirmedAtText == "Confirmed 9:12 AM" })
        XCTAssertTrue(devices.contains { $0.deviceName == "Maya's iPhone" && $0.confirmedAtText == "Confirmed 9:13 AM" })
        // Both rows render with the shared `.protected` status preset.
        XCTAssertEqual(StatusKind.protected.rawValue, "protected")
    }

    // MARK: Test — B-008 is only valid for acknowledgedOnDevice + enforcing; every other
    // scenario carries no device acknowledgement rows at all.

    func testDeviceAcknowledgementRowsOnlyPresentWhenAcknowledgedOnDeviceAndEnforcing() {
        for scenario in SubscriptionDemoScenario.allCases {
            let presentation = SubscriptionDemoData.presentation(for: scenario)
            if !presentation.deviceAcknowledgements.isEmpty {
                XCTAssertEqual(presentation.reactivationStep, .acknowledgedOnDevice)
                XCTAssertEqual(presentation.protection, .enforcing)
            }
        }
        let active = SubscriptionDemoData.presentation(for: .protectionActiveOnDevice)
        XCTAssertFalse(active.deviceAcknowledgements.isEmpty)
    }

    // MARK: Test — no StoreKit/payment/network implementation was introduced anywhere
    // in this isolated feature.

    func testNoStoreKitPaymentOrNetworkImplementationIsPresent() {
        let featureDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ThemisFamily/Features/Subscription")
        let forbiddenTokens = ["import StoreKit", "URLSession", "SKProduct", "SKPaymentQueue", "import Network"]
        guard let enumerator = FileManager.default.enumerator(at: featureDirectory, includingPropertiesForKeys: nil) else {
            XCTFail("Could not enumerate Subscription feature directory")
            return
        }
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            guard let contents = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
            for token in forbiddenTokens {
                XCTAssertFalse(contents.contains(token), "\(fileURL.lastPathComponent) unexpectedly contains \(token)")
            }
        }
    }
}
