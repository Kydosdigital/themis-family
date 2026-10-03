import SwiftUI

/// P-023 Parent Home. Loads its state from the repository and renders
/// `ParentHomeContentView`, which previews and review states use directly.
struct ParentHomeView: View {
    let scenario: DemoScenario

    @StateObject private var viewModel: ParentHomeViewModel
    @State private var destination: ParentHomeRoute?

    init(repository: any ParentDashboardRepository, scenario: DemoScenario) {
        self.scenario = scenario
        _viewModel = StateObject(wrappedValue: ParentHomeViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if let state = viewModel.state {
                ParentHomeContentView(state: state, open: open)
            } else if let errorMessage = viewModel.errorMessage {
                ScrollView {
                    ErrorStateView(title: errorMessage) {
                        Task { await viewModel.load(scenario: scenario) }
                    }
                    .padding(ThemisSpacing.screen)
                }
                .themisGround(.grouped)
            } else {
                LoadingStateView(label: "Loading your family")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .themisGround(.grouped)
            }
        }
        .navigationDestination(item: $destination) { route in
            switch route.screenID {
            case "A-001":
                ParentTaskApprovalFlowView(initial: .actionCentre)
            case "A-002":
                ParentTaskApprovalFlowView(initial: .review)
            case "A-004":
                ParentRequestFlowView(initial: .detail)
            case "F-001":
                FreePassFlowView()
            default:
                ShellPlaceholderView(title: route.title, screenID: route.screenID, isTabRoot: false)
            }
        }
        .task(id: scenario) {
            await viewModel.load(scenario: scenario)
        }
    }

    private func open(_ route: ParentHomeRoute) {
        destination = route
    }
}

/// The P-023 layout for a given state. No loading, no repository: deterministic
/// for previews and review.
///
/// Fixed scan order: Needs You, children and protection, current agreements,
/// quick actions. The quick-action dock floats above the tab bar at standard sizes
/// and moves inline at accessibility text sizes and on iPad, so it never covers content.
struct ParentHomeContentView: View {
    let state: ParentHomeState
    var open: (ParentHomeRoute) -> Void = { _ in }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var dockIsInline: Bool {
        dynamicTypeSize.isAccessibilitySize || horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: state.parentName, subtitle: state.greeting) {
                    BellButton(count: state.actionCentreCount) {
                        open(.actionCentre)
                    }
                }

                ForEach(state.sections, id: \.self) { section in
                    sectionView(section)
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? ThemisSpacing.screenPad : ThemisSpacing.screen)
            .padding(.bottom, dockIsInline ? 40 : ThemisSpacing.block)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !dockIsInline {
                QuickActionDock(actions: state.quickActions, placement: .floating, perform: perform)
            }
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .toolbar(navigationBarVisibility, for: .navigationBar)
    }

    @ViewBuilder
    private func sectionView(_ section: ParentHomeSection) -> some View {
        switch section {
        case .attention:
            attention
        case .children:
            ThemisGroupedSection("Children", data: state.children) { child in
                rowButton(destination: child.destination) {
                    ChildStatusRow(child: child)
                }
            }
        case .agreements:
            ThemisGroupedSection("Agreements", data: state.agreements) { agreement in
                rowButton(destination: agreement.destination) {
                    ThemisRow(title: agreement.title, subtitle: agreement.detail, showsChevron: true)
                }
            }
        case .quickActions:
            if dockIsInline {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                    SectionHeader(title: "Quick actions")
                        .padding(.horizontal, 4)
                    QuickActionDock(actions: state.quickActions, placement: .inline, perform: perform)
                }
            }
        }
    }

    @ViewBuilder
    private var attention: some View {
        switch state.attention {
        case let .needsYou(content):
            NeedsYouCard(content: content, open: open)
        case let .setupIncomplete(content), let .protectionProblem(content):
            HomeActionCard(content: content, open: open)
        case .nothingPending:
            InlineBanner(.success, "Nothing needs you right now")
        case .noChildren:
            // Not a drawn P-023 state. Onboarding (P-004 onwards) owns adding a child.
            EmptyStateView(
                title: "Add your first child",
                message: "Create a child profile, pair their device, then set the first family rule.",
                systemImage: "person.2"
            )
        }
    }

    @ViewBuilder
    private func rowButton<RowLabel: View>(destination: ParentHomeRoute?, @ViewBuilder label: () -> RowLabel) -> some View {
        if let destination {
            Button { open(destination) } label: { label() }
                .buttonStyle(.plain)
        } else {
            label()
        }
    }

    private func perform(_ action: ParentQuickAction) {
        open(action.destination)
    }

    /// The page header replaces the navigation bar on this tab root. Debug builds keep
    /// the bar so the demo scenario control stays reachable; review screenshots use the
    /// previews below, which match Release.
    private var navigationBarVisibility: Visibility {
        #if DEBUG
        return .automatic
        #else
        return .hidden
        #endif
    }
}

// MARK: - Review states (deterministic)

#Preview("P-023 · Needs you") {
    NavigationStack {
        ParentHomeContentView(state: ParentHomeDemoData.canonical())
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("P-023 · Clear") {
    NavigationStack {
        ParentHomeContentView(state: ParentHomeDemoData.nothingPending)
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("P-023 · Setup incomplete") {
    NavigationStack {
        ParentHomeContentView(state: ParentHomeDemoData.setupIncomplete)
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("P-023 · Protection problem") {
    NavigationStack {
        ParentHomeContentView(state: ParentHomeDemoData.protectionProblem)
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("P-023 · Needs you · AX3") {
    NavigationStack {
        ParentHomeContentView(state: ParentHomeDemoData.canonical())
            .toolbar(.hidden, for: .navigationBar)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("P-023 · Protection unavailable · AX5") {
    NavigationStack {
        ParentHomeContentView(
            state: ParentHomeDemoData.canonical(
                samProtection: .protectionUnavailable,
                samEvidence: .noticed(minutesAgo: 10)
            )
        )
        .toolbar(.hidden, for: .navigationBar)
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("P-023 · In tab shell") {
    ParentTabShell(selection: .constant(.home)) { tab in
        if tab == .home {
            ParentHomeContentView(state: ParentHomeDemoData.canonical())
                .toolbar(.hidden, for: .navigationBar)
        } else {
            ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID)
        }
    }
}
