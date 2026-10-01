import Foundation

/// Feature-local presentation repository for UI-12 Subscription. Kept inside
/// `Features/Subscription` rather than `Core/Repositories` so this isolated slice never
/// touches shared protocols. A future subscription service conforms to this same shape
/// once real entitlement data (App Store server notifications, backend state) exists.
protocol SubscriptionRepository: Sendable {
    func presentation(for scenario: SubscriptionDemoScenario) async throws -> SubscriptionPresentation
}

/// Deterministic mock repository. No Supabase, no StoreKit, no network calls — demo
/// data only.
struct MockSubscriptionRepository: SubscriptionRepository {
    func presentation(for scenario: SubscriptionDemoScenario) async throws -> SubscriptionPresentation {
        SubscriptionDemoData.presentation(for: scenario)
    }
}
