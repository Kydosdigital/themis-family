import Foundation

/// Parent tabs. Approved IA: Home, Rules, Activity, Settings. Do not add tabs.
enum ParentTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case home
    case rules
    case activity
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .rules: return "Rules"
        case .activity: return "Activity"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .rules: return "checklist"
        case .activity: return "chart.bar"
        case .settings: return "gearshape"
        }
    }

    /// Screen ID of the tab root.
    var rootScreenID: String {
        switch self {
        case .home: return "P-023"
        case .rules: return "R-001"
        case .activity: return "T-001"
        case .settings: return "ST-001"
        }
    }
}

/// Child and Teen tabs. Approved IA: Home, My Rules, Requests. Do not add tabs.
enum ChildTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case home
    case myRules
    case requests

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .myRules: return "My Rules"
        case .requests: return "Requests"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .myRules: return "checklist"
        case .requests: return "bubble.left"
        }
    }

    /// Screen ID of the tab root. Child and Teen share My Rules; Requests differs.
    func rootScreenID(for segment: ExperienceSegment) -> String {
        switch (self, segment) {
        case (.home, .child): return "C-001"
        case (.home, .teen): return "C-001 · Teen"
        case (.myRules, _): return "C-015"
        case (.requests, .child): return "C-017"
        case (.requests, .teen): return "Q-001"
        }
    }
}
