import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var parentTab: ParentTab = .home
    @State private var childTab: ChildTab = .home

    var body: some View {
        switch container.perspective {
        case .parent:
            ParentTabShell(selection: $parentTab) { tab in
                parentRoot(tab)
                    .demoControls()
            }
        case .child:
            childShell(segment: .child, childID: DemoData.samID)
        case .teen:
            childShell(segment: .teen, childID: DemoData.mayaID)
        case .rules:
            NavigationStack { RulesSchoolAccessView(initialSection: .rules) }
                .demoControls()
        case .schoolAccess:
            NavigationStack { RulesSchoolAccessView(initialSection: .schoolAccess) }
                .demoControls()
        case .taskDetail:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.taskDetail, surfaceAudience: .child)
            }
            .demoControls()
        case .submittedOnTime:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.submittedOnTime, surfaceAudience: .child)
            }
            .demoControls()
        case .approvalGrace:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.approvalGrace, surfaceAudience: .child)
            }
            .demoControls()
        case .overdue:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.overdue, surfaceAudience: .child)
            }
            .demoControls()
        case .gamesPaused:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.gamesPaused, surfaceAudience: .child)
            }
            .demoControls()
        case .waitingRestricted:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.waitingRestricted, surfaceAudience: .child)
            }
            .demoControls()
        case .multipleRestrictions:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.multipleRestrictions, surfaceAudience: .child)
            }
            .demoControls()
        case .actionCentre:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.actionCentre, surfaceAudience: .parent)
            }
            .demoControls()
        case .taskReview:
            NavigationStack {
                TasksDeadlineLockView(state: TasksDeadlineLockDemoData.parentTaskReview, surfaceAudience: .parent)
            }
            .demoControls()
        case .needsWork:
            NavigationStack {
                NeedsWorkTaskView(state: TasksDeadlineLockDemoData.needsWork)
            }
            .demoControls()
        case .approvalPending:
            NavigationStack {
                ApprovalApplicationStatusView(state: TasksDeadlineLockDemoData.approvedPendingDevice)
            }
            .demoControls()
        case .approvalApplied:
            NavigationStack {
                ApprovalApplicationStatusView(state: TasksDeadlineLockDemoData.appliedOnDevice)
            }
            .demoControls()
        case .requestEntry:
            NavigationStack { RequestComposerView(audience: .teen) }
                .demoControls()
        case .requestPending:
            NavigationStack { RequestStateView(state: RequestsDemoData.pending) }
                .demoControls()
        case .requestClarification:
            NavigationStack { RequestStateView(state: RequestsDemoData.clarificationReceived) }
                .demoControls()
        case .requestPartial:
            NavigationStack { RequestStateView(state: RequestsDemoData.partial) }
                .demoControls()
        case .requestExpired:
            NavigationStack { RequestStateView(state: RequestsDemoData.expired) }
                .demoControls()
        case .requestDetail:
            NavigationStack { RequestStateView(state: RequestsDemoData.parentDetail, surfaceAudience: .parent) }
                .demoControls()
        case .requestAskClarification:
            NavigationStack { ParentRequestFlowView(initial: .askClarification) }
                .demoControls()
        case .requestWaitingReply:
            NavigationStack { RequestStateView(state: RequestsDemoData.waitingForReply, surfaceAudience: .parent) }
                .demoControls()
        case .requestAlreadyResolved:
            NavigationStack { RequestStateView(state: RequestsDemoData.alreadyResolved, surfaceAudience: .parent) }
                .demoControls()
        case .requestApprovalPending:
            NavigationStack { RequestStateView(state: RequestsDemoData.approvedPendingDevice, surfaceAudience: .parent) }
                .demoControls()
        case .freePassEntry:
            NavigationStack { FreePassFlowView(initialStep: .entry) }
                .demoControls()
        case .freePassChild:
            NavigationStack { FreePassFlowView(initialStep: .child) }
                .demoControls()
        case .freePassScope:
            NavigationStack { FreePassFlowView(initialStep: .scope) }
                .demoControls()
        case .freePassDuration:
            NavigationStack { FreePassFlowView(initialStep: .duration) }
                .demoControls()
        case .freePassPreview:
            NavigationStack { FreePassFlowView(initialStep: .preview) }
                .demoControls()
        case .freePassConfirm:
            NavigationStack { FreePassFlowView(initialStep: .confirm) }
                .demoControls()
        case .freePassActive:
            NavigationStack { FreePassFlowView(initialStep: .active) }
                .demoControls()
        case .freePassRevoke:
            NavigationStack { FreePassFlowView(initialStep: .revoke) }
                .demoControls()
        case .freePassRevocationSent:
            NavigationStack { FreePassFlowView(initialStep: .revocationSent) }
                .demoControls()
        case .freePassRevoked:
            NavigationStack { FreePassFlowView(initialStep: .revoked) }
                .demoControls()
        case .onboarding:
            OnboardingView(
                initialStep: container.onboardingInitialStep ?? .launch,
                onComplete: {
                    container.scenario = .normal
                    container.onboardingInitialStep = nil
                    container.perspective = .parent
                },
                onDefer: {
                    container.scenario = .setupIncomplete
                    container.onboardingInitialStep = nil
                    container.perspective = .parent
                }
            )
            .demoControls()
        }
    }

    @ViewBuilder
    private func parentRoot(_ tab: ParentTab) -> some View {
        switch tab {
        case .home:
            ParentHomeView(
                repository: container.parentRepository,
                scenario: container.scenario
            )
        case .rules:
            NavigationStack { RulesSchoolAccessView() }
        case .activity, .settings:
            ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID)
        }
    }

    private func childShell(segment: ExperienceSegment, childID: UUID) -> some View {
        ChildTabShell(segment: segment, selection: $childTab) { tab in
            Group {
                switch tab {
                case .home:
                    ChildHomeView(
                        childID: childID,
                        repository: container.childRepository,
                        scenario: container.scenario
                    )
                case .myRules:
                    ShellPlaceholderView(title: tab.title, screenID: tab.rootScreenID(for: segment))
                case .requests:
                    RequestHistoryView(audience: segment)
                }
            }
            .demoControls()
        }
    }
}
