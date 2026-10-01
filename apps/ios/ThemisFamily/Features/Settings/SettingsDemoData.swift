import Foundation

/// The household a Settings screen presents and who is looking at it.
struct SettingsPresentationState: Equatable, Sendable {
    var household: SettingsHousehold
    var viewerID: String
}

/// Deterministic canonical family: Sarah (Owner), Alex (Guardian), Sam (Child), Maya (Teen).
/// Nothing is generated at runtime and nothing here is real account, device or billing data.
enum SettingsDemoData {
    static let sarah = HouseholdMemberPresentation(id: "sarah", name: "Sarah", role: .owner)
    static let alex = HouseholdMemberPresentation(id: "alex", name: "Alex", role: .guardian, joined: "3 Sep")

    static let sam = ChildProfilePresentation(
        id: "sam", firstName: "Sam", experience: .child,
        device: ManagedDevicePresentation(
            name: "Sam’s iPhone", status: .protected, lastVerified: "2 min ago",
            applePermission: "Given", paired: "3 Sep",
            explanation: "Rules are applying on Sam’s iPhone."
        )
    )

    static let maya = ChildProfilePresentation(
        id: "maya", firstName: "Maya", experience: .teen,
        device: ManagedDevicePresentation(
            name: "Maya’s iPhone", status: .syncPending, lastVerified: "14 min ago",
            explanation: "A change is on its way to Maya’s iPhone. Her last-synced rules may still apply."
        )
    )

    /// Sarah’s family with Alex as accepted Guardian.
    static let household = SettingsHousehold(
        name: "Sarah’s family", owner: sarah, guardian: .accepted(alex), children: [sam, maya]
    )

    static let householdWithoutGuardian = SettingsHousehold(
        name: "Sarah’s family", owner: sarah, guardian: .none, children: [sam, maya]
    )

    static let householdWithPendingInvite = SettingsHousehold(
        name: "Sarah’s family", owner: sarah, guardian: .invited(name: "Alex", contact: "alex@example.com"), children: [sam, maya]
    )

    static func state(for scenario: SettingsScenario) -> SettingsPresentationState {
        switch scenario {
        case .owner:
            return SettingsPresentationState(household: household, viewerID: sarah.id)
        case .guardian:
            return SettingsPresentationState(household: household, viewerID: alex.id)
        case .ownerNoGuardian:
            return SettingsPresentationState(household: householdWithoutGuardian, viewerID: sarah.id)
        case .ownerPendingInvite:
            return SettingsPresentationState(household: householdWithPendingInvite, viewerID: sarah.id)
        case .ownerAfterTransfer:
            let transferred = (try? household.transferringOwnership(to: alex.id).get()) ?? household
            return SettingsPresentationState(household: transferred, viewerID: sarah.id)
        }
    }

    static let notificationPreferences: [NotificationPreference] = [
        NotificationPreference(id: "tasks", title: "Tasks sent for review", isOn: true),
        NotificationPreference(id: "requests", title: "Requests", isOn: true),
        NotificationPreference(id: "protection", title: "Protection problems", isOn: true),
        NotificationPreference(id: "billing", title: "Billing", isOn: true)
    ]

    static let subscriptionBoundary = SettingsSubscriptionBoundary(statusLabel: "Active")

    /// The sample text the Contact support frame shows.
    static let sampleSupportMessage = "Bedtime didn’t start on Sam’s iPhone last night."
}
