import SwiftUI

/// Spacing tokens (`space.*`). Audience-dependent radii and heights live on `ThemisAudience`.
enum ThemisSpacing {
    /// `space.screen` · horizontal screen margin (iPad pane 28 pt).
    static let screen: CGFloat = 20
    static let screenPad: CGFloat = 28
    /// `space.block` · vertical gap between blocks.
    static let block: CGFloat = 14
    /// `space.row` · row padding, 12 vertical × 16 horizontal.
    static let rowVertical: CGFloat = 12
    static let rowHorizontal: CGFloat = 16
    /// `space.card` · card padding (Needs you 18, task 20).
    static let card: CGFloat = 16
    static let cardNeedsYou: CGFloat = 18
    static let cardTask: CGFloat = 20
    /// `space.inline` · icon–label and chip gaps.
    static let inline6: CGFloat = 6
    static let inline8: CGFloat = 8
    static let inline10: CGFloat = 10
    static let inline12: CGFloat = 12
    /// `space.dockClearance` · bottom content inset when the quick-action dock floats.
    static let dockClearance: CGFloat = 96

    // Legacy scale used by the pre-handoff scaffold views until UI-02/UI-03.
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    static let cardRadius: CGFloat = ThemisAudience.parent.cardRadius
    static let controlRadius: CGFloat = ThemisAudience.parent.buttonRadius
}

/// Fixed radii (`radius.*`). Card, panel and button radii vary by audience; see `ThemisAudience`.
enum ThemisRadius {
    /// `radius.xs` · segmented thumb.
    static let xs: CGFloat = 9
    /// `radius.sm` · chips, avatars.
    static let sm: CGFloat = 12
    /// Banners.
    static let banner: CGFloat = 16
    /// Buttons inside the floating quick-action dock.
    static let dockButton: CGFloat = 16
    /// Inner notes (consequence note, stacked list inside a panel).
    static let inner: CGFloat = 18
    /// Inputs.
    static let input: CGFloat = 14
    /// `radius.sheet` · custom sheet top corners. System sheet preferred.
    static let sheet: CGFloat = 28
}

/// Touch sizes (`size.*`).
enum ThemisSize {
    /// `size.tap.min` · nav, bell, links.
    static let tapMinimum: CGFloat = 44
    /// `size.chip.min` · choice chips.
    static let chipMinimum: CGFloat = 44
    /// Input minimum height.
    static let inputMinimum: CGFloat = 52
    /// Status header glyph circle.
    static let statusHeaderGlyph: CGFloat = 44
    /// Avatar tile in rows.
    static let avatar: CGFloat = 38
    /// Avatar tile at the head of a card (Needs you, action cards).
    static let avatarLarge: CGFloat = 40
}

/// Line widths (`border.*`).
enum ThemisBorder {
    static let hairline: CGFloat = 1
    static let control: CGFloat = 1
    static let input: CGFloat = 1.5
    static let selected: CGFloat = 2
    static let conditional: CGFloat = 1.5
}

/// Shadows (`shadow.*`). Only the Needs you card and the floating dock are elevated.
enum ThemisShadow {
    struct Layer {
        let color: Color
        let radius: CGFloat
        let y: CGFloat
    }

    /// `shadow.elevated` · Needs you card only. CSS blur is halved for SwiftUI's radius.
    static let elevated: [Layer] = [
        Layer(color: ThemisColor.shadowInk.opacity(0.04), radius: 1, y: 1),
        Layer(color: ThemisColor.brandPrimary.opacity(0.10), radius: 14, y: 10)
    ]

    /// `shadow.dock` · floating quick-action dock.
    static let dock: [Layer] = [
        Layer(color: ThemisColor.shadowInk.opacity(0.14), radius: 15, y: 10)
    ]
}

extension View {
    func themisShadow(_ layers: [ThemisShadow.Layer]) -> some View {
        layers.reduce(AnyView(self)) { view, layer in
            AnyView(view.shadow(color: layer.color, radius: layer.radius, x: 0, y: layer.y))
        }
    }
}
