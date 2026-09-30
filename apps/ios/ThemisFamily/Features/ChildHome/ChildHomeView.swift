import SwiftUI

enum ChildHomeRoute: String, Identifiable, Hashable {
    case active
    case transparency
    case essentialAccess
    case myRules

    var id: String { rawValue }
}

/// UI-03 Child + Teen Home entry point. Repository-backed for production architecture,
/// while deterministic presentation states make previews and visual review repeatable.
struct ChildHomeView: View {
    let childID: UUID
    let scenario: DemoScenario

    @StateObject private var viewModel: ChildHomeViewModel
    @State private var destination: ChildHomeRoute?

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
        Group {
            if let state = viewModel.state {
                ChildHomeContentView(state: state) { destination = $0 }
            } else if let errorMessage = viewModel.errorMessage {
                ScrollView {
                    ErrorStateView(title: errorMessage) {
                        Task { await viewModel.load(childID: childID, scenario: scenario) }
                    }
                    .padding(ThemisSpacing.screen)
                }
                .themisGround(.grouped)
            } else {
                LoadingStateView(label: "Loading Themis")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .themisGround(.grouped)
            }
        }
        .navigationDestination(item: $destination) { route in
            if let state = viewModel.state {
                destinationView(route, state: state)
            }
        }
        .task(id: scenario) {
            await viewModel.load(childID: childID, scenario: scenario)
        }
    }

    @ViewBuilder
    private func destinationView(_ route: ChildHomeRoute, state: ChildTeenHomeState) -> some View {
        switch route {
        case .active:
            ThemisActiveView(state: state)
        case .transparency:
            TransparencyDetailView(
                state: state.transparency,
                audience: ThemisAudience(state.audience)
            )
        case .essentialAccess:
            EssentialAccessView(
                state: state.essentialAccess,
                audience: ThemisAudience(state.audience)
            )
        case .myRules:
            ShellPlaceholderView(title: "My Rules", screenID: "C-015", isTabRoot: false)
        }
    }
}

/// Deterministic C-001 layout used by the app, previews and Simulator review.
struct ChildHomeContentView: View {
    let state: ChildTeenHomeState
    var open: (ChildHomeRoute) -> Void = { _ in }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var audience: ThemisAudience { ThemisAudience(state.audience) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                header
                activeCard
                transparencyLink

                switch state.content {
                case let .childHomework(homework):
                    childHomework(homework)
                case let .teen(teen):
                    teenHome(teen)
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? ThemisSpacing.screenPad : ThemisSpacing.screen)
            .padding(.bottom, 40)
        }
        .themisAudience(audience)
        .themisGround(audience.homeGround)
        .toolbar(navigationBarVisibility, for: .navigationBar)
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
            if let dayLabel = state.dayLabel {
                Text(dayLabel)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

            Text(state.audience == .child ? "Hi \(state.firstName)" : state.firstName)
                .themisFont(.pageTitle)
                .foregroundStyle(ThemisColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.top, 8)
    }

    private var activeCard: some View {
        Button { open(.active) } label: {
            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                    StatusBadge(state.activeStatus, size: .chip, accessibilityContext: "Themis status")
                    HStack(spacing: ThemisSpacing.inline10) {
                        Text("Themis is active")
                            .themisFont(.rowTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(ThemisColor.chevron)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens Themis status and essential access information")
    }

    private var transparencyLink: some View {
        Button { open(.transparency) } label: {
            HStack(spacing: ThemisSpacing.inline8) {
                Image(systemName: "eye")
                    .accessibilityHidden(true)
                Text(state.transparencyLinkTitle)
                    .themisFont(.rowTitle)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(ThemisColor.brandPrimary)
            .frame(minHeight: ThemisSize.tapMinimum)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func childHomework(_ homework: ChildHomeworkHomeState) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            SectionHeader(title: homework.sectionTitle)
                .padding(.horizontal, 4)

            ThemisCard(padding: ThemisSpacing.cardTask) {
                VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                    StatusBadge(homework.status, size: .chip)

                    VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                        Text("Homework")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(homework.dueText)
                            .themisFont(.screenTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                    }

                    AgreementTimeline(model: homework.timeline)

                    ConsequenceNote(
                        text: homework.consequence,
                        background: ThemisColor.statusBgWarning
                    )

                    ThemisButton(
                        title: homework.primaryActionTitle,
                        systemImage: "checkmark"
                    ) {
                        open(.myRules)
                    }

                    ThemisButton(
                        title: homework.secondaryActionTitle,
                        systemImage: "clock.badge.questionmark",
                        style: .secondary
                    ) {
                        open(.myRules)
                    }
                }
            }
        }
    }

    private func teenHome(_ teen: TeenHomeState) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                SectionHeader(title: teen.nowSectionTitle)
                    .padding(.horizontal, 4)

                ThemisCard(padding: ThemisSpacing.cardTask) {
                    VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                        VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                            Text(teen.scheduleTitle)
                                .themisFont(.headline)
                                .foregroundStyle(ThemisColor.textPrimary)
                            Text(teen.scheduleSummary)
                                .themisFont(.body)
                                .foregroundStyle(ThemisColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        StatusBadge(teen.scheduleStatus, size: .chip)

                        AgreementTimeline(model: teen.eveningTimeline)
                    }
                }
            }

            VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                SectionHeader(title: teen.todaySectionTitle)
                    .padding(.horizontal, 4)

                ThemisCard(padding: ThemisSpacing.cardTask) {
                    VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                        VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                            Text(teen.focusTitle)
                                .themisFont(.headline)
                                .foregroundStyle(ThemisColor.textPrimary)
                            Text(teen.focusSummary)
                                .themisFont(.body)
                                .foregroundStyle(ThemisColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        ThemisButton(
                            title: teen.startActionTitle,
                            systemImage: "play.fill"
                        ) {
                            open(.myRules)
                        }

                        ThemisButton(
                            title: teen.requestActionTitle,
                            systemImage: "clock.badge.questionmark",
                            style: .secondary
                        ) {
                            open(.myRules)
                        }
                    }
                }
            }
        }
    }

    private var navigationBarVisibility: Visibility {
        #if DEBUG
        return .automatic
        #else
        return .hidden
        #endif
    }
}

/// C-012 · Themis is active.
struct ThemisActiveView: View {
    let state: ChildTeenHomeState

    private var audience: ThemisAudience { ThemisAudience(state.audience) }
    private var ground: ThemisGround { state.audience == .child ? .warm : .plain }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: state.activeStatus,
                    explanation: state.audience == .child
                        ? "Your family rules are active on this iPhone. You can see what is set up and what your parent or carer can see."
                        : "Themis is active on this iPhone. This page shows your family rules, configured essential access and the privacy boundary."
                )

                SectionHeader(title: "Your Themis")
                    .padding(.horizontal, 4)

                ThemisCard(padding: 0) {
                    VStack(spacing: 0) {
                        NavigationLink {
                            ShellPlaceholderView(title: "My Rules", screenID: "C-015", isTabRoot: false)
                        } label: {
                            ThemisRow(
                                title: "My rules",
                                subtitle: "See the family rules that apply to this iPhone",
                                isLink: true,
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)

                        divider

                        NavigationLink {
                            EssentialAccessView(state: state.essentialAccess, audience: audience)
                        } label: {
                            ThemisRow(
                                title: "Essential access",
                                subtitle: "See how school and important access are configured",
                                isLink: true,
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)

                        divider

                        NavigationLink {
                            TransparencyDetailView(state: state.transparency, audience: audience)
                        } label: {
                            ThemisRow(
                                title: state.transparencyLinkTitle,
                                subtitle: "See exactly what Themis does and does not provide",
                                isLink: true,
                                showsChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                InlineBanner(
                    .info,
                    "Phone, Messages and Maps can be configured or recommended to stay available where supported. Emergency calling is never deliberately restricted."
                )
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.vertical, ThemisSpacing.block)
        }
        .themisAudience(audience)
        .themisGround(ground)
        .navigationTitle("Themis is active")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var divider: some View {
        Rectangle()
            .fill(ThemisColor.borderHairline)
            .frame(height: ThemisBorder.hairline)
            .accessibilityHidden(true)
    }
}

/// C-013 · Child and Teen transparency.
struct TransparencyDetailView: View {
    let state: TransparencyState
    let audience: ThemisAudience

    private var ground: ThemisGround { audience == .child ? .warm : .plain }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text(state.title)
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(state.intro)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                factSection(
                    title: state.visibleSectionTitle,
                    facts: state.visibleFacts,
                    systemImage: "eye"
                )

                factSection(
                    title: state.privateSectionTitle,
                    facts: state.privateFacts,
                    systemImage: "lock.fill"
                )
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.vertical, ThemisSpacing.block)
        }
        .themisAudience(audience)
        .themisGround(ground)
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func factSection(title: String, facts: [String], systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            SectionHeader(title: title)
                .padding(.horizontal, 4)

            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    ForEach(facts, id: \.self) { fact in
                        HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline10) {
                            Image(systemName: systemImage)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(ThemisColor.brandPrimary)
                                .accessibilityHidden(true)
                            Text(fact)
                                .themisFont(.body)
                                .foregroundStyle(ThemisColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }
}

/// C-014 · Essential access and reassurance.
struct EssentialAccessView: View {
    let state: EssentialAccessState
    let audience: ThemisAudience

    private var ground: ThemisGround { audience == .child ? .warm : .plain }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text(state.title)
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(state.intro)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        ForEach(state.facts, id: \.self) { fact in
                            HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline10) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(ThemisColor.brandPrimary)
                                    .accessibilityHidden(true)
                                Text(fact)
                                    .themisFont(.body)
                                    .foregroundStyle(ThemisColor.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }

                InlineBanner(
                    .info,
                    "Themis does not claim deep content filtering, and Apple capability details remain subject to the approved real-device gates."
                )
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.vertical, ThemisSpacing.block)
        }
        .themisAudience(audience)
        .themisGround(ground)
        .navigationTitle("Essential access")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Review states

#Preview("C-001 · Sam Child") {
    NavigationStack {
        ChildHomeContentView(state: ChildTeenHomeDemoData.sam)
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("C-001 · Sam Child · AX3") {
    NavigationStack {
        ChildHomeContentView(state: ChildTeenHomeDemoData.sam)
            .toolbar(.hidden, for: .navigationBar)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("C-001 · Maya Teen") {
    NavigationStack {
        ChildHomeContentView(state: ChildTeenHomeDemoData.maya)
            .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("C-001 · Maya Teen · AX3") {
    NavigationStack {
        ChildHomeContentView(state: ChildTeenHomeDemoData.maya)
            .toolbar(.hidden, for: .navigationBar)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("C-012 · Child") {
    NavigationStack {
        ThemisActiveView(state: ChildTeenHomeDemoData.sam)
    }
}

#Preview("C-013 · Child") {
    NavigationStack {
        TransparencyDetailView(
            state: ChildTeenHomeDemoData.childTransparency,
            audience: .child
        )
    }
}

#Preview("C-013 · Teen") {
    NavigationStack {
        TransparencyDetailView(
            state: ChildTeenHomeDemoData.teenTransparency,
            audience: .teen
        )
    }
}

#Preview("C-014 · Child") {
    NavigationStack {
        EssentialAccessView(
            state: ChildTeenHomeDemoData.childEssentialAccess,
            audience: .child
        )
    }
}

#Preview("C-014 · Teen") {
    NavigationStack {
        EssentialAccessView(
            state: ChildTeenHomeDemoData.teenEssentialAccess,
            audience: .teen
        )
    }
}

#Preview("C-001 · Sam in tab shell") {
    ChildTabShell(segment: .child, selection: .constant(.home)) { tab in
        if tab == .home {
            ChildHomeContentView(state: ChildTeenHomeDemoData.sam)
                .toolbar(.hidden, for: .navigationBar)
        } else {
            ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID(for: .child))
        }
    }
}

#Preview("C-001 · Maya in tab shell") {
    ChildTabShell(segment: .teen, selection: .constant(.home)) { tab in
        if tab == .home {
            ChildHomeContentView(state: ChildTeenHomeDemoData.maya)
                .toolbar(.hidden, for: .navigationBar)
        } else {
            ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID(for: .teen))
        }
    }
}
