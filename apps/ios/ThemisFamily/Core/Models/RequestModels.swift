import Foundation

enum RequestType: String, CaseIterable, Hashable, Sendable {
    case extraTime = "Extra time"
    case deadlineExtension = "Deadline extension"
    case temporaryAccess = "Temporary access"
    case exception = "One-off exception"
}

enum RequestLifecycleState: String, Equatable, Sendable {
    case draft
    case sending
    case pending
    case awaitingClarificationReply
    case approved
    case partiallyApproved
    case declined
    case expired
    case cancelled
}

enum RequestDeviceApplicationState: String, Equatable, Sendable {
    case notApplicable
    case pending
    case applied
}

enum RequestAdultDecision: String, Equatable, Sendable {
    case approve
    case partialApprove
    case decline
}

enum RequestDecisionAttemptResult: Equatable, Sendable {
    case recorded(RequestAdultDecision, by: TaskApproverRole)
    case alreadyResolved(RequestAdultDecision, by: TaskApproverRole)
    case notAuthorised
}

struct RequestDecisionLedger: Equatable, Sendable {
    private(set) var decision: RequestAdultDecision?
    private(set) var decidedBy: TaskApproverRole?

    mutating func record(_ attemptedDecision: RequestAdultDecision, by role: TaskApproverRole) -> RequestDecisionAttemptResult {
        guard role.canDecide else { return .notAuthorised }
        if let decision, let decidedBy {
            return .alreadyResolved(decision, by: decidedBy)
        }
        decision = attemptedDecision
        decidedBy = role
        return .recorded(attemptedDecision, by: role)
    }
}

struct RequestSubmissionRoute: Equatable, Sendable {
    let requestOwnerID: UUID
    let approversToNotify: [TaskApproverRole]

    func maySubmit(actorID: UUID) -> Bool {
        actorID == requestOwnerID
    }

    static func household(requestOwnerID: UUID) -> RequestSubmissionRoute {
        RequestSubmissionRoute(
            requestOwnerID: requestOwnerID,
            approversToNotify: [.owner, .guardian]
        )
    }
}

struct RequestReminderState: Equatable, Sendable {
    static let automaticReminderMinutes = 15

    var automaticReminderSent: Bool
    var manualNudgeSent: Bool

    var canSendManualNudge: Bool { !manualNudgeSent }
}

struct RequestClarificationState: Equatable, Sendable {
    var question: String?
    var reply: String?

    var canAskQuestion: Bool { question == nil }
    var canReply: Bool { question != nil && reply == nil }
    var roundComplete: Bool { question != nil && reply != nil }
}

enum RequestRestrictionReason: String, Hashable, Sendable {
    case bedtime = "Bedtime rule is still active"
    case deadlineLock = "Deadline Lock is still active"
    case schoolMode = "School Mode still limits this target"
}

struct RequestPresentation: Equatable, Sendable {
    var screenID: String
    var audience: ExperienceSegment
    var childID: UUID
    var childName: String
    var type: RequestType
    var target: String
    var requestedMinutes: Int?
    var grantedMinutes: Int?
    var reason: String?
    var status: ThemisStatus
    var headline: String
    var message: String
    var lifecycle: RequestLifecycleState
    var deviceApplication: RequestDeviceApplicationState
    var reminder: RequestReminderState
    var clarification: RequestClarificationState
    var expiresText: String?
    var remainingRestrictions: [RequestRestrictionReason]

    var isPending: Bool {
        lifecycle == .pending || lifecycle == .awaitingClarificationReply
    }

    var canCancel: Bool { lifecycle == .pending }
    var canAskClarification: Bool { isPending && clarification.canAskQuestion }
    var canReplyClarification: Bool { lifecycle == .awaitingClarificationReply && clarification.canReply }

    var mayClaimTargetAvailable: Bool {
        (lifecycle == .approved || lifecycle == .partiallyApproved)
            && deviceApplication == .applied
            && remainingRestrictions.isEmpty
    }

    func sendingManualNudge() -> RequestPresentation {
        guard isPending, reminder.canSendManualNudge else { return self }
        var copy = self
        copy.reminder.manualNudgeSent = true
        return copy
    }

    func askingClarification(_ question: String) -> RequestPresentation {
        guard canAskClarification else { return self }
        var copy = self
        copy.lifecycle = .awaitingClarificationReply
        copy.status = .needsYourReply
        copy.headline = "Waiting for (childName)’s reply"
        copy.message = "The request stays pending. You can still decide without waiting for a reply."
        copy.clarification.question = question
        return copy
    }

    func replyingToClarification(_ reply: String) -> RequestPresentation {
        guard canReplyClarification else { return self }
        var copy = self
        copy.lifecycle = .pending
        copy.status = .pending
        copy.headline = "Reply sent"
        copy.message = "Your reply is attached to this request. Your parent or carer can now decide."
        copy.clarification.reply = reply
        return copy
    }

    func applyingDecision(
        _ decision: RequestAdultDecision,
        grantedMinutes: Int? = nil,
        deviceAcknowledged: Bool = false,
        remainingRestrictions: [RequestRestrictionReason] = []
    ) -> RequestPresentation {
        guard isPending else { return self }
        var copy = self
        copy.remainingRestrictions = remainingRestrictions
        switch decision {
        case .approve:
            copy.lifecycle = .approved
            copy.status = deviceAcknowledged ? .appliedOnDevice : .approved
            copy.headline = deviceAcknowledged ? "Applied on device" : "Approved"
            copy.grantedMinutes = grantedMinutes ?? requestedMinutes
        case .partialApprove:
            copy.lifecycle = .partiallyApproved
            copy.status = deviceAcknowledged ? .appliedOnDevice : .partiallyApproved
            copy.headline = "Partially approved"
            copy.grantedMinutes = grantedMinutes
        case .decline:
            copy.lifecycle = .declined
            copy.status = .declined
            copy.headline = "Request declined"
            copy.grantedMinutes = nil
        }
        copy.deviceApplication = decision == .decline ? .notApplicable : (deviceAcknowledged ? .applied : .pending)
        if decision == .decline {
            copy.message = "The request is closed. No temporary access was granted."
        } else if deviceAcknowledged {
            copy.message = remainingRestrictions.isEmpty
                ? "The approved change is active on (childName)’s device."
                : "This request was applied, but another family rule still limits this target."
        } else {
            copy.message = "The decision is recorded. Waiting for (childName)’s device to confirm the change."
        }
        return copy
    }

    func expiring() -> RequestPresentation {
        guard isPending else { return self }
        var copy = self
        copy.lifecycle = .expired
        copy.status = .expired
        copy.headline = "Request expired"
        copy.message = "This request no longer matches the current situation. Start a new request if you still need access."
        copy.deviceApplication = .notApplicable
        return copy
    }

    func cancelling() -> RequestPresentation {
        guard lifecycle == .pending else { return self }
        var copy = self
        copy.lifecycle = .cancelled
        copy.status = ThemisStatus(.resolved, label: "Cancelled")
        copy.headline = "Request cancelled"
        copy.message = "This request is closed. Nothing changed on the device."
        copy.deviceApplication = .notApplicable
        return copy
    }
}
