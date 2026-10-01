import Foundation

/// A change a Settings screen asks for. The repository decides what happens.
enum SettingsAction: Equatable, Sendable {
    case inviteGuardian(contact: String)
    case cancelGuardianInvite
    case removeGuardian
    case addChild(NewChildDraft)
    case saveChild(id: String, firstName: String, experience: ExperienceSegment)
    case removeChild(id: String)
    case requestDeviceRemoval(childID: String)
    case requestResync(childID: String)
    case sendSupportMessage(String)
    case transferOwnership(toID: String)
    case leaveHousehold
    case deleteHousehold
    case signOut
}

enum SettingsActionOutcome: Equatable, Sendable {
    /// Accepted. `isPresentationOnly` is true when nothing real happened.
    case accepted(isPresentationOnly: Bool)
    case rejected(reason: String)

    var isAccepted: Bool {
        if case .accepted = self { return true }
        return false
    }
}

/// Settings presentation repository, local to this feature. A real implementation arrives with
/// the backend; it must enforce roles server-side and report real outcomes.
protocol SettingsRepository: Sendable {
    func state(for scenario: SettingsScenario) async throws -> SettingsPresentationState
    func perform(_ action: SettingsAction) async -> SettingsActionOutcome
}

/// Deterministic mock. It accepts every action as presentation-only: no email, support ticket,
/// device command, ownership change, deletion, sign-out, StoreKit call or network request happens.
struct MockSettingsRepository: SettingsRepository {
    /// Always false. Used by tests and previews to prove nothing real is performed.
    let performsRealMutations = false

    func state(for scenario: SettingsScenario) async throws -> SettingsPresentationState {
        SettingsDemoData.state(for: scenario)
    }

    func perform(_ action: SettingsAction) async -> SettingsActionOutcome {
        .accepted(isPresentationOnly: true)
    }

    /// "alex@example.com" → "Alex". The mock invites nobody; this only labels the pending card.
    static func displayName(forContact contact: String) -> String {
        let local = contact.split(separator: "@").first.map(String.init) ?? contact
        let trimmed = local.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "Guardian" }
        return first.uppercased() + trimmed.dropFirst()
    }
}
