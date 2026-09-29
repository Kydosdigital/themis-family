import SwiftUI

enum ThemisTypography {
    // Manrope is the approved brand direction, but the font asset has not yet
    // been added to the repository. These semantic styles intentionally use
    // the system font as a temporary fallback rather than pretending another
    // brand font is final.
    static let hero = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .bold, design: .rounded)
    static let section = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodyStrong = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
}
