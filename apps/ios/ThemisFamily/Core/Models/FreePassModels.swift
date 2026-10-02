import Foundation

enum FreePassTargetKind: String, Equatable, Sendable {
    case app = "App"
    case website = "Website"
    case category = "Category"
}

struct FreePassTarget: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let kind: FreePassTargetKind
    var isAlwaysAllowed: Bool = false
    var isEmergencyCommunication: Bool = false

    var canReceiveFreePass: Bool {
        !isAlwaysAllowed && !isEmergencyCommunication
    }
}

enum FreePassTargets {
    static let games = FreePassTarget(id: "category.games", name: "Games", kind: .category)
    static let youtube = FreePassTarget(id: "app.youtube", name: "YouTube", kind: .app)
    static let roblox = FreePassTarget(id: "app.roblox", name: "Roblox", kind: .app)
    static let minecraft = FreePassTarget(id: "app.minecraft", name: "Minecraft", kind: .app)
    static let entertainment = FreePassTarget(id: "category.entertainment", name: "All entertainment", kind: .category)

    // Safety boundaries are represented explicitly so tests can prove these cannot
    // accidentally enter a Free Pass scope.
    static let phone = FreePassTarget(
        id: "system.phone",
        name: "Phone",
        kind: .app,
        isAlwaysAllowed: true,
        isEmergencyCommunication: true
    )
    static let messages = FreePassTarget(
        id: "system.messages",
        name: "Messages",
        kind: .app,
        isAlwaysAllowed: true,
        isEmergencyCommunication: true
    )

    static let selectable: [FreePassTarget] = [games, youtube, roblox, minecraft, entertainment]
}

enum FreePassPreset: String, CaseIterable, Identifiable, Sendable {
    case games30
    case youtube20
    case entertainment30

    var id: String { rawValue }

    var title: String {
        switch self {
        case .games30: return "Games · 30 min"
        case .youtube20: return "YouTube · 20 min"
        case .entertainment30: return "All entertainment · 30 min"
        }
    }

    var targets: [FreePassTarget] {
        switch self {
        case .games30: return [FreePassTargets.games]
        case .youtube20: return [FreePassTargets.youtube]
        case .entertainment30: return [FreePassTargets.entertainment]
        }
    }

    var durationMinutes: Int {
        switch self {
        case .games30, .entertainment30: return 30
        case .youtube20: return 20
        }
    }
}

struct FreePassRuleDisclosure: Identifiable, Equatable, Sendable {
    let id: String
    let ruleName: String
    let detail: String
    let isActiveNow: Bool
    let beginsDuringPass: Bool
}

enum FreePassLifecycleState: String, Equatable, Sendable {
    case draft
    case active
    case revocationSent
    case revoked
    case expired
}

enum FreePassDeviceApplicationState: String, Equatable, Sendable {
    case notSent
    case pending
    case applied
    case revocationPending
    case revoked
    case expired
}

enum FreePassGrantActionResult: Equatable, Sendable {
    case allowed
    case notAuthorised
    case invalidDraft
}

enum FreePassPolicy {
    /// FR-044 / BR-210 / DEC-30: expiry is part of the locally cached grant.
    static let expiryIsLocal = true
    static let expiryRequiresNetwork = false
    static let expiryRequiresSecondParentAction = false
}

struct FreePassDraft: Equatable, Sendable {
    var childID: UUID?
    var childName: String?
    var targets: [FreePassTarget] = []
    var durationMinutes: Int?

    var hasExplicitChild: Bool { childID != nil && !(childName ?? "").isEmpty }
    var hasExplicitScope: Bool { !targets.isEmpty && targets.allSatisfy(\.canReceiveFreePass) }
    var hasExplicitDuration: Bool { (durationMinutes ?? 0) > 0 }

    func canConfirm(role: TaskApproverRole) -> Bool {
        role.canDecide && hasExplicitChild && hasExplicitScope && hasExplicitDuration
    }

    mutating func selectChild(id: UUID, name: String) {
        childID = id
        childName = name
    }

    mutating func apply(_ preset: FreePassPreset) {
        targets = preset.targets
        durationMinutes = preset.durationMinutes
    }

    mutating func chooseCustom(targets: [FreePassTarget], durationMinutes: Int) {
        self.targets = targets
        self.durationMinutes = durationMinutes
    }

    func makeGrant(
        role: TaskApproverRole,
        startsAt: Date,
        endLabel: String,
        overriddenRules: [FreePassRuleDisclosure],
        scheduledRules: [FreePassRuleDisclosure],
        remainingRestrictions: [String] = []
    ) -> FreePassPresentation? {
        guard canConfirm(role: role),
              let childID,
              let childName,
              let durationMinutes else {
            return nil
        }

        return FreePassPresentation(
            screenID: "F-007",
            childID: childID,
            childName: childName,
            targets: targets,
            durationMinutes: durationMinutes,
            startsAt: startsAt,
            expiresAt: startsAt.addingTimeInterval(TimeInterval(durationMinutes * 60)),
            endLabel: endLabel,
            status: .freePassActive,
            headline: "Free Pass active",
            message: "Only the selected scope is temporarily available. Normal effective enforcement resumes automatically when this pass ends.",
            lifecycle: .active,
            deviceApplication: .applied,
            overriddenRules: overriddenRules,
            scheduledRules: scheduledRules,
            remainingRestrictions: remainingRestrictions
        )
    }
}

struct FreePassPresentation: Equatable, Sendable {
    var screenID: String
    var childID: UUID
    var childName: String
    var targets: [FreePassTarget]
    var durationMinutes: Int
    var startsAt: Date
    var expiresAt: Date
    var endLabel: String
    var status: ThemisStatus
    var headline: String
    var message: String
    var lifecycle: FreePassLifecycleState
    var deviceApplication: FreePassDeviceApplicationState
    var overriddenRules: [FreePassRuleDisclosure]
    var scheduledRules: [FreePassRuleDisclosure]
    var remainingRestrictions: [String]

    var scopeText: String {
        targets.map(\.name).joined(separator: ", ")
    }

    var mayClaimSelectedTargetsAvailable: Bool {
        lifecycle == .active
            && deviceApplication == .applied
            && remainingRestrictions.isEmpty
    }

    var hasScheduledRuleBeginningDuringPass: Bool {
        scheduledRules.contains(where: \.beginsDuringPass)
    }

    func revoking(by role: TaskApproverRole, deviceAcknowledged: Bool) -> FreePassPresentation {
        guard role.canDecide, lifecycle == .active else { return self }
        var copy = self

        if deviceAcknowledged {
            copy.screenID = "F-010"
            copy.lifecycle = .revoked
            copy.deviceApplication = .revoked
            copy.status = .accessRevoked
            copy.headline = "Access revoked"
            copy.message = "\(childName)’s device confirmed the change. Normal effective enforcement is now back in force for this scope."
        } else {
            copy.screenID = "F-009"
            copy.lifecycle = .revocationSent
            copy.deviceApplication = .revocationPending
            copy.status = ThemisStatus(.applying, label: "Revocation sent")
            copy.headline = "Revocation sent"
            copy.message = "The revocation is recorded. Waiting for \(childName)’s device to acknowledge and apply it before claiming access is revoked on-device."
        }
        return copy
    }

    func acknowledgingRevocation() -> FreePassPresentation {
        guard lifecycle == .revocationSent else { return self }
        var copy = self
        copy.screenID = "F-010"
        copy.lifecycle = .revoked
        copy.deviceApplication = .revoked
        copy.status = .accessRevoked
        copy.headline = "Access revoked"
        copy.message = "\(childName)’s device confirmed the change. Normal effective enforcement is now back in force for this scope."
        return copy
    }

    func expiring(at now: Date) -> FreePassPresentation {
        guard lifecycle == .active, now >= expiresAt else { return self }
        var copy = self
        copy.lifecycle = .expired
        copy.deviceApplication = .expired
        copy.status = .expired
        copy.headline = "Free Pass ended"
        copy.message = "The locally cached expiry was reached. Normal effective enforcement resumes without another parent action or a new push at the expiry moment."
        return copy
    }
}
