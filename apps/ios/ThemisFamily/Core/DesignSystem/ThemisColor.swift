import SwiftUI

enum ThemisColor {
    static let actionPrimary = Color(hex: 0x2563EB)
    static let mint = Color(hex: 0x34D399)
    static let aqua = Color(hex: 0x7DD3FC)
    static let peach = Color(hex: 0xFFB79E)
    static let border = Color(hex: 0xE5E7EB)
    static let surface = Color.white
    static let surfaceMuted = Color(hex: 0xF6F7F9)
    static let textPrimary = Color(hex: 0x152238)
    static let textSecondary = Color(hex: 0x5F6B7A)
    static let destructive = Color.red
    static let attention = Color.orange

    static func status(_ status: ProtectionStatus) -> Color {
        switch status {
        case .protected:
            return mint
        case .syncPending:
            return aqua
        case .deviceOffline:
            return attention
        case .needsAttention:
            return peach
        case .protectionUnavailable:
            return destructive
        }
    }
}

private extension Color {
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
