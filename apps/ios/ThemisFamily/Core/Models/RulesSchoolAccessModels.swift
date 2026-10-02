import Foundation

enum RuleType: String, CaseIterable, Identifiable, Hashable {
    case scheduled = "Scheduled Rule"
    case deadlineLock = "Deadline Lock"
    case earnFirst = "Earn First"

    var id: String { rawValue }
}

enum RuleVerificationType: String, CaseIterable, Identifiable, Hashable {
    case parentApproval = "Parent Approval"
    case automaticSession = "Automatic Verification"

    var id: String { rawValue }
}

enum RuleSyncState: String, Hashable {
    case active = "Active"
    case pendingSync = "Pending sync"
}

enum RuleTargetKind: String, Hashable {
    case app
    case website
    case category
}

struct RuleTarget: Identifiable, Hashable {
    let id: UUID
    var name: String
    var kind: RuleTargetKind

    init(id: UUID = UUID(), name: String, kind: RuleTargetKind) {
        self.id = id
        self.name = name
        self.kind = kind
    }
}

struct RuleSchedule: Equatable, Hashable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var appliesOnSchoolDays: Bool
}

struct DeadlineLockConfiguration: Equatable, Hashable {
    static let approvalGraceMinutes = 30

    var deadlineHour: Int
    var deadlineMinute: Int
    var verificationType: RuleVerificationType
}

struct EarnFirstConfiguration: Equatable, Hashable {
    var requiredMinutes: Int
    var rewardMinutes: Int
}

struct RuleDraft: Identifiable, Equatable {
    let id: UUID
    var childName: String
    var type: RuleType
    var title: String
    var targets: [RuleTarget]
    var schedule: RuleSchedule?
    var deadlineLock: DeadlineLockConfiguration?
    var earnFirst: EarnFirstConfiguration?
    var exceptions: [RuleTarget]
    var syncState: RuleSyncState

    init(
        id: UUID = UUID(),
        childName: String,
        type: RuleType,
        title: String,
        targets: [RuleTarget],
        schedule: RuleSchedule? = nil,
        deadlineLock: DeadlineLockConfiguration? = nil,
        earnFirst: EarnFirstConfiguration? = nil,
        exceptions: [RuleTarget] = [],
        syncState: RuleSyncState = .active
    ) {
        self.id = id
        self.childName = childName
        self.type = type
        self.title = title
        self.targets = targets
        self.schedule = schedule
        self.deadlineLock = deadlineLock
        self.earnFirst = earnFirst
        self.exceptions = exceptions
        self.syncState = syncState
    }
}

struct AlwaysAllowedState: Equatable {
    var targets: [RuleTarget]
    var disclosure: String?
}

struct SchoolAccessState: Equatable {
    var schoolTargets: [RuleTarget]
    var entertainmentTargets: [RuleTarget]
    var temporaryEducationalRequestsEnabled: Bool
    var singleDevicePerChildNote: String
}

enum EffectiveRestrictionResult: Equatable {
    case unrestricted
    case restrictedBy([String])
}

enum RulesSchoolAccessPolicy {
    static let emergencyAccessMessage = "Emergency calling and OS-level emergency functionality are never deliberately restricted."

    static let essentialAccessMessage = "Phone, Messages and Maps can be configured to stay available where supported."

    static let schoolAccessCapabilityMessage = "School Access does not classify educational versus entertainment content inside the same app or website."

    static let temporarySchoolAccessMessage = "Temporary educational access uses the existing request and grant flow."

    static func allowedVerificationTypes(
        for ruleType: RuleType,
        isSupportedThemisSession: Bool
    ) -> [RuleVerificationType] {
        switch ruleType {
        case .deadlineLock:
            return [.parentApproval]
        case .earnFirst:
            return isSupportedThemisSession ? [.parentApproval, .automaticSession] : [.parentApproval]
        case .scheduled:
            return [.parentApproval]
        }
    }

    static func effectiveRestriction(
        activeRestrictionNames: [String]
    ) -> EffectiveRestrictionResult {
        activeRestrictionNames.isEmpty
            ? .unrestricted
            : .restrictedBy(activeRestrictionNames)
    }

    static func applyAlwaysAllowed(
        target: RuleTarget,
        to rules: [RuleDraft],
        currentAlwaysAllowed: [RuleTarget]
    ) -> (rules: [RuleDraft], state: AlwaysAllowedState) {
        let updatedRules = rules.map { rule in
            var copy = rule
            copy.targets.removeAll { $0.id == target.id }
            return copy
        }

        var allowed = currentAlwaysAllowed
        if !allowed.contains(where: { $0.id == target.id }) {
            allowed.append(target)
        }

        return (
            updatedRules,
            AlwaysAllowedState(
                targets: allowed,
                disclosure: "\(target.name) was removed from restrictive rules because Always Allowed takes priority."
            )
        )
    }

    static func canAddRestrictedTarget(
        _ target: RuleTarget,
        alwaysAllowed: [RuleTarget]
    ) -> Bool {
        !alwaysAllowed.contains(where: { $0.id == target.id })
    }
}

enum RulesSchoolAccessDemoData {
    static let roblox = RuleTarget(name: "Roblox", kind: .app)
    static let minecraft = RuleTarget(name: "Minecraft", kind: .app)
    static let youtube = RuleTarget(name: "YouTube", kind: .app)
    static let schoolPortal = RuleTarget(name: "School portal", kind: .website)

    static let scheduled = RuleDraft(
        childName: "Maya",
        type: .scheduled,
        title: "Social apps",
        targets: [youtube],
        schedule: RuleSchedule(
            startHour: 22,
            startMinute: 0,
            endHour: 7,
            endMinute: 0,
            appliesOnSchoolDays: false
        )
    )

    static let deadlineLock = RuleDraft(
        childName: "Sam",
        type: .deadlineLock,
        title: "Homework Deadline",
        targets: [roblox, minecraft],
        deadlineLock: DeadlineLockConfiguration(
            deadlineHour: 18,
            deadlineMinute: 0,
            verificationType: .parentApproval
        )
    )

    static let earnFirst = RuleDraft(
        childName: "Sam",
        type: .earnFirst,
        title: "Focus then play",
        targets: [roblox],
        earnFirst: EarnFirstConfiguration(
            requiredMinutes: 30,
            rewardMinutes: 45
        )
    )

    static let pendingSync = RuleDraft(
        childName: "Maya",
        type: .scheduled,
        title: "Evening wind-down",
        targets: [youtube],
        schedule: RuleSchedule(
            startHour: 21,
            startMinute: 30,
            endHour: 7,
            endMinute: 0,
            appliesOnSchoolDays: true
        ),
        syncState: .pendingSync
    )

    static let schoolAccess = SchoolAccessState(
        schoolTargets: [schoolPortal],
        entertainmentTargets: [roblox, minecraft, youtube],
        temporaryEducationalRequestsEnabled: true,
        singleDevicePerChildNote: "School Access assumes one managed device per child. Do not share one managed device across sibling profiles."
    )
}
