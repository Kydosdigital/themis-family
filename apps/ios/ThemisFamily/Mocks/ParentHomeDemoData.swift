import Foundation

/// Deterministic P-023 Parent Home states, using the exact copy of the approved frames
/// (Themis Final Prototype: P-023, P-023 · Clear, P-023 · Setup incomplete,
/// P-023 · Protection problem).
///
/// Demo data only. It never means that an approval, sync or Apple enforcement happened.
enum ParentHomeDemoData {
    static let samAvatar = ChildAvatar(initial: "S", tone: .aqua)
    static let mayaAvatar = ChildAvatar(initial: "M", tone: .peach)

    static func state(for scenario: DemoScenario) -> ParentHomeState {
        switch scenario {
        case .nothingPending:
            return nothingPending
        case .setupIncomplete:
            return setupIncomplete
        case .protectionProblem:
            return protectionProblem
        case .noChildren:
            return noChildren
        case .syncPending:
            return canonical(samProtection: .syncPending, samEvidence: .verified(minutesAgo: 14))
        case .deviceOffline:
            return canonical(samProtection: .deviceOffline, samEvidence: .verified(minutesAgo: 180))
        case .protectionUnavailable:
            return canonical(samProtection: .protectionUnavailable, samEvidence: .noticed(minutesAgo: 10))
        default:
            return canonical()
        }
    }

    // MARK: P-023 canonical

    /// Sam's homework waiting for review with 18 min of grace left, Maya's request
    /// pending, Sam Protected, Maya Sync Pending.
    static func canonical(
        samProtection: ProtectionStatus = .protected,
        samEvidence: ProtectionEvidence = .verified(minutesAgo: 2)
    ) -> ParentHomeState {
        ParentHomeState(
            parentName: "Sarah",
            greeting: "Good evening",
            actionCentreCount: 2,
            attention: .needsYou(
                NeedsYouContent(
                    primary: NeedsYouPrimaryItem(
                        avatar: samAvatar,
                        title: "Sam sent homework for review",
                        grace: ApprovalGraceWindow(minutesRemaining: 18),
                        actionTitle: "Review",
                        destination: ParentHomeRoute(screenID: "A-002", title: "Review")
                    ),
                    others: [
                        NeedsYouItem(
                            id: "maya-request",
                            avatar: mayaAvatar,
                            title: "Maya asked for 15 more min",
                            detail: "Instagram · 4 min ago",
                            status: .pending,
                            destination: ParentHomeRoute(screenID: "A-004", title: "Request")
                        )
                    ]
                )
            ),
            children: [
                sam(samProtection, samEvidence, destination: samProtection == .protected ? childDetail : protectionDetail(samProtection)),
                maya(.syncPending, .verified(minutesAgo: 14), destination: protectionDetail(.syncPending, child: "Maya"))
            ],
            agreements: [homeworkDue, socialAppsPause],
            quickActions: ParentQuickAction.allCases
        )
    }

    // MARK: P-023 · Clear

    static let nothingPending = ParentHomeState(
        parentName: "Sarah",
        greeting: "Good evening",
        actionCentreCount: 0,
        attention: .nothingPending,
        children: [
            sam(.protected, .verified(minutesAgo: 0), destination: childDetail),
            maya(.protected, .verified(minutesAgo: 2), destination: nil)
        ],
        agreements: [
            AgreementSummary(
                id: "homework-done",
                title: "Homework done for today",
                detail: "Sam · Approved 6:13 PM",
                destination: ParentHomeRoute(screenID: "R-002", title: "Rule")
            ),
            socialAppsPause
        ],
        quickActions: ParentQuickAction.allCases
    )

    // MARK: P-023 · Setup incomplete

    /// Sam's pairing was deferred. Maya stays independently Protected.
    static let setupIncomplete = ParentHomeState(
        parentName: "Sarah",
        greeting: "Good evening",
        actionCentreCount: 0,
        attention: .setupIncomplete(
            HomeActionCardContent(
                avatar: samAvatar,
                title: "Finish setting up Sam",
                message: "Sam’s protection isn’t active yet. Finish pairing Sam’s iPhone to continue setup.",
                status: .notActiveYet,
                actionTitle: "Finish setup",
                destination: pairSam
            )
        ),
        children: [
            ChildStatusSummary(
                id: DemoData.samID,
                firstName: "Sam",
                segment: .child,
                avatar: samAvatar,
                protection: .notActiveYet,
                evidence: .notActiveYet,
                destination: pairSam
            ),
            maya(.protected, .verified(minutesAgo: 3), destination: protectionDetail(.protected, child: "Maya"))
        ],
        agreements: [socialAppsPause],
        quickActions: ParentQuickAction.allCases
    )

    // MARK: P-023 · Protection problem

    static let protectionProblem = ParentHomeState(
        parentName: "Sarah",
        greeting: "Good evening",
        actionCentreCount: 1,
        attention: .protectionProblem(
            HomeActionCardContent(
                avatar: samAvatar,
                title: "Sam’s protection needs attention",
                message: "Apple permission was turned off on Sam’s iPhone.",
                status: .needsAttention,
                actionTitle: "Fix this",
                destination: protectionDetail(.needsAttention)
            )
        ),
        children: [
            sam(.needsAttention, .noticed(minutesAgo: 10), destination: protectionDetail(.needsAttention)),
            maya(.protected, .verified(minutesAgo: 5), destination: nil)
        ],
        agreements: [homeworkDue],
        quickActions: ParentQuickAction.allCases
    )

    // MARK: No children (not a drawn P-023 state)

    static let noChildren = ParentHomeState(
        parentName: "Sarah",
        greeting: "Good evening",
        actionCentreCount: 0,
        attention: .noChildren,
        children: [],
        agreements: [],
        quickActions: ParentQuickAction.allCases
    )

    // MARK: Building blocks

    private static let childDetail = ParentHomeRoute(screenID: "P-029", title: "Sam")
    private static let pairSam = ParentHomeRoute(screenID: "P-009", title: "Pair Sam’s iPhone")

    private static func protectionDetail(_ status: ProtectionStatus, child: String = "Sam") -> ParentHomeRoute {
        let suffix: String
        switch status {
        case .protected: suffix = "Protected"
        case .syncPending: suffix = "Sync"
        case .deviceOffline: suffix = "Offline"
        case .needsAttention: suffix = "Attention"
        case .protectionUnavailable: suffix = "Unavailable"
        }
        return ParentHomeRoute(screenID: "P-030 · \(suffix)", title: "\(child)’s protection")
    }

    private static let homeworkDue = AgreementSummary(
        id: "homework-due",
        title: "Homework due 6:00 PM",
        detail: "Sam · School days",
        destination: ParentHomeRoute(screenID: "R-002", title: "Rule")
    )

    private static let socialAppsPause = AgreementSummary(
        id: "social-apps-pause",
        title: "Social apps pause 10:00 PM",
        detail: "Maya · Every night",
        destination: ParentHomeRoute(screenID: "R-001", title: "Rules")
    )

    private static func sam(
        _ status: ProtectionStatus,
        _ evidence: ProtectionEvidence,
        destination: ParentHomeRoute?
    ) -> ChildStatusSummary {
        ChildStatusSummary(
            id: DemoData.samID,
            firstName: "Sam",
            segment: .child,
            avatar: samAvatar,
            protection: .protection(status),
            evidence: evidence,
            destination: destination
        )
    }

    private static func maya(
        _ status: ProtectionStatus,
        _ evidence: ProtectionEvidence,
        destination: ParentHomeRoute?
    ) -> ChildStatusSummary {
        ChildStatusSummary(
            id: DemoData.mayaID,
            firstName: "Maya",
            segment: .teen,
            avatar: mayaAvatar,
            protection: .protection(status),
            evidence: evidence,
            destination: destination
        )
    }
}
