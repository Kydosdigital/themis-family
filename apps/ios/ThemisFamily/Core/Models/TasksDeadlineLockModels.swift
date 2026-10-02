import Foundation

enum TaskSubmissionTransportState: String, Equatable, Sendable {
    case notSubmitted
    case submitting
    case recorded
}

enum TaskDecisionState: String, Equatable, Sendable {
    case none
    case awaitingApproval
    case approved
    case needsWork
}

enum TaskDeviceApplicationState: String, Equatable, Sendable {
    case notApplicable
    case pending
    case applied
}

enum DeadlineLockPhase: String, Equatable, Sendable {
    case beforeDeadline
    case grace
    case restricted
    case cleared
}

enum TaskRestrictionReason: String, CaseIterable, Hashable, Sendable {
    case homeworkDeadline = "Homework is overdue"
    case bedtime = "Bedtime rule is active"
    case earnFirst = "Earn First is still active"
}

struct TaskReminderState: Equatable, Sendable {
    static let automaticReminderMinutes = 15

    var automaticReminderSent: Bool
    var manualNudgeSent: Bool

    var canSendManualNudge: Bool { !manualNudgeSent }
}

struct TaskDeadlineLockPresentation: Equatable, Sendable {
    let screenID: String
    let audience: ExperienceSegment
    let childName: String
    let taskTitle: String
    let deadlineText: String
    let status: ThemisStatus
    let headline: String
    let message: String
    let submission: TaskSubmissionTransportState
    let decision: TaskDecisionState
    let deadlinePhase: DeadlineLockPhase
    let graceMinutesRemaining: Int?
    let deviceApplication: TaskDeviceApplicationState
    let activeRestrictions: [TaskRestrictionReason]
    let reminder: TaskReminderState
    let parentNote: String?

    var isEffectivelyAvailable: Bool {
        activeRestrictions.isEmpty
    }

    var mayClaimUnlocked: Bool {
        isEffectivelyAvailable && deviceApplication != .pending
    }

    var graceLengthMinutes: Int { ApprovalGraceWindow.approvedLengthMinutes }

    func applyingApproval(deviceAcknowledged: Bool) -> TaskDeadlineLockPresentation {
        let remainingRestrictions = activeRestrictions.filter { $0 != .homeworkDeadline }
        return TaskDeadlineLockPresentation(
            screenID: deviceAcknowledged ? "P-028" : "P-027",
            audience: audience,
            childName: childName,
            taskTitle: taskTitle,
            deadlineText: deadlineText,
            status: deviceAcknowledged ? .appliedOnDevice : .applying,
            headline: deviceAcknowledged ? "Applied on device" : "Approved",
            message: deviceAcknowledged
                ? (remainingRestrictions.isEmpty
                    ? "The homework restriction is cleared on \(childName)’s iPhone."
                    : "Homework is cleared. Another family rule still keeps some access paused.")
                : "Approval is recorded. Waiting for \(childName)’s iPhone to confirm the change.",
            submission: .recorded,
            decision: .approved,
            deadlinePhase: remainingRestrictions.contains(.homeworkDeadline) ? .restricted : .cleared,
            graceMinutesRemaining: nil,
            deviceApplication: deviceAcknowledged ? .applied : .pending,
            activeRestrictions: remainingRestrictions,
            reminder: reminder,
            parentNote: nil
        )
    }

    func rejectingDuringGrace(note: String?) -> TaskDeadlineLockPresentation {
        var restrictions = activeRestrictions
        if !restrictions.contains(.homeworkDeadline) {
            restrictions.append(.homeworkDeadline)
        }
        return TaskDeadlineLockPresentation(
            screenID: "A-003",
            audience: audience,
            childName: childName,
            taskTitle: taskTitle,
            deadlineText: deadlineText,
            status: .overdue,
            headline: "Needs more work",
            message: "The homework Deadline Lock is active now. \(childName) can submit again when ready.",
            submission: .recorded,
            decision: .needsWork,
            deadlinePhase: .restricted,
            graceMinutesRemaining: nil,
            deviceApplication: .notApplicable,
            activeRestrictions: restrictions,
            reminder: reminder,
            parentNote: note
        )
    }

    func expiringGrace() -> TaskDeadlineLockPresentation {
        var restrictions = activeRestrictions
        if !restrictions.contains(.homeworkDeadline) {
            restrictions.append(.homeworkDeadline)
        }
        return TaskDeadlineLockPresentation(
            screenID: "C-010",
            audience: audience,
            childName: childName,
            taskTitle: taskTitle,
            deadlineText: deadlineText,
            status: .waiting,
            headline: "Waiting for approval",
            message: "Games are paused until this is reviewed.",
            submission: .recorded,
            decision: .awaitingApproval,
            deadlinePhase: .restricted,
            graceMinutesRemaining: nil,
            deviceApplication: .notApplicable,
            activeRestrictions: restrictions,
            reminder: reminder,
            parentNote: nil
        )
    }
}
