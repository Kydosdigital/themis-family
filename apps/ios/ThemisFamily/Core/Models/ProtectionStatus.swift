import Foundation

enum ProtectionStatus: String, Codable, Sendable {
    case protected
    case syncPending
    case deviceOffline
    case needsAttention
    case protectionUnavailable

    /// Approved label, in the design system's sentence case.
    var title: String { statusKind.defaultLabel }

    /// SF Symbol for the glyph, from the shared status system.
    var symbolName: String { statusKind.glyphSymbol }
}
