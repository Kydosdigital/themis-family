import XCTest
@testable import ThemisFamily

final class OnboardingStateTests: XCTestCase {
    func testOnboardingScreenOrderIsP001ThroughP022() {
        XCTAssertEqual(OnboardingStep.allCases.count, 22)
        XCTAssertEqual(
            OnboardingStep.allCases.map(\.screenID),
            (1...22).map { String(format: "P-%03d", $0) }
        )
    }

    func testAccountCreationNeverClaimsProtectionIsActive() {
        XCTAssertTrue(
            OnboardingDemoData.accountProtectionStatus.localizedCaseInsensitiveContains("not active yet")
        )
        XCTAssertFalse(OnboardingActivationReadiness.accountOnly.canActivateProtection)
    }

    func testCanonicalChildProfileUsesFirstNameExplicitExperienceAndSchoolDays() {
        let draft = OnboardingDemoData.canonicalDraft
        XCTAssertEqual(draft.child.firstName, "Sam")
        XCTAssertEqual(draft.child.experience, .child)
        XCTAssertEqual(draft.schedule, .schoolDays)
        XCTAssertEqual(draft.deadlineDisplay, "6:00 PM")
    }

    func testPairingHasAllApprovedPresentationVariants() {
        XCTAssertEqual(
            Set(PairingPresentationVariant.allCases),
            Set([.code, .childDevice, .codeExpired, .alreadyPaired, .recoveryRequired])
        )
    }

    func testSystemOwnedAppleStepsStayExplicitlySystemOwned() {
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedAppleAuthorisationMessage.localizedCaseInsensitiveContains("iOS")
        )
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedAppleAuthorisationMessage.localizedCaseInsensitiveContains("Family Controls")
        )
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedPickerMessage.localizedCaseInsensitiveContains("Apple")
        )
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedPickerMessage.localizedCaseInsensitiveContains("system sheet")
        )
    }

    func testCanonicalGenericHomeworkOnlyOffersParentApproval() {
        XCTAssertEqual(OnboardingVerification.allCases, [.parentApproval])
        XCTAssertEqual(OnboardingDemoData.canonicalDraft.verification, .parentApproval)
    }

    func testEssentialAccessCopyKeepsAppleBoundaryAndEmergencyCallingRule() {
        XCTAssertTrue(
            OnboardingDemoData.canonicalDraft.essentialAccessSummary.localizedCaseInsensitiveContains("where supported")
        )
        XCTAssertTrue(
            OnboardingDemoData.emergencyAccessMessage.localizedCaseInsensitiveContains("never deliberately restricted")
        )
    }

    func testAgreementReviewKeepsCanonicalFacts() {
        XCTAssertEqual(
            OnboardingDemoData.agreementFacts,
            [
                "Homework due 6:00 PM, school days",
                "Checked by Parent Approval",
                "If not approved Roblox and Minecraft pause",
                "Always Allowed Phone, Messages, Maps and school apps, where supported",
                "Sam can Ask for more time"
            ]
        )
    }

    func testWelcomeAndHomeworkTimelinesKeepCanonicalTimes() {
        XCTAssertEqual(OnboardingDemoData.welcomeTimeline.ticks, ["4 PM", "6", "8", "10 PM"])
        XCTAssertEqual(OnboardingDemoData.welcomeTimeline.nowLabel, "5:40")
        XCTAssertEqual(OnboardingDemoData.homeworkTimeline.ticks, ["4 PM", "6", "8 PM"])
        XCTAssertTrue(OnboardingDemoData.homeworkTimeline.bands.contains(where: {
            $0.label == "Games pause" && $0.isConditional && $0.startMinute == 18 * 60
        }))
    }

    func testActivationRequiresEveryRequiredCondition() {
        XCTAssertTrue(OnboardingActivationReadiness.canonicalActivated.canActivateProtection)

        let keyPaths: [WritableKeyPath<OnboardingActivationReadiness, Bool>] = [
            \.accountCreated,
            \.childCreated,
            \.devicePaired,
            \.appleAuthorisationGranted,
            \.hasActiveRuleTarget,
            \.testShieldApplied,
            \.testShieldRemoved,
            \.resultingStateVerified
        ]

        for keyPath in keyPaths {
            var readiness = OnboardingActivationReadiness.canonicalActivated
            readiness[keyPath: keyPath] = false
            XCTAssertFalse(readiness.canActivateProtection)
        }
    }

    @MainActor
    func testApprovedFiveChapterIndicatorsAppearAtCanonicalEntries() {
        let viewModel = OnboardingViewModel(initialStep: .goal)
        XCTAssertEqual(viewModel.progressStep, 1)
        XCTAssertEqual(viewModel.progressLabel, "Step 1 of 5 · Your family")

        viewModel.step = .addChild
        XCTAssertEqual(viewModel.progressStep, 2)
        XCTAssertEqual(viewModel.progressLabel, "Step 2 of 5 · Your child")

        viewModel.step = .pairDeviceIntro
        XCTAssertEqual(viewModel.progressStep, 3)
        XCTAssertEqual(viewModel.progressLabel, "Step 3 of 5 · Sam's iPhone")

        viewModel.step = .familyControlsExplanation
        XCTAssertEqual(viewModel.progressStep, 4)
        XCTAssertEqual(viewModel.progressLabel, "Step 4 of 5 · Permission")

        viewModel.step = .starterRule
        XCTAssertEqual(viewModel.progressStep, 5)
        XCTAssertEqual(viewModel.progressLabel, "Step 5 of 5 · First rule")

        viewModel.step = .agreementReview
        XCTAssertNil(viewModel.progressStep)
        XCTAssertNil(viewModel.progressLabel)
    }

    @MainActor
    func testHomeworkStarterLightweightStateDoesNotAddAnExtraTapStop() {
        let viewModel = OnboardingViewModel(initialStep: .starterRule)
        viewModel.advance()
        XCTAssertEqual(viewModel.step, .controlledApps)

        viewModel.go(to: "P-014")
        XCTAssertEqual(viewModel.step, .homeworkDeadlineStarter)
    }

    @MainActor
    func testVisualReviewLaunchArgumentsSelectOnboardingDeterministically() {
        XCTAssertEqual(
            AppContainer.visualReviewPerspective(from: ["ThemisFamily", "--visual-review-perspective", "onboarding"]),
            .onboarding
        )
        XCTAssertEqual(
            AppContainer.visualReviewOnboardingStep(from: ["ThemisFamily", "--visual-review-onboarding-screen", "P-019"]),
            .agreementReview
        )
        XCTAssertNil(
            AppContainer.visualReviewOnboardingStep(from: ["ThemisFamily", "--visual-review-onboarding-screen", "P-099"])
        )
    }

    @MainActor
    func testViewModelCanResumeAtDeterministicScreenID() {
        let viewModel = OnboardingViewModel(initialStep: .welcome)
        XCTAssertEqual(viewModel.step, .welcome)
        XCTAssertNil(viewModel.progressStep)

        viewModel.go(to: "P-019")
        XCTAssertEqual(viewModel.step, .agreementReview)
        XCTAssertNil(viewModel.progressStep)

        viewModel.go(to: "P-022")
        XCTAssertEqual(viewModel.step, .activated)
        XCTAssertNil(viewModel.progressStep)
    }

    @MainActor
    func testFailedProtectionResultCannotReachActivationReadiness() {
        let viewModel = OnboardingViewModel(initialStep: .protectionTestResult)
        viewModel.testResult = .retry
        XCTAssertFalse(viewModel.activationReadiness.canActivateProtection)

        viewModel.testResult = .permissionRequired
        XCTAssertFalse(viewModel.activationReadiness.canActivateProtection)

        viewModel.testResult = .success
        XCTAssertTrue(viewModel.activationReadiness.canActivateProtection)
    }

    @MainActor
    func testPairingRecoveryStateNeverCountsAsActivationReady() {
        let viewModel = OnboardingViewModel(initialStep: .pairing)
        viewModel.pairingVariant = .recoveryRequired
        viewModel.testResult = .retry
        XCTAssertFalse(viewModel.activationReadiness.canActivateProtection)
    }
}
