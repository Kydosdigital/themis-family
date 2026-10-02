import SwiftUI

enum FreePassFlowStep: String, CaseIterable, Sendable {
    case entry
    case child
    case scope
    case duration
    case preview
    case confirm
    case active
    case revoke
    case revocationSent
    case revoked

    var screenID: String {
        switch self {
        case .entry: return "F-001"
        case .child: return "F-002"
        case .scope: return "F-003"
        case .duration: return "F-004"
        case .preview: return "F-005"
        case .confirm: return "F-006"
        case .active: return "F-007"
        case .revoke: return "F-008"
        case .revocationSent: return "F-009"
        case .revoked: return "F-010"
        }
    }
}

struct FreePassFlowView: View {
    @State private var step: FreePassFlowStep
    @State private var selectedPreset: FreePassPreset?
    @State private var selectedChildID: UUID?
    @State private var selectedChildName: String?
    @State private var selectedTargets: Set<FreePassTarget>
    @State private var durationMinutes: Int?
    @State private var presentation: FreePassPresentation

    init(initialStep: FreePassFlowStep = .entry) {
        let canonical = initialStep == .entry || initialStep == .child
            ? FreePassDraft()
            : FreePassDemoData.canonicalDraft

        _step = State(initialValue: initialStep)
        _selectedPreset = State(initialValue: initialStep == .entry || initialStep == .child ? nil : .games30)
        _selectedChildID = State(initialValue: canonical.childID)
        _selectedChildName = State(initialValue: canonical.childName)
        _selectedTargets = State(initialValue: Set(canonical.targets))
        _durationMinutes = State(initialValue: canonical.durationMinutes)

        switch initialStep {
        case .revocationSent:
            _presentation = State(initialValue: FreePassDemoData.revocationSent)
        case .revoked:
            _presentation = State(initialValue: FreePassDemoData.revoked)
        default:
            _presentation = State(initialValue: FreePassDemoData.active)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                if ![.active, .revoke, .revocationSent, .revoked].contains(step) {
                    StepProgress(current: progressStep, total: 6, label: step.screenID)
                }
                content
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        switch step {
        case .active, .revoke, .revocationSent, .revoked: return "Free Pass"
        default: return "Give a Free Pass"
        }
    }

    private var progressStep: Int {
        switch step {
        case .entry: return 1
        case .child: return 2
        case .scope: return 3
        case .duration: return 4
        case .preview: return 5
        case .confirm: return 6
        case .active, .revoke, .revocationSent, .revoked: return 6
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .entry:
            entry
        case .child:
            childSelection
        case .scope:
            scopeSelection
        case .duration:
            durationSelection
        case .preview:
            overridePreview
        case .confirm:
            confirmation
        case .active:
            activeState
        case .revoke:
            revokeConfirmation
        case .revocationSent:
            stateCard(presentation)
        case .revoked:
            stateCard(presentation)
        }
    }

    private var entry: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(
                title: "A little flexibility",
                subtitle: "Give temporary access to something specific. There is no blanket Free Pass."
            )

            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    Text("Quick presets")
                        .themisFont(.headline)
                    Text("Each preset has an explicit scope and duration. You still choose the child before anything is granted.")
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)

                    ForEach(FreePassPreset.allCases) { preset in
                        ThemisButton(title: preset.title, style: .secondary) {
                            selectedPreset = preset
                            selectedTargets = Set(preset.targets)
                            durationMinutes = preset.durationMinutes
                            step = .child
                        }
                    }
                }
            }

            ThemisButton(title: "Choose custom access", style: .tertiary) {
                selectedPreset = nil
                selectedTargets = []
                durationMinutes = nil
                step = .child
            }
        }
    }

    private var childSelection: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(title: "Who is this for?", subtitle: "Choose one child. Nothing is preselected.")

            selectionButton(
                title: "Sam",
                subtitle: "Child",
                selected: selectedChildID == DemoData.samID
            ) {
                selectedChildID = DemoData.samID
                selectedChildName = "Sam"
            }

            selectionButton(
                title: "Maya",
                subtitle: "Teen",
                selected: selectedChildID == DemoData.mayaID
            ) {
                selectedChildID = DemoData.mayaID
                selectedChildName = "Maya"
            }

            ThemisButton(
                title: "Continue",
                isDisabled: selectedChildID == nil
            ) {
                step = selectedPreset == nil ? .scope : .preview
            }
        }
    }

    private var scopeSelection: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(
                title: "Choose exactly what",
                subtitle: "Select one or more apps, websites or categories. Free Pass never defaults to everything."
            )

            ForEach(FreePassTargets.selectable) { target in
                selectionButton(
                    title: target.name,
                    subtitle: target.kind.rawValue,
                    selected: selectedTargets.contains(target)
                ) {
                    if selectedTargets.contains(target) {
                        selectedTargets.remove(target)
                    } else {
                        selectedTargets.insert(target)
                    }
                }
            }

            InlineBanner(.info, "Phone, Messages and essential emergency access are outside Free Pass scope.")

            ThemisButton(
                title: "Continue",
                isDisabled: selectedTargets.isEmpty
            ) {
                step = .duration
            }
        }
    }

    private var durationSelection: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(title: "How long?", subtitle: "Choose a specific duration for this scope.")

            ChoiceChips(
                options: [15, 20, 30, 45],
                selection: $durationMinutes,
                title: { minutes in minutes == 45 ? "45 min · custom" : "\(minutes) min" }
            )

            ThemisButton(
                title: "Review what changes",
                isDisabled: durationMinutes == nil
            ) {
                step = .preview
            }
        }
    }

    private var overridePreview: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(
                title: "What this changes",
                subtitle: "Check the rules affected before you confirm."
            )

            summaryCard

            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    Text("Temporarily overridden")
                        .themisFont(.headline)
                    ForEach(FreePassDemoData.active.overriddenRules) { rule in
                        disclosureRow(rule, status: .overridden)
                    }
                }
            }

            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    Text("Starts during this pass")
                        .themisFont(.headline)
                    ForEach(FreePassDemoData.active.scheduledRules) { rule in
                        disclosureRow(rule, status: ThemisStatus(.due, label: "Starts later"))
                    }
                    Text("A rule that starts later is disclosed, not silently overridden.")
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }

            ThemisButton(title: "Continue to confirmation") {
                step = .confirm
            }
        }
    }

    private var confirmation: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(title: "Confirm Free Pass", subtitle: "Nothing changes until you confirm.")

            summaryCard

            InlineBanner(
                .info,
                "The pass expires locally on the child device. Normal effective enforcement resumes automatically at expiry, even if the parent device or network is unavailable then."
            )

            ThemisButton(title: "Confirm Free Pass") {
                var draft = FreePassDraft()
                if let selectedChildID, let selectedChildName {
                    draft.selectChild(id: selectedChildID, name: selectedChildName)
                }
                draft.chooseCustom(
                    targets: Array(selectedTargets).sorted(by: { $0.name < $1.name }),
                    durationMinutes: durationMinutes ?? 0
                )

                if let grant = draft.makeGrant(
                    role: .owner,
                    startsAt: FreePassDemoData.start,
                    endLabel: durationMinutes == 30 ? "8:45 PM" : "\(durationMinutes ?? 0) min after activation",
                    overriddenRules: [FreePassDemoData.bedtime],
                    scheduledRules: [FreePassDemoData.studyWindDown]
                ) {
                    presentation = grant
                    step = .active
                }
            }
        }
    }

    private var activeState: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            stateCard(presentation)

            if !presentation.remainingRestrictions.isEmpty {
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                        Text("Another restriction still applies")
                            .themisFont(.headline)
                        ForEach(presentation.remainingRestrictions, id: \.self) { restriction in
                            Text(restriction)
                                .themisFont(.secondary)
                        }
                    }
                }
            }

            ThemisButton(title: "Revoke Free Pass", style: .destructive) {
                step = .revoke
            }
        }
    }

    private var revokeConfirmation: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            PageHeader(title: "End this Free Pass?", subtitle: "The original family rules will resume for this scope.")

            stateCard(presentation)

            InlineBanner(
                .warning,
                "After you revoke, Themis will show Revocation sent until the child device confirms the change. It will not claim access is revoked earlier."
            )

            ThemisButton(title: "Revoke now", style: .destructiveConfirm) {
                presentation = presentation.revoking(by: .owner, deviceAcknowledged: false)
                step = .revocationSent
            }

            ThemisButton(title: "Keep Free Pass", style: .tertiary) {
                step = .active
            }
        }
    }

    private var summaryCard: some View {
        ThemisCard {
            VStack(spacing: 0) {
                ThemisRow(title: "Child", value: selectedChildName ?? "Not selected")
                Divider()
                ThemisRow(title: "Scope", value: selectedTargets.isEmpty ? "Not selected" : scopeText)
                Divider()
                ThemisRow(title: "Duration", value: durationMinutes.map { "\($0) min" } ?? "Not selected")
                Divider()
                ThemisRow(title: "Ends", value: durationMinutes == 30 ? "8:45 PM" : "At the stated local expiry")
            }
        }
    }

    private var scopeText: String {
        selectedTargets
            .map(\.name)
            .sorted()
            .joined(separator: ", ")
    }

    private func stateCard(_ state: FreePassPresentation) -> some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                StatusBadge(state.status)
                Text(state.headline)
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(state.message)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                ThemisRow(title: "Child", value: state.childName)
                Divider()
                ThemisRow(title: "Scope", value: state.scopeText)
                Divider()
                ThemisRow(title: "Duration", value: "\(state.durationMinutes) min")
                Divider()
                ThemisRow(title: "Ends", value: state.endLabel)
            }
        }
    }

    private func disclosureRow(_ rule: FreePassRuleDisclosure, status: ThemisStatus) -> some View {
        ThemisRow(
            title: rule.ruleName,
            subtitle: rule.detail,
            status: status
        )
    }

    private func selectionButton(
        title: String,
        subtitle: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ThemisCard(isSelected: selected) {
                HStack(spacing: ThemisSpacing.inline12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .themisFont(.rowTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(subtitle)
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selected ? ThemisColor.brandPrimary : ThemisColor.textSecondary)
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

#Preview("F-001 · Entry") { NavigationStack { FreePassFlowView(initialStep: .entry) } }
#Preview("F-003 · Scope") { NavigationStack { FreePassFlowView(initialStep: .scope) } }
#Preview("F-005 · Preview") { NavigationStack { FreePassFlowView(initialStep: .preview) } }
#Preview("F-007 · Active") { NavigationStack { FreePassFlowView(initialStep: .active) } }
#Preview("F-009 · Revocation sent") { NavigationStack { FreePassFlowView(initialStep: .revocationSent) } }
#Preview("F-010 · Access revoked") { NavigationStack { FreePassFlowView(initialStep: .revoked) } }
#Preview("F-007 · Active · AX3") {
    NavigationStack { FreePassFlowView(initialStep: .active) }
        .environment(\.dynamicTypeSize, .accessibility3)
}
