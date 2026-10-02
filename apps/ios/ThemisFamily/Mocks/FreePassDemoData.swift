import Foundation

enum FreePassDemoData {
    static let start = Date(timeIntervalSince1970: 1_796_145_000)

    static let bedtime = FreePassRuleDisclosure(
        id: "rule.bedtime.games",
        ruleName: "Bedtime",
        detail: "Games are currently paused by the bedtime schedule.",
        isActiveNow: true,
        beginsDuringPass: false
    )

    static let studyWindDown = FreePassRuleDisclosure(
        id: "rule.study-wind-down.games",
        ruleName: "Study wind-down",
        detail: "Starts at 8:30 PM. Games may pause again then. This Free Pass does not silently override a new scheduled restriction.",
        isActiveNow: false,
        beginsDuringPass: true
    )

    static var canonicalDraft: FreePassDraft {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.apply(.games30)
        return draft
    }

    static var customDraft: FreePassDraft {
        var draft = FreePassDraft()
        draft.selectChild(id: DemoData.mayaID, name: "Maya")
        draft.chooseCustom(targets: [.roblox], durationMinutes: 45)
        return draft
    }

    static var active: FreePassPresentation {
        canonicalDraft.makeGrant(
            role: .owner,
            startsAt: start,
            endLabel: "8:45 PM",
            overriddenRules: [bedtime],
            scheduledRules: [studyWindDown]
        )!
    }

    static var activeWithAnotherRestriction: FreePassPresentation {
        canonicalDraft.makeGrant(
            role: .owner,
            startsAt: start,
            endLabel: "8:45 PM",
            overriddenRules: [bedtime],
            scheduledRules: [studyWindDown],
            remainingRestrictions: ["Homework Deadline Lock still limits Roblox"]
        )!
    }

    static var revocationSent: FreePassPresentation {
        active.revoking(by: .owner, deviceAcknowledged: false)
    }

    static var revoked: FreePassPresentation {
        revocationSent.acknowledgingRevocation()
    }

    static var expired: FreePassPresentation {
        active.expiring(at: active.expiresAt.addingTimeInterval(1))
    }
}
