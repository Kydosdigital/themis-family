import Foundation

@MainActor
final class AppContainer: ObservableObject {
    enum Perspective: String, CaseIterable, Identifiable {
        case parent = "Parent"
        case child = "Sam · Child"
        case teen = "Maya · Teen"
        case onboarding = "Onboarding"
        case rules = "Rules"
        case schoolAccess = "School Access"
        case taskDetail = "Task Detail"
        case submittedOnTime = "Submitted On Time"
        case approvalGrace = "Approval Grace"
        case overdue = "Homework Overdue"
        case gamesPaused = "Games Paused"
        case waitingRestricted = "Waiting Restricted"
        case multipleRestrictions = "Multiple Restrictions"
        case actionCentre = "Action Centre"
        case taskReview = "Task Review"
        case needsWork = "Needs Work"
        case approvalPending = "Approval Pending"
        case approvalApplied = "Approval Applied"
        case requestEntry = "Request Entry"
        case requestPending = "Request Pending"
        case requestClarification = "Request Clarification"
        case requestPartial = "Request Partial"
        case requestExpired = "Request Expired"
        case requestDetail = "Request Detail"
        case requestAskClarification = "Ask Clarification"
        case requestWaitingReply = "Waiting Reply"
        case requestAlreadyResolved = "Request Resolved"
        case requestApprovalPending = "Request Approval Pending"
        case freePassEntry = "Free Pass Entry"
        case freePassChild = "Free Pass Child"
        case freePassScope = "Free Pass Scope"
        case freePassDuration = "Free Pass Duration"
        case freePassPreview = "Free Pass Preview"
        case freePassConfirm = "Free Pass Confirm"
        case freePassActive = "Free Pass Active"
        case freePassRevoke = "Free Pass Revoke"
        case freePassRevocationSent = "Free Pass Revocation Sent"
        case freePassRevoked = "Free Pass Revoked"

        var id: String { rawValue }
    }

    let parentRepository: any ParentDashboardRepository
    let childRepository: any ChildHomeRepository

    @Published var scenario: DemoScenario
    @Published var perspective: Perspective
    @Published var onboardingInitialStep: OnboardingStep?

    init(
        parentRepository: any ParentDashboardRepository,
        childRepository: any ChildHomeRepository,
        scenario: DemoScenario = .normal,
        perspective: Perspective = .parent,
        onboardingInitialStep: OnboardingStep? = nil
    ) {
        self.parentRepository = parentRepository
        self.childRepository = childRepository
        self.scenario = scenario
        self.perspective = perspective
        self.onboardingInitialStep = onboardingInitialStep
    }

    static func preview(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppContainer {
        let onboardingStep = visualReviewOnboardingStep(from: arguments)
        return AppContainer(
            parentRepository: MockParentDashboardRepository(),
            childRepository: MockChildHomeRepository(),
            perspective: visualReviewPerspective(from: arguments) ?? (onboardingStep == nil ? .parent : .onboarding),
            onboardingInitialStep: onboardingStep
        )
    }

    /// Deterministic review-only launch selection for Release Simulator screenshot CI.
    /// Normal app launches omit the flag and continue to start in the Parent perspective.
    static func visualReviewPerspective(from arguments: [String]) -> Perspective? {
        guard let flagIndex = arguments.firstIndex(of: "--visual-review-perspective") else {
            return nil
        }
        let valueIndex = arguments.index(after: flagIndex)
        guard valueIndex < arguments.endIndex else { return nil }

        switch arguments[valueIndex].lowercased() {
        case "parent": return .parent
        case "child": return .child
        case "teen": return .teen
        case "onboarding": return .onboarding
        case "rules": return .rules
        case "school-access": return .schoolAccess
        case "task-detail": return .taskDetail
        case "submitted-on-time": return .submittedOnTime
        case "approval-grace": return .approvalGrace
        case "overdue": return .overdue
        case "games-paused": return .gamesPaused
        case "waiting-restricted": return .waitingRestricted
        case "multiple-restrictions": return .multipleRestrictions
        case "action-centre": return .actionCentre
        case "task-review": return .taskReview
        case "needs-work": return .needsWork
        case "approval-pending": return .approvalPending
        case "approval-applied": return .approvalApplied
        case "request-entry": return .requestEntry
        case "request-pending": return .requestPending
        case "request-clarification": return .requestClarification
        case "request-partial": return .requestPartial
        case "request-expired": return .requestExpired
        case "request-detail": return .requestDetail
        case "request-ask-clarification": return .requestAskClarification
        case "request-waiting-reply": return .requestWaitingReply
        case "request-already-resolved": return .requestAlreadyResolved
        case "request-approval-pending": return .requestApprovalPending
        case "free-pass-entry": return .freePassEntry
        case "free-pass-child": return .freePassChild
        case "free-pass-scope": return .freePassScope
        case "free-pass-duration": return .freePassDuration
        case "free-pass-preview": return .freePassPreview
        case "free-pass-confirm": return .freePassConfirm
        case "free-pass-active": return .freePassActive
        case "free-pass-revoke": return .freePassRevoke
        case "free-pass-revocation-sent": return .freePassRevocationSent
        case "free-pass-revoked": return .freePassRevoked
        default: return nil
        }
    }

    static func visualReviewOnboardingStep(from arguments: [String]) -> OnboardingStep? {
        guard let flagIndex = arguments.firstIndex(of: "--visual-review-onboarding-screen") else {
            return nil
        }
        let valueIndex = arguments.index(after: flagIndex)
        guard valueIndex < arguments.endIndex else { return nil }
        return OnboardingStep.from(screenID: arguments[valueIndex])
    }
}
