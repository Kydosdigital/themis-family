import Foundation

/// Holds the household Settings presents and applies each intent through the repository.
///
/// Role checks here are presentation guards so a hidden control cannot be triggered by accident.
/// They are not authorisation: the server must enforce roles. A state only changes when the
/// repository accepts the action, and the demo repository says its outcomes are presentation-only.
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var household: SettingsHousehold
    @Published private(set) var viewerID: String
    @Published var notifications: [NotificationPreference]
    @Published private(set) var deviceRemoval: [String: DeviceRemovalState] = [:]
    @Published private(set) var childRemoval: [String: ChildRemovalState] = [:]
    @Published private(set) var resyncRequested: Set<String> = []
    @Published private(set) var supportMessageSent = false
    @Published private(set) var ownershipTransfer: OwnershipTransferState = .idle
    @Published private(set) var deletion: HouseholdDeletionState = .idle
    /// Why the last action was refused, if it was.
    @Published private(set) var lastRefusal: String?

    private let repository: any SettingsRepository

    init(
        repository: any SettingsRepository = MockSettingsRepository(),
        state: SettingsPresentationState = SettingsDemoData.state(for: .owner),
        notifications: [NotificationPreference] = SettingsDemoData.notificationPreferences
    ) {
        self.repository = repository
        self.household = state.household
        self.viewerID = state.viewerID
        self.notifications = notifications
    }

    var viewerRole: SettingsRole {
        household.role(of: viewerID) ?? .guardian
    }

    func can(_ capability: SettingsCapability) -> Bool {
        viewerRole.can(capability)
    }

    func removal(for childID: String) -> DeviceRemovalState {
        deviceRemoval[childID] ?? .idle
    }

    func load(scenario: SettingsScenario) async {
        guard let state = try? await repository.state(for: scenario) else { return }
        household = state.household
        viewerID = state.viewerID
    }

    // MARK: Guardian

    @discardableResult
    func inviteGuardian(contact: String) async -> Bool {
        let trimmed = contact.trimmingCharacters(in: .whitespacesAndNewlines)
        guard allowed(.inviteGuardian), household.canInviteGuardian, !trimmed.isEmpty else {
            return refuse(household.canInviteGuardian ? "Only the Owner can invite a Guardian." : SettingsCopy.guardianSlotTaken)
        }
        guard await accepted(.inviteGuardian(contact: trimmed)) else { return false }
        household.guardian = .invited(name: MockSettingsRepository.displayName(forContact: trimmed), contact: trimmed)
        return true
    }

    @discardableResult
    func cancelGuardianInvite() async -> Bool {
        guard allowed(.inviteGuardian), household.pendingInvite != nil else { return refuse("Only the Owner can cancel an invite.") }
        guard await accepted(.cancelGuardianInvite) else { return false }
        household.guardian = .none
        return true
    }

    /// Removing the Guardian does not cancel anything waiting, move ownership or change rules.
    @discardableResult
    func removeGuardian() async -> Bool {
        guard allowed(.removeGuardian), household.hasAcceptedGuardian else { return refuse("Only the Owner can remove the Guardian.") }
        guard await accepted(.removeGuardian) else { return false }
        household.guardian = .none
        return true
    }

    // MARK: Children and devices

    @discardableResult
    func addChild(_ draft: NewChildDraft) async -> Bool {
        guard allowed(.addChild), draft.isComplete, let experience = draft.experience else { return refuse("Add a first name and choose an experience.") }
        guard await accepted(.addChild(draft)) else { return false }
        let id = "child-\(draft.trimmedName.lowercased())-\(household.children.count + 1)"
        household.children.append(ChildProfilePresentation(id: id, firstName: draft.trimmedName, experience: experience, device: nil))
        return true
    }

    @discardableResult
    func saveChild(id: String, firstName: String, experience: ExperienceSegment) async -> Bool {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard allowed(.editChildProfile), !trimmed.isEmpty, let index = household.children.firstIndex(where: { $0.id == id }) else {
            return refuse("Add a first name.")
        }
        guard await accepted(.saveChild(id: id, firstName: trimmed, experience: experience)) else { return false }
        household.children[index].firstName = trimmed
        household.children[index].experience = experience
        return true
    }

    /// A request, like device removal: the profile stays until the removal is acknowledged.
    @discardableResult
    func removeChild(id: String) async -> Bool {
        guard allowed(.removeChild), household.child(id: id) != nil else { return refuse("This child can’t be removed here.") }
        guard await accepted(.removeChild(id: id)) else { return false }
        childRemoval[id] = .requested
        return true
    }

    /// Confirming records a request and waits for the device. It never reports the device removed.
    @discardableResult
    func requestDeviceRemoval(childID: String) async -> Bool {
        guard allowed(.removeChildDevice), household.child(id: childID)?.device != nil else { return refuse("This device can’t be removed here.") }
        deviceRemoval[childID] = .removeRequested
        guard await accepted(.requestDeviceRemoval(childID: childID)) else {
            deviceRemoval[childID] = .idle
            return false
        }
        deviceRemoval[childID] = .removing
        return true
    }

    /// The device confirmed. Only an acknowledgement moves "Removing" to "Removed", and the
    /// profile and rules are kept.
    func acknowledgeDeviceRemoval(childID: String) {
        guard deviceRemoval[childID] == .removing, let index = household.children.firstIndex(where: { $0.id == childID }) else { return }
        household.children[index].device = nil
        deviceRemoval[childID] = .removed
    }

    // MARK: Support

    @discardableResult
    func requestResync(childID: String) async -> Bool {
        guard household.child(id: childID)?.device != nil else { return refuse("This device can’t be resynced.") }
        guard await accepted(.requestResync(childID: childID)) else { return false }
        resyncRequested.insert(childID)
        return true
    }

    func resetSupportMessage() {
        supportMessageSent = false
    }

    @discardableResult
    func sendSupportMessage(_ text: String) async -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return refuse("Describe what’s happening.") }
        guard await accepted(.sendSupportMessage(trimmed)) else { return false }
        supportMessageSent = true
        return true
    }

    // MARK: Ownership

    /// Moves ownership to the accepted Guardian atomically. Presentation only.
    @discardableResult
    func transferOwnership() async -> Bool {
        guard allowed(.transferOwnership), let target = household.acceptedGuardian else {
            return refuse("Ownership can only go to your Guardian.")
        }
        guard case let .success(updated) = household.transferringOwnership(to: target.id) else {
            return refuse("Ownership can only go to your Guardian.")
        }
        guard await accepted(.transferOwnership(toID: target.id)) else { return false }
        household = updated
        ownershipTransfer = .completed
        return true
    }

    @discardableResult
    func leaveHousehold() async -> Bool {
        guard viewerRole == .guardian else { return refuse("An Owner leaves by transferring ownership or deleting the household.") }
        return await accepted(.leaveHousehold)
    }

    @discardableResult
    func deleteHousehold(typed: String) async -> Bool {
        guard allowed(.deleteHousehold), DeleteConfirmation.isSatisfied(by: typed) else {
            return refuse("Only the Owner can delete the household, and only after typing DELETE.")
        }
        guard await accepted(.deleteHousehold) else { return false }
        deletion = .deletedPresentationOnly
        return true
    }

    @discardableResult
    func signOut() async -> Bool {
        await accepted(.signOut)
    }

    #if DEBUG
    /// Review helper: puts a device in a removal state without going through the repository.
    /// Debug builds only; used by previews.
    func setDeviceRemovalForPreview(childID: String, state: DeviceRemovalState) {
        deviceRemoval[childID] = state
        if state == .removed, let index = household.children.firstIndex(where: { $0.id == childID }) {
            household.children[index].device = nil
        }
    }

    func markResyncRequestedForPreview(childID: String) {
        resyncRequested.insert(childID)
    }

    func markSupportMessageSentForPreview() {
        supportMessageSent = true
    }
    #endif

    // MARK: Helpers

    private func allowed(_ capability: SettingsCapability) -> Bool {
        can(capability)
    }

    private func accepted(_ action: SettingsAction) async -> Bool {
        let outcome = await repository.perform(action)
        if case let .rejected(reason) = outcome {
            lastRefusal = reason
            return false
        }
        lastRefusal = nil
        return true
    }

    private func refuse(_ reason: String) -> Bool {
        lastRefusal = reason
        return false
    }
}
