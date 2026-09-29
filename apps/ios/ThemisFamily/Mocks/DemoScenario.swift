import Foundation

enum DemoScenario: String, CaseIterable, Identifiable, Sendable {
    case normal = "Normal"
    case homeworkOverdue = "Homework overdue"
    case waitingApproval = "Waiting for approval"
    case approvalGrace = "Approval grace"
    case multipleRestrictions = "Multiple restrictions"
    case deviceOffline = "Device offline"
    case syncPending = "Sync pending"
    case protectionUnavailable = "Protection unavailable"
    case freePassActive = "Free Pass active"
    case subscriptionGrace = "Subscription grace"
    case subscriptionExpired = "Subscription expired"
    case noChildren = "No children"
    case noRules = "No rules"
    case requestPending = "Request pending"
    case requestDeclined = "Request declined"

    var id: String { rawValue }
}
