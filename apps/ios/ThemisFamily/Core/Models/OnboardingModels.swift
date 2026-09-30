import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable, Hashable {
    case launch
    case welcome
    case signInWithApple
    case accountCreated
    case goal
    case addChild
    case chooseExperience
    case childCreated
    case pairDeviceIntro
    case pairing
    case familyControlsExplanation
    case appleAuthorisationHandoff
    case starterRule
    case homeworkDeadlineStarter
    case controlledApps
    case deadline
    case verification
    case essentialAccess
    case agreementReview
    case protectionTest
    case protectionTestResult
    case activated

    var id: String { screenID }

    var screenID: String {
        switch self {
        case .launch: return "P-001"
        case .welcome: return "P-002"
        case .signInWithApple: return "P-003"
        case .accountCreated: return "P-004"
        case .goal: return "P-005"
        case .addChild: return "P-006"
        case .chooseExperience: return "P-007"
        case .childCreated: return "P-008"
        case .pairDeviceIntro: return "P-009"
        case .pairing: return "P-010"
        case .familyControlsExplanation: return "P-011"
        case .appleAuthorisationHandoff: return "P-012"
        case .starterRule: return "P-013"
        case .homeworkDeadlineStarter: return "P-014"
        case .controlledApps: return "P-015"
        case .deadline: return "P-016"
        case .verification: return "P-017"
        case .essentialAccess: return "P-018"
        case .agreementReview: return "P-019"
        case .protectionTest: return "P-020"
        case .protectionTestResult: return "P-021"
        case .activated: return "P-022"
        }
    }

    var ordinal: Int { rawValue + 1 }

    static func from(screenID: String) -> OnboardingStep? {
        allCases.first { $0.screenID.caseInsensitiveCompare(screenID) == .orderedSame }
    }
}

enum OnboardingGoal: String, CaseIterable, Hashable {
    case homework = "Homework"
    case bedtime = "Bedtime"
    case gaming = "Gaming"
    case social = "Social"
    case schoolNights = "School nights"
}

enum OnboardingExperience: String, CaseIterable, Hashable {
    case child = "Child"
    case teen = "Teen"
}

enum OnboardingVerification: String, CaseIterable, Hashable {
    case parentApproval = "Parent Approval"
}

enum PairingPresentationVariant: String, CaseIterable, Hashable {
    case code = "Pairing code"
    case alreadyPaired = "Already paired"
    case recoveryRequired = "Recovery required"
}

enum ProtectionTestPresentationResult: String, CaseIterable, Hashable {
    case success = "Success"
    case retry = "Retry"
    case permissionRequired = "Permission required"
}

struct OnboardingChildProfile: Equatable, Hashable {
    var firstName: String
    var experience: OnboardingExperience
}

struct OnboardingDraft: Equatable {
    var ownerName: String
    var goal: OnboardingGoal
    var child: OnboardingChildProfile
    var controlledTargets: [String]
    var deadlineHour: Int
    var deadlineMinute: Int
    var verification: OnboardingVerification
    var schoolAccessPreserved: Bool
    var essentialAccessSummary: String

    var deadlineDisplay: String {
        let hour12 = deadlineHour % 12 == 0 ? 12 : deadlineHour % 12
        let suffix = deadlineHour >= 12 ? "PM" : "AM"
        return String(format: "%d:%02d %@", hour12, deadlineMinute, suffix)
    }
}

struct OnboardingActivationReadiness: Equatable {
    var accountCreated: Bool
    var childCreated: Bool
    var devicePaired: Bool
    var appleAuthorisationGranted: Bool
    var hasActiveRuleTarget: Bool
    var testShieldApplied: Bool
    var testShieldRemoved: Bool
    var resultingStateVerified: Bool

    var canActivateProtection: Bool {
        accountCreated
            && childCreated
            && devicePaired
            && appleAuthorisationGranted
            && hasActiveRuleTarget
            && testShieldApplied
            && testShieldRemoved
            && resultingStateVerified
    }

    static let accountOnly = OnboardingActivationReadiness(
        accountCreated: true,
        childCreated: false,
        devicePaired: false,
        appleAuthorisationGranted: false,
        hasActiveRuleTarget: false,
        testShieldApplied: false,
        testShieldRemoved: false,
        resultingStateVerified: false
    )

    static let canonicalActivated = OnboardingActivationReadiness(
        accountCreated: true,
        childCreated: true,
        devicePaired: true,
        appleAuthorisationGranted: true,
        hasActiveRuleTarget: true,
        testShieldApplied: true,
        testShieldRemoved: true,
        resultingStateVerified: true
    )
}

enum OnboardingDemoData {
    static let canonicalDraft = OnboardingDraft(
        ownerName: "Sarah",
        goal: .homework,
        child: OnboardingChildProfile(firstName: "Sam", experience: .child),
        controlledTargets: ["Roblox", "Minecraft"],
        deadlineHour: 18,
        deadlineMinute: 0,
        verification: .parentApproval,
        schoolAccessPreserved: true,
        essentialAccessSummary: "School access stays available. Phone, Messages and Maps can be configured to stay available where supported."
    )

    static let accountCreatedMessage = "Your account is ready. Protection is not active yet."

    static let emergencyAccessMessage = "Emergency calling and iOS emergency functionality are never deliberately restricted."

    static let systemOwnedAppleAuthorisationMessage = "Apple provides the Family Controls permission step. Themis explains why it is needed, then hands over to the system flow."

    static let systemOwnedPickerMessage = "Apps and websites are chosen with Apple's system picker. Themis does not replace it with its own app catalogue."

    static let agreementFacts = [
        "Homework is due at 6:00 PM.",
        "Roblox and Minecraft pause if the rule applies.",
        "Parent Approval confirms homework completion.",
        "School access stays available.",
        "Essential apps can be configured to stay available where supported."
    ]
}
