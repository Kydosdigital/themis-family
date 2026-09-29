import SwiftUI

@main
@MainActor
struct ThemisFamilyApp: App {
    @StateObject private var container = AppContainer.preview()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
        }
    }
}
