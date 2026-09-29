import SwiftUI

struct ChildHomeView: View {
    let childID: UUID
    let scenario: DemoScenario

    @StateObject private var viewModel: ChildHomeViewModel
    @State private var showsTransparency = false

    init(
        childID: UUID,
        repository: any ChildHomeRepository,
        scenario: DemoScenario
    ) {
        self.childID = childID
        self.scenario = scenario
        _viewModel = StateObject(wrappedValue: ChildHomeViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.lg) {
                if let home = viewModel.home {
                    childHeader(home)
                    activeStatus(home)
                    taskSection(home.task)

                    if let freePassSummary = home.freePassSummary {
                        ThemisCard {
                            Label(freePassSummary, systemImage: "ticket.fill")
                                .font(ThemisTypography.bodyStrong)
                                .foregroundStyle(ThemisColor.textPrimary)
                        }
                    }

                    if let requestStatusSummary = home.requestStatusSummary {
                        ThemisCard {
                            Text(requestStatusSummary)
                                .font(ThemisTypography.body)
                                .foregroundStyle(ThemisColor.textPrimary)
                        }
                    }

                    ThemisButton(
                        title: "Ask for more time",
                        systemImage: "clock.badge.questionmark",
                        style: .secondary
                    ) {}

                    Button {
                        showsTransparency = true
                    } label: {
                        Label("What can my parent see?", systemImage: "eye")
                            .font(ThemisTypography.bodyStrong)
                    }
                    .foregroundStyle(ThemisColor.actionPrimary)
                } else if viewModel.isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Themis isn’t available right now",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            }
            .padding(ThemisSpacing.md)
        }
        .background(ThemisColor.surfaceMuted)
        .navigationTitle("Themis")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: scenario) {
            await viewModel.load(childID: childID, scenario: scenario)
        }
        .sheet(isPresented: $showsTransparency) {
            TransparencyView()
        }
    }

    private func childHeader(_ home: ChildHomeData) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.xs) {
            Text("Hi, \(home.child.firstName)")
                .font(ThemisTypography.hero)
                .foregroundStyle(ThemisColor.textPrimary)
            HStack {
                ProtectionStatusBadge(status: home.child.protectionStatus)
                Text("Themis is active")
                    .font(ThemisTypography.caption)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
    }

    private func activeStatus(_ home: ChildHomeData) -> some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
                if home.activeRestrictionReasons.isEmpty {
                    Label("Everything looks good.", systemImage: "checkmark.circle.fill")
                        .font(ThemisTypography.section)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text("Your current family rules aren’t pausing anything right now.")
                        .font(ThemisTypography.body)
                        .foregroundStyle(ThemisColor.textSecondary)
                } else {
                    Text("Some apps are paused")
                        .font(ThemisTypography.section)
                        .foregroundStyle(ThemisColor.textPrimary)

                    ForEach(home.activeRestrictionReasons, id: \.self) { reason in
                        Label(reason, systemImage: "pause.circle.fill")
                            .font(ThemisTypography.body)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func taskSection(_ task: TaskItem?) -> some View {
        if let task {
            VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
                ThemisSectionHeader(title: "Today")

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
                        Text(task.title)
                            .font(ThemisTypography.section)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(task.dueSummary)
                            .font(ThemisTypography.caption)
                            .foregroundStyle(ThemisColor.textSecondary)

                        Text(taskStateText(task.state))
                            .font(ThemisTypography.body)
                            .foregroundStyle(ThemisColor.textPrimary)

                        if task.state == .due {
                            ThemisButton(title: "I’m done", systemImage: "checkmark") {}
                        }
                    }
                }
            }
        }
    }

    private func taskStateText(_ state: TaskState) -> String {
        switch state {
        case .due:
            return "When you’re finished, submit it for approval."
        case .submittedAwaitingApproval:
            return "Submitted on time. Waiting for approval."
        case let .approvalGrace(minutesRemaining):
            return "Submitted on time. Approval grace ends in \(minutesRemaining) min."
        case .overdueRestricted:
            return "Waiting for approval. Games are paused until this is reviewed."
        case .approved:
            return "Approved."
        }
    }
}

private struct TransparencyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ThemisSpacing.lg) {
                    Text("Themis is active")
                        .font(ThemisTypography.title)
                        .foregroundStyle(ThemisColor.textPrimary)

                    disclosure(
                        "What Themis controls",
                        "Apps and websites can be paused based on family rules and schedules."
                    )
                    disclosure(
                        "What your parent can see",
                        "Your Themis rules, tasks, requests, temporary access, protection status, and some Screen Time activity Apple makes available through parental reports."
                    )
                    disclosure(
                        "What Themis does not show",
                        "Themis does not let your parent read your messages or give them a minute-by-minute feed of everything you do."
                    )
                    disclosure(
                        "Need something?",
                        "You can ask for more time or access when a rule is active."
                    )
                }
                .padding(ThemisSpacing.md)
            }
            .background(ThemisColor.surfaceMuted)
            .navigationTitle("About Themis")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func disclosure(_ title: String, _ body: String) -> some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
                Text(title)
                    .font(ThemisTypography.section)
                Text(body)
                    .font(ThemisTypography.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
    }
}
