import XCTest
@testable import ThemisFamily

final class TasksDeadlineLockTests: XCTestCase {
    func testOnlyTaskOwnerCanSubmitCanonicalHomework() {
        let route = TasksDeadlineLockDemoData.homeworkSubmissionRoute
        XCTAssertTrue(route.maySubmit(actorID: DemoData.samID))
        XCTAssertFalse(route.maySubmit(actorID: DemoData.mayaID))
    }

    func testSubmissionRoutesToAllEligibleAdultApprovers() {
        XCTAssertEqual(
            TasksDeadlineLockDemoData.homeworkSubmissionRoute.approversToNotify,
            [.owner, .guardian]
        )
    }

    func testHomeworkUsesParentApprovalPresentation() {
        let state = TasksDeadlineLockDemoData.taskDetail
        XCTAssertEqual(state.taskTitle, "Homework")
        XCTAssertEqual(state.decision, .none)
        XCTAssertEqual(state.screenID, "C-002")
    }

    func testOfflineSubmissionIsNotAwaitingApproval() {
        let state = TasksDeadlineLockDemoData.submittingOffline
        XCTAssertEqual(state.submission, .submitting)
        XCTAssertEqual(state.decision, .none)
        XCTAssertEqual(state.status.label, "Submitting…")
        XCTAssertFalse(state.message.localizedCaseInsensitiveContains("waiting for approval"))
    }

    func testApprovalGraceIsFixedAtThirtyMinutes() {
        let state = TasksDeadlineLockDemoData.approvalGrace
        XCTAssertEqual(state.deadlinePhase, .grace)
        XCTAssertEqual(state.graceLengthMinutes, 30)
        XCTAssertEqual(state.graceMinutesRemaining, 18)
        XCTAssertTrue(state.activeRestrictions.isEmpty)
    }

    func testApprovalDuringGraceAvoidsDeadlineLock() {
        let approved = TasksDeadlineLockDemoData.approvalGrace.applyingApproval(deviceAcknowledged: false)
        XCTAssertEqual(approved.decision, .approved)
        XCTAssertEqual(approved.deadlinePhase, .cleared)
        XCTAssertFalse(approved.activeRestrictions.contains(.homeworkDeadline))
        XCTAssertEqual(approved.deviceApplication, .pending)
        XCTAssertFalse(approved.mayClaimUnlocked)
    }

    func testGraceExpiryActivatesDeadlineLock() {
        let expired = TasksDeadlineLockDemoData.approvalGrace.expiringGrace()
        XCTAssertEqual(expired.deadlinePhase, .restricted)
        XCTAssertEqual(expired.decision, .awaitingApproval)
        XCTAssertTrue(expired.activeRestrictions.contains(.homeworkDeadline))
        XCTAssertFalse(expired.isEffectivelyAvailable)
    }

    func testRejectionDuringGraceActivatesDeadlineLockImmediately() {
        let rejected = TasksDeadlineLockDemoData.taskReview.rejectingDuringGrace(note: nil)
        XCTAssertEqual(rejected.decision, .needsWork)
        XCTAssertEqual(rejected.deadlinePhase, .restricted)
        XCTAssertTrue(rejected.activeRestrictions.contains(.homeworkDeadline))
        XCTAssertNil(rejected.parentNote)
    }

    func testNeedsWorkNoteIsOptionalAndOneWayPresentationData() {
        let withoutNote = TasksDeadlineLockDemoData.taskReview.rejectingDuringGrace(note: nil)
        let withNote = TasksDeadlineLockDemoData.taskReview.rejectingDuringGrace(note: "Finish the last question.")
        XCTAssertNil(withoutNote.parentNote)
        XCTAssertEqual(withNote.parentNote, "Finish the last question.")
    }

    func testApprovalRecordedDoesNotEqualDeviceApplied() {
        let pending = TasksDeadlineLockDemoData.approvedPendingDevice
        XCTAssertEqual(pending.decision, .approved)
        XCTAssertEqual(pending.deviceApplication, .pending)
        XCTAssertEqual(pending.screenID, "P-027")
        XCTAssertNotEqual(pending.screenID, "P-028")
        XCTAssertFalse(pending.mayClaimUnlocked)

        let applied = TasksDeadlineLockDemoData.appliedOnDevice
        XCTAssertEqual(applied.deviceApplication, .applied)
        XCTAssertEqual(applied.screenID, "P-028")
        XCTAssertTrue(applied.mayClaimUnlocked)
    }

    func testMultipleRestrictionsPreventFalseUnlock() {
        let state = TasksDeadlineLockDemoData.multipleRestrictions
        XCTAssertEqual(state.decision, .approved)
        XCTAssertEqual(state.status.label, "Homework cleared")
        XCTAssertNotEqual(state.status.kind, .overdue)
        XCTAssertEqual(state.activeRestrictions, [.bedtime])
        XCTAssertFalse(state.isEffectivelyAvailable)
        XCTAssertFalse(state.mayClaimUnlocked)
        XCTAssertTrue(state.message.localizedCaseInsensitiveContains("bedtime"))
    }

    func testApprovalClearsOnlyDeadlineLock() {
        let pending = TaskDeadlineLockPresentation(
            screenID: "A-002",
            audience: .child,
            childName: "Sam",
            taskTitle: "Homework",
            deadlineText: "Submitted",
            status: .needsYou,
            headline: "Review",
            message: "Review",
            submission: .recorded,
            decision: .awaitingApproval,
            deadlinePhase: .restricted,
            graceMinutesRemaining: nil,
            deviceApplication: .notApplicable,
            activeRestrictions: [.homeworkDeadline, .bedtime],
            reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
            parentNote: nil
        )

        let applied = pending.applyingApproval(deviceAcknowledged: true)
        XCTAssertFalse(applied.activeRestrictions.contains(.homeworkDeadline))
        XCTAssertTrue(applied.activeRestrictions.contains(.bedtime))
        XCTAssertFalse(applied.isEffectivelyAvailable)
        XCTAssertFalse(applied.mayClaimUnlocked)
    }

    func testAutomaticReminderIntervalIsFifteenMinutes() {
        XCTAssertEqual(TaskReminderState.automaticReminderMinutes, 15)
    }

    func testOwnerAndGuardianCanDecideButChildAndTeenCannot() {
        XCTAssertTrue(TaskApproverRole.owner.canDecide)
        XCTAssertTrue(TaskApproverRole.guardian.canDecide)
        XCTAssertFalse(TaskApproverRole.child.canDecide)
        XCTAssertFalse(TaskApproverRole.teen.canDecide)
    }

    func testFirstValidAdultDecisionWins() {
        var ledger = TaskDecisionLedger()
        XCTAssertEqual(
            ledger.record(.approve, by: .guardian),
            .recorded(.approve, by: .guardian)
        )
        XCTAssertEqual(
            ledger.record(.needsWork, by: .owner),
            .alreadyResolved(.approve, by: .guardian)
        )
        XCTAssertEqual(ledger.decision, .approve)
        XCTAssertEqual(ledger.decidedBy, .guardian)
    }

    func testUnauthorisedDecisionDoesNotResolveTask() {
        var ledger = TaskDecisionLedger()
        XCTAssertEqual(ledger.record(.approve, by: .child), .notAuthorised)
        XCTAssertNil(ledger.decision)
        XCTAssertNil(ledger.decidedBy)
    }

    func testSendingManualReminderIsBoundedToPresentationState() {
        let sent = TasksDeadlineLockDemoData.submittedOnTime.sendingManualReminder()
        XCTAssertTrue(sent.reminder.manualNudgeSent)
        XCTAssertFalse(sent.reminder.canSendManualNudge)
        XCTAssertEqual(sent.reminder.automaticReminderSent, TasksDeadlineLockDemoData.submittedOnTime.reminder.automaticReminderSent)
        XCTAssertEqual(sent.decision, .awaitingApproval)
    }

    func testManualNudgeAndAutomaticReminderAreIndependent() {
        let neither = TaskReminderState(automaticReminderSent: false, manualNudgeSent: false)
        let automaticOnly = TaskReminderState(automaticReminderSent: true, manualNudgeSent: false)
        let manualOnly = TaskReminderState(automaticReminderSent: false, manualNudgeSent: true)

        XCTAssertTrue(neither.canSendManualNudge)
        XCTAssertTrue(automaticOnly.canSendManualNudge)
        XCTAssertFalse(manualOnly.canSendManualNudge)
    }

    func testAwaitingApprovalDoesNotAutoApprove() {
        let waiting = TasksDeadlineLockDemoData.waitingRestricted
        XCTAssertEqual(waiting.decision, .awaitingApproval)
        XCTAssertNotEqual(waiting.decision, .approved)
        XCTAssertTrue(waiting.activeRestrictions.contains(.homeworkDeadline))
    }

    func testAlwaysAllowedRemainsAbsoluteAgainstRestrictiveRules() {
        let target = RulesSchoolAccessDemoData.schoolPortal
        let restrictiveRule = RulesSchoolAccessDemoData.deadlineLock
        let result = RulesSchoolAccessPolicy.applyAlwaysAllowed(
            target: target,
            to: [restrictiveRule],
            currentAlwaysAllowed: []
        )

        XCTAssertTrue(result.state.targets.contains(where: { $0.id == target.id }))
        XCTAssertFalse(result.rules[0].targets.contains(where: { $0.id == target.id }))
        XCTAssertFalse(
            RulesSchoolAccessPolicy.canAddRestrictedTarget(
                target,
                alwaysAllowed: result.state.targets
            )
        )
    }

    func testAlwaysAllowedBoundaryRemainsOutsideRestrictionList() {
        for state in [
            TasksDeadlineLockDemoData.gamesPaused,
            TasksDeadlineLockDemoData.waitingRestricted,
            TasksDeadlineLockDemoData.multipleRestrictions
        ] {
            XCTAssertFalse(state.activeRestrictions.map(\.rawValue).contains { value in
                value.localizedCaseInsensitiveContains("always allowed")
            })
        }
    }
}
