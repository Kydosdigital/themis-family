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
    @Published var schedule: OnboardingSchedule = .schoolDays
    @Published var isTestingProtection = false

    init(initialStep: OnboardingStep = .launch) {
        self.step = initialStep
        self.deadline = Calendar.current.date(
            bySettingHour: OnboardingDemoData.canonicalDraft.deadlineHour,
            minute: OnboardingDemoData.canonicalDraft.deadlineMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    var progressStep: Int? {
        switch step {
        case .launch, .welcome, .signInWithApple, .accountCreated:
            return nil
        case .goal:
            return 1
        case .addChild, .chooseExperience, .childCreated:
            return 2
        case .pairDeviceIntro, .pairing:
            return 3
        case .familyControlsExplanation, .appleAuthorisationHandoff:
            return 4
        case .starterRule, .homeworkDeadlineStarter, .controlledApps, .deadline,
             .verification, .essentialAccess, .agreementReview, .protectionTest,
             .protectionTestResult, .activated:
            return 5
        }
    }

    var progressLabel: String? {
        guard let progressStep else { return nil }
        switch progressStep {
        case 1: return "Step 1 of 5 · Your family"
        case 2: return "Step 2 of 5 · Your child"
        case 3: return "Step 3 of 5 · \(safeChildName)'s iPhone"
        case 4: return "Step 4 of 5 · Permission"
        default: return "Step 5 of 5 · First rule"
        }
    }

    var canGoBack: Bool {
        step != .launch
    }

    var safeChildName: String {
        let trimmed = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Sam" : trimmed
    }

    var canonicalDraft: OnboardingDraft {
        var draft = OnboardingDemoData.canonicalDraft
        draft.goal = goal ?? .homework
        draft.child = OnboardingChildProfile(firstName: safeChildName, experience: experience)
        let components = Calendar.current.dateComponents([.hour, .minute], from: deadline)
        draft.deadlineHour = components.hour ?? 18
        draft.deadlineMinute = components.minute ?? 0
        draft.schedule = schedule
        return draft
    }

    var activationReadiness: OnboardingActivationReadiness {
        guard testResult == .success else {
            return OnboardingActivationReadiness(
                accountCreated: true,
                childCreated: true,
                devicePaired: pairingVariant != .recoveryRequired && pairingVariant != .alreadyPaired,
                appleAuthorisationGranted: testResult != .permissionRequired,
                hasActiveRuleTarget: true,
                testShieldApplied: false,
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

        // P-014 is a lightweight selected-starter state inside P-013 in the approved
        // flow. Keep it addressable for review, but do not add a tap-stop.
        if step == .starterRule {
            self.step = .controlledApps
            return
        }

        self.step = OnboardingStep.allCases[nextIndex]
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

    func runProtectionTest() async {
        isTestingProtection = true
        try? await Task.sleep(for: .milliseconds(700))
        guard !Task.isCancelled else { return }
        isTestingProtection = false
        step = .protectionTestResult
    }

    func retryProtectionTest() {
        testResult = .success
        isTestingProtection = false
        step = .protectionTest
    }
}
