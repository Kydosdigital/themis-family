import SwiftUI

/// Semantic colour tokens from the approved Engineering Handoff token sheet (Pass 5).
///
/// Feature views use these names only. Raw hex values live here and nowhere else.
/// Token names mirror the handoff (`color.brand.primary` → `ThemisColor.brandPrimary`).
/// No purple anywhere in the system.
enum ThemisColor {
    // MARK: Brand

    /// `color.brand.primary` · primary actions, selection, Needs you label.
    static let brandPrimary = Color(hex: 0x2563EB)
    /// `color.brand.primaryPressed` · pressed state, task eyebrow.
    static let brandPrimaryPressed = Color(hex: 0x1D4ED8)
    /// `color.brand.primaryTint` · grace, selected background.
    static let brandPrimaryTint = Color(hex: 0xEAF1FE)
    /// `color.brand.secondary` · selected chips, now-marker, iPad selected tab.
    static let brandSecondary = Color(hex: 0x0F1B33)

    // MARK: Ink

    /// `color.text.primary` · body and titles.
    static let textPrimary = Color(hex: 0x0F1B33)
    /// `color.text.secondary` · meta, explanations.
    static let textSecondary = Color(hex: 0x515B6E)
    /// `color.text.tertiary` · captions and tick labels only.
    static let textTertiary = Color(hex: 0x6B7486)
    /// `color.text.onPrimary` · text on cobalt.
    static let textOnPrimary = Color.white
    /// `color.text.destructive` · destructive labels, validation errors.
    static let textDestructive = Color(hex: 0xB4361A)
    /// Disabled button label (prototype value, not a separate token-sheet row).
    static let textDisabled = Color(hex: 0x5B6477)

    // MARK: Backgrounds and surfaces

    /// `color.bg.parent` · Parent/Teen flow screens.
    static let backgroundParent = Color.white
    /// `color.bg.grouped` · Parent Home, lists, Teen Home.
    static let backgroundGrouped = Color(hex: 0xF6F7F9)
    /// `color.bg.child` · Child screens only.
    static let backgroundChild = Color(hex: 0xFFF8F3)
    /// `color.surface` · grouped sections on grey or warm ground.
    static let surface = Color.white
    /// `color.surface.onWhite` · grouped sections on white ground.
    static let surfaceOnWhite = Color(hex: 0xF6F7F9)
    /// `color.tabBar.child` · Child tab bar.
    static let tabBarChild = Color(hex: 0xFFFBF8)
    /// Parent/Teen tab bar (prototype: white at 97%).
    static let tabBarParent = Color.white.opacity(0.97)
    /// Inactive tab glyph and label.
    static let tabInactive = Color(hex: 0x6B7486)
    /// `color.scrim` · custom sheet scrim. Prefer the system sheet.
    static let scrim = Color(hex: 0x0F1B33, opacity: 0.32)
    /// Secondary button inside the floating quick-action dock (prototype `dock`).
    static let dockSecondary = Color(hex: 0xF0F2F5)
    /// Segmented control track and disabled button fill.
    static let controlTrack = Color(hex: 0xE9ECF0)

    // MARK: Status fills (glyph circle)

    static let statusSuccess = Color(hex: 0x34D399)
    static let statusSuccessSoft = Color(hex: 0xA7EBCF)
    static let statusInfo = Color(hex: 0x7DD3FC)
    static let statusWarning = Color(hex: 0xFFB79E)
    static let statusPending = Color(hex: 0xFFD3C2)
    static let statusNeutral = Color(hex: 0xE5E7EB)
    static let statusOffline = Color(hex: 0xCBD2DC)
    static let statusUnavailable = Color(hex: 0x5B6477)
    static let statusGrace = Color(hex: 0xBFD3FB)
    /// Expired glyph fill. Prototype value (`ThemisScreen` ST.expired); not a separate token-sheet row.
    static let statusExpired = Color(hex: 0xD5D9E0)
    /// Error banner glyph fill (prototype `err`), equal to `textDestructive`.
    static let statusError = Color(hex: 0xB4361A)

    // MARK: Status tints (chip / banner background)

    static let statusBgSuccess = Color(hex: 0xE3F7EE)
    static let statusBgInfo = Color(hex: 0xE4F4FD)
    static let statusBgWarning = Color(hex: 0xFFEEE6)
    static let statusBgPending = Color(hex: 0xFFF1EB)
    static let statusBgNeutral = Color(hex: 0xF0F1F4)
    static let statusBgOffline = Color(hex: 0xEEF0F3)
    static let statusBgBrand = Color(hex: 0xEAF1FE)
    static let statusBgError = Color(hex: 0xFDECE7)

    // MARK: Lines

    /// `border.hairline` · row dividers.
    static let borderHairline = Color(hex: 0xEEF0F3)
    /// `border.control` · secondary buttons, chips.
    static let borderControl = Color(hex: 0xE5E7EB)
    /// `border.control` input variant (1.5 pt).
    static let borderInput = Color(hex: 0xD5D9E0)
    /// `border.elevated` · Needs you card.
    static let borderElevated = Color(hex: 0xDCE6FB)
    /// `border.destructive` · destructive button.
    static let borderDestructive = Color(hex: 0xF3D3C8)
    /// Disclosure chevron.
    static let chevron = Color(hex: 0x9AA3B2)
    /// Shadow ink; opacity is set by `ThemisShadow`.
    static let shadowInk = Color(hex: 0x0F1B33)

    // MARK: Legacy aliases
    //
    // Used by the pre-handoff scaffold views (Parent Home, Child Home) until
    // they are rebuilt in slices UI-02 and UI-03. New code uses the names above.

    static let actionPrimary = brandPrimary
    static let border = borderControl
    static let surfaceMuted = backgroundGrouped
    static let attention = statusWarning
    static let mint = statusSuccess
    static let aqua = statusInfo
    static let peach = statusWarning

    static func status(_ status: ProtectionStatus) -> Color {
        status.statusKind.tone.fill
    }
}

/// Colour pairs for agreement-timeline bands and avatar tiles
/// (`color.timeline.*`, `color.child.panel`).
enum ThemisTone: String, CaseIterable, Sendable {
    case aqua
    case mint
    case peach
    case cobalt
    case grey

    /// Band / avatar background.
    var band: Color {
        switch self {
        case .aqua: return Color(hex: 0xE1F3FD)
        case .mint: return Color(hex: 0xE2F6EE)
        case .peach: return Color(hex: 0xFFEDE5)
        case .cobalt: return Color(hex: 0xEAF1FE)
        case .grey: return Color(hex: 0xF0F1F4)
        }
    }

    /// Band dot and conditional (dashed) border.
    var dot: Color {
        switch self {
        case .aqua: return Color(hex: 0x0EA5E9)
        case .mint: return Color(hex: 0x10B981)
        case .peach: return Color(hex: 0xF97352)
        case .cobalt: return Color(hex: 0x2563EB)
        case .grey: return Color(hex: 0x9AA3B2)
        }
    }

    /// Stronger tint used behind a task panel.
    var panel: Color {
        switch self {
        case .aqua: return Color(hex: 0xCBEBFC)
        case .mint: return Color(hex: 0xCDF1E1)
        case .peach: return Color(hex: 0xFFDCCD)
        case .cobalt: return Color(hex: 0xD6E3FC)
        case .grey: return Color(hex: 0xE5E7EB)
        }
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
