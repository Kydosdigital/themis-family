import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var parentTab: ParentTab = .home
    @State private var childTab: ChildTab = .home

    var body: some View {
        switch container.perspective {
        case .parent:
            ParentTabShell(selection: $parentTab) { tab in
                parentRoot(tab)
                    .demoControls()
            }
        case .child:
            childShell(segment: .child, childID: DemoData.samID)
        case .teen:
            childShell(segment: .teen, childID: DemoData.mayaID)
        case .onboarding:
            OnboardingView(initialStep: container.onboardingInitialStep ?? .launch) {
                container.onboardingInitialStep = nil
                container.perspective = .parent
            }
            .demoControls()
        }
    }

    @ViewBuilder
    private func parentRoot(_ tab: ParentTab) -> some View {
        switch tab {
        case .home:
            ParentHomeView(
                repository: container.parentRepository,
                scenario: container.scenario
            )
        case .rules, .activity, .settings:
            ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID)
        }
    }

    private func childShell(segment: ExperienceSegment, childID: UUID) -> some View {
        ChildTabShell(segment: segment, selection: $childTab) { tab in
            Group {
                switch tab {
                case .home:
                    ChildHomeView(
                        childID: childID,
                        repository: container.childRepository,
                        scenario: container.scenario
                    )
                case .myRules, .requests:
                    ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID(for: segment))
                }
            }
            .demoControls()
        }
    }
}
