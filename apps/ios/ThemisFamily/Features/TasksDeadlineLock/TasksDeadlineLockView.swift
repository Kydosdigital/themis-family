import SwiftUI

enum TasksDeadlineLockAudience: Equatable {
    case child
    case parent
}

/// UI-06 presentation for C-002...C-011 and the parent approval/application states.
/// This is deliberately mock-driven. Production persistence, push delivery and
/// Apple enforcement remain behind their existing gates.
struct TasksDeadlineLockView: View {
    let state: TaskDeadlineLockPresentation
    let surfaceAudience: TasksDeadlineLockAudience
    var onSubmit: () -> Void = {}
    var onSendReminder: () -> Void = {}
    var onApprove: () -> Void = {}
    var onNeedsWork: () -> Void = {}

    private var audience: ThemisAudience {
        switch surfaceAudience {
        case .parent: return .parent
        case .child: return ThemisAudience(state.audience)
        }
    }

    private var ground: ThemisGround {
        surfaceAudience == .child && state.audience == .child ? .warm : .grouped
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                header

                if let grace = state.graceMinutesRemaining {
                    graceCard(minutesRemaining: grace)
                }

                if !state.activeRestrictions.isEmpty {
                    restrictions
                }

                if surfaceAudience == .parent {
                    parentActions
                } else {
                    childActions
                }

                if state.deviceApplication == .pending {
                    InlineBanner(
                        .info,
                        "Approval is recorded, but the child device has not confirmed the change yet."
                    )
                }

                if state.deviceApplication == .applied {
                    InlineBanner(
                        .success,
                        state.activeRestrictions.isEmpty
                            ? "The child device confirmed the homework restriction is cleared."
                            : "The device confirmed the homework change. Other active family rules still apply."
                    )
                }
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.vertical, ThemisSpacing.block)
        }
        .themisAudience(audience)
        .themisGround(ground)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                StatusBadge(state.status, size: .chip)

                Text(state.headline)
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(state.deadlineText)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.message)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func graceCard(minutesRemaining: Int) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            SectionHeader(title: "Approval grace")
                .padding(.horizontal, 4)

            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline10) {
                        Text("\(minutesRemaining) min")
                            .themisFont(.screenTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text("remaining")
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }

                    ProgressView(
                        value: Double(state.graceLengthMinutes - minutesRemaining),
                        total: Double(state.graceLengthMinutes)
                    )
                    .tint(ThemisColor.brandPrimary)
                    .accessibilityLabel("Approval grace time used")
                    .accessibilityValue("\(state.graceLengthMinutes - minutesRemaining) of \(state.graceLengthMinutes) minutes")

                    Text("The fixed approval grace lasts 30 minutes after the deadline. If it expires without a decision, the Deadline Lock applies.")
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var restrictions: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            SectionHeader(
                title: state.activeRestrictions.count > 1 ? "Why access is paused" : "Why access is paused"
            )
            .padding(.horizontal, 4)

            ThemisCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(state.activeRestrictions.enumerated()), id: \.element) { index, reason in
                        if index > 0 {
                            Rectangle()
                                .fill(ThemisColor.borderHairline)
                                .frame(height: ThemisBorder.hairline)
                                .accessibilityHidden(true)
                        }

                        HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline10) {
                            Image(systemName: "pause.circle.fill")
                                .foregroundStyle(ThemisColor.statusWarning)
                                .accessibilityHidden(true)
                            Text(reason.rawValue)
                                .themisFont(.body)
                                .foregroundStyle(ThemisColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 8)
                        }
                        .padding(.vertical, ThemisSpacing.rowVertical)
                        .padding(.horizontal, ThemisSpacing.rowHorizontal)
                        .accessibilityElement(children: .combine)
                    }
                }
            }

            if state.decision == .approved && !state.activeRestrictions.isEmpty {
                InlineBanner(
                    .info,
                    "Homework is cleared, but access is not described as unlocked while another active rule still applies."
                )
            }
        }
    }

    @ViewBuilder
    private var childActions: some View {
        switch state.screenID {
        case "C-002", "C-003", "C-007", "C-008", "C-009":
            ThemisButton(
                title: state.submission == .submitting
                    ? "Submitting"
                    : (state.screenID == "C-003" || state.screenID == "C-009" ? "Submit for approval" : "I’ve finished my homework"),
                systemImage: "checkmark",
                isLoading: state.submission == .submitting,
                action: onSubmit
            )

        case "C-004", "C-005", "C-010":
            if state.decision == .awaitingApproval {
                ThemisButton(
                    title: state.reminder.manualNudgeSent ? "Reminder sent" : "Send a reminder",
                    systemImage: "bell",
                    style: .secondary,
                    isDisabled: !state.reminder.canSendManualNudge,
                    action: onSendReminder
                )

                Text(state.reminder.automaticReminderSent
                    ? "The automatic 15-minute reminder has already been sent. Your manual reminder is separate."
                    : "Themis can send one automatic reminder at 15 minutes. You can also send one separate reminder.")
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

        case "C-011":
            EmptyView()

        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var parentActions: some View {
        switch state.screenID {
        case "A-001", "P-024":
            ThemisButton(title: "Review homework", systemImage: "checkmark.circle", action: onApprove)

        case "A-002", "P-025":
            ThemisButton(title: "Approve", systemImage: "checkmark", action: onApprove)
            ThemisButton(title: "Needs work", style: .secondary, action: onNeedsWork)

        default:
            EmptyView()
        }
    }

    private var navigationTitle: String {
        switch surfaceAudience {
        case .child:
            return state.taskTitle
        case .parent:
            return state.screenID == "A-001" ? "Action Centre" : "Homework review"
        }
    }
}

/// A-003 · Reject / Needs work. The note is intentionally optional and one-way.
struct NeedsWorkTaskView: View {
    let state: TaskDeadlineLockPresentation
    var onSubmit: (String?) -> Void = { _ in }

    @State private var note = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text("Needs work")
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Sam can submit Homework again. Add a short note if it would help. A note is optional and does not start a chat.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                TextField(
                    "Optional note",
                    text: $note,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .accessibilityHint("Optional one-way note for Sam")

                ThemisButton(title: "Send back for more work") {
                    let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSubmit(trimmed.isEmpty ? nil : trimmed)
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(.parent)
        .themisGround(.plain)
        .navigationTitle("Needs work")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// P-027 / P-028 review state. Kept explicit so a recorded approval can never
/// visually masquerade as device acknowledgement.
struct ApprovalApplicationStatusView: View {
    let state: TaskDeadlineLockPresentation

    var body: some View {
        TasksDeadlineLockView(state: state, surfaceAudience: .parent)
            .navigationTitle(state.screenID == "P-028" ? "Protection current" : "Applying change")
    }
}

// MARK: - Deterministic review states

#Preview("C-002 · Task detail") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.taskDetail,
            surfaceAudience: .child
        )
    }
}

#Preview("C-003 · Submit task") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.submitTask,
            surfaceAudience: .child
        )
    }
}

#Preview("C-005 · Approval grace") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.approvalGrace,
            surfaceAudience: .child
        )
    }
}

#Preview("C-008 · Games paused") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.gamesPaused,
            surfaceAudience: .child
        )
    }
}

#Preview("C-011 · Multiple restrictions") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.multipleRestrictions,
            surfaceAudience: .child
        )
    }
}

#Preview("C-006 · Approved") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.approved,
            surfaceAudience: .child
        )
    }
}

#Preview("C-009 · Submit while restricted") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.submitWhileRestricted,
            surfaceAudience: .child
        )
    }
}

#Preview("A-001 · Action Centre") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.actionCentre,
            surfaceAudience: .parent
        )
    }
}

#Preview("P-024 · Parent receives action") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.parentActionReceived,
            surfaceAudience: .parent
        )
    }
}

#Preview("P-025 · Task review") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.parentTaskReview,
            surfaceAudience: .parent
        )
    }
}

#Preview("P-026 · Approved") {
    NavigationStack {
        ApprovalApplicationStatusView(state: TasksDeadlineLockDemoData.approvalRecorded)
    }
}

#Preview("A-002 · Task review") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.taskReview,
            surfaceAudience: .parent
        )
    }
}

#Preview("A-003 · Needs work") {
    NavigationStack {
        NeedsWorkTaskView(state: TasksDeadlineLockDemoData.needsWork)
    }
}

#Preview("P-027 · Approved, device pending") {
    NavigationStack {
        ApprovalApplicationStatusView(state: TasksDeadlineLockDemoData.approvedPendingDevice)
    }
}

#Preview("P-028 · Applied on device") {
    NavigationStack {
        ApprovalApplicationStatusView(state: TasksDeadlineLockDemoData.appliedOnDevice)
    }
}

#Preview("C-005 · Approval grace · AX3") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.approvalGrace,
            surfaceAudience: .child
        )
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("A-002 · Task review · AX3") {
    NavigationStack {
        TasksDeadlineLockView(
            state: TasksDeadlineLockDemoData.taskReview,
            surfaceAudience: .parent
        )
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
