import XCTest
@testable import ThemisFamily

final class RequestsTests: XCTestCase {
    func testOfflineSubmissionIsSendingNotPending() {
        let state = RequestsDemoData.sendingOffline
        XCTAssertEqual(state.lifecycle, .sending)
        XCTAssertEqual(state.status.label, "Waiting to send")
        XCTAssertNotEqual(state.lifecycle, .pending)
        XCTAssertTrue(state.message.localizedCaseInsensitiveContains("not Pending"))
    }

    func testOnlyRequestOwnerMaySubmit() {
        let route = RequestsDemoData.mayaRoute
        XCTAssertTrue(route.maySubmit(actorID: DemoData.mayaID))
        XCTAssertFalse(route.maySubmit(actorID: DemoData.samID))
    }

    func testConfirmedRequestNotifiesEligibleAdults() {
        XCTAssertEqual(RequestsDemoData.mayaRoute.approversToNotify, [.owner, .guardian])
    }

    func testAllScopedDecisionAndReminderScreensAreExplicit() {
        XCTAssertEqual(RequestsDemoData.reminderSent.screenID, "Q-007")
        XCTAssertEqual(RequestsDemoData.parentApprove.screenID, "A-005")
        XCTAssertEqual(RequestsDemoData.parentPartial.screenID, "A-006")
        XCTAssertEqual(RequestsDemoData.parentDecline.screenID, "A-007")
        XCTAssertEqual(RequestsDemoData.waitingForReply.screenID, "A-009")
    }

    func testAutomaticReminderIntervalIsFifteenMinutes() {
        XCTAssertEqual(RequestReminderState.automaticReminderMinutes, 15)
    }

    func testManualNudgeIsCappedAtOneAndIndependent() {
        var state = RequestsDemoData.pending
        state.reminder.automaticReminderSent = true
        let nudged = state.sendingManualNudge()
        XCTAssertTrue(nudged.reminder.automaticReminderSent)
        XCTAssertTrue(nudged.reminder.manualNudgeSent)
        XCTAssertFalse(nudged.reminder.canSendManualNudge)
        XCTAssertEqual(nudged.sendingManualNudge(), nudged)
    }

    func testClarificationIsExactlyOneQuestionAndOneReply() {
        let asked = RequestsDemoData.parentDetail.askingClarification("How much longer?")
        XCTAssertEqual(asked.clarification.question, "How much longer?")
        XCTAssertFalse(asked.canAskClarification)
        XCTAssertTrue(asked.canReplyClarification)

        let replied = asked.replyingToClarification("Ten minutes.")
        XCTAssertEqual(replied.clarification.reply, "Ten minutes.")
        XCTAssertTrue(replied.clarification.roundComplete)
        XCTAssertFalse(replied.canReplyClarification)
        XCTAssertEqual(replied.askingClarification("Second question"), replied)
    }

    func testClarificationDoesNotBlockAdultDecision() {
        let waiting = RequestsDemoData.waitingForReply
        let decided = waiting.applyingDecision(.approve, grantedMinutes: 15, deviceAcknowledged: false)
        XCTAssertEqual(decided.lifecycle, .approved)
        XCTAssertEqual(decided.deviceApplication, .pending)
    }

    func testFirstValidAdultDecisionWins() {
        var ledger = RequestDecisionLedger()
        XCTAssertEqual(ledger.record(.approve, by: .guardian), .recorded(.approve, by: .guardian))
        XCTAssertEqual(ledger.record(.decline, by: .owner), .alreadyResolved(.approve, by: .guardian))
        XCTAssertEqual(ledger.decision, .approve)
    }

    func testChildCannotResolveRequest() {
        var ledger = RequestDecisionLedger()
        XCTAssertEqual(ledger.record(.approve, by: .teen), .notAuthorised)
        XCTAssertNil(ledger.decision)
    }

    func testPartialApprovalPreservesRequestedAndGrantedDuration() {
        let state = RequestsDemoData.partial
        XCTAssertEqual(state.requestedMinutes, 30)
        XCTAssertEqual(state.grantedMinutes, 15)
        XCTAssertEqual(state.lifecycle, .partiallyApproved)
        XCTAssertEqual(state.status.kind, .partiallyApproved)
    }

    func testExpiryPreventsStaleApproval() {
        let expired = RequestsDemoData.pending.expiring()
        XCTAssertEqual(expired.lifecycle, .expired)
        XCTAssertEqual(expired.applyingDecision(.approve, grantedMinutes: 15), expired)
    }

    func testCancellationOnlyAppliesWhilePending() {
        let cancelled = RequestsDemoData.pending.cancelling()
        XCTAssertEqual(cancelled.lifecycle, .cancelled)
        XCTAssertEqual(RequestsDemoData.approved.cancelling(), RequestsDemoData.approved)
    }

    func testApprovedAndAppliedRemainSeparate() {
        let pending = RequestsDemoData.parentDetail.applyingDecision(.approve, grantedMinutes: 15, deviceAcknowledged: false)
        XCTAssertEqual(pending.lifecycle, .approved)
        XCTAssertEqual(pending.deviceApplication, .pending)
        XCTAssertFalse(pending.mayClaimTargetAvailable)

        let applied = RequestsDemoData.parentDetail.applyingDecision(.approve, grantedMinutes: 15, deviceAcknowledged: true)
        XCTAssertEqual(applied.deviceApplication, .applied)
        XCTAssertTrue(applied.mayClaimTargetAvailable)
    }

    func testAnotherRestrictionPreventsFalseAvailabilityClaim() {
        let applied = RequestsDemoData.parentDetail.applyingDecision(
            .approve,
            grantedMinutes: 15,
            deviceAcknowledged: true,
            remainingRestrictions: [.bedtime]
        )
        XCTAssertEqual(applied.deviceApplication, .applied)
        XCTAssertFalse(applied.mayClaimTargetAvailable)
        XCTAssertEqual(applied.remainingRestrictions, [.bedtime])
    }

    func testEveryDemoRequestHasSpecificTarget() {
        for state in [
            RequestsDemoData.pending,
            RequestsDemoData.approved,
            RequestsDemoData.partial,
            RequestsDemoData.schoolTemporaryAccess
        ] {
            XCTAssertFalse(state.target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    func testSchoolTemporaryAccessUsesSameRequestLifecycle() {
        XCTAssertEqual(RequestsDemoData.schoolTemporaryAccess.type, .temporaryAccess)
        XCTAssertEqual(RequestsDemoData.schoolTemporaryAccess.lifecycle, .pending)
        XCTAssertEqual(RequestsDemoData.schoolTemporaryAccess.reminder, RequestsDemoData.pending.reminder)
    }
}
