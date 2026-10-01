import SwiftUI

/// T-001 Activity overview, the Parent Activity tab root.
///
/// Rendered inside the Parent tab's own `NavigationStack`, so this view does not create
/// one. Not wired into `RootView` on this branch.
struct ActivityView: View {
    @StateObject private var viewModel: ActivityViewModel

    init(repository: any ActivityRepository = MockActivityRepository(), initialScope: ActivityScope = .all) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(repository: repository, scope: initialScope))
    }

    var body: some View {
        Group {
            if let screen = viewModel.screen {
                ActivityOverviewContentView(screen: screen, scope: $viewModel.scope)
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
/// Outcomes first, then ways into the histories. Apple's report sits in its own
/// "Shown by Apple" group and never shares a container with Themis activity.
struct ActivityOverviewContentView: View {
    let screen: ActivityScreenState
    @Binding var scope: ActivityScope

    /// Recent items shown on the overview. The full list lives in each child's Activity.
    private static let recentLimit = 6

    var body: some View {
        let snapshot = screen.snapshot
        let recent = Array(snapshot.events(for: scope).prefix(Self.recentLimit))

        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "Activity")

                Text(ActivityCopy.overviewIntro)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                SegmentedChoice(
                    label: "Show activity for",
                    options: ActivityScope.allCases,
                    selection: $scope,
                    title: { $0.title }
                )

                if recent.isEmpty {
                    EmptyStateView(
                        title: ActivityCopy.emptyTitle,
                        message: ActivityCopy.emptyMessage,
                        systemImage: "clock"
                    )
                } else {
                    ActivityEventSections(events: recent, snapshot: snapshot, showsChild: scope == .all)
                }

                ThemisGroupedSection("Children", data: Self.childLinks) { item in
                    ActivityLinkRow(item: item)
                }

                ThemisGroupedSection("History", data: Self.historyLinks(scope: scope)) { item in
                    ActivityLinkRow(item: item)
                }

                ThemisGroupedSection(AppleScreenTimeCopy.sectionLabel, data: Self.appleLinks) { item in
                    ActivityLinkRow(item: item)
                }

                Text(ActivityCopy.overviewFooter)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.bottom, ThemisSpacing.lg)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .toolbar(.hidden, for: .navigationBar)
        .activityNavigation(screen)
    }

    private static let childLinks: [ActivityLink] = ActivityChild.allCases.map { child in
        ActivityLink(
            id: "child-\(child.id)",
            route: .child(child),
            title: child.title,
            subtitle: "Themis outcomes for \(child.firstName)",
            child: child
        )
    }

    private static func historyLinks(scope: ActivityScope) -> [ActivityLink] {
        [
            ActivityLink(id: "rules", route: .ruleHistory(scope), title: "Rule history", subtitle: "Outcomes of your family’s rules"),
            ActivityLink(id: "requests", route: .requestHistory(scope), title: "Request history", subtitle: "Asked and decided"),
            ActivityLink(id: "protection", route: .protectionHistory(scope), title: "Protection history", subtitle: "Changes in device protection")
        ]
    }

    private static let appleLinks: [ActivityLink] = [
        ActivityLink(
            id: "apple-screen-time",
            route: .appleScreenTime,
            title: AppleScreenTimeCopy.title,
            subtitle: "Apple’s own report, kept separate from Themis activity"
        )
    ]
}

/// A navigation row on the overview or a child's Activity.
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

/// Events grouped under day headings ("Today", "Yesterday", "Monday").
struct ActivityEventSections: View {
    let events: [ActivityEvent]
    let snapshot: ActivitySnapshot
    let showsChild: Bool

    var body: some View {
        ForEach(snapshot.dayGroups(for: events)) { group in
            ThemisGroupedSection(group.title, data: group.events) { event in
                ActivityEventRow(event: event, showsChild: showsChild)
            }
        }
    }
}

/// One outcome: title, who and when, and the outcome with glyph and label.
/// Only events with timing evidence open a detail, since nothing else has more to show.
struct ActivityEventRow: View {
    let event: ActivityEvent
    let showsChild: Bool

    var body: some View {
        if event.timing != nil {
            NavigationLink(value: ActivityRoute.eventDetail(event.id)) {
                row(showsChevron: true)
            }
            .buttonStyle(.plain)
        } else {
            row(showsChevron: false)
        }
    }

    private func row(showsChevron: Bool) -> some View {
        ThemisRow(
            title: event.title,
            subtitle: subtitle,
            status: event.outcome,
            avatar: avatar,
            showsChevron: showsChevron
        )
    }

    private var avatar: (initial: String, tone: ThemisTone)? {
        showsChild ? (initial: event.child.initial, tone: event.child.tone) : nil
    }

    /// "Sam · 5:48 PM · Resolved by Sarah", then any detail on its own line.
    private var subtitle: String {
        var parts: [String] = []
        if showsChild { parts.append(event.child.firstName) }
        parts.append(ActivityCalendar.timeText(event.occurredAt))
        if let resolverText = event.resolverText { parts.append(resolverText) }
        let line = parts.joined(separator: " · ")
        if event.timing == nil, let detail = event.detail {
            return line + "\n" + detail
        }
        return line
    }
}

// MARK: - Previews (deterministic)

struct ActivityOverviewPreviewHost: View {
    @State var scope: ActivityScope
    var appleReport: AppleScreenTimeReportState = .systemOwnedReportArea

    var body: some View {
        NavigationStack {
            ActivityOverviewContentView(
                screen: ActivityScreenState(snapshot: ActivityDemoData.snapshot, appleReport: appleReport),
                scope: $scope
            )
        }
    }
}

#Preview("T-001 · Activity overview · All") {
    ActivityOverviewPreviewHost(scope: .all)
}

#Preview("T-001 · Activity overview · Sam") {
    ActivityOverviewPreviewHost(scope: .sam)
}

#Preview("T-001 · Activity overview · AX3") {
    ActivityOverviewPreviewHost(scope: .all)
        .environment(\.dynamicTypeSize, .accessibility3)
}
