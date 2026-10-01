import SwiftUI

// ST-005 Notifications and ST-006 Privacy & transparency.
// Local values only: no APNs, no notification permission request, nothing stored.

/// ST-005 Notifications. Notifications show a name and an event only; reasons, notes and details
/// open inside the unlocked app.
struct NotificationsView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        SettingsPage(title: "Notifications") {
            ThemisGroupedSection(SettingsCopy.notificationsSection, data: model.notifications) { preference in
                Toggle(isOn: binding(for: preference.id)) {
                    Text(preference.title)
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                }
                .tint(ThemisColor.brandPrimary)
                .padding(.vertical, ThemisSpacing.rowVertical)
                .padding(.horizontal, ThemisSpacing.rowHorizontal)
                .frame(minHeight: ThemisSize.tapMinimum)
            }
            SettingsNote(text: SettingsCopy.notificationsPrivacyNote)
            SettingsNote(text: SettingsCopy.notificationsLimitsNote)
        }
    }

    private func binding(for id: String) -> Binding<Bool> {
        Binding(
            get: { model.notifications.first { $0.id == id }?.isOn ?? false },
            set: { newValue in
                if let index = model.notifications.firstIndex(where: { $0.id == id }) {
                    model.notifications[index].isOn = newValue
                }
            }
        )
    }
}

/// ST-006 Privacy & transparency. What Themis keeps, how long, and what it never has. Apple's
/// Screen Time reports are shown by Apple and never stored by Themis. Retention periods are
/// subject to final legal review.
struct PrivacyView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        SettingsPage(title: "Privacy") {
            SectionHeader(title: SettingsCopy.privacyKeepsHeading)
            KeyValueList(
                items: [
                    .init(SettingsCopy.structuredHistoryRetention.label, SettingsCopy.structuredHistoryRetention.period),
                    .init(SettingsCopy.freeTextRetention.label, SettingsCopy.freeTextRetention.period),
                    .init(SettingsCopy.auditLogRetention.label, SettingsCopy.auditLogRetention.period)
                ]
            )

            SectionHeader(title: SettingsCopy.privacyNeverHeading)
            ChecklistList(
                items: [
                    .init(.no, SettingsCopy.neverHasAppUsage),
                    .init(.no, SettingsCopy.neverHasMessagesAndHistory)
                ]
            )

            SettingsNote(text: SettingsCopy.privacyFooter)

            ThemisGroupedSection(data: childRows) { row in
                SettingsRowView(row: row)
            }
        }
    }

    /// "What Sam sees" opens the child's own transparency screen (C-013), owned by another slice.
    private var childRows: [SettingsRowModel] {
        model.household.children.map { child in
            SettingsRowModel(
                id: "sees-\(child.id)",
                title: "What \(child.firstName) sees",
                route: .external(.childTransparency(childID: child.id))
            )
        }
    }
}

// MARK: - Previews (deterministic)

#Preview("ST-005 · Notifications") {
    SettingsPreviewHost(.owner) { NotificationsView() }
}

#Preview("ST-006 · Privacy") {
    SettingsPreviewHost(.owner) { PrivacyView() }
}

#Preview("ST-006 · Privacy · AX3") {
    SettingsPreviewHost(.owner) { PrivacyView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}
