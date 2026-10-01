import SwiftUI

// MARK: - UI-13 Edge States · Shared rendering
//
// Maps an `EdgeStatePresentation` onto the existing, read-only Core design
// system (`StatusBadge`, `ThemisStatus`, `EmptyStateView`, `ErrorStateView`,
// `InlineBanner`, `ThemisButton`, `ThemisCard`). No Core file is modified;
// this is purely a feature-local presentation layer, as required for UI-13.

private extension EdgeStateStatusKind {
    /// Maps the local, Foundation-only status kind onto the shared `ThemisStatus`
    /// system. Returns `nil` when the state deliberately shows no status chip.
    var themisStatus: ThemisStatus? {
        switch self {
        case .protectionUnavailable: return .protectionUnavailable
        case .deviceOffline: return .deviceOffline
        case .syncPending: return .syncPending
        case .approvedTimingUnverified: return .approvedTimingUnverified
        case .notFinished: return .notFinished
        case .waitingToSend: return .waitingToSend
        case .accessRevoked: return .accessRevoked
        case .none: return nil
        }
    }
}

private extension EdgeStateAudience {
    var themisAudience: ThemisAudience {
        switch self {
        case .parent: return .parent
        case .child: return .child
        case .teen: return .teen
        }
    }

    var ground: ThemisGround {
        self == .child ? .warm : .grouped
    }
}

private extension EdgeStateAction.Kind {
    var buttonStyle: ThemisButton.Style {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        case .tertiary: return .tertiary
        case .destructive: return .destructive
        }
    }
}

/// A single row showing both the child-device-claimed time and the
/// server-received time. Both are always shown together; neither is ever
/// presented alone as "the" timing fact (DEC-40, §17.7a).
struct TimingEvidenceRow: View {
    let evidence: TimingEvidencePresentation

    var body: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                row(label: "Child device says", value: evidence.childDeviceClaimedTime)
                row(label: "Themis received", value: evidence.serverReceivedTime)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .themisFont(.secondary)
                .foregroundStyle(ThemisColor.textSecondary)
            Spacer()
            Text(value)
                .themisFont(.rowTitle)
                .foregroundStyle(ThemisColor.textPrimary)
                .monospacedDigit()
        }
    }
}

/// Renders one approved UI-13 edge-state presentation. This is the single
/// rendering path shared by every scenario, so the safety-critical
/// distinctions (empty vs error, offline vs failed, queued vs sent, timing
/// unknown vs late) live in one place.
struct EdgeStateView: View {
    let presentation: EdgeStatePresentation
    var onAction: (EdgeStateAction) -> Void = { _ in }

    var body: some View {
        Group {
            if presentation.isCalmEmpty {
                ScrollView {
                    EmptyStateView(
                        title: presentation.title,
                        message: presentation.message,
                        systemImage: "checkmark"
                    )
                    .padding(.top, ThemisSpacing.block)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                        header
                        if let evidence = presentation.timingEvidence {
                            TimingEvidenceRow(evidence: evidence)
                        }
                        if !presentation.actions.isEmpty {
                            VStack(spacing: ThemisSpacing.inline10) {
                                ForEach(presentation.actions) { action in
                                    ThemisButton(title: action.title, style: action.kind.buttonStyle) {
                                        onAction(action)
                                    }
                                }
                            }
                        }
                    }
                    .padding(ThemisSpacing.screen)
                }
            }
        }
        .themisAudience(presentation.audience.themisAudience)
        .themisGround(presentation.audience.ground)
        .navigationTitle("\(presentation.screenID) · \(presentation.frameName)")
    }

    @ViewBuilder
    private var header: some View {
        if let status = presentation.statusKind.themisStatus {
            StatusHeader(
                status: status,
                explanation: presentation.message,
                lastVerified: presentation.lastVerifiedText
            )
        } else if presentation.severity == .failure || presentation.severity == .interrupted {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                InlineBanner(presentation.severity == .failure ? .error : .warning, presentation.title)
                Text(presentation.message)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                Text(presentation.title)
                    .themisFont(.headline)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(presentation.message)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let lastVerified = presentation.lastVerifiedText {
                    Text(lastVerified)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }
        }
    }
}

/// Loads a scenario through `EdgeStateViewModel` and renders it. Mirrors the
/// load/loading/error pattern used by the other features' root views.
struct EdgeStateContainerView: View {
    let scenario: EdgeStateScenario
    @StateObject private var viewModel: EdgeStateViewModel

    init(scenario: EdgeStateScenario, repository: any EdgeStateRepository = DemoEdgeStateRepository()) {
        self.scenario = scenario
        _viewModel = StateObject(wrappedValue: EdgeStateViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if let presentation = viewModel.presentation {
                EdgeStateView(presentation: presentation)
            } else {
                LoadingStateView(label: "Loading")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: scenario) {
            await viewModel.load(scenario: scenario)
        }
    }
}

/// A simple catalogue list of every approved UI-13 state, useful for review
/// and QA. Not wired into `RootView` or any other navigation shell.
struct EdgeStateCatalogueView: View {
    var body: some View {
        List(EdgeStateDemoData.all) { presentation in
            NavigationLink {
                EdgeStateView(presentation: presentation)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(presentation.screenID) · \(presentation.frameName)")
                        .themisFont(.rowTitle)
                    Text(presentation.title)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }
        }
        .navigationTitle("Edge states")
    }
}
