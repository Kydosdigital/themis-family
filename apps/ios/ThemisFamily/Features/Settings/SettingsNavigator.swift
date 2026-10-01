import SwiftUI

/// Hooks the main lane connects when it wires Settings into the app. Unset hooks fall back to a
/// placeholder screen, so Settings runs on its own and never reaches into another slice.
struct SettingsIntegration {
    /// Opens a destination owned by another slice (B-002, P-031, P-009, C-013, P-002).
    var onExternal: ((SettingsExternalDestination) -> Void)? = nil
}

/// Settings' own navigation depth inside the Parent tab's NavigationStack. Screens push by
/// route, and a flow can pop to a screen or back to the root without a stack of its own.
final class SettingsNavigator: ObservableObject {
    @Published private(set) var routes: [SettingsRoute] = []
    let integration: SettingsIntegration

    init(integration: SettingsIntegration = SettingsIntegration(), routes: [SettingsRoute] = []) {
        self.integration = integration
        self.routes = routes
    }

    func route(at depth: Int) -> SettingsRoute? {
        routes.indices.contains(depth) ? routes[depth] : nil
    }

    func push(_ route: SettingsRoute) {
        routes.append(route)
    }

    /// Opens a screen another slice owns: through the main lane's hook, or a placeholder.
    func open(_ destination: SettingsExternalDestination) {
        if let hook = integration.onExternal {
            hook(destination)
        } else {
            push(.external(destination))
        }
    }

    func set(_ route: SettingsRoute, at depth: Int) {
        guard routes.indices.contains(depth) else { return }
        routes[depth] = route
    }

    /// Replaces the screen on top, as flows do when one step gives way to the next.
    func replaceTop(with route: SettingsRoute) {
        guard !routes.isEmpty else {
            routes = [route]
            return
        }
        routes[routes.count - 1] = route
    }

    /// Keeps `depth` screens and removes the rest.
    func pop(to depth: Int) {
        guard depth >= 0, depth < routes.count else { return }
        routes = Array(routes.prefix(depth))
    }

    func popToRoot() {
        routes = []
    }

    /// Pops back to the most recent screen with this route, if there is one.
    func pop(toRoute route: SettingsRoute) {
        guard let index = routes.lastIndex(of: route) else { return }
        routes = Array(routes.prefix(index + 1))
    }
}

/// Registers the screen that Settings pushes at `depth`, bound to the navigator's routes.
private struct SettingsLevelModifier: ViewModifier {
    @EnvironmentObject private var navigator: SettingsNavigator
    let depth: Int

    func body(content: Content) -> some View {
        content.navigationDestination(
            item: Binding<SettingsRoute?>(
                get: { navigator.route(at: depth) },
                set: { newValue in
                    if let newValue {
                        navigator.set(newValue, at: depth)
                    } else {
                        navigator.pop(to: depth)
                    }
                }
            )
        ) { route in
            SettingsDestinationView(route: route, depth: depth + 1)
        }
    }
}

extension View {
    /// Lets this screen push the next Settings screen at `depth`.
    func settingsLevel(_ depth: Int) -> some View {
        modifier(SettingsLevelModifier(depth: depth))
    }
}
