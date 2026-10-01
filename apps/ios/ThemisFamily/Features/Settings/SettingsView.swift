import SwiftUI

/// ST-001 Settings, the Parent Settings tab root.
///
/// Rendered inside the Parent tab's own `NavigationStack`, so this view does not create one.
/// Not wired into `RootView` on this branch. Owner sees the full list; a Guardian sees the
/// Owner-only rows as visible, labelled "Owner only", and not actionable.
struct SettingsView: View {
    @StateObject private var model: SettingsViewModel
    @StateObject private var navigator: SettingsNavigator

    init(
        repository: any SettingsRepository = MockSettingsRepository(),
        scenario: SettingsScenario = .owner,
        integration: SettingsIntegration = SettingsIntegration()
    ) {
        _model = StateObject(
            wrappedValue: SettingsViewModel(repository: repository, state: SettingsDemoData.state(for: scenario))
        )
        _navigator = StateObject(wrappedValue: SettingsNavigator(integration: integration))
    }

    var body: some View {
        SettingsRootView()
            .environmentObject(model)
            .environmentObject(navigator)
            .themisAudience(.parent)
    }
}

/// The ST-001 layout for the current household and viewer.
struct SettingsRootView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "Settings")

                ForEach(SettingsPresentation.rootSections(household: model.household, viewerRole: model.viewerRole)) { section in
                    SettingsRowsSection(section: section)
                }
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.bottom, ThemisSpacing.lg)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .toolbar(.hidden, for: .navigationBar)
        .settingsLevel(0)
    }
}

/// Routes a Settings route to its screen. Each screen can push the next at `depth`.
struct SettingsDestinationView: View {
    let route: SettingsRoute
    let depth: Int

    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        Group {
            switch route {
            case .household: HouseholdView()
            case .guardian: GuardianView()
            case .inviteGuardian: InviteGuardianView()
            case .childrenAndDevices: ChildrenAndDevicesView()
            case .addChild: AddChildView()
            case let .editChild(id):
                if let child = model.household.child(id: id) {
                    EditChildView(child: child)
                } else {
                    EmptyStateView(title: "Child not found", systemImage: "person")
                }
            case let .device(id): DeviceDetailView(childID: id)
            case .notifications: NotificationsView()
            case .privacy: PrivacyView()
            case .support: SupportView()
            case let .diagnose(id): DiagnoseDeviceView(childID: id)
            case .contactSupport: ContactSupportView()
            case .safeguarding: SafeguardingView()
            case .transferOwnership: TransferOwnershipView()
            case .ownershipTransferred: OwnershipTransferredView()
            case .leaveHousehold: LeaveHouseholdView()
            case .deleteHousehold: DeleteHouseholdView()
            case .householdDeleted: HouseholdDeletedView()
            case .account: AccountView()
            case let .external(destination):
                ShellPlaceholderView(title: destination.title, screenID: destination.screenID, isTabRoot: false)
            }
        }
        .settingsLevel(depth)
    }
}

// MARK: - Shared pieces

/// A Settings list section built from row models.
struct SettingsRowsSection: View {
    let section: SettingsRowSection

    var body: some View {
        ThemisGroupedSection(section.title, data: section.rows) { row in
            SettingsRowView(row: row)
        }
    }
}

/// One row. A row with a route pushes it; a row for another slice's screen opens it through the
/// integration hook; an Owner-only row for a Guardian is visible, labelled and not actionable.
struct SettingsRowView: View {
    let row: SettingsRowModel

    @EnvironmentObject private var navigator: SettingsNavigator

    var body: some View {
        if let route = row.route, !row.isOwnerOnlyLocked {
            Button {
                if case let .external(destination) = route {
                    navigator.open(destination)
                } else {
                    navigator.push(route)
                }
            } label: {
                content(showsChevron: true)
            }
            .buttonStyle(.plain)
        } else if row.isOwnerOnlyLocked {
            // Spoken in words, so the boundary never rests on opacity or colour.
            content(showsChevron: false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(row.accessibilityDescription)
                .accessibilityHint(row.accessibilityHint ?? "")
                .accessibilityAddTraits(.isStaticText)
        } else {
            content(showsChevron: false)
        }
    }

    private func content(showsChevron: Bool) -> some View {
        ThemisRow(
            title: row.title,
            subtitle: row.subtitle,
            status: row.status,
            value: row.value,
            avatar: avatar,
            showsChevron: showsChevron
        )
    }

    private var avatar: (initial: String, tone: ThemisTone)? {
        guard let avatar = row.avatar else { return nil }
        return (initial: avatar.initial, tone: avatar.tone)
    }
}

/// Frame for a pushed Settings screen: a scrolling page with the native navigation bar and an
/// optional bottom action area. At accessibility text sizes the actions move into the page, so
/// nothing is pinned over content, and the bottom area follows the keyboard otherwise.
struct SettingsPage<Content: View, Bottom: View>: View {
    let title: String
    var ground: ThemisGround
    private(set) var hasBottom: Bool
    private let content: Content
    private let bottom: Bottom

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        title: String,
        ground: ThemisGround = .grouped,
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottom: () -> Bottom
    ) {
        self.title = title
        self.ground = ground
        self.hasBottom = true
        self.content = content()
        self.bottom = bottom()
    }

    var body: some View {
        let inline = dynamicTypeSize.isAccessibilitySize

        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                content
                if hasBottom && inline {
                    bottomStack
                }
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.top, ThemisSpacing.inline8)
            .padding(.bottom, ThemisSpacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if hasBottom && !inline {
                bottomStack
                    .padding(.horizontal, ThemisSpacing.screen)
                    .padding(.vertical, ThemisSpacing.inline12)
                    .background(ground.background)
            }
        }
        .themisAudience(.parent)
        .themisGround(ground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var bottomStack: some View {
        VStack(spacing: ThemisSpacing.inline8) {
            bottom
        }
    }
}

extension SettingsPage where Bottom == EmptyView {
    init(title: String, ground: ThemisGround = .grouped, @ViewBuilder content: () -> Content) {
        self.init(title: title, ground: ground, content: content, bottom: { EmptyView() })
        self.hasBottom = false
    }
}

/// Supporting copy in the frames' secondary text style.
struct SettingsNote: View {
    let text: String

    var body: some View {
        Text(text)
            .themisFont(.secondary)
            .foregroundStyle(ThemisColor.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A screen title ("Make Alex the Owner?").
struct SettingsTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .themisFont(.screenTitle)
            .foregroundStyle(ThemisColor.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A tappable card with a title, subtitle and chevron (ST-010 choices).
struct SettingsChoiceCard: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ThemisCard {
                HStack(spacing: ThemisSpacing.inline12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .themisFont(.rowTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(subtitle)
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ThemisColor.chevron)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview host

/// Hosts a Settings screen with a deterministic household, for previews only.
struct SettingsPreviewHost<Content: View>: View {
    @StateObject private var model: SettingsViewModel
    @StateObject private var navigator = SettingsNavigator()
    private let content: Content

    init(_ scenario: SettingsScenario = .owner, @ViewBuilder content: () -> Content) {
        _model = StateObject(wrappedValue: SettingsViewModel(state: SettingsDemoData.state(for: scenario)))
        self.content = content()
    }

    init(model: SettingsViewModel, @ViewBuilder content: () -> Content) {
        _model = StateObject(wrappedValue: model)
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content.settingsLevel(1)
        }
        .environmentObject(model)
        .environmentObject(navigator)
        .themisAudience(.parent)
    }
}

#Preview("ST-001 · Owner") {
    SettingsPreviewHost(.owner) { SettingsRootView() }
}

#Preview("ST-001 · Guardian") {
    SettingsPreviewHost(.guardian) { SettingsRootView() }
}

#Preview("ST-001 · Owner · AX3") {
    SettingsPreviewHost(.owner) { SettingsRootView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("ST-001 · Guardian · AX3") {
    SettingsPreviewHost(.guardian) { SettingsRootView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}
