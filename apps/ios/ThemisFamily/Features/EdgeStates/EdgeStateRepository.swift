import Foundation

// MARK: - UI-13 Edge States · Feature-local mock repository
//
// Deterministic, in-memory only. No Supabase, no networking, no StoreKit, no
// FamilyControls/DeviceActivity, no APNs, no real persistence. This exists
// purely so the view model has a seam for previews/tests, mirroring the
// repository pattern used elsewhere in the app (e.g. `ParentDashboardRepository`).

/// Reads edge-state presentations. The only implementation is the deterministic
/// demo repository below; production integration of these presentations into
/// the real feature screens is out of scope for this isolated slice.
protocol EdgeStateRepository: Sendable {
    func presentation(for scenario: EdgeStateScenario) async -> EdgeStatePresentation
    func allPresentations() async -> [EdgeStatePresentation]
}

/// Deterministic, in-memory repository backed by `EdgeStateDemoData`.
struct DemoEdgeStateRepository: EdgeStateRepository {
    func presentation(for scenario: EdgeStateScenario) async -> EdgeStatePresentation {
        EdgeStateDemoData.presentation(for: scenario)
    }

    func allPresentations() async -> [EdgeStatePresentation] {
        EdgeStateDemoData.all
    }
}
