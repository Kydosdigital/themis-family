import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var showsScenarioSwitcher = false

    var body: some View {
        NavigationStack {
            Group {
                switch container.perspective {
                case .parent:
                    ParentHomeView(
                        repository: container.parentRepository,
                        scenario: container.scenario
                    )
                case .child:
                    ChildHomeView(
                        childID: DemoData.samID,
                        repository: container.childRepository,
                        scenario: container.scenario
                    )
                case .teen:
                    ChildHomeView(
                        childID: DemoData.mayaID,
                        repository: container.childRepository,
                        scenario: container.scenario
                    )
                }
            }
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsScenarioSwitcher = true
                    } label: {
                        Label("Demo controls", systemImage: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Open developer scenario controls")
                }
            }
            .sheet(isPresented: $showsScenarioSwitcher) {
                DemoScenarioSwitcher()
                    .environmentObject(container)
            }
            #endif
        }
        .tint(ThemisColor.actionPrimary)
    }
}
