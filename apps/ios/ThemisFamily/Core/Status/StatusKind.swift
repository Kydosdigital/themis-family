import SwiftUI

/// Colour treatment for a status: glyph-circle fill, chip tint and glyph colour.
/// Status is never communicated by colour alone; every status also has a glyph and a label.
enum StatusTone: String, CaseIterable, Sendable {
    case success
    case successSoft
    case info
    case warning
    case pending
    case neutral
    case offline
    case unavailable
    case grace
    case expired
    case brand
    case error

    /// Glyph-circle fill.
    var fill: Color {
        switch self {
        case .success: return ThemisColor.statusSuccess
        case .successSoft: return ThemisColor.statusSuccessSoft
        case .info: return ThemisColor.statusInfo
        case .warning: return ThemisColor.statusWarning
        case .pending: return ThemisColor.statusPending
        case .neutral: return ThemisColor.statusNeutral
        case .offline: return ThemisColor.statusOffline
        case .unavailable: return ThemisColor.statusUnavailable
        case .grace: return ThemisColor.statusGrace
        case .expired: return ThemisColor.statusExpired
        case .brand: return ThemisColor.brandPrimary
        case .error: return ThemisColor.statusError
        }
    }

    /// Chip and banner background.
    var tint: Color {
        switch self {
        case .success, .successSoft: return ThemisColor.statusBgSuccess
        case .info: return ThemisColor.statusBgInfo
        case .warning: return ThemisColor.statusBgWarning
        case .pending: return ThemisColor.statusBgPending
        case .neutral, .expired: return ThemisColor.statusBgNeutral
        case .offline, .unavailable: return ThemisColor.statusBgOffline
        case .grace, .brand: return ThemisColor.statusBgBrand
        case .error: return ThemisColor.statusBgError
        }
    }

    /// Glyph colour inside the circle. White only on the dark fills.
    var glyphColor: Color {
        hasLightGlyph ? ThemisColor.textOnPrimary : ThemisColor.textPrimary
    }

    var hasLightGlyph: Bool {
        switch self {
        case .unavailable, .brand, .error: return true
        default: return false
        }
    }
}

/// The visual status kinds of the approved status system (prototype `ST` table).
///
/// A kind fixes glyph and tone. The label defaults to the kind's own label and can be
/// overridden where the state matrix reuses a kind ("Unconfirmed" uses `.deviceOffline`).
enum StatusKind: String, CaseIterable, Sendable {
    // Protection
    case protected
    case syncPending
    case deviceOffline
    case needsAttention
    case protectionUnavailable
    case notActiveYet
    // Tasks and requests
    case pending
    case waiting
    case grace
    case due
    case overdue
    case approved
    case partiallyApproved
    case declined
    case expired
    case resolved
    case cleared
    // Application to device
    case applying
    case applied
    case accessRevoked
    // Free Pass, sessions and schedules
    case freePassActive
    case overridden
    case suggested
    case active
    case open
    case paused
    case selected

    var defaultLabel: String {
        switch self {
        case .protected: return "Protected"
        case .syncPending: return "Sync pending"
        case .deviceOffline: return "Device offline"
        case .needsAttention: return "Needs attention"
        case .protectionUnavailable: return "Protection unavailable"
        case .notActiveYet: return "Not active yet"
        case .pending: return "Pending"
        case .waiting: return "Waiting"
        case .grace: return "Grace"
        case .due: return "Due today"
        case .overdue: return "Overdue"
        case .approved: return "Approved"
        case .partiallyApproved: return "Partially approved"
        case .declined: return "Declined"
        case .expired: return "Expired"
        case .resolved: return "Resolved"
        case .cleared: return "Cleared"
        case .applying: return "Applying"
        case .applied: return "Applied on device"
        case .accessRevoked: return "Access revoked"
        case .freePassActive: return "Free Pass active"
        case .overridden: return "Overridden"
        case .suggested: return "Suggested"
        case .active: return "Active"
        case .open: return "Open"
        case .paused: return "Paused"
        case .selected: return "Selected"
        }
    }

    var tone: StatusTone {
        switch self {
        case .protected, .applied, .open, .cleared, .accessRevoked: return .success
        case .approved, .resolved: return .successSoft
        case .syncPending, .applying, .partiallyApproved: return .info
        case .needsAttention, .overdue, .paused: return .warning
        case .pending: return .pending
        case .waiting, .declined, .notActiveYet: return .neutral
        case .deviceOffline: return .offline
        case .protectionUnavailable: return .unavailable
        case .grace, .due, .overridden, .suggested: return .grace
        case .expired: return .expired
        case .freePassActive, .active, .selected: return .brand
        }
    }

    /// SF Symbol drawn inside the tinted glyph circle (handoff SF Symbols map).
    var glyphSymbol: String {
        switch self {
        case .protected, .approved, .applied, .open, .cleared, .accessRevoked, .resolved:
            return "checkmark"
        case .syncPending, .applying:
            return "arrow.triangle.2.circlepath"
        case .deviceOffline:
            return "wifi.slash"
        case .notActiveYet:
            return "circle.dashed"
        case .needsAttention:
            return "exclamationmark"
        case .protectionUnavailable:
            return "minus"
        case .pending, .waiting, .grace, .due, .overdue, .expired:
            return "clock"
        case .partiallyApproved:
            return "circle.lefthalf.filled"
        case .freePassActive, .overridden:
            return "ticket.fill"
        case .suggested:
            return "sparkle"
        case .active, .selected:
            return "circle.fill"
        case .declined:
            return "xmark"
        case .paused:
            return "pause.fill"
        }
    }
}

/// A status as shown to people: a kind plus the label for this context.
struct ThemisStatus: Hashable, Sendable {
    let kind: StatusKind
    let label: String

    init(_ kind: StatusKind, label: String? = nil) {
        self.kind = kind
        self.label = label ?? kind.defaultLabel
    }

    var tone: StatusTone { kind.tone }
}

extension ThemisStatus {
    // The complete approved list from the handoff state matrix and the UI-01 brief.
    // Label overrides reuse a kind's glyph and tone exactly as the prototype does.

    // Protection
    static let protected = ThemisStatus(.protected)
    static let syncPending = ThemisStatus(.syncPending)
    static let deviceOffline = ThemisStatus(.deviceOffline)
    static let needsAttention = ThemisStatus(.needsAttention)
    static let protectionUnavailable = ThemisStatus(.protectionUnavailable)
    static let notActiveYet = ThemisStatus(.notActiveYet)
    static let unconfirmed = ThemisStatus(.deviceOffline, label: "Unconfirmed")

    // Task
    static let due = ThemisStatus(.due)
    static let waiting = ThemisStatus(.waiting)
    static let grace = ThemisStatus(.grace)
    static let overdue = ThemisStatus(.overdue)
    static let approved = ThemisStatus(.approved)
    static let cleared = ThemisStatus(.cleared)
    static let needsYou = ThemisStatus(.needsAttention, label: "Needs you")

    // Request
    static let pending = ThemisStatus(.pending)
    static let needsYourReply = ThemisStatus(.waiting, label: "Needs your reply")
    static let partiallyApproved = ThemisStatus(.partiallyApproved)
    static let declined = ThemisStatus(.declined)
    static let expired = ThemisStatus(.expired)
    static let resolved = ThemisStatus(.resolved)
    static let waitingToSend = ThemisStatus(.waiting, label: "Waiting to send")

    // Free Pass
    static let freePassActive = ThemisStatus(.freePassActive)
    static let overridden = ThemisStatus(.overridden)
    static let sending = ThemisStatus(.applying, label: "Sending")
    static let accessRevoked = ThemisStatus(.accessRevoked)

    // Subscription
    static let subscriptionActive = ThemisStatus(.active)
    static let payment = ThemisStatus(.needsAttention, label: "Payment")
    static let cancelled = ThemisStatus(.expired, label: "Cancelled")
    static let protectionEnded = ThemisStatus(.notActiveYet, label: "Protection ended")
    static let off = ThemisStatus(.notActiveYet, label: "Off")

    // Approval / application
    static let applying = ThemisStatus(.applying)
    static let appliedOnDevice = ThemisStatus(.applied)
    static let removing = ThemisStatus(.applying, label: "Removing")

    // Sessions
    static let active = ThemisStatus(.active)
    static let paused = ThemisStatus(.paused)
    static let completed = ThemisStatus(.approved, label: "Completed")
    static let notFinished = ThemisStatus(.expired, label: "Not finished")

    // Timing integrity
    static let approvedTimingUnverified = ThemisStatus(.approved, label: "Approved, timing unverified")

    /// Every approved status preset, for previews and tests.
    static let allApproved: [ThemisStatus] = [
        .protected, .syncPending, .deviceOffline, .needsAttention, .protectionUnavailable,
        .notActiveYet, .unconfirmed,
        .due, .waiting, .grace, .overdue, .approved, .cleared, .needsYou,
        .pending, .needsYourReply, .partiallyApproved, .declined, .expired, .resolved, .waitingToSend,
        .freePassActive, .overridden, .sending, .accessRevoked,
        .subscriptionActive, .payment, .cancelled, .protectionEnded, .off,
        .applying, .appliedOnDevice, .removing,
        .active, .paused, .completed, .notFinished,
        .approvedTimingUnverified
    ]
}

extension ProtectionStatus {
    /// The five protection states map one-to-one onto status kinds.
    var statusKind: StatusKind {
        switch self {
        case .protected: return .protected
        case .syncPending: return .syncPending
        case .deviceOffline: return .deviceOffline
        case .needsAttention: return .needsAttention
        case .protectionUnavailable: return .protectionUnavailable
        }
    }

    var themisStatus: ThemisStatus { ThemisStatus(statusKind) }
}
