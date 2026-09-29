import SwiftUI
import UIKit

/// Approved type roles (`type.*`) from the Engineering Handoff.
///
/// Each role has a Parent / Child / Teen size, a weight, tracking and the
/// Dynamic Type text style it scales relative to. Apply with `.themisFont(_:)`,
/// which reads the audience from the environment and scales with Dynamic Type.
enum ThemisTextRole: String, CaseIterable, Sendable {
    case display
    case numeral
    case pageTitle
    case screenTitle
    case headline
    case rowTitle
    case body
    case secondary
    case meta
    case sectionLabel
    case caption
    case button

    /// Point size at the default Dynamic Type size.
    func size(for audience: ThemisAudience) -> CGFloat {
        let sizes: (parent: CGFloat, child: CGFloat, teen: CGFloat)
        switch self {
        case .display: sizes = (34, 36, 33)
        case .numeral: sizes = (48, 51, 46)
        case .pageTitle: sizes = (32, 34, 31)
        case .screenTitle: sizes = (26, 28, 25)
        case .headline: sizes = (19, 20, 18.5)
        case .rowTitle: sizes = (16, 17, 15.5)
        case .body: sizes = (16, 17, 15.5)
        case .secondary: sizes = (15, 16, 14.5)
        case .meta: sizes = (13, 14, 12.5)
        case .sectionLabel: sizes = (12, 12, 12)
        case .caption: sizes = (13, 13, 13)
        case .button: sizes = (17, 18, 16.5)
        }
        switch audience {
        case .parent: return sizes.parent
        case .child: return sizes.child
        case .teen: return sizes.teen
        }
    }

    var weight: Font.Weight {
        switch self {
        case .display: return .semibold
        case .numeral, .pageTitle, .screenTitle, .headline, .rowTitle, .button: return .bold
        case .body, .secondary, .meta: return .medium
        case .sectionLabel: return .heavy
        case .caption: return .semibold
        }
    }

    /// Letter spacing as a fraction of the point size (−2.8% → −0.028).
    var trackingEm: CGFloat {
        switch self {
        case .display: return -0.028
        case .numeral: return -0.035
        case .pageTitle: return -0.025
        case .screenTitle: return -0.022
        case .headline: return -0.01
        case .sectionLabel: return 0.09
        default: return 0
        }
    }

    /// The Dynamic Type style this role scales relative to (`UIFontMetrics`).
    var textStyle: Font.TextStyle {
        switch self {
        case .display, .numeral, .pageTitle: return .largeTitle
        case .screenTitle: return .title
        case .headline: return .title3
        case .rowTitle, .button: return .headline
        case .body: return .body
        case .secondary: return .subheadline
        case .meta, .caption: return .footnote
        case .sectionLabel: return .caption
        }
    }

    /// Section labels are set in capitals.
    var isUppercase: Bool { self == .sectionLabel }

    /// Extra line spacing for running text (body is set at 1.5 line height).
    var lineSpacingEm: CGFloat {
        switch self {
        case .body, .secondary: return 0.25
        default: return 0
        }
    }
}

/// Manrope is the approved typeface. The font files are not yet bundled
/// (asset register: "Required · licence check (SIL OFL)"), so until they are,
/// every role renders in the system font at the approved size, weight and
/// tracking. Once the files are added to the target and listed under
/// `UIAppFonts`, Manrope is picked up automatically with no call-site changes.
enum ThemisFontFamily {
    static let isManropeAvailable: Bool = UIFont(name: "Manrope-Bold", size: 12) != nil

    static func manropeName(for weight: Font.Weight) -> String {
        switch weight {
        case .heavy, .black: return "Manrope-ExtraBold"
        case .bold: return "Manrope-Bold"
        case .semibold: return "Manrope-SemiBold"
        case .medium: return "Manrope-Medium"
        default: return "Manrope-Regular"
        }
    }

    static func font(size: CGFloat, weight: Font.Weight) -> Font {
        if isManropeAvailable {
            return .custom(manropeName(for: weight), fixedSize: size)
        }
        return .system(size: size, weight: weight)
    }
}

private struct ThemisFontModifier: ViewModifier {
    let role: ThemisTextRole
    @ScaledMetric private var size: CGFloat

    init(role: ThemisTextRole, audience: ThemisAudience) {
        self.role = role
        _size = ScaledMetric(wrappedValue: role.size(for: audience), relativeTo: role.textStyle)
    }

    func body(content: Content) -> some View {
        content
            .font(ThemisFontFamily.font(size: size, weight: role.weight))
            .tracking(size * role.trackingEm)
            .lineSpacing(size * role.lineSpacingEm)
            .textCase(role.isUppercase ? .uppercase : nil)
    }
}

private struct ThemisAudienceFontModifier: ViewModifier {
    let role: ThemisTextRole
    let audienceOverride: ThemisAudience?
    @Environment(\.themisAudience) private var audience

    func body(content: Content) -> some View {
        content.modifier(ThemisFontModifier(role: role, audience: audienceOverride ?? audience))
    }
}

extension View {
    /// Applies an approved type role, scaled with Dynamic Type, for the current audience.
    func themisFont(_ role: ThemisTextRole, audience: ThemisAudience? = nil) -> some View {
        modifier(ThemisAudienceFontModifier(role: role, audienceOverride: audience))
    }
}

/// Font values for the pre-handoff scaffold views. They scale with Dynamic Type
/// via their text style but use Apple's style sizes, not the exact role sizes.
/// New code uses `.themisFont(_:)`. Removed when UI-02/UI-03 rebuild those views.
enum ThemisTypography {
    static let hero = Font.system(.largeTitle, weight: .semibold)
    static let title = Font.system(.title, weight: .bold)
    static let section = Font.system(.title3, weight: .bold)
    static let body = Font.system(.body, weight: .medium)
    static let bodyStrong = Font.system(.headline, weight: .bold)
    static let caption = Font.system(.footnote, weight: .semibold)
}
