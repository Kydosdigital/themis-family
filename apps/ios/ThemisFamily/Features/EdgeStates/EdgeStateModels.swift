import Foundation

// MARK: - UI-13 Edge States
//
// Isolated, presentation-only models for the approved UI-13 edge-state catalogue.
// This file is Foundation-only (no SwiftUI/UIKit) so it can be fully type-checked
// and unit tested without a SwiftUI runtime.
//
// UI-13 does not own normal production screens (Parent Home, Child Home, Tasks,
// Requests, Activity, Onboarding, Subscription, Protection). It prepares the
// approved edge-state presentations in isolation for later adoption by the
// sequential feature builders. See docs/26_ERROR_AND_EDGE_CASE_CATALOGUE.md,
// docs/17_OFFLINE_AND_SYNC_BEHAVIOUR.md, docs/20_STATE_MACHINES.md,
// docs/34_OPEN_QUESTIONS.md (OQ-19, OQ-34, OQ-40) and docs/35_DECISION_LOG.md
// (DEC-27, DEC-34, DEC-40, DEC-42, DEC-43, DEC-47, DEC-48, DEC-49).

/// The audience a given edge-state presentation is written for.
/// Mirrors `ThemisAudience` conceptually without depending on it, so this file
/// stays Foundation-only.
enum EdgeStateAudience: String, CaseIterable, Sendable {
    case parent
    case child
    case teen
}

/// Calm severity banding for an edge state. Never a substitute for honest copy;
/// every state must still explain what happened, what is known and what can be
/// done next (see problem statement §31).
enum EdgeStateSeverity: String, CaseIterable, Sendable {
    /// A calm, successful empty state. Not an error (A-001 · Empty, T-001 · Empty).
    case calmEmpty
    /// Something needs attention but is not an error (timing review, queued items).
    case attention
    /// Connectivity or sync is degraded; last-known state still applies.
    case offline
    /// Protection/permission is not currently active and must be explained honestly.
    case unavailable
    /// A send/submit attempt did not durably succeed.
    case failure
    /// A session or pairing flow ended without completing.
    case interrupted
}

/// The exact approved UI-13 scenario inventory (problem statement §7).
/// Each case is one, and only one, canonical approved state. Do not broaden this
/// list to the full EC-01…EC-36 catalogue: many of those items are owned by other
/// UI slices or production spikes (problem statement §8).
enum EdgeStateScenario: String, CaseIterable, Identifiable, Sendable {
    case serversUnreachable          // P-023 · Servers unreachable
    case actionCentreEmpty           // A-001 · Empty
    case activityEmpty               // T-001 · Empty
    case timingUnverified            // A-002 · Timing
    case timingApproved              // A-002 · Timing approved
    case timingAsk                   // A-002 · Timing ask
    case activityTiming              // T-002 · Timing
    case childTimingUnverified       // C-004 · Timing
    case childOffline                // C-001 · Offline
    case childQueuedOffline          // C-004 · Queued
    case requestSavedOffline         // Q-006 · Offline
    case childPermissionNeeded       // C-001 · Permission
    case childDeviceRemoved          // C-001 · Removed
    case pairingInterrupted          // P-010 · Interrupted
    case sessionAbandoned            // E-007 · Abandoned
    case decisionSendFailed          // A-004 · Send failed
    case permissionRevokedExternally // P-012 · External revoke

    var id: String { rawValue }

    /// The approved screen identifier this edge state is a variant of.
    var screenID: String {
        switch self {
        case .serversUnreachable: return "P-023"
        case .actionCentreEmpty: return "A-001"
        case .activityEmpty: return "T-001"
        case .timingUnverified, .timingApproved, .timingAsk: return "A-002"
        case .activityTiming: return "T-002"
        case .childTimingUnverified: return "C-004"
        case .childOffline: return "C-001"
        case .childQueuedOffline: return "C-004"
        case .requestSavedOffline: return "Q-006"
        case .childPermissionNeeded: return "C-001"
        case .childDeviceRemoved: return "C-001"
        case .pairingInterrupted: return "P-010"
        case .sessionAbandoned: return "E-007"
        case .decisionSendFailed: return "A-004"
        case .permissionRevokedExternally: return "P-012"
        }
    }

    /// Short canonical frame name, matching the problem statement's §7 inventory.
    var frameName: String {
        switch self {
        case .serversUnreachable: return "Servers unreachable"
        case .actionCentreEmpty: return "Empty"
        case .activityEmpty: return "Empty"
        case .timingUnverified: return "Timing"
        case .timingApproved: return "Timing approved"
        case .timingAsk: return "Timing ask"
        case .activityTiming: return "Timing"
        case .childTimingUnverified: return "Timing"
        case .childOffline: return "Offline"
        case .childQueuedOffline: return "Queued"
        case .requestSavedOffline: return "Offline"
        case .childPermissionNeeded: return "Permission"
        case .childDeviceRemoved: return "Removed"
        case .pairingInterrupted: return "Interrupted"
        case .sessionAbandoned: return "Abandoned"
        case .decisionSendFailed: return "Send failed"
        case .permissionRevokedExternally: return "External revoke"
        }
    }

    /// The audience this state is written for.
    var audience: EdgeStateAudience {
        switch self {
        case .serversUnreachable, .actionCentreEmpty, .timingUnverified, .timingApproved,
             .timingAsk, .activityTiming, .decisionSendFailed:
            return .parent
        case .childOffline, .childQueuedOffline, .childTimingUnverified, .childPermissionNeeded,
             .childDeviceRemoved:
            return .child
        case .activityEmpty, .requestSavedOffline, .pairingInterrupted, .sessionAbandoned,
             .permissionRevokedExternally:
            return .parent
        }
    }

    var severity: EdgeStateSeverity {
        switch self {
        case .actionCentreEmpty, .activityEmpty:
            return .calmEmpty
        case .timingUnverified, .timingApproved, .timingAsk, .activityTiming, .childTimingUnverified:
            return .attention
        case .childOffline, .childQueuedOffline, .requestSavedOffline:
            return .offline
        case .childPermissionNeeded, .childDeviceRemoved, .permissionRevokedExternally,
             .serversUnreachable:
            return .unavailable
        case .decisionSendFailed:
            return .failure
        case .pairingInterrupted, .sessionAbandoned:
            return .interrupted
        }
    }
}

/// An available action on an edge-state presentation. Presentation-only: no
/// networking, no persistence. The view layer wires these to local, deterministic
/// mock behaviour only.
struct EdgeStateAction: Identifiable, Hashable, Sendable {
    enum Kind: String, Sendable {
        case primary
        case secondary
        case tertiary
        case destructive
    }

    var id: String { title }
    let title: String
    let kind: Kind
}

/// The two timestamps shown whenever submission timing could not be verified.
/// Both must always be shown together; neither is ever presented as "the" truth.
/// See DEC-40 / §17.7a trusted-time model and problem statement §12/§28.
struct TimingEvidencePresentation: Hashable, Sendable {
    /// The time the child device claims the action happened (device-local clock).
    let childDeviceClaimedTime: String
    /// The time the server received the submission.
    let serverReceivedTime: String
}

/// Canonical, test-asserted copy for the UI-13 catalogue. Kept Foundation-only so
/// exact strings can be unit tested without a SwiftUI runtime.
///
/// These strings encode safety-critical semantic constraints (problem statement
/// §9-§28): never "Protected" where inappropriate, never "late"/"on time" for
/// unverified timing, never claiming real-time detection or server receipt that
/// has not happened.
enum EdgeStateCopy {
    // MARK: P-023 · Servers unreachable
    static let serversUnreachableTitle = "Can't reach Themis"
    static let serversUnreachableMessage =
        "Themis can't reach its servers right now. This device's last-synced " +
        "protection plan may continue to apply, but Themis can't confirm the " +
        "current state or send new changes until the connection is restored."
    static let lastVerifiedPrefix = "Last verified"

    // MARK: A-001 · Empty (Action Centre)
    static let actionCentreEmptyTitle = "All caught up"
    static let actionCentreEmptyMessage =
        "Nothing needs your attention right now. Tasks, requests and reviews will " +
        "show up here as soon as something needs you."

    // MARK: T-001 · Empty (Activity)
    static let activityEmptyTitle = "No activity yet"
    static let activityEmptyMessage =
        "Activity will show outcomes from Themis rules, tasks, requests, temporary " +
        "access and protection as they happen. It isn't a record of everything on " +
        "the device."

    // MARK: A-002 · Timing could not be verified
    static let timingUnverifiedTitle = "Timing could not be verified"
    static let timingUnverifiedExplanation =
        "Themis can't confirm which timing should be trusted for this submission. " +
        "This is a neutral gap in the evidence, not a judgement about the child \u{2014} " +
        "you can review and decide what to do next."
    /// Canonical deterministic example evidence, as directed for this isolated catalogue.
    static let timingUnverifiedExample = TimingEvidencePresentation(
        childDeviceClaimedTime: "5:58 PM",
        serverReceivedTime: "6:02 PM"
    )
    static let timingActionApprove = "Approve"
    static let timingActionNeedsMoreWork = "Needs more work"
    static let timingActionAskOneQuestion = "Ask one question"

    // MARK: A-002 · Timing approved
    /// Exact outcome copy. Must never be rewritten to "Submitted on time".
    static let timingApprovedOutcome = "Approved, timing unverified"
    static let timingApprovedExplanation =
        "You approved this task. Themis still can't confirm exactly when it was " +
        "submitted, so the record keeps showing " +
        "\u{201C}\(timingApprovedOutcome)\u{201D} rather than rewriting the history. " +
        "Any other active rules still apply."

    // MARK: A-002 · Timing ask (bounded clarification)
    static let timingAskTitle = "Ask one question"
    static let timingAskExplanation =
        "You can ask one question and get one reply before deciding. This stays " +
        "bounded, not an ongoing conversation \u{2014} after the reply, you'll choose " +
        "Approve or Needs more work."
    static let timingAskPlaceholderQuestion = "Can you tell me what time you actually finished?"

    // MARK: T-002 · Timing (Activity presentation after review)
    static let activityTimingExplanation =
        "This task's timing couldn't be verified. The record preserves " +
        "\u{201C}\(timingApprovedOutcome)\u{201D} \u{2014} the outcome is never " +
        "rewritten based on a timing guess."

    // MARK: C-004 · Timing (child-facing)
    static let childTimingTitle = "Checking this with a grown-up"
    static let childTimingMessage =
        "Themis couldn't confirm the exact time for this one, so a parent or carer " +
        "will take a normal look. This isn't something you need to worry about."

    // MARK: C-001 · Offline (child)
    static let childOfflineTitle = "No connection right now"
    static let childOfflineMessage =
        "Themis can't reach the service right now. This device keeps using its " +
        "last-synced rules, but Themis can't confirm they're current and new " +
        "changes can't arrive until it reconnects."

    // MARK: C-004 · Queued (saved offline)
    static let childQueuedTitle = "Saved offline"
    static let childQueuedMessage =
        "The time you pressed it is saved. This will send to Themis as soon as the " +
        "connection comes back. If the timing can't later be confirmed, a parent or " +
        "carer may take a normal look."

    // MARK: Q-006 · Offline (request saved offline)
    static let requestSavedOfflineTitle = "Request saved offline"
    static let requestSavedOfflineMessage =
        "This request is saved on this device and will send when Themis reconnects. " +
        "It hasn't reached a parent or carer yet."

    // MARK: C-001 · Permission needed (child)
    static let childPermissionTitle = "Permission needed"
    static let childPermissionMessage =
        "Themis can't currently apply the agreed protection on this device because " +
        "a required Apple permission isn't available. A parent or carer can look " +
        "into this."

    // MARK: C-001 · Removed (child)
    static let childRemovedTitle = "This device isn't set up for Themis"
    static let childRemovedMessage =
        "Themis is no longer set up for this household on this device."

    // MARK: P-010 · Pairing interrupted
    static let pairingInterruptedTitle = "Pairing interrupted"
    static let pairingInterruptedMessage =
        "Pairing didn't finish. This device wasn't added to the household, so " +
        "there's nothing partial to undo \u{2014} you can try again whenever " +
        "you're ready."
    static let pairingInterruptedRetry = "Try pairing again"

    // MARK: E-007 · Session not finished (abandoned)
    static let sessionAbandonedTitle = "Session not finished"
    static let sessionAbandonedMessage =
        "This session wasn't resumed in time, so it didn't count as finished. No " +
        "progress was lost on purpose \u{2014} you can start a fresh session whenever " +
        "you're ready."
    /// The confirmed ceiling: the earlier of context expiry or this many hours
    /// from the last trustworthy checkpoint (DEC-49). Never invent a different value.
    static let sessionAbandonedCeilingHours = 24

    // MARK: A-004 · Decision not sent
    static let decisionNotSentTitle = "Decision not sent"
    static let decisionNotSentMessage =
        "Your decision didn't reach Themis, so it hasn't taken effect yet. Nothing " +
        "was discarded \u{2014} you can retry to send it now."
    static let decisionNotSentRetry = "Retry"

    // MARK: P-012 · Permission revoked externally
    static let externalRevokeTitle = "Permission revoked externally"
    static let externalRevokeMessage =
        "The required Apple permission for this device was turned off outside " +
        "Themis. Themis found this out the next time the app checked in, not the " +
        "moment it happened. Protection on this device is unavailable until " +
        "permission is restored."
}
