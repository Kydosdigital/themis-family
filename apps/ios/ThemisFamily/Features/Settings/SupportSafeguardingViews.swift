import SwiftUI

// ST-007 Support (and Diagnose, Resync, Contact, Sent) and ST-008 Safeguarding help.
// Presentation only: no network request, no support ticket, no real resync.
// Support diagnoses and guides. It never acts as the parent: it cannot change rules, approve or
// decline anything, grant Free Passes, change restrictions, impersonate a parent or rewrite billing.
// Safeguarding is a separate path. Its owner, procedure and contact details are not decided, so
// none are shown.

/// ST-007 Support.
struct SupportView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator

    var body: some View {
        SettingsPage(title: "Support") {
            Text(SettingsCopy.supportIntro)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            ThemisGroupedSection("Fix a problem", data: fixRows) { row in
                SettingsRowView(row: row)
            }

            ThemisButton(title: "Contact support", style: .secondary) { navigator.push(.contactSupport) }

            ThemisGroupedSection(data: safeguardingRows) { row in
                SettingsRowView(row: row)
            }
        }
    }

    private var fixRows: [SettingsRowModel] {
        let firstChild = model.household.children.first?.id ?? "sam"
        let canSeeBilling = model.can(.manageSubscription)
        return [
            SettingsRowModel(id: "rule", title: "A rule isn’t working", subtitle: "Check a device", route: .diagnose(firstChild)),
            // Billing is the Owner's. A Guardian sees the row, labelled, and cannot open it.
            SettingsRowModel(
                id: "billing", title: "Billing question", subtitle: "See your App Store status",
                value: canSeeBilling ? nil : "Owner only",
                route: .external(.subscriptionSettings), isOwnerOnlyLocked: !canSeeBilling
            ),
            // Inert: Settings makes no StoreKit call.
            SettingsRowModel(id: "restore", title: "Restore purchases")
        ]
    }

    private var safeguardingRows: [SettingsRowModel] {
        [
            SettingsRowModel(
                id: "safeguarding", title: "Worried about a child’s safety?",
                subtitle: "Safeguarding help is separate", route: .safeguarding
            )
        ]
    }
}

/// ST-007 · Diagnose, then Resync (sheet) and Resync sent. A resync is a request that restores
/// what the parent already set; support never makes a new decision.
struct DiagnoseDeviceView: View {
    let childID: String

    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var showsResync: Bool

    init(childID: String, showsResync: Bool = false) {
        self.childID = childID
        _showsResync = State(initialValue: showsResync)
    }

    var body: some View {
        if model.resyncRequested.contains(childID) {
            resyncSent
        } else {
            diagnosis
        }
    }

    private var child: ChildProfilePresentation? { model.household.child(id: childID) }
    private var deviceName: String { child?.device?.name ?? "\(child?.firstName ?? "Your child")’s iPhone" }

    private var diagnosis: some View {
        SettingsPage(title: "Check \(deviceName)", ground: .plain) {
            ChecklistList(
                items: [
                    .init(.yes, "Paired to your household"),
                    .init(.yes, "Last sync \(child?.device?.lastVerified ?? "unknown")")
                ]
            )

            // The frame's example finding: Apple permission turned off on Sam's iPhone.
            if childID == SettingsDemoData.sam.id {
                ThemisCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apple permission")
                            .themisFont(.rowTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text("Turned off on \(deviceName)")
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                        StatusBadge(.needsAttention)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                }
                ThemisButton(title: "Fix this") { navigator.open(.fixProtection(childID: childID)) }
            }

            ThemisButton(title: "Ask support to resync this iPhone", style: .tertiary) { showsResync = true }
                .frame(maxWidth: .infinity)
        }
        .themisConfirmationSheet(
            isPresented: $showsResync,
            title: SettingsCopy.resyncSheetTitle(deviceName),
            lines: [SettingsCopy.resyncSheetLine(deviceName)],
            confirmTitle: "Request resync"
        ) {
            Task { await model.requestResync(childID: childID) }
        }
    }

    /// "Requested", not "Applying": Settings does not know the device is re-applying anything.
    private var resyncSent: some View {
        SettingsPage(title: "Check \(deviceName)", ground: .plain) {
            ThemisCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resync requested")
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text(SettingsCopy.resyncRequestedSubtitle(deviceName))
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                    StatusBadge(ThemisStatus(.applying, label: "Requested"))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
            }
            SettingsNote(text: SettingsCopy.resyncRequestedNote)
        }
    }
}

/// ST-007 · Contact, then Sent. Support sees device and sync status for this issue only.
struct ContactSupportView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var message: String

    init(initialMessage: String = "") {
        _message = State(initialValue: initialMessage)
    }

    var body: some View {
        if model.supportMessageSent {
            sent
        } else {
            form
        }
    }

    private var form: some View {
        SettingsPage(title: "Contact support", ground: .plain) {
            ReasonField(label: "What’s happening?", text: $message, prompt: "Describe the problem")
            SettingsNote(text: SettingsCopy.supportContactNote)
        } bottom: {
            ThemisButton(
                title: "Send",
                isDisabled: message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
                Task { await model.sendSupportMessage(message) }
            }
        }
    }

    private var sent: some View {
        SettingsPage(title: "Contact support", ground: .plain) {
            InlineBanner(.success, "Sent to support")
            SettingsNote(text: SettingsCopy.supportSentNote)
        } bottom: {
            ThemisButton(title: "Done", style: .secondary) {
                model.resetSupportMessage()
                navigator.popToRoot()
            }
        }
    }
}

/// ST-008 Safeguarding help. Calm and serious. The report action stays unavailable until the
/// safeguarding owner and procedure exist, and no contact, name or response time is invented.
struct SafeguardingView: View {
    var body: some View {
        SettingsPage(title: "Safeguarding help", ground: .plain) {
            SettingsTitle(text: SettingsCopy.safeguardingTitle)
            InlineBanner(.warning, SettingsCopy.safeguardingEmergency)
            Text(SettingsCopy.safeguardingBody)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            SettingsNote(text: SettingsCopy.safeguardingPrivacy)
        } bottom: {
            ThemisButton(title: SettingsCopy.safeguardingAction, isDisabled: !SafeguardingPlaceholder.hasOperationalContact) {}
            Text(SettingsCopy.safeguardingPending)
                .themisFont(.meta)
                .foregroundStyle(ThemisColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
// MARK: - Previews (deterministic)

#Preview("ST-007 · Support") {
    SettingsPreviewHost(.owner) { SupportView() }
}

#Preview("ST-007 · Diagnose") {
    SettingsPreviewHost(.owner) { DiagnoseDeviceView(childID: "sam") }
}

#Preview("ST-007 · Resync") {
    SettingsPreviewHost(.owner) { DiagnoseDeviceView(childID: "sam", showsResync: true) }
}

#Preview("ST-007 · Resync sent") {
    SettingsPreviewHost(model: resyncModel) { DiagnoseDeviceView(childID: "sam") }
}

#Preview("ST-007 · Contact") {
    SettingsPreviewHost(.owner) { ContactSupportView(initialMessage: SettingsDemoData.sampleSupportMessage) }
}

#Preview("ST-007 · Sent") {
    SettingsPreviewHost(model: sentModel) { ContactSupportView() }
}

#Preview("ST-008 · Safeguarding") {
    SettingsPreviewHost(.owner) { SafeguardingView() }
}

#Preview("ST-008 · Safeguarding · AX3") {
    SettingsPreviewHost(.owner) { SafeguardingView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}

@MainActor
private var resyncModel: SettingsViewModel {
    let model = SettingsViewModel(state: SettingsDemoData.state(for: .owner))
    model.markResyncRequestedForPreview(childID: "sam")
    return model
}

@MainActor
private var sentModel: SettingsViewModel {
    let model = SettingsViewModel(state: SettingsDemoData.state(for: .owner))
    model.markSupportMessageSentForPreview()
    return model
}
#endif
