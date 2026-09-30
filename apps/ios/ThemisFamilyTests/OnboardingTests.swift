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
            OnboardingDemoData.accountCreatedMessage.localizedCaseInsensitiveContains("not active yet")
        )
        XCTAssertFalse(OnboardingActivationReadiness.accountOnly.canActivateProtection)
    }

    func testCanonicalChildProfileUsesFirstNameAndExplicitExperience() {
        let child = OnboardingDemoData.canonicalDraft.child
        XCTAssertEqual(child.firstName, "Sam")
        XCTAssertEqual(child.experience, .child)
    }

    func testPairingHasAllApprovedPresentationVariants() {
        XCTAssertEqual(
            Set(PairingPresentationVariant.allCases),
            Set([.code, .alreadyPaired, .recoveryRequired])
        )
    }

    func testSystemOwnedAppleStepsStayExplicitlySystemOwned() {
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedAppleAuthorisationMessage.localizedCaseInsensitiveContains("Apple")
        )
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedAppleAuthorisationMessage.localizedCaseInsensitiveContains("system")
        )
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedPickerMessage.localizedCaseInsensitiveContains("Apple")
        )
        XCTAssertTrue(
            OnboardingDemoData.systemOwnedPickerMessage.localizedCaseInsensitiveContains("system picker")
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
                "Homework is due at 6:00 PM.",
                "Roblox and Minecraft pause if the rule applies.",
                "Parent Approval confirms homework completion.",
                "School access stays available.",
                "Essential apps can be configured to stay available where supported."
            ]
        )
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
        XCTAssertEqual(viewModel.phase, 1)

        viewModel.go(to: "P-019")
        XCTAssertEqual(viewModel.step, .agreementReview)
        XCTAssertEqual(viewModel.phase, 4)

        viewModel.go(to: "P-022")
        XCTAssertEqual(viewModel.step, .activated)
        XCTAssertEqual(viewModel.phase, 5)
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
}
