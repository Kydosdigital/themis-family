import SwiftUI

struct ProtectionPresentation: Equatable, Sendable {
    let status: ProtectionStatus
    let evidence: ProtectionEvidence
    let explanation: String
    let restrictionsRemainInEffect: Bool
    let recoveryAvailable: Bool

    var statusText: String { status.title }
    var evidenceText: String { "Last verified: " + evidence.text.replacingOccurrences(of: "Verified ", with: "") }

    var isProtected: Bool {
        guard status == .protected else { return false }
        if case .verified = evidence { return true }
        return false
    }
}

enum ProtectionDemoData {
    static let protected = ProtectionPresentation(status: .protected, evidence: .verified(minutesAgo: 2), explanation: "Protection was confirmed on Sam’s iPhone.", restrictionsRemainInEffect: true, recoveryAvailable: false)
    static let syncPending = ProtectionPresentation(status: .syncPending, evidence: .verified(minutesAgo: 14), explanation: "The latest protection update is still waiting for confirmation.", restrictionsRemainInEffect: true, recoveryAvailable: false)
    static let deviceOffline = ProtectionPresentation(status: .deviceOffline, evidence: .verified(minutesAgo: 180), explanation: "Sam’s iPhone is offline, so Themis cannot confirm the latest protection state.", restrictionsRemainInEffect: true, recoveryAvailable: false)
    static let needsAttention = ProtectionPresentation(status: .needsAttention, evidence: .noticed(minutesAgo: 10), explanation: "Protection needs your attention before it can be confirmed again.", restrictionsRemainInEffect: true, recoveryAvailable: true)
    static let unavailable = ProtectionPresentation(status: .protectionUnavailable, evidence: .noticed(minutesAgo: 10), explanation: "Protection cannot currently be confirmed on Sam’s iPhone.", restrictionsRemainInEffect: false, recoveryAvailable: true)
    static let permissionRevoked = ProtectionPresentation(status: .protectionUnavailable, evidence: .noticed(minutesAgo: 0), explanation: "Screen Time permission is no longer available. Re-authorise protection to continue.", restrictionsRemainInEffect: false, recoveryAvailable: true)
    static let recovered = ProtectionPresentation(status: .protected, evidence: .verified(minutesAgo: 0), explanation: "Protection has been confirmed again on Sam’s iPhone.", restrictionsRemainInEffect: true, recoveryAvailable: false)

    static func state(for status: ProtectionStatus) -> ProtectionPresentation {
        switch status {
        case .protected: return protected
        case .syncPending: return syncPending
        case .deviceOffline: return deviceOffline
        case .needsAttention: return needsAttention
        case .protectionUnavailable: return unavailable
        }
    }
}

struct ChildProtectionDetailView: View {
    let presentation: ProtectionPresentation
    var onFix: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "Sam’s protection", subtitle: "iPhone")

                VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                    Label(presentation.statusText, systemImage: presentation.status.symbolName)
                        .font(.title2.weight(.semibold))
                    Text(presentation.explanation)
                        .foregroundStyle(.secondary)
                    Text(presentation.evidenceText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 20))

                if presentation.status == .syncPending || presentation.status == .deviceOffline {
                    InlineBanner(.info, "Existing rules stay on the child device using its last confirmed local plan. This status does not mean restrictions were cleared.")
                }

                if presentation.recoveryAvailable {
                    Button("Fix this", action: onFix)
                        .buttonStyle(.borderedProminent)
                        .accessibilityHint("Opens protection recovery")
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .navigationTitle("Protection")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
    }
}

private struct ChildDetailSummaryRow: Identifiable {\n    let id: String\n    let title: String\n    let subtitle: String\n}\n\nstruct ChildDetailView: View {
    var openProtection: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "Sam", subtitle: "Child · iPhone")

                Button(action: openProtection) {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                        Text("Protection").font(.headline)
                        Label("Protected", systemImage: ProtectionStatus.protected.symbolName)
                        Text("Last verified: 2 min ago").font(.footnote).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.background, in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)

                ThemisGroupedSection("Current agreements", data: ["Homework due 6:00 PM", "Social apps pause 10:00 PM"]) { item in
                    ThemisRow(title: item, subtitle: item.hasPrefix("Homework") ? "School days" : "Every night")
                }

                ThemisGroupedSection("Needs you", data: ["Homework review", "Extra time request"]) { item in
                    ThemisRow(title: item, subtitle: item == "Homework review" ? "Waiting for Sarah" : "Pending")
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .navigationTitle("Sam")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProtectionRecoveryView: View {
    @State private var step = 0
    var onRecovered: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: step == 0 ? "Fix protection" : "Check protection", subtitle: "Sam’s iPhone")
                if step == 0 {
                    Text("Themis needs Screen Time permission on Sam’s iPhone before protection can be confirmed.")
                    Text("Continue to the system permission flow. Themis will only show Protected after the device confirms protection again.")
                        .foregroundStyle(.secondary)
                    Button("Continue to system settings") { step = 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    InlineBanner(.info, "Waiting for confirmation from Sam’s iPhone")
                    Text("Returning from system settings does not by itself mean protection is active.")
                        .foregroundStyle(.secondary)
                    Button("Simulate confirmed recovery", action: onRecovered)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .themisAudience(.parent)
        .themisGround(.grouped)
        .navigationTitle("Fix protection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProtectionFlowView: View {
    let initial: ProtectionPresentation
    @State private var route: Int = 0
    @State private var presentation: ProtectionPresentation

    init(initial: ProtectionPresentation) {
        self.initial = initial
        _presentation = State(initialValue: initial)
    }

    var body: some View {
        ChildProtectionDetailView(presentation: presentation) { route = 1 }
            .navigationDestination(isPresented: Binding(get: { route == 1 }, set: { if !$0 { route = 0 } })) {
                ProtectionRecoveryView {
                    presentation = ProtectionDemoData.recovered
                    route = 0
                }
            }
    }
}
