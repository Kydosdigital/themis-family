import Foundation

// MARK: - UI-13 Edge States · Presentation layer
//
// Foundation-only presentation model. Keeping this free of SwiftUI/Core imports
// lets `EdgeStateTests.swift` fully type-check and assert on exact copy and
// semantics without a SwiftUI runtime. The SwiftUI view layer
// (`EdgeStateView.swift` and friends) maps `EdgeStatePresentation` onto the
// shared, read-only Core design-system components (`StatusBadge`, `ThemisStatus`,
// `ErrorStateView`, `EmptyStateView`, `InlineBanner`, `ThemisButton`, `ThemisCard`).

/// A lightweight, local mirror of the handful of `StatusKind` cases this
/// catalogue needs, so this file does not import the SwiftUI-dependent Core
/// design system. The view layer maps these onto the real `ThemisStatus`.
enum EdgeStateStatusKind: String, Sendable {
    case protectionUnavailable
    case unconfirmed
    case deviceOffline
    case syncPending
    case approvedTimingUnverified
    case notFinished
    case waitingToSend
    case accessRevoked = "access_revoked" // not used by default states; reserved
    case none
}

/// One fully-resolved, deterministic presentation of an approved UI-13 edge
/// state. Everything a view needs to render the state lives here; nothing is
/// computed from network, persistence or system frameworks.
struct EdgeStatePresentation: Identifiable, Hashable, Sendable {
    let id: EdgeStateScenario
    let screenID: String
    let frameName: String
    let audience: EdgeStateAudience
    let severity: EdgeStateSeverity

    let title: String
    let message: String

    /// Shown for Parent/Teen protection or sync states. `nil` when not applicable.
    let statusKind: EdgeStateStatusKind
    let statusLabel: String?

    /// "Last verified …" wording for stale/offline/unreachable states. Never a
    /// fixed/invented staleness threshold (OQ-19 remains unresolved).
    let lastVerifiedText: String?

    /// Present only for the three A-002 timing states and their Activity/child
    /// mirrors (C-004 · Timing, T-002 · Timing).
    let timingEvidence: TimingEvidencePresentation?

    let actions: [EdgeStateAction]

    /// `true` when this state must never be presented with an error glyph
    /// (A-001 · Empty, T-001 · Empty are calm, successful empty states).
    var isCalmEmpty: Bool { severity == .calmEmpty }
}

/// Deterministic factory for every approved UI-13 scenario. No randomness, no
/// current-time reads: every value is fixed so previews, screenshots and tests
/// are stable.
enum EdgeStateDemoData {
    /// Builds the presentation for one scenario.
    static func presentation(for scenario: EdgeStateScenario) -> EdgeStatePresentation {
        switch scenario {
        case .serversUnreachable:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .unavailable,
                title: EdgeStateCopy.serversUnreachableTitle,
                message: EdgeStateCopy.serversUnreachableMessage,
                statusKind: .unconfirmed,
                statusLabel: "Unconfirmed",
                lastVerifiedText: "\(EdgeStateCopy.lastVerifiedPrefix) 2 hr ago",
                timingEvidence: nil,
                actions: [EdgeStateAction(title: "Try again", kind: .secondary)]
            )

        case .actionCentreEmpty:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .calmEmpty,
                title: EdgeStateCopy.actionCentreEmptyTitle,
                message: EdgeStateCopy.actionCentreEmptyMessage,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .activityEmpty:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .calmEmpty,
                title: EdgeStateCopy.activityEmptyTitle,
                message: EdgeStateCopy.activityEmptyMessage,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .timingUnverified:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .attention,
                title: EdgeStateCopy.timingUnverifiedTitle,
                message: EdgeStateCopy.timingUnverifiedExplanation,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: EdgeStateCopy.timingUnverifiedExample,
                actions: [
                    EdgeStateAction(title: EdgeStateCopy.timingActionApprove, kind: .primary),
                    EdgeStateAction(title: EdgeStateCopy.timingActionNeedsMoreWork, kind: .secondary),
                    EdgeStateAction(title: EdgeStateCopy.timingActionAskOneQuestion, kind: .tertiary)
                ]
            )

        case .timingApproved:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .attention,
                title: EdgeStateCopy.timingApprovedOutcome,
                message: EdgeStateCopy.timingApprovedExplanation,
                statusKind: .approvedTimingUnverified,
                statusLabel: EdgeStateCopy.timingApprovedOutcome,
                lastVerifiedText: nil,
                timingEvidence: EdgeStateCopy.timingUnverifiedExample,
                actions: []
            )

        case .timingAsk:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .attention,
                title: EdgeStateCopy.timingAskTitle,
                message: EdgeStateCopy.timingAskExplanation,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: EdgeStateCopy.timingUnverifiedExample,
                actions: [EdgeStateAction(title: "Send question", kind: .primary)]
            )

        case .activityTiming:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .attention,
                title: EdgeStateCopy.timingApprovedOutcome,
                message: EdgeStateCopy.activityTimingExplanation,
                statusKind: .approvedTimingUnverified,
                statusLabel: EdgeStateCopy.timingApprovedOutcome,
                lastVerifiedText: nil,
                timingEvidence: EdgeStateCopy.timingUnverifiedExample,
                actions: []
            )

        case .childTimingUnverified:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .child,
                severity: .attention,
                title: EdgeStateCopy.childTimingTitle,
                message: EdgeStateCopy.childTimingMessage,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .childOffline:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .child,
                severity: .offline,
                title: EdgeStateCopy.childOfflineTitle,
                message: EdgeStateCopy.childOfflineMessage,
                statusKind: .deviceOffline,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .childQueuedOffline:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .child,
                severity: .offline,
                title: EdgeStateCopy.childQueuedTitle,
                message: EdgeStateCopy.childQueuedMessage,
                statusKind: .waitingToSend,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .requestSavedOffline:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .teen,
                severity: .offline,
                title: EdgeStateCopy.requestSavedOfflineTitle,
                message: EdgeStateCopy.requestSavedOfflineMessage,
                statusKind: .waitingToSend,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .childPermissionNeeded:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .child,
                severity: .unavailable,
                title: EdgeStateCopy.childPermissionTitle,
                message: EdgeStateCopy.childPermissionMessage,
                statusKind: .protectionUnavailable,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .childDeviceRemoved:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .child,
                severity: .unavailable,
                title: EdgeStateCopy.childRemovedTitle,
                message: EdgeStateCopy.childRemovedMessage,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: []
            )

        case .pairingInterrupted:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .interrupted,
                title: EdgeStateCopy.pairingInterruptedTitle,
                message: EdgeStateCopy.pairingInterruptedMessage,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: [EdgeStateAction(title: EdgeStateCopy.pairingInterruptedRetry, kind: .primary)]
            )

        case .sessionAbandoned:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .child,
                severity: .interrupted,
                title: EdgeStateCopy.sessionAbandonedTitle,
                message: EdgeStateCopy.sessionAbandonedMessage,
                statusKind: .notFinished,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: [EdgeStateAction(title: "Start a fresh session", kind: .primary)]
            )

        case .decisionSendFailed:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .failure,
                title: EdgeStateCopy.decisionNotSentTitle,
                message: EdgeStateCopy.decisionNotSentMessage,
                statusKind: .none,
                statusLabel: nil,
                lastVerifiedText: nil,
                timingEvidence: nil,
                actions: [EdgeStateAction(title: EdgeStateCopy.decisionNotSentRetry, kind: .primary)]
            )

        case .permissionRevokedExternally:
            return EdgeStatePresentation(
                id: scenario,
                screenID: scenario.screenID,
                frameName: scenario.frameName,
                audience: .parent,
                severity: .unavailable,
                title: EdgeStateCopy.externalRevokeTitle,
                message: EdgeStateCopy.externalRevokeMessage,
                statusKind: .protectionUnavailable,
                statusLabel: nil,
                lastVerifiedText: "\(EdgeStateCopy.lastVerifiedPrefix) at last app check-in",
                timingEvidence: nil,
                actions: [EdgeStateAction(title: "Check Apple permission", kind: .secondary)]
            )
        }
    }

    /// Every approved scenario's presentation, in catalogue order.
    static let all: [EdgeStatePresentation] = EdgeStateScenario.allCases.map(presentation(for:))
}
