import SwiftUI

struct ProtectionPresentation: Equatable, Sendable {
    let status: ProtectionStatus
    let evidence: ProtectionEvidence
    let explanation: String
    let restrictionsRemainInEffect: Bool
    let recoveryAvailable: Bool

    // A raw Protected state without verified evidence must never render as confirmed.
    var displayStatus: ProtectionStatus {
        status == .protected && !isProtected ? .needsAttention : status
    }
    var statusText: String { displayStatus.title }
    var displayExplanation: String {
        status == .protected && !isProtected
            ? "Protection needs your attention before it can be confirmed again."
            : explanation
    }
    var displayRecoveryAvailable: Bool {
        recoveryAvailable || (status == .protected && !isProtected)
    }
    var evidenceText: String {
        switch evidence {
        case .verified:
            return "Last verified: " + evidence.text.replacingOccurrences(of: "Verified ", with: "")
        case .noticed:
            return "Issue noticed: " + evidence.text.replacingOccurrences(of: "Noticed ", with: "")
        case .notActiveYet:
            return "Protection not active yet"
        }
    }

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

    /// Child-specific review copy must never attribute Maya's device to Sam.
    static func forChild(_ presentation: ProtectionPresentation, name: String) -> ProtectionPresentation {
        guard name != "Sam" else { return presentation }
        return ProtectionPresentation(
            status: presentation.status,
            evidence: presentation.evidence,
            explanation: presentation.explanation.replacingOccurrences(of: "Sam’s iPhone", with: "\(name)’s iPhone"),
            restrictionsRemainInEffect: presentation.restrictionsRemainInEffect,
            recoveryAvailable: presentation.recoveryAvailable
        )
    }

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
    var childName: String = "Sam"
    var onFix: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: "\(childName)’s protection", subtitle: "iPhone")

                VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                    Label(presentation.statusText, systemImage: presentation.displayStatus.symbolName)
                        .font(.title2.weight(.semibold))
                    Text(presentation.displayExplanation)
                        .foregroundStyle(.secondary)
                    Text(presentation.evidenceText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 20))

                if presentation.status == .syncPending {
                    InlineBanner(.info, "The last confirmed local plan may continue while valid. New changes are waiting for device confirmation; this status does not mean restrictions were cleared.")
                } else if presentation.status == .deviceOffline {
                    InlineBanner(.info, "The last-synced protection plan may continue while valid, but Themis cannot confirm the current device state. Offline does not mean restrictions were cleared.")
                }

                if presentation.displayRecoveryAvailable {
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

private struct ChildDetailSummaryRow: Identifiable {
    let id: String
    let title: String
    let subtitle: String
}

struct ChildDetailView: View {
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

                ThemisGroupedSection("Current agreements", data: [
                    ChildDetailSummaryRow(id: "homework", title: "Homework due 6:00 PM", subtitle: "School days"),
                    ChildDetailSummaryRow(id: "social", title: "Social apps pause 10:00 PM", subtitle: "Every night")
                ]) { item in
                    ThemisRow(title: item.title, subtitle: item.subtitle)
                }

                ThemisGroupedSection("Needs you", data: [
                    ChildDetailSummaryRow(id: "review", title: "Homework review", subtitle: "Waiting for Sarah"),
                    ChildDetailSummaryRow(id: "extra-time", title: "Extra time request", subtitle: "Pending")
                ]) { item in
                    ThemisRow(title: item.title, subtitle: item.subtitle)
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
    var childName: String = "Sam"
    var onRecovered: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                PageHeader(title: step == 0 ? "Fix protection" : "Check protection", subtitle: "\(childName)’s iPhone")
                if step == 0 {
                    Text("Open Themis on \(childName)’s iPhone and follow the Apple permission steps.")
                    Text("Once those steps are complete, return here. Themis will only show Protected after the device confirms protection again.")
                        .foregroundStyle(.secondary)
                    Button("Continue") { step = 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    InlineBanner(.info, "Waiting for confirmation from \(childName)’s iPhone")
                    Text("Returning here does not by itself mean protection is active.")
                        .foregroundStyle(.secondary)
                    #if DEBUG
                    // Only debug demo builds may simulate a device acknowledgement.
                    Button("Simulate confirmed recovery", action: onRecovered)
                        .buttonStyle(.borderedProminent)
                    #endif
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
    let childName: String
    @State private var route: Int = 0
    @State private var presentation: ProtectionPresentation

    init(initial: ProtectionPresentation, childName: String = "Sam") {
        self.initial = initial
        self.childName = childName
        _presentation = State(initialValue: initial)
    }

    var body: some View {
        ChildProtectionDetailView(presentation: presentation, childName: childName) { route = 1 }
            .navigationDestination(isPresented: Binding(get: { route == 1 }, set: { if !$0 { route = 0 } })) {
                ProtectionRecoveryView(childName: childName) {
                    presentation = ProtectionDemoData.forChild(ProtectionDemoData.recovered, name: childName)
                    route = 0
                }
            }
    }
}
