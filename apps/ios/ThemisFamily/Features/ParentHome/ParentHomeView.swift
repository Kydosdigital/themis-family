import SwiftUI

struct ParentHomeView: View {
    let scenario: DemoScenario

    @StateObject private var viewModel: ParentHomeViewModel

    init(repository: any ParentDashboardRepository, scenario: DemoScenario) {
        self.scenario = scenario
        _viewModel = StateObject(wrappedValue: ParentHomeViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.lg) {
                if let dashboard = viewModel.dashboard {
                    header(dashboard)

                    if let subscriptionBanner = dashboard.subscriptionBanner {
                        subscriptionBannerView(subscriptionBanner)
                    }

                    if dashboard.children.isEmpty {
                        emptyFamily
                    } else {
                        childrenSection(dashboard.children)
                    }

                    pendingSection(dashboard.pendingRequests)

                    ThemisSectionHeader(
                        title: "Quick actions",
                        subtitle: "Keep the family agreement clear and easy to adjust."
                    )

                    HStack(spacing: ThemisSpacing.sm) {
                        quickAction("Add rule", icon: "plus.circle.fill")
                        quickAction("Free Pass", icon: "ticket.fill")
                    }
                } else if viewModel.isLoading {
                    ProgressView("Loading your family…")
                        .frame(maxWidth: .infinity, minHeight: 240)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Couldn’t load family",
                        systemImage: "wifi.exclamationmark",
                        description: Text(errorMessage)
                    )
                }
            }
            .padding(ThemisSpacing.md)
        }
        .background(ThemisColor.surfaceMuted)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: scenario) {
            await viewModel.load(scenario: scenario)
        }
        .refreshable {
            await viewModel.load(scenario: scenario)
        }
    }

    private func header(_ dashboard: ParentDashboardData) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.xs) {
            Text("Good morning, \(dashboard.ownerName)")
                .font(ThemisTypography.hero)
                .foregroundStyle(ThemisColor.textPrimary)
            Text("Here’s how your family’s digital agreement is looking.")
                .font(ThemisTypography.body)
                .foregroundStyle(ThemisColor.textSecondary)
        }
    }

    private func subscriptionBannerView(_ message: String) -> some View {
        ThemisCard {
            HStack(alignment: .top, spacing: ThemisSpacing.sm) {
                Image(systemName: "creditcard.trianglebadge.exclamationmark")
                    .foregroundStyle(ThemisColor.attention)
                Text(message)
                    .font(ThemisTypography.body)
                    .foregroundStyle(ThemisColor.textPrimary)
            }
        }
    }

    private func childrenSection(_ children: [ChildProfile]) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
            ThemisSectionHeader(title: "Your family")

            ForEach(children) { child in
                ChildSummaryCard(child: child)
            }
        }
    }

    private func pendingSection(_ requests: [AccessRequest]) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
            ThemisSectionHeader(
                title: "Needs your attention",
                subtitle: requests.isEmpty ? "Nothing waiting right now." : "Requests are waiting for a decision."
            )

            if requests.isEmpty {
                ThemisCard {
                    Label("You’re all caught up.", systemImage: "checkmark.circle.fill")
                        .font(ThemisTypography.bodyStrong)
                        .foregroundStyle(ThemisColor.textPrimary)
                }
            } else {
                ForEach(requests) { request in
                    ThemisCard {
                        VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
                            Text("\(request.childName) sent a request")
                                .font(ThemisTypography.bodyStrong)
                            Text(request.summary)
                                .font(ThemisTypography.body)
                                .foregroundStyle(ThemisColor.textSecondary)
                            Text(request.requestedDuration)
                                .font(ThemisTypography.caption)
                                .foregroundStyle(ThemisColor.textSecondary)

                            HStack {
                                Button("Decline") {}
                                    .buttonStyle(.bordered)
                                Button("Review") {}
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyFamily: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.md) {
                Image(systemName: "person.2.badge.plus")
                    .font(.title)
                    .foregroundStyle(ThemisColor.actionPrimary)
                Text("Add your first child")
                    .font(ThemisTypography.section)
                Text("Create a child profile, pair their device, then set the first family rule.")
                    .font(ThemisTypography.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                ThemisButton(title: "Add child", systemImage: "plus") {}
            }
        }
    }

    private func quickAction(_ title: String, icon: String) -> some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(ThemisColor.actionPrimary)
                Text(title)
                    .font(ThemisTypography.bodyStrong)
            }
        }
    }
}

private struct ChildSummaryCard: View {
    let child: ChildProfile

    var body: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: ThemisSpacing.xs) {
                        Text(child.firstName)
                            .font(ThemisTypography.section)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(child.experienceSegment.rawValue + " experience")
                            .font(ThemisTypography.caption)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                    Spacer()
                    ProtectionStatusBadge(status: child.protectionStatus)
                }

                HStack(spacing: ThemisSpacing.lg) {
                    metric("\(child.activeRuleCount)", label: "Active rules")
                    metric("\(child.pendingActionCount)", label: "Pending")
                }

                if let lastVerified = child.lastVerified {
                    Text("Last verified \(lastVerified.formatted(.relative(presentation: .named)))")
                        .font(ThemisTypography.caption)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }
        }
    }

    private func metric(_ value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.xs) {
            Text(value)
                .font(ThemisTypography.title)
                .foregroundStyle(ThemisColor.textPrimary)
            Text(label)
                .font(ThemisTypography.caption)
                .foregroundStyle(ThemisColor.textSecondary)
        }
    }
}
