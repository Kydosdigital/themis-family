import Foundation

enum ProtectionStatus: String, Codable, Sendable {
    case protected
    case syncPending
    case deviceOffline
    case needsAttention
    case protectionUnavailable

    var title: String {
        switch self {
        case .protected: return "Protected"
        case .syncPending: return "Sync Pending"
        case .deviceOffline: return "Device Offline"
        case .needsAttention: return "Needs Attention"
        case .protectionUnavailable: return "Protection Unavailable"
        }
    }

    var symbolName: String {
        switch self {
        case .protected: return "checkmark.shield.fill"
        case .syncPending: return "arrow.triangle.2.circlepath"
        case .deviceOffline: return "wifi.slash"
        case .needsAttention: return "exclamationmark.triangle.fill"
        case .protectionUnavailable: return "xmark.shield.fill"
        }
    }
}
