import SwiftUI

/// The three audience variants of the one Themis system (handoff `variant.*`).
///
/// Parent is the most restrained, Child is warmer and larger, Teen sits close to Parent.
/// Components read the audience from the environment so the same component
/// renders correctly on every surface.
enum ThemisAudience: String, CaseIterable, Sendable {
    case parent
    case child
    case teen

    init(_ segment: ExperienceSegment) {
        switch segment {
        case .child: self = .child
        case .teen: self = .teen
        }
    }

    /// `radius.card` · 20 pt (Child 24, Teen 18).
    var cardRadius: CGFloat {
        switch self {
        case .parent: return 20
        case .child: return 24
        case .teen: return 18
        }
    }

    /// `radius.panel` · 22 pt (Child 28).
    var panelRadius: CGFloat { self == .child ? 28 : 22 }

    /// `radius.button` · 14 pt (Child 18).
    var buttonRadius: CGFloat { self == .child ? 18 : 14 }

    /// `size.button.*` · Parent 52, Teen 50, Child 58.
    var buttonHeight: CGFloat {
        switch self {
        case .parent: return 52
        case .child: return 58
        case .teen: return 50
        }
    }

    /// `size.row.min` · 52 pt (Child 56).
    var rowMinHeight: CGFloat { self == .child ? 56 : 52 }

    /// Default screen ground for tab roots. Child screens are always warm.
    var homeGround: ThemisGround { self == .child ? .warm : .grouped }

    /// Tab bar background.
    var tabBarBackground: Color {
        self == .child ? ThemisColor.tabBarChild : ThemisColor.tabBarParent
    }
}

/// The screen ground a view sits on. Grouped sections take the contrasting surface:
/// white sections on grey or warm ground, soft-grey sections on white ground.
enum ThemisGround: Sendable {
    /// `color.bg.parent` · Parent/Teen flow screens.
    case plain
    /// `color.bg.grouped` · Parent Home, lists, Teen Home.
    case grouped
    /// `color.bg.child` · Child screens only.
    case warm

    var background: Color {
        switch self {
        case .plain: return ThemisColor.backgroundParent
        case .grouped: return ThemisColor.backgroundGrouped
        case .warm: return ThemisColor.backgroundChild
        }
    }

    var surface: Color {
        self == .plain ? ThemisColor.surfaceOnWhite : ThemisColor.surface
    }
}

private struct ThemisAudienceKey: EnvironmentKey {
    static let defaultValue: ThemisAudience = .parent
}

private struct ThemisGroundKey: EnvironmentKey {
    static let defaultValue: ThemisGround = .grouped
}

extension EnvironmentValues {
    var themisAudience: ThemisAudience {
        get { self[ThemisAudienceKey.self] }
        set { self[ThemisAudienceKey.self] = newValue }
    }

    var themisGround: ThemisGround {
        get { self[ThemisGroundKey.self] }
        set { self[ThemisGroundKey.self] = newValue }
    }
}

extension View {
    /// Sets the audience variant for this subtree.
    func themisAudience(_ audience: ThemisAudience) -> some View {
        environment(\.themisAudience, audience)
    }

    /// Paints the screen ground edge to edge and tells child components which surface to use.
    func themisGround(_ ground: ThemisGround) -> some View {
        environment(\.themisGround, ground)
            .background(ground.background.ignoresSafeArea())
    }
}
