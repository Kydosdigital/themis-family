import Foundation

/// A row on a Settings list, built from the household and the viewer's role.
struct SettingsRowModel: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    var subtitle: String? = nil
    /// Trailing text, e.g. "Owner only".
    var value: String? = nil
    var route: SettingsRoute? = nil
    var avatar: SettingsAvatar? = nil
    /// Status chip with glyph and label, e.g. a device's protection.
    var status: ThemisStatus? = nil
    /// Visible for context but not actionable for this role.
    var isOwnerOnlyLocked = false

    /// What assistive technology reads. A locked row says "Owner only" in words, so the
    /// boundary never depends on opacity or colour.
    var accessibilityDescription: String {
        let parts = [title, subtitle, value].compactMap { $0 }
        if isOwnerOnlyLocked, !parts.contains("Owner only") {
            return (parts + ["Owner only"]).joined(separator: ", ")
        }
        return parts.joined(separator: ", ")
    }

    /// Read after the label for a locked row.
    var accessibilityHint: String? {
        isOwnerOnlyLocked ? "Owner only. Only the Owner can change this." : nil
    }
}

struct SettingsAvatar: Equatable, Sendable {
    let initial: String
    let tone: ThemisTone
}

struct SettingsRowSection: Identifiable, Equatable, Sendable {
    let id: String
    let title: String?
    let rows: [SettingsRowModel]
}

/// Every sentence Settings shows that a requirement or privacy rule pins down. Kept in one
/// place so it can be tested.
enum SettingsCopy {
    // MARK: Household and Guardian

    static func ownerOnlyBanner(ownerName: String) -> String {
        "Only \(ownerName) can transfer ownership, manage the Guardian or delete the household."
    }

    static let guardianCan = "Approve tasks and requests, give Free Passes, edit rules, manage devices"
    static let guardianCannot = "Change the subscription, invite or remove anyone, delete the household"

    static func removeGuardianTitle(_ name: String) -> String { "Remove \(name) as Guardian?" }
    /// Pending approvals are not cancelled and ownership does not move.
    static func removeGuardianLine(_ name: String) -> String { "Anything waiting for \(name) stays waiting for you." }

    static let inviteIntro = "One Guardian per household. They can approve, give Free Passes and edit rules. They can’t change the subscription, invite others or delete the household."
    static let inviteFieldLabel = "Their email or phone number"
    static let inviteSentNote = "A pending invite doesn’t count as a household member until it’s accepted."
    static let guardianSlotTaken = "You already have a Guardian. A household has one Guardian."

    // MARK: Children and devices

    static let firstNameHelper = "First name only. No date of birth needed."
    static let experiencePrinciple = "Choose the experience that best fits your child. You can change this later."
    static let childExperienceDetail = "Simpler words and bigger buttons."
    static let teenExperienceDetail = "More autonomy and fuller detail."

    static func experienceChangeNote(_ name: String) -> String {
        "Changing the experience changes wording and layout on \(name)’s iPhone. Rules stay the same."
    }

    static func removeChildTitle(_ name: String) -> String { "Remove \(name) from your household?" }
    static func removeChildLine(_ name: String) -> String {
        "Themis removes its restrictions from \(name)’s iPhone and unpairs it. \(name)’s history follows the normal retention periods."
    }

    static func removeDeviceTitle(_ device: String) -> String { "Remove \(device)?" }
    static let removeDeviceLine = "Themis removes its restrictions and stops syncing with it. You can pair it again later."
    static func removingTitle(_ device: String) -> String { "Removing \(device)" }
    static func removingSubtitle(_ device: String) -> String { "Waiting for \(device) to confirm" }
    static let removingNote = "If it’s offline, it’s removed from your household now and clears its restrictions next time it connects."
    static func removedTitle(_ device: String) -> String { "\(device) removed" }
    static func removedNote(_ name: String) -> String { "\(name)’s profile and rules are kept. Pair a device to protect \(name) again." }

    // MARK: Notifications

    static let notificationsSection = "Sent to you"
    static let notificationsPrivacyNote = "Notifications show a name and an event only. Reasons, notes and details open after you unlock and open Themis."
    static let notificationsLimitsNote = "Each item gets one automatic reminder after 15 minutes, and your child can send one nudge. Nothing more."

    // MARK: Privacy and transparency (retention per docs/23 section 23.5)

    static let privacyKeepsHeading = "What Themis keeps"
    static let privacyNeverHeading = "What Themis never has"
    /// Structured Rule/Task/Request/Grant/Session history: 12-month rolling.
    static let structuredHistoryRetention = (label: "Rules, tasks, requests, passes", period: "12 months")
    /// Free-text reasons, clarification text and rejection notes: 90-day rolling.
    static let freeTextRetention = (label: "Request reasons and notes", period: "90 days")
    static let auditLogRetention = (label: "Audit log", period: "12 months")
    static let neverHasAppUsage = "Which apps your children use, or for how long"
    static let neverHasMessagesAndHistory = "Messages, chats, browsing or search history"
    static let privacyFooter = "Apple’s Screen Time reports are shown by Apple and never stored by Themis. Retention periods are subject to final legal review."

    // MARK: Support and safeguarding

    static let supportIntro = "Support can check your devices and guide you through fixes. Support can’t change your rules, approve requests or make decisions for your family."
    static let supportContactNote = "Support sees device and sync status for this issue only. They don’t see your children’s requests or notes."
    static let supportSentNote = "We’ll reply in the Themis app and by email."
    static func resyncSheetTitle(_ device: String) -> String { "Ask support to resync \(device)?" }
    static func resyncSheetLine(_ device: String) -> String { "\(device) re-applies the rules you already set. Your rules don’t change." }
    static func resyncRequestedSubtitle(_ device: String) -> String { "\(device) will re-apply your existing rules" }
    static let resyncRequestedNote = "Support’s action is logged. It restores what you set; it never makes a new decision."
    static let safeguardingTitle = "If you’re worried about a child’s safety"
    static let safeguardingEmergency = "If someone is in immediate danger, contact emergency services now."
    static let safeguardingBody = "This goes to a trained safeguarding reviewer, separate from ordinary support."
    static let safeguardingPrivacy = "Only the reviewer handling your report can see it."
    static let safeguardingAction = "Contact the safeguarding team"
    static let safeguardingPending = "Procedure and contact details to be confirmed before launch."

    // MARK: Ownership

    static func transferTitle(_ name: String) -> String { "Make \(name) the Owner?" }
    static func transferBody(_ name: String) -> String { "\(name) becomes the Owner and you become a Guardian, in one step." }
    static let transferLoses = "Subscription, Guardian management, deleting the household"
    static let transferKeeps = "Approvals, Free Passes, rules, devices"
    static func transferSheetTitle(_ name: String) -> String { "Transfer ownership to \(name)?" }
    static func transferSheetLine(_ name: String) -> String { "This takes effect straight away. Only \(name) can transfer it back." }
    static func transferredTitle(_ name: String) -> String { "\(name) is now the Owner" }
    static func transferredNote(household: String) -> String { "You’re a Guardian in \(household)." }
    static func leaveNowTitle(household: String) -> String { "Leave \(household)?" }
    static func leaveNowLine(_ name: String) -> String { "\(name) keeps managing the household. Anything waiting for you goes to \(name)." }

    static let leaveTitle = "A household always needs an Owner"
    static let leaveChoose = "To leave, choose one:"
    static let leaveRule = "Ownership can’t go to a child, and a household can’t be left without an Owner."
    static let noGuardianInfo = "There’s no Guardian to transfer to yet."
    static let inviteFirstTitle = "Invite a Guardian first"
    static let inviteFirstSubtitle = "Once they accept, transfer ownership, then leave"
    static let deleteCardTitle = "Delete the household"
    static let deleteCardSubtitle = "Removes everything and clears restrictions"

    // MARK: Deleting the household

    static func deleteTitle(household: String) -> String { "Delete \(household)?" }

    static func deleteBody(childNames: [String]) -> String {
        "This deletes all rules, history and devices, and removes Themis restrictions from \(possessiveIPhones(childNames)). It can’t be undone."
    }

    /// The deletion screen must say the App Store subscription is not cancelled automatically.
    static let deleteSubscriptionNote = "Your App Store subscription isn’t cancelled automatically. Manage it in the App Store."
    static let deleteFieldLabel = "Type DELETE to confirm"
    static let deleteFinalTitle = "Delete everything now?"

    static func deleteFinalLine(childNames: [String]) -> String {
        "\(naturalList(childNames)) will see that Themis is no longer set up on their iPhones."
    }

    static func deletedNote(childNames: [String]) -> String {
        "Restrictions are being removed from \(possessiveIPhones(childNames)) as they connect."
    }

    // MARK: Account

    static let signOutTitle = "Sign out of Themis?"
    static func signOutLine(otherParent: String?) -> String {
        guard let otherParent else { return "Rules keep running on your children’s iPhones." }
        return "Rules keep running on your children’s iPhones. \(otherParent) still gets approvals."
    }

    // MARK: Helpers

    /// "Sam", "Sam and Maya", "Sam, Maya and Leo".
    static func naturalList(_ names: [String]) -> String {
        switch names.count {
        case 0: return "Your children"
        case 1: return names[0]
        default: return names.dropLast().joined(separator: ", ") + " and " + (names.last ?? "")
        }
    }

    /// "Sam’s and Maya’s iPhones".
    static func possessiveIPhones(_ names: [String]) -> String {
        guard !names.isEmpty else { return "your children’s iPhones" }
        let possessives = names.map { "\($0)’s" }
        let joined = possessives.count == 1
            ? possessives[0]
            : possessives.dropLast().joined(separator: ", ") + " and " + (possessives.last ?? "")
        return "\(joined) iPhone" + (names.count == 1 ? "" : "s")
    }
}

/// Builds the Settings lists exactly as the approved frames show them.
enum SettingsPresentation {
    // MARK: ST-001

    /// ST-001 for the viewing role. Owner sees the full list; Guardian sees Owner-only rows as
    /// visible but not actionable, with "Owner only" in words.
    static func rootSections(household: SettingsHousehold, viewerRole: SettingsRole) -> [SettingsRowSection] {
        switch viewerRole {
        case .owner: return ownerRoot(household)
        case .guardian: return guardianRoot(household)
        }
    }

    private static func ownerRoot(_ household: SettingsHousehold) -> [SettingsRowSection] {
        let owner = household.owner
        return [
            SettingsRowSection(id: "account", title: nil, rows: [
                SettingsRowModel(
                    id: "account", title: owner.name, subtitle: "Owner · signed in with Apple", route: .account,
                    avatar: SettingsAvatar(initial: owner.initial, tone: .cobalt)
                )
            ]),
            SettingsRowSection(id: "household", title: "Household", rows: [
                SettingsRowModel(id: "household", title: "Household", subtitle: household.name, route: .household),
                SettingsRowModel(id: "children", title: "Children & devices", subtitle: childNames(household), route: .childrenAndDevices),
                guardianRow(household)
            ]),
            SettingsRowSection(id: "preferences", title: "Preferences", rows: [
                SettingsRowModel(id: "notifications", title: "Notifications", route: .notifications),
                SettingsRowModel(id: "privacy", title: "Privacy & transparency", route: .privacy)
            ]),
            SettingsRowSection(id: "subscription", title: "Subscription", rows: [
                SettingsRowModel(id: "subscription", title: "Subscription", subtitle: "Active", route: .external(.subscriptionSettings))
            ]),
            helpSection(detailed: true)
        ]
    }

    private static func guardianRow(_ household: SettingsHousehold) -> SettingsRowModel {
        if let guardian = household.acceptedGuardian {
            return SettingsRowModel(id: "guardian", title: "Guardian", subtitle: guardian.name, route: .guardian)
        }
        if let invite = household.pendingInvite {
            return SettingsRowModel(id: "guardian", title: "Guardian", subtitle: "Invite sent to \(invite.name)", route: .inviteGuardian)
        }
        return SettingsRowModel(id: "guardian", title: "Guardian", subtitle: "None yet", route: .inviteGuardian)
    }

    private static func guardianRoot(_ household: SettingsHousehold) -> [SettingsRowSection] {
        let me = household.acceptedGuardian ?? HouseholdMemberPresentation(id: "guardian", name: "Guardian", role: .guardian)
        let ownerName = household.owner.name
        return [
            SettingsRowSection(id: "account", title: nil, rows: [
                SettingsRowModel(
                    id: "account", title: me.name, subtitle: "Guardian · signed in with Apple", route: .account,
                    avatar: SettingsAvatar(initial: me.initial, tone: .mint)
                )
            ]),
            SettingsRowSection(id: "household", title: "Household", rows: [
                SettingsRowModel(id: "household", title: "Household", subtitle: "Owner: \(ownerName)", route: .household),
                SettingsRowModel(id: "children", title: "Children & devices", subtitle: childNames(household), route: .childrenAndDevices)
            ]),
            SettingsRowSection(id: "owner-only", title: "Owner only", rows: [
                SettingsRowModel(
                    id: "subscription", title: "Subscription", subtitle: "\(ownerName) manages this",
                    value: "Owner only", isOwnerOnlyLocked: true
                ),
                SettingsRowModel(
                    id: "guardian-ownership", title: "Guardian and ownership", subtitle: "\(ownerName) manages this",
                    value: "Owner only", isOwnerOnlyLocked: true
                )
            ]),
            helpSection(detailed: false)
        ]
    }

    private static func helpSection(detailed: Bool) -> SettingsRowSection {
        SettingsRowSection(id: "help", title: "Help", rows: [
            SettingsRowModel(id: "support", title: "Support", subtitle: detailed ? "Fix a problem with Themis" : nil, route: .support),
            SettingsRowModel(id: "safeguarding", title: "Safeguarding help", subtitle: detailed ? "Worried about a child’s safety" : nil, route: .safeguarding)
        ])
    }

    static func childNames(_ household: SettingsHousehold) -> String {
        household.children.map(\.firstName).joined(separator: ", ")
    }

    // MARK: ST-002

    /// Name, Owner, Guardian and Children. The Owner also sees the household name; each viewer
    /// sees "(you)" next to themselves.
    static func householdItems(household: SettingsHousehold, viewerRole: SettingsRole) -> [(key: String, value: String)] {
        var items: [(key: String, value: String)] = []
        if viewerRole == .owner { items.append((key: "Name", value: household.name)) }
        items.append((key: "Owner", value: viewerRole == .owner ? "\(household.owner.name) (you)" : household.owner.name))
        let guardianValue: String
        if let guardian = household.acceptedGuardian {
            guardianValue = viewerRole == .guardian ? "\(guardian.name) (you)" : guardian.name
        } else if let invite = household.pendingInvite {
            guardianValue = "\(invite.name) (invited)"
        } else {
            guardianValue = "None"
        }
        items.append((key: "Guardian", value: guardianValue))
        items.append((key: "Children", value: household.children.map { "\($0.firstName) (\($0.experience.rawValue))" }.joined(separator: ", ")))
        return items
    }

    /// The Owner's "Ownership" rows. Transfer needs an accepted Guardian.
    static func ownershipRows(household: SettingsHousehold) -> [SettingsRowModel] {
        let transfer: SettingsRowModel
        if let guardian = household.acceptedGuardian {
            transfer = SettingsRowModel(id: "transfer", title: "Transfer ownership", subtitle: "To \(guardian.name)", route: .transferOwnership)
        } else {
            transfer = SettingsRowModel(id: "transfer", title: "Transfer ownership", subtitle: SettingsCopy.inviteFirstTitle, route: .inviteGuardian)
        }
        return [transfer, SettingsRowModel(id: "leave", title: "Leave household", route: .leaveHousehold)]
    }

    // MARK: P-034

    /// "Sam’s iPhone · Verified 2 min ago · Protected". A child with no device shows that
    /// protection is not active yet.
    static func deviceRow(for child: ChildProfilePresentation, removal: DeviceRemovalState) -> SettingsRowModel {
        let avatar = SettingsAvatar(initial: child.initial, tone: child.tone)
        let id = "device-\(child.id)"
        guard let device = child.device else {
            return SettingsRowModel(
                id: id, title: "\(child.firstName)’s iPhone", subtitle: "Protection not active yet",
                route: .device(child.id), avatar: avatar, status: .notActiveYet
            )
        }
        switch removal {
        case .removeRequested, .removing:
            return SettingsRowModel(
                id: id, title: device.name, subtitle: SettingsCopy.removingSubtitle(device.name),
                route: .device(child.id), avatar: avatar, status: .removing
            )
        case .idle, .removed:
            return SettingsRowModel(
                id: id, title: device.name, subtitle: device.verifiedText,
                route: .device(child.id), avatar: avatar, status: device.status
            )
        }
    }
}
