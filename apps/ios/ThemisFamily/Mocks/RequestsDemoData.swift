import Foundation

enum RequestsDemoData {
    static let mayaRoute = RequestSubmissionRoute.household(requestOwnerID: DemoData.mayaID)

    static let entry = RequestPresentation(
        screenID: "Q-001",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: nil,
        status: ThemisStatus(.open, label: "New request"),
        headline: "Ask for more time",
        message: "Choose what you need, how long you need it for, and an optional reason.",
        lifecycle: .draft,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: nil,
        remainingRestrictions: []
    )

    static let sendingOffline = RequestPresentation(
        screenID: "Q-005 · Offline",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .waitingToSend,
        headline: "Sending…",
        message: "This request is queued on your device. It is not Pending until Themis confirms it was received.",
        lifecycle: .sending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Up to 4 hours, or earlier if the context ends",
        remainingRestrictions: []
    )

    static let pending = RequestPresentation(
        screenID: "Q-006",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .pending,
        headline: "Request sent",
        message: "Waiting for your parent or carer. You can send one reminder if you need to.",
        lifecycle: .pending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Expires when this context ends, or after 4 hours at the latest",
        remainingRestrictions: []
    )

    static let clarificationReceived = RequestPresentation(
        screenID: "Q-008",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .needsYourReply,
        headline: "Sarah asked one question",
        message: "Reply once. This does not open a chat.",
        lifecycle: .awaitingClarificationReply,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: true, manualNudgeSent: false),
        clarification: RequestClarificationState(
            question: "How much longer do you actually need?",
            reply: nil
        ),
        expiresText: "Still expires with the original request context",
        remainingRestrictions: []
    )

    static let clarificationReplied = RequestPresentation(
        screenID: "Q-009",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .pending,
        headline: "Reply sent",
        message: "Your reply is attached. There is no further message thread.",
        lifecycle: .pending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: true, manualNudgeSent: true),
        clarification: RequestClarificationState(
            question: "How much longer do you actually need?",
            reply: "About ten minutes."
        ),
        expiresText: "Still expires with the original request context",
        remainingRestrictions: []
    )

    static let approved = RequestPresentation(
        screenID: "Q-010",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: 15,
        reason: "I’m finishing a conversation with my friends.",
        status: .appliedOnDevice,
        headline: "15 more minutes approved",
        message: "The approved change is active on Maya’s device.",
        lifecycle: .approved,
        deviceApplication: .applied,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Access ends automatically when the 15 minutes finish",
        remainingRestrictions: []
    )

    static let partial = RequestPresentation(
        screenID: "Q-011",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 30,
        grantedMinutes: 15,
        reason: "I’d like a little longer tonight.",
        status: .partiallyApproved,
        headline: "15 minutes approved",
        message: "You asked for 30 minutes. Sarah approved 15 minutes.",
        lifecycle: .partiallyApproved,
        deviceApplication: .pending,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Waiting for device confirmation",
        remainingRestrictions: []
    )

    static let declined = RequestPresentation(
        screenID: "Q-012",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .declined,
        headline: "Request declined",
        message: "No extra time was added.",
        lifecycle: .declined,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: nil,
        remainingRestrictions: []
    )

    static let expired = RequestPresentation(
        screenID: "Q-013",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .expired,
        headline: "Request expired",
        message: "The situation this request referred to has ended. Start a new request if you still need something.",
        lifecycle: .expired,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: true, manualNudgeSent: true),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Expired when the original context ended",
        remainingRestrictions: []
    )

    static let cancelRequest = RequestPresentation(
        screenID: "Q-014",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: nil,
        status: .pending,
        headline: "Cancel this request?",
        message: "You can cancel while it is still Pending. Nothing changes on the device.",
        lifecycle: .pending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: nil,
        remainingRestrictions: []
    )

    static let parentDetail = RequestPresentation(
        screenID: "A-004",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .needsYou,
        headline: "Maya asked for 15 more min",
        message: "Instagram · request received 4 min ago",
        lifecycle: .pending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Expires when this context ends, or after 4 hours at the latest",
        remainingRestrictions: []
    )

    static let askClarification = RequestPresentation(
        screenID: "A-008",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: nil,
        reason: "I’m finishing a conversation with my friends.",
        status: .needsYou,
        headline: "Ask one question",
        message: "This is a single request-scoped clarification, not a message thread.",
        lifecycle: .pending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: nil,
        remainingRestrictions: []
    )

    static let waitingForReply = parentDetail.askingClarification("How much longer do you actually need?")

    static let alreadyResolved = RequestPresentation(
        screenID: "A-010",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: 15,
        reason: "I’m finishing a conversation with my friends.",
        status: .resolved,
        headline: "Already resolved",
        message: "Priya’s approval was recorded first. This request cannot be decided again.",
        lifecycle: .approved,
        deviceApplication: .pending,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: nil,
        remainingRestrictions: []
    )

    static let approvedPendingDevice = RequestPresentation(
        screenID: "A-011",
        audience: .teen,
        childID: DemoData.mayaID,
        childName: "Maya",
        type: .extraTime,
        target: "Instagram",
        requestedMinutes: 15,
        grantedMinutes: 15,
        reason: "I’m finishing a conversation with my friends.",
        status: .applying,
        headline: "Approved",
        message: "The decision is recorded. Waiting for Maya’s iPhone to confirm the change.",
        lifecycle: .approved,
        deviceApplication: .pending,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Device application pending",
        remainingRestrictions: []
    )

    static let schoolTemporaryAccess = RequestPresentation(
        screenID: "Q-006 · School",
        audience: .child,
        childID: DemoData.samID,
        childName: "Sam",
        type: .temporaryAccess,
        target: "School website",
        requestedMinutes: 30,
        grantedMinutes: nil,
        reason: "I need it for homework.",
        status: .pending,
        headline: "School access request sent",
        message: "This uses the same request lifecycle as every other temporary-access request.",
        lifecycle: .pending,
        deviceApplication: .notApplicable,
        reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
        clarification: RequestClarificationState(question: nil, reply: nil),
        expiresText: "Expires with this homework context, or after 4 hours at the latest",
        remainingRestrictions: []
    )
}
