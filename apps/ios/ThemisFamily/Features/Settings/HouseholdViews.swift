import SwiftUI

// ST-002 Household, ST-003 Guardian, ST-004 Invite Guardian.
// Presentation only: no email is sent, no invitation or membership is created, nothing changes
// on a server.

/// ST-002 Household. Owner sees the household name and the Ownership rows with Delete household;
/// a Guardian sees the facts and a banner that these actions are the Owner's.
struct HouseholdView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator

    var body: some View {
        let household = model.household
        let role = model.viewerRole
        let items = SettingsPresentation.householdItems(household: household, viewerRole: role)

        SettingsPage(title: "Household") {
            KeyValueList(items: items.map { KeyValueList.Item($0.key, $0.value) })

            if role == .owner {
                ThemisGroupedSection("Ownership", data: SettingsPresentation.ownershipRows(household: household)) { row in
                    SettingsRowView(row: row)
                }
                if model.can(.deleteHousehold) {
                    ThemisButton(title: "Delete household", style: .destructive) {
                        navigator.push(.deleteHousehold)
                    }
                }
            } else {
                InlineBanner(.info, SettingsCopy.ownerOnlyBanner(ownerName: household.owner.name))
            }
        }
    }
}

/// ST-003 Guardian. Only the Owner can remove the Guardian. Removing does not cancel anything
/// waiting, change ownership or touch rules.
struct GuardianView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var showsRemoval: Bool

    init(showsRemoval: Bool = false) {
        _showsRemoval = State(initialValue: showsRemoval)
    }

    var body: some View {
        let guardian = model.household.acceptedGuardian
        let name = guardian?.name ?? "Guardian"

        SettingsPage(title: "Guardian") {
            if let guardian {
                ThemisCard {
                    HStack(spacing: ThemisSpacing.inline12) {
                        AvatarTile(initial: guardian.initial, tone: .mint, size: .large)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(guardian.name)
                                .themisFont(.rowTitle)
                                .foregroundStyle(ThemisColor.textPrimary)
                            Text(joinedText(guardian))
                                .themisFont(.meta)
                                .foregroundStyle(ThemisColor.textSecondary)
                            StatusBadge(ThemisStatus(.active, label: "Joined"))
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .accessibilityElement(children: .combine)
                }

                KeyValueList(
                    items: [
                        .init("Can", SettingsCopy.guardianCan),
                        .init("Can’t", SettingsCopy.guardianCannot)
                    ]
                )

                if !model.can(.removeGuardian) {
                    InlineBanner(.info, SettingsCopy.ownerOnlyBanner(ownerName: model.household.owner.name))
                }
            } else {
                EmptyStateView(title: "No Guardian", systemImage: "person.2")
                ThemisButton(title: "Invite a Guardian") { navigator.push(.inviteGuardian) }
            }
        } bottom: {
            if guardian != nil && model.can(.removeGuardian) {
                ThemisButton(title: "Remove \(name) as Guardian", style: .destructive) {
                    showsRemoval = true
                }
            }
        }
        .themisConfirmationSheet(
            isPresented: $showsRemoval,
            title: SettingsCopy.removeGuardianTitle(name),
            lines: [SettingsCopy.removeGuardianLine(name)],
            confirmTitle: "Remove \(name)",
            isDestructive: true
        ) {
            Task {
                if await model.removeGuardian() {
                    // The approved flow continues to Invite Guardian.
                    navigator.replaceTop(with: .inviteGuardian)
                }
            }
        }
    }

    private func joinedText(_ guardian: HouseholdMemberPresentation) -> String {
        guardian.joined.map { "Guardian · joined \($0)" } ?? "Guardian"
    }
}

/// ST-004 Invite Guardian, and ST-004 · Sent. One Guardian per household: with a Guardian already
/// in place there is no second invitation, and a pending invite fills the slot.
struct InviteGuardianView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @State private var contact: String

    init(initialContact: String = "") {
        _contact = State(initialValue: initialContact)
    }

    var body: some View {
        let household = model.household

        if let invite = household.pendingInvite {
            sent(invite.name)
        } else if !household.canInviteGuardian {
            blocked
        } else {
            form
        }
    }

    private var form: some View {
        SettingsPage(title: "Guardian", ground: .plain) {
            SettingsTitle(text: "Invite a Guardian")
            SettingsNote(text: SettingsCopy.inviteIntro)
            ReasonField(
                label: SettingsCopy.inviteFieldLabel,
                text: $contact,
                prompt: "name@example.com",
                lineLimit: 1...1
            )
        } bottom: {
            if model.can(.inviteGuardian) {
                ThemisButton(
                    title: "Send invite",
                    isDisabled: contact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ) {
                    Task { await model.inviteGuardian(contact: contact) }
                }
            } else {
                InlineBanner(.info, SettingsCopy.ownerOnlyBanner(ownerName: model.household.owner.name))
            }
        }
    }

    private func sent(_ name: String) -> some View {
        SettingsPage(title: "Guardian", ground: .plain) {
            ThemisCard {
                HStack(alignment: .top, spacing: ThemisSpacing.inline12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Invite sent to \(name)")
                            .themisFont(.rowTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text("Waiting for \(name) to accept")
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                        StatusBadge(.pending)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }
            SettingsNote(text: SettingsCopy.inviteSentNote)
        } bottom: {
            if model.can(.inviteGuardian) {
                ThemisButton(title: "Cancel invite", style: .secondary) {
                    Task { await model.cancelGuardianInvite() }
                }
            }
        }
    }

    private var blocked: some View {
        SettingsPage(title: "Guardian", ground: .plain) {
            SettingsTitle(text: "Invite a Guardian")
            InlineBanner(.info, SettingsCopy.guardianSlotTaken)
        }
    }
}

// MARK: - Previews (deterministic)

#Preview("ST-002 · Household · Owner") {
    SettingsPreviewHost(.owner) { HouseholdView() }
}

#Preview("ST-002 · Household · Guardian") {
    SettingsPreviewHost(.guardian) { HouseholdView() }
}

#Preview("ST-003 · Guardian") {
    SettingsPreviewHost(.owner) { GuardianView() }
}

#Preview("ST-003 · Remove") {
    SettingsPreviewHost(.owner) { GuardianView(showsRemoval: true) }
}

#Preview("ST-004 · Invite") {
    SettingsPreviewHost(.ownerNoGuardian) { InviteGuardianView(initialContact: "alex@example.com") }
}

#Preview("ST-004 · Sent") {
    SettingsPreviewHost(.ownerPendingInvite) { InviteGuardianView() }
}
