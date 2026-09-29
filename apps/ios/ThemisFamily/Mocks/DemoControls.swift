import SwiftUI

extension View {
    /// Debug-only toolbar button that opens the demo scenario switcher.
    /// Compiles to nothing in Release builds.
    func demoControls() -> some View {
        modifier(DemoControlsModifier())
    }
}

private struct DemoControlsModifier: ViewModifier {
    @EnvironmentObject private var container: AppContainer
    @State private var showsScenarioSwitcher = false

    func body(content: Content) -> some View {
        #if DEBUG
        content
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
        #else
        content
        #endif
    }
}
