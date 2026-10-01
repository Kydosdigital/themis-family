import SwiftUI

// T-002 Child activity, T-003 Rule changes, T-004 Requests, T-005 Protection, and the
// timing-unverified detail. All are pushed inside the Parent tab's NavigationStack, so they
// use the native navigation bar and create no stack of their own. None offers an action:
// everything shown was resolved elsewhere.

/// Registers the Activity destinations. Apply once on the Activity root.
extension View {
    func activityNavigation(_ screen: ActivityScreenState) -> some View {
        navigationDestination(for: ActivityRoute.self) { route in
            ActivityDestinationView(route: route, screen: screen)
        }
    }
}

struct ActivityDestinationView: View {
    let route: ActivityRoute
    let screen: ActivityScreenState

    var body: some View {
        switch route {
        case let .child(child):
            ChildActivityView(child: child, snapshot: screen.snapshot)
        case .ruleChanges:
            RuleChangesView(snapshot: screen.snapshot)
        case .requestHistory:
            RequestHistoryView(snapshot: screen.snapshot)
        case .protectionHistory:
            ProtectionHistoryView(snapshot: screen.snapshot)
        case .appleScreenTime:
            AppleScreenTimeBoundaryView(state: screen.appleReport)
        case let .eventDetail(id):
            if let event = screen.snapshot.event(id: id) {
                ActivityEventDetailView(event: event)
            } else {
                EmptyStateView(title: ActivityCopy.emptyTitle, systemImage: "clock")
                    .themisGround(.grouped)
            }
        }
    }
}

/// Shared frame for a pushed Activity screen.
private struct ActivityPage<Content: View>: View {
    let title: String
    var ground: ThemisGround = .grouped
    private let content: Content

    init(title: String, ground: ThemisGround = .grouped, @ViewBuilder content: () -> Content) {
        self.title = title
        self.ground = ground
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                content
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.top, ThemisSpacing.inline8)
            .padding(.bottom, ThemisSpacing.lg)
        }
        .themisAudience(.parent)
        .themisGround(ground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Supporting copy under a list, in the frames' secondary text style.
private struct ActivityNote: View {
    let text: String

    var body: some View {
        Text(text)
            .themisFont(.secondary)
            .foregroundStyle(ThemisColor.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - T-002 Child activity

/// One child's Themis-owned outcomes for this week. No Apple data appears here; the Screen
/// Time link only opens Apple's own, separately bounded screen.
struct ChildActivityView: View {
    let child: ActivityChild
    let snapshot: ActivitySnapshot

    var body: some View {
        let summary = snapshot.summary(for: ActivityScope(child), period: .thisWeek)
        let rows = ActivityPresentation.weekRows(for: child, snapshot: snapshot)

        ActivityPage(title: child.firstName) {
            KeyValueList(
                items: ActivityPresentation.summaryItems(summary).map { KeyValueList.Item($0.key, $0.value) }
            )

            if !rows.isEmpty {
                ThemisGroupedSection(ActivityPeriod.thisWeek.title, data: rows) { row in
                    ActivityRowView(row: row)
                }
            }

            if ActivityPresentation.showsAppUsageNote(for: child) {
                ActivityNote(text: ActivityCopy.appUsageNote(for: child))
            }

            NavigationLink(value: ActivityRoute.appleScreenTime) {
                Text(AppleScreenTimeCopy.childLinkTitle)
                    .themisFont(.rowTitle)
                    .foregroundStyle(ThemisColor.brandPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: ThemisSize.tapMinimum)
            }
            .buttonStyle(.plain)
        }
    }
}

/// Timing-unverified detail. Both times are shown as recorded; the outcome is never
/// restated as on time or late, and there are no actions because the task was already
/// resolved.
struct ActivityEventDetailView: View {
    let event: ActivityEvent

    var body: some View {
        ActivityPage(title: event.title) {
            StatusHeader(status: event.outcome, explanation: event.detail ?? "")

            if let timing = event.timing {
                KeyValueList(
                    items: [
                        .init("Child-device claimed", timing.claimedText),
                        .init("Server received", timing.serverReceivedText)
                    ]
                )
            }

            KeyValueList(items: summaryItems)
        }
    }

    private var summaryItems: [KeyValueList.Item] {
        var items: [KeyValueList.Item] = [
            .init("Child", event.child.title),
            .init("Outcome", event.outcome.label)
        ]
        if let resolver = event.resolver {
            items.append(.init("Resolved by", resolver))
        }
        return items
    }
}

// MARK: - T-003 Rule changes

/// Who changed which rule, and when, by month. Shows the last 12 months.
struct RuleChangesView: View {
    let snapshot: ActivitySnapshot

    var body: some View {
        ActivityPage(title: "Rule changes") {
            ForEach(ActivityPresentation.ruleChangeSections(snapshot: snapshot)) { section in
                ThemisGroupedSection(section.title, data: section.rows) { row in
                    ActivityRowView(row: row)
                }
            }

            ActivityNote(text: ActivityRetention.ruleChangesFooter)
        }
    }
}

// MARK: - T-004 Requests

/// Requests and their outcomes, read-only. No decision controls and no message thread.
/// Structured outcomes keep the 12-month period; only reasons and notes are removed at 90 days.
struct RequestHistoryView: View {
    @State private var scope: ActivityScope
    let snapshot: ActivitySnapshot

    init(initialScope: ActivityScope = .all, snapshot: ActivitySnapshot) {
        _scope = State(initialValue: initialScope)
        self.snapshot = snapshot
    }

    var body: some View {
        ActivityPage(title: "Requests") {
            SegmentedChoice(
                label: "Show requests for",
                options: ActivityScope.allCases,
                selection: $scope,
                title: { $0.title }
            )

            ThemisGroupedSection(data: ActivityPresentation.requestRows(scope: scope, snapshot: snapshot)) { row in
                ActivityRowView(row: row)
            }

            ActivityNote(text: ActivityRetention.requestsFooter)
        }
    }
}

// MARK: - T-005 Protection

/// Current protection with when it was last verified, then earlier changes. Recovery
/// belongs to Protection (UI-09), not here.
struct ProtectionHistoryView: View {
    let snapshot: ActivitySnapshot

    var body: some View {
        ActivityPage(title: "Protection") {
            ThemisGroupedSection("Now", data: ActivityPresentation.protectionNowRows(snapshot: snapshot)) { row in
                ActivityRowView(row: row)
            }

            ThemisGroupedSection("Earlier", data: ActivityPresentation.protectionEarlierRows(snapshot: snapshot)) { row in
                ActivityRowView(row: row)
            }
        }
    }
}

// MARK: - Previews (deterministic)

/// Hosts a pushed Activity screen with its destinations registered, for previews only.
struct ActivityPreviewHost<Content: View>: View {
    let snapshot: ActivitySnapshot
    let appleReport: AppleScreenTimeReportState
    private let content: Content

    init(
        snapshot: ActivitySnapshot = ActivityDemoData.snapshot,
        appleReport: AppleScreenTimeReportState = .systemOwnedReportArea,
        @ViewBuilder content: () -> Content
    ) {
        self.snapshot = snapshot
        self.appleReport = appleReport
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .activityNavigation(ActivityScreenState(snapshot: snapshot, appleReport: appleReport))
        }
    }
}

#Preview("T-002 · Sam activity") {
    ActivityPreviewHost { ChildActivityView(child: .sam, snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-002 · Maya activity") {
    ActivityPreviewHost { ChildActivityView(child: .maya, snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-002 · Sam activity · AX3") {
    ActivityPreviewHost { ChildActivityView(child: .sam, snapshot: ActivityDemoData.snapshot) }
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("T-003 · Rule changes") {
    ActivityPreviewHost { RuleChangesView(snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-002 · Timing unverified detail") {
    ActivityPreviewHost {
        ActivityEventDetailView(
            event: ActivityDemoData.snapshot.event(id: "sam-homework-timing-unverified") ?? ActivityDemoData.events[0]
        )
    }
}

#Preview("T-004 · Requests") {
    ActivityPreviewHost { RequestHistoryView(snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-005 · Protection") {
    ActivityPreviewHost { ProtectionHistoryView(snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-005 · Protection · all five states") {
    ActivityPreviewHost(snapshot: ActivityDemoData.allProtectionStatesSnapshot) {
        ProtectionHistoryView(snapshot: ActivityDemoData.allProtectionStatesSnapshot)
    }
}
