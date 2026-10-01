import Foundation

// UI-10 Activity (T-001 to T-006).
//
// Reporting model (docs/22_REPORTING_AND_ANALYTICS.md §22.2):
// - Category A, Themis-owned outcomes, is modelled here as `ActivityEvent`.
// - Category B, Apple-owned Screen Time activity, is deliberately NOT modelled.
//   `AppleScreenTimeReportState` carries availability only: no usage records,
//   bundle identifiers, domains or minutes. The underlying data never leaves
//   Apple's report-extension sandbox.

/// The Themis-owned event categories Activity can show. Nothing else.
enum ActivityCategory: String, CaseIterable, Sendable {
    case rule
    case task
    case request
    case temporaryAccess
    case protection
    case session
}

enum ActivityChild: String, CaseIterable, Identifiable, Hashable, Sendable {
    case sam
    case maya

    var id: String { rawValue }

    var firstName: String {
        switch self {
        case .sam: return "Sam"
        case .maya: return "Maya"
        }
    }

    var segment: ExperienceSegment {
        switch self {
        case .sam: return .child
        case .maya: return .teen
        }
    }

    /// "Sam · Child".
    var title: String { "\(firstName) · \(segment.rawValue)" }

    var initial: String { String(firstName.prefix(1)) }

    var tone: ThemisTone {
        switch self {
        case .sam: return .aqua
        case .maya: return .peach
        }
    }

    /// "Sam’s iPhone".
    var deviceName: String { "\(firstName)’s iPhone" }
}

/// Presentation-only filter for the feed. It never changes what is stored.
enum ActivityScope: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case sam
    case maya

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .sam: return "Sam"
        case .maya: return "Maya"
        }
    }

    var child: ActivityChild? {
        switch self {
        case .all: return nil
        case .sam: return .sam
        case .maya: return .maya
        }
    }

    func includes(_ other: ActivityChild) -> Bool {
        child == nil || child == other
    }

    init(_ child: ActivityChild) {
        switch child {
        case .sam: self = .sam
        case .maya: self = .maya
        }
    }
}

/// Both times shown when timing could not be verified. Neither is treated as true:
/// Activity never rewrites the history as on time or late.
struct TimingEvidence: Equatable, Sendable {
    /// Submission time claimed by the child's device.
    let claimedByChildDevice: Date
    /// Time the Themis server received the submission.
    let serverReceived: Date

    var claimedText: String { ActivityCalendar.timeText(claimedByChildDevice) }
    var serverReceivedText: String { ActivityCalendar.timeText(serverReceived) }
}

/// One Themis-owned outcome, already resolved elsewhere. Activity displays it and
/// offers no actions.
struct ActivityEvent: Identifiable, Equatable, Sendable {
    let id: String
    let child: ActivityChild
    let occurredAt: Date
    let category: ActivityCategory
    let title: String
    /// Outcome with its glyph and label. Never colour only.
    let outcome: ThemisStatus
    let detail: String?
    /// Who resolved or granted it, where relevant ("Sarah").
    let resolver: String?
    /// Present only when timing could not be verified.
    var timing: TimingEvidence? = nil

    /// "Resolved by Sarah" / "Granted by Sarah".
    var resolverText: String? {
        guard let resolver else { return nil }
        switch category {
        case .temporaryAccess: return "Granted by \(resolver)"
        default: return "Resolved by \(resolver)"
        }
    }

    static func newestFirst(_ lhs: ActivityEvent, _ rhs: ActivityEvent) -> Bool {
        lhs.occurredAt != rhs.occurredAt ? lhs.occurredAt > rhs.occurredAt : lhs.id < rhs.id
    }
}

/// A device's current protection with the evidence for it. A status is never shown
/// without when it was last confirmed. No staleness threshold (OQ-19) lives here.
struct ProtectionNow: Identifiable, Equatable, Sendable {
    let child: ActivityChild
    let status: ThemisStatus
    /// "Verified 2 min ago", "Change waiting to reach device".
    let evidence: String

    var id: String { child.id }
}

struct ActivityDayGroup: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let events: [ActivityEvent]
}

/// Everything Category A for Activity. Apple report availability is deliberately not
/// part of it, so the two categories cannot share a container by construction.
struct ActivitySnapshot: Equatable, Sendable {
    /// Fixed "now" so the demo is deterministic.
    let referenceDate: Date
    let events: [ActivityEvent]
    let protectionNow: [ProtectionNow]

    /// Newest first, ties broken by id.
    func events(for scope: ActivityScope, categories: Set<ActivityCategory>? = nil) -> [ActivityEvent] {
        events
            .filter { scope.includes($0.child) && (categories?.contains($0.category) ?? true) }
            .sorted(by: ActivityEvent.newestFirst)
    }

    func event(id: String) -> ActivityEvent? {
        events.first { $0.id == id }
    }

    func protectionNow(for scope: ActivityScope) -> [ProtectionNow] {
        protectionNow.filter { scope.includes($0.child) }
    }

    /// Consecutive events on the same day, in the order given.
    func dayGroups(for events: [ActivityEvent]) -> [ActivityDayGroup] {
        var groups: [ActivityDayGroup] = []
        for event in events {
            let key = ActivityCalendar.dayKey(event.occurredAt)
            if let last = groups.last, last.id == key {
                groups[groups.count - 1] = ActivityDayGroup(id: key, title: last.title, events: last.events + [event])
            } else {
                groups.append(
                    ActivityDayGroup(
                        id: key,
                        title: ActivityCalendar.dayLabel(for: event.occurredAt, relativeTo: referenceDate),
                        events: [event]
                    )
                )
            }
        }
        return groups
    }
}

/// Availability and presentation of Apple's own Screen Time report (T-006).
///
/// This carries NO usage data. Raw app and website usage stays inside Apple's
/// `DeviceActivityReport` sandbox, and the real cross-device capability on the
/// parent's device is still the Priority 8 spike.
enum AppleScreenTimeReportState: String, CaseIterable, Sendable {
    /// Review state: the bounded, Apple-owned area where Apple's report would appear.
    case systemOwnedReportArea
    /// Apple's report isn't available on this device right now.
    case unavailable
}

/// T-006 copy, kept in one place so it can be tested.
enum AppleScreenTimeCopy {
    static let title = "Apple Screen Time"
    static let sectionLabel = "Shown by Apple"
    static let areaLabel = "Apple-owned report area"
    static let areaTitle = "Apple Screen Time"
    static let areaDetail = "Rendered by Apple. What appears depends on Apple and the device."
    static let reportExpectation = "When available, Apple’s Screen Time report appears here."
    static let privacy = "Themis does not receive, store or export the underlying app and website usage data."
    static let separation = "Themis activity (tasks, requests, passes, protection) is separate and stays in the Activity tab."
    static let unavailableMessage = "Screen Time report isn’t available on this device right now."
    static let unavailableSupport = "Your Themis activity history still shows rule, task, request, temporary-access and protection outcomes."

    /// Every sentence shown for a state, for copy checks.
    static func allCopy(for state: AppleScreenTimeReportState) -> [String] {
        switch state {
        case .systemOwnedReportArea:
            return [title, sectionLabel, areaLabel, areaTitle, areaDetail, reportExpectation, privacy, separation]
        case .unavailable:
            return [title, sectionLabel, unavailableMessage, unavailableSupport, privacy, separation]
        }
    }
}

/// Static Activity copy outside T-006.
enum ActivityCopy {
    static let overviewIntro = "Outcomes from your family’s Themis rules."
    static let overviewFooter = "Activity shows what happened with your family’s Themis rules. It isn’t a record of everything your children do."
    static let emptyTitle = "No activity yet"
    static let emptyMessage = "Activity appears after the first day with Themis."
    static let loadError = "We couldn’t load your activity right now."
    static let protectionFooter = "Each status shows when Themis last confirmed it."
    static let timingExplanation = "Themis could not verify which submission time should be trusted."

    static func appUsageNote(for child: ActivityChild) -> String {
        "Themis doesn’t show which apps \(child.firstName) used or for how long."
    }
}

/// Navigation targets inside the Activity stack.
enum ActivityRoute: Hashable, Sendable {
    case child(ActivityChild)
    case ruleHistory(ActivityScope)
    case requestHistory(ActivityScope)
    case protectionHistory(ActivityScope)
    case appleScreenTime
    case eventDetail(String)
}

/// Fixed-calendar formatting so demo output never depends on the device's locale or
/// time zone. UTC, Gregorian, 12-hour clock as drawn ("5:48 PM").
enum ActivityCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    private static let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private static let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    /// "5:48 PM".
    static func timeText(_ date: Date) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let hour24 = parts.hour ?? 0
        let minute = parts.minute ?? 0
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        return "\(hour12):" + String(format: "%02d", minute) + (hour24 >= 12 ? " PM" : " AM")
    }

    /// Stable key for grouping by day.
    static func dayKey(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-" + String(format: "%02d", parts.month ?? 0) + "-" + String(format: "%02d", parts.day ?? 0)
    }

    /// "Today", "Yesterday", a weekday within the last week, otherwise "26 Sep".
    static func dayLabel(for date: Date, relativeTo reference: Date) -> String {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: reference)
        ).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Yesterday"
        case 2...6: return weekdayNames[calendar.component(.weekday, from: date) - 1]
        default:
            let parts = calendar.dateComponents([.day, .month], from: date)
            return "\(parts.day ?? 1) \(monthNames[(parts.month ?? 1) - 1])"
        }
    }
}
