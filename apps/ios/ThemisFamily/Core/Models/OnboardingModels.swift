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

    static func from(screenID: String) -> OnboardingStep? {
        allCases.first { $0.screenID.caseInsensitiveCompare(screenID) == .orderedSame }
    }
}

enum OnboardingGoal: String, CaseIterable, Hashable {
    case homework = "Homework"
    case bedtime = "Bedtime"
    case gaming = "Gaming"
    case socialApps = "Social apps"
    case schoolNights = "School nights"
}

enum OnboardingExperience: String, CaseIterable, Hashable {
    case child = "Child"
    case teen = "Teen"
}

enum OnboardingVerification: String, CaseIterable, Hashable {
    case parentApproval = "Parent Approval"
}

enum OnboardingSchedule: String, CaseIterable, Hashable {
    case schoolDays = "School days"
    case everyDay = "Every day"
    case custom = "Custom"
}

enum PairingPresentationVariant: String, CaseIterable, Hashable {
    case code = "Pairing code"
    case childDevice = "Child device"
    case codeExpired = "Code expired"
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
    var schedule: OnboardingSchedule
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
        schedule: .schoolDays,
        verification: .parentApproval,
        schoolAccessPreserved: true,
        essentialAccessSummary: "Phone, Messages, Maps and school apps can be configured to stay available where supported."
    )

    static let accountCreatedTitle = "Hi Sarah. Your account is ready."
    static let accountProtectionStatus = "Not active yet. Three steps to go."
    static let emergencyAccessMessage = "Emergency calling is never deliberately restricted."
    static let systemOwnedAppleAuthorisationMessage = "Family Controls permission is shown by iOS on Sam's iPhone."
    static let systemOwnedPickerMessage = "Apple's app and website picker opens next. Themis does not draw or replace that system sheet."

    static let agreementFacts = [
        "Homework due 6:00 PM, school days",
        "Checked by Parent Approval",
        "If not approved Roblox and Minecraft pause",
        "Always Allowed Phone, Messages, Maps and school apps, where supported",
        "Sam can Ask for more time"
    ]

    static let welcomeTimeline = AgreementTimelineModel(
        startMinute: 16 * 60,
        endMinute: 22 * 60,
        ticks: ["4 PM", "6", "8", "10 PM"],
        bands: [
            .init("Homework", from: 16 * 60, to: 18 * 60, tone: .aqua),
            .init("Gaming", from: 18 * 60, to: 20 * 60, tone: .mint),
            .init("Bedtime", from: 20 * 60 + 30, to: 23 * 60, tone: .peach)
        ],
        nowMinute: 17 * 60 + 40,
        nowLabel: "5:40"
    )

    static let homeworkTimeline = AgreementTimelineModel(
        startMinute: 16 * 60,
        endMinute: 20 * 60,
        ticks: ["4 PM", "6", "8 PM"],
        bands: [
            .init("Homework", from: 16 * 60, to: 18 * 60, tone: .aqua),
            .init("Games pause", from: 18 * 60, to: 20 * 60, tone: .peach, isConditional: true)
        ]
    )
}
