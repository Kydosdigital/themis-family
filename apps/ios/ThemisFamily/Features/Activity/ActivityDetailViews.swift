import SwiftUI

// T-002 Child activity, T-003 Rule history, T-004 Request history, T-005 Protection
// history, and the timing-unverified detail. All are pushed inside the Parent tab's
// NavigationStack, so they use the native navigation bar and create no stack of their own.
// None of them offers an action: everything shown was resolved elsewhere.

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
        case let .ruleHistory(scope):
            RuleHistoryView(scope: scope, snapshot: screen.snapshot)
        case let .requestHistory(scope):
            RequestHistoryView(initialScope: scope, snapshot: screen.snapshot)
        case let .protectionHistory(scope):
            ProtectionHistoryView(scope: scope, snapshot: screen.snapshot)
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
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
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
        .themisGround(.grouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - T-002 Child activity

/// One child's Themis-owned outcomes. No Apple data appears here; the Screen Time row
/// only links to Apple's own, separately bounded screen.
struct ChildActivityView: View {
    let child: ActivityChild
    let snapshot: ActivitySnapshot

    var body: some View {
        let scope = ActivityScope(child)
        ActivityPage(title: child.firstName) {
            ThemisCard {
                HStack(spacing: ThemisSpacing.inline12) {
                    AvatarTile(initial: child.initial, tone: child.tone, size: .large)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.title)
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text("Themis outcomes only")
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }

            ActivityEventSections(events: snapshot.events(for: scope), snapshot: snapshot, showsChild: false)

            ThemisGroupedSection("History for \(child.firstName)", data: historyLinks(scope)) { item in
                ActivityLinkRow(item: item)
            }

            Text(ActivityCopy.appUsageNote(for: child))
                .themisFont(.meta)
                .foregroundStyle(ThemisColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)

            ThemisGroupedSection(AppleScreenTimeCopy.sectionLabel, data: [appleLink]) { item in
                ActivityLinkRow(item: item)
            }
        }
    }

    private func historyLinks(_ scope: ActivityScope) -> [ActivityLink] {
        [
            ActivityLink(id: "rules", route: .ruleHistory(scope), title: "Rule history", subtitle: "Outcomes of \(child.firstName)’s rules"),
            ActivityLink(id: "requests", route: .requestHistory(scope), title: "Request history", subtitle: "Asked and decided"),
            ActivityLink(id: "protection", route: .protectionHistory(scope), title: "Protection history", subtitle: "Changes in \(child.deviceName) protection")
        ]
    }

    private var appleLink: ActivityLink {
        ActivityLink(
            id: "apple-screen-time",
            route: .appleScreenTime,
            title: "Open Apple’s Screen Time report",
            subtitle: "Shown by Apple, separate from Themis activity"
        )
    }
}

// MARK: - T-003 Rule history

/// Outcomes under the family's rules, including task outcomes such as approvals.
struct RuleHistoryView: View {
    let scope: ActivityScope
    let snapshot: ActivitySnapshot

    var body: some View {
        let events = snapshot.events(for: scope, categories: [.rule, .task])
        ActivityPage(title: "Rule history") {
            if events.isEmpty {
                EmptyStateView(title: ActivityCopy.emptyTitle, message: ActivityCopy.emptyMessage, systemImage: "clock")
            } else {
                ActivityEventSections(events: events, snapshot: snapshot, showsChild: scope == .all)
            }
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

// MARK: - T-004 Request history

/// Requests and their outcomes, read-only. No decision controls and no message thread.
struct RequestHistoryView: View {
    @State private var scope: ActivityScope
    let snapshot: ActivitySnapshot

    init(initialScope: ActivityScope = .all, snapshot: ActivitySnapshot) {
        _scope = State(initialValue: initialScope)
        self.snapshot = snapshot
    }

    var body: some View {
        let events = snapshot.events(for: scope, categories: [.request])
        ActivityPage(title: "Request history") {
            SegmentedChoice(
                label: "Show requests for",
                options: ActivityScope.allCases,
                selection: $scope,
                title: { $0.title }
            )

            if events.isEmpty {
                EmptyStateView(title: ActivityCopy.emptyTitle, message: ActivityCopy.emptyMessage, systemImage: "clock")
            } else {
                ActivityEventSections(events: events, snapshot: snapshot, showsChild: scope == .all)
            }
        }
    }
}

// MARK: - T-005 Protection history

/// Current protection with its evidence, then earlier changes. Recovery belongs to
/// Protection (UI-09), not here.
struct ProtectionHistoryView: View {
    let scope: ActivityScope
    let snapshot: ActivitySnapshot

    var body: some View {
        let current = snapshot.protectionNow(for: scope)
        let events = snapshot.events(for: scope, categories: [.protection])
        ActivityPage(title: "Protection history") {
            ThemisGroupedSection("Now", data: current) { item in
                ThemisRow(
                    title: item.child.deviceName,
                    subtitle: item.evidence,
                    status: item.status,
                    avatar: (initial: item.child.initial, tone: item.child.tone)
                )
            }

            ActivityEventSections(events: events, snapshot: snapshot, showsChild: scope == .all)

            Text(ActivityCopy.protectionFooter)
                .themisFont(.meta)
                .foregroundStyle(ThemisColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: - Previews (deterministic)

/// Hosts a pushed Activity screen with its destinations registered, for previews only.
struct ActivityPreviewHost<Content: View>: View {
    let appleReport: AppleScreenTimeReportState
    private let content: Content

    init(appleReport: AppleScreenTimeReportState = .systemOwnedReportArea, @ViewBuilder content: () -> Content) {
        self.appleReport = appleReport
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .activityNavigation(ActivityScreenState(snapshot: ActivityDemoData.snapshot, appleReport: appleReport))
        }
    }
}

#Preview("T-002 · Sam activity") {
    ActivityPreviewHost { ChildActivityView(child: .sam, snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-002 · Maya activity") {
    ActivityPreviewHost { ChildActivityView(child: .maya, snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-003 · Rule history") {
    ActivityPreviewHost { RuleHistoryView(scope: .all, snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-003 · Timing unverified detail") {
    ActivityPreviewHost {
        ActivityEventDetailView(
            event: ActivityDemoData.snapshot.event(id: "sam-homework-timing-unverified") ?? ActivityDemoData.events[0]
        )
    }
}

#Preview("T-004 · Request history") {
    ActivityPreviewHost { RequestHistoryView(snapshot: ActivityDemoData.snapshot) }
}

#Preview("T-005 · Protection history") {
    ActivityPreviewHost { ProtectionHistoryView(scope: .all, snapshot: ActivityDemoData.snapshot) }
}
