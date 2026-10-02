import SwiftUI

struct RequestStateView: View {
    let state: RequestPresentation
    var surfaceAudience: ThemisAudience? = nil
    var onSendReminder: (() -> Void)? = nil
    var onReply: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    private var audience: ThemisAudience {
        surfaceAudience ?? ThemisAudience(state.audience)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                statusCard
                details
                clarification
                actions
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(audience)
        .themisGround(audience.homeGround)
        .navigationTitle(state.screenID)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusCard: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                StatusBadge(state.status)
                Text(state.headline)
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(state.message)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var details: some View {
        ThemisCard {
            VStack(spacing: 0) {
                ThemisRow(title: "Request", subtitle: state.type.rawValue, value: state.target)
                if let requested = state.requestedMinutes {
                    Divider()
                    ThemisRow(title: "Requested", value: "\(requested) min")
                }
                if let granted = state.grantedMinutes {
                    Divider()
                    ThemisRow(title: "Granted", value: "\(granted) min")
                }
                if let reason = state.reason, !reason.isEmpty {
                    Divider()
                    ThemisRow(title: "Reason", subtitle: reason)
                }
                if let expiresText = state.expiresText {
                    Divider()
                    ThemisRow(title: "Expiry", subtitle: expiresText)
                }
                if !state.remainingRestrictions.isEmpty {
                    Divider()
                    ThemisRow(
                        title: "Other rule still active",
                        subtitle: state.remainingRestrictions.map(\.rawValue).joined(separator: " · "),
                        status: ThemisStatus(.waiting, label: "Still limited")
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var clarification: some View {
        if let question = state.clarification.question {
            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                    Text("One clarification")
                        .themisFont(.sectionLabel)
                        .foregroundStyle(ThemisColor.textSecondary)
                    Text(question)
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                    if let reply = state.clarification.reply {
                        Divider()
                        Text("Reply")
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                        Text(reply)
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                    }
                    Text("This request does not become a chat thread.")
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private var actions: some View {
        if state.isPending, let onSendReminder {
            ThemisButton(
                title: state.reminder.canSendManualNudge ? "Send one reminder" : "Reminder sent",
                style: .secondary,
                isDisabled: !state.reminder.canSendManualNudge,
                action: onSendReminder
            )
        }
        if state.canReplyClarification, let onReply {
            ThemisButton(title: "Reply once", action: onReply)
        }
        if state.canCancel, let onCancel {
            ThemisButton(title: "Cancel request", style: .destructive, action: onCancel)
        }
    }
}

struct RequestComposerView: View {
    enum Step: Int {
        case entry = 1
        case target = 2
        case duration = 3
        case reason = 4
        case review = 5
        case pending = 6
    }

    let audience: ExperienceSegment

    @State private var step: Step = .entry
    @State private var target: String? = "Instagram"
    @State private var duration: Int? = 15
    @State private var reason = ""
    @State private var pendingState = RequestsDemoData.pending

    private var themisAudience: ThemisAudience { ThemisAudience(audience) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                if step != .pending {
                    StepProgress(current: min(step.rawValue, 5), total: 5, label: "Request")
                }
                content
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(themisAudience)
        .themisGround(themisAudience.homeGround)
        .navigationTitle(step == .pending ? "Request" : "Ask for more time")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .entry:
            intro
        case .target:
            choiceTarget
        case .duration:
            choiceDuration
        case .reason:
            optionalReason
        case .review:
            review
        case .pending:
            RequestStateView(
                state: pendingState,
                surfaceAudience: themisAudience,
                onSendReminder: {
                    pendingState = pendingState.sendingManualNudge()
                },
                onCancel: {
                    pendingState = pendingState.cancelling()
                }
            )
        }
    }

    private var intro: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                Text("What do you need?")
                    .themisFont(.screenTitle)
                Text("Ask for a specific amount of time or temporary access. Requests are not messages.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                ThemisButton(title: "Start request") { step = .target }
            }
        }
    }

    private var choiceTarget: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            Text("Choose what you need")
                .themisFont(.screenTitle)
            ChoiceChips(
                options: ["Instagram", "Games", "School website"],
                selection: $target,
                title: { $0 }
            )
            ThemisButton(title: "Continue", isDisabled: target == nil) { step = .duration }
        }
    }

    private var choiceDuration: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            Text("How much time?")
                .themisFont(.screenTitle)
            ChoiceChips(
                options: [5, 15, 30],
                selection: $duration,
                title: { "\($0) min" }
            )
            ThemisButton(title: "Continue", isDisabled: duration == nil) { step = .reason }
        }
    }

    private var optionalReason: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            Text("Add a reason")
                .themisFont(.screenTitle)
            ReasonField(
                label: "Reason · optional",
                text: $reason,
                prompt: "A short reason",
                helper: "Visible only inside the authenticated Themis app."
            )
            ThemisButton(title: "Review request") { step = .review }
        }
    }

    private var review: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            RequestStateView(
                state: RequestPresentation(
                    screenID: "Q-005",
                    audience: audience,
                    childID: audience == .child ? DemoData.samID : DemoData.mayaID,
                    childName: audience == .child ? "Sam" : "Maya",
                    type: .extraTime,
                    target: target ?? "Target",
                    requestedMinutes: duration,
                    grantedMinutes: nil,
                    reason: reason.isEmpty ? nil : reason,
                    status: ThemisStatus(.open, label: "Ready to send"),
                    headline: "Review your request",
                    message: "Check the target and time before sending.",
                    lifecycle: .draft,
                    deviceApplication: .notApplicable,
                    reminder: RequestReminderState(automaticReminderSent: false, manualNudgeSent: false),
                    clarification: RequestClarificationState(question: nil, reply: nil),
                    expiresText: "The request expires when its context ends, or after 4 hours at the latest",
                    remainingRestrictions: []
                ),
                surfaceAudience: themisAudience
            )
            ThemisButton(title: "Send request") {
                pendingState = RequestsDemoData.pending
                step = .pending
            }
        }
    }
}

struct RequestHistoryView: View {
    let audience: ExperienceSegment

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                    PageHeader(title: "Requests", subtitle: audience == .child ? "Your requests" : "Your request history")
                    NavigationLink {
                        RequestComposerView(audience: audience)
                    } label: {
                        ThemisCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ask for more time")
                                        .themisFont(.rowTitle)
                                        .foregroundStyle(ThemisColor.textPrimary)
                                    Text("Make a specific request")
                                        .themisFont(.meta)
                                        .foregroundStyle(ThemisColor.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(ThemisColor.brandPrimary)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    ThemisCard {
                        VStack(spacing: 0) {
                            ThemisRow(title: "Instagram · 15 min", subtitle: "Maya · 4 min ago", status: .pending)
                            Divider()
                            ThemisRow(title: "Games · 15 min", subtitle: "Yesterday", status: .approved)
                        }
                    }
                }
                .padding(ThemisSpacing.screen)
            }
            .themisAudience(ThemisAudience(audience))
            .themisGround(ThemisAudience(audience).homeGround)
        }
    }
}

struct ParentRequestFlowView: View {
    enum Initial {
        case detail
        case askClarification
    }

    let initial: Initial
    @State private var state: RequestPresentation
    @State private var showingClarification = false
    @State private var question = ""

    init(initial: Initial = .detail) {
        self.initial = initial
        _state = State(initialValue: initial == .detail ? RequestsDemoData.parentDetail : RequestsDemoData.askClarification)
        _showingClarification = State(initialValue: initial == .askClarification)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                RequestStateView(state: state, surfaceAudience: .parent)

                if state.isPending {
                    ThemisButton(title: "Approve 15 min") {
                        state = state.applyingDecision(.approve, grantedMinutes: 15, deviceAcknowledged: false)
                    }
                    ThemisButton(title: "Approve less", style: .secondary) {
                        state = state.applyingDecision(.partialApprove, grantedMinutes: 5, deviceAcknowledged: false)
                    }
                    ThemisButton(title: "Decline", style: .secondary) {
                        state = state.applyingDecision(.decline)
                    }
                    if state.canAskClarification {
                        ThemisButton(title: "Ask one question", style: .tertiary) {
                            showingClarification = true
                        }
                    }
                }

                if showingClarification, state.canAskClarification {
                    ThemisCard {
                        VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                            ReasonField(
                                label: "One clarification question",
                                text: $question,
                                prompt: "Ask one short question",
                                helper: "One question and one reply only. This is not chat."
                            )
                            ThemisButton(title: "Send question", isDisabled: question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                                state = state.askingClarification(question)
                                showingClarification = false
                            }
                        }
                    }
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .navigationTitle("Request")
        .navigationBarTitleDisplayMode(.inline)
    }
}
