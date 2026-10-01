import Foundation

// UI-11 Settings (ST-001 to ST-012, P-032 to P-034).
//
// Presentation models only. Nothing here is a production domain model, and nothing in this
// feature authorises anything: hiding or disabling a control is presentation, and the server
// must enforce roles. No networking, StoreKit, FamilyControls, APNs or persistence.

// MARK: - Roles and capabilities

/// The two parent roles in V1: exactly one Owner, up to one additional Guardian.
enum SettingsRole: String, CaseIterable, Sendable {
    case owner
    case guardian

    var title: String {
        switch self {
        case .owner: return "Owner"
        case .guardian: return "Guardian"
        }
    }

    func can(_ capability: SettingsCapability) -> Bool {
        switch self {
        case .owner: return true
        case .guardian: return !SettingsCapability.ownerOnly.contains(capability)
        }
    }
}

/// Settings actions, per docs/18_ROLES_AND_PERMISSIONS.md §18.2. Owner and Guardian share
/// everything except the Owner-only administrative set.
enum SettingsCapability: String, CaseIterable, Sendable {
    // Shared by Owner and Guardian.
    case addChild
    case editChildProfile
    case removeChild
    case addChildDevice
    case removeChildDevice
    case viewReporting
    case editRules
    case grantFreePass
    case approveTasks
    case changeSchoolAllowlist
    // Owner only.
    case inviteGuardian
    case removeGuardian
    case manageSubscription
    case transferOwnership
    case deleteHousehold

    static let ownerOnly: Set<SettingsCapability> = [
        .inviteGuardian, .removeGuardian, .manageSubscription, .transferOwnership, .deleteHousehold
    ]
}

// MARK: - Household

struct HouseholdMemberPresentation: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    var role: SettingsRole
    /// "3 Sep".
    var joined: String? = nil

    var initial: String { String(name.prefix(1)) }
}

/// The household's single Guardian slot. A pending invite is not a household member until it
/// is accepted, and it fills the slot: V1 caps Guardians at one.
enum GuardianSlot: Equatable, Sendable {
    case none
    case invited(name: String, contact: String)
    case accepted(HouseholdMemberPresentation)
}

enum OwnershipTransferError: Error, Equatable, Sendable {
    case noAcceptedGuardian
    case targetIsAChild
    case targetNotAnAcceptedGuardian
    case targetIsAlreadyOwner
}

/// The two V1 ways for an Owner to leave. There is no third.
enum OwnerExitRoute: CaseIterable, Sendable {
    case transferThenLeave
    case deleteHousehold
}

struct SettingsHousehold: Equatable, Sendable {
    var name: String
    /// A single Owner by construction, so a household with no Owner cannot be represented.
    var owner: HouseholdMemberPresentation
    var guardian: GuardianSlot
    var children: [ChildProfilePresentation]

    /// V1 supports exactly one Owner plus up to one additional Guardian (DEC-14).
    static let maxGuardians = 1

    var acceptedGuardian: HouseholdMemberPresentation? {
        if case let .accepted(member) = guardian { return member }
        return nil
    }

    var pendingInvite: (name: String, contact: String)? {
        if case let .invited(name, contact) = guardian { return (name, contact) }
        return nil
    }

    var ownerCount: Int { 1 }

    var guardianCount: Int { acceptedGuardian == nil ? 0 : 1 }

    /// A second Guardian cannot be invited while the slot is taken by a Guardian or an invite.
    var canInviteGuardian: Bool { guardian == .none }

    var hasAcceptedGuardian: Bool { acceptedGuardian != nil }

    func role(of memberID: String) -> SettingsRole? {
        if owner.id == memberID { return .owner }
        if acceptedGuardian?.id == memberID { return .guardian }
        return nil
    }

    func child(id: String) -> ChildProfilePresentation? {
        children.first { $0.id == id }
    }

    /// Owner exit routes. Without an accepted Guardian, transfer is unavailable and only
    /// deleting the household remains.
    var availableOwnerExitRoutes: [OwnerExitRoute] {
        hasAcceptedGuardian ? [.transferThenLeave, .deleteHousehold] : [.deleteHousehold]
    }

    /// Ownership moves atomically: the accepted Guardian becomes Owner and the Owner becomes
    /// Guardian in one step, so there is never a household with no Owner. The target must
    /// already be the accepted Guardian: not a child, not a pending invite.
    func transferringOwnership(to targetID: String) -> Result<SettingsHousehold, OwnershipTransferError> {
        if children.contains(where: { $0.id == targetID }) { return .failure(.targetIsAChild) }
        if owner.id == targetID { return .failure(.targetIsAlreadyOwner) }
        guard let incoming = acceptedGuardian else { return .failure(.noAcceptedGuardian) }
        guard incoming.id == targetID else { return .failure(.targetNotAnAcceptedGuardian) }

        var updated = self
        var newOwner = incoming
        newOwner.role = .owner
        var newGuardian = owner
        newGuardian.role = .guardian
        updated.owner = newOwner
        updated.guardian = .accepted(newGuardian)
        return .success(updated)
    }
}

// MARK: - Children and devices

/// One managed device as Settings presents it. Everything shown comes from the household's
/// presentation state; no device is contacted.
struct ManagedDevicePresentation: Equatable, Sendable {
    let name: String
    var status: ThemisStatus
    /// "2 min ago".
    var lastVerified: String
    /// "Given". Nil when not shown.
    var applePermission: String? = nil
    /// "3 Sep". Nil when not shown.
    var paired: String? = nil
    /// What the status means, in the approved wording.
    var explanation: String

    /// "Verified 2 min ago". A protection status is never shown without when it was confirmed.
    var verifiedText: String { "Verified \(lastVerified)" }
}

struct ChildProfilePresentation: Identifiable, Equatable, Sendable {
    let id: String
    var firstName: String
    var experience: ExperienceSegment
    /// V1 assumes one dedicated device per child (DEC-26). That is a scope assumption for
    /// shared-device scenarios, not a confirmed cap on managed devices, so no copy states a limit.
    var device: ManagedDevicePresentation?

    static let assumedManagedDevicesPerChild = 1

    /// "Sam · Child".
    var title: String { "\(firstName) · \(experience.rawValue)" }
    var initial: String { String(firstName.prefix(1)) }

    var tone: ThemisTone { experience == .child ? .aqua : .peach }
}

/// A new child. First name and experience only: no date of birth, age or anything else.
struct NewChildDraft: Equatable, Sendable {
    var firstName: String = ""
    var experience: ExperienceSegment? = nil

    var trimmedName: String { firstName.trimmingCharacters(in: .whitespacesAndNewlines) }
    var isComplete: Bool { !trimmedName.isEmpty && experience != nil }
}

/// Device removal keeps the request and its confirmation apart. "Removing" is not "Removed":
/// the device may only unbind the next time it connects.
enum DeviceRemovalState: Equatable, Sendable {
    case idle
    /// The parent confirmed. Nothing has reached the device.
    case removeRequested
    /// Waiting for the device to confirm. Not a success state.
    case removing
    /// The device acknowledged. Only now is the device removed.
    case removed

    var isFinal: Bool { self == .removed }
}

/// A child profile removal request. Like device removal, it is a request until acknowledged.
enum ChildRemovalState: Equatable, Sendable {
    case none
    case requested
}

// MARK: - Ownership and deletion

enum OwnershipTransferState: Equatable, Sendable {
    case idle
    case completed
}

enum HouseholdDeletionState: Equatable, Sendable {
    case idle
    /// Presentation only: nothing was deleted, no restriction cleared, no subscription touched.
    case deletedPresentationOnly
}

/// Typed confirmation for deleting a household.
enum DeleteConfirmation {
    static let phrase = "DELETE"

    static func isSatisfied(by typed: String) -> Bool {
        typed.trimmingCharacters(in: .whitespacesAndNewlines) == phrase
    }
}

// MARK: - Notifications, privacy, support, safeguarding, subscription boundary

struct NotificationPreference: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    var isOn: Bool
}

/// What ordinary Support may and may not do. Support diagnoses and guides; it never acts as
/// the parent (docs/30_ADMIN_AND_SUPPORT.md §30.3a).
enum SupportCapability: CaseIterable, Sendable {
    // May.
    case diagnoseDevice
    case requestSafeResync
    case accountRecoveryHelp
    case restorePurchaseGuidance
    case receiveSupportMessage
    // May not.
    case editRules
    case approveOrRejectTask
    case approveOrDeclineRequest
    case grantFreePass
    case revokeFreePass
    case changeRestrictions
    case impersonateParent
    case rewriteBillingState
}

enum SupportBoundary {
    static let allowed: Set<SupportCapability> = [
        .diagnoseDevice, .requestSafeResync, .accountRecoveryHelp, .restorePurchaseGuidance, .receiveSupportMessage
    ]

    static func canPerform(_ capability: SupportCapability) -> Bool {
        allowed.contains(capability)
    }
}

/// Safeguarding is a separate path from ordinary support. Its owner, procedure and contact
/// details are not decided, so none are shown or invented here.
enum SafeguardingPlaceholder {
    static let hasOperationalContact = false
}

/// ST-009: the Settings side of the Subscription boundary. Settings only shows the status and
/// hands off. The subscription screens (B-001 to B-008) belong to another slice.
struct SettingsSubscriptionBoundary: Equatable, Sendable {
    /// "Active" for the canonical Owner state.
    let statusLabel: String
    /// Changing or managing the subscription is Owner only.
    let requiresOwner = true
}

// MARK: - Navigation

/// Destinations owned by other slices. Settings only names them; the main lane connects them.
enum SettingsExternalDestination: Hashable, Sendable {
    /// B-002 Manage subscription (Subscription slice).
    case subscriptionSettings
    /// P-031 Fix this (Protection slice).
    case fixProtection(childID: String)
    /// P-009 Pair device (Onboarding).
    case pairDevice(childID: String)
    /// C-013 What a child sees (Child and Teen Home).
    case childTransparency(childID: String)
    /// P-002 Welcome, after leaving, deleting or signing out.
    case welcome

    var screenID: String {
        switch self {
        case .subscriptionSettings: return "B-002"
        case .fixProtection: return "P-031"
        case .pairDevice: return "P-009"
        case .childTransparency: return "C-013"
        case .welcome: return "P-002"
        }
    }

    var title: String {
        switch self {
        case .subscriptionSettings: return "Subscription"
        case .fixProtection: return "Fix this"
        case .pairDevice: return "Pair a device"
        case .childTransparency: return "What your child sees"
        case .welcome: return "Welcome"
        }
    }
}

enum SettingsRoute: Hashable, Sendable {
    case household
    case guardian
    case inviteGuardian
    case childrenAndDevices
    case addChild
    case editChild(String)
    case device(String)
    case notifications
    case privacy
    case support
    case diagnose(String)
    case contactSupport
    case safeguarding
    case transferOwnership
    case ownershipTransferred
    case leaveHousehold
    case deleteHousehold
    case householdDeleted
    case account
    case external(SettingsExternalDestination)
}

// MARK: - Scenarios

/// Deterministic review states.
enum SettingsScenario: String, CaseIterable, Identifiable, Sendable {
    case owner = "Owner"
    case guardian = "Guardian"
    case ownerNoGuardian = "Owner · no Guardian"
    case ownerPendingInvite = "Owner · invite pending"
    case ownerAfterTransfer = "After transfer"

    var id: String { rawValue }
}
