import Foundation

struct ChildProfile: Identifiable, Equatable, Sendable {
    let id: UUID
    let firstName: String
    let experienceSegment: ExperienceSegment
    let protectionStatus: ProtectionStatus
    let lastVerified: Date?
    let activeRuleCount: Int
    let pendingActionCount: Int
}

enum RuleKind: String, Sendable {
    case scheduled = "Scheduled"
    case deadlineLock = "Deadline Lock"
    case earnFirst = "Earn First"
}

struct FamilyRule: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let kind: RuleKind
    let scheduleSummary: String
    let targetsSummary: String
    let isActive: Bool
}

enum TaskState: Equatable, Sendable {
    case due
    case submittedAwaitingApproval
    case approvalGrace(minutesRemaining: Int)
    case overdueRestricted
    case approved
}

struct TaskItem: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let dueSummary: String
    let state: TaskState
}

enum RequestStatus: String, Sendable {
    case pending
    case approved
    case partiallyApproved
    case declined
    case expired
    case cancelled
}

struct AccessRequest: Identifiable, Equatable, Sendable {
    let id: UUID
    let childName: String
    let summary: String
    let requestedDuration: String
    let status: RequestStatus
}

struct ParentDashboardData: Equatable, Sendable {
    let ownerName: String
    let children: [ChildProfile]
    let pendingRequests: [AccessRequest]
    let subscriptionBanner: String?
}

struct ChildHomeData: Equatable, Sendable {
    let child: ChildProfile
    let activeRestrictionReasons: [String]
    let task: TaskItem?
    let freePassSummary: String?
    let requestStatusSummary: String?
}
