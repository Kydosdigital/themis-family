import SwiftUI

// P-034 Children & devices, P-034 · Device and its removal states, P-032 Add another child,
// P-033 Edit child profile.
// Presentation only: no device command, no FamilyControls call, no unpairing, no data deleted.
// A child profile holds a first name and an experience (Child or Teen), nothing else.

/// P-034 Children & devices.
struct ChildrenAndDevicesView: View {
    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator

    var body: some View {
        SettingsPage(title: "Children & devices") {
            ForEach(model.household.children) { child in
                ThemisGroupedSection(child.title, data: rows(for: child)) { row in
                    SettingsRowView(row: row)
                }
            }

            if model.can(.addChild) {
                ThemisButton(title: "Add another child", systemImage: "plus", style: .secondary) {
                    navigator.push(.addChild)
                }
            }
        }
    }

    private func rows(for child: ChildProfilePresentation) -> [SettingsRowModel] {
        var rows = [
            SettingsPresentation.deviceRow(for: child, removal: model.removal(for: child.id)),
            SettingsRowModel(id: "edit-\(child.id)", title: "Edit profile", route: .editChild(child.id))
        ]
        if model.childRemoval[child.id] == .requested {
            rows.append(SettingsRowModel(id: "removal-\(child.id)", title: "Removal requested", status: .removing))
        }
        return rows
    }
}

/// P-034 · Device, then Removing, then Removed. Removing is a request waiting on the device; only
/// the device's acknowledgement makes it Removed.
struct DeviceDetailView: View {
    let childID: String

    @EnvironmentObject private var model: SettingsViewModel
    @EnvironmentObject private var navigator: SettingsNavigator
    @State private var showsRemoval: Bool

    init(childID: String, showsRemoval: Bool = false) {
        self.childID = childID
        _showsRemoval = State(initialValue: showsRemoval)
    }

    var body: some View {
        switch model.removal(for: childID) {
        case .removeRequested, .removing:
            removing
        case .removed:
            removed
        case .idle:
            detail
        }
    }

    private var child: ChildProfilePresentation? { model.household.child(id: childID) }
    private var deviceName: String { child?.device?.name ?? "\(child?.firstName ?? "Child")’s iPhone" }

    // MARK: Device

    private var detail: some View {
        SettingsPage(title: deviceName, ground: .plain) {
            if let device = child?.device {
                StatusHeader(status: device.status, explanation: device.explanation)
                KeyValueList(items: deviceItems(device))
                ThemisButton(title: "Check now", style: .secondary) {
                    // Inert: Settings sends no device command. Protection checks belong to the Protection slice.
                }
            } else {
                StatusHeader(
                    status: .notActiveYet,
                    explanation: "Pair a device to protect \(child?.firstName ?? "your child")."
                )
                ThemisButton(title: "Pair a device") { navigator.open(.pairDevice(childID: childID)) }
            }
        } bottom: {
            if child?.device != nil && model.can(.removeChildDevice) {
                ThemisButton(title: "Remove this iPhone", style: .destructive) { showsRemoval = true }
            }
        }
        .themisConfirmationSheet(
            isPresented: $showsRemoval,
            title: SettingsCopy.removeDeviceTitle(deviceName),
            lines: [SettingsCopy.removeDeviceLine],
            confirmTitle: "Remove iPhone",
            isDestructive: true
        ) {
            Task { await model.requestDeviceRemoval(childID: childID) }
        }
    }

    private func deviceItems(_ device: ManagedDevicePresentation) -> [KeyValueList.Item] {
        var items: [KeyValueList.Item] = [.init("Last verified", device.lastVerified)]
        if let permission = device.applePermission { items.append(.init("Apple permission", permission)) }
        if let paired = device.paired { items.append(.init("Paired", paired)) }
        return items
    }

    // MARK: Removing (not a success state)

    private var removing: some View {
        SettingsPage(title: deviceName, ground: .plain) {
            ThemisCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text(SettingsCopy.removingTitle(deviceName))
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text(SettingsCopy.removingSubtitle(deviceName))
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                    StatusBadge(.removing)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
            }
            SettingsNote(text: SettingsCopy.removingNote)

            #if DEBUG
            // Review control only: stands in for the device's confirmation, which a real
            // repository would deliver. Not compiled into Release.
            ThemisButton(title: "Simulate device confirmation", style: .tertiary) {
                model.acknowledgeDeviceRemoval(childID: childID)
            }
            #endif
        }
    }

    // MARK: Removed (acknowledged)

    private var removed: some View {
        SettingsPage(title: deviceName, ground: .plain) {
            InlineBanner(.success, SettingsCopy.removedTitle(deviceName))
            SettingsNote(text: SettingsCopy.removedNote(child?.firstName ?? "Your child"))
        } bottom: {
            ThemisButton(title: "Pair a device") { navigator.open(.pairDevice(childID: childID)) }
            ThemisButton(title: "Done", style: .secondary) { navigator.pop(toRoute: .childrenAndDevices) }
        }
    }
}

/// How a child experience is described, shared by P-032 and P-033.
struct ExperienceChoiceCard: View {
    let segment: ExperienceSegment
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ThemisCard(isSelected: isSelected) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(segment.rawValue)
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text(segment == .child ? SettingsCopy.childExperienceDetail : SettingsCopy.teenExperienceDetail)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// P-032 Add another child. First name, then Child or Teen. No date of birth, no age.
struct AddChildView: View {
    enum Step {
        case name
        case experience
    }

    @EnvironmentObject private var model: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: NewChildDraft
    @State private var step: Step

    init(initialDraft: NewChildDraft = NewChildDraft(), initialStep: Step = .name) {
        _draft = State(initialValue: initialDraft)
        _step = State(initialValue: initialStep)
    }

    var body: some View {
        SettingsPage(title: "Add a child", ground: .plain) {
            switch step {
            case .name:
                SettingsTitle(text: "Who are we adding?")
                ReasonField(
                    label: "First name",
                    text: $draft.firstName,
                    prompt: "First name",
                    helper: SettingsCopy.firstNameHelper,
                    lineLimit: 1...1
                )
            case .experience:
                SettingsTitle(text: "Which experience suits \(draft.trimmedName)?")
                ExperienceChoiceCard(segment: .child, isSelected: draft.experience == .child) { draft.experience = .child }
                ExperienceChoiceCard(segment: .teen, isSelected: draft.experience == .teen) { draft.experience = .teen }
                SettingsNote(text: SettingsCopy.experiencePrinciple)
            }
        } bottom: {
            switch step {
            case .name:
                ThemisButton(title: "Continue", isDisabled: draft.trimmedName.isEmpty) { step = .experience }
            case .experience:
                ThemisButton(title: "Add \(draft.trimmedName)", isDisabled: !draft.isComplete) {
                    Task {
                        if await model.addChild(draft) { dismiss() }
                    }
                }
            }
        }
    }
}

/// P-033 Edit child profile. Editable: first name and Child or Teen. Removing a child is a
/// request, and a paired device is not claimed unbound.
struct EditChildView: View {
    let child: ChildProfilePresentation

    @EnvironmentObject private var model: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var experience: ExperienceSegment
    @State private var showsRemoval: Bool

    init(child: ChildProfilePresentation, showsRemoval: Bool = false) {
        self.child = child
        _name = State(initialValue: child.firstName)
        _experience = State(initialValue: child.experience)
        _showsRemoval = State(initialValue: showsRemoval)
    }

    var body: some View {
        SettingsPage(title: child.firstName, ground: .plain) {
            ReasonField(label: "First name", text: $name, prompt: "First name", lineLimit: 1...1)
            ExperienceChoiceCard(segment: .child, isSelected: experience == .child) { experience = .child }
            ExperienceChoiceCard(segment: .teen, isSelected: experience == .teen) { experience = .teen }
            SettingsNote(text: SettingsCopy.experienceChangeNote(child.firstName))
        } bottom: {
            if model.can(.removeChild) {
                ThemisButton(title: "Remove \(child.firstName) from household", style: .destructive) {
                    showsRemoval = true
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        if await model.saveChild(id: child.id, firstName: name, experience: experience) { dismiss() }
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .themisConfirmationSheet(
            isPresented: $showsRemoval,
            title: SettingsCopy.removeChildTitle(child.firstName),
            lines: [SettingsCopy.removeChildLine(child.firstName)],
            confirmTitle: "Remove \(child.firstName)",
            isDestructive: true
        ) {
            Task {
                if await model.removeChild(id: child.id) { dismiss() }
            }
        }
    }
}

#if DEBUG
// MARK: - Previews (deterministic)

#Preview("P-034 · Children & devices") {
    SettingsPreviewHost(.owner) { ChildrenAndDevicesView() }
}

#Preview("P-034 · Device") {
    SettingsPreviewHost(.owner) { DeviceDetailView(childID: "sam") }
}

#Preview("P-034 · Device · AX3") {
    SettingsPreviewHost(.owner) { DeviceDetailView(childID: "sam") }
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("P-034 · Remove") {
    SettingsPreviewHost(.owner) { DeviceDetailView(childID: "sam", showsRemoval: true) }
}

#Preview("P-034 · Removing") {
    SettingsPreviewHost(model: removalModel(.removing)) { DeviceDetailView(childID: "sam") }
}

#Preview("P-034 · Removed") {
    SettingsPreviewHost(model: removalModel(.removed)) { DeviceDetailView(childID: "sam") }
}

#Preview("P-032 · Add child") {
    SettingsPreviewHost(.owner) { AddChildView(initialDraft: NewChildDraft(firstName: "Leo")) }
}

#Preview("P-032 · Add child · experience") {
    SettingsPreviewHost(.owner) {
        AddChildView(initialDraft: NewChildDraft(firstName: "Leo", experience: .child), initialStep: .experience)
    }
}

#Preview("P-033 · Edit child") {
    SettingsPreviewHost(.owner) { EditChildView(child: SettingsDemoData.sam) }
}

#Preview("P-033 · Remove") {
    SettingsPreviewHost(.owner) { EditChildView(child: SettingsDemoData.sam, showsRemoval: true) }
}

/// A model already in a removal state, for previews.
@MainActor
private func removalModel(_ state: DeviceRemovalState) -> SettingsViewModel {
    let model = SettingsViewModel(state: SettingsDemoData.state(for: .owner))
    model.setDeviceRemovalForPreview(childID: "sam", state: state)
    return model
}
#endif
