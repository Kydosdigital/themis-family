import SwiftUI

struct RulesSchoolAccessView: View {
    enum InitialSection {
        case rules
        case schoolAccess
    }

    @State private var rules = [RulesSchoolAccessDemoData.scheduled, RulesSchoolAccessDemoData.deadlineLock, RulesSchoolAccessDemoData.earnFirst, RulesSchoolAccessDemoData.pendingSync]
    @State private var alwaysAllowed = AlwaysAllowedState(targets: [RulesSchoolAccessDemoData.schoolPortal], disclosure: nil)
    @State private var showingSchoolAccess: Bool
    @State private var showingCreate = false

    init(initialSection: InitialSection = .rules) {
        _showingSchoolAccess = State(initialValue: initialSection == .schoolAccess)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "Rules", subtitle: "Clear agreements for each child")
                rulesSection
                AlwaysAllowedCard(state: alwaysAllowed)
                Button { showingSchoolAccess = true } label: {
                    ThemisRow(title: "School Access", subtitle: "School essentials available, entertainment limited", isLink: true, showsChevron: true)
                }
                .buttonStyle(.plain)
                .background(ThemisColor.surface, in: RoundedRectangle(cornerRadius: 16))
                Button { showingCreate = true } label: {
                    Label("Create rule", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.bottom, ThemisSpacing.block)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingCreate) { RuleEditorView() }
        .navigationDestination(isPresented: $showingSchoolAccess) { SchoolAccessView(state: RulesSchoolAccessDemoData.schoolAccess) }
    }

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            SectionHeader(title: "Family rules")
            ForEach(rules) { rule in
                ThemisCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(rule.title).themisFont(.rowTitle)
                            Spacer()
                            Text(rule.syncState.rawValue)
                                .themisFont(.meta)
                                .foregroundStyle(rule.syncState == .pendingSync ? ThemisColor.textDestructive : ThemisColor.textSecondary)
                        }
                        Text("\(rule.childName) · \(rule.type.rawValue)")
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                        Text(rule.targets.map(\.name).joined(separator: ", "))
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

struct AlwaysAllowedCard: View {
    let state: AlwaysAllowedState

    var body: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Always Allowed", systemImage: "checkmark.shield")
                    .themisFont(.headline)
                Text("These stay available even when another rule would restrict them.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                ForEach(state.targets) { target in
                    Text(target.name).themisFont(.rowTitle)
                }
                if let disclosure = state.disclosure {
                    Text(disclosure)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
                Text(RulesSchoolAccessPolicy.emergencyAccessMessage)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
    }
}

struct RuleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var child = "Sam"
    @State private var type: RuleType = .scheduled
    @State private var title = ""
    @State private var verification: RuleVerificationType = .parentApproval
    @State private var rewardMinutes = 45

    var body: some View {
        NavigationStack {
            Form {
                Section("Who") { Picker("Child", selection: $child) { Text("Sam").tag("Sam"); Text("Maya").tag("Maya") } }
                Section("Rule") {
                    Picker("Type", selection: $type) {
                        ForEach(RuleType.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Rule name", text: $title)
                }
                Section("Controls") {
                    Button("Choose apps, websites or categories") { }
                    Text("Selection is completed in Apple’s system-owned picker.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if type == .deadlineLock {
                    Section("Condition") {
                        Picker("Verification", selection: $verification) { Text("Parent Approval").tag(RuleVerificationType.parentApproval) }
                        Text("A submission made before the deadline has a 30-minute approval grace period. Rejection or grace expiry activates the lock.")
                            .font(.footnote)
                    }
                }
                if type == .earnFirst {
                    Section("Reward") {
                        Stepper("\(rewardMinutes) minutes access", value: $rewardMinutes, in: 5...180, step: 5)
                        Text("The reward duration is fixed when this rule is saved.")
                            .font(.footnote)
                    }
                }
                Section("Review") {
                    Text("Saving while the child device is offline shows Pending sync until the device receives the rule.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Create rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { dismiss() }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
            }
        }
    }
}

struct SchoolAccessView: View {
    let state: SchoolAccessState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "School Access", subtitle: "Keep school essentials available during school hours")
                ThemisCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("School essentials").themisFont(.headline)
                        ForEach(state.schoolTargets) { Text($0.name).themisFont(.rowTitle) }
                        Text("Chosen school apps and sites are Always Allowed.")
                            .themisFont(.meta).foregroundStyle(ThemisColor.textSecondary)
                    }
                }
                ThemisCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Entertainment during school hours").themisFont(.headline)
                        Text(state.entertainmentTargets.map(\.name).joined(separator: ", "))
                            .themisFont(.secondary)
                        Text("Temporary educational access uses the same Request and Grant flow.")
                            .themisFont(.meta).foregroundStyle(ThemisColor.textSecondary)
                    }
                }
                InlineBanner(.info, RulesSchoolAccessPolicy.schoolAccessCapabilityMessage)
                ThemisCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Essential access").themisFont(.headline)
                        Text(RulesSchoolAccessPolicy.essentialAccessMessage).themisFont(.secondary)
                        Text(RulesSchoolAccessPolicy.emergencyAccessMessage).themisFont(.meta).foregroundStyle(ThemisColor.textSecondary)
                        Text(state.singleDevicePerChildNote).themisFont(.meta).foregroundStyle(ThemisColor.textSecondary)
                    }
                }
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.bottom, ThemisSpacing.block)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("R-001 · Rules") { NavigationStack { RulesSchoolAccessView() } }
#Preview("R-001 · Rules · AX3") { NavigationStack { RulesSchoolAccessView() }.environment(\.dynamicTypeSize, .accessibility3) }
#Preview("S-001 · School Access") { NavigationStack { SchoolAccessView(state: RulesSchoolAccessDemoData.schoolAccess) } }
#Preview("S-001 · School Access · AX3") { NavigationStack { SchoolAccessView(state: RulesSchoolAccessDemoData.schoolAccess) }.environment(\.dynamicTypeSize, .accessibility3) }
