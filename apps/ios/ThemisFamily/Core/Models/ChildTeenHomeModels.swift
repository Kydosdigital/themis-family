import Foundation

struct ChildTeenHomeState: Equatable, Sendable {
    enum Content: Equatable, Sendable {
        case childHomework(ChildHomeworkHomeState)
        case teen(TeenHomeState)
    }

    let screenID: String
    let audience: ExperienceSegment
    let firstName: String
    let dayLabel: String?
    let activeStatus: ThemisStatus
    let transparencyLinkTitle: String
    let content: Content
    let transparency: TransparencyState
    let essentialAccess: EssentialAccessState
}

struct ChildHomeworkHomeState: Equatable, Sendable {
    let sectionTitle: String
    let status: ThemisStatus
    let dueText: String
    let timeline: AgreementTimelineModel
    let consequence: String
    let primaryActionTitle: String
    let secondaryActionTitle: String
}

struct TeenHomeState: Equatable, Sendable {
    let nowSectionTitle: String
    let scheduleTitle: String
    let scheduleSummary: String
    let scheduleStatus: ThemisStatus
    let eveningTimeline: AgreementTimelineModel
    let todaySectionTitle: String
    let focusTitle: String
    let focusSummary: String
    let startActionTitle: String
    let requestActionTitle: String
}

struct TransparencyState: Equatable, Sendable {
    let screenID: String
    let title: String
    let intro: String
    let visibleSectionTitle: String
    let visibleFacts: [String]
    let privateSectionTitle: String
    let privateFacts: [String]

    var allFacts: [String] {
        visibleFacts + privateFacts
    }

    var exposesMessageContent: Bool {
        visibleFacts.contains { $0.localizedCaseInsensitiveContains("message") || $0.localizedCaseInsensitiveContains("chat content") }
    }

    var exposesFullBrowsingHistory: Bool {
        visibleFacts.contains { $0.localizedCaseInsensitiveContains("full browsing") || $0.localizedCaseInsensitiveContains("everything you search") }
    }

    var exposesMinuteByMinuteActivity: Bool {
        visibleFacts.contains { $0.localizedCaseInsensitiveContains("minute-by-minute") }
    }

    var modelsRawScreenTimeAsStoredByThemis: Bool {
        visibleFacts.contains { $0.localizedCaseInsensitiveContains("raw Screen Time") }
    }
}

struct EssentialAccessState: Equatable, Sendable {
    let screenID: String
    let title: String
    let intro: String
    let facts: [String]

    var guaranteesPhoneMessagesOrMaps: Bool {
        facts.contains { fact in
            let lower = fact.lowercased()
            let namesOneOfThem = lower.contains("phone") || lower.contains("messages") || lower.contains("maps")
            let explicitlyDisclaimsGuarantee =
                lower.contains("not technically guaranteed") ||
                lower.contains("not guaranteed")
            let makesGuarantee =
                (lower.contains("guaranteed") && !explicitlyDisclaimsGuarantee) ||
                lower.contains("always remain available") ||
                lower.contains("cannot be blocked")
            return namesOneOfThem && makesGuarantee
        }
    }

    var saysEmergencyCallingIsNeverDeliberatelyRestricted: Bool {
        facts.contains { $0.localizedCaseInsensitiveContains("never deliberately restricted") }
    }
}
