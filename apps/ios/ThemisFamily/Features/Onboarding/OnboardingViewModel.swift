import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep
    @Published var goal: OnboardingGoal? = .homework
    @Published var childName: String = "Sam"
    @Published var experience: OnboardingExperience = .child
    @Published var pairingVariant: PairingPresentationVariant = .code
    @Published var testResult: ProtectionTestPresentationResult = .success
    @Published var deadline: Date

    init(initialStep: OnboardingStep = .launch) {
        self.step = initialStep
        self.deadline = Calendar.current.date(
            bySettingHour: OnboardingDemoData.canonicalDraft.deadlineHour,
            minute: OnboardingDemoData.canonicalDraft.deadlineMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    var phase: Int {
        switch step {
        case .launch, .welcome, .signInWithApple, .accountCreated, .goal:
            return 1
        case .addChild, .chooseExperience, .childCreated, .pairDeviceIntro, .pairing:
            return 2
        case .familyControlsExplanation, .appleAuthorisationHandoff:
            return 3
        case .starterRule, .homeworkDeadlineStarter, .controlledApps, .deadline, .verification, .essentialAccess, .agreementReview:
            return 4
        case .protectionTest, .protectionTestResult, .activated:
            return 5
        }
    }

    var phaseLabel: String {
        switch phase {
        case 1: return "Start"
        case 2: return "Sam and this device"
        case 3: return "Apple permission"
        case 4: return "First family rule"
        default: return "Test and activate"
        }
    }

    var canGoBack: Bool {
        step != .launch
    }

    var canonicalDraft: OnboardingDraft {
        var draft = OnboardingDemoData.canonicalDraft
        draft.goal = goal ?? .homework
        draft.child = OnboardingChildProfile(
            firstName: childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Sam" : childName,
            experience: experience
        )
        let components = Calendar.current.dateComponents([.hour, .minute], from: deadline)
        draft.deadlineHour = components.hour ?? 18
        draft.deadlineMinute = components.minute ?? 0
        return draft
    }

    var activationReadiness: OnboardingActivationReadiness {
        guard testResult == .success else {
            return OnboardingActivationReadiness(
                accountCreated: true,
                childCreated: true,
                devicePaired: pairingVariant != .recoveryRequired,
                appleAuthorisationGranted: testResult != .permissionRequired,
                hasActiveRuleTarget: true,
                testShieldApplied: testResult == .success,
                testShieldRemoved: false,
                resultingStateVerified: false
            )
        }
        return .canonicalActivated
    }

    func advance() {
        guard let index = OnboardingStep.allCases.firstIndex(of: step) else { return }
        let nextIndex = OnboardingStep.allCases.index(after: index)
        guard nextIndex < OnboardingStep.allCases.endIndex else { return }
        step = OnboardingStep.allCases[nextIndex]
    }

    func retreat() {
        guard let index = OnboardingStep.allCases.firstIndex(of: step),
              index > OnboardingStep.allCases.startIndex else { return }
        step = OnboardingStep.allCases[OnboardingStep.allCases.index(before: index)]
    }

    func go(to screenID: String) {
        if let step = OnboardingStep.from(screenID: screenID) {
            self.step = step
        }
    }

    func retryProtectionTest() {
        testResult = .success
        step = .protectionTest
    }
}
