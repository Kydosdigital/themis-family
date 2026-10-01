import SwiftUI

/// T-001 Activity, the Parent Activity tab root.
///
/// Rendered inside the Parent tab's own `NavigationStack`, so this view does not create
/// one. Not wired into `RootView` on this branch.
struct ActivityView: View {
    @StateObject private var viewModel: ActivityViewModel

    init(repository: any ActivityRepository = MockActivityRepository(), initialPeriod: ActivityPeriod = .thisWeek) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(repository: repository, period: initialPeriod))
    }

    var body: some View {
        Group {
            if let screen = viewModel.screen {
                ActivityOverviewContentView(screen: screen, period: $viewModel.period)
            } else if let errorMessage = viewModel.errorMessage {
                ScrollView {
                    ErrorStateView(title: errorMessage) {
                        Task { await viewModel.load() }
                    }
                    .padding(ThemisSpacing.screen)
                }
                .themisGround(.grouped)
            } else {
                LoadingStateView(label: "Loading your activity")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .themisGround(.grouped)
            }
        }
        .themisAudience(.parent)
        .task { await viewModel.load() }
    }
}

/// The T-001 layout for a given state. No loading and no repository, so previews and
/// review states are deterministic.
///
/// A week or last week of Themis outcomes per child, then ways into the histories. Apple's
/// report sits in its own "Shown by Apple" group and never shares a container with Themis
/// activity or with these counts.
struct ActivityOverviewContentView: View {
    let screen: ActivityScreenState
    @Binding var period: ActivityPeriod

    var body: some View {
        let snapshot = screen.snapshot

        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "Activity")

                SegmentedChoice(
                    label: "Show activity for",
                    options: ActivityPeriod.allCases,
                    selection: $period,
                    title: { $0.title }
                )

                if snapshot.events.isEmpty {
                    InlineBanner(.info, ActivityCopy.emptyMessage)
                } else {
                    ThemisGroupedSection(period.title, data: childLinks(snapshot)) { item in
                        ActivityLinkRow(item: item)
                    }
                }

                ThemisGroupedSection("History", data: Self.historyLinks) { item in
                    ActivityLinkRow(item: item)
                }

                ThemisGroupedSection(AppleScreenTimeCopy.sectionLabel, data: Self.appleLinks) { item in
                    ActivityLinkRow(item: item)
                }

                Text(ActivityCopy.overviewFooter)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.bottom, ThemisSpacing.lg)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .toolbar(.hidden, for: .navigationBar)
        .activityNavigation(screen)
    }

    /// One row per child with that child's Themis-owned counts for the selected period.
    private func childLinks(_ snapshot: ActivitySnapshot) -> [ActivityLink] {
        ActivityChild.allCases.map { child in
            ActivityLink(
                id: "child-\(child.id)",
                route: .child(child),
                title: child.title,
                subtitle: ActivityPresentation.overviewLine(
                    snapshot.summary(for: ActivityScope(child), period: period)
                ),
                child: child
            )
        }
    }

    private static let historyLinks: [ActivityLink] = [
        ActivityLink(id: "rules", route: .ruleChanges, title: "Rule changes", subtitle: "Who changed what, and when"),
        ActivityLink(id: "requests", route: .requestHistory, title: "Requests", subtitle: "Asked, decided, expired"),
        ActivityLink(id: "protection", route: .protectionHistory, title: "Protection", subtitle: "Device status over time")
    ]

    private static let appleLinks: [ActivityLink] = [
        ActivityLink(
            id: "apple-screen-time",
            route: .appleScreenTime,
            title: AppleScreenTimeCopy.overviewTitle,
            subtitle: AppleScreenTimeCopy.overviewSubtitle
        )
    ]
}

/// A navigation row on the overview.
struct ActivityLink: Identifiable, Equatable, Sendable {
    let id: String
    let route: ActivityRoute
    let title: String
    let subtitle: String
    var child: ActivityChild? = nil
}

struct ActivityLinkRow: View {
    let item: ActivityLink

    var body: some View {
        NavigationLink(value: item.route) {
            ThemisRow(
                title: item.title,
                subtitle: item.subtitle,
                avatar: avatar,
                showsChevron: true
            )
        }
        .buttonStyle(.plain)
    }

    private var avatar: (initial: String, tone: ThemisTone)? {
        guard let child = item.child else { return nil }
        return (initial: child.initial, tone: child.tone)
    }
}

/// A list row with its outcome chip. Only rows with timing evidence open a detail, since
/// nothing else has more to show.
struct ActivityRowView: View {
    let row: ActivityListRow

    var body: some View {
        if let id = row.detailEventID {
            NavigationLink(value: ActivityRoute.eventDetail(id)) {
                content(showsChevron: true)
            }
            .buttonStyle(.plain)
        } else {
            content(showsChevron: false)
        }
    }

    private func content(showsChevron: Bool) -> some View {
        ThemisRow(
            title: row.title,
            subtitle: row.subtitle,
            status: row.status,
            showsChevron: showsChevron
        )
    }
}

// MARK: - Previews (deterministic)

struct ActivityOverviewPreviewHost: View {
    @State var period: ActivityPeriod

    var body: some View {
        NavigationStack {
            ActivityOverviewContentView(
                screen: ActivityScreenState(snapshot: ActivityDemoData.snapshot, appleReport: .systemOwnedReportArea),
                period: $period
            )
        }
    }
}

#Preview("T-001 · Activity · This week") {
    ActivityOverviewPreviewHost(period: .thisWeek)
}

#Preview("T-001 · Activity · Last week") {
    ActivityOverviewPreviewHost(period: .lastWeek)
}

#Preview("T-001 · Activity · AX3") {
    ActivityOverviewPreviewHost(period: .thisWeek)
        .environment(\.dynamicTypeSize, .accessibility3)
}
