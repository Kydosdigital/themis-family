import Foundation

/// What the Activity screens render: Category A and the Apple report availability,
/// kept as separate fields.
struct ActivityScreenState: Equatable, Sendable {
    let snapshot: ActivitySnapshot
    let appleReport: AppleScreenTimeReportState
}

@MainActor
final class ActivityViewModel: ObservableObject {
    @Published private(set) var screen: ActivityScreenState?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    /// The T-001 period selector. Presentation only.
    @Published var period: ActivityPeriod

    private let repository: any ActivityRepository

    init(repository: any ActivityRepository, period: ActivityPeriod = .thisWeek) {
        self.repository = repository
        self.period = period
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await repository.activity()
            let appleReport = await repository.appleScreenTimeReportState()
            screen = ActivityScreenState(snapshot: snapshot, appleReport: appleReport)
        } catch {
            errorMessage = ActivityCopy.loadError
        }

        isLoading = false
    }
}
