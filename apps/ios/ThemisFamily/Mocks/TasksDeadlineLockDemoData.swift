import Foundation

enum TasksDeadlineLockDemoData {
    static let homeworkSubmissionRoute = TaskSubmissionRoute.parentApproval(taskOwnerID: DemoData.samID)

    static let taskDetail = TaskDeadlineLockPresentation(
        screenID: "C-002",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Due at 6:00 PM",
        status: .due,
        headline: "Homework",
        message: "Finish your homework before 6:00 PM. If it is overdue, Roblox and Minecraft pause.",
        submission: .notSubmitted,
        decision: .none,
        deadlinePhase: .beforeDeadline,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let submitTask = TaskDeadlineLockPresentation(
        screenID: "C-003",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Due at 6:00 PM",
        status: .due,
        headline: "Ready to submit?",
        message: "Your parent or carer will review your homework submission.",
        submission: .notSubmitted,
        decision: .none,
        deadlinePhase: .beforeDeadline,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let submittingOffline = TaskDeadlineLockPresentation(
        screenID: "C-003 · Offline",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Due at 6:00 PM",
        status: ThemisStatus(.waiting, label: "Submitting…"),
        headline: "Submitting…",
        message: "Your completion will wait to send when Themis reconnects. It has not been recorded for approval yet.",
        submission: .submitting,
        decision: .none,
        deadlinePhase: .beforeDeadline,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let submittedOnTime = TaskDeadlineLockPresentation(
        screenID: "C-004",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted before 6:00 PM",
        status: .waiting,
        headline: "Submitted on time",
        message: "Waiting for approval.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .beforeDeadline,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let approvalGrace = TaskDeadlineLockPresentation(
        screenID: "C-005",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Deadline passed at 6:00 PM",
        status: .grace,
        headline: "Submitted on time. Waiting for approval.",
        message: "Approval grace ends in 18 min. Roblox and Minecraft stay available during this grace period.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .grace,
        graceMinutesRemaining: 18,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let approved = TaskDeadlineLockPresentation(
        screenID: "C-006",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Approved",
        status: .approved,
        headline: "Homework approved",
        message: "The homework restriction is cleared. Access is available only where no other family rule still applies.",
        submission: .recorded,
        decision: .approved,
        deadlinePhase: .cleared,
        graceMinutesRemaining: nil,
        deviceApplication: .applied,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let overdue = TaskDeadlineLockPresentation(
        screenID: "C-007",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Was due at 6:00 PM",
        status: .overdue,
        headline: "Homework is overdue",
        message: "You can still submit it for review.",
        submission: .notSubmitted,
        decision: .none,
        deadlinePhase: .restricted,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [.homeworkDeadline],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let gamesPaused = TaskDeadlineLockPresentation(
        screenID: "C-008",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Was due at 6:00 PM",
        status: .overdue,
        headline: "Games are paused",
        message: "Homework was due at 6:00 PM. Submit it when you are ready. Your configured school and essential access stays available.",
        submission: .notSubmitted,
        decision: .none,
        deadlinePhase: .restricted,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [.homeworkDeadline],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let submitWhileRestricted = TaskDeadlineLockPresentation(
        screenID: "C-009",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted after 6:00 PM",
        status: .overdue,
        headline: "Submit for review",
        message: "Games stay paused while your parent or carer reviews this submission.",
        submission: .notSubmitted,
        decision: .none,
        deadlinePhase: .restricted,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [.homeworkDeadline],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let waitingRestricted = TaskDeadlineLockPresentation(
        screenID: "C-010",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted after 6:00 PM",
        status: .waiting,
        headline: "Waiting for approval",
        message: "Games are paused until this is reviewed.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .restricted,
        graceMinutesRemaining: nil,
        deviceApplication: .notApplicable,
        activeRestrictions: [.homeworkDeadline],
        reminder: TaskReminderState(automaticReminderSent: true, manualNudgeSent: false),
        parentNote: nil
    )

    static let multipleRestrictions = TaskDeadlineLockPresentation(
        screenID: "C-011",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Homework approved",
        status: ThemisStatus(.cleared, label: "Homework cleared"),
        headline: "Homework done. Games are still paused.",
        message: "The homework restriction is cleared, but the bedtime rule is still active.",
        submission: .recorded,
        decision: .approved,
        deadlinePhase: .cleared,
        graceMinutesRemaining: nil,
        deviceApplication: .applied,
        activeRestrictions: [.bedtime],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let actionCentre = TaskDeadlineLockPresentation(
        screenID: "A-001",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted before 6:00 PM",
        status: .needsYou,
        headline: "Sam sent homework for review",
        message: "18 min of approval grace remains.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .grace,
        graceMinutesRemaining: 18,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let parentActionReceived = TaskDeadlineLockPresentation(
        screenID: "P-024",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted before 6:00 PM",
        status: .needsYou,
        headline: "Sam sent homework for review",
        message: "Open the task to approve it or send it back for more work.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .grace,
        graceMinutesRemaining: 18,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let parentTaskReview = TaskDeadlineLockPresentation(
        screenID: "P-025",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted before 6:00 PM",
        status: .needsYou,
        headline: "Review Sam’s homework",
        message: "Sam submitted before the deadline. Approval grace has 18 min remaining.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .grace,
        graceMinutesRemaining: 18,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let taskReview = TaskDeadlineLockPresentation(
        screenID: "A-002",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Submitted before 6:00 PM",
        status: .needsYou,
        headline: "Review Sam’s homework",
        message: "Sam submitted before the deadline. Approval grace has 18 min remaining.",
        submission: .recorded,
        decision: .awaitingApproval,
        deadlinePhase: .grace,
        graceMinutesRemaining: 18,
        deviceApplication: .notApplicable,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let approvalRecorded = TaskDeadlineLockPresentation(
        screenID: "P-026",
        audience: .child,
        childName: "Sam",
        taskTitle: "Homework",
        deadlineText: "Decision recorded",
        status: .approved,
        headline: "Approved",
        message: "Your approval is recorded. Themis is sending the resulting change to Sam’s iPhone.",
        submission: .recorded,
        decision: .approved,
        deadlinePhase: .cleared,
        graceMinutesRemaining: nil,
        deviceApplication: .pending,
        activeRestrictions: [],
        reminder: TaskReminderState(automaticReminderSent: false, manualNudgeSent: false),
        parentNote: nil
    )

    static let approvedPendingDevice: TaskDeadlineLockPresentation = {
        let value = parentTaskReview.applyingApproval(deviceAcknowledged: false)
        return TaskDeadlineLockPresentation(
            screenID: "P-027",
            audience: value.audience,
            childName: value.childName,
            taskTitle: value.taskTitle,
            deadlineText: value.deadlineText,
            status: value.status,
            headline: value.headline,
            message: value.message,
            submission: value.submission,
            decision: value.decision,
            deadlinePhase: value.deadlinePhase,
            graceMinutesRemaining: value.graceMinutesRemaining,
            deviceApplication: value.deviceApplication,
            activeRestrictions: value.activeRestrictions,
            reminder: value.reminder,
            parentNote: value.parentNote
        )
    }()

    static let appliedOnDevice: TaskDeadlineLockPresentation = {
        let value = parentTaskReview.applyingApproval(deviceAcknowledged: true)
        return TaskDeadlineLockPresentation(
            screenID: "P-028",
            audience: value.audience,
            childName: value.childName,
            taskTitle: value.taskTitle,
            deadlineText: value.deadlineText,
            status: value.status,
            headline: value.headline,
            message: value.message,
            submission: value.submission,
            decision: value.decision,
            deadlinePhase: value.deadlinePhase,
            graceMinutesRemaining: value.graceMinutesRemaining,
            deviceApplication: value.deviceApplication,
            activeRestrictions: value.activeRestrictions,
            reminder: value.reminder,
            parentNote: value.parentNote
        )
    }()

    static let needsWork = taskReview.rejectingDuringGrace(note: "Please finish the last question.")
}
