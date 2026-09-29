import Foundation

enum DemoData {
    static let samID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let mayaID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

    static func dashboard(for scenario: DemoScenario, now: Date = .now) -> ParentDashboardData {
        let samStatus: ProtectionStatus = {
            switch scenario {
            case .deviceOffline: return .deviceOffline
            case .syncPending: return .syncPending
            case .protectionUnavailable: return .protectionUnavailable
            default: return .protected
            }
        }()

        let children: [ChildProfile]
        if scenario == .noChildren {
            children = []
        } else {
            children = [
                ChildProfile(
                    id: samID,
                    firstName: "Sam",
                    experienceSegment: .child,
                    protectionStatus: samStatus,
                    lastVerified: samStatus == .deviceOffline ? now.addingTimeInterval(-3_600) : now.addingTimeInterval(-90),
                    activeRuleCount: scenario == .noRules ? 0 : 2,
                    pendingActionCount: [.waitingApproval, .approvalGrace, .requestPending].contains(scenario) ? 1 : 0
                ),
                ChildProfile(
                    id: mayaID,
                    firstName: "Maya",
                    experienceSegment: .teen,
                    protectionStatus: .protected,
                    lastVerified: now.addingTimeInterval(-45),
                    activeRuleCount: scenario == .noRules ? 0 : 2,
                    pendingActionCount: 0
                )
            ]
        }

        let requests: [AccessRequest] = {
            switch scenario {
            case .requestPending:
                return [
                    AccessRequest(
                        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                        childName: "Maya",
                        summary: "Extra Instagram time",
                        requestedDuration: "15 minutes",
                        status: .pending
                    )
                ]
            case .requestDeclined:
                return [
                    AccessRequest(
                        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                        childName: "Maya",
                        summary: "Extra Instagram time",
                        requestedDuration: "15 minutes",
                        status: .declined
                    )
                ]
            default:
                return []
            }
        }()

        let subscriptionBanner: String? = {
            switch scenario {
            case .subscriptionGrace:
                return "There’s a billing issue. Protection remains active during Apple’s billing grace period."
            case .subscriptionExpired:
                return "Protection has expired. Themis-managed restrictions have been cleared."
            default:
                return nil
            }
        }()

        return ParentDashboardData(
            ownerName: "Sarah",
            children: children,
            pendingRequests: requests,
            subscriptionBanner: subscriptionBanner
        )
    }

    static func childHome(childID: UUID, scenario: DemoScenario, now: Date = .now) -> ChildHomeData {
        let isSam = childID == samID
        let profile = dashboard(for: scenario, now: now).children.first(where: { $0.id == childID })
            ?? ChildProfile(
                id: childID,
                firstName: isSam ? "Sam" : "Maya",
                experienceSegment: isSam ? .child : .teen,
                protectionStatus: .protected,
                lastVerified: now,
                activeRuleCount: 0,
                pendingActionCount: 0
            )

        let task: TaskItem? = {
            guard isSam else { return nil }
            switch scenario {
            case .homeworkOverdue:
                return TaskItem(
                    id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                    title: "Homework",
                    dueSummary: "Due at 6:00 PM",
                    state: .overdueRestricted
                )
            case .waitingApproval:
                return TaskItem(
                    id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                    title: "Homework",
                    dueSummary: "Submitted on time",
                    state: .submittedAwaitingApproval
                )
            case .approvalGrace:
                return TaskItem(
                    id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                    title: "Homework",
                    dueSummary: "Submitted on time",
                    state: .approvalGrace(minutesRemaining: 18)
                )
            default:
                return TaskItem(
                    id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                    title: "Homework",
                    dueSummary: "Due at 6:00 PM",
                    state: .due
                )
            }
        }()

        let reasons: [String] = {
            switch scenario {
            case .homeworkOverdue:
                return ["Homework is overdue."]
            case .multipleRestrictions:
                return ["Games are paused for bedtime.", "Homework is also overdue."]
            default:
                return []
            }
        }()

        return ChildHomeData(
            child: profile,
            activeRestrictionReasons: reasons,
            task: task,
            freePassSummary: scenario == .freePassActive ? "Free Pass active for games · 22 min remaining" : nil,
            requestStatusSummary: scenario == .requestDeclined ? "Your extra-time request was declined." : nil
        )
    }
}
