import Foundation

/// Presentation repository for Activity, local to this feature.
///
/// Category A (Themis-owned outcomes) and the Apple report state are separate calls on
/// purpose: Apple's usage data never passes through a Themis repository, and only its
/// availability is represented.
protocol ActivityRepository: Sendable {
    func activity() async throws -> ActivitySnapshot
    func appleScreenTimeReportState() async -> AppleScreenTimeReportState
}

/// Deterministic mock. Not evidence that anything was stored, synced or applied.
struct MockActivityRepository: ActivityRepository {
    var reportState: AppleScreenTimeReportState = .systemOwnedReportArea
    /// Presents the state after Sam's Thursday timing review instead of the canonical frames.
    var timingReviewed = false

    func activity() async throws -> ActivitySnapshot {
        timingReviewed ? ActivityDemoData.timingResolvedSnapshot : ActivityDemoData.snapshot
    }

    func appleScreenTimeReportState() async -> AppleScreenTimeReportState {
        reportState
    }
}
