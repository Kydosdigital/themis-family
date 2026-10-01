import SwiftUI

// ST-010 Transfer ownership (Confirm, Done, Leave, No Guardian, Leave now), ST-011 Delete
// household (Confirm, Done) and ST-012 Account (Sign out).
// Presentation only. Nothing is transferred, deleted, cleared, cancelled or signed out for real:
// no StoreKit call, no deletion sequencing, no session revocation. Ownership never moves to a
// child or to someone not yet an accepted Guardian, and a household never has no Owner.

/// ST-010 Transfer ownership. Only the Owner, only to the accepted Guardian, in one step.
struct TransferOwnershipView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var showsConfirm: Bool

    init(showsConfirm: Bool = false) {
        _showsConfirm = State(initialValue: showsConfirm)
    }

    var body: some View {
        if let target = model.household.acceptedGuardian, model.can(.transferOwnership) {
            transfer(to: target)
        } else {
            unavailable
        }
    }

    private func transfer(to target: HouseholdMemberPresentation) -> some View {
        SettingsPage(title: "Transfer ownership", ground: .plain) {
            SettingsTitle(text: SettingsCopy.transferTitle(target.name))
            Text(SettingsCopy.transferBody(target.name))
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            KeyValueList(
                items: [
                    .init("You lose", SettingsCopy.transferLoses),
                    .init("You keep", SettingsCopy.transferKeeps)
                ]
            )
        } bottom: {
            ThemisButton(title: "Transfer to \(target.name)") { showsConfirm = true }
        }
        .themisConfirmationSheet(
            isPresented: $showsConfirm,
            title: SettingsCopy.transferSheetTitle(target.name),
            lines: [SettingsCopy.transferSheetLine(target.name)],
            confirmTitle: "Transfer ownership"
        ) {
            Task {
                if await model.transferOwnership() {
                    navigator.replaceTop(with: .ownershipTransferred)
                }
            }
        }
    }

    /// No accepted Guardian, or not the Owner: transfer is unavailable.
    private var unavailable: some View {
        SettingsPage(title: "Transfer ownership", ground: .plain) {
            if model.can(.transferOwnership) {
                InlineBanner(.info, SettingsCopy.noGuardianInfo)
                SettingsChoiceCard(title: SettingsCopy.inviteFirstTitle, subtitle: SettingsCopy.inviteFirstSubtitle) {
                    navigator.push(.inviteGuardian)
                }
            } else {
                InlineBanner(.info, SettingsCopy.ownerOnlyBanner(ownerName: model.household.owner.name))
            }
        }
    }
}

/// ST-010 · Done, with the Leave now sheet. The roles have swapped: the former Owner is a Guardian.
struct OwnershipTransferredView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var showsLeave: Bool

    init(showsLeave: Bool = false) {
        _showsLeave = State(initialValue: showsLeave)
    }

    var body: some View {
        let household = model.household

        SettingsPage(title: "Ownership", ground: .plain) {
            InlineBanner(.success, SettingsCopy.transferredTitle(household.owner.name))
            SettingsNote(text: SettingsCopy.transferredNote(household: household.name))
        } bottom: {
            ThemisButton(title: "Leave household", style: .secondary) { showsLeave = true }
            ThemisButton(title: "Done", style: .secondary) { navigator.popToRoot() }
        }
        .themisConfirmationSheet(
            isPresented: $showsLeave,
            title: SettingsCopy.leaveNowTitle(household: household.name),
            lines: [SettingsCopy.leaveNowLine(household.owner.name)],
            confirmTitle: "Leave",
            isDestructive: true
        ) {
            Task {
                if await model.leaveHousehold() {
                    navigator.open(.welcome)
                }
            }
        }
    }
}

/// ST-010 · Leave (a Guardian exists) and ST-010 · No Guardian. An Owner has exactly two ways to
/// leave: transfer then leave, or delete the household. Without an accepted Guardian only
/// deleting remains, and transfer is unavailable.
struct LeaveHouseholdView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator

    var body: some View {
        let household = model.household

        SettingsPage(title: "Leave household") {
            SettingsTitle(text: SettingsCopy.leaveTitle)

            if let guardian = household.acceptedGuardian {
                SettingsNote(text: SettingsCopy.leaveChoose)
                SettingsChoiceCard(title: "Transfer ownership, then leave", subtitle: "To \(guardian.name), your Guardian") {
                    navigator.push(.transferOwnership)
                }
            } else {
                InlineBanner(.info, SettingsCopy.noGuardianInfo)
                SettingsChoiceCard(title: SettingsCopy.inviteFirstTitle, subtitle: SettingsCopy.inviteFirstSubtitle) {
                    navigator.push(.inviteGuardian)
                }
            }

            if model.can(.deleteHousehold) {
                SettingsChoiceCard(title: SettingsCopy.deleteCardTitle, subtitle: SettingsCopy.deleteCardSubtitle) {
                    navigator.push(.deleteHousehold)
                }
            }

            SettingsNote(text: SettingsCopy.leaveRule)
        }
    }
}

/// ST-011 Delete household, with the typed DELETE field and the final confirmation. Owner only,
/// destructive and irreversible. It says the App Store subscription is not cancelled
/// automatically. Nothing is deleted here.
struct DeleteHouseholdView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var typed: String
    @State private var showsFinal: Bool

    init(typed: String = "", showsFinal: Bool = false) {
        _typed = State(initialValue: typed)
        _showsFinal = State(initialValue: showsFinal)
    }

    var body: some View {
        let household = model.household
        let names = household.children.map(\.firstName)

        SettingsPage(title: "Delete household", ground: .plain) {
            if model.can(.deleteHousehold) {
                SettingsTitle(text: SettingsCopy.deleteTitle(household: household.name))
                Text(SettingsCopy.deleteBody(childNames: names))
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                SettingsNote(text: SettingsCopy.deleteSubscriptionNote)
                ReasonField(
                    label: SettingsCopy.deleteFieldLabel,
                    text: $typed,
                    prompt: DeleteConfirmation.phrase,
                    lineLimit: 1...1
                )
            } else {
                InlineBanner(.info, SettingsCopy.ownerOnlyBanner(ownerName: household.owner.name))
            }
        } bottom: {
            if model.can(.deleteHousehold) {
                ThemisButton(
                    title: "Delete household",
                    style: .destructive,
                    isDisabled: !DeleteConfirmation.isSatisfied(by: typed)
                ) {
                    showsFinal = true
                }
            }
        }
        .themisConfirmationSheet(
            isPresented: $showsFinal,
            title: SettingsCopy.deleteFinalTitle,
            lines: [SettingsCopy.deleteFinalLine(childNames: names)],
            confirmTitle: "Delete household",
            isDestructive: true
        ) {
            Task {
                if await model.deleteHousehold(typed: typed) {
                    navigator.replaceTop(with: .householdDeleted)
                }
            }
        }
    }
}

/// ST-011 · Done. Restrictions are described as being removed as devices connect; Settings has
/// not removed anything.
struct HouseholdDeletedView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator

    var body: some View {
        let names = model.household.children.map(\.firstName)

        SettingsPage(title: "Household deleted", ground: .plain) {
            InlineBanner(.success, "Household deleted")
            SettingsNote(text: SettingsCopy.deletedNote(childNames: names))
        } bottom: {
            ThemisButton(title: "Done", style: .secondary) { navigator.open(.welcome) }
        }
    }
}

/// ST-012 Account, with the Sign out confirmation. Presentation only: no authentication call and
/// no claim that a session or token was revoked.
struct AccountView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var showsSignOut: Bool

    init(showsSignOut: Bool = false) {
        _showsSignOut = State(initialValue: showsSignOut)
    }

    var body: some View {
        let household = model.household
        let otherParent = model.viewerRole == .owner ? household.acceptedGuardian?.name : household.owner.name

        SettingsPage(title: "Account") {
            KeyValueList(
                items: [
                    .init("Signed in with", "Apple"),
                    .init("Role", model.viewerRole.title)
                ]
            )
            ThemisButton(title: "Sign out", style: .secondary) { showsSignOut = true }
        }
        .themisConfirmationSheet(
            isPresented: $showsSignOut,
            title: SettingsCopy.signOutTitle,
            lines: [SettingsCopy.signOutLine(otherParent: otherParent)],
            confirmTitle: "Sign out"
        ) {
            Task {
                if await model.signOut() {
                    navigator.open(.welcome)
                }
            }
        }
    }
}

// MARK: - Previews (deterministic)

#Preview("ST-010 · Transfer") {
    SettingsPreviewHost(.owner) { TransferOwnershipView() }
}

#Preview("ST-010 · Confirm") {
    SettingsPreviewHost(.owner) { TransferOwnershipView(showsConfirm: true) }
}

#Preview("ST-010 · Confirm · AX3") {
    SettingsPreviewHost(.owner) { TransferOwnershipView(showsConfirm: true) }
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("ST-010 · Done") {
    SettingsPreviewHost(.ownerAfterTransfer) { OwnershipTransferredView() }
}

#Preview("ST-010 · Leave now") {
    SettingsPreviewHost(.ownerAfterTransfer) { OwnershipTransferredView(showsLeave: true) }
}

#Preview("ST-010 · Leave") {
    SettingsPreviewHost(.owner) { LeaveHouseholdView() }
}

#Preview("ST-010 · No Guardian") {
    SettingsPreviewHost(.ownerNoGuardian) { LeaveHouseholdView() }
}

#Preview("ST-011 · Delete") {
    SettingsPreviewHost(.owner) { DeleteHouseholdView() }
}

#Preview("ST-011 · Delete · AX3") {
    SettingsPreviewHost(.owner) { DeleteHouseholdView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("ST-011 · Confirm") {
    SettingsPreviewHost(.owner) { DeleteHouseholdView(typed: DeleteConfirmation.phrase, showsFinal: true) }
}

#Preview("ST-011 · Confirm · AX3") {
    SettingsPreviewHost(.owner) { DeleteHouseholdView(typed: DeleteConfirmation.phrase, showsFinal: true) }
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("ST-011 · Done") {
    SettingsPreviewHost(.owner) { HouseholdDeletedView() }
}

#Preview("ST-012 · Account") {
    SettingsPreviewHost(.owner) { AccountView() }
}

#Preview("ST-012 · Sign out") {
    SettingsPreviewHost(.owner) { AccountView(showsSignOut: true) }
}
