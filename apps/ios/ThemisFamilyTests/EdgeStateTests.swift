import XCTest
@testable import ThemisFamily

/// UI-13 Edge States tests. These assert the exact approved scenario
/// inventory and the safety-critical semantic distinctions called out in the
/// problem statement: empty ≠ error, offline ≠ failed, queued ≠ sent,
/// timing-unknown ≠ late/on-time, and no invented thresholds/guarantees.
final class EdgeStateTests: XCTestCase {

    // MARK: 1. Exact approved scenario inventory

    func testApprovedScenarioInventoryIsExactlySeventeenStates() {
        XCTAssertEqual(EdgeStateScenario.allCases.count, 17)
    }

    func testApprovedScenarioInventoryMatchesCanonicalScreenIDs() {
        let expected: Set<String> = [
            "P-023", "A-001", "T-001", "A-002", "T-002", "C-004", "C-001",
            "Q-006", "P-010", "E-007", "A-004", "P-012"
        ]
        let actual = Set(EdgeStateScenario.allCases.map(\.screenID))
        XCTAssertEqual(actual, expected)
    }

    func testEveryScenarioHasAUniquePresentation() {
        let presentations = EdgeStateDemoData.all
        XCTAssertEqual(presentations.count, EdgeStateScenario.allCases.count)
        XCTAssertEqual(Set(presentations.map(\.id)).count, presentations.count)
    }

    // MARK: 2-3. Empty states are not errors

    func testActionCentreEmptyIsNotRepresentedAsAnError() {
        let presentation = EdgeStateDemoData.presentation(for: .actionCentreEmpty)
        XCTAssertTrue(presentation.isCalmEmpty)
        XCTAssertEqual(presentation.severity, .calmEmpty)
        XCTAssertNotEqual(presentation.severity, .failure)
    }

    func testActivityEmptyIsNotRepresentedAsAnError() {
        let presentation = EdgeStateDemoData.presentation(for: .activityEmpty)
        XCTAssertTrue(presentation.isCalmEmpty)
        XCTAssertEqual(presentation.severity, .calmEmpty)
        XCTAssertNotEqual(presentation.severity, .failure)
    }

    func testActivityEmptyDoesNotMentionAppleScreenTimeOrSurveillance() {
        let presentation = EdgeStateDemoData.presentation(for: .activityEmpty)
        let lowercased = presentation.message.lowercased()
        XCTAssertFalse(lowercased.contains("screen time"))
        XCTAssertFalse(lowercased.contains("surveillance"))
    }

    // MARK: 4-5. Servers unreachable

    func testServersUnreachableUsesLastKnownLastVerifiedSemantics() {
        let presentation = EdgeStateDemoData.presentation(for: .serversUnreachable)
        let lastVerified = try! XCTUnwrap(presentation.lastVerifiedText)
        XCTAssertTrue(lastVerified.hasPrefix(EdgeStateCopy.lastVerifiedPrefix))
        XCTAssertTrue(presentation.message.contains("last-synced"))
    }

    func testServersUnreachableNeverInventsAnOQ19Threshold() {
        let presentation = EdgeStateDemoData.presentation(for: .serversUnreachable)
        let message = presentation.message.lowercased()
        // Must not claim a specific staleness threshold such as "after 30 minutes".
        XCTAssertFalse(message.contains("after 30 minutes"))
        XCTAssertFalse(message.contains("after 1 hour"))
        XCTAssertFalse(message.contains("becomes sync pending"))
        XCTAssertFalse(message.contains("becomes needs attention"))
    }

    func testServersUnreachableNeverClaimsProtectedOrInstantUpdates() {
        let presentation = EdgeStateDemoData.presentation(for: .serversUnreachable)
        XCTAssertEqual(presentation.statusKind, .unconfirmed)
        XCTAssertFalse(presentation.title.lowercased().contains("protected"))
        XCTAssertFalse(presentation.message.lowercased().contains("everything will update instantly"))
    }

    // MARK: 6-8. Timing could not be verified

    func testTimingUnverifiedCarriesBothClaimedAndServerReceivedTime() {
        let presentation = EdgeStateDemoData.presentation(for: .timingUnverified)
        let evidence = try! XCTUnwrap(presentation.timingEvidence)
        XCTAssertEqual(evidence.childDeviceClaimedTime, "5:58 PM")
        XCTAssertEqual(evidence.serverReceivedTime, "6:02 PM")
    }

    func testTimingUnverifiedNeverLabelsTheTaskLate() {
        let presentation = EdgeStateDemoData.presentation(for: .timingUnverified)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        XCTAssertFalse(combined.contains("late"))
        XCTAssertFalse(combined.contains("after the deadline"))
    }

    func testTimingUnverifiedNeverLabelsTheTaskOnTime() {
        let presentation = EdgeStateDemoData.presentation(for: .timingUnverified)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        XCTAssertFalse(combined.contains("on time"))
        XCTAssertFalse(combined.contains("submitted on time"))
    }

    func testTimingUnverifiedNeverUsesDishonestyOrCheatingLanguage() {
        let presentation = EdgeStateDemoData.presentation(for: .timingUnverified)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        for forbidden in ["dishonest", "cheat", "lied", "lying"] {
            XCTAssertFalse(combined.contains(forbidden), "Must not contain '\(forbidden)'")
        }
    }

    func testTimingUnverifiedOffersApproveNeedsMoreWorkAndAskOneQuestion() {
        let presentation = EdgeStateDemoData.presentation(for: .timingUnverified)
        let titles = Set(presentation.actions.map(\.title))
        XCTAssertTrue(titles.contains(EdgeStateCopy.timingActionApprove))
        XCTAssertTrue(titles.contains(EdgeStateCopy.timingActionNeedsMoreWork))
        XCTAssertTrue(titles.contains(EdgeStateCopy.timingActionAskOneQuestion))
    }

    // MARK: 9-10. Timing approved

    func testTimingApprovedOutcomeIsExactlyApprovedTimingUnverified() {
        let presentation = EdgeStateDemoData.presentation(for: .timingApproved)
        XCTAssertEqual(presentation.title, "Approved, timing unverified")
        XCTAssertEqual(presentation.statusLabel, "Approved, timing unverified")
    }

    func testTimingApprovedIsNotRewrittenToOnTime() {
        let presentation = EdgeStateDemoData.presentation(for: .timingApproved)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        XCTAssertFalse(combined.contains("submitted on time"))
        XCTAssertFalse(combined.contains("on time"))
    }

    func testTimingApprovedNeverClaimsEverythingUnlocked() {
        let presentation = EdgeStateDemoData.presentation(for: .timingApproved)
        XCTAssertFalse(presentation.message.lowercased().contains("everything unlocked"))
        XCTAssertFalse(presentation.message.lowercased().contains("everything is unlocked"))
    }

    // MARK: 11. Timing ask: bounded clarification only

    func testTimingAskSupportsAtMostOneQuestionAndOneReplyConcept() {
        let message = EdgeStateCopy.timingAskExplanation.lowercased()
        XCTAssertTrue(message.contains("one question"))
        XCTAssertTrue(message.contains("one reply"))
        XCTAssertFalse(message.contains("open chat"))
        XCTAssertFalse(message.contains("messaging"))
    }

    // MARK: T-002 timing (Activity presentation)

    func testActivityTimingPreservesApprovedTimingUnverifiedOutcome() {
        let presentation = EdgeStateDemoData.presentation(for: .activityTiming)
        XCTAssertEqual(presentation.statusLabel, "Approved, timing unverified")
        let combined = (presentation.title + " " + presentation.message).lowercased()
        XCTAssertFalse(combined.contains("on time"))
        XCTAssertFalse(combined.contains(" late"))
    }

    // MARK: 12. C-004 Timing (child) contains no blame/cheating language

    func testChildTimingContainsNoBlameOrCheatingLanguage() {
        let presentation = EdgeStateDemoData.presentation(for: .childTimingUnverified)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        for forbidden in ["late", "lied", "lying", "cheat", "dishonest", "wrong", "your time was wrong"] {
            XCTAssertFalse(combined.contains(forbidden), "Must not contain '\(forbidden)'")
        }
    }

    func testChildTimingDoesNotRevealAntiTamperingDetails() {
        let presentation = EdgeStateDemoData.presentation(for: .childTimingUnverified)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        for forbidden in ["clock", "tamper", "monotonic", "spoof"] {
            XCTAssertFalse(combined.contains(forbidden), "Must not contain '\(forbidden)'")
        }
    }

    // MARK: 13. C-004 Queued

    func testChildQueuedNeverPromisesOnTimeCredit() {
        let presentation = EdgeStateDemoData.presentation(for: .childQueuedOffline)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        XCTAssertFalse(combined.contains("counts as on time"))
        XCTAssertFalse(combined.contains("will count as on time"))
    }

    func testChildQueuedPreservesTrustedTimePrinciple() {
        let presentation = EdgeStateDemoData.presentation(for: .childQueuedOffline)
        XCTAssertTrue(presentation.message.contains("The time you pressed it is saved"))
    }

    // MARK: C-001 Offline

    func testChildOfflineNeverClaimsProtectedOrInstantSync() {
        let presentation = EdgeStateDemoData.presentation(for: .childOffline)
        XCTAssertEqual(presentation.statusKind, .deviceOffline)
        let combined = presentation.message.lowercased()
        XCTAssertFalse(combined.contains("protected"))
        XCTAssertFalse(combined.contains("everything will update instantly"))
        XCTAssertFalse(combined.contains("all restrictions are definitely current"))
    }

    // MARK: Q-006 Offline

    func testRequestSavedOfflineNeverClaimsParentHasReceivedIt() {
        let presentation = EdgeStateDemoData.presentation(for: .requestSavedOffline)
        let combined = presentation.message.lowercased()
        XCTAssertFalse(combined.contains("sarah has seen it"))
        XCTAssertFalse(combined.contains("parent has received"))
        XCTAssertFalse(combined.contains("notification sent"))
        XCTAssertFalse(combined.contains("approval pending"))
    }

    func testRequestSavedOfflineDoesNotImplementRealNetworking() {
        // Presentation-only: there must be no actions that imply live network retry.
        let presentation = EdgeStateDemoData.presentation(for: .requestSavedOffline)
        XCTAssertTrue(presentation.actions.isEmpty)
    }

    // MARK: C-001 Permission

    func testChildPermissionDoesNotBlameTheChild() {
        let presentation = EdgeStateDemoData.presentation(for: .childPermissionNeeded)
        let combined = presentation.message.lowercased()
        XCTAssertFalse(combined.contains("you turned off"))
        XCTAssertFalse(combined.contains("your fault"))
    }

    func testChildPermissionUsesProtectionUnavailableStatus() {
        let presentation = EdgeStateDemoData.presentation(for: .childPermissionNeeded)
        XCTAssertEqual(presentation.statusKind, .protectionUnavailable)
    }

    // MARK: C-001 Removed

    func testChildDeviceRemovedNeverShowsProtected() {
        let presentation = EdgeStateDemoData.presentation(for: .childDeviceRemoved)
        XCTAssertFalse(presentation.title.lowercased().contains("protected"))
        XCTAssertFalse(presentation.message.lowercased().contains("protected"))
    }

    // MARK: P-010 Interrupted

    func testPairingInterruptedProvidesRetryAndNeverClaimsConnected() {
        let presentation = EdgeStateDemoData.presentation(for: .pairingInterrupted)
        XCTAssertFalse(presentation.actions.isEmpty)
        let combined = presentation.message.lowercased()
        XCTAssertFalse(combined.contains("connected"))
        XCTAssertFalse(combined.contains("protected"))
        XCTAssertFalse(combined.contains("paired"))
    }

    // MARK: E-007 Abandoned

    func testSessionAbandonedUsesConfirmedTwentyFourHourCeiling() {
        XCTAssertEqual(EdgeStateCopy.sessionAbandonedCeilingHours, 24)
    }

    func testSessionAbandonedAwardsNoCompletionCreditAndNoBlame() {
        let presentation = EdgeStateDemoData.presentation(for: .sessionAbandoned)
        let combined = presentation.message.lowercased()
        XCTAssertFalse(combined.contains("completed"))
        XCTAssertFalse(combined.contains("failed"))
        XCTAssertFalse(combined.contains("you didn't"))
    }

    // MARK: A-004 Send failed

    func testDecisionNotSentNeverClaimsAppliedOrApprovedOrResolved() {
        let presentation = EdgeStateDemoData.presentation(for: .decisionSendFailed)
        let combined = (presentation.title + " " + presentation.message).lowercased()
        for forbidden in ["approved", "applied", "declined", "resolved"] {
            XCTAssertFalse(combined.contains(forbidden), "Must not contain '\(forbidden)'")
        }
    }

    func testDecisionNotSentOffersRetryAndDoesNotDiscard() {
        let presentation = EdgeStateDemoData.presentation(for: .decisionSendFailed)
        XCTAssertTrue(presentation.actions.contains { $0.title == EdgeStateCopy.decisionNotSentRetry })
        XCTAssertTrue(presentation.message.lowercased().contains("nothing was discarded"))
    }

    // MARK: P-012 External revoke

    func testExternalRevokeNeverClaimsRealTimeDetection() {
        let presentation = EdgeStateDemoData.presentation(for: .permissionRevokedExternally)
        let combined = presentation.message.lowercased()
        XCTAssertTrue(combined.contains("next time"))
        XCTAssertFalse(combined.contains("immediately detected"))
        XCTAssertFalse(combined.contains("in real time"))
    }

    func testExternalRevokeMovesToProtectionUnavailable() {
        let presentation = EdgeStateDemoData.presentation(for: .permissionRevokedExternally)
        XCTAssertEqual(presentation.statusKind, .protectionUnavailable)
    }

    // MARK: Global safety invariants across all 17 states

    func testNoStateEverShowsProtectedWhenUnavailableOrOffline() {
        let unsafeScenarios: [EdgeStateScenario] = [
            .serversUnreachable, .childOffline, .childPermissionNeeded, .childDeviceRemoved,
            .permissionRevokedExternally
        ]
        for scenario in unsafeScenarios {
            let presentation = EdgeStateDemoData.presentation(for: scenario)
            XCTAssertNotEqual(presentation.statusKind, .accessRevoked)
            XCTAssertFalse(
                presentation.title.lowercased() == "protected",
                "\(scenario.rawValue) must never title itself Protected"
            )
        }
    }

    func testNoStateUsesRawNetworkOrHTTPDiagnosticLanguage() {
        for presentation in EdgeStateDemoData.all {
            let combined = (presentation.title + " " + presentation.message).lowercased()
            for forbidden in ["http 500", "request failed", "network exception", "null pointer"] {
                XCTAssertFalse(combined.contains(forbidden), "\(presentation.id.rawValue) must not contain '\(forbidden)'")
            }
        }
    }

    func testNoScenarioIsDuplicatedAcrossTheCatalogue() {
        let ids = EdgeStateDemoData.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }
}


    func testApprovedAudienceMappingForTeenAndChildEdgeStates() {
        XCTAssertEqual(EdgeStateScenario.requestSavedOffline.audience, .teen)
        XCTAssertEqual(
            EdgeStateDemoData.presentation(for: .requestSavedOffline).audience,
            .teen
        )
        XCTAssertEqual(EdgeStateScenario.sessionAbandoned.audience, .child)
        XCTAssertEqual(
            EdgeStateDemoData.presentation(for: .sessionAbandoned).audience,
            .child
        )
    }

    func testServersUnreachableUsesApprovedUnconfirmedStatus() {
        let presentation = EdgeStateDemoData.presentation(for: .serversUnreachable)
        XCTAssertEqual(presentation.statusKind, .unconfirmed)
        XCTAssertEqual(presentation.statusLabel, "Unconfirmed")
        XCTAssertNotNil(presentation.lastVerifiedText)
    }

    func testQueuedOfflineCopyDoesNotPromiseImmediateSendTiming() {
        let message = EdgeStateCopy.childQueuedMessage.lowercased()
        XCTAssertFalse(message.contains("as soon as"))
        XCTAssertTrue(message.contains("wait to send"))
    }

    func testPairingInterruptedDoesNotClaimThereIsNothingPartialToUndo() {
        let message = EdgeStateCopy.pairingInterruptedMessage.lowercased()
        XCTAssertFalse(message.contains("nothing partial to undo"))
        XCTAssertTrue(message.contains("hasn't confirmed"))
    }
