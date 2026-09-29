import SwiftUI

/// `ThemisNavigationShell` for the Parent experience.
///
/// iPhone, and iPad at accessibility text sizes: native `TabView`, one `NavigationStack`
/// per tab. iPad at regular width: native `NavigationSplitView` with the same four
/// destinations in the sidebar. The information architecture is identical in both.
struct ParentTabShell<Content: View>: View {
    @Binding var selection: ParentTab
    private let content: (ParentTab) -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(selection: Binding<ParentTab>, @ViewBuilder content: @escaping (ParentTab) -> Content) {
        _selection = selection
        self.content = content
    }

    var body: some View {
        Group {
            if usesSplitView {
                splitView
            } else {
                tabView
            }
        }
        .themisAudience(.parent)
        .tint(ThemisColor.brandPrimary)
    }

    /// Size-class driven, so iPadOS multitasking and Dynamic Type both fall back to tabs
    /// natively. No custom width threshold.
    private var usesSplitView: Bool {
        horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize
    }

    private var tabView: some View {
        TabView(selection: $selection) {
            ForEach(ParentTab.allCases) { tab in
                NavigationStack {
                    content(tab)
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                .tag(tab)
                .toolbarBackground(ThemisAudience.parent.tabBarBackground, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            List(ParentTab.allCases, selection: sidebarSelection) { tab in
                Label(tab.title, systemImage: tab.systemImage)
                    .themisFont(.rowTitle)
                    .tag(tab)
            }
            .navigationTitle("Themis Family")
        } detail: {
            NavigationStack {
                content(selection)
            }
            .id(selection)
        }
    }

    /// `List(selection:)` needs an optional binding; the shell always has a tab selected.
    private var sidebarSelection: Binding<ParentTab?> {
        Binding(
            get: { selection },
            set: { if let newValue = $0 { selection = newValue } }
        )
    }
}

/// `ThemisNavigationShell` for the Child and Teen experiences: Home, My Rules, Requests.
/// Child uses the warm tab bar; Teen matches Parent.
struct ChildTabShell<Content: View>: View {
    let segment: ExperienceSegment
    @Binding var selection: ChildTab
    private let content: (ChildTab) -> Content

    init(
        segment: ExperienceSegment,
        selection: Binding<ChildTab>,
        @ViewBuilder content: @escaping (ChildTab) -> Content
    ) {
        self.segment = segment
        _selection = selection
        self.content = content
    }

    var body: some View {
        let audience = ThemisAudience(segment)
        TabView(selection: $selection) {
            ForEach(ChildTab.allCases) { tab in
                NavigationStack {
                    content(tab)
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                .tag(tab)
                .toolbarBackground(audience.tabBarBackground, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
        }
        .themisAudience(audience)
        .tint(ThemisColor.brandPrimary)
    }
}

/// Tab root for a destination whose screens are built in a later slice.
/// Uses the approved header and ground so the shell can be reviewed now;
/// it deliberately shows no invented layout.
struct ShellPlaceholderView: View {
    let title: String
    let screenID: String

    @Environment(\.themisAudience) private var audience

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: title)
                EmptyStateView(
                    title: "\(title) isn’t built yet",
                    message: "Screen \(screenID) is built in a later slice.",
                    systemImage: "hammer"
                )
            }
            .padding(.horizontal, ThemisSpacing.screen)
        }
        .themisGround(audience.homeGround)
        .toolbar(.hidden, for: .navigationBar)
    }
}
