import Foundation

/// Presentation state for P-023 Parent Home.
///
/// A display model, not a persistence model: repositories (mock today, Supabase later)
/// produce it, and `ParentHomeView` renders it without knowing where it came from.
struct ParentHomeState: Equatable, Sendable {
    /// Signed-in parent, shown as the page title ("Sarah").
    let parentName: String
    /// Small line above the name ("Good evening").
    let greeting: String
    /// Items waiting in the Action Centre, shown on the bell.
    let actionCentreCount: Int
    /// Block 1 of the fixed scan order.
    let attention: ParentHomeAttention
    /// Block 2.
    let children: [ChildStatusSummary]
    /// Block 3.
    let agreements: [AgreementSummary]
    /// Block 4. Always Add rule and Free Pass.
    let quickActions: [ParentQuickAction]

    /// The approved mobile scan order. Sections without content are skipped,
    /// but the order never changes.
    var sections: [ParentHomeSection] {
        var result: [ParentHomeSection] = [.attention]
        if !children.isEmpty { result.append(.children) }
        if !agreements.isEmpty { result.append(.agreements) }
        result.append(.quickActions)
        return result
    }
}

enum ParentHomeSection: String, CaseIterable, Sendable {
    case attention
    case children
    case agreements
    case quickActions
}

/// What sits in the Needs You position.
enum ParentHomeAttention: Equatable, Sendable {
    /// P-023 canonical: decisions waiting for the parent.
    case needsYou(NeedsYouContent)
    /// P-023 · Setup incomplete: a child whose protection isn't active yet.
    case setupIncomplete(HomeActionCardContent)
    /// P-023 · Protection problem: a child whose protection needs attention.
    case protectionProblem(HomeActionCardContent)
    /// P-023 · Clear: nothing needs a decision.
    case nothingPending
    /// No children added yet (pre-onboarding; not a drawn P-023 state).
    case noChildren
}

/// Contents of `NeedsYouCard`: one primary item with its action, then further items.
struct NeedsYouContent: Equatable, Sendable {
    let primary: NeedsYouPrimaryItem
    let others: [NeedsYouItem]

    /// Shown in the card's count pill.
    var count: Int { 1 + others.count }
}

struct NeedsYouPrimaryItem: Equatable, Sendable {
    let avatar: ChildAvatar
    /// "Sam sent homework for review".
    let title: String
    /// Present while a Provisional Approval Grace Period (DEC-40) is running.
    let grace: ApprovalGraceWindow?
    /// "Review".
    let actionTitle: String
    let destination: ParentHomeRoute
}

struct NeedsYouItem: Identifiable, Equatable, Sendable {
    let id: String
    let avatar: ChildAvatar
    /// "Maya asked for 15 more min".
    let title: String
    /// "Instagram · 4 min ago".
    let detail: String
    let status: ThemisStatus
    let destination: ParentHomeRoute
}

/// Remaining time in the 30-minute Provisional Approval Grace Period (DEC-40, BR-207).
/// Countdowns show whole minutes only.
struct ApprovalGraceWindow: Equatable, Sendable {
    /// Length of the grace period set by DEC-40.
    static let approvedLengthMinutes = 30

    let minutesRemaining: Int
    var totalMinutes: Int = ApprovalGraceWindow.approvedLengthMinutes

    /// Share of the grace period already used, 0…1. Drives the `GraceBar` fill.
    var elapsedFraction: Double {
        guard totalMinutes > 0 else { return 1 }
        let remaining = min(max(minutesRemaining, 0), totalMinutes)
        return Double(totalMinutes - remaining) / Double(totalMinutes)
    }

    /// "18 min".
    var remainingText: String { "\(max(minutesRemaining, 0)) min" }
}

/// Setup-incomplete and protection-problem cards share one layout (prototype `card`).
struct HomeActionCardContent: Equatable, Sendable {
    let avatar: ChildAvatar
    let title: String
    let message: String
    let status: ThemisStatus
    let actionTitle: String
    let destination: ParentHomeRoute
}

struct ChildAvatar: Equatable, Sendable {
    let initial: String
    let tone: ThemisTone
}

/// One child's protection health as shown in the Children group.
struct ChildStatusSummary: Identifiable, Equatable, Sendable {
    let id: UUID
    let firstName: String
    let segment: ExperienceSegment
    let avatar: ChildAvatar
    let protection: ChildProtectionDisplay
    let evidence: ProtectionEvidence
    /// Nil when the row doesn't navigate.
    let destination: ParentHomeRoute?

    /// "Sam · Child".
    var title: String { "\(firstName) · \(segment.rawValue)" }

    var status: ThemisStatus { protection.status }

    /// "Verified 2 min ago". Protection status is never shown without its evidence.
    var evidenceText: String { evidence.text }
}

/// Protection as displayed for a child: one of the five honest protection states,
/// or not active yet because setup hasn't finished.
enum ChildProtectionDisplay: Equatable, Sendable {
    case protection(ProtectionStatus)
    case notActiveYet

    var status: ThemisStatus {
        switch self {
        case let .protection(status): return status.themisStatus
        case .notActiveYet: return .notActiveYet
        }
    }
}

/// When protection state was last confirmed, as shown next to every protection status.
/// The staleness threshold (OQ-19) is not decided here; the repository chooses the status.
enum ProtectionEvidence: Equatable, Sendable {
    case verified(minutesAgo: Int)
    case noticed(minutesAgo: Int)
    case notActiveYet

    var text: String {
        switch self {
        case let .verified(minutes): return minutes <= 0 ? "Verified just now" : "Verified \(Self.age(minutes))"
        case let .noticed(minutes): return minutes <= 0 ? "Noticed just now" : "Noticed \(Self.age(minutes))"
        case .notActiveYet: return "Protection not active yet"
        }
    }

    static func age(_ minutes: Int) -> String {
        minutes < 60 ? "\(minutes) min ago" : "\(minutes / 60) hr ago"
    }
}

/// A current agreement row ("Homework due 6:00 PM" · "Sam · School days").
struct AgreementSummary: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let detail: String
    let destination: ParentHomeRoute
}

/// The two approved quick actions. Do not add others.
enum ParentQuickAction: String, CaseIterable, Identifiable, Sendable {
    case addRule
    case freePass

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addRule: return "Add rule"
        case .freePass: return "Free Pass"
        }
    }

    var isPrimary: Bool { self == .addRule }

    var destination: ParentHomeRoute {
        switch self {
        case .addRule: return ParentHomeRoute(screenID: "R-003", title: "New rule")
        case .freePass: return ParentHomeRoute(screenID: "F-001", title: "Free Pass")
        }
    }
}

/// Where a Parent Home tap leads, by approved screen ID. Screens built in later
/// slices open a placeholder.
struct ParentHomeRoute: Hashable, Sendable {
    let screenID: String
    let title: String
    /// Child identity for protection routes; never infer identity from display copy.
    var childName: String? = nil

    static let actionCentre = ParentHomeRoute(screenID: "A-001", title: "Action Centre")
}
